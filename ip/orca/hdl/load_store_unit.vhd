library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
library work;
use work.constants_pkg.all;
use work.utils.all;

entity load_store_unit is
  generic (
    REGISTER_SIZE       : positive range 32 to 32;
    SIGN_EXTENSION_SIZE : positive
    );
  port (
    clk   : in std_logic;
    reset : in std_logic;

    lsu_idle : out std_logic;

    valid                    : in     std_logic;
    rs1_data                 : in     std_logic_vector(REGISTER_SIZE-1 downto 0);
    rs2_data                 : in     std_logic_vector(REGISTER_SIZE-1 downto 0);
    instruction              : in     std_logic_vector(31 downto 0);
    sign_extension           : in     std_logic_vector(SIGN_EXTENSION_SIZE-1 downto 0);
    writeback_stall_from_lsu : buffer std_logic;
    lsu_ready                : out    std_logic;
    data_out                 : out    std_logic_vector(REGISTER_SIZE-1 downto 0);
    data_enable              : out    std_logic;
    load_in_progress         : buffer std_logic;

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
  constant BYTE_SIZE  : std_logic_vector(2 downto 0) := "000";
  constant HALF_SIZE  : std_logic_vector(2 downto 0) := "001";
  constant WORD_SIZE  : std_logic_vector(2 downto 0) := "010";
  constant UBYTE_SIZE : std_logic_vector(2 downto 0) := "100";
  constant UHALF_SIZE : std_logic_vector(2 downto 0) := "101";

  constant STORE_INSTR : std_logic_vector(6 downto 0) := "0100011";
  constant LOAD_INSTR  : std_logic_vector(6 downto 0) := "0000011";

  alias base_address : std_logic_vector(REGISTER_SIZE-1 downto 0) is rs1_data;
  alias source_data  : std_logic_vector(REGISTER_SIZE-1 downto 0) is rs2_data;

  alias fun3   : std_logic_vector(2 downto 0) is instruction(14 downto 12);
  alias opcode : std_logic_vector(6 downto 0) is instruction(6 downto 0);
  signal imm   : std_logic_vector(11 downto 0);

  signal address_unaligned : std_logic_vector(REGISTER_SIZE-1 downto 0);

  signal load_fun3      : std_logic_vector(2 downto 0);
  signal load_alignment : std_logic_vector(1 downto 0);

  signal store_byte0 : std_logic_vector(7 downto 0);
  signal store_byte1 : std_logic_vector(7 downto 0);
  signal store_byte2 : std_logic_vector(7 downto 0);
  signal store_byte3 : std_logic_vector(7 downto 0);

  signal load_byte0 : std_logic_vector(7 downto 0);
  signal load_byte1 : std_logic_vector(7 downto 0);
  signal load_byte2 : std_logic_vector(7 downto 0);
  signal load_byte3 : std_logic_vector(7 downto 0);

  signal write_instr : std_logic;
  signal read_instr  : std_logic;
begin
  write_instr <= '1' when opcode = STORE_INSTR else '0';
  read_instr  <= '1' when opcode = LOAD_INSTR  else '0';

  oimm_requestvalid <= (read_instr or write_instr) and valid;
  oimm_readnotwrite <= read_instr;

  imm <= instruction(31 downto 25) & instruction(11 downto 7) when instruction(5) = '1'
         else instruction(31 downto 20);

  address_unaligned <= std_logic_vector(unsigned(sign_extension(REGISTER_SIZE-12-1 downto 0) &
                                                 imm)+unsigned(base_address));

  --Little endian byte-enables
  oimm_byteenable <= "0001" when fun3 = BYTE_SIZE and address_unaligned(1 downto 0) = "00" else
                     "0010" when fun3 = BYTE_SIZE and address_unaligned(1 downto 0) = "01" else
                     "0100" when fun3 = BYTE_SIZE and address_unaligned(1 downto 0) = "10" else
                     "1000" when fun3 = BYTE_SIZE and address_unaligned(1 downto 0) = "11" else
                     "0011" when fun3 = HALF_SIZE and address_unaligned(1 downto 0) = "00" else
                     "1100" when fun3 = HALF_SIZE and address_unaligned(1 downto 0) = "10" else
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

  --Addresses are always aligned
  oimm_address <= address_unaligned(REGISTER_SIZE-1 downto 2) & "00";

  --Stall if sending a request and slave is not ready or if awaiting readdata
  --and it hasn't arrived yet
  writeback_stall_from_lsu <= load_in_progress and (not oimm_readdatavalid);
  lsu_ready                <= ((not read_instr) and (not write_instr)) or (not oimm_waitrequest);
  lsu_idle                 <= not load_in_progress;  --idle is state-only

  process(clk)
  begin
    if rising_edge(clk) then
      if oimm_readdatavalid = '1' then
        load_in_progress <= '0';
      end if;
      if (oimm_requestvalid = '1' and oimm_readnotwrite = '1') and oimm_waitrequest = '0' then
        load_alignment   <= address_unaligned(1 downto 0);
        load_fun3        <= fun3;
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
  with load_fun3 select
    data_out <=
    std_logic_vector(resize(signed(load_byte0), REGISTER_SIZE))                when BYTE_SIZE,
    std_logic_vector(resize(signed(load_byte1 & load_byte0), REGISTER_SIZE))   when HALF_SIZE,
    std_logic_vector(resize(unsigned(load_byte0), REGISTER_SIZE))              when UBYTE_SIZE,
    std_logic_vector(resize(unsigned(load_byte1 & load_byte0), REGISTER_SIZE)) when UHALF_SIZE,
    load_byte3 & load_byte2 & load_byte1 & load_byte0                          when others;

  data_enable <= oimm_readdatavalid;
end architecture;
