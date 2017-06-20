library ieee;
use IEEE.std_logic_1164.all;

entity top_tb is
end entity;


architecture rtl of top_tb is
  component top is
    port(
      clk            : in std_logic;
      scratchpad_clk : in std_logic;
      reset_btn      : in std_logic;

      --uart
      rxd : in  std_logic;
      txd : out std_logic;
      cts : in  std_logic;
      rts : out std_logic;

      R_LED  : out std_logic;
      G_LED  : out std_logic;
      B_LED  : out std_logic;
      HP_LED : out std_logic

      );
  end component;

  signal reset_n          : std_logic;
  signal clk            : std_logic;
  signal scratchpad_clk : std_logic;
  signal clks           : std_logic_vector(1 downto 0);
  signal uart_pmod      : std_logic_vector(3 downto 0);
  signal rxd            : std_logic;
  signal txd            : std_logic;
  signal cts            : std_logic;
  signal rts            : std_logic;


  ----12 MHz
  constant CLOCK_PERIOD : time := 83.33 ns;
  --constant CLOCK_PERIOD : time := 1 ns;
begin

process
  begin
    reset_n <= '0';
    wait for CLOCK_PERIOD*25*6/7;
    reset_n <= not reset_n;
    wait;
  end process;


  dut : component top
    port map(
      clk            => clk,
      scratchpad_clk => scratchpad_clk,
      reset_btn      => reset_n,
      rxd            => rxd,
      txd            => txd,
      cts            => cts,
      rts            => rts);

  cts <= '0';

  --assign the clocks
  process
  begin
    clks <= "11";
    wait for (CLOCK_PERIOD/2/3);
    clks <= "10";
    wait for (CLOCK_PERIOD/2/3);
    clks <= "11";
    wait for (CLOCK_PERIOD/2/3);
    clks <= "00";
    wait for (CLOCK_PERIOD/2/3);
    clks <= "01";
    wait for (CLOCK_PERIOD/2/3);
    clks <= "00";
    wait for (CLOCK_PERIOD/2/3);
  end process;

  clk            <= clks(1);
  scratchpad_clk <= clks(0);



end architecture;
