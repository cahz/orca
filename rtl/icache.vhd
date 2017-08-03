library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.rv_components.all;
use work.utils.all;

entity icache is
  generic (
    CACHE_SIZE     : integer range 64 to 524288 := 32768; -- Byte size of cache
    LINE_SIZE      : integer range 16 to 64     := 64;    -- Bytes per cache line 
    ADDR_WIDTH     : integer                    := 32;
    ORCA_WIDTH     : integer                    := 32;
    DRAM_WIDTH     : integer                    := 32; 
    BYTE_SIZE      : integer                    := 8;
    BURST_EN       : integer                    := 0;
		FAMILY				 : string											:= "ALTERA"
  );
  port (
    clk     : in std_logic;
    reset   : in std_logic;

    orca_AWID    : in std_logic_vector(3 downto 0);
    orca_AWADDR  : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    orca_AWLEN   : in std_logic_vector(3 downto 0);
    orca_AWSIZE  : in std_logic_vector(2 downto 0);
    orca_AWBURST : in std_logic_vector(1 downto 0); 

    orca_AWLOCK  : in std_logic_vector(1 downto 0);
    orca_AWCACHE : in std_logic_vector(3 downto 0);
    orca_AWPROT  : in std_logic_vector(2 downto 0);
    orca_AWVALID : in std_logic;
    orca_AWREADY : out std_logic;

    orca_WID     : in std_logic_vector(3 downto 0);
    orca_WDATA   : in std_logic_vector(ORCA_WIDTH -1 downto 0);
    orca_WSTRB   : in std_logic_vector(ORCA_WIDTH/BYTE_SIZE -1 downto 0);
    orca_WLAST   : in std_logic;
    orca_WVALID  : in std_logic;
    orca_WREADY  : out std_logic;

    orca_BID     : out std_logic_vector(3 downto 0);
    orca_BRESP   : out std_logic_vector(1 downto 0);
    orca_BVALID  : out std_logic;
    orca_BREADY  : in std_logic;

    orca_ARID    : in std_logic_vector(3 downto 0);
    orca_ARADDR  : in std_logic_vector(ADDR_WIDTH -1 downto 0);
    orca_ARLEN   : in std_logic_vector(3 downto 0);
    orca_ARSIZE  : in std_logic_vector(2 downto 0);
    orca_ARBURST : in std_logic_vector(1 downto 0);
    orca_ARLOCK  : in std_logic_vector(1 downto 0);
    orca_ARCACHE : in std_logic_vector(3 downto 0);
    orca_ARPROT  : in std_logic_vector(2 downto 0);
    orca_ARVALID : in std_logic;
    orca_ARREADY : out std_logic;

    orca_RID     : out std_logic_vector(3 downto 0);
    orca_RDATA   : out std_logic_vector(ORCA_WIDTH -1 downto 0);
    orca_RRESP   : out std_logic_vector(1 downto 0);
    orca_RLAST   : out std_logic;
    orca_RVALID  : out std_logic;
    orca_RREADY  : in std_logic;

    dram_AWID     : out std_logic_vector(3 downto 0);
    dram_AWADDR   : out std_logic_vector(ADDR_WIDTH-1 downto 0);
    dram_AWLEN    : out std_logic_vector(3 downto 0);
    dram_AWSIZE   : out std_logic_vector(2 downto 0);
    dram_AWBURST  : out std_logic_vector(1 downto 0); 

    dram_AWLOCK   : out std_logic_vector(1 downto 0);
    dram_AWCACHE  : out std_logic_vector(3 downto 0);
    dram_AWPROT   : out std_logic_vector(2 downto 0);
    dram_AWVALID  : out std_logic;
    dram_AWREADY  : in std_logic;

    dram_WID      : out std_logic_vector(3 downto 0);
    dram_WDATA    : out std_logic_vector(DRAM_WIDTH -1 downto 0);
    dram_WSTRB    : out std_logic_vector(DRAM_WIDTH/BYTE_SIZE -1 downto 0);
    dram_WLAST    : out std_logic;
    dram_WVALID   : out std_logic;
    dram_WREADY   : in std_logic;

    dram_BID      : in std_logic_vector(3 downto 0);
    dram_BRESP    : in std_logic_vector(1 downto 0);
    dram_BVALID   : in std_logic;
    dram_BREADY   : out std_logic;

    dram_ARID     : out std_logic_vector(3 downto 0);
    dram_ARADDR   : out std_logic_vector(ADDR_WIDTH -1 downto 0);
    dram_ARLEN    : out std_logic_vector(3 downto 0);
    dram_ARSIZE   : out std_logic_vector(2 downto 0);
    dram_ARBURST  : out std_logic_vector(1 downto 0);
    dram_ARLOCK   : out std_logic_vector(1 downto 0);
    dram_ARCACHE  : out std_logic_vector(3 downto 0);
    dram_ARPROT   : out std_logic_vector(2 downto 0);
    dram_ARVALID  : out std_logic;
    dram_ARREADY  : in std_logic;

    dram_RID      : in std_logic_vector(3 downto 0);
    dram_RDATA    : in std_logic_vector(DRAM_WIDTH -1 downto 0);
    dram_RRESP    : in std_logic_vector(1 downto 0);
    dram_RLAST    : in std_logic;
    dram_RVALID   : in std_logic;
    dram_RREADY   : out std_logic
  );
end entity icache;

architecture rtl of icache is
begin
end architecture;
