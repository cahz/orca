library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity orca_project is
  port(
    KEY      : in std_logic_vector(3 downto 0);
    SW       : in std_logic_vector(17 downto 0);
    clock_50 : in std_logic;

    LEDR : out std_logic_vector(17 downto 0);
    LEDG : out std_logic_vector(7 downto 0);
    HEX7 : out std_logic_vector(6 downto 0);
    HEX6 : out std_logic_vector(6 downto 0);
    HEX5 : out std_logic_vector(6 downto 0);
    HEX4 : out std_logic_vector(6 downto 0);
    HEX3 : out std_logic_vector(6 downto 0);
    HEX2 : out std_logic_vector(6 downto 0);
    HEX1 : out std_logic_vector(6 downto 0);
    HEX0 : out std_logic_vector(6 downto 0);

    DRAM_ADDR  : out   std_logic_vector(12 downto 0);
    DRAM_BA    : out   std_logic_vector(1 downto 0);
    DRAM_CAS_N : out   std_logic;
    DRAM_CKE   : out   std_logic;
    DRAM_CLK   : out   std_logic;
    DRAM_CS_N  : out   std_logic;
    DRAM_DQ    : inout std_logic_vector(31 downto 0);
    DRAM_DQM   : out   std_logic_vector(3 downto 0);
    DRAM_RAS_N : out   std_logic;
    DRAM_WE_N  : out   std_logic
    );
end entity orca_project;

architecture rtl of orca_project is
  component orca_system is
    port (
      clk_clk                  : in    std_logic                     := 'X';  -- clk
      hex0_export              : out   std_logic_vector(31 downto 0);  -- export
      hex1_export              : out   std_logic_vector(31 downto 0);  -- export
      hex2_export              : out   std_logic_vector(31 downto 0);  -- export
      hex3_export              : out   std_logic_vector(31 downto 0);  -- export
      ledg_export              : out   std_logic_vector(31 downto 0);  -- export
      ledr_export              : out   std_logic_vector(31 downto 0);  -- export
      reset_reset_n            : in    std_logic                     := 'X';  -- reset_n
      the_altpll_areset_export : in    std_logic                     := 'X';  -- export
      the_altpll_locked_export : out   std_logic;  -- export
      sdram_wire_addr          : out   std_logic_vector(12 downto 0);  -- addr
      sdram_wire_ba            : out   std_logic_vector(1 downto 0);   -- ba
      sdram_wire_cas_n         : out   std_logic;  -- cas_n
      sdram_wire_cke           : out   std_logic;  -- cke
      sdram_wire_cs_n          : out   std_logic;  -- cs_n
      sdram_wire_dq            : inout std_logic_vector(31 downto 0) := (others => 'X');  -- dq
      sdram_wire_dqm           : out   std_logic_vector(3 downto 0);   -- dqm
      sdram_wire_ras_n         : out   std_logic;  -- ras_n
      sdram_wire_we_n          : out   std_logic;  -- we_n
      clk_sdram_clk            : out   std_logic   -- clk
      );
  end component orca_system;

  signal hex_input   : std_logic_vector(31 downto 0);
  signal clk         : std_logic;
  signal reset       : std_logic;
  signal resetn      : std_logic;
  signal ledg_export : std_logic_vector(31 downto 0);
  signal ledr_export : std_logic_vector(31 downto 0);
  signal hex3_export : std_logic_vector(31 downto 0);
  signal hex2_export : std_logic_vector(31 downto 0);
  signal hex1_export : std_logic_vector(31 downto 0);
  signal hex0_export : std_logic_vector(31 downto 0);

  function seven_segment (
    signal input : std_logic_vector)
    return std_logic_vector is
    variable to_ret : std_logic_vector(6 downto 0) := "XXXXXXX";
  begin  -- function le2be
    case input is
      when x"0"   => to_ret := "1000000";
      when x"1"   => to_ret := "1111001";
      when x"2"   => to_ret := "0100100";
      when x"3"   => to_ret := "0110000";
      when x"4"   => to_ret := "0011001";
      when x"5"   => to_ret := "0010010";
      when x"6"   => to_ret := "0000010";
      when x"7"   => to_ret := "1111000";
      when x"8"   => to_ret := "0000000";
      when x"9"   => to_ret := "0011000";
      when x"a"   => to_ret := "0001000";
      when x"b"   => to_ret := "0000011";
      when x"c"   => to_ret := "1000110";
      when x"d"   => to_ret := "0100001";
      when x"e"   => to_ret := "0000110";
      when x"f"   => to_ret := "0001110";
      when others => null;
    end case;
    return to_ret;
  end function;
begin
  clk    <= clock_50;
  resetn <= key(1);
  reset  <= not key(1);

  rv : component orca_system
    port map (
      clk_clk                  => clk,
      reset_reset_n            => resetn,
      ledg_export              => ledg_export,
      ledr_export              => ledr_export,
      hex3_export              => hex3_export,
      hex2_export              => hex2_export,
      hex1_export              => hex1_export,
      hex0_export              => hex0_export,
      the_altpll_areset_export => reset,
      the_altpll_locked_export => LEDG(5),
      sdram_wire_addr          => DRAM_ADDR,
      sdram_wire_ba            => DRAM_BA,
      sdram_wire_cas_n         => DRAM_CAS_N,
      sdram_wire_cke           => DRAM_CKE,
      sdram_wire_cs_n          => DRAM_CS_N,
      sdram_wire_dq            => DRAM_DQ,
      sdram_wire_dqm           => DRAM_DQM,
      sdram_wire_ras_n         => DRAM_RAS_N,
      sdram_wire_we_n          => DRAM_WE_N,
      clk_sdram_clk            => DRAM_CLK
      );

  hex_input <=
    hex3_export when sw(3) = '1' else
    hex2_export when sw(2) = '1' else
    hex1_export when sw(1) = '1' else
    hex0_export when sw(0) = '1' else
    (others => '0');

  HEX0 <= seven_segment(hex_input(3 downto 0));
  HEX1 <= seven_segment(hex_input(7 downto 4));
  HEX2 <= seven_segment(hex_input(11 downto 8));
  HEX3 <= seven_segment(hex_input(15 downto 12));
  HEX4 <= seven_segment(hex_input(19 downto 16));
  HEX5 <= seven_segment(hex_input(23 downto 20));
  HEX6 <= seven_segment(hex_input(27 downto 24));
  HEX7 <= seven_segment(hex_input(31 downto 28));

  LEDR             <= ledr_export(17 downto 0);
  LEDG(4 downto 0) <= ledg_export(4 downto 0);
  LEDG(7)          <= resetn;
end;
