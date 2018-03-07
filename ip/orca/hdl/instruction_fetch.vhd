library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.rv_components.all;
use work.utils.all;
use work.constants_pkg.all;

entity instruction_fetch is
  generic (
    REGISTER_SIZE          : positive range 32 to 32;
    RESET_VECTOR           : std_logic_vector(31 downto 0);
    MAX_IFETCHES_IN_FLIGHT : positive;
    BTB_ENTRIES            : natural
    );
  port (
    clk   : in std_logic;
    reset : in std_logic;

    pause_ifetch : in std_logic;

    to_pc_correction_data        : in     unsigned(REGISTER_SIZE-1 downto 0);
    to_pc_correction_source_pc   : in     unsigned(REGISTER_SIZE-1 downto 0);
    to_pc_correction_valid       : in     std_logic;
    to_pc_correction_predictable : in     std_logic;
    from_pc_correction_ready     : buffer std_logic;

    --quash_ifetch is handled by to_pc_correction_valid
    ifetch_idle : out std_logic;

    from_ifetch_instruction     : out std_logic_vector(31 downto 0);
    from_ifetch_program_counter : out unsigned(REGISTER_SIZE-1 downto 0);
    from_ifetch_predicted_pc    : out unsigned(REGISTER_SIZE-1 downto 0);
    from_ifetch_valid           : out std_logic;
    to_ifetch_ready             : in  std_logic;

    program_counter : buffer unsigned(REGISTER_SIZE-1 downto 0);

    --ORCA-internal memory-mapped master
    oimm_address       : buffer std_logic_vector(REGISTER_SIZE-1 downto 0);
    oimm_requestvalid  : buffer std_logic;
    oimm_readdata      : in     std_logic_vector(31 downto 0);
    oimm_readdatavalid : in     std_logic;
    oimm_waitrequest   : in     std_logic
    );
end entity instruction_fetch;


architecture rtl of instruction_fetch is
  --Could get promoted to top level; for instance no FIFO_BYPASS with
  --MAX_IFETCHES_IN_FLIGHT = 1 reduces throughput but might be useful for low
  --performance embedded systems
  constant FIFO_BYPASS             : boolean := true;  --MAX_IFETCHES_IN_FLIGHT = 1;
  constant BREAK_CHAIN_FROM_DECODE : boolean := MAX_IFETCHES_IN_FLIGHT > 2;

  signal ready_for_next_fetch        : std_logic;
  signal waiting_for_not_waitrequest : std_logic;

  signal predicted_program_counter : unsigned(REGISTER_SIZE-1 downto 0);

  signal pc_instruction_fifo_reset : std_logic;
  signal pc_fifo_can_accept_data   : std_logic;

  signal pc_fifo_write     : std_logic;
  signal pc_fifo_writedata : std_logic_vector((2*REGISTER_SIZE)-1 downto 0);
  signal pc_fifo_readdata  : std_logic_vector((2*REGISTER_SIZE)-1 downto 0);
  signal pc_fifo_read      : std_logic;
  signal pc_fifo_empty     : std_logic;
  signal pc_fifo_full      : std_logic;
  signal pc_fifo_usedw     : unsigned(log2(MAX_IFETCHES_IN_FLIGHT+1)-1 downto 0);

  signal next_pc_fifo_usedw          : unsigned(log2(MAX_IFETCHES_IN_FLIGHT+1)-1 downto 0);
  signal next_instruction_fifo_usedw : unsigned(log2(MAX_IFETCHES_IN_FLIGHT+1)-1 downto 0);
  signal fetches_to_quash            : unsigned(log2(MAX_IFETCHES_IN_FLIGHT+1)-1 downto 0);
  signal quashing_readdata           : std_logic;

  signal instruction_fifo_write     : std_logic;
  signal instruction_fifo_read      : std_logic;
  signal instruction_fifo_empty     : std_logic;
  signal instruction_fifo_full      : std_logic;
  signal instruction_fifo_writedata : std_logic_vector(31 downto 0);
  signal instruction_fifo_readdata  : std_logic_vector(31 downto 0);
  signal instruction_fifo_usedw     : unsigned(log2(MAX_IFETCHES_IN_FLIGHT+1)-1 downto 0);

  signal ifetch_valid : std_logic;
begin
  --Stage is idle when there are no instruction being fetched (either waiting
  --for waitrequest to go low or readdatavalid to be returned) and no
  --instructions waiting to be dispatched.
  ifetch_idle <= (not waiting_for_not_waitrequest) and (not quashing_readdata) and pc_fifo_empty;

  --No branch predictor; assume PC+4
  no_btb_gen : if BTB_ENTRIES = 0 generate
    predicted_program_counter <= program_counter + to_unsigned(4, predicted_program_counter'length);
  end generate no_btb_gen;
  --Branch predictor.  On a branch/jump update BTB ways; don't predict PC
  --updates from other sources as they have side-effects.
  btb_gen : if BTB_ENTRIES > 0 generate
    subtype btb_tag_type is std_logic_vector(((REGISTER_SIZE-log2(BTB_ENTRIES))-2)-1 downto 0);
    type btb_tag_vector is array (natural range <>) of btb_tag_type;
    subtype btb_prediction_type is std_logic_vector((REGISTER_SIZE-2)-1 downto 0);
    type btb_prediction_vector is array (natural range <>) of btb_prediction_type;

    signal btb_update     : std_logic;
    signal btb_tag        : btb_tag_vector(BTB_ENTRIES-1 downto 0);
    signal btb_prediction : btb_prediction_vector(BTB_ENTRIES-1 downto 0);
    signal btb_valid      : std_logic_vector(BTB_ENTRIES-1 downto 0);

    signal btb_prediction_valid     : std_logic;
    signal btb_prediction_pc        : unsigned(REGISTER_SIZE-1 downto 0);
    signal btb_prediction_tag       : btb_tag_type;
    signal btb_prediction_tag_match : std_logic;
  begin
    btb_update <= to_pc_correction_valid and to_pc_correction_predictable;

    one_entry_gen : if BTB_ENTRIES = 1 generate
      process (clk) is
      begin
        if rising_edge(clk) then
          if btb_update = '1' then
            btb_valid(0)      <= '1';
            btb_prediction(0) <= std_logic_vector(to_pc_correction_data(REGISTER_SIZE-1 downto 2));
            btb_tag(0)        <= std_logic_vector(to_pc_correction_source_pc(REGISTER_SIZE-1 downto 2));
          end if;

          if reset = '1' then
            btb_valid <= (others => '0');
          end if;
        end if;
      end process;
      btb_prediction_valid <= btb_valid(0);
      btb_prediction_pc    <= unsigned(std_logic_vector'(btb_prediction(0) & "00"));
      btb_prediction_tag   <= btb_tag(0);
    end generate one_entry_gen;
    multiple_entries_gen : if BTB_ENTRIES > 1 generate
      signal btb_read_entry_select  : unsigned(log2(BTB_ENTRIES)-1 downto 0);
      signal btb_write_entry_select : unsigned(log2(BTB_ENTRIES)-1 downto 0);
      signal btb_read_valid         : std_logic;
      signal btb_read_prediction    : btb_prediction_type;
      signal btb_read_tag           : btb_tag_type;
    begin
      btb_read_entry_select  <= unsigned(program_counter(log2(BTB_ENTRIES)+1 downto 2));
      btb_write_entry_select <= to_pc_correction_source_pc(log2(BTB_ENTRIES)+1 downto 2);
      process (clk) is
      begin
        if rising_edge(clk) then
          if btb_update = '1' then
            btb_valid(to_integer(btb_write_entry_select)) <= '1';
            btb_prediction(to_integer(btb_write_entry_select)) <=
              std_logic_vector(to_pc_correction_data(REGISTER_SIZE-1 downto 2));
            btb_tag(to_integer(btb_write_entry_select)) <=
              std_logic_vector(to_pc_correction_source_pc(REGISTER_SIZE-1 downto log2(BTB_ENTRIES)+2));
          end if;

          if reset = '1' then
            --For large rams we may want to change this; for now since the BTB
            --is asynchronous read we can assume it will be small (implemented
            --in LUTs or distributed RAMs) and so having a reset vector is OK.
            btb_valid <= (others => '0');
          end if;
        end if;
      end process;
      btb_prediction_valid <= btb_valid(to_integer(btb_read_entry_select));
      btb_prediction_pc    <= unsigned(std_logic_vector'(btb_prediction(to_integer(btb_read_entry_select)) & "00"));
      btb_prediction_tag   <= btb_tag(to_integer(btb_read_entry_select));
    end generate multiple_entries_gen;
    btb_prediction_tag_match <=
      '1' when btb_prediction_tag = std_logic_vector(program_counter(REGISTER_SIZE-1 downto log2(BTB_ENTRIES)+2)) else
      '0';

    predicted_program_counter <=
      btb_prediction_pc when btb_prediction_valid = '1' and btb_prediction_tag_match = '1' else
      program_counter + to_unsigned(4, predicted_program_counter'length);
  end generate btb_gen;


  --When a PC correction is requested, hold it until the current instruction
  --request has issued in case it's stalled (not waiting_for_not_waitrequest)
  from_pc_correction_ready <= (not waiting_for_not_waitrequest) or (not oimm_waitrequest);
  process(clk)
  begin
    if rising_edge(clk) then
      if oimm_readdatavalid = '1' and quashing_readdata = '1' then
        fetches_to_quash <= fetches_to_quash - to_unsigned(1, fetches_to_quash'length);
      end if;

      if to_pc_correction_valid = '1' and from_pc_correction_ready = '1' then
        program_counter  <= to_pc_correction_data;
        fetches_to_quash <= next_pc_fifo_usedw - next_instruction_fifo_usedw;
      elsif oimm_requestvalid = '1' and oimm_waitrequest = '0' then
        program_counter <= predicted_program_counter;
      end if;

      if reset = '1' then
        program_counter  <= unsigned(RESET_VECTOR(REGISTER_SIZE-1 downto 0));
        fetches_to_quash <= to_unsigned(0, fetches_to_quash'length);
      end if;
    end if;
  end process;
  quashing_readdata <= '1' when fetches_to_quash /= to_unsigned(0, fetches_to_quash'length) else '0';

  --Don't fetch when updating the PC, no more instructions can fit in the
  --instruction FIFO, or an interrupt is pending
  ready_for_next_fetch <= (not reset) and
                          (not to_pc_correction_valid) and
                          pc_fifo_can_accept_data and
                          (not pause_ifetch);

  oimm_requestvalid <= waiting_for_not_waitrequest or ready_for_next_fetch;
  oimm_address      <= std_logic_vector(program_counter);

  --Per spec must hold the request valid once initiated
  process(clk)
  begin
    if rising_edge(clk) then
      if oimm_waitrequest = '0' then
        waiting_for_not_waitrequest <= '0';
      else
        if oimm_requestvalid = '1' then
          waiting_for_not_waitrequest <= '1';
        end if;
      end if;

      if reset = '1' then
        waiting_for_not_waitrequest <= '0';
      end if;
    end if;
  end process;

  --Store returned instructions and their corresponding PC's
  pc_fifo_write              <= oimm_requestvalid and (not oimm_waitrequest);
  pc_fifo_writedata          <= std_logic_vector(predicted_program_counter) & std_logic_vector(program_counter);
  pc_fifo_read               <= ifetch_valid and to_ifetch_ready;
  instruction_fifo_writedata <= oimm_readdata;

  --If the PC FIFO can accept data.  Because this is a critical path and it
  --depends on the stall signal from the rest of the pipeline (via
  --pc_fifo_read) the BREAK_CHAIN_FROM_DECODE generic can be used to reduce the
  --fmax penalty at the cost of reducing throughput when the PC FIFO fills up
  --(with one entry only 50% throughput is possible, with 2 or more 100% is
  --possible if the instruction read latency is less than the number of
  --entries).
  pc_fifo_can_accept_data <= (not pc_fifo_full) when BREAK_CHAIN_FROM_DECODE else (not pc_fifo_full) or pc_fifo_read;


  --On PC correction flush the PC and instruction FIFOs.
  pc_instruction_fifo_reset <= to_pc_correction_valid and from_pc_correction_ready;

  --Need to calculate 'next' usedw values for tracking instruction fetches in
  --flight on a mispredict correction
  process (clk) is
  begin
    if rising_edge(clk) then
      pc_fifo_usedw          <= next_pc_fifo_usedw;
      instruction_fifo_usedw <= next_instruction_fifo_usedw;
      if reset = '1' or pc_instruction_fifo_reset = '1' then
        pc_fifo_usedw          <= to_unsigned(0, pc_fifo_usedw'length);
        instruction_fifo_usedw <= to_unsigned(0, instruction_fifo_usedw'length);
      end if;
    end if;
  end process;

  --Single request in flight/single entry instruction FIFO
  single_fetch_in_flight : if MAX_IFETCHES_IN_FLIGHT = 1 generate
    pc_fifo_empty          <= not pc_fifo_full;
    instruction_fifo_empty <= not instruction_fifo_full;
    pc_fifo_full           <= pc_fifo_usedw(0);
    instruction_fifo_full  <= instruction_fifo_usedw(0);
    next_pc_fifo_usedw <=
      to_unsigned(1, next_pc_fifo_usedw'length) when pc_fifo_write = '1' else
      to_unsigned(0, next_pc_fifo_usedw'length) when pc_fifo_read = '1' else
      pc_fifo_usedw;
    next_instruction_fifo_usedw <=
      to_unsigned(1, next_instruction_fifo_usedw'length) when instruction_fifo_write = '1' else
      to_unsigned(0, next_instruction_fifo_usedw'length) when instruction_fifo_read = '1' else
      instruction_fifo_usedw;
    process(clk)
    begin
      if rising_edge(clk) then
        if pc_fifo_write = '1' then
          pc_fifo_readdata <= pc_fifo_writedata;
        end if;
        if instruction_fifo_write = '1' then
          instruction_fifo_readdata <= instruction_fifo_writedata;
        end if;
      end if;
    end process;
  end generate single_fetch_in_flight;
  --Dual request in flight/dual entry instruction FIFO
  dual_fetches_in_flight : if MAX_IFETCHES_IN_FLIGHT = 2 generate
    signal pc_fifo_internaldata          : std_logic_vector((2*REGISTER_SIZE)-1 downto 0);
    signal instruction_fifo_internaldata : std_logic_vector(31 downto 0);
  begin
    next_pc_fifo_usedw <=
      pc_fifo_usedw + to_unsigned(1, pc_fifo_usedw'length) when pc_fifo_write = '1' and pc_fifo_read = '0' else
      pc_fifo_usedw - to_unsigned(1, pc_fifo_usedw'length) when pc_fifo_write = '0' and pc_fifo_read = '1' else
      pc_fifo_usedw;
    next_instruction_fifo_usedw <=
      instruction_fifo_usedw + to_unsigned(1, instruction_fifo_usedw'length) when
      instruction_fifo_write = '1' and instruction_fifo_read = '0' else
      instruction_fifo_usedw - to_unsigned(1, instruction_fifo_usedw'length) when
      instruction_fifo_write = '0' and instruction_fifo_read = '1' else
      instruction_fifo_usedw;
    process(clk)
    begin
      if rising_edge(clk) then
        if pc_fifo_write = '1' then
          pc_fifo_empty        <= '0';
          pc_fifo_internaldata <= pc_fifo_writedata;
          if pc_fifo_read = '1' then
            if pc_fifo_full = '1' then
              pc_fifo_readdata <= pc_fifo_internaldata;
            else
              pc_fifo_readdata <= pc_fifo_writedata;
            end if;
          else
            if pc_fifo_empty = '1' then
              pc_fifo_readdata <= pc_fifo_writedata;
            end if;
            pc_fifo_full <= not pc_fifo_empty;
          end if;
        elsif pc_fifo_read = '1' then
          pc_fifo_full     <= '0';
          pc_fifo_readdata <= pc_fifo_internaldata;
          pc_fifo_empty    <= not pc_fifo_full;
        end if;

        if instruction_fifo_write = '1' then
          instruction_fifo_empty        <= '0';
          instruction_fifo_internaldata <= instruction_fifo_writedata;
          if instruction_fifo_read = '1' then
            if instruction_fifo_full = '1' then
              instruction_fifo_readdata <= instruction_fifo_internaldata;
            else
              instruction_fifo_readdata <= instruction_fifo_writedata;
            end if;
          else
            instruction_fifo_full <= not instruction_fifo_empty;
            if instruction_fifo_empty = '1' then
              instruction_fifo_readdata <= instruction_fifo_writedata;
            end if;
          end if;
        elsif instruction_fifo_read = '1' then
          instruction_fifo_full     <= '0';
          instruction_fifo_readdata <= instruction_fifo_internaldata;
          instruction_fifo_empty    <= not instruction_fifo_full;
        end if;

        if reset = '1' or pc_instruction_fifo_reset = '1' then
          pc_fifo_empty          <= '1';
          pc_fifo_full           <= '0';
          instruction_fifo_empty <= '1';
          instruction_fifo_full  <= '0';
        end if;
      end if;
    end process;
  end generate dual_fetches_in_flight;
  --Multiple request in flight/multiple entry instruction FIFO using LUTs.
  --Might be better to switch to RAM based FIFO already at 3 if distributed
  --RAMs are supported on the family.
  a_few_fetches_in_flight : if MAX_IFETCHES_IN_FLIGHT > 2 generate
    type pc_fifo_data_vector is array (natural range <>) of std_logic_vector((2*REGISTER_SIZE)-1 downto 0);
    signal pc_fifo_internaldata          : pc_fifo_data_vector(MAX_IFETCHES_IN_FLIGHT-1 downto 0);
    type instruction_fifo_data_vector is array (natural range <>) of std_logic_vector(31 downto 0);
    signal instruction_fifo_internaldata : instruction_fifo_data_vector(MAX_IFETCHES_IN_FLIGHT-1 downto 0);
  begin
    next_pc_fifo_usedw <=
      pc_fifo_usedw + to_unsigned(1, pc_fifo_usedw'length) when pc_fifo_write = '1' and pc_fifo_read = '0' else
      pc_fifo_usedw - to_unsigned(1, pc_fifo_usedw'length) when pc_fifo_write = '0' and pc_fifo_read = '1' else
      pc_fifo_usedw;
    next_instruction_fifo_usedw <=
      instruction_fifo_usedw + to_unsigned(1, instruction_fifo_usedw'length) when
      instruction_fifo_write = '1' and instruction_fifo_read = '0' else
      instruction_fifo_usedw - to_unsigned(1, instruction_fifo_usedw'length) when
      instruction_fifo_write = '0' and instruction_fifo_read = '1' else
      instruction_fifo_usedw;
    lut_gen : if MAX_IFETCHES_IN_FLIGHT < 4 generate
      pc_fifo_readdata          <= pc_fifo_internaldata(0);
      instruction_fifo_readdata <= instruction_fifo_internaldata(0);

      process(clk)
      begin
        if rising_edge(clk) then
          if pc_fifo_read = '1' then
            pc_fifo_internaldata(MAX_IFETCHES_IN_FLIGHT-2 downto 0) <=
              pc_fifo_internaldata(MAX_IFETCHES_IN_FLIGHT-1 downto 1);
          end if;
          if pc_fifo_write = '1' then
            pc_fifo_empty <= '0';
            if pc_fifo_read = '1' then
              pc_fifo_internaldata(to_integer(pc_fifo_usedw - to_unsigned(1, pc_fifo_usedw'length))) <= pc_fifo_writedata;
            else
              pc_fifo_internaldata(to_integer(pc_fifo_usedw)) <= pc_fifo_writedata;
              if pc_fifo_usedw = to_unsigned(MAX_IFETCHES_IN_FLIGHT-1, pc_fifo_usedw'length) then
                pc_fifo_full <= '1';
              end if;
            end if;
          elsif pc_fifo_read = '1' then
            pc_fifo_full <= '0';
            if pc_fifo_usedw = to_unsigned(1, pc_fifo_usedw'length) then
              pc_fifo_empty <= '1';
            end if;
          end if;

          if instruction_fifo_read = '1' then
            instruction_fifo_internaldata(MAX_IFETCHES_IN_FLIGHT-2 downto 0) <=
              instruction_fifo_internaldata(MAX_IFETCHES_IN_FLIGHT-1 downto 1);
          end if;
          if instruction_fifo_write = '1' then
            instruction_fifo_empty <= '0';
            if instruction_fifo_read = '1' then
              instruction_fifo_internaldata(to_integer(instruction_fifo_usedw - to_unsigned(1, instruction_fifo_usedw'length))) <= instruction_fifo_writedata;
            else
              instruction_fifo_internaldata(to_integer(instruction_fifo_usedw)) <= instruction_fifo_writedata;
              if instruction_fifo_usedw = to_unsigned(MAX_IFETCHES_IN_FLIGHT-1, instruction_fifo_usedw'length) then
                instruction_fifo_full <= '1';
              end if;
            end if;
          elsif instruction_fifo_read = '1' then
            instruction_fifo_full <= '0';
            if instruction_fifo_usedw = to_unsigned(1, instruction_fifo_usedw'length) then
              instruction_fifo_empty <= '1';
            end if;
          end if;

          if reset = '1' or pc_instruction_fifo_reset = '1' then
            pc_fifo_empty          <= '1';
            pc_fifo_full           <= '0';
            instruction_fifo_empty <= '1';
            instruction_fifo_full  <= '0';
          end if;
        end if;
      end process;
    end generate lut_gen;
    ram_gen : if MAX_IFETCHES_IN_FLIGHT >= 4 generate
      signal pc_fifo_read_address           : unsigned(log2(MAX_IFETCHES_IN_FLIGHT)-1 downto 0);
      signal pc_fifo_write_address          : unsigned(log2(MAX_IFETCHES_IN_FLIGHT)-1 downto 0);
      signal instruction_fifo_read_address  : unsigned(log2(MAX_IFETCHES_IN_FLIGHT)-1 downto 0);
      signal instruction_fifo_write_address : unsigned(log2(MAX_IFETCHES_IN_FLIGHT)-1 downto 0);
    begin
      pc_fifo_readdata          <= pc_fifo_internaldata(to_integer(pc_fifo_read_address));
      instruction_fifo_readdata <= instruction_fifo_internaldata(to_integer(instruction_fifo_read_address));

      process(clk)
      begin
        if rising_edge(clk) then
          if pc_fifo_write = '1' then
            pc_fifo_empty                                           <= '0';
            pc_fifo_internaldata(to_integer(pc_fifo_write_address)) <= pc_fifo_writedata;
            pc_fifo_write_address <=
              pc_fifo_write_address + to_unsigned(1, pc_fifo_write_address'length);
            if (pc_fifo_read = '0' and
                pc_fifo_usedw = to_unsigned(MAX_IFETCHES_IN_FLIGHT-1, pc_fifo_usedw'length)) then
              pc_fifo_full <= '1';
            end if;
          end if;
          if pc_fifo_read = '1' then
            pc_fifo_full <= '0';
            pc_fifo_read_address <=
              pc_fifo_read_address + to_unsigned(1, pc_fifo_read_address'length);
            if (pc_fifo_write = '0' and
                pc_fifo_usedw = to_unsigned(1, pc_fifo_usedw'length)) then
              pc_fifo_empty <= '1';
            end if;
          end if;

          if instruction_fifo_write = '1' then
            instruction_fifo_empty                                                    <= '0';
            instruction_fifo_internaldata(to_integer(instruction_fifo_write_address)) <= instruction_fifo_writedata;
            instruction_fifo_write_address <=
              instruction_fifo_write_address + to_unsigned(1, instruction_fifo_write_address'length);
            if (instruction_fifo_read = '0' and
                instruction_fifo_usedw = to_unsigned(MAX_IFETCHES_IN_FLIGHT-1, instruction_fifo_usedw'length)) then
              instruction_fifo_full <= '1';
            end if;
          end if;
          if instruction_fifo_read = '1' then
            instruction_fifo_full <= '0';
            instruction_fifo_read_address <=
              instruction_fifo_read_address + to_unsigned(1, instruction_fifo_read_address'length);
            if (instruction_fifo_write = '0' and
                instruction_fifo_usedw = to_unsigned(1, instruction_fifo_usedw'length)) then
              instruction_fifo_empty <= '1';
            end if;
          end if;

          if reset = '1' or pc_instruction_fifo_reset = '1' then
            pc_fifo_empty                  <= '1';
            pc_fifo_full                   <= '0';
            instruction_fifo_empty         <= '1';
            instruction_fifo_full          <= '0';
            pc_fifo_read_address           <= to_unsigned(0, pc_fifo_read_address'length);
            pc_fifo_write_address          <= to_unsigned(0, pc_fifo_write_address'length);
            instruction_fifo_read_address  <= to_unsigned(0, instruction_fifo_read_address'length);
            instruction_fifo_write_address <= to_unsigned(0, instruction_fifo_write_address'length);
          end if;
        end if;
      end process;
    end generate ram_gen;
  end generate a_few_fetches_in_flight;

  --Feed readdata directly to decode stage
  bypass_gen : if FIFO_BYPASS generate
    from_ifetch_instruction <= instruction_fifo_readdata when instruction_fifo_empty = '0' else
                               oimm_readdata;
    ifetch_valid           <= (not instruction_fifo_empty) or (oimm_readdatavalid and (not quashing_readdata));
    instruction_fifo_read  <= pc_fifo_read and (not instruction_fifo_empty);
    instruction_fifo_write <= (oimm_readdatavalid and (not quashing_readdata)) and
                              ((not to_ifetch_ready) or (not instruction_fifo_empty));
  end generate bypass_gen;
  no_bypass_gen : if not FIFO_BYPASS generate
    from_ifetch_instruction <= instruction_fifo_readdata;
    ifetch_valid            <= not instruction_fifo_empty;
    instruction_fifo_read   <= pc_fifo_read;
    instruction_fifo_write  <= (oimm_readdatavalid and (not quashing_readdata));
  end generate no_bypass_gen;

  from_ifetch_valid           <= ifetch_valid;
  from_ifetch_program_counter <= unsigned(pc_fifo_readdata(REGISTER_SIZE-1 downto 0));
  from_ifetch_predicted_pc    <= unsigned(pc_fifo_readdata((2*REGISTER_SIZE)-1 downto REGISTER_SIZE));

  assert (BTB_ENTRIES = 0) or (2**log2(BTB_ENTRIES) = BTB_ENTRIES) report
    "BTB_ENTRIES (" &
    natural'image(BTB_ENTRIES) &
    ") must be a power of 2."
    severity failure;

  assert (MAX_IFETCHES_IN_FLIGHT < 4) or (2**log2(MAX_IFETCHES_IN_FLIGHT) = MAX_IFETCHES_IN_FLIGHT) report
    "MAX_IFETCHES_IN_FLIGHT (" &
    natural'image(MAX_IFETCHES_IN_FLIGHT) &
    ") must be less than 4 or a power of 2."
    severity failure;

  assert FIFO_BYPASS or (MAX_IFETCHES_IN_FLIGHT > 1) report
    "With FIFO_BYPASS set to false and MAX_IFETCHES_IN_FLIGHT set to 1 the instruction fetch will only be able to maintain a throughput of 1 instruction every 2 cycles." severity error;

end architecture rtl;
