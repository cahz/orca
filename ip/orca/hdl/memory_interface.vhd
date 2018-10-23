library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.rv_components.all;
use work.utils.all;
use work.constants_pkg.all;

entity memory_interface is
  generic (
    REGISTER_SIZE         : positive range 32 to 32;
    WRITE_FIRST_SUPPORTED : boolean;

    WISHBONE_SINGLE_CYCLE_READS : boolean;
    MAX_IFETCHES_IN_FLIGHT      : positive;
    MAX_OUTSTANDING_REQUESTS    : positive;

    LOG2_BURSTLENGTH : positive;
    AXI_ID_WIDTH     : positive;

    AVALON_AUX   : boolean;
    WISHBONE_AUX : boolean;
    LMB_AUX      : boolean;

    AUX_MEMORY_REGIONS : natural range 0 to 4;
    AMR0_ADDR_BASE     : std_logic_vector(31 downto 0);
    AMR0_ADDR_LAST     : std_logic_vector(31 downto 0);

    UC_MEMORY_REGIONS : natural range 0 to 4;
    UMR0_ADDR_BASE    : std_logic_vector(31 downto 0);
    UMR0_ADDR_LAST    : std_logic_vector(31 downto 0);

    ICACHE_SIZE           : natural;
    ICACHE_LINE_SIZE      : positive range 16 to 256;
    ICACHE_EXTERNAL_WIDTH : positive;

    INSTRUCTION_REQUEST_REGISTER : request_register_type;
    INSTRUCTION_RETURN_REGISTER  : boolean;
    IUC_REQUEST_REGISTER         : request_register_type;
    IUC_RETURN_REGISTER          : boolean;
    IAUX_REQUEST_REGISTER        : request_register_type;
    IAUX_RETURN_REGISTER         : boolean;
    IC_REQUEST_REGISTER          : request_register_type;
    IC_RETURN_REGISTER           : boolean;

    DCACHE_SIZE           : natural;
    DCACHE_LINE_SIZE      : positive range 16 to 256;
    DCACHE_EXTERNAL_WIDTH : positive;
    DCACHE_WRITEBACK      : boolean;

    DATA_REQUEST_REGISTER : request_register_type;
    DATA_RETURN_REGISTER  : boolean;
    DUC_REQUEST_REGISTER  : request_register_type;
    DUC_RETURN_REGISTER   : boolean;
    DAUX_REQUEST_REGISTER : request_register_type;
    DAUX_RETURN_REGISTER  : boolean;
    DC_REQUEST_REGISTER   : request_register_type;
    DC_RETURN_REGISTER    : boolean
    );
  port (
    clk   : in std_logic;
    reset : in std_logic;

    --Auxiliary/Uncached memory regions
    amr_base_addrs : in std_logic_vector((imax(AUX_MEMORY_REGIONS, 1)*REGISTER_SIZE)-1 downto 0);
    amr_last_addrs : in std_logic_vector((imax(AUX_MEMORY_REGIONS, 1)*REGISTER_SIZE)-1 downto 0);
    umr_base_addrs : in std_logic_vector((imax(UC_MEMORY_REGIONS, 1)*REGISTER_SIZE)-1 downto 0);
    umr_last_addrs : in std_logic_vector((imax(UC_MEMORY_REGIONS, 1)*REGISTER_SIZE)-1 downto 0);

    --ICache control (Invalidate/flush/writeback)
    from_icache_control_ready : out std_logic;
    to_icache_control_valid   : in  std_logic;
    to_icache_control_command : in  cache_control_command;

    --DCache control (Invalidate/flush/writeback)
    from_dcache_control_ready : out std_logic;
    to_dcache_control_valid   : in  std_logic;
    to_dcache_control_command : in  cache_control_command;

    --Cache control common signals
    to_cache_control_base : in std_logic_vector(REGISTER_SIZE-1 downto 0);
    to_cache_control_last : in std_logic_vector(REGISTER_SIZE-1 downto 0);

    memory_interface_idle : out std_logic;

    --Instruction ORCA-internal memory-mapped master
    ifetch_oimm_address       : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
    ifetch_oimm_requestvalid  : in  std_logic;
    ifetch_oimm_readdata      : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    ifetch_oimm_waitrequest   : out std_logic;
    ifetch_oimm_readdatavalid : out std_logic;

    --Data ORCA-internal memory-mapped master
    lsu_oimm_address       : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
    lsu_oimm_byteenable    : in  std_logic_vector((REGISTER_SIZE/8)-1 downto 0);
    lsu_oimm_requestvalid  : in  std_logic;
    lsu_oimm_readnotwrite  : in  std_logic;
    lsu_oimm_writedata     : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
    lsu_oimm_readdata      : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    lsu_oimm_readdatavalid : out std_logic;
    lsu_oimm_waitrequest   : out std_logic;


    -------------------------------------------------------------------------------
    --AVALON
    -------------------------------------------------------------------------------
    --Avalon data master
    avm_data_address       : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    avm_data_byteenable    : out std_logic_vector((REGISTER_SIZE/8)-1 downto 0);
    avm_data_read          : out std_logic;
    avm_data_readdata      : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
    avm_data_write         : out std_logic;
    avm_data_writedata     : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    avm_data_waitrequest   : in  std_logic;
    avm_data_readdatavalid : in  std_logic;

    --Avalon instruction master
    avm_instruction_address       : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    avm_instruction_read          : out std_logic;
    avm_instruction_readdata      : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
    avm_instruction_waitrequest   : in  std_logic;
    avm_instruction_readdatavalid : in  std_logic;

    -------------------------------------------------------------------------------
    --WISHBONE
    -------------------------------------------------------------------------------
    --WISHBONE data master
    data_ADR_O   : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    data_DAT_I   : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
    data_DAT_O   : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    data_WE_O    : out std_logic;
    data_SEL_O   : out std_logic_vector((REGISTER_SIZE/8)-1 downto 0);
    data_STB_O   : out std_logic;
    data_ACK_I   : in  std_logic;
    data_CYC_O   : out std_logic;
    data_CTI_O   : out std_logic_vector(2 downto 0);
    data_STALL_I : in  std_logic;

    --WISHBONE instruction master
    instr_ADR_O   : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    instr_DAT_I   : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
    instr_STB_O   : out std_logic;
    instr_ACK_I   : in  std_logic;
    instr_CYC_O   : out std_logic;
    instr_CTI_O   : out std_logic_vector(2 downto 0);
    instr_STALL_I : in  std_logic;

    -------------------------------------------------------------------------------
    --AXI
    -------------------------------------------------------------------------------
    --AXI4-Lite uncached instruction master
    --A full AXI3 interface is exposed for systems that require it, but
    --only the (read-only) AXI4-Lite signals are needed
    IUC_ARID    : out std_logic_vector(AXI_ID_WIDTH-1 downto 0);
    IUC_ARADDR  : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    IUC_ARLEN   : out std_logic_vector(LOG2_BURSTLENGTH-1 downto 0);
    IUC_ARSIZE  : out std_logic_vector(2 downto 0);
    IUC_ARBURST : out std_logic_vector(1 downto 0);
    IUC_ARLOCK  : out std_logic_vector(1 downto 0);
    IUC_ARCACHE : out std_logic_vector(3 downto 0);
    IUC_ARPROT  : out std_logic_vector(2 downto 0);
    IUC_ARVALID : out std_logic;
    IUC_ARREADY : in  std_logic;

    IUC_RID    : in  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
    IUC_RDATA  : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
    IUC_RRESP  : in  std_logic_vector(1 downto 0);
    IUC_RLAST  : in  std_logic;
    IUC_RVALID : in  std_logic;
    IUC_RREADY : out std_logic;

    IUC_AWID    : out std_logic_vector(AXI_ID_WIDTH-1 downto 0);
    IUC_AWADDR  : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    IUC_AWLEN   : out std_logic_vector(LOG2_BURSTLENGTH-1 downto 0);
    IUC_AWSIZE  : out std_logic_vector(2 downto 0);
    IUC_AWBURST : out std_logic_vector(1 downto 0);
    IUC_AWLOCK  : out std_logic_vector(1 downto 0);
    IUC_AWCACHE : out std_logic_vector(3 downto 0);
    IUC_AWPROT  : out std_logic_vector(2 downto 0);
    IUC_AWVALID : out std_logic;
    IUC_AWREADY : in  std_logic;

    IUC_WID    : out std_logic_vector(AXI_ID_WIDTH-1 downto 0);
    IUC_WDATA  : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    IUC_WSTRB  : out std_logic_vector((REGISTER_SIZE/8)-1 downto 0);
    IUC_WLAST  : out std_logic;
    IUC_WVALID : out std_logic;
    IUC_WREADY : in  std_logic;

    IUC_BID    : in  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
    IUC_BRESP  : in  std_logic_vector(1 downto 0);
    IUC_BVALID : in  std_logic;
    IUC_BREADY : out std_logic;

    --AXI4-Lite uncached data master
    --A full AXI3 interface is exposed for systems that require it, but
    --only the AXI4-Lite signals are needed
    DUC_AWID    : out std_logic_vector(AXI_ID_WIDTH-1 downto 0);
    DUC_AWADDR  : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    DUC_AWLEN   : out std_logic_vector(LOG2_BURSTLENGTH-1 downto 0);
    DUC_AWSIZE  : out std_logic_vector(2 downto 0);
    DUC_AWBURST : out std_logic_vector(1 downto 0);
    DUC_AWLOCK  : out std_logic_vector(1 downto 0);
    DUC_AWCACHE : out std_logic_vector(3 downto 0);
    DUC_AWPROT  : out std_logic_vector(2 downto 0);
    DUC_AWVALID : out std_logic;
    DUC_AWREADY : in  std_logic;

    DUC_WID    : out std_logic_vector(AXI_ID_WIDTH-1 downto 0);
    DUC_WDATA  : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    DUC_WSTRB  : out std_logic_vector((REGISTER_SIZE/8)-1 downto 0);
    DUC_WLAST  : out std_logic;
    DUC_WVALID : out std_logic;
    DUC_WREADY : in  std_logic;

    DUC_BID    : in  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
    DUC_BRESP  : in  std_logic_vector(1 downto 0);
    DUC_BVALID : in  std_logic;
    DUC_BREADY : out std_logic;

    DUC_ARID    : out std_logic_vector(AXI_ID_WIDTH-1 downto 0);
    DUC_ARADDR  : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    DUC_ARLEN   : out std_logic_vector(LOG2_BURSTLENGTH-1 downto 0);
    DUC_ARSIZE  : out std_logic_vector(2 downto 0);
    DUC_ARBURST : out std_logic_vector(1 downto 0);
    DUC_ARLOCK  : out std_logic_vector(1 downto 0);
    DUC_ARCACHE : out std_logic_vector(3 downto 0);
    DUC_ARPROT  : out std_logic_vector(2 downto 0);
    DUC_ARVALID : out std_logic;
    DUC_ARREADY : in  std_logic;

    DUC_RID    : in  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
    DUC_RDATA  : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
    DUC_RRESP  : in  std_logic_vector(1 downto 0);
    DUC_RLAST  : in  std_logic;
    DUC_RVALID : in  std_logic;
    DUC_RREADY : out std_logic;

    --AXI3/4 cacheable instruction master
    --WID can be unconnected and LOG2_BURSTLENGTH set to 8 to for AXI4
    --Read-only, write is exposed for systems that require it
    IC_ARID    : out std_logic_vector(AXI_ID_WIDTH-1 downto 0);
    IC_ARADDR  : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    IC_ARLEN   : out std_logic_vector(LOG2_BURSTLENGTH-1 downto 0);
    IC_ARSIZE  : out std_logic_vector(2 downto 0);
    IC_ARBURST : out std_logic_vector(1 downto 0);
    IC_ARLOCK  : out std_logic_vector(1 downto 0);
    IC_ARCACHE : out std_logic_vector(3 downto 0);
    IC_ARPROT  : out std_logic_vector(2 downto 0);
    IC_ARVALID : out std_logic;
    IC_ARREADY : in  std_logic;

    IC_RID    : in  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
    IC_RDATA  : in  std_logic_vector(ICACHE_EXTERNAL_WIDTH-1 downto 0);
    IC_RRESP  : in  std_logic_vector(1 downto 0);
    IC_RLAST  : in  std_logic;
    IC_RVALID : in  std_logic;
    IC_RREADY : out std_logic;

    IC_AWID    : out std_logic_vector(AXI_ID_WIDTH-1 downto 0);
    IC_AWADDR  : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    IC_AWLEN   : out std_logic_vector(LOG2_BURSTLENGTH-1 downto 0);
    IC_AWSIZE  : out std_logic_vector(2 downto 0);
    IC_AWBURST : out std_logic_vector(1 downto 0);
    IC_AWLOCK  : out std_logic_vector(1 downto 0);
    IC_AWCACHE : out std_logic_vector(3 downto 0);
    IC_AWPROT  : out std_logic_vector(2 downto 0);
    IC_AWVALID : out std_logic;
    IC_AWREADY : in  std_logic;

    IC_WID    : out std_logic_vector(AXI_ID_WIDTH-1 downto 0);
    IC_WDATA  : out std_logic_vector(ICACHE_EXTERNAL_WIDTH-1 downto 0);
    IC_WSTRB  : out std_logic_vector((ICACHE_EXTERNAL_WIDTH/8)-1 downto 0);
    IC_WLAST  : out std_logic;
    IC_WVALID : out std_logic;
    IC_WREADY : in  std_logic;
    IC_BID    : in  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
    IC_BRESP  : in  std_logic_vector(1 downto 0);
    IC_BVALID : in  std_logic;
    IC_BREADY : out std_logic;

    --AXI3/4 cacheable data master
    --WID can be unconnected and LOG2_BURSTLENGTH set to 8 to for AXI4
    DC_ARID    : out std_logic_vector(AXI_ID_WIDTH-1 downto 0);
    DC_ARADDR  : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    DC_ARLEN   : out std_logic_vector(LOG2_BURSTLENGTH-1 downto 0);
    DC_ARSIZE  : out std_logic_vector(2 downto 0);
    DC_ARBURST : out std_logic_vector(1 downto 0);
    DC_ARLOCK  : out std_logic_vector(1 downto 0);
    DC_ARCACHE : out std_logic_vector(3 downto 0);
    DC_ARPROT  : out std_logic_vector(2 downto 0);
    DC_ARVALID : out std_logic;
    DC_ARREADY : in  std_logic;

    DC_RID    : in  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
    DC_RDATA  : in  std_logic_vector(DCACHE_EXTERNAL_WIDTH-1 downto 0);
    DC_RRESP  : in  std_logic_vector(1 downto 0);
    DC_RLAST  : in  std_logic;
    DC_RVALID : in  std_logic;
    DC_RREADY : out std_logic;

    DC_AWID    : out std_logic_vector(AXI_ID_WIDTH-1 downto 0);
    DC_AWADDR  : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    DC_AWLEN   : out std_logic_vector(LOG2_BURSTLENGTH-1 downto 0);
    DC_AWSIZE  : out std_logic_vector(2 downto 0);
    DC_AWBURST : out std_logic_vector(1 downto 0);
    DC_AWLOCK  : out std_logic_vector(1 downto 0);
    DC_AWCACHE : out std_logic_vector(3 downto 0);
    DC_AWPROT  : out std_logic_vector(2 downto 0);
    DC_AWVALID : out std_logic;
    DC_AWREADY : in  std_logic;

    DC_WID    : out std_logic_vector(AXI_ID_WIDTH-1 downto 0);
    DC_WDATA  : out std_logic_vector(DCACHE_EXTERNAL_WIDTH-1 downto 0);
    DC_WSTRB  : out std_logic_vector((DCACHE_EXTERNAL_WIDTH/8)-1 downto 0);
    DC_WLAST  : out std_logic;
    DC_WVALID : out std_logic;
    DC_WREADY : in  std_logic;
    DC_BID    : in  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
    DC_BRESP  : in  std_logic_vector(1 downto 0);
    DC_BVALID : in  std_logic;
    DC_BREADY : out std_logic;

    -------------------------------------------------------------------------------
    --LMB
    -------------------------------------------------------------------------------
    --Xilinx local memory bus instruction master
    --Read-only, write is exposed for systems that require it
    ILMB_Addr         : out std_logic_vector(0 to REGISTER_SIZE-1);
    ILMB_Byte_Enable  : out std_logic_vector(0 to (REGISTER_SIZE/8)-1);
    ILMB_Data_Write   : out std_logic_vector(0 to REGISTER_SIZE-1);
    ILMB_AS           : out std_logic;
    ILMB_Read_Strobe  : out std_logic;
    ILMB_Write_Strobe : out std_logic;
    ILMB_Data_Read    : in  std_logic_vector(0 to REGISTER_SIZE-1);
    ILMB_Ready        : in  std_logic;
    ILMB_Wait         : in  std_logic;
    ILMB_CE           : in  std_logic;
    ILMB_UE           : in  std_logic;

    --Xilinx local memory bus data master
    DLMB_Addr         : out std_logic_vector(0 to REGISTER_SIZE-1);
    DLMB_Byte_Enable  : out std_logic_vector(0 to (REGISTER_SIZE/8)-1);
    DLMB_Data_Write   : out std_logic_vector(0 to REGISTER_SIZE-1);
    DLMB_AS           : out std_logic;
    DLMB_Read_Strobe  : out std_logic;
    DLMB_Write_Strobe : out std_logic;
    DLMB_Data_Read    : in  std_logic_vector(0 to REGISTER_SIZE-1);
    DLMB_Ready        : in  std_logic;
    DLMB_Wait         : in  std_logic;
    DLMB_CE           : in  std_logic;
    DLMB_UE           : in  std_logic
    );
end entity memory_interface;

architecture rtl of memory_interface is
  constant A4L_BURST_SIZE : std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(log2(REGISTER_SIZE/8), 3));
  constant A4L_BURST_INCR : std_logic_vector(1 downto 0) := "01";
  constant A4L_LOCK_VAL   : std_logic_vector(1 downto 0) := "00";
  constant A4L_CACHE_VAL  : std_logic_vector(3 downto 0) := "0000";

  signal lsu_oimm_address_aligned : std_logic_vector(lsu_oimm_address'range);
  signal iinternal_register_idle  : std_logic;
  signal iexternal_registers_idle : std_logic;
  signal dinternal_register_idle  : std_logic;
  signal dexternal_registers_idle : std_logic;
  signal icache_idle              : std_logic;
  signal dcache_idle              : std_logic;
  signal ic_master_idle           : std_logic;
  signal dc_master_idle           : std_logic;
  signal iuc_master_idle          : std_logic;
  signal duc_master_idle          : std_logic;

  signal iuc_oimm_address       : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal iuc_oimm_byteenable    : std_logic_vector((REGISTER_SIZE/8)-1 downto 0);
  signal iuc_oimm_requestvalid  : std_logic;
  signal iuc_oimm_readnotwrite  : std_logic;
  signal iuc_oimm_writedata     : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal iuc_oimm_readdata      : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal iuc_oimm_readdatavalid : std_logic;
  signal iuc_oimm_waitrequest   : std_logic;

  signal duc_oimm_address       : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal duc_oimm_byteenable    : std_logic_vector((REGISTER_SIZE/8)-1 downto 0);
  signal duc_oimm_requestvalid  : std_logic;
  signal duc_oimm_readnotwrite  : std_logic;
  signal duc_oimm_writedata     : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal duc_oimm_readdata      : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal duc_oimm_readdatavalid : std_logic;
  signal duc_oimm_waitrequest   : std_logic;

  signal iaux_oimm_address       : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal iaux_oimm_byteenable    : std_logic_vector((REGISTER_SIZE/8)-1 downto 0);
  signal iaux_oimm_requestvalid  : std_logic;
  signal iaux_oimm_readnotwrite  : std_logic;
  signal iaux_oimm_writedata     : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal iaux_oimm_readdata      : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal iaux_oimm_readdatavalid : std_logic;
  signal iaux_oimm_waitrequest   : std_logic;

  signal daux_oimm_address       : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal daux_oimm_byteenable    : std_logic_vector((REGISTER_SIZE/8)-1 downto 0);
  signal daux_oimm_requestvalid  : std_logic;
  signal daux_oimm_readnotwrite  : std_logic;
  signal daux_oimm_writedata     : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal daux_oimm_readdata      : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal daux_oimm_readdatavalid : std_logic;
  signal daux_oimm_waitrequest   : std_logic;

  signal icacheint_oimm_address       : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal icacheint_oimm_byteenable    : std_logic_vector((REGISTER_SIZE/8)-1 downto 0);
  signal icacheint_oimm_requestvalid  : std_logic;
  signal icacheint_oimm_readnotwrite  : std_logic;
  signal icacheint_oimm_writedata     : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal icacheint_oimm_readdata      : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal icacheint_oimm_readdatavalid : std_logic;
  signal icacheint_oimm_waitrequest   : std_logic;

  signal dcacheint_oimm_address       : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal dcacheint_oimm_byteenable    : std_logic_vector((REGISTER_SIZE/8)-1 downto 0);
  signal dcacheint_oimm_requestvalid  : std_logic;
  signal dcacheint_oimm_readnotwrite  : std_logic;
  signal dcacheint_oimm_writedata     : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal dcacheint_oimm_readdata      : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal dcacheint_oimm_readdatavalid : std_logic;
  signal dcacheint_oimm_waitrequest   : std_logic;

  signal aresetn : std_logic;
begin
  assert (bool_to_int(AVALON_AUX) + bool_to_int(WISHBONE_AUX) + bool_to_int(LMB_AUX)) < 2 report
    "At most one auxiliary interface type (AVALON_AUX, WISHBONE_AUX, LMB_AUX) must be enabled"
    severity failure;
  assert AUX_MEMORY_REGIONS = 0 or (AVALON_AUX or WISHBONE_AUX or LMB_AUX) report
    "if AUX_MEMORY_REGIONS > 0 then one auxiliary interface (AVALON_AUX, WISHBONE_AUX, or LMB_AUX) must be enabled"
    severity failure;

  aresetn <= not reset;

  memory_interface_idle <= iinternal_register_idle and dinternal_register_idle and
                           iexternal_registers_idle and dexternal_registers_idle and
                           icache_idle and dcache_idle and
                           ic_master_idle and dc_master_idle and
                           iuc_master_idle and duc_master_idle;

  -----------------------------------------------------------------------------
  -- Instruction cache and mux
  -----------------------------------------------------------------------------
  instruction_cache_mux : cache_mux
    generic map (
      ADDRESS_WIDTH => REGISTER_SIZE,
      DATA_WIDTH    => REGISTER_SIZE,

      MAX_OUTSTANDING_READS => MAX_IFETCHES_IN_FLIGHT,

      AUX_MEMORY_REGIONS => AUX_MEMORY_REGIONS,
      AMR0_ADDR_BASE     => AMR0_ADDR_BASE,
      AMR0_ADDR_LAST     => AMR0_ADDR_LAST,

      UC_MEMORY_REGIONS => UC_MEMORY_REGIONS,
      UMR0_ADDR_BASE    => UMR0_ADDR_BASE,
      UMR0_ADDR_LAST    => UMR0_ADDR_LAST,

      CACHE_SIZE      => ICACHE_SIZE,
      CACHE_LINE_SIZE => ICACHE_LINE_SIZE,

      INTERNAL_REQUEST_REGISTER => INSTRUCTION_REQUEST_REGISTER,
      INTERNAL_RETURN_REGISTER  => INSTRUCTION_RETURN_REGISTER,
      UC_REQUEST_REGISTER       => IUC_REQUEST_REGISTER,
      UC_RETURN_REGISTER        => IUC_RETURN_REGISTER,
      AUX_REQUEST_REGISTER      => IAUX_REQUEST_REGISTER,
      AUX_RETURN_REGISTER       => IAUX_RETURN_REGISTER
      )
    port map (
      clk   => clk,
      reset => reset,

      amr_base_addrs => amr_base_addrs,
      amr_last_addrs => amr_last_addrs,
      umr_base_addrs => umr_base_addrs,
      umr_last_addrs => umr_last_addrs,

      internal_register_idle  => iinternal_register_idle,
      external_registers_idle => iexternal_registers_idle,

      oimm_address       => ifetch_oimm_address,
      oimm_requestvalid  => ifetch_oimm_requestvalid,
      oimm_readdata      => ifetch_oimm_readdata,
      oimm_readdatavalid => ifetch_oimm_readdatavalid,
      oimm_waitrequest   => ifetch_oimm_waitrequest,

      cacheint_oimm_address       => icacheint_oimm_address,
      cacheint_oimm_byteenable    => icacheint_oimm_byteenable,
      cacheint_oimm_requestvalid  => icacheint_oimm_requestvalid,
      cacheint_oimm_readnotwrite  => icacheint_oimm_readnotwrite,
      cacheint_oimm_writedata     => icacheint_oimm_writedata,
      cacheint_oimm_readdata      => icacheint_oimm_readdata,
      cacheint_oimm_readdatavalid => icacheint_oimm_readdatavalid,
      cacheint_oimm_waitrequest   => icacheint_oimm_waitrequest,

      uc_oimm_address       => iuc_oimm_address,
      uc_oimm_byteenable    => iuc_oimm_byteenable,
      uc_oimm_requestvalid  => iuc_oimm_requestvalid,
      uc_oimm_readnotwrite  => iuc_oimm_readnotwrite,
      uc_oimm_writedata     => iuc_oimm_writedata,
      uc_oimm_readdata      => iuc_oimm_readdata,
      uc_oimm_readdatavalid => iuc_oimm_readdatavalid,
      uc_oimm_waitrequest   => iuc_oimm_waitrequest,

      aux_oimm_address       => iaux_oimm_address,
      aux_oimm_byteenable    => iaux_oimm_byteenable,
      aux_oimm_requestvalid  => iaux_oimm_requestvalid,
      aux_oimm_readnotwrite  => iaux_oimm_readnotwrite,
      aux_oimm_writedata     => iaux_oimm_writedata,
      aux_oimm_readdata      => iaux_oimm_readdata,
      aux_oimm_readdatavalid => iaux_oimm_readdatavalid,
      aux_oimm_waitrequest   => iaux_oimm_waitrequest
      );

  instruction_cache_gen : if ICACHE_SIZE /= 0 generate
    signal ic_oimm_address            : std_logic_vector(REGISTER_SIZE-1 downto 0);
    signal ic_oimm_burstlength        : std_logic_vector(LOG2_BURSTLENGTH downto 0);
    signal ic_oimm_burstlength_minus1 : std_logic_vector(LOG2_BURSTLENGTH-1 downto 0);
    signal ic_oimm_byteenable         : std_logic_vector((REGISTER_SIZE/8)-1 downto 0);
    signal ic_oimm_requestvalid       : std_logic;
    signal ic_oimm_readnotwrite       : std_logic;
    signal ic_oimm_writedata          : std_logic_vector(REGISTER_SIZE-1 downto 0);
    signal ic_oimm_writelast          : std_logic;
    signal ic_oimm_readdata           : std_logic_vector(REGISTER_SIZE-1 downto 0);
    signal ic_oimm_readdatavalid      : std_logic;
    signal ic_oimm_waitrequest        : std_logic;
  begin
    instruction_cache : cache_controller
      generic map (
        CACHE_SIZE            => ICACHE_SIZE,
        LINE_SIZE             => ICACHE_LINE_SIZE,
        ADDRESS_WIDTH         => REGISTER_SIZE,
        INTERNAL_WIDTH        => REGISTER_SIZE,
        EXTERNAL_WIDTH        => ICACHE_EXTERNAL_WIDTH,
        LOG2_BURSTLENGTH      => LOG2_BURSTLENGTH,
        POLICY                => READ_ONLY,
        REGION_OPTIMIZATIONS  => true,
        WRITE_FIRST_SUPPORTED => WRITE_FIRST_SUPPORTED
        )
      port map (
        clk   => clk,
        reset => reset,

        from_cache_control_ready => from_icache_control_ready,
        to_cache_control_valid   => to_icache_control_valid,
        to_cache_control_command => to_icache_control_command,
        to_cache_control_base    => to_cache_control_base,
        to_cache_control_last    => to_cache_control_last,

        precache_idle => iinternal_register_idle,
        cache_idle    => icache_idle,

        cacheint_oimm_address       => icacheint_oimm_address,
        cacheint_oimm_byteenable    => icacheint_oimm_byteenable,
        cacheint_oimm_requestvalid  => icacheint_oimm_requestvalid,
        cacheint_oimm_readnotwrite  => icacheint_oimm_readnotwrite,
        cacheint_oimm_writedata     => icacheint_oimm_writedata,
        cacheint_oimm_readdata      => icacheint_oimm_readdata,
        cacheint_oimm_readdatavalid => icacheint_oimm_readdatavalid,
        cacheint_oimm_waitrequest   => icacheint_oimm_waitrequest,

        c_oimm_address            => ic_oimm_address,
        c_oimm_burstlength        => ic_oimm_burstlength,
        c_oimm_burstlength_minus1 => ic_oimm_burstlength_minus1,
        c_oimm_byteenable         => ic_oimm_byteenable,
        c_oimm_requestvalid       => ic_oimm_requestvalid,
        c_oimm_readnotwrite       => ic_oimm_readnotwrite,
        c_oimm_writedata          => ic_oimm_writedata,
        c_oimm_writelast          => ic_oimm_writelast,
        c_oimm_readdata           => ic_oimm_readdata,
        c_oimm_readdatavalid      => ic_oimm_readdatavalid,
        c_oimm_waitrequest        => ic_oimm_waitrequest
        );

    ic_master : axi_master
      generic map (
        ADDRESS_WIDTH            => REGISTER_SIZE,
        DATA_WIDTH               => REGISTER_SIZE,
        ID_WIDTH                 => AXI_ID_WIDTH,
        LOG2_BURSTLENGTH         => LOG2_BURSTLENGTH,
        MAX_OUTSTANDING_REQUESTS => 0,
        REQUEST_REGISTER         => IC_REQUEST_REGISTER,
        RETURN_REGISTER          => IC_RETURN_REGISTER
        )
      port map (
        clk     => clk,
        reset   => reset,
        aresetn => aresetn,

        master_idle => ic_master_idle,

        oimm_address            => ic_oimm_address,
        oimm_burstlength_minus1 => ic_oimm_burstlength_minus1,
        oimm_byteenable         => ic_oimm_byteenable,
        oimm_requestvalid       => ic_oimm_requestvalid,
        oimm_readnotwrite       => ic_oimm_readnotwrite,
        oimm_writedata          => ic_oimm_writedata,
        oimm_writelast          => ic_oimm_writelast,
        oimm_readdata           => ic_oimm_readdata,
        oimm_readdatavalid      => ic_oimm_readdatavalid,
        oimm_waitrequest        => ic_oimm_waitrequest,

        AWID    => IC_AWID,
        AWADDR  => IC_AWADDR,
        AWLEN   => IC_AWLEN,
        AWSIZE  => IC_AWSIZE,
        AWBURST => IC_AWBURST,
        AWLOCK  => IC_AWLOCK,
        AWCACHE => IC_AWCACHE,
        AWPROT  => IC_AWPROT,
        AWVALID => IC_AWVALID,
        AWREADY => IC_AWREADY,

        WID    => IC_WID,
        WSTRB  => IC_WSTRB,
        WVALID => IC_WVALID,
        WLAST  => IC_WLAST,
        WDATA  => IC_WDATA,
        WREADY => IC_WREADY,

        BID    => IC_BID,
        BRESP  => IC_BRESP,
        BVALID => IC_BVALID,
        BREADY => IC_BREADY,

        ARID    => IC_ARID,
        ARADDR  => IC_ARADDR,
        ARLEN   => IC_ARLEN,
        ARSIZE  => IC_ARSIZE,
        ARBURST => IC_ARBURST,
        ARLOCK  => IC_ARLOCK,
        ARCACHE => IC_ARCACHE,
        ARPROT  => IC_ARPROT,
        ARVALID => IC_ARVALID,
        ARREADY => IC_ARREADY,

        RID    => IC_RID,
        RDATA  => IC_RDATA,
        RRESP  => IC_RRESP,
        RLAST  => IC_RLAST,
        RVALID => IC_RVALID,
        RREADY => IC_RREADY
        );
  end generate instruction_cache_gen;
  no_instruction_cache_gen : if ICACHE_SIZE = 0 generate
    from_icache_control_ready <= '1';
    icache_idle               <= '1';
    ic_master_idle            <= '1';

    IC_AWID    <= (others => '0');
    IC_AWADDR  <= (others => '0');
    IC_AWLEN   <= (others => '0');
    IC_AWSIZE  <= (others => '0');
    IC_AWBURST <= (others => '0');
    IC_AWLOCK  <= (others => '0');
    IC_AWCACHE <= (others => '0');
    IC_AWPROT  <= (others => '0');
    IC_AWVALID <= '0';
    IC_WID     <= (others => '0');
    IC_WDATA   <= (others => '0');
    IC_WSTRB   <= (others => '0');
    IC_WLAST   <= '0';
    IC_WVALID  <= '0';
    IC_BREADY  <= '0';
    IC_ARID    <= (others => '0');
    IC_ARADDR  <= (others => '0');
    IC_ARLEN   <= (others => '0');
    IC_ARSIZE  <= (others => '0');
    IC_ARBURST <= (others => '0');
    IC_ARLOCK  <= (others => '0');
    IC_ARCACHE <= (others => '0');
    IC_ARPROT  <= (others => '0');
    IC_ARVALID <= '0';
    IC_RREADY  <= '0';
  end generate no_instruction_cache_gen;

  -----------------------------------------------------------------------------
  -- Data cache and mux
  -----------------------------------------------------------------------------
  lsu_oimm_address_aligned <= lsu_oimm_address(lsu_oimm_address'left downto 2) & "00";
  data_cache_mux : cache_mux
    generic map (
      ADDRESS_WIDTH => REGISTER_SIZE,
      DATA_WIDTH    => REGISTER_SIZE,

      MAX_OUTSTANDING_READS => 1,

      AUX_MEMORY_REGIONS => AUX_MEMORY_REGIONS,
      AMR0_ADDR_BASE     => AMR0_ADDR_BASE,
      AMR0_ADDR_LAST     => AMR0_ADDR_LAST,

      UC_MEMORY_REGIONS => UC_MEMORY_REGIONS,
      UMR0_ADDR_BASE    => UMR0_ADDR_BASE,
      UMR0_ADDR_LAST    => UMR0_ADDR_LAST,

      CACHE_SIZE      => DCACHE_SIZE,
      CACHE_LINE_SIZE => DCACHE_LINE_SIZE,

      INTERNAL_REQUEST_REGISTER => DATA_REQUEST_REGISTER,
      INTERNAL_RETURN_REGISTER  => DATA_RETURN_REGISTER,
      UC_REQUEST_REGISTER       => DUC_REQUEST_REGISTER,
      UC_RETURN_REGISTER        => DUC_RETURN_REGISTER,
      AUX_REQUEST_REGISTER      => DAUX_REQUEST_REGISTER,
      AUX_RETURN_REGISTER       => DAUX_RETURN_REGISTER
      )
    port map (
      clk   => clk,
      reset => reset,

      amr_base_addrs => amr_base_addrs,
      amr_last_addrs => amr_last_addrs,
      umr_base_addrs => umr_base_addrs,
      umr_last_addrs => umr_last_addrs,

      internal_register_idle  => dinternal_register_idle,
      external_registers_idle => dexternal_registers_idle,

      oimm_address       => lsu_oimm_address_aligned,
      oimm_byteenable    => lsu_oimm_byteenable,
      oimm_requestvalid  => lsu_oimm_requestvalid,
      oimm_readnotwrite  => lsu_oimm_readnotwrite,
      oimm_writedata     => lsu_oimm_writedata,
      oimm_readdata      => lsu_oimm_readdata,
      oimm_readdatavalid => lsu_oimm_readdatavalid,
      oimm_waitrequest   => lsu_oimm_waitrequest,

      cacheint_oimm_address       => dcacheint_oimm_address,
      cacheint_oimm_byteenable    => dcacheint_oimm_byteenable,
      cacheint_oimm_requestvalid  => dcacheint_oimm_requestvalid,
      cacheint_oimm_readnotwrite  => dcacheint_oimm_readnotwrite,
      cacheint_oimm_writedata     => dcacheint_oimm_writedata,
      cacheint_oimm_readdata      => dcacheint_oimm_readdata,
      cacheint_oimm_readdatavalid => dcacheint_oimm_readdatavalid,
      cacheint_oimm_waitrequest   => dcacheint_oimm_waitrequest,

      uc_oimm_address       => duc_oimm_address,
      uc_oimm_byteenable    => duc_oimm_byteenable,
      uc_oimm_requestvalid  => duc_oimm_requestvalid,
      uc_oimm_readnotwrite  => duc_oimm_readnotwrite,
      uc_oimm_writedata     => duc_oimm_writedata,
      uc_oimm_readdata      => duc_oimm_readdata,
      uc_oimm_readdatavalid => duc_oimm_readdatavalid,
      uc_oimm_waitrequest   => duc_oimm_waitrequest,

      aux_oimm_address       => daux_oimm_address,
      aux_oimm_byteenable    => daux_oimm_byteenable,
      aux_oimm_requestvalid  => daux_oimm_requestvalid,
      aux_oimm_readnotwrite  => daux_oimm_readnotwrite,
      aux_oimm_writedata     => daux_oimm_writedata,
      aux_oimm_readdata      => daux_oimm_readdata,
      aux_oimm_readdatavalid => daux_oimm_readdatavalid,
      aux_oimm_waitrequest   => daux_oimm_waitrequest
      );

  data_cache_gen : if DCACHE_SIZE /= 0 generate
    signal dc_oimm_address            : std_logic_vector(REGISTER_SIZE-1 downto 0);
    signal dc_oimm_burstlength        : std_logic_vector(LOG2_BURSTLENGTH downto 0);
    signal dc_oimm_burstlength_minus1 : std_logic_vector(LOG2_BURSTLENGTH-1 downto 0);
    signal dc_oimm_byteenable         : std_logic_vector((REGISTER_SIZE/8)-1 downto 0);
    signal dc_oimm_requestvalid       : std_logic;
    signal dc_oimm_readnotwrite       : std_logic;
    signal dc_oimm_writedata          : std_logic_vector(REGISTER_SIZE-1 downto 0);
    signal dc_oimm_writelast          : std_logic;
    signal dc_oimm_readdata           : std_logic_vector(REGISTER_SIZE-1 downto 0);
    signal dc_oimm_readdatavalid      : std_logic;
    signal dc_oimm_waitrequest        : std_logic;

    function boolean_to_cache_policy (
      constant WRITEBACK : boolean
      )
      return cache_policy is
      variable policy : cache_policy;
    begin
      if WRITEBACK then
        policy := WRITE_BACK;
      else
        policy := WRITE_THROUGH;
      end if;
      return policy;
    end function boolean_to_cache_policy;
  begin
    data_cache : cache_controller
      generic map (
        CACHE_SIZE            => DCACHE_SIZE,
        LINE_SIZE             => DCACHE_LINE_SIZE,
        ADDRESS_WIDTH         => REGISTER_SIZE,
        INTERNAL_WIDTH        => REGISTER_SIZE,
        EXTERNAL_WIDTH        => DCACHE_EXTERNAL_WIDTH,
        LOG2_BURSTLENGTH      => LOG2_BURSTLENGTH,
        POLICY                => boolean_to_cache_policy(DCACHE_WRITEBACK),
        REGION_OPTIMIZATIONS  => true,
        WRITE_FIRST_SUPPORTED => WRITE_FIRST_SUPPORTED
        )
      port map (
        clk   => clk,
        reset => reset,

        from_cache_control_ready => from_dcache_control_ready,
        to_cache_control_valid   => to_dcache_control_valid,
        to_cache_control_command => to_dcache_control_command,
        to_cache_control_base    => to_cache_control_base,
        to_cache_control_last    => to_cache_control_last,

        precache_idle => dinternal_register_idle,
        cache_idle    => dcache_idle,

        cacheint_oimm_address       => dcacheint_oimm_address,
        cacheint_oimm_byteenable    => dcacheint_oimm_byteenable,
        cacheint_oimm_requestvalid  => dcacheint_oimm_requestvalid,
        cacheint_oimm_readnotwrite  => dcacheint_oimm_readnotwrite,
        cacheint_oimm_writedata     => dcacheint_oimm_writedata,
        cacheint_oimm_readdata      => dcacheint_oimm_readdata,
        cacheint_oimm_readdatavalid => dcacheint_oimm_readdatavalid,
        cacheint_oimm_waitrequest   => dcacheint_oimm_waitrequest,

        c_oimm_address            => dc_oimm_address,
        c_oimm_burstlength        => dc_oimm_burstlength,
        c_oimm_burstlength_minus1 => dc_oimm_burstlength_minus1,
        c_oimm_byteenable         => dc_oimm_byteenable,
        c_oimm_requestvalid       => dc_oimm_requestvalid,
        c_oimm_readnotwrite       => dc_oimm_readnotwrite,
        c_oimm_writedata          => dc_oimm_writedata,
        c_oimm_writelast          => dc_oimm_writelast,
        c_oimm_readdata           => dc_oimm_readdata,
        c_oimm_readdatavalid      => dc_oimm_readdatavalid,
        c_oimm_waitrequest        => dc_oimm_waitrequest
        );

    dc_master : axi_master
      generic map (
        ADDRESS_WIDTH            => REGISTER_SIZE,
        DATA_WIDTH               => REGISTER_SIZE,
        ID_WIDTH                 => AXI_ID_WIDTH,
        LOG2_BURSTLENGTH         => LOG2_BURSTLENGTH,
        MAX_OUTSTANDING_REQUESTS => MAX_OUTSTANDING_REQUESTS,
        REQUEST_REGISTER         => DC_REQUEST_REGISTER,
        RETURN_REGISTER          => DC_RETURN_REGISTER
        )
      port map (
        clk     => clk,
        reset   => reset,
        aresetn => aresetn,

        master_idle => dc_master_idle,

        oimm_address            => dc_oimm_address,
        oimm_burstlength_minus1 => dc_oimm_burstlength_minus1,
        oimm_byteenable         => dc_oimm_byteenable,
        oimm_requestvalid       => dc_oimm_requestvalid,
        oimm_readnotwrite       => dc_oimm_readnotwrite,
        oimm_writedata          => dc_oimm_writedata,
        oimm_writelast          => dc_oimm_writelast,
        oimm_readdata           => dc_oimm_readdata,
        oimm_readdatavalid      => dc_oimm_readdatavalid,
        oimm_waitrequest        => dc_oimm_waitrequest,

        AWID    => DC_AWID,
        AWADDR  => DC_AWADDR,
        AWLEN   => DC_AWLEN,
        AWSIZE  => DC_AWSIZE,
        AWBURST => DC_AWBURST,
        AWLOCK  => DC_AWLOCK,
        AWCACHE => DC_AWCACHE,
        AWPROT  => DC_AWPROT,
        AWVALID => DC_AWVALID,
        AWREADY => DC_AWREADY,

        WID    => DC_WID,
        WSTRB  => DC_WSTRB,
        WVALID => DC_WVALID,
        WLAST  => DC_WLAST,
        WDATA  => DC_WDATA,
        WREADY => DC_WREADY,

        BID    => DC_BID,
        BRESP  => DC_BRESP,
        BVALID => DC_BVALID,
        BREADY => DC_BREADY,

        ARID    => DC_ARID,
        ARADDR  => DC_ARADDR,
        ARLEN   => DC_ARLEN,
        ARSIZE  => DC_ARSIZE,
        ARBURST => DC_ARBURST,
        ARLOCK  => DC_ARLOCK,
        ARCACHE => DC_ARCACHE,
        ARPROT  => DC_ARPROT,
        ARVALID => DC_ARVALID,
        ARREADY => DC_ARREADY,

        RID    => DC_RID,
        RDATA  => DC_RDATA,
        RRESP  => DC_RRESP,
        RLAST  => DC_RLAST,
        RVALID => DC_RVALID,
        RREADY => DC_RREADY
        );
  end generate data_cache_gen;
  no_data_cache_gen : if DCACHE_SIZE = 0 generate
    from_dcache_control_ready <= '1';
    dcache_idle               <= '1';
    dc_master_idle            <= '1';

    DC_AWID    <= (others => '0');
    DC_AWADDR  <= (others => '0');
    DC_AWLEN   <= (others => '0');
    DC_AWSIZE  <= (others => '0');
    DC_AWBURST <= (others => '0');
    DC_AWLOCK  <= (others => '0');
    DC_AWCACHE <= (others => '0');
    DC_AWPROT  <= (others => '0');
    DC_AWVALID <= '0';
    DC_WID     <= (others => '0');
    DC_WDATA   <= (others => '0');
    DC_WSTRB   <= (others => '0');
    DC_WLAST   <= '0';
    DC_WVALID  <= '0';
    DC_BREADY  <= '0';
    DC_ARID    <= (others => '0');
    DC_ARADDR  <= (others => '0');
    DC_ARLEN   <= (others => '0');
    DC_ARSIZE  <= (others => '0');
    DC_ARBURST <= (others => '0');
    DC_ARLOCK  <= (others => '0');
    DC_ARCACHE <= (others => '0');
    DC_ARPROT  <= (others => '0');
    DC_ARVALID <= '0';
    DC_RREADY  <= '0';
  end generate no_data_cache_gen;

  -----------------------------------------------------------------------------
  -- LMB auxiliary interface
  -----------------------------------------------------------------------------
  ilmb_aux_enabled : if LMB_AUX generate
    signal iread_in_flight  : std_logic;
    signal iwrite_in_flight : std_logic;
    signal dread_in_flight  : std_logic;
    signal dwrite_in_flight : std_logic;
  begin
    ILMB_Addr         <= iaux_oimm_address;
    ILMB_Byte_Enable  <= iaux_oimm_byteenable;
    ILMB_Data_Write   <= iaux_oimm_writedata;
    ILMB_AS           <= iaux_oimm_requestvalid and (not iaux_oimm_waitrequest);
    ILMB_Read_Strobe  <= iaux_oimm_readnotwrite and iaux_oimm_requestvalid and (not iaux_oimm_waitrequest);
    ILMB_Write_Strobe <= (not iaux_oimm_readnotwrite) and iaux_oimm_requestvalid and (not iaux_oimm_waitrequest);
    DLMB_Addr         <= daux_oimm_address;
    DLMB_Byte_Enable  <= daux_oimm_byteenable;
    DLMB_Data_Write   <= daux_oimm_writedata;
    DLMB_AS           <= daux_oimm_requestvalid and (not daux_oimm_waitrequest);
    DLMB_Read_Strobe  <= daux_oimm_readnotwrite and daux_oimm_requestvalid and (not daux_oimm_waitrequest);
    DLMB_Write_Strobe <= (not daux_oimm_readnotwrite) and daux_oimm_requestvalid and (not daux_oimm_waitrequest);

    --The LMB spec (which is inside the MicroBlaze Processor Reference Guide)
    --is vague about how Wait and Ready differ and can be used.  A conservative
    --reading is that a new request can be sent as soon as Ready is asserted
    --and there's no reason to pay attention to Wait.
    --It's not explicitly stated but looking at Xilinx's HDL it's clear that
    --Ready can't be asserted on the same cycle as the strobe signals.
    process (clk) is
    begin
      if rising_edge(clk) then
        if ILMB_Ready = '1' then
          iread_in_flight  <= '0';
          iwrite_in_flight <= '0';
        end if;

        if iaux_oimm_requestvalid = '1' and iaux_oimm_waitrequest = '0' then
          if iaux_oimm_readnotwrite = '1' then
            iread_in_flight <= '1';
          else
            iwrite_in_flight <= '1';
          end if;
        end if;

        if reset = '1' then
          iread_in_flight  <= '0';
          iwrite_in_flight <= '0';
        end if;
      end if;
    end process;
    process (clk) is
    begin
      if rising_edge(clk) then
        if DLMB_Ready = '1' then
          dread_in_flight  <= '0';
          dwrite_in_flight <= '0';
        end if;

        if daux_oimm_requestvalid = '1' and daux_oimm_waitrequest = '0' then
          if daux_oimm_readnotwrite = '1' then
            dread_in_flight <= '1';
          else
            dwrite_in_flight <= '1';
          end if;
        end if;

        if reset = '1' then
          dread_in_flight  <= '0';
          dwrite_in_flight <= '0';
        end if;
      end if;
    end process;

    iaux_oimm_readdata      <= ILMB_Data_Read;
    iaux_oimm_readdatavalid <= ILMB_Ready and iread_in_flight;
    iaux_oimm_waitrequest   <= (iread_in_flight or iwrite_in_flight) and (not ILMB_Ready);
    daux_oimm_readdata      <= DLMB_Data_Read;
    daux_oimm_readdatavalid <= DLMB_Ready and dread_in_flight;
    daux_oimm_waitrequest   <= (dread_in_flight or dwrite_in_flight) and (not DLMB_Ready);
  end generate ilmb_aux_enabled;
  ilmb_aux_disabled : if not LMB_AUX generate
    ILMB_Addr         <= (others => '0');
    ILMB_Byte_Enable  <= (others => '0');
    ILMB_Data_Write   <= (others => '0');
    ILMB_AS           <= '0';
    ILMB_Read_Strobe  <= '0';
    ILMB_Write_Strobe <= '0';
    DLMB_Addr         <= (others => '0');
    DLMB_Byte_Enable  <= (others => '0');
    DLMB_Data_Write   <= (others => '0');
    DLMB_AS           <= '0';
    DLMB_Read_Strobe  <= '0';
    DLMB_Write_Strobe <= '0';
  end generate ilmb_aux_disabled;

  -----------------------------------------------------------------------------
  -- AVALON auxiliary interface
  -----------------------------------------------------------------------------
  avalon_enabled : if AVALON_AUX generate
    avm_instruction_address <= iaux_oimm_address;
    avm_instruction_read    <= iaux_oimm_readnotwrite and iaux_oimm_requestvalid;
    iaux_oimm_readdata      <= avm_instruction_readdata;
    iaux_oimm_waitrequest   <= avm_instruction_waitrequest;
    iaux_oimm_readdatavalid <= avm_instruction_readdatavalid;

    avm_data_address        <= daux_oimm_address;
    avm_data_byteenable     <= daux_oimm_byteenable;
    avm_data_read           <= daux_oimm_readnotwrite and daux_oimm_requestvalid;
    daux_oimm_readdata      <= avm_data_readdata;
    avm_data_write          <= (not daux_oimm_readnotwrite) and daux_oimm_requestvalid;
    avm_data_writedata      <= daux_oimm_writedata;
    daux_oimm_waitrequest   <= avm_data_waitrequest;
    daux_oimm_readdatavalid <= avm_data_readdatavalid;
  end generate avalon_enabled;
  avalon_disabled : if not AVALON_AUX generate
    avm_data_address        <= (others => '0');
    avm_data_byteenable     <= (others => '0');
    avm_data_read           <= '0';
    avm_data_write          <= '0';
    avm_data_writedata      <= (others => '0');
    avm_instruction_address <= (others => '0');
    avm_instruction_read    <= '0';
  end generate avalon_disabled;

  -----------------------------------------------------------------------------
  -- WISHBONE auxiliary interface
  -----------------------------------------------------------------------------
  wishbone_enabled : if WISHBONE_AUX generate
    signal reading               : std_logic;
    signal writing               : std_logic;
    signal awaiting_ack          : std_logic;
    signal delayed_readdatavalid : std_logic;
    signal delayed_readdata      : std_logic_vector(REGISTER_SIZE-1 downto 0);
  begin
    awaiting_ack <= reading or writing;

    no_single_cycle_gen : if not WISHBONE_SINGLE_CYCLE_READS generate
      daux_oimm_readdata      <= data_DAT_I;
      daux_oimm_readdatavalid <= data_ACK_I and reading;
    end generate no_single_cycle_gen;
    single_cycle_gen : if WISHBONE_SINGLE_CYCLE_READS generate
      daux_oimm_readdata      <= data_DAT_I when delayed_readdatavalid = '0' else delayed_readdata;
      daux_oimm_readdatavalid <= (data_ACK_I and reading) or delayed_readdatavalid;
    end generate single_cycle_gen;
    daux_oimm_waitrequest <= data_STALL_I or (awaiting_ack and (not data_ACK_I));
    data_ADR_O            <= daux_oimm_address;
    data_STB_O            <= daux_oimm_requestvalid and ((not awaiting_ack) or data_ACK_I);
    data_CYC_O            <= daux_oimm_requestvalid and ((not awaiting_ack) or data_ACK_I);
    data_CTI_O            <= (others => '0');
    data_SEL_O            <= daux_oimm_byteenable;
    data_WE_O             <= not daux_oimm_readnotwrite;
    data_DAT_O            <= daux_oimm_writedata;
    process(clk)
    begin
      if rising_edge(clk) then
        delayed_readdata      <= data_DAT_I;
        delayed_readdatavalid <= '0';
        if data_ACK_I = '1' then
          reading <= '0';
          writing <= '0';
        end if;
        if daux_oimm_waitrequest = '0' then
          --Allow one ACK in flight.  Must delay single cycle reads to conform
          --to OIMM spec (readdatavalid can't come back on the same cycle as
          --read is asserted).
          if awaiting_ack = '0' and data_ACK_I = '1' then
            delayed_readdatavalid <= daux_oimm_readnotwrite and daux_oimm_requestvalid;
            reading               <= '0';
            writing               <= '0';
          else
            reading <= daux_oimm_readnotwrite and daux_oimm_requestvalid;
            writing <= (not daux_oimm_readnotwrite) and daux_oimm_requestvalid;
          end if;
        end if;

        if reset = '1' then
          delayed_readdatavalid <= '0';
          reading               <= '0';
          writing               <= '0';
        end if;
      end if;
    end process;

    instr_ADR_O             <= iaux_oimm_address;
    instr_CYC_O             <= iaux_oimm_readnotwrite and iaux_oimm_requestvalid;
    instr_CTI_O             <= (others => '0');
    instr_STB_O             <= iaux_oimm_readnotwrite and iaux_oimm_requestvalid;
    iaux_oimm_readdata      <= instr_DAT_I;
    iaux_oimm_waitrequest   <= instr_STALL_I;
    iaux_oimm_readdatavalid <= instr_ACK_I;
  end generate wishbone_enabled;
  wishbone_disabled : if not WISHBONE_AUX generate
    data_ADR_O  <= (others => '0');
    data_STB_O  <= '0';
    data_CYC_O  <= '0';
    data_CTI_O  <= (others => '0');
    data_SEL_O  <= (others => '0');
    data_WE_O   <= '0';
    data_DAT_O  <= (others => '0');
    instr_ADR_O <= (others => '0');
    instr_CYC_O <= '0';
    instr_CTI_O <= (others => '0');
    instr_STB_O <= '0';
  end generate wishbone_disabled;

  -----------------------------------------------------------------------------
  -- AXI4-Lite uncached interface
  -----------------------------------------------------------------------------
  uc_masters_gen : if UC_MEMORY_REGIONS /= 0 generate
    iuc_master : a4l_master
      generic map (
        ADDRESS_WIDTH            => REGISTER_SIZE,
        DATA_WIDTH               => REGISTER_SIZE,
        MAX_OUTSTANDING_REQUESTS => 0
        )
      port map (
        clk     => clk,
        reset   => reset,
        aresetn => aresetn,

        master_idle => iuc_master_idle,

        oimm_address       => iuc_oimm_address,
        oimm_byteenable    => iuc_oimm_byteenable,
        oimm_requestvalid  => iuc_oimm_requestvalid,
        oimm_readnotwrite  => iuc_oimm_readnotwrite,
        oimm_writedata     => iuc_oimm_writedata,
        oimm_readdata      => iuc_oimm_readdata,
        oimm_readdatavalid => iuc_oimm_readdatavalid,
        oimm_waitrequest   => iuc_oimm_waitrequest,

        AWADDR  => IUC_AWADDR,
        AWPROT  => IUC_AWPROT,
        AWVALID => IUC_AWVALID,
        AWREADY => IUC_AWREADY,

        WSTRB  => IUC_WSTRB,
        WVALID => IUC_WVALID,
        WDATA  => IUC_WDATA,
        WREADY => IUC_WREADY,

        BRESP  => IUC_BRESP,
        BVALID => IUC_BVALID,
        BREADY => IUC_BREADY,

        ARADDR  => IUC_ARADDR,
        ARPROT  => IUC_ARPROT,
        ARVALID => IUC_ARVALID,
        ARREADY => IUC_ARREADY,

        RDATA  => IUC_RDATA,
        RRESP  => IUC_RRESP,
        RVALID => IUC_RVALID,
        RREADY => IUC_RREADY
        );

    duc_master : a4l_master
      generic map (
        ADDRESS_WIDTH            => REGISTER_SIZE,
        DATA_WIDTH               => REGISTER_SIZE,
        MAX_OUTSTANDING_REQUESTS => MAX_OUTSTANDING_REQUESTS
        )
      port map (
        clk     => clk,
        reset   => reset,
        aresetn => aresetn,

        master_idle => duc_master_idle,

        oimm_address       => duc_oimm_address,
        oimm_byteenable    => duc_oimm_byteenable,
        oimm_requestvalid  => duc_oimm_requestvalid,
        oimm_readnotwrite  => duc_oimm_readnotwrite,
        oimm_writedata     => duc_oimm_writedata,
        oimm_readdata      => duc_oimm_readdata,
        oimm_readdatavalid => duc_oimm_readdatavalid,
        oimm_waitrequest   => duc_oimm_waitrequest,

        AWADDR  => DUC_AWADDR,
        AWPROT  => DUC_AWPROT,
        AWVALID => DUC_AWVALID,
        AWREADY => DUC_AWREADY,

        WSTRB  => DUC_WSTRB,
        WVALID => DUC_WVALID,
        WDATA  => DUC_WDATA,
        WREADY => DUC_WREADY,

        BRESP  => DUC_BRESP,
        BVALID => DUC_BVALID,
        BREADY => DUC_BREADY,

        ARADDR  => DUC_ARADDR,
        ARPROT  => DUC_ARPROT,
        ARVALID => DUC_ARVALID,
        ARREADY => DUC_ARREADY,

        RDATA  => DUC_RDATA,
        RRESP  => DUC_RRESP,
        RVALID => DUC_RVALID,
        RREADY => DUC_RREADY
        );
  end generate uc_masters_gen;
  no_uc_masters_gen : if UC_MEMORY_REGIONS = 0 generate
    iuc_master_idle <= '1';
    duc_master_idle <= '1';

    IUC_AWADDR  <= (others => '0');
    IUC_AWPROT  <= (others => '0');
    IUC_AWVALID <= '0';
    IUC_WDATA   <= (others => '0');
    IUC_WSTRB   <= (others => '0');
    IUC_WVALID  <= '0';
    IUC_BREADY  <= '0';
    IUC_ARADDR  <= (others => '0');
    IUC_ARPROT  <= (others => '0');
    IUC_ARVALID <= '0';
    IUC_RREADY  <= '0';

    DUC_AWADDR  <= (others => '0');
    DUC_AWPROT  <= (others => '0');
    DUC_AWVALID <= '0';
    DUC_WDATA   <= (others => '0');
    DUC_WSTRB   <= (others => '0');
    DUC_WVALID  <= '0';
    DUC_BREADY  <= '0';
    DUC_ARADDR  <= (others => '0');
    DUC_ARPROT  <= (others => '0');
    DUC_ARVALID <= '0';
    DUC_RREADY  <= '0';
  end generate no_uc_masters_gen;
  --Uncached bus signals are AXI4L, translate to AXI3 if needed
  IUC_AWID    <= (others => '0');
  IUC_AWLEN   <= (others => '0');
  IUC_AWSIZE  <= A4L_BURST_SIZE;
  IUC_AWBURST <= A4L_BURST_INCR;
  IUC_AWLOCK  <= A4L_LOCK_VAL;
  IUC_AWCACHE <= A4L_CACHE_VAL;
  IUC_WID     <= (others => '0');
  IUC_WLAST   <= '1';
  IUC_ARID    <= (others => '0');
  IUC_ARLEN   <= (others => '0');
  IUC_ARSIZE  <= A4L_BURST_SIZE;
  IUC_ARBURST <= A4L_BURST_INCR;
  IUC_ARLOCK  <= A4L_LOCK_VAL;
  IUC_ARCACHE <= A4L_CACHE_VAL;
  DUC_AWID    <= (others => '0');
  DUC_AWLEN   <= (others => '0');
  DUC_AWSIZE  <= A4L_BURST_SIZE;
  DUC_AWBURST <= A4L_BURST_INCR;
  DUC_AWLOCK  <= A4L_LOCK_VAL;
  DUC_AWCACHE <= A4L_CACHE_VAL;
  DUC_WID     <= (others => '0');
  DUC_WLAST   <= '1';
  DUC_ARID    <= (others => '0');
  DUC_ARLEN   <= (others => '0');
  DUC_ARSIZE  <= A4L_BURST_SIZE;
  DUC_ARBURST <= A4L_BURST_INCR;
  DUC_ARLOCK  <= A4L_LOCK_VAL;
  DUC_ARCACHE <= A4L_CACHE_VAL;

end architecture rtl;
