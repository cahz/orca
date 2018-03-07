library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.idram_utils.all;
use work.idram_components.all;

entity idram_behav is
  generic (
    RAM_DEPTH   : integer := 1024;
    RAM_WIDTH   : integer := 32;
    WRITE_FIRST : boolean := false
    );
  port (
    clk : in std_logic;

    instr_address  : in  std_logic_vector(log2(RAM_DEPTH)-1 downto 0);
    instr_data_in  : in  std_logic_vector(RAM_WIDTH-1 downto 0);
    instr_we       : in  std_logic;
    instr_en       : in  std_logic;
    instr_be       : in  std_logic_vector((RAM_WIDTH/8)-1 downto 0);
    instr_readdata : out std_logic_vector(RAM_WIDTH-1 downto 0);

    data_address  : in  std_logic_vector(log2(RAM_DEPTH)-1 downto 0);
    data_data_in  : in  std_logic_vector(RAM_WIDTH-1 downto 0);
    data_we       : in  std_logic;
    data_en       : in  std_logic;
    data_be       : in  std_logic_vector((RAM_WIDTH/8)-1 downto 0);
    data_readdata : out std_logic_vector(RAM_WIDTH-1 downto 0)
    );
end entity idram_behav;

architecture rtl of idram_behav is
  type data_vector is array (natural range <>) of std_logic_vector(8-1 downto 0);
  signal wren_a     : std_logic_vector((RAM_WIDTH/8)-1 downto 0);
  signal wren_b     : std_logic_vector((RAM_WIDTH/8)-1 downto 0);
  signal en_a       : std_logic_vector((RAM_WIDTH/8)-1 downto 0);
  signal en_b       : std_logic_vector((RAM_WIDTH/8)-1 downto 0);
  signal data_a     : data_vector((RAM_WIDTH/8)-1 downto 0);
  signal data_b     : data_vector((RAM_WIDTH/8)-1 downto 0);
  signal readdata_a : data_vector((RAM_WIDTH/8)-1 downto 0);
  signal readdata_b : data_vector((RAM_WIDTH/8)-1 downto 0);
begin
  idram_gen : for gbyte in (RAM_WIDTH/8)-1 downto 0 generate
    wren_a(gbyte) <= instr_we and instr_be(gbyte);
    wren_b(gbyte) <= data_we and data_be(gbyte);
    en_a(gbyte)   <= instr_en and instr_be(gbyte);
    en_b(gbyte)   <= data_en and data_be(gbyte);

    data_a(gbyte) <= instr_data_in(((gbyte+1)*8)-1 downto gbyte*8);
    data_b(gbyte) <= data_data_in(((gbyte+1)*8)-1 downto gbyte*8);

    tdp_ram : component tdp_ram_behav
      generic map (
        RAM_DEPTH   => RAM_DEPTH,
        RAM_WIDTH   => 8,
        WRITE_FIRST => WRITE_FIRST
        )
      port map (
        address_a  => instr_address,
        address_b  => data_address,
        clk        => clk,
        data_a     => data_a(gbyte),
        data_b     => data_b(gbyte),
        wren_a     => wren_a(gbyte),
        wren_b     => wren_b(gbyte),
        en_a       => en_a(gbyte),
        en_b       => en_b(gbyte),
        readdata_a => readdata_a(gbyte),
        readdata_b => readdata_b(gbyte)
        );

    instr_readdata(((gbyte+1)*8)-1 downto gbyte*8) <= readdata_a(gbyte);
    data_readdata(((gbyte+1)*8)-1 downto gbyte*8)  <= readdata_b(gbyte);
  end generate idram_gen;

end architecture rtl;
