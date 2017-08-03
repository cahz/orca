-- bram_xilinx.vhd
-- Copyright (C) 2017 VectorBlox Computing, Inc.
--
-- Behavioural implementation of 8-bit wide synchronous true dual-port RAM
-- with output registers (aka pipeline registers).
--
-- Created for Xilinx BRAMs, which have en{ab} inputs (controls reads and
-- writes)and per-byte we{ab}[] inputs, compared to the wren_{ab} and
-- byteena_{ab}[] inputs of Altera BRAMs.

-- synthesis library vbx_lib
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
-- XST guide says conv_integer from std_logic_unsigned must be used.
use IEEE.std_logic_unsigned.all;

library work;
use work.utils.all;

entity bram_xilinx is
  generic (
    RAM_DEPTH : integer := 1024;
    RAM_WIDTH : integer := 8
    );
  port
    (
      address_a  : in  std_logic_vector(log2(RAM_DEPTH)-1 downto 0);
      address_b  : in  std_logic_vector(log2(RAM_DEPTH)-1 downto 0);
      clock      : in  std_logic;
      data_a     : in  std_logic_vector(RAM_WIDTH-1 downto 0);
      data_b     : in  std_logic_vector(RAM_WIDTH-1 downto 0);
      wren_a     : in  std_logic;
      wren_b     : in  std_logic;
      en_a       : in  std_logic;
      en_b       : in  std_logic;
      readdata_a : out std_logic_vector(RAM_WIDTH-1 downto 0);
      readdata_b : out std_logic_vector(RAM_WIDTH-1 downto 0)
      );
end bram_xilinx;


architecture rtl of bram_xilinx is

  type ram_type is array (RAM_DEPTH-1 downto 0) of std_logic_vector(RAM_WIDTH-1 downto 0);
  -- To infer a true DP RAM with Vivado Synthesis, must use separate processes
  -- for each port, and thus a shared variable.
  -- signal ram : ram_type;
  shared variable ram : ram_type;

begin

  process (clock)
  begin
    if clock'event and clock = '1' then
      if (en_a = '1') then
        -- NOTE: read assignment must come before write assignment to correctly
        -- model read-first synchronization.
        readdata_a <= ram(conv_integer(address_a));
        if wren_a = '1' then
          ram(conv_integer(address_a)) := data_a;
        end if;
      end if;
    end if;
  end process;

  process (clock)
  begin
    if clock'event and clock = '1' then
      if (en_b = '1') then
        readdata_b <= ram(conv_integer(address_b));
        if wren_b = '1' then
          ram(conv_integer(address_b)) := data_b;
        end if;
      end if;
    end if;
  end process;

end rtl;
