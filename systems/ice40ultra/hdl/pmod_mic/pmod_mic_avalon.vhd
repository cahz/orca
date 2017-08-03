-- pmod_mic_avalon.vhd
-- Copyright (C) 2015 VectorBlox Computing, Inc.


-------------------------------------------------------------------------------
-- Regisets
--
--     |----------------------------------------------------------|
--   0:|        ...    ...    ...       ... |mic1_ready|mic0_ready|
--     |----------------------------------------------------------|
--   1:|                         COUNT (controls frequency)       |
--     |----------------------------------------------------------|
--   2:|                         mic0_data                        |
--     |----------------------------------------------------------|
--   3:|                         mic1_data                        |
--     |----------------------------------------------------------|
--     |                              .                           |
--     |                              .                           |
--     |                              .                           |
--     |----------------------------------------------------------|
--  15:|                         mic12_data                       |
--     |----------------------------------------------------------|

-------------------------------------------------------------------------------



library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pmod_mic_avalon is
  generic (
    PORTS          : positive range 1 to 8 := 1;
    CLK_FREQ_HZ    : positive              := 25000000;
    SAMPLE_RATE_HZ : positive              := 48000
    );
  port (
    clk   : in std_logic;
    reset : in std_logic;

    --PmodMic
    sdata : in  std_logic_vector(PORTS-1 downto 0);
    sclk  : out std_logic_vector(PORTS-1 downto 0);
    cs_n  : out std_logic_vector(PORTS-1 downto 0);


    --Avalon
    av_address     : in     std_logic_vector(7 downto 0);
    av_read        : in     std_logic;
    av_readdata    : out    std_logic_vector(31 downto 0);
    av_write       : in     std_logic;
    av_writedata   : in     std_logic_vector(31 downto 0);
    av_waitrequest : buffer std_logic

    );
end entity pmod_mic_avalon;

architecture rtl of pmod_mic_avalon is
  constant ADDR_LSBS : natural                                := 2;
  constant ADDR_BITS : positive                               := 4+ADDR_LSBS;
  constant REG_READY : std_logic_vector(ADDR_BITS-1 downto 0) := std_logic_vector(to_unsigned(0*(2**ADDR_LSBS), ADDR_BITS));
  constant REG_COUNT : std_logic_vector(ADDR_BITS-1 downto 0) := std_logic_vector(to_unsigned(1*(2**ADDR_LSBS), ADDR_BITS));

  constant DEFAULT_COUNT : positive := ((CLK_FREQ_HZ+(SAMPLE_RATE_HZ/2))/SAMPLE_RATE_HZ)-1;
  signal sample_counter  : unsigned(15 downto 0);
  signal sample_count    : unsigned(15 downto 0);

  constant MIC_DATA_BITS : positive := 12;



  type mic_data_out_array is array (natural range <>) of std_logic_vector(MIC_DATA_BITS-1 downto 0);
  signal mic_data_out    : mic_data_out_array(PORTS-1 downto 0) ;
  signal sample          : mic_data_out_array(PORTS-1 downto 0) ;

  signal sample_ready       : std_logic_vector(PORTS-1 downto 0);
  signal sample_read        : std_logic_vector(PORTS-1 downto 0);
  signal start_sampling     : std_logic_vector(PORTS-1 downto 0);
  signal currently_sampling : std_logic_vector(PORTS-1 downto 0);
  signal sampling_done      : std_logic_vector(PORTS-1 downto 0);

  signal mic_select : integer;


  component PmodMICRefComp
    port (
      --General usage
      clk   : in std_logic;
      reset : in std_logic;

      --Pmod interface signals
      sdata : in     std_logic;
      sclk  : buffer std_logic;
      cs_n  : out    std_logic;

                                        --User interface signals
      data  : out std_logic_vector(11 downto 0);
      start : in  std_logic;
      done  : out std_logic
      );
  end component;
begin

  mic_select     <= to_integer(unsigned(av_address(ADDR_BITS-2 downto ADDR_LSBS)))-2;
  --av_waitrequest <= '0' when
  --                  (av_write = '1' or
  --                   (av_read = '1' and sample_ready(mic_select) = '1') or
  --                   (av_read = '1' and av_address(ADDR_BITS-1 downto 0) = REG_READY) or
  --                   (av_read = '1' and av_address(ADDR_BITS-1 downto 0) = REG_COUNT)
  --                   )
  --                  else '1';
  process (clk)
  begin  -- process
    if clk'event and clk = '1' then     -- rising clock edge
      av_waitrequest <= '1';
      if av_write = '1' then
        av_waitrequest <= '0';
        if av_address(ADDR_BITS-1 downto 0) = REG_COUNT then
          sample_count <= unsigned(av_writedata(sample_count'range));
        end if;
      end if;
    av_readdata <= (others => '1');

      if av_read = '1' then
        if av_address(ADDR_BITS-1 downto 0) = REG_READY then
          av_readdata                   <= (others => '0');
          av_readdata(PORTS-1 downto 0) <= sample_ready(PORTS-1 downto 0);
          av_waitrequest                <= '0';
        elsif av_address(ADDR_BITS-1 downto 0) = REG_COUNT then
          av_readdata    <= std_logic_vector(resize(sample_count, av_readdata'length));
          av_waitrequest <= '0';
        else
          av_readdata <=
            std_logic_vector(resize(unsigned(sample(mic_select)), av_readdata'length));
          sample_ready(mic_select) <= '0';
          if sample_ready(mic_select) = '1' then
            av_waitrequest <= '0';
          end if;
        end if;
      end if;


      for iport in PORTS-1 downto 0 loop
        if sampling_done(iport) = '0' then
          start_sampling(iport) <= '0';
        end if;
        if sample_ready(iport) = '0' and sample_read(iport) = '0' then
          sample(iport)       <= mic_data_out(iport);
          sample_ready(iport) <= '1';
          sample_read(iport)  <= '1';
        end if;
        if sampling_done(iport) = '1' and currently_sampling(iport) = '1' then
          currently_sampling(iport) <= '0';
          sample_read(iport)        <= '0';
        end if;
      end loop;  -- iport

      if sample_counter = to_unsigned(0, sample_counter'length) then
        sample_counter     <= sample_count;
        start_sampling     <= (others => '1');
        currently_sampling <= (others => '1');
      else
        sample_counter <= sample_counter - to_unsigned(1, sample_counter'length);
      end if;

      if reset = '1' then
        start_sampling     <= (others => '0');
        currently_sampling <= (others => '0');
        sample_ready       <= (others => '1');
        sample_read        <= (others => '1');
        sample_counter     <= to_unsigned(DEFAULT_COUNT, sample_counter'length);
        sample_count       <= to_unsigned(DEFAULT_COUNT, sample_count'length);
      end if;
    end if;
  end process;

  mic_controller_gen : for gport in PORTS-1 downto 0 generate
    mic_controller : PmodMICRefComp
      port map (
                                        --General usage
        clk   => clk,
        reset => reset,

                                        --Pmod interface signals
        sdata => sdata(gport),
        sclk  => sclk(gport),
        cs_n  => cs_n(gport),

                                        --User interface signals
        data  => mic_data_out(gport),
        start => start_sampling(gport),
        done  => sampling_done(gport)
        );
  end generate mic_controller_gen;
  --no_mic_gen : for gport in 7 downto PORTS generate
  --  mic_data_out(gport) <= (others => '0');
  --end generate no_mic_gen;

end architecture rtl;
