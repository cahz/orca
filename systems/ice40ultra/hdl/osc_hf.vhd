library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;




entity osc_48MHz is
  generic (
    DIVIDER : std_logic_vector(1 downto 0) := "00"
    );
  port (
    clkout : out std_logic
    );
end entity osc_48MHz;


architecture rtl of osc_48MHz is
  function clk_div_trans(
    constant DIVIDER : std_logic_vector(1 downto 0))
    return string is
  begin
    if DIVIDER = "00" then
      return "0b00";
    elsif DIVIDER = "01" then
      return "0b01";
    elsif DIVIDER = "10" then
      return "0b10";
    else
      return "0b11";
    end if;
  end function clk_div_trans;


  signal clk         : std_logic;
  signal count       : unsigned(31 downto 0);
  constant MAX_COUNT : integer   := 48000;
  signal led         : std_logic := '1';
  constant clk_div : string := clk_div_trans(DIVIDER);



  component SB_HFOSC  is
    generic(
      CLKHF_DIV: string:="0b00"
      );
    port(
      CLKHF : out std_logic;
      CLKHFEN  :in std_logic;
      CLKHFPU : in std_logic
      );
  end  component;

begin  -- architecture rtl
  hf_osc_comp : component SB_HFOSC
    generic map (
      CLKHF_DIV => clk_div)
    port map (
      CLKHF    => clkout,
      CLKHFEN  => '1',
      CLKHFPU => '1');
end architecture rtl;
