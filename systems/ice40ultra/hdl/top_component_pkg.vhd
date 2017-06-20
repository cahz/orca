-- top_component_pkg.vhd
-- Copyright (C) 2015 VectorBlox Computing, Inc.

-- Component declarations

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.top_util_pkg.all;

package top_component_pkg is

  type wishbone_bus is record
    adr   : std_logic_vector(31 downto 0);
    rdat  : std_logic_vector(31 downto 0);
    we    : std_logic;
    sel   : std_logic_vector(3 downto 0);
    stb   : std_logic;
    cyc   : std_logic;
    cti   : std_logic_vector(2 downto 0);
    stall : std_logic;
    ack   : std_logic;
    wdat  : std_logic_vector(31 downto 0);
    bte   : std_logic_vector(1 downto 0);
    lock  : std_logic;
    err   : std_logic;
    rty   : std_logic;
  end record wishbone_bus;

  component uart_core
    generic(
      CLK_IN_MHZ : integer := 25;
      BAUD_RATE  : integer := 115200;
      ADDRWIDTH  : integer := 3;
      DATAWIDTH  : integer := 8;
      MODEM_B    : boolean := true;
      FIFO       : boolean := false
      );
    port(
-- Global reset and clock
      CLK        : in  std_logic;
      RESET      : in  std_logic;
-- wishbone interface
      UART_ADR_I : in  std_logic_vector(7 downto 0);
      UART_DAT_I : in  std_logic_vector(15 downto 0);
      UART_DAT_O : out std_logic_vector(15 downto 0);
      UART_STB_I : in  std_logic;
      UART_CYC_I : in  std_logic;
      UART_WE_I  : in  std_logic;
      UART_SEL_I : in  std_logic_vector(3 downto 0);
      UART_CTI_I : in  std_logic_vector(2 downto 0);
      UART_BTE_I : in  std_logic_vector(1 downto 0);
      UART_ACK_O : out std_logic;
      INTR       : out std_logic;
-- Receiver interface
      SIN        : in  std_logic;
      RXRDY_N    : out std_logic;
-- Transmitter interface
--Generate --if MODEM

--begin
      DCD_N : in  std_logic;
      CTS_N : in  std_logic;
      DSR_N : in  std_logic;
      RI_N  : in  std_logic;
      DTR_N : out std_logic;
      RTS_N : out std_logic;

--end Generate ;
--
      SOUT    : out std_logic;
      TXRDY_N : out std_logic
      );
  end component;

  component my_led
    port (
      red_i   : in  std_logic;
      green_i : in  std_logic;
      blue_i  : in  std_logic;
      hp_i    : in  std_logic;
      red     : out std_logic;
      green   : out std_logic;
      blue    : out std_logic;
      hp      : out std_logic);
  end component;

  component wb_ram is
    generic (
      MEM_SIZE         : integer := 4096;
      DATA_WIDTH       : integer := 32;
      INIT_FILE_FORMAT : string  := "hex";
      INIT_FILE_NAME   : string  := "none";
      LATTICE_FAMILY   : string  := "ICE40");
    port (
      CLK_I : in std_logic;
      RST_I : in std_logic;

      ADR_I  : in std_logic_vector(log2(MEM_SIZE)-1 downto 0);
      DAT_I  : in std_logic_vector(DATA_WIDTH-1 downto 0);
      WE_I   : in std_logic;
      CYC_I  : in std_logic;
      STB_I  : in std_logic;
      SEL_I  : in std_logic_vector(DATA_WIDTH/8-1 downto 0);
      CTI_I  : in std_logic_vector(2 downto 0);
      BTE_I  : in std_logic_vector(1 downto 0);
      LOCK_I : in std_logic;

      STALL_O : out std_logic;
      DAT_O   : out std_logic_vector(DATA_WIDTH-1 downto 0);
      ACK_O   : out std_logic;
      ERR_O   : out std_logic;
      RTY_O   : out std_logic);
  end component wb_ram;

  component wb_arbiter is
    generic (
      DATA_WIDTH : integer := 32
      );
    port (
      CLK_I : in std_logic;
      RST_I : in std_logic;

      slave0_ADR_I   : in  std_logic_vector(31 downto 0);
      slave0_DAT_I   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      slave0_DAT_O   : out std_logic_vector(DATA_WIDTH-1 downto 0);
      slave0_WE_I    : in  std_logic;
      slave0_CYC_I   : in  std_logic;
      slave0_STB_I   : in  std_logic;
      slave0_SEL_I   : in  std_logic_vector(DATA_WIDTH/8-1 downto 0);
      slave0_STALL_O : out std_logic;
      slave0_ACK_O   : out std_logic;

      slave1_ADR_I   : in  std_logic_vector(31 downto 0);
      slave1_DAT_I   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      slave1_DAT_O   : out std_logic_vector(DATA_WIDTH-1 downto 0);
      slave1_WE_I    : in  std_logic;
      slave1_CYC_I   : in  std_logic;
      slave1_STB_I   : in  std_logic;
      slave1_SEL_I   : in  std_logic_vector(DATA_WIDTH/8-1 downto 0);
      slave1_STALL_O : out std_logic;
      slave1_ACK_O   : out std_logic;

      slave2_ADR_I   : in  std_logic_vector(31 downto 0);
      slave2_DAT_I   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      slave2_WE_I    : in  std_logic;
      slave2_CYC_I   : in  std_logic;
      slave2_STB_I   : in  std_logic;
      slave2_SEL_I   : in  std_logic_vector(DATA_WIDTH/8-1 downto 0);
      slave2_STALL_O : out std_logic;
      slave2_DAT_O   : out std_logic_vector(DATA_WIDTH-1 downto 0);
      slave2_ACK_O   : out std_logic;

      master_ADR_O   : out std_logic_vector(31 downto 0);
      master_DAT_O   : out std_logic_vector(DATA_WIDTH-1 downto 0);
      master_WE_O    : out std_logic;
      master_CYC_O   : out std_logic;
      master_STB_O   : out std_logic;
      master_SEL_O   : out std_logic_vector(DATA_WIDTH/8-1 downto 0);
      master_STALL_I : in  std_logic;
      master_DAT_I   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      master_ACK_I   : in  std_logic

      );

  end component;

  component wb_pio is
    generic (
      DATA_WIDTH : integer := 32);
    port (
      CLK_I : in std_logic;
      RST_I : in std_logic;

      ADR_I   : in  std_logic_vector(31 downto 0);
      DAT_I   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      WE_I    : in  std_logic;
      CYC_I   : in  std_logic;
      STB_I   : in  std_logic;
      SEL_I   : in  std_logic_vector(3 downto 0);
      CTI_I   : in  std_logic_vector(2 downto 0);
      BTE_I   : in  std_logic_vector(1 downto 0);
      LOCK_I  : in  std_logic;
      ACK_O   : out std_logic;
      STALL_O : out std_logic;
      DATA_O  : out std_logic_vector(DATA_WIDTH -1 downto 0);
      ERR_O   : out std_logic;
      RTY_O   : out std_logic;

      input     : in  std_logic_vector(DATA_WIDTH -1 downto 0);
      output_en : out std_logic_vector(DATA_WIDTH -1 downto 0);
      output    : out std_logic_vector(DATA_WIDTH -1 downto 0)

      );
  end component;

  type address_array is array(0 to 1) of integer;

  component wb_splitter is

    generic (
      SUB_ADDRESS_BITS : positive range 1 to 29 := 16;
      NUM_MASTERS      : positive range 2 to 8  := 2;

      JUST_OR_ACKS : boolean := false;

      DATA_WIDTH : natural := 32
      );
    port(

      CLK_I : in std_logic;
      RST_I : in std_logic;

      slave_ADR_I   : in  std_logic_vector(31 downto 0);
      slave_DAT_I   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      slave_WE_I    : in  std_logic;
      slave_CYC_I   : in  std_logic;
      slave_STB_I   : in  std_logic;
      slave_SEL_I   : in  std_logic_vector(DATA_WIDTH/8-1 downto 0);
      slave_CTI_I   : in  std_logic_vector(2 downto 0);
      slave_BTE_I   : in  std_logic_vector(1 downto 0);
      slave_LOCK_I  : in  std_logic;
      slave_STALL_O : out std_logic;
      slave_DAT_O   : out std_logic_vector(DATA_WIDTH-1 downto 0);
      slave_ACK_O   : out std_logic;
      slave_ERR_O   : out std_logic;
      slave_RTY_O   : out std_logic;

      master0_ADR_O   : out std_logic_vector(31 downto 0);
      master0_DAT_O   : out std_logic_vector(DATA_WIDTH-1 downto 0);
      master0_WE_O    : out std_logic;
      master0_CYC_O   : out std_logic;
      master0_STB_O   : out std_logic;
      master0_SEL_O   : out std_logic_vector(DATA_WIDTH/8-1 downto 0);
      master0_CTI_O   : out std_logic_vector(2 downto 0);
      master0_BTE_O   : out std_logic_vector(1 downto 0);
      master0_LOCK_O  : out std_logic;
      master0_STALL_I : in  std_logic                               := '0';
      master0_DAT_I   : in  std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
      master0_ACK_I   : in  std_logic                               := '0';
      master0_ERR_I   : in  std_logic                               := '0';
      master0_RTY_I   : in  std_logic                               := '0';

      master1_ADR_O   : out std_logic_vector(31 downto 0);
      master1_DAT_O   : out std_logic_vector(DATA_WIDTH-1 downto 0);
      master1_WE_O    : out std_logic;
      master1_CYC_O   : out std_logic;
      master1_STB_O   : out std_logic;
      master1_SEL_O   : out std_logic_vector(DATA_WIDTH/8-1 downto 0);
      master1_CTI_O   : out std_logic_vector(2 downto 0);
      master1_BTE_O   : out std_logic_vector(1 downto 0);
      master1_LOCK_O  : out std_logic;
      master1_STALL_I : in  std_logic                               := '0';
      master1_DAT_I   : in  std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
      master1_ACK_I   : in  std_logic                               := '0';
      master1_ERR_I   : in  std_logic                               := '0';
      master1_RTY_I   : in  std_logic                               := '0';

      master2_ADR_O   : out std_logic_vector(31 downto 0);
      master2_DAT_O   : out std_logic_vector(DATA_WIDTH-1 downto 0);
      master2_WE_O    : out std_logic;
      master2_CYC_O   : out std_logic;
      master2_STB_O   : out std_logic;
      master2_SEL_O   : out std_logic_vector(DATA_WIDTH/8-1 downto 0);
      master2_CTI_O   : out std_logic_vector(2 downto 0);
      master2_BTE_O   : out std_logic_vector(1 downto 0);
      master2_LOCK_O  : out std_logic;
      master2_STALL_I : in  std_logic                               := '0';
      master2_DAT_I   : in  std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
      master2_ACK_I   : in  std_logic                               := '0';
      master2_ERR_I   : in  std_logic                               := '0';
      master2_RTY_I   : in  std_logic                               := '0';

      master3_ADR_O   : out std_logic_vector(31 downto 0);
      master3_DAT_O   : out std_logic_vector(DATA_WIDTH-1 downto 0);
      master3_WE_O    : out std_logic;
      master3_CYC_O   : out std_logic;
      master3_STB_O   : out std_logic;
      master3_SEL_O   : out std_logic_vector(DATA_WIDTH/8-1 downto 0);
      master3_CTI_O   : out std_logic_vector(2 downto 0);
      master3_BTE_O   : out std_logic_vector(1 downto 0);
      master3_LOCK_O  : out std_logic;
      master3_STALL_I : in  std_logic                               := '0';
      master3_DAT_I   : in  std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
      master3_ACK_I   : in  std_logic                               := '0';
      master3_ERR_I   : in  std_logic                               := '0';
      master3_RTY_I   : in  std_logic                               := '0';

      master4_ADR_O   : out std_logic_vector(31 downto 0);
      master4_DAT_O   : out std_logic_vector(DATA_WIDTH-1 downto 0);
      master4_WE_O    : out std_logic;
      master4_CYC_O   : out std_logic;
      master4_STB_O   : out std_logic;
      master4_SEL_O   : out std_logic_vector(DATA_WIDTH/8-1 downto 0);
      master4_CTI_O   : out std_logic_vector(2 downto 0);
      master4_BTE_O   : out std_logic_vector(1 downto 0);
      master4_LOCK_O  : out std_logic;
      master4_STALL_I : in  std_logic                               := '0';
      master4_DAT_I   : in  std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
      master4_ACK_I   : in  std_logic                               := '0';
      master4_ERR_I   : in  std_logic                               := '0';
      master4_RTY_I   : in  std_logic                               := '0';

      master5_ADR_O   : out std_logic_vector(31 downto 0);
      master5_DAT_O   : out std_logic_vector(DATA_WIDTH-1 downto 0);
      master5_WE_O    : out std_logic;
      master5_CYC_O   : out std_logic;
      master5_STB_O   : out std_logic;
      master5_SEL_O   : out std_logic_vector(DATA_WIDTH/8-1 downto 0);
      master5_CTI_O   : out std_logic_vector(2 downto 0);
      master5_BTE_O   : out std_logic_vector(1 downto 0);
      master5_LOCK_O  : out std_logic;
      master5_STALL_I : in  std_logic                               := '0';
      master5_DAT_I   : in  std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
      master5_ACK_I   : in  std_logic                               := '0';
      master5_ERR_I   : in  std_logic                               := '0';
      master5_RTY_I   : in  std_logic                               := '0';

      master6_ADR_O   : out std_logic_vector(31 downto 0);
      master6_DAT_O   : out std_logic_vector(DATA_WIDTH-1 downto 0);
      master6_WE_O    : out std_logic;
      master6_CYC_O   : out std_logic;
      master6_STB_O   : out std_logic;
      master6_SEL_O   : out std_logic_vector(DATA_WIDTH/8-1 downto 0);
      master6_CTI_O   : out std_logic_vector(2 downto 0);
      master6_BTE_O   : out std_logic_vector(1 downto 0);
      master6_LOCK_O  : out std_logic;
      master6_STALL_I : in  std_logic                               := '0';
      master6_DAT_I   : in  std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
      master6_ACK_I   : in  std_logic                               := '0';
      master6_ERR_I   : in  std_logic                               := '0';
      master6_RTY_I   : in  std_logic                               := '0';

      master7_ADR_O   : out std_logic_vector(31 downto 0);
      master7_DAT_O   : out std_logic_vector(DATA_WIDTH-1 downto 0);
      master7_WE_O    : out std_logic;
      master7_CYC_O   : out std_logic;
      master7_STB_O   : out std_logic;
      master7_SEL_O   : out std_logic_vector(DATA_WIDTH/8-1 downto 0);
      master7_CTI_O   : out std_logic_vector(2 downto 0);
      master7_BTE_O   : out std_logic_vector(1 downto 0);
      master7_LOCK_O  : out std_logic;
      master7_STALL_I : in  std_logic                               := '0';
      master7_DAT_I   : in  std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
      master7_ACK_I   : in  std_logic                               := '0';
      master7_ERR_I   : in  std_logic                               := '0';
      master7_RTY_I   : in  std_logic                               := '0');
  end component wb_splitter;

  component pmod_mic_wb is
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

      --WISHBONE
      pmodmic_adr_i : in     std_logic_vector(7 downto 0);
      pmodmic_dat_i : in     std_logic_vector(15 downto 0);
      pmodmic_dat_o : out    std_logic_vector(15 downto 0);
      pmodmic_stb_i : in     std_logic;
      pmodmic_cyc_i : in     std_logic;
      pmodmic_we_i  : in     std_logic;
      pmodmic_sel_i : in     std_logic_vector(3 downto 0);
      pmodmic_cti_i : in     std_logic_vector(2 downto 0);
      pmodmic_bte_i : in     std_logic_vector(1 downto 0);
      pmodmic_ack_o : buffer std_logic
      );
  end component pmod_mic_wb;


  component i2s_wb is
    generic (DATA_WIDTH : integer range 16 to 32;
             ADDR_WIDTH : integer range 5 to 32);
    port (
      wb_clk_i   : in  std_logic;
      wb_rst_i   : in  std_logic;
      wb_sel_i   : in  std_logic;
      wb_stb_i   : in  std_logic;
      wb_we_i    : in  std_logic;
      wb_cyc_i   : in  std_logic;
      wb_bte_i   : in  std_logic_vector(1 downto 0);
      wb_cti_i   : in  std_logic_vector(2 downto 0);
      wb_adr_i   : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
      wb_dat_i   : in  std_logic_vector(DATA_WIDTH -1 downto 0);
      i2s_sd_i   : in  std_logic;       -- I2S data input
      wb_ack_o   : out std_logic;
      wb_stall_o : out std_logic;
      wb_dat_o   : out std_logic_vector(DATA_WIDTH - 1 downto 0);
      rx_int_o   : out std_logic;       -- Interrupt line
      i2s_sck_o  : out std_logic;       -- I2S clock out
      i2s_ws_o   : out std_logic);      -- I2S word select out

  end component i2s_wb;

  component SB_PLL40_CORE is
    generic (
      --- VITAL input port delay
      -- Component Parameters
      FEEDBACK_PATH                  : string                 := "SIMPLE";  -- SIMPLE/DELAY/PHASE_AND_DELAY/EXTERNAL
      DELAY_ADJUSTMENT_MODE_FEEDBACK : string                 := "FIXED";  -- FIXED/DYNAMIC
      DELAY_ADJUSTMENT_MODE_RELATIVE : string                 := "FIXED";  -- FIXED/DYNAMIC
      SHIFTREG_DIV_MODE              : bit_vector(1 downto 0) := "00";  -- 00 (div by 4)/ 01 (div by 7)/11 (div by 5)
      FDA_FEEDBACK                   : bit_vector(3 downto 0) := "0000";
      FDA_RELATIVE                   : bit_vector(3 downto 0) := "0000";
      PLLOUT_SELECT                  : string                 := "GENCLK";

      DIVR         : bit_vector(3 downto 0) := "0000";
      DIVF         : bit_vector(6 downto 0) := "0000000";
      DIVQ         : bit_vector(2 downto 0) := "000";
      FILTER_RANGE : bit_vector(2 downto 0) := "000";

      ENABLE_ICEGATE         : bit     := '0';
      TEST_MODE              : bit     := '0';
      EXTERNAL_DIVIDE_FACTOR : integer := 1  -- Required for PLL Config Wizard.
      );
    port (
      REFERENCECLK    : in  std_logic;  -- PLL ref clock, driven by core logic
      PLLOUTCORE      : out std_logic;  -- PLL output to core logic through local routings.
      PLLOUTGLOBAL    : out std_logic;  -- PLL output to dedicated global clock network
      EXTFEEDBACK     : in  std_logic;  -- FB driven by core logic
      DYNAMICDELAY    : in  std_logic_vector(7 downto 0);  -- driven by core logic
      LOCK            : out std_logic;  -- PLL Lock signal output
      BYPASS          : in  std_logic;  -- REFCLK passed to PLLOUT when bypass is '1'.Driven by core logic
      RESETB          : in  std_logic;  -- Active low reset,Driven by core logic
      SDI             : in  std_logic;  -- Test Input. Driven by core logic.
      SDO             : out std_logic;  -- Test output to RB Logic Tile.
      SCLK            : in  std_logic;  -- Test Clk input.Driven by core logic.
      LATCHINPUTVALUE : in  std_logic   -- iCEGate signal
      );
  end component SB_PLL40_CORE;

  component SB_PLL40_CORE_wrapper_div3 is
    port (
      REFERENCECLK    : in  std_logic;  -- PLL ref clock, driven by core logic
      PLLOUTCORE      : out std_logic;  -- PLL output to core logic through local routings.
      PLLOUTGLOBAL    : out std_logic;  -- PLL output to dedicated global clock network
      EXTFEEDBACK     : in  std_logic;  -- FB driven by core logic
      DYNAMICDELAY    : in  std_logic_vector(7 downto 0);  -- driven by core logic
      LOCK            : out std_logic;  -- PLL Lock signal output
      BYPASS          : in  std_logic;  -- REFCLK passed to PLLOUT when bypass is '1'.Driven by core logic
      RESETB          : in  std_logic;  -- Active low reset,Driven by core logic
      SDI             : in  std_logic;  -- Test Input. Driven by core logic.
      SDO             : out std_logic;  -- Test output to RB Logic Tile.
      SCLK            : in  std_logic;  -- Test Clk input.Driven by core logic.
      LATCHINPUTVALUE : in  std_logic   -- iCEGate signal
      );
  end component SB_PLL40_CORE_wrapper_div3;

  component SB_PLL40_CORE_wrapper_x2 is
    port (
      REFERENCECLK    : in  std_logic;  -- PLL ref clock, driven by core logic
      PLLOUTCORE      : out std_logic;  -- PLL output to core logic through local routings.
      PLLOUTGLOBAL    : out std_logic;  -- PLL output to dedicated global clock network
      EXTFEEDBACK     : in  std_logic;  -- FB driven by core logic
      DYNAMICDELAY    : in  std_logic_vector(7 downto 0);  -- driven by core logic
      LOCK            : out std_logic;  -- PLL Lock signal output
      BYPASS          : in  std_logic;  -- REFCLK passed to PLLOUT when bypass is '1'.Driven by core logic
      RESETB          : in  std_logic;  -- Active low reset,Driven by core logic
      SDI             : in  std_logic;  -- Test Input. Driven by core logic.
      SDO             : out std_logic;  -- Test output to RB Logic Tile.
      SCLK            : in  std_logic;  -- Test Clk input.Driven by core logic.
      LATCHINPUTVALUE : in  std_logic   -- iCEGate signal
      );
  end component SB_PLL40_CORE_wrapper_x2;

  component SB_PLL40_CORE_wrapper_x3 is
    port (
      REFERENCECLK    : in  std_logic;  -- PLL ref clock, driven by core logic
      PLLOUTCORE      : out std_logic;  -- PLL output to core logic through local routings.
      PLLOUTGLOBAL    : out std_logic;  -- PLL output to dedicated global clock network
      EXTFEEDBACK     : in  std_logic;  -- FB driven by core logic
      DYNAMICDELAY    : in  std_logic_vector(7 downto 0);  -- driven by core logic
      LOCK            : out std_logic;  -- PLL Lock signal output
      BYPASS          : in  std_logic;  -- REFCLK passed to PLLOUT when bypass is '1'.Driven by core logic
      RESETB          : in  std_logic;  -- Active low reset,Driven by core logic
      SDI             : in  std_logic;  -- Test Input. Driven by core logic.
      SDO             : out std_logic;  -- Test output to RB Logic Tile.
      SCLK            : in  std_logic;  -- Test Clk input.Driven by core logic.
      LATCHINPUTVALUE : in  std_logic   -- iCEGate signal
      );
  end component SB_PLL40_CORE_wrapper_x3;

  component SB_GB is
    port (
      GLOBAL_BUFFER_OUTPUT         : out std_logic;
      USER_SIGNAL_TO_GLOBAL_BUFFER : in  std_logic);
  end component SB_GB;

  component osc_48MHz is
    generic (
      DIVIDER : std_logic_vector(1 downto 0) := "00"
      );
    port (
      clkout : out std_logic
      );
  end component osc_48MHz;

  component tx_i2s_topm is
    generic (
      DATA_WIDTH : integer range 16 to 32 := 16;
      ADDR_WIDTH : integer range 5 to 32  := 5);
    port (
      -- Wishbone interface
      wb_clk_i  : in  std_logic;
      wb_rst_i  : in  std_logic;
      wb_sel_i  : in  std_logic;
      wb_stb_i  : in  std_logic;
      wb_we_i   : in  std_logic;
      wb_cyc_i  : in  std_logic;
      wb_bte_i  : in  std_logic_vector(1 downto 0);
      wb_cti_i  : in  std_logic_vector(2 downto 0);
      wb_adr_i  : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
      wb_dat_i  : in  std_logic_vector(DATA_WIDTH -1 downto 0);
      wb_ack_o  : out std_logic;
      wb_dat_o  : out std_logic_vector(DATA_WIDTH - 1 downto 0);
      -- Interrupt line
      tx_int_o  : out std_logic;
      -- I2S signals
      i2s_sd_o  : out std_logic;
      i2s_sck_o : out std_logic;
      i2s_ws_o  : out std_logic);
  end component tx_i2s_topm;

  component tx_i2s_wbd is
    generic (DATA_WIDTH : integer range 16 to 32;
             ADDR_WIDTH : integer range 5 to 32);
    port (
      -- Wishbone interface
      wb_clk_i  : in  std_logic;
      wb_rst_i  : in  std_logic;
      wb_sel_i  : in  std_logic;
      wb_stb_i  : in  std_logic;
      wb_we_i   : in  std_logic;
      wb_cyc_i  : in  std_logic;
      wb_bte_i  : in  std_logic_vector(1 downto 0);
      wb_cti_i  : in  std_logic_vector(2 downto 0);
      wb_adr_i  : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
      wb_dat_i  : in  std_logic_vector(DATA_WIDTH -1 downto 0);
      wb_ack_o  : out std_logic;
      wb_dat_o  : out std_logic_vector(DATA_WIDTH - 1 downto 0);
      -- Interrupt line
      tx_int_o  : out std_logic;
      -- I2S signals
      i2s_sd_o  : out std_logic;
      i2s_sck_o : out std_logic;
      i2s_ws_o  : out std_logic);
  end component tx_i2s_wbd;

  component i2s_version is
    generic (DATA_WIDTH : integer;
             ADDR_WIDTH : integer;
             IS_MASTER  : integer);
    port (
      ver_rd   : in  std_logic;         -- version register read
      ver_dout : out std_logic_vector(DATA_WIDTH - 1 downto 0));  -- reg. contents
  end component i2s_version;

  component gen_event_reg is
    generic (DATA_WIDTH : integer := 32);
    port (
      clk      : in  std_logic;         -- clock
      rst      : in  std_logic;         -- reset
      evt_wr   : in  std_logic;         -- event register write
      evt_rd   : in  std_logic;         -- event register read
      evt_din  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);  -- write data
      event    : in  std_logic_vector(DATA_WIDTH - 1 downto 0);  -- event vector
      evt_mask : in  std_logic_vector(DATA_WIDTH - 1 downto 0);  -- irq mask
      evt_en   : in  std_logic;         -- irq enable
      evt_dout : out std_logic_vector(DATA_WIDTH - 1 downto 0);  -- read data
      evt_irq  : out std_logic);        -- interrupt  request
  end component gen_event_reg;

  component dpram is
    generic (DATA_WIDTH : positive;
             RAM_WIDTH  : positive);
    port (
      clk     : in  std_logic;
      rst     : in  std_logic;          -- reset is optional, not used here
      din     : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
      wr_en   : in  std_logic;
      rd_en   : in  std_logic;
      wr_addr : in  std_logic_vector(RAM_WIDTH - 1 downto 0);
      rd_addr : in  std_logic_vector(RAM_WIDTH - 1 downto 0);
      dout    : out std_logic_vector(DATA_WIDTH - 1 downto 0));
  end component dpram;

  component i2s_codec is
    generic (DATA_WIDTH  : integer;
             ADDR_WIDTH  : integer;
             IS_MASTER   : integer range 0 to 1;
             IS_RECEIVER : integer range 0 to 1);
    port (
      wb_clk_i     : in  std_logic;     -- wishbone clock
      conf_res     : in  std_logic_vector(5 downto 0);  -- sample resolution
      conf_ratio   : in  std_logic_vector(7 downto 0);  -- clock divider ratio
      conf_swap    : in  std_logic;     -- left/right sample order
      conf_en      : in  std_logic;     -- transmitter/recevier enable
      i2s_sd_i     : in  std_logic;     -- I2S serial data input
      i2s_sck_i    : in  std_logic;     -- I2S clock input
      i2s_ws_i     : in  std_logic;     -- I2S word select input
      sample_dat_i : in  std_logic_vector(DATA_WIDTH - 1 downto 0);  -- audio data
      sample_dat_o : out std_logic_vector(DATA_WIDTH - 1 downto 0);  -- audio data
      mem_rdwr     : out std_logic;     -- sample buffer read/write
      sample_addr  : out std_logic_vector(ADDR_WIDTH - 2 downto 0);  -- address
      evt_hsbf     : out std_logic;     -- higher sample buf empty event
      evt_lsbf     : out std_logic;     -- lower sample buf empty event
      i2s_sd_o     : out std_logic;     -- I2S serial data output
      i2s_sck_o    : out std_logic;     -- I2S clock output
      i2s_ws_o     : out std_logic);    -- I2S word select output
  end component i2s_codec;


  component SB_I2C

    generic (
      I2C_SLAVE_INIT_ADDR : string := "0b1000001";
      BUS_ADDR74          : string := "0b0001"
      );

    port(
      SBCLKI  : in std_logic;
      SBRWI   : in std_logic;
      SBSTBI  : in std_logic;
      SBADRI7 : in std_logic;
      SBADRI6 : in std_logic;
      SBADRI5 : in std_logic;
      SBADRI4 : in std_logic;
      SBADRI3 : in std_logic;
      SBADRI2 : in std_logic;
      SBADRI1 : in std_logic;
      SBADRI0 : in std_logic;
      SBDATI7 : in std_logic;
      SBDATI6 : in std_logic;
      SBDATI5 : in std_logic;
      SBDATI4 : in std_logic;
      SBDATI3 : in std_logic;
      SBDATI2 : in std_logic;
      SBDATI1 : in std_logic;
      SBDATI0 : in std_logic;
      SCLI    : in std_logic;
      SDAI    : in std_logic;

      SBDATO7 : out   std_logic;
      SBDATO6 : out   std_logic;
      SBDATO5 : out   std_logic;
      SBDATO4 : out   std_logic;
      SBDATO3 : out   std_logic;
      SBDATO2 : out   std_logic;
      SBDATO1 : out   std_logic;
      SBDATO0 : out   std_logic;
      SBACKO  : out   std_logic;
      i2ciRQ  : out   std_logic;
      I2CWKUP : out   std_logic;
      SCLO    : inout std_logic;
      SCLOE   : out   std_logic;
      SDAO    : out   std_logic;
      SDAOE   : out   std_logic
      );
  end component;
  component wb_spimaster is
    generic (
      dat_sz : natural := 8;
      slaves : natural := 1
      );
    port (
      clk_i   : in  std_logic;
      rst_i   : in  std_logic;
      --
      -- Wishbone Interface
      --
      adr_i   : in  std_logic_vector(7 downto 0);
      dat_i   : in  std_logic_vector((dat_sz - 1) downto 0);
      dat_o   : out std_logic_vector((dat_sz - 1) downto 0);
      cyc_i   : in  std_logic;
      sel_i   : in  std_logic;
      we_i    : in  std_logic;
      ack_o   : out std_logic;
      stall_o : out std_logic;
      stb_i   : in  std_logic;

      --aux signals
      done_transfer : out std_logic;
      data_out      : out std_logic_vector(dat_sz -1 downto 0);

      --spi signals
      spi_mosi : out std_logic;
      spi_miso : in  std_logic;
      spi_ss   : out std_logic_vector(slaves- 1 downto 0);
      spi_sclk : out std_logic

      );
  end component wb_spimaster;

  component wb_flash_dma is
    generic (
      MAX_LENGTH : integer);
    port (

      clk_i : in std_logic;
      rst_i : in std_logic;

      master_ADR_O   : out std_logic_vector(32-1 downto 0);
      master_DAT_I   : in  std_logic_vector(32-1 downto 0);
      master_DAT_O   : out std_logic_vector(32-1 downto 0);
      master_WE_O    : out std_logic;
      master_SEL_O   : out std_logic_vector(32/8 -1 downto 0);
      master_STB_O   : out std_logic;
      master_ACK_I   : in  std_logic;
      master_CYC_O   : out std_logic;
      master_CTI_O   : out std_logic_vector(2 downto 0);
      master_STALL_I : in  std_logic;

      slave_ADR_I   : in  std_logic_vector(3 downto 0);
      slave_DAT_O   : out std_logic_vector(32-1 downto 0);
      slave_DAT_I   : in  std_logic_vector(32-1 downto 0);
      slave_WE_I    : in  std_logic;
      slave_SEL_I   : in  std_logic_vector(32/8 -1 downto 0);
      slave_STB_I   : in  std_logic;
      slave_ACK_O   : out std_logic;
      slave_CYC_I   : in  std_logic;
      slave_CTI_I   : in  std_logic_vector(2 downto 0);
      slave_STALL_O : out std_logic;

      --spi signals
      spi_mosi : out std_logic;
      spi_miso : in  std_logic;
      spi_ss   : out std_logic;
      spi_sclk : out std_logic

      );
  end component wb_flash_dma;


  component wb_cam is

    port (

      clk_i : in std_logic;
      rst_i : in std_logic;

      master_ADR_O   : out std_logic_vector(32-1 downto 0);
      master_DAT_O   : out std_logic_vector(32-1 downto 0);
      master_WE_O    : out std_logic;
      master_SEL_O   : out std_logic_vector(32/8 -1 downto 0);
      master_STB_O   : out std_logic;
      master_CYC_O   : out std_logic;
      master_CTI_O   : out std_logic_vector(2 downto 0);
      master_STALL_I : in  std_logic;

      --pio control signals
      cam_start : in  std_logic;
      cam_done  : out std_logic;

      --camera signals
      ovm_pclk  : in std_logic;
      ovm_vsync : in std_logic;
      ovm_href  : in std_logic;
      ovm_dat   : in std_logic_vector(7 downto 0)
      );
  end component wb_cam;


end package;

package body top_component_pkg is
end top_component_pkg;
