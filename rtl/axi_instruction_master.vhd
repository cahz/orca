library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.rv_components.all;

entity axi_instruction_master is
  generic (
    REGISTER_SIZE : integer := 32;
    BYTE_SIZE : integer := 8
  );

  port (
    clk : in std_logic;
    aresetn : in std_logic;

    core_instruction_address : in std_logic_vector(REGISTER_SIZE-1 downto 0);
    core_instruction_read : in std_logic;
    core_instruction_readdata : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    core_instruction_readdatavalid : out std_logic;
    core_instruction_write : in std_logic;
    core_instruction_writedata : in std_logic_vector(REGISTER_SIZE-1 downto 0);
    core_instruction_waitrequest : out std_logic;

    AWID : out std_logic_vector(3 downto 0);
    AWADDR : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    AWLEN : out std_logic_vector(3 downto 0);
    AWSIZE : out std_logic_vector(2 downto 0);
    AWBURST : out std_logic_vector(1 downto 0);
    AWLOCK : out std_logic_vector(1 downto 0);
    AWCACHE : out std_logic_vector(3 downto 0);
    AWPROT : out std_logic_vector(2 downto 0);
    AWVALID : out std_logic;
    AWREADY : in std_logic;

    WID : out std_logic_vector(3 downto 0);
    WSTRB : out std_logic_vector(REGISTER_SIZE/BYTE_SIZE -1 downto 0);
    WLAST : out std_logic;
    WVALID : out std_logic;
    WDATA : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    WREADY : in std_logic;
    
    BID : in std_logic_vector(3 downto 0);
    BRESP : in std_logic_vector(1 downto 0);
    BVALID : in std_logic;
    BREADY : out std_logic;

    ARID : out std_logic_vector(3 downto 0);
    ARADDR : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    ARLEN : out std_logic_vector(3 downto 0);
    ARSIZE : out std_logic_vector(2 downto 0);
    ARLOCK : out std_logic_vector(1 downto 0);
    ARCACHE : out std_logic_vector(3 downto 0);
    ARPROT : out std_logic_vector(2 downto 0);
    ARBURST : out std_logic_vector(1 downto 0);
    ARVALID : out std_logic;
    ARREADY : in std_logic;

    RID : in std_logic_vector(3 downto 0);
    RDATA : in std_logic_vector(REGISTER_SIZE-1 downto 0);
    RRESP : in std_logic_vector(1 downto 0);
    RLAST : in std_logic;
    RVALID : in std_logic;
    RREADY : out std_logic
  );
    
end entity axi_instruction_master;

architecture rtl of axi_instruction_master is
  constant BURST_LEN  : std_logic_vector(3 downto 0) := "0000";
  constant BURST_SIZE : std_logic_vector(2 downto 0) := "010";
  constant BURST_INCR : std_logic_vector(1 downto 0) := "01";
  constant CACHE_VAL  : std_logic_vector(3 downto 0) := "0011";
  constant PROT_VAL   : std_logic_vector(2 downto 0) := "000";
  constant LOCK_VAL   : std_logic_vector(1 downto 0) := "00";

begin 

  AWID <= (others => '0');
  AWLEN <= BURST_LEN;
  AWSIZE <= BURST_SIZE;
  AWBURST <= BURST_INCR;
  AWLOCK <= LOCK_VAL;
  AWCACHE <= CACHE_VAL;
  AWPROT <= PROT_VAL;
  AWBURST <= BURST_INCR;
  AWVALID <= '0';
  AWADDR <= (others => '0');

  WID <= (others => '0');
  WLAST <= '0';
  WVALID <= '0';
  WDATA <= (others => '0');
  WSTRB <= (others => '0');

  BREADY <= '0';

  ARID <= (others => '0');
  ARLEN <= BURST_LEN;
  ARSIZE <= BURST_SIZE;
  ARLOCK <= LOCK_VAL;
  ARCACHE <= CACHE_VAL;
  ARPROT <= PROT_VAL;
  ARBURST <= BURST_INCR; 

  core_instruction_readdata <= RDATA;
  core_instruction_readdatavalid <= RVALID;
  core_instruction_waitrequest <= core_instruction_read and (not ARREADY); 

  ARADDR <= core_instruction_address;
  ARVALID <= core_instruction_read;
  RREADY <= '1';

end architecture;
