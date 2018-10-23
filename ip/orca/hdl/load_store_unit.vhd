library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
library work;
use work.constants_pkg.all;
use work.utils.all;

entity load_store_unit is
  generic (
    REGISTER_SIZE       : positive range 32 to 32;
    SIGN_EXTENSION_SIZE : positive;
    ENABLE_EXCEPTIONS   : boolean
    );
  port (
    clk   : in std_logic;
    reset : in std_logic;

    lsu_idle : out std_logic;

    to_lsu_valid       : in  std_logic;
    from_lsu_illegal   : out std_logic;
    from_lsu_misalign : out std_logic;

    rs1_data       : in std_logic_vector(REGISTER_SIZE-1 downto 0);
    rs2_data       : in std_logic_vector(REGISTER_SIZE-1 downto 0);
    instruction    : in std_logic_vector(31 downto 0);
    sign_extension : in std_logic_vector(SIGN_EXTENSION_SIZE-1 downto 0);

    load_in_progress         : buffer std_logic;
    writeback_stall_from_lsu : buffer std_logic;

    lsu_ready      : out std_logic;
    from_lsu_data  : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    from_lsu_valid : out std_logic;

    --ORCA-internal memory-mapped master
    oimm_address       : out    std_logic_vector(REGISTER_SIZE-1 downto 0);
    oimm_byteenable    : out    std_logic_vector((REGISTER_SIZE/8)-1 downto 0);
    oimm_requestvalid  : buffer std_logic;
    oimm_readnotwrite  : buffer std_logic;
    oimm_writedata     : out    std_logic_vector(REGISTER_SIZE-1 downto 0);
    oimm_readdata      : in     std_logic_vector(REGISTER_SIZE-1 downto 0);
    oimm_readdatavalid : in     std_logic;
    oimm_waitrequest   : in     std_logic
    );
end entity load_store_unit;

architecture rtl of load_store_unit is
  signal from_instruction_illegal : std_logic;
  signal from_alignment_illegal   : std_logic;

  alias base_address : std_logic_vector(REGISTER_SIZE-1 downto 0) is rs1_data;
  alias source_data  : std_logic_vector(REGISTER_SIZE-1 downto 0) is rs2_data;

  alias opcode : std_logic_vector(6 downto 0) is instruction(INSTR_OPCODE'range);
  alias func3  : std_logic_vector(2 downto 0) is instruction(INSTR_FUNC3'range);
  signal imm   : std_logic_vector(11 downto 0);

  signal address_unaligned : std_logic_vector(REGISTER_SIZE-1 downto 0);

  signal load_func3     : std_logic_vector(2 downto 0);
  signal load_alignment : std_logic_vector(1 downto 0);

  signal store_byte0 : std_logic_vector(7 downto 0);
  signal store_byte1 : std_logic_vector(7 downto 0);
  signal store_byte2 : std_logic_vector(7 downto 0);
  signal store_byte3 : std_logic_vector(7 downto 0);

  signal load_byte0 : std_logic_vector(7 downto 0);
  signal load_byte1 : std_logic_vector(7 downto 0);
  signal load_byte2 : std_logic_vector(7 downto 0);
  signal load_byte3 : std_logic_vector(7 downto 0);

  signal store_select : std_logic;
  signal store_valid  : std_logic;
  signal load_select  : std_logic;
  signal load_valid   : std_logic;
begin
  --Decode instruction to select submodule.  All paths must decode to exactly
  --one submodule.
  --ASSUMES only LOAD_OP | STORE_OP for opcode.
  process (opcode, func3) is
  begin
    store_select             <= '0';
    load_select              <= '0';
    from_instruction_illegal <= '0';

    if opcode(5) = LOAD_OP(5) then
      if ENABLE_EXCEPTIONS then
        case func3 is
          when LS_DUBL_FUNC3 | LS_UWORD_FUNC3 | LS_UDUBL_FUNC3 =>
            from_instruction_illegal <= '1';
          when others =>
            load_select <= '1';
        end case;
      else
        load_select <= '1';
      end if;
    else
      if ENABLE_EXCEPTIONS then
        case func3 is
          when LS_BYTE_FUNC3 | LS_HALF_FUNC3 | LS_WORD_FUNC3 =>
            store_select <= '1';
          when others =>
            from_instruction_illegal <= '1';
        end case;
      else
        store_select <= '1';
      end if;
    end if;
  end process;

  --Check for unaligned accesses.  Disabled until properly merged exported to sys_call
  from_alignment_illegal <= to_lsu_valid  when (ENABLE_EXCEPTIONS and
                                      ((func3(1) = '1' and address_unaligned(1 downto 0) /= "00") or
                                       (func3(0) = '1' and address_unaligned(0) /= '0')))
                            else '0';
  from_lsu_misalign <= from_alignment_illegal;
  from_lsu_illegal <= from_instruction_illegal;

  store_valid <= store_select and (not from_alignment_illegal);
  load_valid  <= load_select and (not from_alignment_illegal);

  oimm_requestvalid <= (load_valid or store_valid) and to_lsu_valid;
  oimm_readnotwrite <= '1' when opcode(5) = LOAD_OP(5) else '0';

  imm <= instruction(31 downto 25) & instruction(11 downto 7) when instruction(5) = '1'
         else instruction(31 downto 20);

  address_unaligned <= std_logic_vector(unsigned(sign_extension(REGISTER_SIZE-12-1 downto 0) &
                                                 imm)+unsigned(base_address));

  --Little endian byte-enables
  oimm_byteenable <= "0001" when func3 = LS_BYTE_FUNC3 and address_unaligned(1 downto 0) = "00" else
                     "0010" when func3 = LS_BYTE_FUNC3 and address_unaligned(1 downto 0) = "01" else
                     "0100" when func3 = LS_BYTE_FUNC3 and address_unaligned(1 downto 0) = "10" else
                     "1000" when func3 = LS_BYTE_FUNC3 and address_unaligned(1 downto 0) = "11" else
                     "0011" when func3 = LS_HALF_FUNC3 and address_unaligned(1 downto 0) = "00" else
                     "1100" when func3 = LS_HALF_FUNC3 and address_unaligned(1 downto 0) = "10" else
                     "1111";

  --Align bytes for stores
  store_byte3 <= source_data(7 downto 0) when address_unaligned(1 downto 0) = "11" else
                 source_data(15 downto 8) when address_unaligned(1 downto 0) = "10" else
                 source_data(31 downto 24);
  store_byte2 <= source_data(7 downto 0) when address_unaligned(1 downto 0) = "10" else
                 source_data(23 downto 16);
  store_byte1 <= source_data(7 downto 0) when address_unaligned(1 downto 0) = "01" else
                 source_data(15 downto 8);
  store_byte0 <= source_data(7 downto 0);


  oimm_writedata <= store_byte3 & store_byte2 & store_byte1 & store_byte0;

  --Addresses are aligned to word boundary by memory_interface module
  oimm_address <= address_unaligned(REGISTER_SIZE-1 downto 0);

  --Stall if sending a request and slave is not ready or if awaiting readdata
  --and it hasn't arrived yet
  writeback_stall_from_lsu <= load_in_progress and (not oimm_readdatavalid);
  lsu_ready                <= ((not load_valid) and (not store_valid)) or (not oimm_waitrequest);
  lsu_idle                 <= not load_in_progress;  --idle is state-only

  process(clk)
  begin
    if rising_edge(clk) then
      if oimm_readdatavalid = '1' then
        load_in_progress <= '0';
      end if;
      if (oimm_requestvalid = '1' and oimm_readnotwrite = '1') and oimm_waitrequest = '0' then
        load_alignment   <= address_unaligned(1 downto 0);
        load_func3       <= func3;
        load_in_progress <= '1';
      end if;

      if reset = '1' then
        load_in_progress <= '0';
      end if;
    end if;
  end process;

  --Align bytes after load
  load_byte3 <= oimm_readdata(31 downto 24);
  load_byte2 <= oimm_readdata(23 downto 16);
  load_byte1 <= oimm_readdata(15 downto 8) when load_alignment = "00" else
                oimm_readdata(31 downto 24);
  load_byte0 <= oimm_readdata(7 downto 0) when load_alignment = "00" else
                oimm_readdata(15 downto 8)  when load_alignment = "01" else
                oimm_readdata(23 downto 16) when load_alignment = "10" else
                oimm_readdata(31 downto 24);

  --Zero/sign extend the read data
  with load_func3 select
    from_lsu_data <=
    std_logic_vector(resize(signed(load_byte0), REGISTER_SIZE))                when LS_BYTE_FUNC3,
    std_logic_vector(resize(signed(load_byte1 & load_byte0), REGISTER_SIZE))   when LS_HALF_FUNC3,
    std_logic_vector(resize(unsigned(load_byte0), REGISTER_SIZE))              when LS_UBYTE_FUNC3,
    std_logic_vector(resize(unsigned(load_byte1 & load_byte0), REGISTER_SIZE)) when LS_UHALF_FUNC3,
    load_byte3 & load_byte2 & load_byte1 & load_byte0                          when others;

  from_lsu_valid <= oimm_readdatavalid;
end architecture;
