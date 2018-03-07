library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity edge_extender is
  generic (
    NUM_CYCLES : integer := 32
    );
  port (
    clk           : in  std_logic;
    reset         : in  std_logic;
    interrupt_in  : in  std_logic;
    interrupt_out : out std_logic
    );
end entity edge_extender;

architecture rtl of edge_extender is
  signal register_bank : std_logic_vector(NUM_CYCLES-1 downto 0);
begin

  gen_reg_bank :
  for i in 1 to NUM_CYCLES-1 generate
    process(clk)
    begin
      if rising_edge(clk) then
        if reset = '1' then
          register_bank(i) <= '0';
        else
          register_bank(i) <= register_bank(i-1);
        end if;
      end if;
    end process;
  end generate gen_reg_bank;

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        register_bank(0) <= '0';
      else
        register_bank(0) <= interrupt_in;
      end if;
    end if;
  end process;

  interrupt_out <= '1' when register_bank /= std_logic_vector(to_unsigned(0, NUM_CYCLES))
                   else '0';

end architecture rtl;
