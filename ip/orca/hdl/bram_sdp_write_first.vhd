library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.utils.all;

entity bram_sdp_write_first is
  generic (
    DEPTH                 : positive;
    WIDTH                 : positive;
    WRITE_FIRST_SUPPORTED : boolean
    );
  port (
    clk           : in  std_logic;
    read_address  : in  unsigned(log2(DEPTH)-1 downto 0);
    read_data     : out std_logic_vector(WIDTH-1 downto 0);
    write_address : in  unsigned(log2(DEPTH)-1 downto 0);
    write_enable  : in  std_logic;
    write_data    : in  std_logic_vector(WIDTH-1 downto 0)
    );
end;

architecture rtl of bram_sdp_write_first is
  type word_vector is array(DEPTH-1 downto 0) of std_logic_vector(WIDTH-1 downto 0);
begin

  bypass_gen : if not WRITE_FIRST_SUPPORTED generate
    signal ram                  : word_vector;
    signal ram_out              : std_logic_vector(WIDTH-1 downto 0);
    signal read_write_collision : std_logic;
    signal write_data_d1        : std_logic_vector(WIDTH-1 downto 0);
  begin
    process (clk) is
    begin
      if rising_edge(clk) then
        ram_out <= ram(to_integer(unsigned(read_address)));
        if write_enable = '1' then
          ram(to_integer(unsigned(write_address))) <= write_data;
        end if;
      end if;
    end process;

    --Correct for read/write collisions in RAMs that don't support write first
    read_data <= write_data_d1 when read_write_collision = '1' else ram_out;
    process(clk) is
    begin
      if rising_edge(clk) then
        read_write_collision <= '0';
        if read_address = write_address and write_enable = '1' then
          read_write_collision <= '1';
        end if;
        write_data_d1 <= write_data;
      end if;
    end process;
  end generate bypass_gen;

  write_first_gen : if WRITE_FIRST_SUPPORTED generate
    process (clk) is
      variable ram : word_vector;
    begin
      if rising_edge(clk) then
        if write_enable = '1' then
          ram(to_integer(unsigned(write_address))) := write_data;
        end if;
        read_data <= ram(to_integer(unsigned(read_address)));
      end if;
    end process;
  end generate write_first_gen;

end architecture;
