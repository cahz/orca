library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.rv_components.all;
use work.utils.all;
use work.constants_pkg.all;

entity cache_controller is
  generic (
    CACHE_SIZE            : natural;
    LINE_SIZE             : positive range 16 to 256;
    ADDRESS_WIDTH         : positive;
    INTERNAL_WIDTH        : positive;
    EXTERNAL_WIDTH        : positive;
    LOG2_BURSTLENGTH      : positive;
    POLICY                : cache_policy;
    REGION_OPTIMIZATIONS  : boolean;
    WRITE_FIRST_SUPPORTED : boolean
    );
  port (
    clk   : in std_logic;
    reset : in std_logic;

    --Cache control (Invalidate/flush/writeback)
    from_cache_control_ready : out std_logic;
    to_cache_control_valid   : in  std_logic;
    to_cache_control_command : in  cache_control_command;
    to_cache_control_base    : in  std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    to_cache_control_last    : in  std_logic_vector(ADDRESS_WIDTH-1 downto 0);

    precache_idle : in  std_logic;
    cache_idle    : out std_logic;

    --Cache interface ORCA-internal memory-mapped slave
    cacheint_oimm_address       : in     std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    cacheint_oimm_byteenable    : in     std_logic_vector((INTERNAL_WIDTH/8)-1 downto 0);
    cacheint_oimm_requestvalid  : in     std_logic;
    cacheint_oimm_readnotwrite  : in     std_logic;
    cacheint_oimm_writedata     : in     std_logic_vector(INTERNAL_WIDTH-1 downto 0);
    cacheint_oimm_readdata      : out    std_logic_vector(INTERNAL_WIDTH-1 downto 0);
    cacheint_oimm_readdatavalid : out    std_logic;
    cacheint_oimm_waitrequest   : buffer std_logic;

    --Cached ORCA-internal memory-mapped master
    c_oimm_address            : out std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    c_oimm_burstlength        : out std_logic_vector(LOG2_BURSTLENGTH downto 0);
    c_oimm_burstlength_minus1 : out std_logic_vector(LOG2_BURSTLENGTH-1 downto 0);
    c_oimm_byteenable         : out std_logic_vector((EXTERNAL_WIDTH/8)-1 downto 0);
    c_oimm_requestvalid       : out std_logic;
    c_oimm_readnotwrite       : out std_logic;
    c_oimm_writedata          : out std_logic_vector(EXTERNAL_WIDTH-1 downto 0);
    c_oimm_writelast          : out std_logic;
    c_oimm_readdata           : in  std_logic_vector(EXTERNAL_WIDTH-1 downto 0);
    c_oimm_readdatavalid      : in  std_logic;
    c_oimm_waitrequest        : in  std_logic
    );
end entity cache_controller;

architecture rtl of cache_controller is
  constant DIRTY_BITS                       : natural  := conditional(POLICY = WRITE_BACK, 1, 0);
  constant NUM_LINES                        : positive := CACHE_SIZE/LINE_SIZE;
  constant TAG_BITS                         : positive := ADDRESS_WIDTH-log2(CACHE_SIZE);
  constant TAG_LEFT                         : natural  := ADDRESS_WIDTH-1;
  constant TAG_RIGHT                        : natural  := log2(NUM_LINES)+log2(LINE_SIZE);
  constant CACHELINE_BITS                   : positive := log2(NUM_LINES);
  constant CACHELINE_RIGHT                  : natural  := log2(LINE_SIZE);
  constant INTERNAL_WORDS_PER_EXTERNAL_WORD : positive := EXTERNAL_WIDTH/INTERNAL_WIDTH;

  alias to_cache_control_base_tag_line : std_logic_vector(TAG_BITS+CACHELINE_BITS-1 downto 0) is
    to_cache_control_base(TAG_LEFT downto CACHELINE_RIGHT);
  alias to_cache_control_last_tag_line : std_logic_vector(TAG_BITS+CACHELINE_BITS-1 downto 0) is
    to_cache_control_last(TAG_LEFT downto CACHELINE_RIGHT);
  signal to_cache_control_base_partial : std_logic;
  signal to_cache_control_last_partial : std_logic;

  signal cache_walker_read_tag_line : std_logic_vector(TAG_BITS+CACHELINE_BITS-1 downto 0);

  signal read_region_base_hit    : std_logic;
  signal read_region_inner_hit   : std_logic;
  signal read_region_last_hit    : std_logic;
  signal read_region_hit         : std_logic;
  signal read_region_hit_partial : std_logic;

  function compute_burst_length
    return positive is
  begin  -- function compute_burst_length
    if LINE_SIZE/(EXTERNAL_WIDTH/8) > (2**LOG2_BURSTLENGTH) then
      return 2**LOG2_BURSTLENGTH;
    end if;

    return LINE_SIZE/(EXTERNAL_WIDTH/8);
  end function compute_burst_length;

  constant BYTES_PER_BEAT  : positive                                  := EXTERNAL_WIDTH/8;
  constant BEATS_PER_BURST : positive range 1 to (2**LOG2_BURSTLENGTH) := compute_burst_length;
  constant BYTES_PER_BURST : positive                                  := BYTES_PER_BEAT*BEATS_PER_BURST;
  constant BEATS_PER_LINE  : positive                                  := LINE_SIZE/BYTES_PER_BEAT;
  constant BURSTS_PER_LINE : positive                                  := LINE_SIZE/BYTES_PER_BURST;

  signal read_miss            : std_logic;
  signal read_requestinflight : std_logic;
  signal read_lastaddress     : std_logic_vector(ADDRESS_WIDTH-1 downto 0);
  signal read_lastline        : unsigned(log2(NUM_LINES)-1 downto 0);

  type control_state_type is (WALK_CACHE, IDLE, CACHE_MISSED, WAIT_FOR_HIT);
  signal control_state      : control_state_type;
  signal next_control_state : control_state_type;

  signal write_address      : std_logic_vector(ADDRESS_WIDTH-1 downto 0);
  signal write_byteenable   : std_logic_vector((EXTERNAL_WIDTH/8)-1 downto 0);
  signal write_writedata    : std_logic_vector(EXTERNAL_WIDTH-1 downto 0);
  signal write_requestvalid : std_logic;
  signal write_tag_update   : std_logic;
  signal write_dirty_valid  : std_logic_vector(DIRTY_BITS downto 0);
  alias write_tag_valid     : std_logic is write_dirty_valid(0);

  signal cache_mgt_tag_update  : std_logic;
  signal cache_mgt_dirty_valid : std_logic_vector(DIRTY_BITS downto 0);
  alias cache_mgt_tag_valid    : std_logic is cache_mgt_dirty_valid(0);

  signal cache_walker_tag_update     : std_logic;
  signal cache_walker_dirty_valid    : std_logic_vector(DIRTY_BITS downto 0);
  alias cache_walker_tag_valid       : std_logic is cache_walker_dirty_valid(0);
  signal start_to_cache_walker       : std_logic;
  signal ready_from_cache_walker     : std_logic;
  signal done_from_cache_walker      : std_logic;
  signal cache_walking               : std_logic;
  signal cache_walker_command        : cache_control_command;
  signal cache_walker_line           : unsigned(log2(NUM_LINES)-1 downto 0);
  signal cache_walker_line_increment : std_logic;
  signal cache_walker_line_last      : std_logic;

  signal write_hit             : std_logic;
  signal write_hit_dirty_valid : std_logic_vector(DIRTY_BITS downto 0);

  signal filling           : std_logic;
  signal fill_reading      : std_logic;
  signal start_to_filler   : std_logic;
  signal ready_from_filler : std_logic;
  signal done_from_filler  : std_logic;

  signal fill_external_offset           : unsigned(log2(LINE_SIZE)-1 downto 0);
  signal fill_external_offset_increment : std_logic;
  signal fill_external_offset_last      : std_logic;
  signal fill_internal_offset           : unsigned(log2(LINE_SIZE)-1 downto 0);
  signal fill_internal_offset_increment : std_logic;
  signal fill_internal_offset_last      : std_logic;

  signal write_idle   : std_logic;
  signal write_ready  : std_logic;
  signal write_on_hit : std_logic;

  signal read_address       : std_logic_vector(ADDRESS_WIDTH-1 downto 0);
  signal read_requestvalid  : std_logic;
  signal read_speculative   : std_logic;
  signal read_readdata      : std_logic_vector(EXTERNAL_WIDTH-1 downto 0);
  signal read_readdatavalid : std_logic;
  signal read_readabort     : std_logic;
  signal read_tag           : std_logic_vector(TAG_BITS-1 downto 0);
  signal read_dirty_valid   : std_logic_vector(DIRTY_BITS downto 0);
begin
  --Idle when no reads in flight (either hit or miss), not waiting on a
  --writeback/writethrough, and not walking the cache.
  --Idle is state-only; do not check for incoming requests
  cache_idle <= (not read_requestinflight) and write_idle and (not cache_walking);

  cacheint_oimm_waitrequest <= read_miss or
                               (not write_ready) or
                               cache_walking;

  c_oimm_address(log2(BYTES_PER_BEAT)-1 downto 0) <= (others => '0');

  read_requestvalid           <= cacheint_oimm_requestvalid and (not cacheint_oimm_waitrequest);
  cacheint_oimm_readdatavalid <= read_readdatavalid and (not write_on_hit);

  single_internal_word_gen : if INTERNAL_WORDS_PER_EXTERNAL_WORD = 1 generate
    cacheint_oimm_readdata <= read_readdata;
  end generate single_internal_word_gen;
  multiple_internal_words_gen : if INTERNAL_WORDS_PER_EXTERNAL_WORD > 1 generate
    type internal_word_vector is array (natural range <>) of std_logic_vector(INTERNAL_WIDTH-1 downto 0);
    signal read_readdata_word : internal_word_vector(INTERNAL_WORDS_PER_EXTERNAL_WORD-1 downto 0);
  begin
    internal_word_gen : for gword in INTERNAL_WORDS_PER_EXTERNAL_WORD-1 downto 0 generate
      read_readdata_word(gword) <= read_readdata(((gword+1)*INTERNAL_WIDTH)-1 downto gword*INTERNAL_WIDTH);
    end generate internal_word_gen;
    cacheint_oimm_readdata <=
      read_readdata_word(to_integer(unsigned(read_lastaddress(log2(EXTERNAL_WIDTH/8)-1 downto
                                                              log2(INTERNAL_WIDTH/8)))));
  end generate multiple_internal_words_gen;

  ------------------------------------------------------------------------------
  -- Cache Contol FSM
  ------------------------------------------------------------------------------
  process(control_state, cache_walker_tag_update, cache_walker_dirty_valid, done_from_cache_walker, read_miss, ready_from_filler, precache_idle, cacheint_oimm_requestvalid, write_idle, to_cache_control_valid, ready_from_cache_walker, to_cache_control_command, done_from_filler)
  begin
    next_control_state       <= control_state;
    cache_mgt_tag_update     <= '0';
    cache_mgt_dirty_valid    <= (others => '0');
    start_to_filler          <= '0';
    from_cache_control_ready <= '0';
    start_to_cache_walker    <= '0';

    case control_state is
      when WALK_CACHE =>
        cache_mgt_tag_update  <= cache_walker_tag_update;
        cache_mgt_dirty_valid <= cache_walker_dirty_valid;
        if done_from_cache_walker = '1' then
          next_control_state <= IDLE;
        end if;

      when IDLE =>
        --Could make this combinational to reduce miss latency by one cycle at
        --the expense of a longer path to external memory.
        if read_miss = '1' then
          start_to_filler <= '1';
          if ready_from_filler = '1' then
            next_control_state   <= CACHE_MISSED;
            cache_mgt_tag_update <= '1';
            cache_mgt_tag_valid  <= '0';
          end if;
        else
          if precache_idle = '1' and cacheint_oimm_requestvalid = '0' and write_idle = '1' then
            if ready_from_cache_walker = '1' then
              from_cache_control_ready <= '1';
              if to_cache_control_valid = '1' then
                case to_cache_control_command is
                  when WRITEBACK =>
                    --Skip writeback commands for read_only and writethrough caches
                    if POLICY = WRITE_BACK then
                      start_to_cache_walker <= '1';
                      next_control_state    <= WALK_CACHE;
                    end if;
                  when others =>
                    --Initialize/Invalidate/Flush
                    start_to_cache_walker <= '1';
                    next_control_state    <= WALK_CACHE;
                end case;
              end if;
            end if;
          end if;
        end if;

      when CACHE_MISSED =>
        if done_from_filler = '1' then
          cache_mgt_tag_update <= '1';
          cache_mgt_tag_valid  <= '1';
          next_control_state   <= WAIT_FOR_HIT;
        end if;

      when WAIT_FOR_HIT =>
        if read_miss = '0' then
          next_control_state <= IDLE;
        end if;

      when others =>
        null;
    end case;
  end process;

  ready_from_cache_walker <= '1';
  cache_walker_line_last  <= '1' when cache_walker_line = to_unsigned(NUM_LINES-1, log2(NUM_LINES)) else '0';
  process(clk)
  begin
    if rising_edge(clk) then
      control_state <= next_control_state;

      if done_from_cache_walker = '1' then
        cache_walking <= '0';
      end if;

      if start_to_cache_walker = '1' and ready_from_cache_walker = '1' then
        cache_walking        <= '1';
        cache_walker_command <= to_cache_control_command;
      end if;

      if cache_walker_line_increment = '1' then
        cache_walker_line <= cache_walker_line + to_unsigned(1, cache_walker_line'length);
      end if;

      if reset = '1' then
        control_state        <= WALK_CACHE;
        cache_walker_command <= INITIALIZE;
        cache_walking        <= '1';
        cache_walker_line    <= to_unsigned(0, cache_walker_line'length);
      end if;
    end if;
  end process;


  ------------------------------------------------------------------------------
  -- Cache Filler FSM
  ------------------------------------------------------------------------------
  done_from_filler <= filling and (fill_internal_offset_increment and fill_internal_offset_last);
  process(clk)
  begin
    if rising_edge(clk) then
      if fill_external_offset_increment = '1' and fill_external_offset_last = '1' then
        fill_reading <= '0';
      end if;
      if done_from_filler = '1' then
        filling <= '0';
      end if;

      if start_to_filler = '1' and ready_from_filler = '1' then
        fill_reading <= '1';
        filling      <= '1';
      end if;

      if reset = '1' then
        fill_reading <= '0';
        filling      <= '0';
      end if;
    end if;
  end process;

  fill_internal_offset_increment <= c_oimm_readdatavalid;
  fill_external_offset_increment <= (not c_oimm_waitrequest) and fill_reading;
  one_beat_per_line_gen : if BEATS_PER_LINE = 1 generate
    fill_internal_offset_last <= '1';
    fill_internal_offset      <= to_unsigned(0, fill_internal_offset'length);
  end generate one_beat_per_line_gen;
  multiple_beats_per_line_gen : if BEATS_PER_LINE > 1 generate
    fill_internal_offset_last <= '1' when (fill_internal_offset(log2(LINE_SIZE)-1 downto log2(BYTES_PER_BEAT)) =
                                           to_unsigned(BEATS_PER_LINE-1, log2(BEATS_PER_LINE))) else
                                 '0';
    process(clk)
    begin
      if rising_edge(clk) then
        if fill_internal_offset_increment = '1' then
          fill_internal_offset <= fill_internal_offset + to_unsigned(BYTES_PER_BEAT, fill_internal_offset'length);
        end if;

        if reset = '1' then
          fill_internal_offset <= to_unsigned(0, fill_internal_offset'length);
        end if;
      end if;
    end process;
  end generate multiple_beats_per_line_gen;
  one_burst_per_line_gen : if BURSTS_PER_LINE = 1 generate
    fill_external_offset_last <= '1';
    fill_external_offset      <= to_unsigned(0, fill_external_offset'length);
  end generate one_burst_per_line_gen;
  multiple_bursts_per_line_gen : if BURSTS_PER_LINE > 1 generate
    fill_external_offset_last <= '1' when (fill_external_offset(log2(LINE_SIZE)-1 downto log2(BYTES_PER_BURST)) =
                                           to_unsigned(BURSTS_PER_LINE-1, log2(BURSTS_PER_LINE))) else
                                 '0';
    process(clk)
    begin
      if rising_edge(clk) then
        if fill_external_offset_increment = '1' then
          fill_external_offset <= fill_external_offset + to_unsigned(BYTES_PER_BURST, fill_external_offset'length);
        end if;

        if reset = '1' then
          fill_external_offset <= to_unsigned(0, fill_external_offset'length);
        end if;
      end if;
    end process;
  end generate multiple_bursts_per_line_gen;

  --Write if filling a cacheline (c_oimm_readdatavalid) or a write has caused a
  --tag check (write_on_hit) and that write has hit an existing cacheline
  --(read_readdatavalid)
  write_hit                <= write_on_hit and read_readdatavalid;
  write_hit_dirty_valid(0) <= '1';
  write_requestvalid       <= c_oimm_readdatavalid or write_hit;
  write_tag_update         <= cache_mgt_tag_update or write_hit;
  write_dirty_valid        <= write_hit_dirty_valid when write_hit = '1' else cache_mgt_dirty_valid;


  ------------------------------------------------------------------------------
  -- Cache Internals
  ------------------------------------------------------------------------------
  the_cache : cache
    generic map (
      NUM_LINES             => NUM_LINES,
      LINE_SIZE             => LINE_SIZE,
      ADDRESS_WIDTH         => ADDRESS_WIDTH,
      WIDTH                 => EXTERNAL_WIDTH,
      DIRTY_BITS            => DIRTY_BITS,
      WRITE_FIRST_SUPPORTED => WRITE_FIRST_SUPPORTED
      )
    port map (
      clk   => clk,
      reset => reset,

      read_address         => read_address,
      read_requestvalid    => read_requestvalid,
      read_speculative     => read_speculative,
      read_readdata        => read_readdata,
      read_readdatavalid   => read_readdatavalid,
      read_readabort       => read_readabort,
      read_miss            => read_miss,
      read_requestinflight => read_requestinflight,
      read_lastaddress     => read_lastaddress,
      read_tag             => read_tag,
      read_dirty_valid     => read_dirty_valid,

      write_address      => write_address,
      write_byteenable   => write_byteenable,
      write_requestvalid => write_requestvalid,
      write_writedata    => write_writedata,
      write_tag_update   => write_tag_update,
      write_dirty_valid  => write_dirty_valid
      );
  read_lastline <= unsigned(read_lastaddress(log2(CACHE_SIZE)-1 downto log2(LINE_SIZE)));

  cache_walker_read_tag_line <= read_tag & std_logic_vector(cache_walker_line);
  to_cache_control_base_partial <=
    '1' when to_cache_control_base(log2(LINE_SIZE)-1 downto 0) /= replicate_slv("0", log2(LINE_SIZE)) else '0';
  read_region_base_hit <= '1' when cache_walker_read_tag_line = to_cache_control_base_tag_line else '0';
  read_region_inner_hit <= '1' when (unsigned(cache_walker_read_tag_line) > unsigned(to_cache_control_base_tag_line) and
                                     unsigned(cache_walker_read_tag_line) < unsigned(to_cache_control_last_tag_line)) else '0';
  to_cache_control_last_partial <=
    '1' when to_cache_control_last(log2(LINE_SIZE)-1 downto 0) /= replicate_slv("1", log2(LINE_SIZE)) else '0';
  read_region_last_hit <= '1' when cache_walker_read_tag_line = to_cache_control_last_tag_line else '0';

  --If REGION_OPTIMIZATIONS are off then everything hits and we treat all hits
  --as partial hits (i.e. requiring a writeback before invalidating).
  read_region_hit <=
    read_region_base_hit or read_region_inner_hit or read_region_last_hit when REGION_OPTIMIZATIONS else '1';
  read_region_hit_partial <= ((read_region_base_hit and to_cache_control_base_partial) or
                              (read_region_last_hit and to_cache_control_last_partial)) when REGION_OPTIMIZATIONS else
                             '1';

  ------------------------------------------------------------------------------
  -- Read-only
  ------------------------------------------------------------------------------
  read_only_gen : if POLICY = READ_ONLY generate
    --Cache walking 'FSM'; just invalidate every line (not entered on Writeback/Flush)
    cache_walker_tag_update     <= cache_walking;
    cache_walker_tag_valid      <= '0';
    cache_walker_line_increment <= cache_walking;
    done_from_cache_walker      <= cache_walker_line_last and cache_walking;

    write_idle         <= '1';
    write_ready        <= '1';
    write_on_hit       <= '0';
    write_writedata    <= c_oimm_readdata;
    write_byteenable   <= (others => '1');
    c_oimm_byteenable  <= (others => '1');
    c_oimm_writedata   <= (others => '-');
    c_oimm_burstlength <= std_logic_vector(to_unsigned(BEATS_PER_BURST, c_oimm_burstlength'length));
    c_oimm_burstlength_minus1 <=
      std_logic_vector(to_unsigned(BEATS_PER_BURST-1, c_oimm_burstlength_minus1'length));
    c_oimm_writelast    <= '1';
    ready_from_filler   <= (not filling) or done_from_filler;
    c_oimm_requestvalid <= fill_reading;
    c_oimm_readnotwrite <= '1';
    c_oimm_address(ADDRESS_WIDTH-1 downto log2(LINE_SIZE)) <=
      read_lastaddress(ADDRESS_WIDTH-1 downto log2(LINE_SIZE));
    multiple_beats_per_line_gen : if BEATS_PER_LINE > 1 generate
      c_oimm_address(log2(LINE_SIZE)-1 downto log2(BYTES_PER_BEAT)) <=
        std_logic_vector(fill_external_offset(log2(LINE_SIZE)-1 downto log2(BYTES_PER_BEAT)));
    end generate multiple_beats_per_line_gen;
    read_address <= cacheint_oimm_address when read_miss = '0' else
                    read_lastaddress;
    read_speculative <= '0';

    --On a cacheline fill use the last address (which caused the miss).
    write_address(ADDRESS_WIDTH-1 downto log2(CACHE_SIZE)) <=
      read_lastaddress(ADDRESS_WIDTH-1 downto log2(CACHE_SIZE));
    write_address(log2(CACHE_SIZE)-1 downto log2(LINE_SIZE)) <=
      std_logic_vector(cache_walker_line) when cache_walking = '1' else
      std_logic_vector(read_lastline);
    write_address(log2(LINE_SIZE)-1 downto 0) <=
      std_logic_vector(fill_internal_offset) when read_miss = '1' else
      read_lastaddress(log2(LINE_SIZE)-1 downto 0);
  end generate read_only_gen;


  ------------------------------------------------------------------------------
  -- Not Read-only
  ------------------------------------------------------------------------------
  not_read_only_gen : if POLICY /= READ_ONLY generate
    signal write_hit_byteenable : std_logic_vector((EXTERNAL_WIDTH/8)-1 downto 0);
    signal last_writedata       : std_logic_vector(INTERNAL_WIDTH-1 downto 0);
    signal done_to_write_on_hit : std_logic;
  begin
    process (clk) is
    begin
      if rising_edge(clk) then
        if cacheint_oimm_waitrequest = '0' then
          last_writedata <= cacheint_oimm_writedata;
        end if;

        if done_to_write_on_hit = '1' then
          write_on_hit <= '0';
        end if;

        if (cacheint_oimm_requestvalid = '1' and
            cacheint_oimm_readnotwrite = '0' and
            cacheint_oimm_waitrequest = '0') then
          write_on_hit <= '1';
        end if;

        if reset = '1' then
          write_on_hit <= '0';
        end if;
      end if;
    end process;

    single_internal_word_gen : if INTERNAL_WORDS_PER_EXTERNAL_WORD = 1 generate
      process (clk) is
      begin
        if rising_edge(clk) then
          if cacheint_oimm_waitrequest = '0' then
            write_hit_byteenable <= cacheint_oimm_byteenable;
          end if;
        end if;
      end process;
    end generate single_internal_word_gen;
    multiple_internal_words_gen : if INTERNAL_WORDS_PER_EXTERNAL_WORD > 1 generate
      process (clk) is
      begin
        if rising_edge(clk) then
          if cacheint_oimm_waitrequest = '0' then
            write_hit_byteenable <= (others => '0');
            for iword in INTERNAL_WORDS_PER_EXTERNAL_WORD-1 downto 0 loop
              if (unsigned(cacheint_oimm_address(log2(BYTES_PER_BEAT)-1 downto log2(INTERNAL_WIDTH/8))) =
                  to_unsigned(iword, log2(INTERNAL_WORDS_PER_EXTERNAL_WORD))) then
                write_hit_byteenable(((iword+1)*(INTERNAL_WIDTH/8))-1 downto iword*(INTERNAL_WIDTH/8)) <=
                  cacheint_oimm_byteenable;
              end if;
            end loop;  -- iword
          end if;
        end if;
      end process;
    end generate multiple_internal_words_gen;
    write_writedata <= c_oimm_readdata when read_miss = '1' else
                       replicate_slv(last_writedata, INTERNAL_WORDS_PER_EXTERNAL_WORD);
    write_byteenable <= (others => '1') when read_miss = '1' else write_hit_byteenable;


    ----------------------------------------------------------------------------
    -- Write-through
    ----------------------------------------------------------------------------
    writethrough_gen : if POLICY = WRITE_THROUGH generate
      signal writing_through          : std_logic;
      signal start_to_write_through   : std_logic;
      signal ready_from_write_through : std_logic;
      signal done_from_write_through  : std_logic;
    begin
      --Cache walking 'FSM'; just invalidate every line (not entered on Writeback/Flush)
      cache_walker_tag_update     <= cache_walking;
      cache_walker_tag_valid      <= '0';
      cache_walker_line_increment <= cache_walking;
      done_from_cache_walker      <= cache_walker_line_last and cache_walking;

      write_idle  <= not writing_through;
      write_ready <= ready_from_write_through;

      --In write-through mode all writes are single cycle, all reads are BEATS_PER_BURST
      c_oimm_burstlength <=
        std_logic_vector(to_unsigned(1, c_oimm_burstlength'length)) when writing_through = '1' else
        std_logic_vector(to_unsigned(BEATS_PER_BURST, c_oimm_burstlength'length));
      c_oimm_burstlength_minus1 <=
        std_logic_vector(to_unsigned(0, c_oimm_burstlength_minus1'length)) when writing_through = '1' else
        std_logic_vector(to_unsigned(BEATS_PER_BURST-1, c_oimm_burstlength_minus1'length));
      c_oimm_writedata  <= replicate_slv(last_writedata, INTERNAL_WORDS_PER_EXTERNAL_WORD);
      c_oimm_byteenable <= write_hit_byteenable when writing_through = '1' else (others => '1');
      c_oimm_writelast  <= '1';

      ready_from_filler <= ((not filling) or done_from_filler) and ready_from_write_through;

      c_oimm_requestvalid <= fill_reading or writing_through;
      c_oimm_readnotwrite <= not writing_through;
      c_oimm_address(ADDRESS_WIDTH-1 downto log2(LINE_SIZE)) <=
        read_lastaddress(ADDRESS_WIDTH-1 downto log2(LINE_SIZE));
      multiple_beats_per_line_gen : if BEATS_PER_LINE > 1 generate
        c_oimm_address(log2(LINE_SIZE)-1 downto log2(BYTES_PER_BEAT)) <=
          read_lastaddress(log2(LINE_SIZE)-1 downto log2(BYTES_PER_BEAT)) when writing_through = '1' else
          std_logic_vector(fill_external_offset(log2(LINE_SIZE)-1 downto log2(BYTES_PER_BEAT)));
      end generate multiple_beats_per_line_gen;
      read_address <= cacheint_oimm_address when read_miss = '0' else
                      read_lastaddress;
      read_speculative     <= not cacheint_oimm_readnotwrite;
      done_to_write_on_hit <= read_readdatavalid or read_readabort;

      --On a cacheline fill use the last address (which caused the miss).  On a
      --write hit, use the last address (which caused the hit).
      write_address(ADDRESS_WIDTH-1 downto log2(CACHE_SIZE)) <=
        read_lastaddress(ADDRESS_WIDTH-1 downto log2(CACHE_SIZE));
      write_address(log2(CACHE_SIZE)-1 downto log2(LINE_SIZE)) <=
        std_logic_vector(cache_walker_line) when cache_walking = '1' else
        std_logic_vector(read_lastline);
      write_address(log2(LINE_SIZE)-1 downto 0) <=
        std_logic_vector(fill_internal_offset) when read_miss = '1' else
        read_lastaddress(log2(LINE_SIZE)-1 downto 0);

      done_from_write_through  <= (not c_oimm_waitrequest);
      ready_from_write_through <= (not writing_through) or done_from_write_through;
      start_to_write_through <=
        cacheint_oimm_requestvalid and (not cacheint_oimm_readnotwrite) and (not cacheint_oimm_waitrequest);
      process (clk) is
      begin
        if rising_edge(clk) then
          if done_from_write_through = '1' then
            writing_through <= '0';
          end if;

          if start_to_write_through = '1' and ready_from_write_through = '1' then
            writing_through <= '1';
          end if;

          if reset = '1' then
            writing_through <= '0';
          end if;
        end if;
      end process;
    end generate writethrough_gen;


    ----------------------------------------------------------------------------
    -- Write-back
    ----------------------------------------------------------------------------
    writeback_gen : if POLICY = WRITE_BACK generate
      signal start_to_spiller          : std_logic;
      signal spilling                  : std_logic;
      signal spill_reading_into_buffer : std_logic;
      signal spill_reading_from_buffer : std_logic;
      signal spill_writing_to_memory   : std_logic;
      signal spill_skipping            : std_logic;
      signal ready_from_spiller        : std_logic;
      signal done_from_spiller         : std_logic;

      signal spill_offset           : unsigned(log2(LINE_SIZE)-1 downto 0);
      signal next_spill_offset      : unsigned(log2(LINE_SIZE)-1 downto 0);
      signal spill_offset_increment : std_logic;
      signal spill_offset_last      : std_logic;
      signal next_spill_offset_last : std_logic;
      signal spill_burst_last       : std_logic;

      signal spill_buffer_read_data    : std_logic_vector(EXTERNAL_WIDTH-1 downto 0);
      signal spill_buffer_write_enable : std_logic;
      signal spill_buffer_write_data   : std_logic_vector(EXTERNAL_WIDTH-1 downto 0);
      signal spill_tag                 : std_logic_vector(TAG_BITS-1 downto 0);
      signal spill_dirty_valid         : std_logic_vector(DIRTY_BITS downto 0);
      signal spill_region_hit          : std_logic;
      signal spill_line                : unsigned(log2(NUM_LINES)-1 downto 0);

      type cache_walker_state_type is (IDLE, START_SPILLER, WAIT_ON_SPILLER);
      signal cache_walker_state            : cache_walker_state_type;
      signal next_cache_walker_state       : cache_walker_state_type;
      signal cache_walker_start_to_spiller : std_logic;
    begin

      --Cache walking FSM.  Note that this may add an extra cycle per line for
      --spilling vs. integrating with the spiller FSM; done this way for
      --simplicity and can be optimized later.
      process (cache_walker_state, cache_walking, cache_walker_command, cache_walker_line_last, ready_from_spiller, done_from_spiller, spill_dirty_valid) is
      begin
        next_cache_walker_state       <= cache_walker_state;
        cache_walker_tag_update       <= '0';
        cache_walker_dirty_valid      <= (others => '0');
        done_from_cache_walker        <= '0';
        cache_walker_line_increment   <= '0';
        cache_walker_start_to_spiller <= '0';

        case cache_walker_state is
          when IDLE =>
            if cache_walking = '1' then
              case cache_walker_command is
                when INITIALIZE =>
                  --Write every line until done
                  cache_walker_tag_update     <= '1';
                  cache_walker_tag_valid      <= '0';
                  cache_walker_line_increment <= '1';
                  if cache_walker_line_last = '1' then
                    done_from_cache_walker <= '1';
                  end if;
                when others =>          --INVALIDATE/WRITEBACK/FLUSH
                  --Loading in line address to spill
                  next_cache_walker_state <= START_SPILLER;
              end case;
            end if;

          when START_SPILLER =>
            --Address loaded; wait for spiller to ack
            cache_walker_start_to_spiller <= '1';
            if ready_from_spiller = '1' then
              next_cache_walker_state <= WAIT_ON_SPILLER;
            end if;

          when WAIT_ON_SPILLER =>
            --Spiller FSM in progress
            if done_from_spiller = '1' then
              cache_walker_tag_update <= spill_region_hit;
              if cache_walker_command = WRITEBACK then
                --Set to clean, valid if previously valid
                cache_walker_tag_valid <= spill_dirty_valid(0);
              else
                --FLUSH, set to invalid
                cache_walker_tag_valid <= '0';
              end if;
              cache_walker_line_increment <= '1';
              next_cache_walker_state     <= IDLE;
              if cache_walker_line_last = '1' then
                done_from_cache_walker <= '1';
              end if;
            end if;
          when others =>
            null;
        end case;
      end process;

      process (clk) is
      begin
        if rising_edge(clk) then
          cache_walker_state <= next_cache_walker_state;

          if reset = '1' then
            cache_walker_state <= IDLE;
          end if;
        end if;
      end process;



      write_idle  <= not spilling;
      write_ready <= ready_from_spiller;

      --In write-back mode writes and reads are all BEATS_PER_BURST
      c_oimm_burstlength <= std_logic_vector(to_unsigned(BEATS_PER_BURST, c_oimm_burstlength'length));
      c_oimm_burstlength_minus1 <=
        std_logic_vector(to_unsigned(BEATS_PER_BURST-1, c_oimm_burstlength_minus1'length));
      c_oimm_writedata    <= spill_buffer_read_data;
      c_oimm_byteenable   <= (others => '1');
      c_oimm_writelast    <= spill_burst_last;
      ready_from_filler   <= ((not filling) or done_from_filler) and ready_from_spiller;
      c_oimm_requestvalid <= fill_reading or spill_writing_to_memory;
      c_oimm_readnotwrite <= fill_reading;
      c_oimm_address(ADDRESS_WIDTH-1 downto log2(CACHE_SIZE)) <=
        read_lastaddress(ADDRESS_WIDTH-1 downto log2(CACHE_SIZE)) when fill_reading = '1' else
        spill_tag;
      c_oimm_address(log2(CACHE_SIZE)-1 downto log2(LINE_SIZE)) <=
        std_logic_vector(read_lastline) when fill_reading = '1' else
        std_logic_vector(spill_line);
      multiple_bursts_per_line_address_gen : if BURSTS_PER_LINE > 1 generate
        c_oimm_address(log2(LINE_SIZE)-1 downto log2(BYTES_PER_BURST)) <=
          std_logic_vector(fill_external_offset(log2(LINE_SIZE)-1 downto log2(BYTES_PER_BURST))) when
          fill_reading = '1' else
          std_logic_vector(spill_offset(log2(LINE_SIZE)-1 downto log2(BYTES_PER_BURST)));
      end generate multiple_bursts_per_line_address_gen;
      multiple_beats_per_burst_line_address_gen : if BEATS_PER_BURST > 1 generate
        c_oimm_address(log2(BYTES_PER_BURST)-1 downto log2(BYTES_PER_BEAT)) <= (others => '0');
      end generate multiple_beats_per_burst_line_address_gen;
      read_address(ADDRESS_WIDTH-1 downto log2(CACHE_SIZE)) <=
        spill_tag                                                      when spill_reading_into_buffer = '1' else
        cacheint_oimm_address(ADDRESS_WIDTH-1 downto log2(CACHE_SIZE)) when read_miss = '0' else
        read_lastaddress(ADDRESS_WIDTH-1 downto log2(CACHE_SIZE));
      read_address(log2(CACHE_SIZE)-1 downto log2(LINE_SIZE)) <=
        std_logic_vector(spill_line)                                     when spill_reading_into_buffer = '1' else
        std_logic_vector(cache_walker_line)                              when cache_walking = '1' else
        cacheint_oimm_address(log2(CACHE_SIZE)-1 downto log2(LINE_SIZE)) when read_miss = '0' else
        std_logic_vector(read_lastline);
      read_address(log2(LINE_SIZE)-1 downto 0) <=
        std_logic_vector(spill_offset)                    when spill_reading_into_buffer = '1' else
        cacheint_oimm_address(log2(LINE_SIZE)-1 downto 0) when read_miss = '0' else
        read_lastaddress(log2(LINE_SIZE)-1 downto 0);

      read_speculative                                  <= '0';
      done_to_write_on_hit                              <= read_readdatavalid;
      write_hit_dirty_valid(write_hit_dirty_valid'left) <= '1';

      --On a cacheline fill use the last address (which caused the miss).  On a
      --write hit, use the last address (which caused the hit).  When spilling
      --a line use the same tag so that the WRITEBACK command correctly sets
      --the line to clean after writing it out to memory.
      write_address(ADDRESS_WIDTH-1 downto log2(CACHE_SIZE)) <=
        spill_tag when cache_walking = '1' else
        read_lastaddress(ADDRESS_WIDTH-1 downto log2(CACHE_SIZE));
      write_address(log2(CACHE_SIZE)-1 downto log2(LINE_SIZE)) <=
        std_logic_vector(cache_walker_line) when cache_walking = '1' else
        std_logic_vector(read_lastline);
      write_address(log2(LINE_SIZE)-1 downto 0) <=
        std_logic_vector(fill_internal_offset) when read_miss = '1' else
        read_lastaddress(log2(LINE_SIZE)-1 downto 0);


      --------------------------------------------------------------------------
      -- Cache Spiller FSM
      --------------------------------------------------------------------------
      start_to_spiller   <= (start_to_filler and ready_from_filler) or cache_walker_start_to_spiller;
      ready_from_spiller <= ((not spilling) or done_from_spiller);
      done_from_spiller <= (spill_writing_to_memory and
                            (not c_oimm_waitrequest) and
                            (not fill_reading) and
                            spill_offset_last) or
                           spill_skipping;
      process(clk)
      begin
        if rising_edge(clk) then
          if done_from_spiller = '1' then
            spilling                <= '0';
            spill_writing_to_memory <= '0';
            spill_skipping          <= '0';
          end if;

          if spill_offset_increment = '1' then
            if spill_offset_last = '1' then
              spill_reading_from_buffer <= spill_reading_into_buffer;
              spill_reading_into_buffer <= '0';
            end if;
            if next_spill_offset_last = '1' then
              if spill_reading_into_buffer = '0' then
                spill_reading_from_buffer <= '0';
              end if;
            end if;
          end if;

          if spill_reading_from_buffer = '1' then
            spill_writing_to_memory <= '1';
          end if;

          --Set spilling to indicate the line needs to be spilled
          if start_to_spiller = '1' and ready_from_spiller = '1' then
            spilling          <= '1';
            spill_tag         <= read_tag;
            spill_line        <= unsigned(read_address(log2(CACHE_SIZE)-1 downto log2(LINE_SIZE)));
            spill_dirty_valid <= read_dirty_valid;
            spill_region_hit  <= read_region_hit;

            --Spill for real only if valid, within the region, dirty, and not
            --invalidating (except partial cachelines, which must be flushed on
            --invalidate).
            --
            --Note that INITIALIZE command does not call the spiller so we
            --don't have to check for it here.
            if (read_dirty_valid(0) = '1' and
                read_dirty_valid(read_dirty_valid'left) = '1' and
                (cache_walking = '0' or (read_region_hit = '1' and
                                         (cache_walker_command /= INVALIDATE or read_region_hit_partial = '1')))) then
              spill_reading_into_buffer <= '1';
            else
              spill_skipping <= '1';
            end if;
          end if;

          if reset = '1' then
            spilling                  <= '0';
            spill_reading_into_buffer <= '0';
            spill_reading_from_buffer <= '0';
            spill_writing_to_memory   <= '0';
            spill_skipping            <= '0';
          end if;
        end if;
      end process;

      spill_offset_increment <= spill_reading_into_buffer or
                                (spill_writing_to_memory and ((not c_oimm_waitrequest) and (not fill_reading)));
      one_beat_per_line_offset_gen : if BEATS_PER_LINE = 1 generate
        next_spill_offset      <= to_unsigned(0, next_spill_offset'length);
        spill_offset           <= to_unsigned(0, spill_offset'length);
        next_spill_offset_last <= '1';
        spill_offset_last      <= '1';
      end generate one_beat_per_line_offset_gen;
      multiple_beats_per_line_offset_gen : if BEATS_PER_LINE > 1 generate
        next_spill_offset <=
          spill_offset + to_unsigned(BYTES_PER_BEAT, spill_offset'length) when spill_offset_increment = '1' else
          spill_offset;
        next_spill_offset_last <= '1' when (next_spill_offset(log2(LINE_SIZE)-1 downto log2(BYTES_PER_BEAT)) =
                                            to_unsigned(BEATS_PER_LINE-1, log2(BEATS_PER_LINE))) else
                                  '0';
        process(clk)
        begin
          if rising_edge(clk) then
            spill_offset      <= next_spill_offset;
            spill_offset_last <= next_spill_offset_last;

            if reset = '1' then
              spill_offset <= to_unsigned(0, spill_offset'length);
            end if;
          end if;
        end process;
      end generate multiple_beats_per_line_offset_gen;
      one_beat_per_burst_gen : if BEATS_PER_BURST = 1 generate
        spill_burst_last <= '1';
      end generate one_beat_per_burst_gen;
      multiple_beats_per_burst_gen : if BEATS_PER_BURST > 1 generate
        spill_burst_last <= '1' when (spill_offset(log2(BYTES_PER_BURST)-1 downto log2(BYTES_PER_BEAT)) =
                                      to_unsigned(BEATS_PER_BURST-1, log2(BEATS_PER_BURST))) else
                            '0';
      end generate multiple_beats_per_burst_gen;


      --------------------------------------------------------------------------
      -- Spill Buffer
      --------------------------------------------------------------------------
      process (clk) is
      begin
        if rising_edge(clk) then
          --Readdata comes back one cycle after fill address changes
          spill_buffer_write_enable <= spill_offset_increment and spill_reading_into_buffer;
        end if;
      end process;
      spill_buffer_write_data <= read_readdata;
      one_beat_per_line_buffer_gen : if BEATS_PER_LINE = 1 generate
        process (clk) is
        begin
          if rising_edge(clk) then
            if spill_buffer_write_enable = '1' then
              spill_buffer_read_data <= spill_buffer_write_data;
            end if;
          end if;
        end process;
      end generate one_beat_per_line_buffer_gen;
      multiple_beats_per_line_buffer_gen : if BEATS_PER_LINE > 1 generate
        signal spill_buffer_read_address  : unsigned(log2(BEATS_PER_LINE)-1 downto 0);
        signal spill_buffer_write_address : unsigned(log2(BEATS_PER_LINE)-1 downto 0);
      begin
        process (clk) is
        begin
          if rising_edge(clk) then
            --Readdata comes back one cycle after fill address changes
            spill_buffer_write_address <= spill_offset(log2(LINE_SIZE)-1 downto log2(BYTES_PER_BEAT));
          end if;
        end process;
        spill_buffer_read_address <= next_spill_offset(log2(LINE_SIZE)-1 downto log2(BYTES_PER_BEAT));

        spill_buffer : bram_sdp_write_first
          generic map (
            DEPTH                 => BEATS_PER_LINE,
            WIDTH                 => EXTERNAL_WIDTH,
            WRITE_FIRST_SUPPORTED => WRITE_FIRST_SUPPORTED
            )
          port map (
            clk           => clk,
            read_address  => spill_buffer_read_address,
            read_data     => spill_buffer_read_data,
            write_address => spill_buffer_write_address,
            write_enable  => spill_buffer_write_enable,
            write_data    => spill_buffer_write_data
            );
      end generate multiple_beats_per_line_buffer_gen;
    end generate writeback_gen;
  end generate not_read_only_gen;


  ------------------------------------------------------------------------------
  -- Assertions
  ------------------------------------------------------------------------------
  assert (CACHE_SIZE mod LINE_SIZE) = 0
    report "Error in cache: CACHE_SIZE (" &
    integer'image(CACHE_SIZE) &
    ") must be an even mulitple of LINE_SIZE (" &
    integer'image(LINE_SIZE) &
    ")."
    severity failure;

  assert 2**log2(CACHE_SIZE) = CACHE_SIZE
    report "Error in cache: CACHE_SIZE (" &
    integer'image(CACHE_SIZE) &
    ") must be a power of 2."
    severity failure;

  assert EXTERNAL_WIDTH >= INTERNAL_WIDTH
    report "Error in cache: EXTERNAL_WIDTH (" &
    integer'image(EXTERNAL_WIDTH) &
    ") must be greater than or equal to INTERNAL_WIDTH (" &
    integer'image(INTERNAL_WIDTH) &
    ")."
    severity failure;

--pragma translate_off
  -------------------------------------------------------------------------------
  -- Simulation debug
  -------------------------------------------------------------------------------
  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '0' then
        assert write_hit /= '1' or cache_mgt_tag_update /= '1' report "Multiple simultaneous tag updates" severity failure;
      end if;
    end if;
  end process;
--pragma translate_on

end architecture;
