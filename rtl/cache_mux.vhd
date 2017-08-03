library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.rv_components.all;
use work.utils.all;

-- TODO Implement support for pipelined reads and writes through this mux.
-- One option would be to use a FIFO for the cache select values as well as the address
-- of the read, and complete all transactions while the FIFO is not empty. The mux should
-- be able to accept further transactions as long the FIFO is not full.
-- Another option would be to stop accepting transactions when we change from one bus to 
-- another, process all remaining transactions to the old bus, then start accepting new
-- transactions for the new bus.

entity cache_mux is
  generic (
    TCRAM_SIZE    : integer range 64 to 524288 := 32768; -- Byte size of cache
    ADDR_WIDTH    : integer                    := 32;
    REGISTER_SIZE : integer                    := 32;
    BYTE_SIZE     : integer                    := 8
  );
  port ( 
    clk        : in std_logic;
    reset      : in std_logic;

    in_AWID    : in std_logic_vector(3 downto 0);
    in_AWADDR  : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    in_AWLEN   : in std_logic_vector(3 downto 0);
    in_AWSIZE  : in std_logic_vector(2 downto 0);
    in_AWBURST : in std_logic_vector(1 downto 0); 

    in_AWLOCK  : in std_logic_vector(1 downto 0);
    in_AWCACHE : in std_logic_vector(3 downto 0);
    in_AWPROT  : in std_logic_vector(2 downto 0);
    in_AWVALID : in std_logic;
    in_AWREADY : out std_logic;

    in_WID     : in std_logic_vector(3 downto 0);
    in_WDATA   : in std_logic_vector(REGISTER_SIZE -1 downto 0);
    in_WSTRB   : in std_logic_vector(REGISTER_SIZE/BYTE_SIZE -1 downto 0);
    in_WLAST   : in std_logic;
    in_WVALID  : in std_logic;
    in_WREADY  : out std_logic;

    in_BID     : out std_logic_vector(3 downto 0);
    in_BRESP   : out std_logic_vector(1 downto 0);
    in_BVALID  : out std_logic;
    in_BREADY  : in std_logic;

    in_ARID    : in std_logic_vector(3 downto 0);
    in_ARADDR  : in std_logic_vector(ADDR_WIDTH -1 downto 0);
    in_ARLEN   : in std_logic_vector(3 downto 0);
    in_ARSIZE  : in std_logic_vector(2 downto 0);
    in_ARBURST : in std_logic_vector(1 downto 0);
    in_ARLOCK  : in std_logic_vector(1 downto 0);
    in_ARCACHE : in std_logic_vector(3 downto 0);
    in_ARPROT  : in std_logic_vector(2 downto 0);
    in_ARVALID : in std_logic;
    in_ARREADY : out std_logic;

    in_RID     : out std_logic_vector(3 downto 0);
    in_RDATA   : out std_logic_vector(REGISTER_SIZE -1 downto 0);
    in_RRESP   : out std_logic_vector(1 downto 0);
    in_RLAST   : out std_logic;
    in_RVALID  : out std_logic;
    in_RREADY  : in std_logic;
    
    cache_AWID     : out std_logic_vector(3 downto 0);
    cache_AWADDR   : out std_logic_vector(ADDR_WIDTH-1 downto 0);
    cache_AWLEN    : out std_logic_vector(3 downto 0);
    cache_AWSIZE   : out std_logic_vector(2 downto 0);
    cache_AWBURST  : out std_logic_vector(1 downto 0); 

    cache_AWLOCK   : out std_logic_vector(1 downto 0);
    cache_AWCACHE  : out std_logic_vector(3 downto 0);
    cache_AWPROT   : out std_logic_vector(2 downto 0);
    cache_AWVALID  : out std_logic;
    cache_AWREADY  : in std_logic;

    cache_WID      : out std_logic_vector(3 downto 0);
    cache_WDATA    : out std_logic_vector(REGISTER_SIZE -1 downto 0);
    cache_WSTRB    : out std_logic_vector(REGISTER_SIZE/BYTE_SIZE -1 downto 0);
    cache_WLAST    : out std_logic;
    cache_WVALID   : out std_logic;
    cache_WREADY   : in std_logic;

    cache_BID      : in std_logic_vector(3 downto 0);
    cache_BRESP    : in std_logic_vector(1 downto 0);
    cache_BVALID   : in std_logic;
    cache_BREADY   : out std_logic;

    cache_ARID     : out std_logic_vector(3 downto 0);
    cache_ARADDR   : out std_logic_vector(ADDR_WIDTH -1 downto 0);
    cache_ARLEN    : out std_logic_vector(3 downto 0);
    cache_ARSIZE   : out std_logic_vector(2 downto 0);
    cache_ARBURST  : out std_logic_vector(1 downto 0);
    cache_ARLOCK   : out std_logic_vector(1 downto 0);
    cache_ARCACHE  : out std_logic_vector(3 downto 0);
    cache_ARPROT   : out std_logic_vector(2 downto 0);
    cache_ARVALID  : out std_logic;
    cache_ARREADY  : in std_logic;

    cache_RID      : in std_logic_vector(3 downto 0);
    cache_RDATA    : in std_logic_vector(REGISTER_SIZE -1 downto 0);
    cache_RRESP    : in std_logic_vector(1 downto 0);
    cache_RLAST    : in std_logic;
    cache_RVALID   : in std_logic;
    cache_RREADY   : out std_logic;

    tcram_AWID     : out std_logic_vector(3 downto 0);
    tcram_AWADDR   : out std_logic_vector(ADDR_WIDTH-1 downto 0);
    tcram_AWLEN    : out std_logic_vector(3 downto 0);
    tcram_AWSIZE   : out std_logic_vector(2 downto 0);
    tcram_AWBURST  : out std_logic_vector(1 downto 0); 

    tcram_AWLOCK   : out std_logic_vector(1 downto 0);
    tcram_AWCACHE  : out std_logic_vector(3 downto 0);
    tcram_AWPROT   : out std_logic_vector(2 downto 0);
    tcram_AWVALID  : out std_logic;
    tcram_AWREADY  : in std_logic;

    tcram_WID      : out std_logic_vector(3 downto 0);
    tcram_WDATA    : out std_logic_vector(REGISTER_SIZE -1 downto 0);
    tcram_WSTRB    : out std_logic_vector(REGISTER_SIZE/BYTE_SIZE -1 downto 0);
    tcram_WLAST    : out std_logic;
    tcram_WVALID   : out std_logic;
    tcram_WREADY   : in std_logic;

    tcram_BID      : in std_logic_vector(3 downto 0);
    tcram_BRESP    : in std_logic_vector(1 downto 0);
    tcram_BVALID   : in std_logic;
    tcram_BREADY   : out std_logic;

    tcram_ARID     : out std_logic_vector(3 downto 0);
    tcram_ARADDR   : out std_logic_vector(ADDR_WIDTH -1 downto 0);
    tcram_ARLEN    : out std_logic_vector(3 downto 0);
    tcram_ARSIZE   : out std_logic_vector(2 downto 0);
    tcram_ARBURST  : out std_logic_vector(1 downto 0);
    tcram_ARLOCK   : out std_logic_vector(1 downto 0);
    tcram_ARCACHE  : out std_logic_vector(3 downto 0);
    tcram_ARPROT   : out std_logic_vector(2 downto 0);
    tcram_ARVALID  : out std_logic;
    tcram_ARREADY  : in std_logic;

    tcram_RID      : in std_logic_vector(3 downto 0);
    tcram_RDATA    : in std_logic_vector(REGISTER_SIZE -1 downto 0);
    tcram_RRESP    : in std_logic_vector(1 downto 0);
    tcram_RLAST    : in std_logic;
    tcram_RVALID   : in std_logic;
    tcram_RREADY   : out std_logic
  );
end entity cache_mux;

architecture rtl of cache_mux is
begin
end architecture;
