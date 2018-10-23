
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library std;
use std.textio.all;


entity putchar_testbench is
generic (
  output_file : string := "putchar.out");
  port (
    -- inputs:
    signal address     : in  std_logic_vector (1 downto 0);
    signal chipselect  : in  std_logic;
    signal clk         : in  std_logic;
    signal reset       : in  std_logic;
    signal write_i       : in  std_logic;
    signal writedata   : in  std_logic_vector (31 downto 0);
    signal waitrequest : out std_logic);

end entity putchar_testbench;


architecture rtl of putchar_testbench is

begin
  waitrequest <= '0';
  process(clk)
    variable uart_byte :std_logic_vector(7 downto 0);
    file      outfile  : text;
    variable f_status: FILE_OPEN_STATUS;
    variable  outline  : line;
    variable out_chr : character;
    variable out_str : string(1 downto 1);

  begin
    if rising_edge(clk) then
      if write_i = '1' and chipselect = '1' then
        uart_byte := writedata(uart_byte'range);
        file_open(f_status,outfile, OUTPUT_FILE,append_mode);
        out_chr := character'val(to_integer(unsigned(uart_byte)));
        out_str(1) := out_chr;

        write(outfile,out_str);
        file_close(outfile);

      end if;
    end if;

  end process;


end rtl;
