library IEEE;
use IEEE.STD_LOGIC_1164.all;

library work;
use work.utils.all;

entity true_dual_port_ram_single_clock is

  generic
    (
      DATA_WIDTH : natural := 8;
      ADDR_WIDTH : natural := 6
      );

  port
    (
      clk    : in  std_logic;
      addr_a : in  natural range 0 to 2**ADDR_WIDTH - 1;
      addr_b : in  natural range 0 to 2**ADDR_WIDTH - 1;
      data_a : in  std_logic_vector((DATA_WIDTH-1) downto 0);
      data_b : in  std_logic_vector((DATA_WIDTH-1) downto 0);
      we_a   : in  std_logic := '1';
      we_b   : in  std_logic := '1';
      q_a    : out std_logic_vector((DATA_WIDTH -1) downto 0);
      q_b    : out std_logic_vector((DATA_WIDTH -1) downto 0)
      );

end true_dual_port_ram_single_clock;

architecture rtl of true_dual_port_ram_single_clock is

  -- Build a 2-D array type for the RAM
  subtype word_t is std_logic_vector((DATA_WIDTH-1) downto 0);
  type memory_t is array(0 to 2**ADDR_WIDTH-1) of word_t;

  -- Declare the RAM
  shared variable ram : memory_t;
  signal reg_a, reg_b : std_logic_vector(DATA_WIDTH-1 downto 0);
begin


  -- Port A
  process(clk)
  begin
    if(rising_edge(clk)) then
      if(we_a = '1') then
        ram(addr_a) := data_a;
      end if;

      reg_a <= ram(addr_a);
      q_a   <= reg_a;
    end if;
  end process;

  -- Port B
  process(clk)
  begin
    if(rising_edge(clk)) then
      if(we_b = '1') then
        ram(addr_b) := data_b;
      end if;
      reg_b <= ram(addr_b);
      q_b   <= reg_b;
    end if;
  end process;

end rtl;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_TEXTIO.all;
use STD.TEXTIO.all;

library work;
use work.utils.all;

entity ram_2port is

  generic (
    MEM_DEPTH : natural := 1024;
    MEM_WIDTH : natural := 32);

  port (
    clk       : in  std_logic;
    byte_en0  : in  std_logic_vector(MEM_WIDTH/8-1 downto 0);
    wr_en0    : in  std_logic;
    addr0     : in  std_logic_vector(log2(MEM_DEPTH)-1 downto 0);
    data_in0  : in  std_logic_vector(MEM_WIDTH-1 downto 0);
    data_out0 : out std_logic_vector(MEM_WIDTH-1 downto 0);

    byte_en1  : in  std_logic_vector(MEM_WIDTH/8-1 downto 0);
    wr_en1    : in  std_logic;
    addr1     : in  std_logic_vector(log2(MEM_DEPTH)-1 downto 0);
    data_in1  : in  std_logic_vector(MEM_WIDTH-1 downto 0);
    data_out1 : out std_logic_vector(MEM_WIDTH-1 downto 0)

    );

end entity ram_2port;


architecture behav of ram_2port is
  component true_dual_port_ram_single_clock is

    generic
      (
        DATA_WIDTH : natural := 8;
        ADDR_WIDTH : natural := 6
        );

    port
      (
        clk    : in  std_logic;
        addr_a : in  natural range 0 to 2**ADDR_WIDTH - 1;
        addr_b : in  natural range 0 to 2**ADDR_WIDTH - 1;
        data_a : in  std_logic_vector((DATA_WIDTH-1) downto 0);
        data_b : in  std_logic_vector((DATA_WIDTH-1) downto 0);
        we_a   : in  std_logic := '1';
        we_b   : in  std_logic := '1';
        q_a    : out std_logic_vector((DATA_WIDTH -1) downto 0);
        q_b    : out std_logic_vector((DATA_WIDTH -1) downto 0)
        );

  end component;

begin

  -----------------------------------------------------------------------------
  -- I (JDV) had a whole bunch of trouble getting a proper byte enabled
  -- doal ported ram. This solution (having a seperate entity) seems to work
  -- in both modelsim and quartus
  -----------------------------------------------------------------------------
  byte_gen : for byte in byte_en0'range generate
    signal wen0, wen1           : std_logic;
    signal byte_in0, byte_in1   : std_logic_vector(7 downto 0);
    signal byte_out0, byte_out1 : std_logic_vector(7 downto 0);

    signal addr_a, addr_b : natural range 0 to MEM_DEPTH-1;


  begin
    wen0     <= wr_en0 and byte_en0(byte);
    wen1     <= wr_en1 and byte_en0(byte);
    byte_in0 <= data_in0((byte+1)*8-1 downto byte*8);
    byte_in1 <= data_in1((byte+1)*8-1 downto byte*8);

    data_out0((byte+1)*8-1 downto byte*8) <= byte_out0;
    data_out1((byte+1)*8-1 downto byte*8) <= byte_out1;

    addr_a <= to_integer(unsigned(addr0));
    addr_b <= to_integer(unsigned(addr1));

    dpram : component true_dual_port_ram_single_clock
      generic map (
        DATA_WIDTH => 8,
        ADDR_WIDTH => addr0'length)
      port map (
        clk    => clk,
        data_a => byte_in0,
        data_b => byte_in1,
        addr_a => addr_a,
        addr_b => addr_b,
        we_a   => wen0,
        we_b   => wen1,
        q_a    => byte_out0,
        q_b    => byte_out1);
  end generate byte_gen;
end architecture behav;



library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_TEXTIO.all;
use STD.TEXTIO.all;

library work;
use work.utils.all;

entity ram_4port is
  generic(
    MEM_DEPTH : natural;
    MEM_WIDTH : natural;
    FAMILY    : string := "ALTERA");
  port(
    clk            : in  std_logic;
    scratchpad_clk : in  std_logic;
    reset          : in  std_logic;

    pause_lve_in  : in  std_logic;
    pause_lve_out : out std_logic;
                                        --read source A
    raddr0         : in  std_logic_vector(log2(MEM_DEPTH)-1 downto 0);
    ren0           : in  std_logic;
    scalar_value   : in  std_logic_vector(MEM_WIDTH-1 downto 0);
    scalar_enable  : in  std_logic;
    data_out0      : out std_logic_vector(MEM_WIDTH-1 downto 0);
                                        --read source B
    raddr1      : in  std_logic_vector(log2(MEM_DEPTH)-1 downto 0);
    ren1        : in  std_logic;
    enum_value  : in  std_logic_vector(MEM_WIDTH-1 downto 0);
    enum_enable : in  std_logic;
    data_out1   : out std_logic_vector(MEM_WIDTH-1 downto 0);
    ack01       : out std_logic;
                                        --write dest
    waddr2      : in  std_logic_vector(log2(MEM_DEPTH)-1 downto 0);
    byte_en2    : in  std_logic_vector(MEM_WIDTH/8-1 downto 0);
    wen2        : in  std_logic;
    data_in2    : in  std_logic_vector(MEM_WIDTH-1 downto 0);
                                        --external slave port
    rwaddr3     : in  std_logic_vector(log2(MEM_DEPTH)-1 downto 0);
    wen3        : in  std_logic;
    ren3        : in  std_logic;        --cannot be asserted same cycle as wen3
    byte_en3    : in  std_logic_vector(MEM_WIDTH/8-1 downto 0);
    data_in3    : in  std_logic_vector(MEM_WIDTH-1 downto 0);
    ack3        : out std_logic;
    data_out3   : out std_logic_vector(MEM_WIDTH-1 downto 0));
end entity;

architecture rtl of ram_4port is

  component ram_2port is
    generic (
      MEM_DEPTH : natural := 1024;
      MEM_WIDTH : natural := 32
      );
    port (

      clk       : in  std_logic;
      byte_en0  : in  std_logic_vector(MEM_WIDTH/8-1 downto 0);
      wr_en0    : in  std_logic;
      addr0     : in  std_logic_vector(log2(MEM_DEPTH)-1 downto 0);
      data_in0  : in  std_logic_vector(MEM_WIDTH-1 downto 0);
      data_out0 : out std_logic_vector(MEM_WIDTH-1 downto 0);

      byte_en1  : in  std_logic_vector(MEM_WIDTH/8-1 downto 0);
      wr_en1    : in  std_logic;
      addr1     : in  std_logic_vector(log2(MEM_DEPTH)-1 downto 0);
      data_in1  : in  std_logic_vector(MEM_WIDTH-1 downto 0);
      data_out1 : out std_logic_vector(MEM_WIDTH-1 downto 0));
  end component;


  signal actual_byte_en0  : std_logic_vector(MEM_WIDTH/8-1 downto 0);
  signal actual_wr_en0    : std_logic;
  signal actual_addr0     : std_logic_vector(log2(MEM_DEPTH)-1 downto 0);
  signal actual_data_in0  : std_logic_vector(MEM_WIDTH-1 downto 0);
  signal actual_data_out0 : std_logic_vector(MEM_WIDTH-1 downto 0);

  signal actual_byte_en1  : std_logic_vector(MEM_WIDTH/8-1 downto 0);
  signal actual_wr_en1    : std_logic;
  signal actual_addr1     : std_logic_vector(log2(MEM_DEPTH)-1 downto 0);
  signal actual_data_in1  : std_logic_vector(MEM_WIDTH-1 downto 0);
  signal actual_data_out1 : std_logic_vector(MEM_WIDTH-1 downto 0);

  type cycle_count_t is (SLAVE_WRITE_CYCLE,  --External Slave and lve write
                         READ_CYCLE);        --both lve source reads

  signal cycle_count      : cycle_count_t;
  signal last_cycle_count : cycle_count_t;

  signal sp_follow : std_logic;

  signal byte_en3_latch : std_logic_vector(byte_en3'range);
  signal wen3_latch     : std_logic;
  signal rwaddr3_latch  : std_logic_vector(rwaddr3'range);
  signal data_in3_latch : std_logic_vector(data_in3'range);

  signal pause_lve_internal : std_logic;

  --pipeline bits
  signal read3_ack0 : std_logic;
  signal read3_ack1 : std_logic;
  signal read_ack : std_logic;
begin  -- architecture rtl

  process(clk)
  begin
    if rising_edge(clk) then
      ack3 <= '0';
      if wen3 = '1' or read3_ack1 = '1' then
        ack3 <= '1';
      end if;
      read3_ack0 <= ren3;
      read3_ack1 <= read3_ack0;
      read_ack <= ren0 ;
    end if;
  end process;

  process(scratchpad_clk)
  begin
    if rising_edge(scratchpad_clk) then

      sp_follow <= not sp_follow;
      if reset = '1' then
        sp_follow <= '0';
      end if;
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      byte_en3_latch <= byte_en3;
      wen3_latch     <= wen3;
      rwaddr3_latch  <= rwaddr3;
      data_in3_latch <= data_in3;
    end if;
  end process;

  cycle_count <= SLAVE_WRITE_CYCLE when sp_follow = '0' else READ_CYCLE;

  --Double clock select.
  actual_byte_en0 <= byte_en2       when cycle_count = SLAVE_WRITE_CYCLE else (others => '-');
  actual_byte_en1 <= byte_en3_latch when cycle_count = SLAVE_WRITE_CYCLE else (others => '-');

  actual_wr_en0 <= wen2       when cycle_count = SLAVE_WRITE_CYCLE else '0';
  actual_wr_en1 <= wen3_latch when cycle_count = SLAVE_WRITE_CYCLE else '0';

  actual_addr0 <= waddr2        when cycle_count = SLAVE_WRITE_CYCLE else raddr0;
  actual_addr1 <= rwaddr3_latch when cycle_count = SLAVE_WRITE_CYCLE else raddr1;

  actual_data_in0 <= data_in2       when cycle_count = SLAVE_WRITE_CYCLE else (others => '-');
  actual_data_in1 <= data_in3_latch when cycle_count = SLAVE_WRITE_CYCLE else (others => '-');

  --save values for entire 1x clock
  process(scratchpad_clk)
  begin
    if rising_edge(scratchpad_clk) then
      if cycle_count = SLAVE_WRITE_CYCLE and read3_ack1 = '1' then
        data_out3 <= actual_data_out1;
      end if;
      if cycle_count = READ_CYCLE then
        data_out0 <= actual_data_out0;
        data_out1 <= actual_data_out1;
        if scalar_enable = '1' then
          data_out0 <= scalar_value;
        end if;
        if enum_enable = '1' then
          data_out1 <= enum_value;
        end if;

        ack01 <= read_ack;
      end if;

    end if;
  end process;

  -- Adding this in to match ice40ultraplus lve ram behaviour.
  process(clk)
  begin
    if rising_edge(clk) then
      pause_lve_internal <= pause_lve_in;
      pause_lve_out      <= pause_lve_internal;
    end if;
  end process;

  actual_ram : component ram_2port
    generic map (
      MEM_DEPTH => MEM_DEPTH,
      MEM_WIDTH => MEM_WIDTH)
    port map(
      clk       => scratchpad_clk,
      byte_en0  => actual_byte_en0,
      wr_en0    => actual_wr_en0,
      addr0     => actual_addr0,
      data_in0  => actual_data_in0,
      data_out0 => actual_data_out0,

      byte_en1  => actual_byte_en1,
      wr_en1    => actual_wr_en1,
      addr1     => actual_addr1,
      data_in1  => actual_data_in1,
      data_out1 => actual_data_out1);


end architecture rtl;
