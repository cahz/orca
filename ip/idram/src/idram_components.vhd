library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.idram_utils.all;

package idram_components is
  component idram is
    generic (
      --Port types: 0 = AXI4Lite, 1 = AXI3, 2 = AXI4
      INSTR_PORT_TYPE : natural range 0 to 2 := 0;
      DATA_PORT_TYPE  : natural range 0 to 2 := 0;
      SIZE            : integer              := 32768;
      RAM_WIDTH       : integer              := 32;
      ADDR_WIDTH      : integer              := 32
      );
    port (
      clk   : in std_logic;
      reset : in std_logic;

      instr_AWID    : in std_logic_vector(13 downto 0);
      instr_AWADDR  : in std_logic_vector(ADDR_WIDTH-1 downto 0);
      instr_AWLEN   : in std_logic_vector(7-(4*(INSTR_PORT_TYPE mod 2)) downto 0);
      instr_AWSIZE  : in std_logic_vector(2 downto 0);
      instr_AWBURST : in std_logic_vector(1 downto 0);

      instr_AWLOCK  : in  std_logic_vector(1 downto 0);
      instr_AWCACHE : in  std_logic_vector(3 downto 0);
      instr_AWPROT  : in  std_logic_vector(2 downto 0);
      instr_AWVALID : in  std_logic;
      instr_AWREADY : out std_logic;

      instr_WID    : in  std_logic_vector(13 downto 0);
      instr_WDATA  : in  std_logic_vector(RAM_WIDTH-1 downto 0);
      instr_WSTRB  : in  std_logic_vector((RAM_WIDTH/8)-1 downto 0);
      instr_WLAST  : in  std_logic;
      instr_WVALID : in  std_logic;
      instr_WREADY : out std_logic;

      instr_BID    : out std_logic_vector(13 downto 0);
      instr_BRESP  : out std_logic_vector(1 downto 0);
      instr_BVALID : out std_logic;
      instr_BREADY : in  std_logic;

      instr_ARID    : in  std_logic_vector(13 downto 0);
      instr_ARADDR  : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
      instr_ARLEN   : in  std_logic_vector(7-(4*(INSTR_PORT_TYPE mod 2)) downto 0);
      instr_ARSIZE  : in  std_logic_vector(2 downto 0);
      instr_ARBURST : in  std_logic_vector(1 downto 0);
      instr_ARLOCK  : in  std_logic_vector(1 downto 0);
      instr_ARCACHE : in  std_logic_vector(3 downto 0);
      instr_ARPROT  : in  std_logic_vector(2 downto 0);
      instr_ARVALID : in  std_logic;
      instr_ARREADY : out std_logic;

      instr_RID    : out std_logic_vector(13 downto 0);
      instr_RDATA  : out std_logic_vector(RAM_WIDTH-1 downto 0);
      instr_RRESP  : out std_logic_vector(1 downto 0);
      instr_RLAST  : out std_logic;
      instr_RVALID : out std_logic;
      instr_RREADY : in  std_logic;

      data_AWID    : in std_logic_vector(13 downto 0);
      data_AWADDR  : in std_logic_vector(ADDR_WIDTH-1 downto 0);
      data_AWLEN   : in std_logic_vector(7-(4*(DATA_PORT_TYPE mod 2)) downto 0);
      data_AWSIZE  : in std_logic_vector(2 downto 0);
      data_AWBURST : in std_logic_vector(1 downto 0);

      data_AWLOCK  : in  std_logic_vector(1 downto 0);
      data_AWCACHE : in  std_logic_vector(3 downto 0);
      data_AWPROT  : in  std_logic_vector(2 downto 0);
      data_AWVALID : in  std_logic;
      data_AWREADY : out std_logic;

      data_WID    : in  std_logic_vector(13 downto 0);
      data_WDATA  : in  std_logic_vector(RAM_WIDTH-1 downto 0);
      data_WSTRB  : in  std_logic_vector((RAM_WIDTH/8)-1 downto 0);
      data_WLAST  : in  std_logic;
      data_WVALID : in  std_logic;
      data_WREADY : out std_logic;

      data_BID    : out std_logic_vector(13 downto 0);
      data_BRESP  : out std_logic_vector(1 downto 0);
      data_BVALID : out std_logic;
      data_BREADY : in  std_logic;

      data_ARID    : in  std_logic_vector(13 downto 0);
      data_ARADDR  : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
      data_ARLEN   : in  std_logic_vector(7-(4*(DATA_PORT_TYPE mod 2)) downto 0);
      data_ARSIZE  : in  std_logic_vector(2 downto 0);
      data_ARBURST : in  std_logic_vector(1 downto 0);
      data_ARLOCK  : in  std_logic_vector(1 downto 0);
      data_ARCACHE : in  std_logic_vector(3 downto 0);
      data_ARPROT  : in  std_logic_vector(2 downto 0);
      data_ARVALID : in  std_logic;
      data_ARREADY : out std_logic;

      data_RID    : out std_logic_vector(13 downto 0);
      data_RDATA  : out std_logic_vector(RAM_WIDTH-1 downto 0);
      data_RRESP  : out std_logic_vector(1 downto 0);
      data_RLAST  : out std_logic;
      data_RVALID : out std_logic;
      data_RREADY : in  std_logic
      );
  end component;

  component idram_behav is
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
  end component;

  component tdp_ram_behav is
    generic (
      RAM_DEPTH   : integer := 1024;
      RAM_WIDTH   : integer := 8;
      WRITE_FIRST : boolean := false
      );
    port (
      address_a  : in  std_logic_vector(log2(RAM_DEPTH)-1 downto 0);
      address_b  : in  std_logic_vector(log2(RAM_DEPTH)-1 downto 0);
      clk        : in  std_logic;
      data_a     : in  std_logic_vector(RAM_WIDTH-1 downto 0);
      data_b     : in  std_logic_vector(RAM_WIDTH-1 downto 0);
      wren_a     : in  std_logic;
      wren_b     : in  std_logic;
      en_a       : in  std_logic;
      en_b       : in  std_logic;
      readdata_a : out std_logic_vector(RAM_WIDTH-1 downto 0);
      readdata_b : out std_logic_vector(RAM_WIDTH-1 downto 0)
      );
  end component;
end package idram_components;
