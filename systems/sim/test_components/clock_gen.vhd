library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.MATH_REAL.all;

--Simple clock generator that generates clocks in a manner suitable for
--simulation of synchronous clocks (i.e. all clocks change on the same tick).

entity clock_gen is
  generic(
    CLK_MHZ : positive := 100
    );
  port(
    clk_out    : out std_logic;
    clk_out_2x : out std_logic;
    clk_out_3x : out std_logic
    );
end entity;

architecture rtl of clock_gen is
  --Ticks at 1/12 a clock period so as to generate clks 1x/2x/3x (LCM 6, need 2
  --phases per clock)
  constant TICK_PERIOD_PS : real := (1000.0*1000.0)/(12.0*real(CLK_MHZ));
  signal clks             : std_logic_vector(2 downto 0);
begin  -- architecture rtl

  process
    variable leftover_time_ps : real := 0.0;
    variable wait_time_ps : positive := positive(ROUND(TICK_PERIOD_PS));
  begin
    clks <= "111";
    wait_time_ps     := positive(ROUND((2.0*TICK_PERIOD_PS)+leftover_time_ps));
    leftover_time_ps := ((2.0*TICK_PERIOD_PS)+leftover_time_ps) - real(wait_time_ps);
    wait for wait_time_ps*(1 ps);
    clks <= "110";
    wait_time_ps     := positive(ROUND((1.0*TICK_PERIOD_PS)+leftover_time_ps));
    leftover_time_ps := ((1.0*TICK_PERIOD_PS)+leftover_time_ps) - real(wait_time_ps);
    wait for wait_time_ps*(1 ps);
    clks <= "100";
    wait_time_ps     := positive(ROUND((1.0*TICK_PERIOD_PS)+leftover_time_ps));
    leftover_time_ps := ((1.0*TICK_PERIOD_PS)+leftover_time_ps) - real(wait_time_ps);
    wait for wait_time_ps*(1 ps);
    clks <= "101";
    wait_time_ps     := positive(ROUND((2.0*TICK_PERIOD_PS)+leftover_time_ps));
    leftover_time_ps := ((2.0*TICK_PERIOD_PS)+leftover_time_ps) - real(wait_time_ps);
    wait for wait_time_ps*(1 ps);
    clks <= "010";
    wait_time_ps     := positive(ROUND((2.0*TICK_PERIOD_PS)+leftover_time_ps));
    leftover_time_ps := ((2.0*TICK_PERIOD_PS)+leftover_time_ps) - real(wait_time_ps);
    wait for wait_time_ps*(1 ps);
    clks <= "011";
    wait_time_ps     := positive(ROUND((1.0*TICK_PERIOD_PS)+leftover_time_ps));
    leftover_time_ps := ((1.0*TICK_PERIOD_PS)+leftover_time_ps) - real(wait_time_ps);
    wait for wait_time_ps*(1 ps);
    clks <= "001";
    wait_time_ps     := positive(ROUND((1.0*TICK_PERIOD_PS)+leftover_time_ps));
    leftover_time_ps := ((1.0*TICK_PERIOD_PS)+leftover_time_ps) - real(wait_time_ps);
    wait for wait_time_ps*(1 ps);
    clks <= "000";
    wait_time_ps     := positive(ROUND((2.0*TICK_PERIOD_PS)+leftover_time_ps));
    leftover_time_ps := ((2.0*TICK_PERIOD_PS)+leftover_time_ps) - real(wait_time_ps);
    wait for wait_time_ps*(1 ps);
  end process;
  clk_out    <= clks(2);
  clk_out_2x <= clks(1);
  clk_out_3x <= clks(0);

end architecture rtl;
