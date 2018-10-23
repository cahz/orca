library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.rv_components.all;
use work.utils.all;

entity cache is
  generic (
    NUM_LINES             : positive;
    LINE_SIZE             : positive;
    ADDRESS_WIDTH         : positive;
    WIDTH                 : positive;
    DIRTY_BITS            : natural;
    WRITE_FIRST_SUPPORTED : boolean
    );
  port (
    clk   : in std_logic;
    reset : in std_logic;

    --Read-only data ORCA-internal memory-mapped slave
    read_address         : in     std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    read_requestvalid    : in     std_logic;
    read_speculative     : in     std_logic;
    read_readdata        : out    std_logic_vector(WIDTH-1 downto 0);
    read_readdatavalid   : out    std_logic;
    read_readabort       : out    std_logic;
    read_miss            : buffer std_logic;
    read_requestinflight : buffer std_logic;
    read_lastaddress     : buffer std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    read_tag             : buffer std_logic_vector((ADDRESS_WIDTH-log2(NUM_LINES*LINE_SIZE))-1 downto 0);
    read_dirty_valid     : out    std_logic_vector(DIRTY_BITS downto 0);

    --Write-only data ORCA-internal memory-mapped slave
    write_address      : in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    write_byteenable   : in std_logic_vector((WIDTH/8)-1 downto 0);
    write_requestvalid : in std_logic;
    write_writedata    : in std_logic_vector(WIDTH-1 downto 0);
    write_tag_update   : in std_logic;
    write_dirty_valid  : in std_logic_vector(DIRTY_BITS downto 0)
    );
end entity;

architecture rtl of cache is
begin
  assert false report "Error: entity cache has been stubbed out and cannot be used in this release." severity failure;
end architecture;
