library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.utils.all;
use work.constants_pkg.all;

package rv_components is

  component orca is
    generic (
      REGISTER_SIZE   : integer              := 32;
      --BUS Select
      AVALON_ENABLE   : integer range 0 to 1 := 0;
      WISHBONE_ENABLE : integer range 0 to 1 := 0;
      AXI_ENABLE      : integer range 0 to 1 := 0;

      RESET_VECTOR          : integer               := 16#00000200#;
      MULTIPLY_ENABLE       : natural range 0 to 1  := 0;
      DIVIDE_ENABLE         : natural range 0 to 1  := 0;
      SHIFTER_MAX_CYCLES    : natural               := 1;
      COUNTER_LENGTH        : natural               := 0;
      ENABLE_EXCEPTIONS     : natural               := 1;
      BRANCH_PREDICTORS     : natural               := 0;
      PIPELINE_STAGES       : natural range 4 to 5  := 5;
      LVE_ENABLE            : natural range 0 to 1  := 0;
      ENABLE_EXT_INTERRUPTS : natural range 0 to 1  := 0;
      NUM_EXT_INTERRUPTS    : integer range 0 to 32 := 1;
      SCRATCHPAD_ADDR_BITS  : integer               := 10;
      FAMILY                : string                := "ALTERA");
    port(
      clk            : in std_logic;
      scratchpad_clk : in std_logic;
      reset          : in std_logic;

      --avalon data bus
      avm_data_address              : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      avm_data_byteenable           : out std_logic_vector(REGISTER_SIZE/8 -1 downto 0);
      avm_data_read                 : out std_logic;
      avm_data_readdata             : in  std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '-');
      avm_data_write                : out std_logic;
      avm_data_writedata            : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      avm_data_waitrequest          : in  std_logic                                  := '-';
      avm_data_readdatavalid        : in  std_logic                                  := '-';
      --avalon instruction bus
      avm_instruction_address       : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      avm_instruction_read          : out std_logic;
      avm_instruction_readdata      : in  std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '-');
      avm_instruction_waitrequest   : in  std_logic                                  := '-';
      avm_instruction_readdatavalid : in  std_logic                                  := '-';

      --wishbone data bus
      data_ADR_O    : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      data_DAT_I    : in  std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '-');
      data_DAT_O    : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      data_WE_O     : out std_logic;
      data_SEL_O    : out std_logic_vector(REGISTER_SIZE/8 -1 downto 0);
      data_STB_O    : out std_logic;
      data_ACK_I    : in  std_logic                                  := '-';
      data_CYC_O    : out std_logic;
      data_CTI_O    : out std_logic_vector(2 downto 0);
      data_STALL_I  : in  std_logic                                  := '-';
      --wishbone instruction bus
      instr_ADR_O   : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      instr_DAT_I   : in  std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '-');
      instr_STB_O   : out std_logic;
      instr_ACK_I   : in  std_logic                                  := '-';
      instr_CYC_O   : out std_logic;
      instr_CTI_O   : out std_logic_vector(2 downto 0);
      instr_STALL_I : in  std_logic                                  := '-';

      --AXI BUS

      -- Write address channel ---------------------------------------------------------
      data_AWID    : out std_logic_vector(3 downto 0);  -- ID for write address signals
      data_AWADDR  : out std_logic_vector(REGISTER_SIZE -1 downto 0);  -- Address of the first transferin a burst
      data_AWLEN   : out std_logic_vector(3 downto 0);  -- Number of transfers in a burst, burst must not cross 4 KB boundary, burst length of 1 to 16 transfers in AXI3
      data_AWSIZE  : out std_logic_vector(2 downto 0);  -- Maximum number of bytes to transfer in each data transfer (beat) in a burst
      -- See Table A3-2 for AxSIZE encoding
      -- 0b010 => 4 bytes in a transfer
      data_AWBURST : out std_logic_vector(1 downto 0);  -- defines the burst type, fixed, incr, or wrap
      -- fixed accesses the same address repeatedly, incr increments the address for each transfer, wrap = incr except rolls over to lower address if upper limit is reached
      -- see table A3-3 for AxBURST encoding
      data_AWLOCK  : out std_logic_vector(1 downto 0);  -- Ensures that only the master can access the targeted slave region
      data_AWCACHE : out std_logic_vector(3 downto 0);  -- specifies memory type, see Table A4-5
      data_AWPROT  : out std_logic_vector(2 downto 0);  -- specifies access permission, see Table A4-6
      data_AWVALID : out std_logic;  -- Valid address and control information on bus, asserted until slave asserts AWREADY
      data_AWREADY : in  std_logic := '-';  -- Slave is ready to accept address and control signals

      -- Write data channel ------------------------------------------------------------
      data_WID    : out std_logic_vector(3 downto 0);  -- ID for write data signals
      data_WDATA  : out std_logic_vector(REGISTER_SIZE -1 downto 0);
      data_WSTRB  : out std_logic_vector(REGISTER_SIZE/8 -1 downto 0);  -- Specifies which byte lanes contain valid information
      data_WLAST  : out std_logic;  -- Asserted when master is driving the final write transfer in the burst
      data_WVALID : out std_logic;  -- Valid data available on bus, asserted until slave asserts WREADY
      data_WREADY : in  std_logic := '-';  -- Slave is now available to accept write data

      -- Write response channel ---------------------------------------------------------
      data_BID    : in  std_logic_vector(3 downto 0) := (others => '-');  -- ID for write response
      data_BRESP  : in  std_logic_vector(1 downto 0) := (others => '-');  -- Slave response (with error codes) to a write
      data_BVALID : in  std_logic                    := '-';  -- Indicates that the channel is signaling a valid write response
      data_BREADY : out std_logic;  -- Indicates that master has acknowledged write response

      -- Read address channel ------------------------------------------------------------
      data_ARID    : out std_logic_vector(3 downto 0);
      data_ARADDR  : out std_logic_vector(REGISTER_SIZE -1 downto 0);
      data_ARLEN   : out std_logic_vector(3 downto 0);
      data_ARSIZE  : out std_logic_vector(2 downto 0);
      data_ARBURST : out std_logic_vector(1 downto 0);
      data_ARLOCK  : out std_logic_vector(1 downto 0);
      data_ARCACHE : out std_logic_vector(3 downto 0);
      data_ARPROT  : out std_logic_vector(2 downto 0);
      data_ARVALID : out std_logic;
      data_ARREADY : in  std_logic := '-';

      -- Read data channel -----------------------------------------------------------------
      data_RID    : in  std_logic_vector(3 downto 0)                := (others => '-');
      data_RDATA  : in  std_logic_vector(REGISTER_SIZE -1 downto 0) := (others => '-');
      data_RRESP  : in  std_logic_vector(1 downto 0)                := (others => '-');
      data_RLAST  : in  std_logic                                   := '-';
      data_RVALID : in  std_logic                                   := '-';
      data_RREADY : out std_logic;

      -- Read address channel ------------------------------------------------------------
      instr_ARID    : out std_logic_vector(3 downto 0);
      instr_ARADDR  : out std_logic_vector(REGISTER_SIZE -1 downto 0);
      instr_ARLEN   : out std_logic_vector(3 downto 0);
      instr_ARSIZE  : out std_logic_vector(2 downto 0);
      instr_ARBURST : out std_logic_vector(1 downto 0);
      instr_ARLOCK  : out std_logic_vector(1 downto 0);
      instr_ARCACHE : out std_logic_vector(3 downto 0);
      instr_ARPROT  : out std_logic_vector(2 downto 0);
      instr_ARVALID : out std_logic;
      instr_ARREADY : in  std_logic := '-';

      -- Read data channel -----------------------------------------------------------------
      instr_RID    : in  std_logic_vector(3 downto 0)                := (others => '-');
      instr_RDATA  : in  std_logic_vector(REGISTER_SIZE -1 downto 0) := (others => '-');
      instr_RRESP  : in  std_logic_vector(1 downto 0)                := (others => '-');
      instr_RLAST  : in  std_logic                                   := '-';
      instr_RVALID : in  std_logic                                   := '-';
      instr_RREADY : out std_logic;

      instr_AWID    : out std_logic_vector(3 downto 0);
      instr_AWADDR  : out std_logic_vector(REGISTER_SIZE -1 downto 0);
      instr_AWLEN   : out std_logic_vector(3 downto 0);
      instr_AWSIZE  : out std_logic_vector(2 downto 0);
      instr_AWBURST : out std_logic_vector(1 downto 0);
      instr_AWLOCK  : out std_logic_vector(1 downto 0);
      instr_AWCACHE : out std_logic_vector(3 downto 0);
      instr_AWPROT  : out std_logic_vector(2 downto 0);
      instr_AWVALID : out std_logic;
      instr_AWREADY : in  std_logic                    := '-';
      instr_WID     : out std_logic_vector(3 downto 0);
      instr_WDATA   : out std_logic_vector(REGISTER_SIZE -1 downto 0);
      instr_WSTRB   : out std_logic_vector(REGISTER_SIZE/8 -1 downto 0);
      instr_WLAST   : out std_logic;
      instr_WVALID  : out std_logic;
      instr_WREADY  : in  std_logic                    := '-';
      instr_BID     : in  std_logic_vector(3 downto 0) := (others => '-');
      instr_BRESP   : in  std_logic_vector(1 downto 0) := (others => '-');
      instr_BVALID  : in  std_logic                    := '-';
      instr_BREADY  : out std_logic;

      -------------------------------------------------------------------------------
      -- Scratchpad Slave
      -------------------------------------------------------------------------------
      --avalon
      avm_scratch_address       : in  std_logic_vector(SCRATCHPAD_ADDR_BITS-1 downto 0) := (others => '-');
      avm_scratch_byteenable    : in  std_logic_vector(REGISTER_SIZE/8 -1 downto 0)     := (others => '-');
      avm_scratch_read          : in  std_logic                                         := '-';
      avm_scratch_readdata      : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      avm_scratch_write         : in  std_logic                                         := '-';
      avm_scratch_writedata     : in  std_logic_vector(REGISTER_SIZE-1 downto 0)        := (others => '-');
      avm_scratch_waitrequest   : out std_logic;
      avm_scratch_readdatavalid : out std_logic;

      --wishbone
      sp_ADR_I   : in  std_logic_vector(SCRATCHPAD_ADDR_BITS-1 downto 0) := (others => '-');
      sp_DAT_O   : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      sp_DAT_I   : in  std_logic_vector(REGISTER_SIZE-1 downto 0)        := (others => '-');
      sp_WE_I    : in  std_logic                                         := '-';
      sp_SEL_I   : in  std_logic_vector(REGISTER_SIZE/8 -1 downto 0)     := (others => '-');
      sp_STB_I   : in  std_logic                                         := '-';
      sp_ACK_O   : out std_logic;
      sp_CYC_I   : in  std_logic                                         := '-';
      sp_CTI_I   : in  std_logic_vector(2 downto 0)                      := (others => '-');
      sp_STALL_O : out std_logic;



      global_interrupts : in std_logic_vector(NUM_EXT_INTERRUPTS-1 downto 0) := (others => '0')
      );
  end component orca;

  component orca_core is
    generic (
      REGISTER_SIZE      : integer;
      RESET_VECTOR       : integer;
      MULTIPLY_ENABLE    : natural range 0 to 1;
      DIVIDE_ENABLE      : natural range 0 to 1;
      SHIFTER_MAX_CYCLES : natural;
      COUNTER_LENGTH     : natural;
      ENABLE_EXCEPTIONS  : natural;
      BRANCH_PREDICTORS  : natural;
      PIPELINE_STAGES    : natural range 4 to 5;
      LVE_ENABLE         : natural range 0 to 1;
      NUM_EXT_INTERRUPTS : integer range 0 to 32;
      SCRATCHPAD_SIZE    : integer;
      FAMILY             : string);
    port(
      clk            : in std_logic;
      scratchpad_clk : in std_logic;
      reset          : in std_logic;

      --avalon master bus
      core_data_address              : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      core_data_byteenable           : out std_logic_vector(REGISTER_SIZE/8 -1 downto 0);
      core_data_read                 : out std_logic;
      core_data_readdata             : in  std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => 'X');
      core_data_write                : out std_logic;
      core_data_writedata            : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      core_data_ack                  : in  std_logic                                  := '0';
      --avalon master bus
      core_instruction_address       : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      core_instruction_read          : out std_logic;
      core_instruction_readdata      : in  std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => 'X');
      core_instruction_waitrequest   : in  std_logic                                  := '0';
      core_instruction_readdatavalid : in  std_logic                                  := '0';

      --memory-bus scratchpad-slave
      sp_address   : in  std_logic_vector(log2(SCRATCHPAD_SIZE)-1 downto 0);
      sp_byte_en   : in  std_logic_vector(REGISTER_SIZE/8 -1 downto 0);
      sp_write_en  : in  std_logic;
      sp_read_en   : in  std_logic;
      sp_writedata : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
      sp_readdata  : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      sp_ack       : out std_logic;

      external_interrupts : in std_logic_vector(NUM_EXT_INTERRUPTS-1 downto 0) := (others => '0')
      );
  end component orca_core;

  component decode is
    generic(
      REGISTER_SIZE       : positive;
      SIGN_EXTENSION_SIZE : positive;
      PIPELINE_STAGES     : natural range 1 to 2;
      FAMILY              : string);
    port(
      clk   : in std_logic;
      reset : in std_logic;
      stall : in std_logic;

      flush       : in std_logic;
      instruction : in std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
      valid_input : in std_logic;
      --writeback signals
      wb_sel      : in std_logic_vector(REGISTER_NAME_SIZE -1 downto 0);
      wb_data     : in std_logic_vector(REGISTER_SIZE -1 downto 0);
      wb_enable   : in std_logic;
      wb_valid    : in std_logic;

      --output signals
      rs1_data       : out    std_logic_vector(REGISTER_SIZE -1 downto 0);
      rs2_data       : out    std_logic_vector(REGISTER_SIZE -1 downto 0);
      sign_extension : out    std_logic_vector(SIGN_EXTENSION_SIZE -1 downto 0);
      --inputs just for carrying to next pipeline stage
      br_taken_in    : in     std_logic;
      pc_curr_in     : in     std_logic_vector(REGISTER_SIZE-1 downto 0);
      br_taken_out   : out    std_logic;
      pc_curr_out    : out    std_logic_vector(REGISTER_SIZE-1 downto 0);
      instr_out      : buffer std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
      subseq_instr   : out    std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
      subseq_valid   : out    std_logic;
      valid_output   : out    std_logic;
      decode_flushed : out    std_logic);
  end component decode;

  component execute is
    generic(
      REGISTER_SIZE       : positive;
      SIGN_EXTENSION_SIZE : positive;
      RESET_VECTOR        : integer;
      MULTIPLY_ENABLE     : boolean;
      DIVIDE_ENABLE       : boolean;
      SHIFTER_MAX_CYCLES  : natural;
      COUNTER_LENGTH      : natural;
      ENABLE_EXCEPTIONS   : boolean;
      SCRATCHPAD_SIZE     : integer;
      FAMILY              : string);
    port(
      clk            : in std_logic;
      scratchpad_clk : in std_logic;
      reset          : in std_logic;
      valid_input    : in std_logic;

      br_taken_in  : in std_logic;
      pc_current   : in std_logic_vector(REGISTER_SIZE-1 downto 0);
      instruction  : in std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
      subseq_instr : in std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
      subseq_valid : in std_logic;

      rs1_data       : in std_logic_vector(REGISTER_SIZE-1 downto 0);
      rs2_data       : in std_logic_vector(REGISTER_SIZE-1 downto 0);
      sign_extension : in std_logic_vector(SIGN_EXTENSION_SIZE-1 downto 0);

      wb_sel       : buffer std_logic_vector(REGISTER_NAME_SIZE-1 downto 0);
      wb_data      : buffer std_logic_vector(REGISTER_SIZE-1 downto 0);
      wb_enable    : buffer std_logic;
      valid_output : buffer std_logic;

      branch_pred        : out    std_logic_vector(REGISTER_SIZE*2+3-1 downto 0);
      stall_from_execute : buffer std_logic;

      --memory-bus master
      address   : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      byte_en   : out std_logic_vector(REGISTER_SIZE/8 -1 downto 0);
      write_en  : out std_logic;
      read_en   : out std_logic;
      writedata : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      readdata  : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
      data_ack  : in  std_logic;

      --memory-bus scratchpad-slave
      sp_address   : in  std_logic_vector(log2(SCRATCHPAD_SIZE)-1 downto 0);
      sp_byte_en   : in  std_logic_vector(REGISTER_SIZE/8 -1 downto 0);
      sp_write_en  : in  std_logic;
      sp_read_en   : in  std_logic;
      sp_writedata : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
      sp_readdata  : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      sp_ack       : out std_logic;

      external_interrupts : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
      pipeline_empty      : in  std_logic;
      ifetch_next_pc      : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
      interrupt_pending   : buffer std_logic);
  end component execute;

  component instruction_fetch is
    generic (
      REGISTER_SIZE     : positive;
      RESET_VECTOR      : integer;
      BRANCH_PREDICTORS : natural);
    port (
      clk                : in std_logic;
      reset              : in std_logic;
      downstream_stalled : in std_logic;
      interrupt_pending  : in std_logic;
      branch_pred        : in std_logic_vector(REGISTER_SIZE*2+3-1 downto 0);

      instr_out   : out    std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
      pc_out      : out    std_logic_vector(REGISTER_SIZE-1 downto 0);
      next_pc_out : out    std_logic_vector(REGISTER_SIZE-1 downto 0);
      br_taken    : buffer std_logic;

      valid_instr_out : out std_logic;

      read_address   : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      read_en        : buffer std_logic;
      read_data      : in  std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
      read_datavalid : in  std_logic;
      read_wait      : in  std_logic);
  end component instruction_fetch;

  component arithmetic_unit is
    generic (
      REGISTER_SIZE       : integer;
      SIGN_EXTENSION_SIZE : integer;
      MULTIPLY_ENABLE     : boolean;
      DIVIDE_ENABLE       : boolean;
      SHIFTER_MAX_CYCLES  : natural;
      FAMILY              : string);
    port (
      clk                : in  std_logic;
      stall_to_alu       : in  std_logic;
      stall_from_execute : in  std_logic;
      valid_instr        : in  std_logic;
      rs1_data           : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
      rs2_data           : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
      instruction        : in  std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
      sign_extension     : in  std_logic_vector(SIGN_EXTENSION_SIZE-1 downto 0);
      program_counter    : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
      data_out           : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      data_out_valid     : out std_logic;
      less_than          : out std_logic;
      stall_from_alu     : out std_logic;

      lve_data1        : in std_logic_vector(REGISTER_SIZE-1 downto 0);
      lve_data2        : in std_logic_vector(REGISTER_SIZE-1 downto 0);
      lve_source_valid : in std_logic
      );
  end component arithmetic_unit;

  component branch_unit is
    generic (
      REGISTER_SIZE       : integer;
      SIGN_EXTENSION_SIZE : integer);
    port (
      clk            : in  std_logic;
      stall          : in  std_logic;
      valid          : in  std_logic;
      reset          : in  std_logic;
      rs1_data       : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
      rs2_data       : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
      current_pc     : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
      br_taken_in    : in  std_logic;
      instr          : in  std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
      sign_extension : in  std_logic_vector(SIGN_EXTENSION_SIZE-1 downto 0);
      less_than      : in  std_logic;
      data_out       : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      data_out_en    : out std_logic;
      is_branch      : out std_logic;
      br_taken_out   : out std_logic;
      new_pc         : out std_logic_vector(REGISTER_SIZE-1 downto 0);  --next pc
      bad_predict    : out std_logic
      );
  end component branch_unit;

  component load_store_unit is
    generic (
      REGISTER_SIZE       : integer;
      SIGN_EXTENSION_SIZE : integer);
    port (
      clk            : in     std_logic;
      reset          : in     std_logic;
      valid          : in     std_logic;
      stall_to_lsu   : in     std_logic;
      rs1_data       : in     std_logic_vector(REGISTER_SIZE-1 downto 0);
      rs2_data       : in     std_logic_vector(REGISTER_SIZE-1 downto 0);
      instruction    : in     std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
      sign_extension : in     std_logic_vector(SIGN_EXTENSION_SIZE-1 downto 0);
      stalled        : buffer std_logic;
      data_out       : out    std_logic_vector(REGISTER_SIZE-1 downto 0);
      data_enable    : out    std_logic;
--memory-bus
      address        : out    std_logic_vector(REGISTER_SIZE-1 downto 0);
      byte_en        : out    std_logic_vector(REGISTER_SIZE/8 -1 downto 0);
      write_en       : buffer std_logic;
      read_en        : buffer std_logic;
      write_data     : out    std_logic_vector(REGISTER_SIZE-1 downto 0);
      read_data      : in     std_logic_vector(REGISTER_SIZE-1 downto 0);
      ack            : in     std_logic);
  end component load_store_unit;

  component register_file
    generic(
      REGISTER_SIZE      : positive;
      REGISTER_NAME_SIZE : positive);
    port(
      clk         : in std_logic;
      valid_input : in std_logic;
      rs1_sel     : in std_logic_vector(REGISTER_NAME_SIZE -1 downto 0);
      rs2_sel     : in std_logic_vector(REGISTER_NAME_SIZE -1 downto 0);
      wb_sel      : in std_logic_vector(REGISTER_NAME_SIZE -1 downto 0);
      wb_data     : in std_logic_vector(REGISTER_SIZE -1 downto 0);
      wb_enable   : in std_logic;

      rs1_data : buffer std_logic_vector(REGISTER_SIZE -1 downto 0);
      rs2_data : buffer std_logic_vector(REGISTER_SIZE -1 downto 0)
      );
  end component register_file;

  component system_calls is
    generic (
      REGISTER_SIZE     : natural;
      RESET_VECTOR      : integer;
      COUNTER_LENGTH    : natural;
      ENABLE_EXCEPTIONS : boolean);
    port (
      clk         : in std_logic;
      reset       : in std_logic;
      valid       : in std_logic;
      stall_in    : in std_logic;
      rs1_data    : in std_logic_vector(REGISTER_SIZE-1 downto 0);
      instruction : in std_logic_vector(INSTRUCTION_SIZE-1 downto 0);

      wb_data   : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      wb_enable : out std_logic;

      current_pc    : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
      pc_correction : out std_logic_vector(REGISTER_SIZE -1 downto 0);
      pc_corr_en    : buffer std_logic;

      interrupt_pending   : buffer std_logic;
      pipeline_empty      : in  std_logic;
      external_interrupts : in  std_logic_vector(REGISTER_SIZE-1 downto 0);


      instruction_fetch_pc : in std_logic_vector(REGISTER_SIZE-1 downto 0);
      br_bad_predict       : in std_logic;
      br_new_pc            : in std_logic_vector(REGISTER_SIZE-1 downto 0)
      );
  end component system_calls;

  component lve_ci is
    generic (
      REGISTER_SIZE : positive := 32
      );
    port (
      clk   : in std_logic;
      reset : in std_logic;

      pause : in std_logic;

      func3 : in std_logic_vector(2 downto 0);

      valid_in : in std_logic;
      data1_in : in std_logic_vector(REGISTER_SIZE-1 downto 0);
      data2_in : in std_logic_vector(REGISTER_SIZE-1 downto 0);

      align1_in : in std_logic_vector(1 downto 0);
      align2_in : in std_logic_vector(1 downto 0);

      valid_out        : out std_logic;
      write_enable_out : out std_logic;
      data_out         : out std_logic_vector(REGISTER_SIZE-1 downto 0)
      );
  end component lve_ci;

  component lve_top is
    generic(
      REGISTER_SIZE    : natural;
      SLAVE_DATA_WIDTH : natural;
      SCRATCHPAD_SIZE  : integer;
      FAMILY           : string);
    port(
      clk            : in std_logic;
      scratchpad_clk : in std_logic;
      reset          : in std_logic;
      instruction    : in std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
      valid_instr    : in std_logic;
      stall_to_lve   : in std_logic;
      rs1_data       : in std_logic_vector(REGISTER_SIZE-1 downto 0);
      rs2_data       : in std_logic_vector(REGISTER_SIZE-1 downto 0);

      slave_address  : in  std_logic_vector(log2(SCRATCHPAD_SIZE)-1 downto 0);
      slave_read_en  : in  std_logic;
      slave_write_en : in  std_logic;
      slave_byte_en  : in  std_logic_vector(SLAVE_DATA_WIDTH/8 -1 downto 0);
      slave_data_in  : in  std_logic_vector(SLAVE_DATA_WIDTH-1 downto 0);
      slave_data_out : out std_logic_vector(SLAVE_DATA_WIDTH-1 downto 0);
      slave_ack      : out std_logic;

      stall_from_lve       : out    std_logic;
      lve_alu_data1        : out    std_logic_vector(REGISTER_SIZE-1 downto 0);
      lve_alu_data2        : out    std_logic_vector(REGISTER_SIZE-1 downto 0);
      lve_alu_source_valid : buffer std_logic;
      lve_alu_result       : in     std_logic_vector(REGISTER_SIZE-1 downto 0);
      lve_alu_result_valid : in     std_logic
      );
  end component;

  component ram_mux is
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
  end component;

  component iram is
    generic (
      SIZE        : integer := 4096;
      RAM_WIDTH   : integer := 32;
      BYTE_SIZE   : integer := 8);    
    port (
      clk : in std_logic;
      reset : in std_logic;

      addr : in std_logic_vector(RAM_WIDTH-1 downto 0);
      wdata : in std_logic_vector(RAM_WIDTH-1 downto 0);
      wen  : in std_logic;
      byte_sel : in std_logic_vector(RAM_WIDTH/8-1 downto 0);
      strb  : in std_logic;
      ack   : out std_logic;
      rdata   : out std_logic_vector(RAM_WIDTH-1 downto 0);
      
      ram_AWID    : in std_logic_vector(3 downto 0);
      ram_AWADDR  : in std_logic_vector(RAM_WIDTH-1 downto 0);
      ram_AWLEN   : in std_logic_vector(3 downto 0);
      ram_AWSIZE  : in std_logic_vector(2 downto 0);
      ram_AWBURST : in std_logic_vector(1 downto 0); 

      ram_AWLOCK  : in std_logic_vector(1 downto 0);
      ram_AWCACHE : in std_logic_vector(3 downto 0);
      ram_AWPROT  : in std_logic_vector(2 downto 0);
      ram_AWVALID : in std_logic;
      ram_AWREADY : out std_logic;

      ram_WID     : in std_logic_vector(3 downto 0);
      ram_WDATA   : in std_logic_vector(RAM_WIDTH -1 downto 0);
      ram_WSTRB   : in std_logic_vector(RAM_WIDTH/BYTE_SIZE -1 downto 0);
      ram_WLAST   : in std_logic;
      ram_WVALID  : in std_logic;
      ram_WREADY  : out std_logic;

      ram_BID     : out std_logic_vector(3 downto 0);
      ram_BRESP   : out std_logic_vector(1 downto 0);
      ram_BVALID  : out std_logic;
      ram_BREADY  : in std_logic;

      ram_ARID    : in std_logic_vector(3 downto 0);
      ram_ARADDR  : in std_logic_vector(RAM_WIDTH -1 downto 0);
      ram_ARLEN   : in std_logic_vector(3 downto 0);
      ram_ARSIZE  : in std_logic_vector(2 downto 0);
      ram_ARBURST : in std_logic_vector(1 downto 0);
      ram_ARLOCK  : in std_logic_vector(1 downto 0);
      ram_ARCACHE : in std_logic_vector(3 downto 0);
      ram_ARPROT  : in std_logic_vector(2 downto 0);
      ram_ARVALID : in std_logic;
      ram_ARREADY : out std_logic;

      ram_RID     : out std_logic_vector(3 downto 0);
      ram_RDATA   : out std_logic_vector(RAM_WIDTH -1 downto 0);
      ram_RRESP   : out std_logic_vector(1 downto 0);
      ram_RLAST   : out std_logic;
      ram_RVALID  : out std_logic;
      ram_RREADY  : in std_logic
    );
  end component;

  component bram_microsemi is
    generic (
      RAM_DEPTH       : integer := 1024; -- this is the maximum
      RAM_WIDTH       : integer := 32;
      BYTE_SIZE       : integer := 8
      );
    port (
      clock    : in  std_logic;

      address  : in  std_logic_vector(log2(RAM_DEPTH)-1 downto 0);
      data_in  : in  std_logic_vector(RAM_WIDTH-1 downto 0);
      we       : in  std_logic;
      be       : in  std_logic_vector(RAM_WIDTH/BYTE_SIZE-1 downto 0);
      readdata : out std_logic_vector(RAM_WIDTH-1 downto 0);

      data_address  : in  std_logic_vector(log2(RAM_DEPTH)-1 downto 0);
      data_data_in  : in  std_logic_vector(RAM_WIDTH-1 downto 0);
      data_we       : in  std_logic;
      data_be       : in  std_logic_vector(RAM_WIDTH/BYTE_SIZE-1 downto 0);
      data_readdata : out std_logic_vector(RAM_WIDTH-1 downto 0)
      );
  end component;

  component axi_master is
    generic (
      ADDR_WIDTH : integer := 32;
      REGISTER_SIZE : integer := 32;
      BYTE_SIZE : integer := 8
    );

    port (
      clk : in std_logic;
      aresetn : in std_logic;

      core_data_address : in std_logic_vector(REGISTER_SIZE-1 downto 0);
      core_data_byteenable : in std_logic_vector(REGISTER_SIZE/BYTE_SIZE -1 downto 0);
      core_data_read : in std_logic;
      core_data_readdata : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      core_data_write : in std_logic;
      core_data_writedata : in std_logic_vector(REGISTER_SIZE-1 downto 0);
      core_data_ack : out std_logic;

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
  end component axi_master;

  component ram_4port is
    generic(
      MEM_DEPTH : natural;
      MEM_WIDTH : natural;
      FAMILY    : string := "ALTERA");
    port(
      clk            : in std_logic;
      scratchpad_clk : in std_logic;
      reset          : in std_logic;

      pause_lve_in  : in  std_logic;
      pause_lve_out : out std_logic;
                                        --read source A
      raddr0        : in  std_logic_vector(log2(MEM_DEPTH)-1 downto 0);
      ren0          : in  std_logic;
      scalar_value  : in  std_logic_vector(MEM_WIDTH-1 downto 0);
      scalar_enable : in  std_logic;
      data_out0     : out std_logic_vector(MEM_WIDTH-1 downto 0);

                                        --read source B
      raddr1      : in  std_logic_vector(log2(MEM_DEPTH)-1 downto 0);
      ren1        : in  std_logic;
      enum_value  : in  std_logic_vector(MEM_WIDTH-1 downto 0);
      enum_enable : in  std_logic;
      data_out1   : out std_logic_vector(MEM_WIDTH-1 downto 0);
      ack01       : out std_logic;
      --write dest
      waddr2      : in  std_logic_vector(log2(MEM_DEPTH)-1 downto 0);
      byte_en2    : in  std_logic_vector(MEM_WIDTH/8-1 downto 0);
      wen2        : in  std_logic;
      data_in2    : in  std_logic_vector(MEM_WIDTH-1 downto 0);
                                        --external slave port
      rwaddr3     : in  std_logic_vector(log2(MEM_DEPTH)-1 downto 0);
      wen3        : in  std_logic;
      ren3        : in  std_logic;      --cannot be asserted same cycle as wen3
      byte_en3    : in  std_logic_vector(MEM_WIDTH/8-1 downto 0);
      data_in3    : in  std_logic_vector(MEM_WIDTH-1 downto 0);
      ack3        : out std_logic;
      data_out3   : out std_logic_vector(MEM_WIDTH-1 downto 0));
  end component;

  component idram_xilinx is
    generic (
      RAM_DEPTH       : integer := 1024;
      RAM_WIDTH       : integer := 32;
      BYTE_SIZE       : integer := 8
      );
    port (
      clock    : in  std_logic;

      instr_address  : in  std_logic_vector(log2(RAM_DEPTH)-1 downto 0);
      instr_data_in  : in  std_logic_vector(RAM_WIDTH-1 downto 0);
      instr_we       : in  std_logic;
      instr_en       : in  std_logic;
      instr_be       : in  std_logic_vector(RAM_WIDTH/BYTE_SIZE-1 downto 0);
      instr_readdata : out std_logic_vector(RAM_WIDTH-1 downto 0);

      data_address  : in  std_logic_vector(log2(RAM_DEPTH)-1 downto 0);
      data_data_in  : in  std_logic_vector(RAM_WIDTH-1 downto 0);
      data_we       : in  std_logic;
      data_en       : in  std_logic;
      data_be       : in  std_logic_vector(RAM_WIDTH/BYTE_SIZE-1 downto 0);
      data_readdata : out std_logic_vector(RAM_WIDTH-1 downto 0)
      );
  end component;

  component bram_xilinx is
    generic (
      RAM_DEPTH : integer := 1024
      );
    port (
        address_a  : in  std_logic_vector(log2(RAM_DEPTH)-1 downto 0);
        address_b  : in  std_logic_vector(log2(RAM_DEPTH)-1 downto 0);
        clock      : in  std_logic;
        data_a     : in  std_logic_vector(7 downto 0);
        data_b     : in  std_logic_vector(7 downto 0);
        wren_a     : in  std_logic;
        wren_b     : in  std_logic;
        en_a       : in  std_logic;
        en_b       : in  std_logic;
        readdata_a : out std_logic_vector(7 downto 0);
        readdata_b : out std_logic_vector(7 downto 0)
        );
  end component;


end package rv_components;
