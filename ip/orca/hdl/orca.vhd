library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.rv_components.all;
use work.utils.all;
use work.constants_pkg.all;

entity orca is
  generic (
    REGISTER_SIZE : positive range 32 to 32 := 32;

    RESET_VECTOR           : std_logic_vector(31 downto 0) := X"00000000";
    INTERRUPT_VECTOR       : std_logic_vector(31 downto 0) := X"00000200";
    MAX_IFETCHES_IN_FLIGHT : positive                      := 1;
    BTB_ENTRIES            : natural                       := 0;
    MULTIPLY_ENABLE        : natural range 0 to 1          := 0;
    DIVIDE_ENABLE          : natural range 0 to 1          := 0;
    SHIFTER_MAX_CYCLES     : positive range 1 to 32        := 1;
    ENABLE_EXCEPTIONS      : natural                       := 1;
    PIPELINE_STAGES        : natural range 4 to 5          := 5;
    VCP_ENABLE             : natural range 0 to 2          := 0;
    ENABLE_EXT_INTERRUPTS  : natural range 0 to 1          := 0;
    NUM_EXT_INTERRUPTS     : positive range 1 to 32        := 1;
    POWER_OPTIMIZED        : natural range 0 to 1          := 0;
    FAMILY                 : string                        := "GENERIC";

    -------------------------------------------------------------------------------
    -- Memory interfaces
    -------------------------------------------------------------------------------
    LOG2_BURSTLENGTH : positive range 1 to 8 := 4;
    AXI_ID_WIDTH     : positive              := 2;

    --Auxiliary interface select (at most one enabled)
    AVALON_AUX   : natural range 0 to 1 := 0;
    LMB_AUX      : natural range 0 to 1 := 0;
    WISHBONE_AUX : natural range 0 to 1 := 1;

    --Auxiliary memory regions (0 to disable)
    AUX_MEMORY_REGIONS : natural range 0 to 4          := 1;
    AMR0_ADDR_BASE     : std_logic_vector(31 downto 0) := X"00000000";
    AMR0_ADDR_LAST     : std_logic_vector(31 downto 0) := X"FFFFFFFF";
    AMR0_READ_ONLY     : natural range 0 to 1          := 1;

    --Uncached memory regions (0 to disable)
    UC_MEMORY_REGIONS : natural range 0 to 4          := 0;
    UMR0_ADDR_BASE    : std_logic_vector(31 downto 0) := X"00000000";
    UMR0_ADDR_LAST    : std_logic_vector(31 downto 0) := X"FFFFFFFF";
    UMR0_READ_ONLY    : natural range 0 to 1          := 1;

    --Instruction cache (ICACHE_SIZE 0 to disable)
    ICACHE_SIZE           : natural                  := 0;
    ICACHE_LINE_SIZE      : positive range 16 to 256 := 32;
    ICACHE_EXTERNAL_WIDTH : positive                 := 32;

    --Instruction interface registers for timing/fmax
    --Request registers are 0/off, 1/light (waitrequest/ready only), 2/full
    INSTRUCTION_REQUEST_REGISTER : natural range 0 to 2 := 0;
    INSTRUCTION_RETURN_REGISTER  : natural range 0 to 1 := 0;
    IUC_REQUEST_REGISTER         : natural range 0 to 2 := 0;
    IUC_RETURN_REGISTER          : natural range 0 to 1 := 0;
    IAUX_REQUEST_REGISTER        : natural range 0 to 2 := 0;
    IAUX_RETURN_REGISTER         : natural range 0 to 1 := 0;
    IC_REQUEST_REGISTER          : natural range 0 to 2 := 1;
    IC_RETURN_REGISTER           : natural range 0 to 1 := 0;

    --Data cache (DCACHE_SIZE 0 to disable)
    DCACHE_SIZE           : natural                  := 0;
    DCACHE_LINE_SIZE      : positive range 16 to 256 := 32;
    DCACHE_EXTERNAL_WIDTH : positive                 := 32;
    DCACHE_WRITEBACK      : natural range 0 to 1     := 1;

    --Data interface registers for timing/fmax
    --Request registers are 0/off, 1/light (waitrequest/ready only), 2/full
    DATA_REQUEST_REGISTER : natural range 0 to 2 := 1;
    DATA_RETURN_REGISTER  : natural range 0 to 1 := 0;
    DUC_REQUEST_REGISTER  : natural range 0 to 2 := 0;
    DUC_RETURN_REGISTER   : natural range 0 to 1 := 0;
    DAUX_REQUEST_REGISTER : natural range 0 to 2 := 0;
    DAUX_RETURN_REGISTER  : natural range 0 to 1 := 0;
    DC_REQUEST_REGISTER   : natural range 0 to 2 := 1;
    DC_RETURN_REGISTER    : natural range 0 to 1 := 0
    );
  port (
    clk   : in std_logic;
    reset : in std_logic;

    -------------------------------------------------------------------------------
    -- Interrupts
    -------------------------------------------------------------------------------
    global_interrupts : in std_logic_vector(NUM_EXT_INTERRUPTS-1 downto 0) := (others => '0');

    -------------------------------------------------------------------------------
    --AVALON
    -------------------------------------------------------------------------------
    --Avalon data master
    avm_data_address       : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    avm_data_byteenable    : out std_logic_vector((REGISTER_SIZE/8)-1 downto 0);
    avm_data_read          : out std_logic;
    avm_data_readdata      : in  std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
    avm_data_write         : out std_logic;
    avm_data_writedata     : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    avm_data_waitrequest   : in  std_logic                                  := '0';
    avm_data_readdatavalid : in  std_logic                                  := '0';

    --Avalon instruction master
    avm_instruction_address       : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    avm_instruction_read          : out std_logic;
    avm_instruction_readdata      : in  std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
    avm_instruction_waitrequest   : in  std_logic                                  := '0';
    avm_instruction_readdatavalid : in  std_logic                                  := '0';

    -------------------------------------------------------------------------------
    --WISHBONE
    -------------------------------------------------------------------------------
    --WISHBONE data master
    data_ADR_O   : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    data_DAT_I   : in  std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
    data_DAT_O   : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    data_WE_O    : out std_logic;
    data_SEL_O   : out std_logic_vector((REGISTER_SIZE/8)-1 downto 0);
    data_STB_O   : out std_logic;
    data_ACK_I   : in  std_logic                                  := '0';
    data_CYC_O   : out std_logic;
    data_CTI_O   : out std_logic_vector(2 downto 0);
    data_STALL_I : in  std_logic                                  := '0';

    --WISHBONE instruction master
    instr_ADR_O   : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    instr_DAT_I   : in  std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
    instr_STB_O   : out std_logic;
    instr_ACK_I   : in  std_logic                                  := '0';
    instr_CYC_O   : out std_logic;
    instr_CTI_O   : out std_logic_vector(2 downto 0);
    instr_STALL_I : in  std_logic                                  := '0';

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
    IUC_ARREADY : in  std_logic := '0';

    IUC_RID    : in  std_logic_vector(AXI_ID_WIDTH-1 downto 0)  := (others => '0');
    IUC_RDATA  : in  std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
    IUC_RRESP  : in  std_logic_vector(1 downto 0)               := (others => '0');
    IUC_RLAST  : in  std_logic                                  := '0';
    IUC_RVALID : in  std_logic                                  := '0';
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
    IUC_AWREADY : in  std_logic := '0';

    IUC_WID    : out std_logic_vector(AXI_ID_WIDTH-1 downto 0);
    IUC_WDATA  : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    IUC_WSTRB  : out std_logic_vector((REGISTER_SIZE/8)-1 downto 0);
    IUC_WLAST  : out std_logic;
    IUC_WVALID : out std_logic;
    IUC_WREADY : in  std_logic := '0';

    IUC_BID    : in  std_logic_vector(AXI_ID_WIDTH-1 downto 0) := (others => '0');
    IUC_BRESP  : in  std_logic_vector(1 downto 0)              := (others => '0');
    IUC_BVALID : in  std_logic                                 := '0';
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
    DUC_AWREADY : in  std_logic := '0';

    DUC_WID    : out std_logic_vector(AXI_ID_WIDTH-1 downto 0);
    DUC_WDATA  : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    DUC_WSTRB  : out std_logic_vector((REGISTER_SIZE/8)-1 downto 0);
    DUC_WLAST  : out std_logic;
    DUC_WVALID : out std_logic;
    DUC_WREADY : in  std_logic := '0';

    DUC_BID    : in  std_logic_vector(AXI_ID_WIDTH-1 downto 0) := (others => '0');
    DUC_BRESP  : in  std_logic_vector(1 downto 0)              := (others => '0');
    DUC_BVALID : in  std_logic                                 := '0';
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
    DUC_ARREADY : in  std_logic := '0';

    DUC_RID    : in  std_logic_vector(AXI_ID_WIDTH-1 downto 0)  := (others => '0');
    DUC_RDATA  : in  std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
    DUC_RRESP  : in  std_logic_vector(1 downto 0)               := (others => '0');
    DUC_RLAST  : in  std_logic                                  := '0';
    DUC_RVALID : in  std_logic                                  := '0';
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
    IC_ARREADY : in  std_logic := '0';

    IC_RID    : in  std_logic_vector(AXI_ID_WIDTH-1 downto 0)          := (others => '0');
    IC_RDATA  : in  std_logic_vector(ICACHE_EXTERNAL_WIDTH-1 downto 0) := (others => '0');
    IC_RRESP  : in  std_logic_vector(1 downto 0)                       := (others => '0');
    IC_RLAST  : in  std_logic                                          := '0';
    IC_RVALID : in  std_logic                                          := '0';
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
    IC_AWREADY : in  std_logic := '0';

    IC_WID    : out std_logic_vector(AXI_ID_WIDTH-1 downto 0);
    IC_WDATA  : out std_logic_vector(ICACHE_EXTERNAL_WIDTH-1 downto 0);
    IC_WSTRB  : out std_logic_vector((ICACHE_EXTERNAL_WIDTH/8)-1 downto 0);
    IC_WLAST  : out std_logic;
    IC_WVALID : out std_logic;
    IC_WREADY : in  std_logic                                 := '0';
    IC_BID    : in  std_logic_vector(AXI_ID_WIDTH-1 downto 0) := (others => '0');
    IC_BRESP  : in  std_logic_vector(1 downto 0)              := (others => '0');
    IC_BVALID : in  std_logic                                 := '0';
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
    DC_ARREADY : in  std_logic := '0';

    DC_RID    : in  std_logic_vector(AXI_ID_WIDTH-1 downto 0)          := (others => '0');
    DC_RDATA  : in  std_logic_vector(DCACHE_EXTERNAL_WIDTH-1 downto 0) := (others => '0');
    DC_RRESP  : in  std_logic_vector(1 downto 0)                       := (others => '0');
    DC_RLAST  : in  std_logic                                          := '0';
    DC_RVALID : in  std_logic                                          := '0';
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
    DC_AWREADY : in  std_logic := '0';

    DC_WID    : out std_logic_vector(AXI_ID_WIDTH-1 downto 0);
    DC_WDATA  : out std_logic_vector(DCACHE_EXTERNAL_WIDTH-1 downto 0);
    DC_WSTRB  : out std_logic_vector((DCACHE_EXTERNAL_WIDTH/8)-1 downto 0);
    DC_WLAST  : out std_logic;
    DC_WVALID : out std_logic;
    DC_WREADY : in  std_logic                                 := '0';
    DC_BID    : in  std_logic_vector(AXI_ID_WIDTH-1 downto 0) := (others => '0');
    DC_BRESP  : in  std_logic_vector(1 downto 0)              := (others => '0');
    DC_BVALID : in  std_logic                                 := '0';
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
    ILMB_Data_Read    : in  std_logic_vector(0 to REGISTER_SIZE-1) := (others => '0');
    ILMB_Ready        : in  std_logic                              := '0';
    ILMB_Wait         : in  std_logic                              := '0';
    ILMB_CE           : in  std_logic                              := '0';
    ILMB_UE           : in  std_logic                              := '0';

    --Xilinx local memory bus data master
    DLMB_Addr         : out std_logic_vector(0 to REGISTER_SIZE-1);
    DLMB_Byte_Enable  : out std_logic_vector(0 to (REGISTER_SIZE/8)-1);
    DLMB_Data_Write   : out std_logic_vector(0 to REGISTER_SIZE-1);
    DLMB_AS           : out std_logic;
    DLMB_Read_Strobe  : out std_logic;
    DLMB_Write_Strobe : out std_logic;
    DLMB_Data_Read    : in  std_logic_vector(0 to REGISTER_SIZE-1) := (others => '0');
    DLMB_Ready        : in  std_logic                              := '0';
    DLMB_Wait         : in  std_logic                              := '0';
    DLMB_CE           : in  std_logic                              := '0';
    DLMB_UE           : in  std_logic                              := '0';

    ---------------------------------------------------------------------------
    -- Timer signals
    ---------------------------------------------------------------------------
    timer_value     : in  std_logic_vector(63 downto 0) := (others => '0');
    timer_interrupt : in  std_logic                     := '0';
    ---------------------------------------------------------------------------
    -- Vector Coprocessor Port
    ---------------------------------------------------------------------------
    vcp_data0       : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    vcp_data1       : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    vcp_data2       : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    vcp_instruction : out std_logic_vector(40 downto 0);
    vcp_valid_instr : out std_logic;

    vcp_ready            : in std_logic                                  := '1';
    vcp_illegal          : in std_logic                                  := '0';
    vcp_writeback_data   : in std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
    vcp_writeback_en     : in std_logic                                  := '0';
    vcp_alu_data1        : in std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
    vcp_alu_data2        : in std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
    vcp_alu_source_valid : in std_logic                                  := '0';

    vcp_alu_result       : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    vcp_alu_result_valid : out std_logic
    );
end entity orca;

architecture rtl of orca is
  --Might want to bring these out to the top level.
  constant WRITE_FIRST_SMALL_RAMS   : boolean  := FAMILY = "XILINX" or FAMILY = "INTEL";
  constant MAX_OUTSTANDING_REQUESTS : positive := 4;

  function natural_to_request_register (
    constant NATURAL_REQUEST_REGISTER : natural range 0 to 2
    )
    return request_register_type is
    variable request_register : request_register_type := OFF;
  begin
    case NATURAL_REQUEST_REGISTER is
      when 2 =>
        request_register := FULL;
      when 1 =>
        request_register := LIGHT;
      when others =>
        request_register := OFF;
    end case;
    return request_register;
  end function natural_to_request_register;

  function natural_to_vcp (
    constant NATURAL_VCP : natural range 0 to 2
    )
    return vcp_type is
    variable vcp : vcp_type := DISABLED;
  begin
    case NATURAL_VCP is
      when 2 =>
        vcp := SIXTY_FOUR_BIT;
      when 1 =>
        vcp := THIRTY_TWO_BIT;
      when others =>
        vcp := DISABLED;
    end case;
    return vcp;
  end function natural_to_vcp;

  signal amr_base_addrs : std_logic_vector((imax(AUX_MEMORY_REGIONS, 1)*REGISTER_SIZE)-1 downto 0);
  signal amr_last_addrs : std_logic_vector((imax(AUX_MEMORY_REGIONS, 1)*REGISTER_SIZE)-1 downto 0);
  signal umr_base_addrs : std_logic_vector((imax(UC_MEMORY_REGIONS, 1)*REGISTER_SIZE)-1 downto 0);
  signal umr_last_addrs : std_logic_vector((imax(UC_MEMORY_REGIONS, 1)*REGISTER_SIZE)-1 downto 0);

  signal from_icache_control_ready : std_logic;
  signal to_icache_control_valid   : std_logic;
  signal to_icache_control_command : cache_control_command;
  signal from_dcache_control_ready : std_logic;
  signal to_dcache_control_valid   : std_logic;
  signal to_dcache_control_command : cache_control_command;
  signal to_cache_control_base     : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal to_cache_control_last     : std_logic_vector(REGISTER_SIZE-1 downto 0);

  signal memory_interface_idle : std_logic;

  signal lsu_oimm_address       : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal lsu_oimm_byteenable    : std_logic_vector((REGISTER_SIZE/8)-1 downto 0);
  signal lsu_oimm_requestvalid  : std_logic;
  signal lsu_oimm_readnotwrite  : std_logic;
  signal lsu_oimm_writedata     : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal lsu_oimm_readdata      : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal lsu_oimm_readdatavalid : std_logic;
  signal lsu_oimm_waitrequest   : std_logic;

  signal ifetch_oimm_address       : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal ifetch_oimm_requestvalid  : std_logic;
  signal ifetch_oimm_readdata      : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal ifetch_oimm_waitrequest   : std_logic;
  signal ifetch_oimm_readdatavalid : std_logic;
begin

  core : orca_core
    generic map (
      REGISTER_SIZE          => REGISTER_SIZE,
      RESET_VECTOR           => RESET_VECTOR,
      INTERRUPT_VECTOR       => INTERRUPT_VECTOR,
      MAX_IFETCHES_IN_FLIGHT => MAX_IFETCHES_IN_FLIGHT,
      BTB_ENTRIES            => BTB_ENTRIES,
      MULTIPLY_ENABLE        => MULTIPLY_ENABLE /= 0,
      DIVIDE_ENABLE          => DIVIDE_ENABLE /= 0,
      SHIFTER_MAX_CYCLES     => SHIFTER_MAX_CYCLES,
      POWER_OPTIMIZED        => POWER_OPTIMIZED /= 0,
      ENABLE_EXCEPTIONS      => ENABLE_EXCEPTIONS /= 0,
      PIPELINE_STAGES        => PIPELINE_STAGES,
      VCP_ENABLE             => natural_to_vcp(VCP_ENABLE),
      ENABLE_EXT_INTERRUPTS  => ENABLE_EXT_INTERRUPTS /= 0,
      NUM_EXT_INTERRUPTS     => NUM_EXT_INTERRUPTS,
      WRITE_FIRST_SMALL_RAMS => WRITE_FIRST_SMALL_RAMS,
      FAMILY                 => FAMILY,

      AUX_MEMORY_REGIONS => AUX_MEMORY_REGIONS,
      AMR0_ADDR_BASE     => AMR0_ADDR_BASE,
      AMR0_ADDR_LAST     => AMR0_ADDR_LAST,
      AMR0_READ_ONLY     => AMR0_READ_ONLY /= 0,

      UC_MEMORY_REGIONS => UC_MEMORY_REGIONS,
      UMR0_ADDR_BASE    => UMR0_ADDR_BASE,
      UMR0_ADDR_LAST    => UMR0_ADDR_LAST,
      UMR0_READ_ONLY    => UMR0_READ_ONLY /= 0,

      HAS_ICACHE => ICACHE_SIZE /= 0,
      HAS_DCACHE => DCACHE_SIZE /= 0
      )
    port map (
      clk   => clk,
      reset => reset,

      global_interrupts => global_interrupts,

      memory_interface_idle => memory_interface_idle,

      --ICache control (Invalidate/flush/writeback)
      from_icache_control_ready => from_icache_control_ready,
      to_icache_control_valid   => to_icache_control_valid,
      to_icache_control_command => to_icache_control_command,

      --DCache control (Invalidate/flush/writeback)
      from_dcache_control_ready => from_dcache_control_ready,
      to_dcache_control_valid   => to_dcache_control_valid,
      to_dcache_control_command => to_dcache_control_command,

      --Cache control common signals
      to_cache_control_base => to_cache_control_base,
      to_cache_control_last => to_cache_control_last,

      --Instruction memory-mapped master
      ifetch_oimm_address       => ifetch_oimm_address,
      ifetch_oimm_requestvalid  => ifetch_oimm_requestvalid,
      ifetch_oimm_readdata      => ifetch_oimm_readdata,
      ifetch_oimm_waitrequest   => ifetch_oimm_waitrequest,
      ifetch_oimm_readdatavalid => ifetch_oimm_readdatavalid,

      --Data memory-mapped master
      lsu_oimm_address       => lsu_oimm_address,
      lsu_oimm_byteenable    => lsu_oimm_byteenable,
      lsu_oimm_requestvalid  => lsu_oimm_requestvalid,
      lsu_oimm_readnotwrite  => lsu_oimm_readnotwrite,
      lsu_oimm_writedata     => lsu_oimm_writedata,
      lsu_oimm_readdata      => lsu_oimm_readdata,
      lsu_oimm_readdatavalid => lsu_oimm_readdatavalid,
      lsu_oimm_waitrequest   => lsu_oimm_waitrequest,

      --Timer signals
      timer_value     => timer_value,
      timer_interrupt => timer_interrupt,

      --Vector coprocessor port
      vcp_data0            => vcp_data0,
      vcp_data1            => vcp_data1,
      vcp_data2            => vcp_data2,
      vcp_instruction      => vcp_instruction,
      vcp_valid_instr      => vcp_valid_instr,
      vcp_ready            => vcp_ready,
      vcp_illegal          => vcp_illegal,
      vcp_writeback_data   => vcp_writeback_data,
      vcp_writeback_en     => vcp_writeback_en,
      vcp_alu_data1        => vcp_alu_data1,
      vcp_alu_data2        => vcp_alu_data2,
      vcp_alu_source_valid => vcp_alu_source_valid,
      vcp_alu_result       => vcp_alu_result,
      vcp_alu_result_valid => vcp_alu_result_valid,

      --Auxiliary/Uncached memory regions
      amr_base_addrs => amr_base_addrs,
      amr_last_addrs => amr_last_addrs,
      umr_base_addrs => umr_base_addrs,
      umr_last_addrs => umr_last_addrs
      );

  the_memory_interface : memory_interface
    generic map (
      REGISTER_SIZE         => REGISTER_SIZE,
      WRITE_FIRST_SUPPORTED => false,  --May be able to enable on some families
      --to save bypass logic

      WISHBONE_SINGLE_CYCLE_READS => false,  --For now assumed not supported; can
                                        --be brought to top level if needed
      MAX_IFETCHES_IN_FLIGHT      => MAX_IFETCHES_IN_FLIGHT,
      MAX_OUTSTANDING_REQUESTS    => MAX_OUTSTANDING_REQUESTS,

      LOG2_BURSTLENGTH => LOG2_BURSTLENGTH,
      AXI_ID_WIDTH     => AXI_ID_WIDTH,

      AVALON_AUX   => AVALON_AUX /= 0,
      WISHBONE_AUX => WISHBONE_AUX /= 0,
      LMB_AUX      => LMB_AUX /= 0,

      AUX_MEMORY_REGIONS => AUX_MEMORY_REGIONS,
      AMR0_ADDR_BASE     => AMR0_ADDR_BASE,
      AMR0_ADDR_LAST     => AMR0_ADDR_LAST,

      UC_MEMORY_REGIONS => UC_MEMORY_REGIONS,
      UMR0_ADDR_BASE    => UMR0_ADDR_BASE,
      UMR0_ADDR_LAST    => UMR0_ADDR_LAST,

      ICACHE_SIZE           => ICACHE_SIZE,
      ICACHE_LINE_SIZE      => ICACHE_LINE_SIZE,
      ICACHE_EXTERNAL_WIDTH => ICACHE_EXTERNAL_WIDTH,

      INSTRUCTION_REQUEST_REGISTER => natural_to_request_register(INSTRUCTION_REQUEST_REGISTER),
      INSTRUCTION_RETURN_REGISTER  => INSTRUCTION_RETURN_REGISTER /= 0,
      IUC_REQUEST_REGISTER         => natural_to_request_register(IUC_REQUEST_REGISTER),
      IUC_RETURN_REGISTER          => IUC_RETURN_REGISTER /= 0,
      IAUX_REQUEST_REGISTER        => natural_to_request_register(IAUX_REQUEST_REGISTER),
      IAUX_RETURN_REGISTER         => IAUX_RETURN_REGISTER /= 0,
      IC_REQUEST_REGISTER          => natural_to_request_register(IC_REQUEST_REGISTER),
      IC_RETURN_REGISTER           => IC_RETURN_REGISTER /= 0,

      DCACHE_SIZE           => DCACHE_SIZE,
      DCACHE_LINE_SIZE      => DCACHE_LINE_SIZE,
      DCACHE_EXTERNAL_WIDTH => DCACHE_EXTERNAL_WIDTH,
      DCACHE_WRITEBACK      => DCACHE_WRITEBACK /= 0,

      DATA_REQUEST_REGISTER => natural_to_request_register(DATA_REQUEST_REGISTER),
      DATA_RETURN_REGISTER  => DATA_RETURN_REGISTER /= 0,
      DUC_REQUEST_REGISTER  => natural_to_request_register(DUC_REQUEST_REGISTER),
      DUC_RETURN_REGISTER   => DUC_RETURN_REGISTER /= 0,
      DAUX_REQUEST_REGISTER => natural_to_request_register(DAUX_REQUEST_REGISTER),
      DAUX_RETURN_REGISTER  => DAUX_RETURN_REGISTER /= 0,
      DC_REQUEST_REGISTER   => natural_to_request_register(DC_REQUEST_REGISTER),
      DC_RETURN_REGISTER    => DC_RETURN_REGISTER /= 0
      )
    port map (
      clk   => clk,
      reset => reset,

      memory_interface_idle => memory_interface_idle,

      --Auxiliary/Uncached memory regions
      amr_base_addrs => amr_base_addrs,
      amr_last_addrs => amr_last_addrs,
      umr_base_addrs => umr_base_addrs,
      umr_last_addrs => umr_last_addrs,

      --ICache control (Invalidate/flush/writeback)
      from_icache_control_ready => from_icache_control_ready,
      to_icache_control_valid   => to_icache_control_valid,
      to_icache_control_command => to_icache_control_command,

      --DCache control (Invalidate/flush/writeback)
      from_dcache_control_ready => from_dcache_control_ready,
      to_dcache_control_valid   => to_dcache_control_valid,
      to_dcache_control_command => to_dcache_control_command,

      --Cache control common signals
      to_cache_control_base => to_cache_control_base,
      to_cache_control_last => to_cache_control_last,

      --Instruction memory-mapped master
      ifetch_oimm_address       => ifetch_oimm_address,
      ifetch_oimm_requestvalid  => ifetch_oimm_requestvalid,
      ifetch_oimm_readdata      => ifetch_oimm_readdata,
      ifetch_oimm_waitrequest   => ifetch_oimm_waitrequest,
      ifetch_oimm_readdatavalid => ifetch_oimm_readdatavalid,

      --Data memory-mapped master
      lsu_oimm_address       => lsu_oimm_address,
      lsu_oimm_byteenable    => lsu_oimm_byteenable,
      lsu_oimm_requestvalid  => lsu_oimm_requestvalid,
      lsu_oimm_readnotwrite  => lsu_oimm_readnotwrite,
      lsu_oimm_writedata     => lsu_oimm_writedata,
      lsu_oimm_readdata      => lsu_oimm_readdata,
      lsu_oimm_readdatavalid => lsu_oimm_readdatavalid,
      lsu_oimm_waitrequest   => lsu_oimm_waitrequest,

      -------------------------------------------------------------------------------
      --AVALON
      -------------------------------------------------------------------------------
      --Avalon data master
      avm_data_address       => avm_data_address,
      avm_data_byteenable    => avm_data_byteenable,
      avm_data_read          => avm_data_read,
      avm_data_readdata      => avm_data_readdata,
      avm_data_write         => avm_data_write,
      avm_data_writedata     => avm_data_writedata,
      avm_data_waitrequest   => avm_data_waitrequest,
      avm_data_readdatavalid => avm_data_readdatavalid,

      --Avalon instruction master
      avm_instruction_address       => avm_instruction_address,
      avm_instruction_read          => avm_instruction_read,
      avm_instruction_readdata      => avm_instruction_readdata,
      avm_instruction_waitrequest   => avm_instruction_waitrequest,
      avm_instruction_readdatavalid => avm_instruction_readdatavalid,

      -------------------------------------------------------------------------------
      --WISHBONE
      -------------------------------------------------------------------------------
      --WISHBONE data master
      data_ADR_O   => data_ADR_O,
      data_DAT_I   => data_DAT_I,
      data_DAT_O   => data_DAT_O,
      data_WE_O    => data_WE_O,
      data_SEL_O   => data_SEL_O,
      data_STB_O   => data_STB_O,
      data_ACK_I   => data_ACK_I,
      data_CYC_O   => data_CYC_O,
      data_CTI_O   => data_CTI_O,
      data_STALL_I => data_STALL_I,

      --WISHBONE instruction master
      instr_ADR_O   => instr_ADR_O,
      instr_DAT_I   => instr_DAT_I,
      instr_STB_O   => instr_STB_O,
      instr_ACK_I   => instr_ACK_I,
      instr_CYC_O   => instr_CYC_O,
      instr_CTI_O   => instr_CTI_O,
      instr_STALL_I => instr_STALL_I,

      -------------------------------------------------------------------------------
      --AXI
      -------------------------------------------------------------------------------
      --AXI4-Lite uncached instruction master
      --A full AXI3 interface is exposed for systems that require it, but
      --only the (read-only) AXI4-Lite signals are needed
      IUC_ARID    => IUC_ARID,
      IUC_ARADDR  => IUC_ARADDR,
      IUC_ARLEN   => IUC_ARLEN,
      IUC_ARSIZE  => IUC_ARSIZE,
      IUC_ARBURST => IUC_ARBURST,
      IUC_ARLOCK  => IUC_ARLOCK,
      IUC_ARCACHE => IUC_ARCACHE,
      IUC_ARPROT  => IUC_ARPROT,
      IUC_ARVALID => IUC_ARVALID,
      IUC_ARREADY => IUC_ARREADY,

      IUC_RID    => IUC_RID,
      IUC_RDATA  => IUC_RDATA,
      IUC_RRESP  => IUC_RRESP,
      IUC_RLAST  => IUC_RLAST,
      IUC_RVALID => IUC_RVALID,
      IUC_RREADY => IUC_RREADY,

      IUC_AWID    => IUC_AWID,
      IUC_AWADDR  => IUC_AWADDR,
      IUC_AWLEN   => IUC_AWLEN,
      IUC_AWSIZE  => IUC_AWSIZE,
      IUC_AWBURST => IUC_AWBURST,
      IUC_AWLOCK  => IUC_AWLOCK,
      IUC_AWCACHE => IUC_AWCACHE,
      IUC_AWPROT  => IUC_AWPROT,
      IUC_AWVALID => IUC_AWVALID,
      IUC_AWREADY => IUC_AWREADY,

      IUC_WID    => IUC_WID,
      IUC_WDATA  => IUC_WDATA,
      IUC_WSTRB  => IUC_WSTRB,
      IUC_WLAST  => IUC_WLAST,
      IUC_WVALID => IUC_WVALID,
      IUC_WREADY => IUC_WREADY,

      IUC_BID    => IUC_BID,
      IUC_BRESP  => IUC_BRESP,
      IUC_BVALID => IUC_BVALID,
      IUC_BREADY => IUC_BREADY,

      --AXI4-Lite uncached data master
      --A full AXI3 interface is exposed for systems that require it, but
      --only the AXI4-Lite signals are needed
      DUC_AWID    => DUC_AWID,
      DUC_AWADDR  => DUC_AWADDR,
      DUC_AWLEN   => DUC_AWLEN,
      DUC_AWSIZE  => DUC_AWSIZE,
      DUC_AWBURST => DUC_AWBURST,
      DUC_AWLOCK  => DUC_AWLOCK,
      DUC_AWCACHE => DUC_AWCACHE,
      DUC_AWPROT  => DUC_AWPROT,
      DUC_AWVALID => DUC_AWVALID,
      DUC_AWREADY => DUC_AWREADY,

      DUC_WID    => DUC_WID,
      DUC_WDATA  => DUC_WDATA,
      DUC_WSTRB  => DUC_WSTRB,
      DUC_WLAST  => DUC_WLAST,
      DUC_WVALID => DUC_WVALID,
      DUC_WREADY => DUC_WREADY,

      DUC_BID    => DUC_BID,
      DUC_BRESP  => DUC_BRESP,
      DUC_BVALID => DUC_BVALID,
      DUC_BREADY => DUC_BREADY,

      DUC_ARID    => DUC_ARID,
      DUC_ARADDR  => DUC_ARADDR,
      DUC_ARLEN   => DUC_ARLEN,
      DUC_ARSIZE  => DUC_ARSIZE,
      DUC_ARBURST => DUC_ARBURST,
      DUC_ARLOCK  => DUC_ARLOCK,
      DUC_ARCACHE => DUC_ARCACHE,
      DUC_ARPROT  => DUC_ARPROT,
      DUC_ARVALID => DUC_ARVALID,
      DUC_ARREADY => DUC_ARREADY,

      DUC_RID    => DUC_RID,
      DUC_RDATA  => DUC_RDATA,
      DUC_RRESP  => DUC_RRESP,
      DUC_RLAST  => DUC_RLAST,
      DUC_RVALID => DUC_RVALID,
      DUC_RREADY => DUC_RREADY,

      --AXI3/4 cacheable instruction master
      --WID can be unconnected and LOG2_BURSTLENGTH set to 8 to for AXI4
      --Read-only, write is exposed for systems that require it
      IC_ARID    => IC_ARID,
      IC_ARADDR  => IC_ARADDR,
      IC_ARLEN   => IC_ARLEN,
      IC_ARSIZE  => IC_ARSIZE,
      IC_ARBURST => IC_ARBURST,
      IC_ARLOCK  => IC_ARLOCK,
      IC_ARCACHE => IC_ARCACHE,
      IC_ARPROT  => IC_ARPROT,
      IC_ARVALID => IC_ARVALID,
      IC_ARREADY => IC_ARREADY,

      IC_RID    => IC_RID,
      IC_RDATA  => IC_RDATA,
      IC_RRESP  => IC_RRESP,
      IC_RLAST  => IC_RLAST,
      IC_RVALID => IC_RVALID,
      IC_RREADY => IC_RREADY,

      IC_AWID    => IC_AWID,
      IC_AWADDR  => IC_AWADDR,
      IC_AWLEN   => IC_AWLEN,
      IC_AWSIZE  => IC_AWSIZE,
      IC_AWBURST => IC_AWBURST,
      IC_AWLOCK  => IC_AWLOCK,
      IC_AWCACHE => IC_AWCACHE,
      IC_AWPROT  => IC_AWPROT,
      IC_AWVALID => IC_AWVALID,
      IC_AWREADY => IC_AWREADY,

      IC_WID    => IC_WID,
      IC_WDATA  => IC_WDATA,
      IC_WSTRB  => IC_WSTRB,
      IC_WLAST  => IC_WLAST,
      IC_WVALID => IC_WVALID,
      IC_WREADY => IC_WREADY,
      IC_BID    => IC_BID,
      IC_BRESP  => IC_BRESP,
      IC_BVALID => IC_BVALID,
      IC_BREADY => IC_BREADY,

      --AXI3/4 cacheable data master
      --WID can be unconnected and LOG2_BURSTLENGTH set to 8 to for AXI4
      DC_ARID    => DC_ARID,
      DC_ARADDR  => DC_ARADDR,
      DC_ARLEN   => DC_ARLEN,
      DC_ARSIZE  => DC_ARSIZE,
      DC_ARBURST => DC_ARBURST,
      DC_ARLOCK  => DC_ARLOCK,
      DC_ARCACHE => DC_ARCACHE,
      DC_ARPROT  => DC_ARPROT,
      DC_ARVALID => DC_ARVALID,
      DC_ARREADY => DC_ARREADY,

      DC_RID    => DC_RID,
      DC_RDATA  => DC_RDATA,
      DC_RRESP  => DC_RRESP,
      DC_RLAST  => DC_RLAST,
      DC_RVALID => DC_RVALID,
      DC_RREADY => DC_RREADY,

      DC_AWID    => DC_AWID,
      DC_AWADDR  => DC_AWADDR,
      DC_AWLEN   => DC_AWLEN,
      DC_AWSIZE  => DC_AWSIZE,
      DC_AWBURST => DC_AWBURST,
      DC_AWLOCK  => DC_AWLOCK,
      DC_AWCACHE => DC_AWCACHE,
      DC_AWPROT  => DC_AWPROT,
      DC_AWVALID => DC_AWVALID,
      DC_AWREADY => DC_AWREADY,

      DC_WID    => DC_WID,
      DC_WDATA  => DC_WDATA,
      DC_WSTRB  => DC_WSTRB,
      DC_WLAST  => DC_WLAST,
      DC_WVALID => DC_WVALID,
      DC_WREADY => DC_WREADY,
      DC_BID    => DC_BID,
      DC_BRESP  => DC_BRESP,
      DC_BVALID => DC_BVALID,
      DC_BREADY => DC_BREADY,

      -------------------------------------------------------------------------------
      --LMB
      -------------------------------------------------------------------------------
      --Xilinx local memory bus instruction master
      --Read-only, write is exposed for systems that require it
      ILMB_Addr         => ILMB_Addr,
      ILMB_Byte_Enable  => ILMB_Byte_Enable,
      ILMB_Data_Write   => ILMB_Data_Write,
      ILMB_AS           => ILMB_AS,
      ILMB_Read_Strobe  => ILMB_Read_Strobe,
      ILMB_Write_Strobe => ILMB_Write_Strobe,
      ILMB_Data_Read    => ILMB_Data_Read,
      ILMB_Ready        => ILMB_Ready,
      ILMB_Wait         => ILMB_Wait,
      ILMB_CE           => ILMB_CE,
      ILMB_UE           => ILMB_UE,

      --Xilinx local memory bus data master
      DLMB_Addr         => DLMB_Addr,
      DLMB_Byte_Enable  => DLMB_Byte_Enable,
      DLMB_Data_Write   => DLMB_Data_Write,
      DLMB_AS           => DLMB_AS,
      DLMB_Read_Strobe  => DLMB_Read_Strobe,
      DLMB_Write_Strobe => DLMB_Write_Strobe,
      DLMB_Data_Read    => DLMB_Data_Read,
      DLMB_Ready        => DLMB_Ready,
      DLMB_Wait         => DLMB_Wait,
      DLMB_CE           => DLMB_CE,
      DLMB_UE           => DLMB_UE
      );

  assert ENABLE_EXT_INTERRUPTS = 0 or ENABLE_EXCEPTIONS /= 0 report "External interrupts are enabled but exceptions are not enabled so they will never be processed; please disable extrnal interrupts (set ENABLE_EXT_INTERRUPTS to 0) or enable exceptions (set ENABLE_EXCEPTIONS to 1)" severity failure;

end architecture rtl;
