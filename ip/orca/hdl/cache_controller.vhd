library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.rv_components.all;
use work.utils.all;
use work.constants_pkg.all;

entity cache_controller is
  generic (
    CACHE_SIZE            : natural;
    LINE_SIZE             : positive range 16 to 256;
    ADDRESS_WIDTH         : positive;
    INTERNAL_WIDTH        : positive;
    EXTERNAL_WIDTH        : positive;
    LOG2_BURSTLENGTH      : positive;
    POLICY                : cache_policy;
    REGION_OPTIMIZATIONS  : boolean;
    WRITE_FIRST_SUPPORTED : boolean
    );
  port (
    clk   : in std_logic;
    reset : in std_logic;

    --Cache control (Invalidate/flush/writeback)
    from_cache_control_ready : out std_logic;
    to_cache_control_valid   : in  std_logic;
    to_cache_control_command : in  cache_control_command;
    to_cache_control_base    : in  std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    to_cache_control_last    : in  std_logic_vector(ADDRESS_WIDTH-1 downto 0);

    precache_idle : in  std_logic;
    cache_idle    : out std_logic;

    --Cache interface ORCA-internal memory-mapped slave
    cacheint_oimm_address       : in     std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    cacheint_oimm_byteenable    : in     std_logic_vector((INTERNAL_WIDTH/8)-1 downto 0);
    cacheint_oimm_requestvalid  : in     std_logic;
    cacheint_oimm_readnotwrite  : in     std_logic;
    cacheint_oimm_writedata     : in     std_logic_vector(INTERNAL_WIDTH-1 downto 0);
    cacheint_oimm_readdata      : out    std_logic_vector(INTERNAL_WIDTH-1 downto 0);
    cacheint_oimm_readdatavalid : out    std_logic;
    cacheint_oimm_waitrequest   : buffer std_logic;

    --Cached ORCA-internal memory-mapped master
    c_oimm_address            : out std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    c_oimm_burstlength        : out std_logic_vector(LOG2_BURSTLENGTH downto 0);
    c_oimm_burstlength_minus1 : out std_logic_vector(LOG2_BURSTLENGTH-1 downto 0);
    c_oimm_byteenable         : out std_logic_vector((EXTERNAL_WIDTH/8)-1 downto 0);
    c_oimm_requestvalid       : out std_logic;
    c_oimm_readnotwrite       : out std_logic;
    c_oimm_writedata          : out std_logic_vector(EXTERNAL_WIDTH-1 downto 0);
    c_oimm_writelast          : out std_logic;
    c_oimm_readdata           : in  std_logic_vector(EXTERNAL_WIDTH-1 downto 0);
    c_oimm_readdatavalid      : in  std_logic;
    c_oimm_waitrequest        : in  std_logic
    );
end entity cache_controller;

architecture rtl of cache_controller is
begin
  assert false report "Error: entity cache_controller has been stubbed out and cannot be used in this release." severity failure;
end architecture;
