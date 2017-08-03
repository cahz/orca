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
			BYTE_SIZE       : integer              := 8;
			--BUS Select
			AVALON_ENABLE   : integer range 0 to 1 := 0;
			WISHBONE_ENABLE : integer range 0 to 1 := 0;
			AXI_ENABLE      : integer range 0 to 1 := 0;

			RESET_VECTOR          : integer                    := 16#00000000#;
			INTERRUPT_VECTOR			: integer										 := 16#00000200#;
			MULTIPLY_ENABLE       : natural range 0  to 1      := 0;
			DIVIDE_ENABLE         : natural range 0  to 1      := 0;
			SHIFTER_MAX_CYCLES    : natural                    := 1;
			COUNTER_LENGTH        : natural                    := 0;
			ENABLE_EXCEPTIONS     : natural                    := 1;
			BRANCH_PREDICTORS     : natural                    := 0;
			PIPELINE_STAGES       : natural range 4  to 5      := 5;
			LVE_ENABLE            : natural range 0  to 1      := 0;
			ENABLE_EXT_INTERRUPTS : natural range 0  to 1      := 0;
			NUM_EXT_INTERRUPTS    : integer range 1  to 32     := 1;
			SCRATCHPAD_ADDR_BITS  : integer                    := 10;
			TCRAM_SIZE            : integer range 64 to 524288 := 32768;
			CACHE_SIZE            : integer range 64 to 524288 := 32768;
			LINE_SIZE             : integer range 16 to 64     := 64;
			DRAM_WIDTH            : integer                    := 32;
			BURST_EN              : integer range 0  to 1      := 0;
			POWER_OPTIMIZED				: integer range 0  to 1			 := 0;
			CACHE_ENABLE					: integer range 0  to 1			 := 0;
			FAMILY                : string                     := "ALTERA");
		port (
			clk            : in std_logic;
			scratchpad_clk : in std_logic;
			reset          : in std_logic;

			--avalon data bus
			avm_data_address              : out std_logic_vector(REGISTER_SIZE-1 downto 0);
			avm_data_byteenable           : out std_logic_vector(REGISTER_SIZE/8 -1 downto 0);
			avm_data_read                 : out std_logic;
			avm_data_readdata             : in  std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
			avm_data_write                : out std_logic;
			avm_data_writedata            : out std_logic_vector(REGISTER_SIZE-1 downto 0);
			avm_data_waitrequest          : in  std_logic := '0';
			avm_data_readdatavalid        : in  std_logic := '0';
			--avalon instruction bus
			avm_instruction_address       : out std_logic_vector(REGISTER_SIZE-1 downto 0);
			avm_instruction_read          : out std_logic;
			avm_instruction_readdata      : in  std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
			avm_instruction_waitrequest   : in  std_logic := '0';
			avm_instruction_readdatavalid : in  std_logic := '0';
			--wishbone data bus
			data_ADR_O                    : out std_logic_vector(REGISTER_SIZE-1 downto 0);
			data_DAT_I                    : in  std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
			data_DAT_O                    : out std_logic_vector(REGISTER_SIZE-1 downto 0);
			data_WE_O                     : out std_logic;
			data_SEL_O                    : out std_logic_vector(REGISTER_SIZE/8 -1 downto 0);
			data_STB_O                    : out std_logic;
			data_ACK_I                    : in  std_logic := '0';
			data_CYC_O                    : out std_logic;
			data_CTI_O                    : out std_logic_vector(2 downto 0);
			data_STALL_I                  : in  std_logic := '0';
			--wishbone instruction bus
			instr_ADR_O                   : out std_logic_vector(REGISTER_SIZE-1 downto 0);
			instr_DAT_I                   : in  std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
			instr_STB_O                   : out std_logic;
			instr_ACK_I                   : in  std_logic := '0';
			instr_CYC_O                   : out std_logic;
			instr_CTI_O                   : out std_logic_vector(2 downto 0);
			instr_STALL_I                 : in  std_logic := '0';

			--AXI
			data_AWID    : out std_logic_vector(3 downto 0);
			data_AWADDR  : out std_logic_vector(REGISTER_SIZE -1 downto 0);
			data_AWLEN   : out std_logic_vector(3 downto 0);
			data_AWSIZE  : out std_logic_vector(2 downto 0);
			data_AWBURST : out std_logic_vector(1 downto 0);
			data_AWLOCK  : out std_logic_vector(1 downto 0);
			data_AWCACHE : out std_logic_vector(3 downto 0);
			data_AWPROT  : out std_logic_vector(2 downto 0);
			data_AWVALID : out std_logic;
			data_AWREADY : in  std_logic := '0';

			data_WID    : out std_logic_vector(3 downto 0);
			data_WDATA  : out std_logic_vector(REGISTER_SIZE -1 downto 0);
			data_WSTRB  : out std_logic_vector(REGISTER_SIZE/8 -1 downto 0);
			data_WLAST  : out std_logic;
			data_WVALID : out std_logic;
			data_WREADY : in  std_logic := '0';

			data_BID    : in  std_logic_vector(3 downto 0) := (others => '0');
			data_BRESP  : in  std_logic_vector(1 downto 0) := (others => '0');
			data_BVALID : in  std_logic := '0';
			data_BREADY : out std_logic;

			data_ARID    : out std_logic_vector(3 downto 0);
			data_ARADDR  : out std_logic_vector(REGISTER_SIZE -1 downto 0);
			data_ARLEN   : out std_logic_vector(3 downto 0);
			data_ARSIZE  : out std_logic_vector(2 downto 0);
			data_ARBURST : out std_logic_vector(1 downto 0);
			data_ARLOCK  : out std_logic_vector(1 downto 0);
			data_ARCACHE : out std_logic_vector(3 downto 0);
			data_ARPROT  : out std_logic_vector(2 downto 0);
			data_ARVALID : out std_logic;
			data_ARREADY : in  std_logic := '0';

			data_RID    : in  std_logic_vector(3 downto 0) := (others => '0');
			data_RDATA  : in  std_logic_vector(REGISTER_SIZE -1 downto 0) := (others => '0');
			data_RRESP  : in  std_logic_vector(1 downto 0) := (others => '0');
			data_RLAST  : in  std_logic := '0';
			data_RVALID : in  std_logic := '0';
			data_RREADY : out std_logic;

			itcram_ARID    : out std_logic_vector(3 downto 0);
			itcram_ARADDR  : out std_logic_vector(REGISTER_SIZE -1 downto 0);
			itcram_ARLEN   : out std_logic_vector(3 downto 0);
			itcram_ARSIZE  : out std_logic_vector(2 downto 0);
			itcram_ARBURST : out std_logic_vector(1 downto 0);
			itcram_ARLOCK  : out std_logic_vector(1 downto 0);
			itcram_ARCACHE : out std_logic_vector(3 downto 0);
			itcram_ARPROT  : out std_logic_vector(2 downto 0);
			itcram_ARVALID : out std_logic;
			itcram_ARREADY : in  std_logic := '0';

			itcram_RID    : in  std_logic_vector(3 downto 0) := (others => '0');
			itcram_RDATA  : in  std_logic_vector(REGISTER_SIZE -1 downto 0) := (others => '0');
			itcram_RRESP  : in  std_logic_vector(1 downto 0) := (others => '0');
			itcram_RLAST  : in  std_logic := '0';
			itcram_RVALID : in  std_logic := '0';
			itcram_RREADY : out std_logic;

			itcram_AWID    : out std_logic_vector(3 downto 0);
			itcram_AWADDR  : out std_logic_vector(REGISTER_SIZE -1 downto 0);
			itcram_AWLEN   : out std_logic_vector(3 downto 0);
			itcram_AWSIZE  : out std_logic_vector(2 downto 0);
			itcram_AWBURST : out std_logic_vector(1 downto 0);
			itcram_AWLOCK  : out std_logic_vector(1 downto 0);
			itcram_AWCACHE : out std_logic_vector(3 downto 0);
			itcram_AWPROT  : out std_logic_vector(2 downto 0);
			itcram_AWVALID : out std_logic;
			itcram_AWREADY : in  std_logic := '0';

			itcram_WID     : out std_logic_vector(3 downto 0);
			itcram_WDATA   : out std_logic_vector(REGISTER_SIZE -1 downto 0);
			itcram_WSTRB   : out std_logic_vector(REGISTER_SIZE/8 -1 downto 0);
			itcram_WLAST   : out std_logic;
			itcram_WVALID  : out std_logic;
			itcram_WREADY  : in  std_logic := '0';

			itcram_BID     : in  std_logic_vector(3 downto 0) := (others => '0');
			itcram_BRESP   : in  std_logic_vector(1 downto 0) := (others => '0');
			itcram_BVALID  : in  std_logic := '0';
			itcram_BREADY  : out std_logic;

			iram_ARID    : out std_logic_vector(3 downto 0);
			iram_ARADDR  : out std_logic_vector(REGISTER_SIZE -1 downto 0);
			iram_ARLEN   : out std_logic_vector(3 downto 0);
			iram_ARSIZE  : out std_logic_vector(2 downto 0);
			iram_ARBURST : out std_logic_vector(1 downto 0);
			iram_ARLOCK  : out std_logic_vector(1 downto 0);
			iram_ARCACHE : out std_logic_vector(3 downto 0);
			iram_ARPROT  : out std_logic_vector(2 downto 0);
			iram_ARVALID : out std_logic;
			iram_ARREADY : in  std_logic := '0';

			iram_RID    : in  std_logic_vector(3 downto 0) := (others => '0');
			iram_RDATA  : in  std_logic_vector(DRAM_WIDTH-1 downto 0) := (others => '0');
			iram_RRESP  : in  std_logic_vector(1 downto 0) := (others => '0');
			iram_RLAST  : in  std_logic := '0';
			iram_RVALID : in  std_logic := '0';
			iram_RREADY : out std_logic;

			iram_AWID    : out std_logic_vector(3 downto 0);
			iram_AWADDR  : out std_logic_vector(REGISTER_SIZE -1 downto 0);
			iram_AWLEN   : out std_logic_vector(3 downto 0);
			iram_AWSIZE  : out std_logic_vector(2 downto 0);
			iram_AWBURST : out std_logic_vector(1 downto 0);
			iram_AWLOCK  : out std_logic_vector(1 downto 0);
			iram_AWCACHE : out std_logic_vector(3 downto 0);
			iram_AWPROT  : out std_logic_vector(2 downto 0);
			iram_AWVALID : out std_logic;
			iram_AWREADY : in  std_logic := '0';
			
			iram_WID     : out std_logic_vector(3 downto 0);
			iram_WDATA   : out std_logic_vector(DRAM_WIDTH-1 downto 0);
			iram_WSTRB   : out std_logic_vector(DRAM_WIDTH/8 -1 downto 0);
			iram_WLAST   : out std_logic;
			iram_WVALID  : out std_logic;
			iram_WREADY  : in  std_logic := '0';
			iram_BID     : in  std_logic_vector(3 downto 0) := (others => '0');
			iram_BRESP   : in  std_logic_vector(1 downto 0) := (others => '0');
			iram_BVALID  : in  std_logic := '0';
			iram_BREADY  : out std_logic;

			-------------------------------------------------------------------------------
			-- Scratchpad Slave
			-------------------------------------------------------------------------------
			--avalon
			avm_scratch_address       : in  std_logic_vector(SCRATCHPAD_ADDR_BITS-1 downto 0) := (others => '0');
			avm_scratch_byteenable    : in  std_logic_vector(REGISTER_SIZE/8 -1 downto 0) := (others => '0');
			avm_scratch_read          : in  std_logic := '0';
			avm_scratch_readdata      : out std_logic_vector(REGISTER_SIZE-1 downto 0);
			avm_scratch_write         : in  std_logic := '0';
			avm_scratch_writedata     : in  std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
			avm_scratch_waitrequest   : out std_logic;
			avm_scratch_readdatavalid : out std_logic;

			--wishbone
			sp_ADR_I   : in  std_logic_vector(SCRATCHPAD_ADDR_BITS-1 downto 0) := (others => '0');
			sp_DAT_O   : out std_logic_vector(REGISTER_SIZE-1 downto 0);
			sp_DAT_I   : in  std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
			sp_WE_I    : in  std_logic := '0';
			sp_SEL_I   : in  std_logic_vector(REGISTER_SIZE/8 -1 downto 0) := (others => '0');
			sp_STB_I   : in  std_logic := '0';
			sp_ACK_O   : out std_logic;
			sp_CYC_I   : in  std_logic := '0';
			sp_CTI_I   : in  std_logic_vector(2 downto 0) := (others => '0');
			sp_STALL_O : out std_logic; 

			global_interrupts : in std_logic_vector(NUM_EXT_INTERRUPTS-1 downto 0) := (others => '0')
		);
	end component orca;

  component orca_core is
    generic (
      REGISTER_SIZE      : integer;
      RESET_VECTOR       : integer;
			INTERRUPT_VECTOR	 : integer;
      MULTIPLY_ENABLE    : natural range 0 to 1;
      DIVIDE_ENABLE      : natural range 0 to 1;
      SHIFTER_MAX_CYCLES : natural;
      POWER_OPTIMIZED    : natural range 0 to 1 := 0;
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
      INTERRUPT_VECTOR    : integer;
      MULTIPLY_ENABLE     : boolean;
      DIVIDE_ENABLE       : boolean;
      SHIFTER_MAX_CYCLES  : natural;
      POWER_OPTIMIZED     : boolean;
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
			fetch_in_flight			: in  std_logic;
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

      branch_pred : in std_logic_vector(REGISTER_SIZE*2+3-1 downto 0);

      instr_out   : out    std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
      pc_out      : out    std_logic_vector(REGISTER_SIZE-1 downto 0);
      next_pc_out : out    std_logic_vector(REGISTER_SIZE-1 downto 0);
      br_taken    : buffer std_logic;

      valid_instr_out : out std_logic;
			fetch_in_flight : out std_logic;

      read_address   : out    std_logic_vector(REGISTER_SIZE-1 downto 0);
      read_en        : buffer std_logic;
      read_data      : in     std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
      read_datavalid : in     std_logic;
      read_wait      : in     std_logic);
  end component instruction_fetch;

  component arithmetic_unit is
    generic (
      REGISTER_SIZE       : integer;
      SIMD_ENABLE         : boolean;
      SIGN_EXTENSION_SIZE : integer;
      MULTIPLY_ENABLE     : boolean;
      DIVIDE_ENABLE       : boolean;
      SHIFTER_MAX_CYCLES  : natural;
      POWER_OPTIMIZED     : boolean;
      FAMILY              : string);
    port (
      clk                : in std_logic;
      stall_to_alu       : in std_logic;
      stall_from_execute : in std_logic;
      simd_op_size       : in std_logic_vector(1 downto 0);
      valid_instr        : in std_logic;

      rs1_data        : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
      rs2_data        : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
      instruction     : in  std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
      sign_extension  : in  std_logic_vector(SIGN_EXTENSION_SIZE-1 downto 0);
      program_counter : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
      data_out        : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      data_out_valid  : out std_logic;
      less_than       : out std_logic;
      stall_from_alu  : out std_logic;

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
      INTERRUPT_VECTOR  : integer;
      COUNTER_LENGTH    : natural;
      ENABLE_EXCEPTIONS : boolean);
    port (
      clk         : in  std_logic;
      reset       : in  std_logic;
      valid       : in  std_logic;
      stall_in    : in  std_logic;
      rs1_data    : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
      instruction : in  std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
      stall_out   : out std_logic;
      wb_data     : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      wb_enable   : out std_logic;

      current_pc    : in     std_logic_vector(REGISTER_SIZE-1 downto 0);
      pc_correction : out    std_logic_vector(REGISTER_SIZE -1 downto 0);
      pc_corr_en    : buffer std_logic;

      interrupt_pending   : buffer std_logic;
      pipeline_empty      : in     std_logic;
      external_interrupts : in     std_logic_vector(REGISTER_SIZE-1 downto 0);


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
      POWER_OPTIMIZED  : boolean;
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
      lve_alu_op_size      : out    std_logic_vector(1 downto 0);
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
      nvm_addr     : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
      nvm_wdata    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      nvm_wen      : in  std_logic;
      nvm_byte_sel : in  std_logic_vector(DATA_WIDTH/8 -1 downto 0);
      nvm_strb     : in  std_logic;
      nvm_ack      : out std_logic;
      nvm_rdata    : out std_logic_vector(DATA_WIDTH-1 downto 0);

      -- user signals
      user_ARREADY : out std_logic;
      user_ARADDR  : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
      user_ARVALID : in  std_logic;

      user_RREADY : out std_logic;
      user_RDATA  : out std_logic_vector(ADDR_WIDTH-1 downto 0);
      user_RVALID : out std_logic;

      user_AWADDR  : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
      user_AWVALID : in  std_logic;
      user_AWREADY : out std_logic;

      user_WDATA  : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
      user_WVALID : in  std_logic;
      user_WREADY : out std_logic;

      user_BREADY : in  std_logic;
      user_BVALID : out std_logic;

      -- mux signals/ram inputs
      SEL          : in  std_logic;
      ram_addr     : out std_logic_vector(ADDR_WIDTH-1 downto 0);
      ram_wdata    : out std_logic_vector(DATA_WIDTH-1 downto 0);
      ram_wen      : out std_logic;
      ram_byte_sel : out std_logic_vector(DATA_WIDTH/8-1 downto 0);
      ram_strb     : out std_logic;
      ram_ack      : in  std_logic;
      ram_rdata    : in  std_logic_vector(DATA_WIDTH-1 downto 0)
      );
  end component;

  component iram is
    generic (
      SIZE      : integer := 4096;
      RAM_WIDTH : integer := 32;
      BYTE_SIZE : integer := 8);
    port (
      clk   : in std_logic;
      reset : in std_logic;

      addr     : in  std_logic_vector(RAM_WIDTH-1 downto 0);
      wdata    : in  std_logic_vector(RAM_WIDTH-1 downto 0);
      wen      : in  std_logic;
      byte_sel : in  std_logic_vector(RAM_WIDTH/8-1 downto 0);
      strb     : in  std_logic;
      ack      : out std_logic;
      rdata    : out std_logic_vector(RAM_WIDTH-1 downto 0);

      ram_AWID    : in std_logic_vector(3 downto 0);
      ram_AWADDR  : in std_logic_vector(RAM_WIDTH-1 downto 0);
      ram_AWLEN   : in std_logic_vector(3 downto 0);
      ram_AWSIZE  : in std_logic_vector(2 downto 0);
      ram_AWBURST : in std_logic_vector(1 downto 0);

      ram_AWLOCK  : in  std_logic_vector(1 downto 0);
      ram_AWCACHE : in  std_logic_vector(3 downto 0);
      ram_AWPROT  : in  std_logic_vector(2 downto 0);
      ram_AWVALID : in  std_logic;
      ram_AWREADY : out std_logic;

      ram_WID    : in  std_logic_vector(3 downto 0);
      ram_WDATA  : in  std_logic_vector(RAM_WIDTH -1 downto 0);
      ram_WSTRB  : in  std_logic_vector(RAM_WIDTH/BYTE_SIZE -1 downto 0);
      ram_WLAST  : in  std_logic;
      ram_WVALID : in  std_logic;
      ram_WREADY : out std_logic;

      ram_BID    : out std_logic_vector(3 downto 0);
      ram_BRESP  : out std_logic_vector(1 downto 0);
      ram_BVALID : out std_logic;
      ram_BREADY : in  std_logic;

      ram_ARID    : in  std_logic_vector(3 downto 0);
      ram_ARADDR  : in  std_logic_vector(RAM_WIDTH -1 downto 0);
      ram_ARLEN   : in  std_logic_vector(3 downto 0);
      ram_ARSIZE  : in  std_logic_vector(2 downto 0);
      ram_ARBURST : in  std_logic_vector(1 downto 0);
      ram_ARLOCK  : in  std_logic_vector(1 downto 0);
      ram_ARCACHE : in  std_logic_vector(3 downto 0);
      ram_ARPROT  : in  std_logic_vector(2 downto 0);
      ram_ARVALID : in  std_logic;
      ram_ARREADY : out std_logic;

      ram_RID    : out std_logic_vector(3 downto 0);
      ram_RDATA  : out std_logic_vector(RAM_WIDTH -1 downto 0);
      ram_RRESP  : out std_logic_vector(1 downto 0);
      ram_RLAST  : out std_logic;
      ram_RVALID : out std_logic;
      ram_RREADY : in  std_logic
      );
  end component;

  component bram_microsemi is
    generic (
      RAM_DEPTH : integer := 1024;      -- this is the maximum
      RAM_WIDTH : integer := 32;
      BYTE_SIZE : integer := 8
      );
    port (
      clock : in std_logic;

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
      ADDR_WIDTH    : integer := 32;
      REGISTER_SIZE : integer := 32;
      BYTE_SIZE     : integer := 8
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
      AWREADY : in  std_logic;

      WID    : out std_logic_vector(3 downto 0);
      WSTRB  : out std_logic_vector(REGISTER_SIZE/BYTE_SIZE -1 downto 0);
      WLAST  : out std_logic;
      WVALID : out std_logic;
      WDATA  : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      WREADY : in  std_logic;

      BID    : in  std_logic_vector(3 downto 0);
      BRESP  : in  std_logic_vector(1 downto 0);
      BVALID : in  std_logic;
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
      ARREADY : in  std_logic;

      RID : in std_logic_vector(3 downto 0);
      RDATA : in std_logic_vector(REGISTER_SIZE-1 downto 0);
      RRESP : in std_logic_vector(1 downto 0);
      RLAST : in std_logic;
      RVALID : in std_logic;
      RREADY : out std_logic
    );
  end component axi_master;

component axi_instruction_master is
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
    
end component axi_instruction_master;

  component ram_4port is
    generic(
      MEM_DEPTH       : natural;
      MEM_WIDTH       : natural;
      POWER_OPTIMIZED : boolean;
      FAMILY          : string := "ALTERA");
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
      RAM_DEPTH : integer := 1024;
      RAM_WIDTH : integer := 8
      );
    port (
        address_a  : in  std_logic_vector(log2(RAM_DEPTH)-1 downto 0);
        address_b  : in  std_logic_vector(log2(RAM_DEPTH)-1 downto 0);
        clock      : in  std_logic;
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

  component icache is
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
  end component icache;

  component cache_xilinx is
    generic (
      NUM_LINES   : integer := 1;  
      LINE_SIZE   : integer := 64; -- In bytes
      BYTE_SIZE   : integer := 8;
      ADDR_WIDTH  : integer := 32;
      READ_WIDTH  : integer := 32;
      WRITE_WIDTH  : integer := 32
    );
    port (
      clock : in std_logic;

      read_address   : in std_logic_vector(ADDR_WIDTH-1 downto 0);
      read_data_in   : in std_logic_vector(READ_WIDTH-1 downto 0); 
      read_valid_in  : in std_logic;
      read_we        : in std_logic;
      read_en        : in std_logic;
      read_readdata  : out std_logic_vector(READ_WIDTH-1 downto 0);
      read_hit       : out std_logic;

      write_address   : in std_logic_vector(ADDR_WIDTH-1 downto 0);
      write_data_in   : in std_logic_vector(WRITE_WIDTH-1 downto 0);
      write_valid_in  : in std_logic;
      write_we        : in std_logic;
      write_en        : in std_logic;
      write_readdata  : out std_logic_vector(WRITE_WIDTH-1 downto 0);
      write_hit       : out std_logic;

      write_tag_valid_in : in std_logic;
      write_tag_valid_en : in std_logic
    );
  end component;

  component cache_mux is
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
  end component;

end package rv_components;
