-- sp_bram.vhd
-- Copyright (C) 2016 VectorBlox Computing, Inc.
--
-- single port BRAM

-- synthesis library sp_bram_lib
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;


entity sp_bram is
  generic (
    LOG2_DEPTH : positive := 10;
    WIDTH      : positive := 8
    );
  port(
    clk : in std_logic;

    write_address : in unsigned(LOG2_DEPTH-1 downto 0);
    write_enable  : in std_logic;
    write_data    : in std_logic_vector(WIDTH-1 downto 0);

    read_address : in  unsigned(LOG2_DEPTH-1 downto 0);
    read_data    : out std_logic_vector(WIDTH-1 downto 0)
    );
end entity sp_bram;

architecture rtl of sp_bram is
  constant DEPTH                 : positive := 2**LOG2_DEPTH;
  type ram_type is array (natural range <>) of std_logic_vector(WIDTH-1 downto 0);
  signal ram                     : ram_type(DEPTH-1 downto 0);
  signal registered_read_address : unsigned(LOG2_DEPTH-1 downto 0);
begin
  process (clk) is
  begin  -- process
    if clk'event and clk = '1' then     -- rising clock edge
      if write_enable = '1' then
        ram(to_integer(write_address)) <= write_data;
      end if;
      registered_read_address <= read_address;
    end if;
  end process;
  read_data <= ram(to_integer(registered_read_address));
end architecture rtl;


