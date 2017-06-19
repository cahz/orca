library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.utils.all;

entity ram_mux is
  generic (
    DATA_WIDTH : natural := 32;
    ADDR_WIDTH : natural := 32
  );
  port (
    -- init signals
    nvm_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    nvm_wdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
    nvm_wen : in std_logic;
    nvm_byte_sel : in std_logic_vector(DATA_WIDTH/8 -1 downto 0);
    nvm_strb : in std_logic;
    nvm_ack : out std_logic;
    nvm_rdata : out std_logic_vector(DATA_WIDTH-1 downto 0);

    -- user signals
    user_ARREADY : out std_logic;
    user_ARADDR : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    user_ARVALID : in std_logic;

    user_RREADY : out std_logic;
    user_RDATA  : out std_logic_vector(ADDR_WIDTH-1 downto 0);
    user_RVALID : out std_logic;
    
    user_AWADDR : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    user_AWVALID : in std_logic;
    user_AWREADY : out std_logic;

    user_WDATA  : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    user_WVALID : in std_logic;
    user_WREADY : out std_logic;

    user_BREADY : in std_logic;
    user_BVALID : out std_logic;

    -- mux signals/ram inputs
    SEL : in std_logic;
    ram_addr : out std_logic_vector(ADDR_WIDTH-1 downto 0);
    ram_wdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
    ram_wen : out std_logic;
    ram_byte_sel : out std_logic_vector(DATA_WIDTH/8-1 downto 0);
    ram_strb : out std_logic;
    ram_ack : in std_logic;
    ram_rdata : in std_logic_vector(DATA_WIDTH-1 downto 0)
  );  
end entity ram_mux;

-- BUG: This bus is not AXI compliant, fix me.

architecture rtl of ram_mux is
begin
  ram_addr <= nvm_addr when (SEL = '0') 
    else user_ARADDR when (user_ARVALID = '1') else user_AWADDR;
  ram_wdata <= nvm_wdata when (SEL = '0') else USER_WDATA;
  ram_wen <= nvm_wen when (SEL = '0') else ((not user_ARVALID) and (USER_WVALID));
  ram_byte_sel <= nvm_byte_sel when (SEL = '0') else (others => '1');
  nvm_rdata <= ram_rdata when (SEL = '0') else (others => '0');
  user_RDATA <= ram_rdata when (SEL = '1') else (others => '0');
  ram_strb <= nvm_strb when (SEL = '0') else (user_ARVALID or user_WVALID); 
  nvm_ack <= ram_ack when (SEL = '0') else '0';

  user_ARREADY <= SEL;
  user_RREADY <= SEL;
  user_WREADY <= SEL;
  user_AWREADY <= SEL;
  user_BVALID <= SEL;
  user_RVALID <= SEL and ram_ack;
    
end architecture rtl;
