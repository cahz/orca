library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.utils.all;

entity wb_ram is

  generic (
    MEM_SIZE         : integer := 4096;
    DATA_WIDTH       : integer := 32;
    INIT_FILE_FORMAT : string  := "hex";
    INIT_FILE_NAME   : string  := "none";
    LATTICE_FAMILY   : string  := "ICE40");
  port (
    CLK_I : in std_logic;
    RST_I : in std_logic;

    ADR_I : in std_logic_vector(log2(MEM_SIZE)-1 downto 0);
    DAT_I : in std_logic_vector(DATA_WIDTH-1 downto 0);
    WE_I  : in std_logic;
    CYC_I : in std_logic;
    STB_I : in std_logic;
    SEL_I : in std_logic_vector(DATA_WIDTH/8-1 downto 0);
    CTI_I : in std_logic_vector(2 downto 0);
    BTE_I : in std_logic_vector(1 downto 0);

    LOCK_I : in std_logic;

    STALL_O : out std_logic;
    DAT_O   : out std_logic_vector(DATA_WIDTH-1 downto 0);
    ACK_O   : out std_logic;
    ERR_O   : out std_logic;
    RTY_O   : out std_logic);

end entity wb_ram;

architecture bram of wb_ram is
  component bram_lattice is
    generic (
      RAM_DEPTH      : integer := 1024;
      RAM_WIDTH      : integer := 32;
      BYTE_SIZE      : integer := 8;
      INIT_FILE_NAME : string
      );
    port
      (
        address  : in  std_logic_vector(log2(RAM_DEPTH)-1 downto 0);
        clock    : in  std_logic;
        data_in  : in  std_logic_vector(RAM_WIDTH-1 downto 0);
        we       : in  std_logic;
        re       : in  std_logic;
        be       : in  std_logic_vector(RAM_WIDTH/BYTE_SIZE-1 downto 0);
        readdata : out std_logic_vector(RAM_WIDTH-1 downto 0)
        );
  end component bram_lattice;

  constant BYTES_PER_WORD : integer := DATA_WIDTH/8;

  signal address           : std_logic_vector(log2(MEM_SIZE/BYTES_PER_WORD)-1 downto 0);
  signal write_en, read_en : std_logic;
begin  -- architecture rtl

  address  <= ADR_I(address'left+log2(BYTES_PER_WORD) downto log2(BYTES_PER_WORD));
  write_en <= STB_I and cyc_i and we_i;
  read_en  <= STB_I and cyc_i;
  ram : component bram_lattice
    generic map (
      RAM_DEPTH      => MEM_SIZE/4,
      INIT_FILE_NAME => INIT_FILE_NAME)
    port map (
      address  => address,
      clock    => CLK_I,
      data_in  => DAT_I,
      we       => write_en,
      re       => read_en,
      be       => SEL_I,
      readdata => DAT_O);

  STALL_O <= '0';
  ERR_O   <= '0';
  RTY_O   <= '0';

  process(CLK_I)
  begin
    if rising_edge(CLK_I) then
      ACK_O <= STB_I and CYC_I;
    end if;
  end process;

end architecture bram;

architecture spram of wb_ram is
  component SB_SPRAM256KA is
    port (CLOCK      : in  std_logic;
          ADDRESS    : in  std_logic_vector(13 downto 0);
          DATAIN     : in  std_logic_vector(15 downto 0);
          MASKWREN   : in  std_logic_vector(3 downto 0);
          WREN       : in  std_logic;
          CHIPSELECT : in  std_logic;
          STANDBY    : in  std_logic;
          SLEEP      : in  std_logic;
          POWEROFF   : in  std_logic;
          DATAOUT    : out std_logic_vector(15 downto 0)
          );

  end component;

  signal spram_address : std_logic_vector(13 downto 0);
  signal mask_wren0    : std_logic_vector(3 downto 0);
  signal mask_wren1    : std_logic_vector(3 downto 0);

  signal hi_sel       : std_logic;
  signal hi_sel_latch : std_logic;
  signal low_data_out : std_logic_vector(dat_o'range);
  signal hi_data_out  : std_logic_vector(dat_o'range);
  signal low_we       : std_logic;
  signal hi_we        : std_logic;
begin  -- architecture rtl

  STALL_O <= '0';
  ERR_O   <= '0';
  RTY_O   <= '0';

  spram_address <= std_logic_vector(resize(unsigned(adr_i(adr_i'left downto 2)), 14));

  mask_wren0 <= sel_i(1) & sel_i(1) & sel_i(0) & sel_i(0);
  mask_wren1 <= sel_i(3) & sel_i(3) & sel_i(2) & sel_i(2);

  hi_sel       <= '0'         when MEM_SIZE <= 2**16  else adr_i(adr_i'left);
  hi_sel_latch <= hi_sel      when rising_edge(clk_i);
  dat_o        <= hi_data_out when hi_sel_latch = '1' else low_data_out;
  low_we       <= not hi_sel and we_i and cyc_i and stb_i;
  hi_we        <= hi_sel and we_i and cyc_i and stb_i;

  STALL_O <= '0';
  ERR_O   <= '0';
  RTY_O   <= '0';

  SPRAM0 : component SB_SPRAM256KA
    port map (
      ADDRESS    => spram_address,
      DATAIN     => dat_i(15 downto 0),
      MASKWREN   => mask_wren0,
      WREN       => low_we,
      CHIPSELECT => '1',
      CLOCK      => clk_i,
      STANDBY    => '0',
      SLEEP      => '0',
      POWEROFF   => '1',
      DATAOUT    => low_data_out(15 downto 0));


  SPRAM1 : component SB_SPRAM256KA
    port map (
      ADDRESS    => spram_address,
      DATAIN     => dat_i(31 downto 16),
      MASKWREN   => mask_wren1,
      WREN       => low_we,
      CHIPSELECT => '1',
      CLOCK      => clk_i,
      STANDBY    => '0',
      SLEEP      => '0',
      POWEROFF   => '1',
      DATAOUT    => low_data_out(31 downto 16));

  BIG_MEM : if MEM_SIZE > 2**16 generate
  begin


    SPRAM2 : component SB_SPRAM256KA
      port map (
        ADDRESS    => spram_address,
        DATAIN     => dat_i(15 downto 0),
        MASKWREN   => mask_wren0,
        WREN       => hi_we,
        CHIPSELECT => '1',
        CLOCK      => clk_i,
        STANDBY    => '0',
        SLEEP      => '0',
        POWEROFF   => '1',
        DATAOUT    => hi_data_out(15 downto 0));

    SPRAM3 : component SB_SPRAM256KA
      port map (
        ADDRESS    => spram_address,
        DATAIN     => dat_i(31 downto 16),
        MASKWREN   => mask_wren1,
        WREN       => hi_we,
        CHIPSELECT => '1',
        CLOCK      => clk_i,
        STANDBY    => '0',
        SLEEP      => '0',
        POWEROFF   => '1',
        DATAOUT    => hi_data_out(31 downto 16));


  end generate BIG_MEM;
  process(CLK_I)
  begin
    if rising_edge(CLK_I) then
      ACK_O <= STB_I and CYC_I;
    end if;
  end process;

end architecture spram;
