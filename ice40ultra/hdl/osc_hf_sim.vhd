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

  function max_count_from_div (
    constant DIVIDER : std_logic_vector(1 downto 0))
    return integer is
  begin
    if DIVIDER = "00" then
      return 0;
    elsif DIVIDER = "01" then
      return 1;
    elsif DIVIDER = "10" then
      return 2;
    else
      return 4;
    end if;
  end function max_count_from_div;

  signal clk            : std_logic             := '1';
  signal divided_clk    : std_logic             := '1';
  signal count          : unsigned(31 downto 0) := (others => '0');
  constant MAX_COUNT    : integer               := max_count_from_div(DIVIDER);
  signal led            : std_logic             := '1';
  constant CLOCK_PERIOD : time                  := 20.833333 ns;
begin  -- architecture rtl
  process
  begin
    clk <= not clk;
    wait for CLOCK_PERIOD/2;
  end process;

  process(clk)
  begin

    count <= count + 1;
    if count >= to_unsigned(MAX_COUNT, count'length) then
      count       <= (others => '0');
      divided_clk <= not divided_clk;
    end if;
  end process;
  clkout <= divided_clk;
end architecture rtl;
