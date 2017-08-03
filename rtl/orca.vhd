library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.rv_components.all;
use work.utils.all;

entity orca is
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
	POWER_OPTIMIZED		  : integer range 0  to 1	   := 0;
	CACHE_ENABLE		  : integer range 0  to 1	   := 0;
    FAMILY                : string                     := "ALTERA");
  port(
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

end entity orca;

architecture rtl of orca is

  signal core_data_address    : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal core_data_byteenable : std_logic_vector(REGISTER_SIZE/8 -1 downto 0);
  signal core_data_read       : std_logic;
  signal core_data_readdata   : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal core_data_write      : std_logic;
  signal core_data_writedata  : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal core_data_ack        : std_logic;

  signal core_instruction_address       : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal core_instruction_read          : std_logic;
  signal core_instruction_readdata      : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal core_instruction_waitrequest   : std_logic;
  signal core_instruction_readdatavalid : std_logic;

  signal sp_address   : std_logic_vector(SCRATCHPAD_ADDR_BITS-1 downto 0);
  signal sp_byte_en   : std_logic_vector(REGISTER_SIZE/8 -1 downto 0);
  signal sp_write_en  : std_logic;
  signal sp_read_en   : std_logic;
  signal sp_writedata : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal sp_readdata  : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal sp_ack       : std_logic;

begin  -- architecture rtl
  assert (AVALON_ENABLE + WISHBONE_ENABLE + AXI_ENABLE = 1) report "Exactly one bus type must be enabled" severity failure;
	assert (((CACHE_ENABLE = 1) and (FAMILY = "XILINX")) or (CACHE_ENABLE = 0)) report "Cache not supported for this family" severity failure;

  -----------------------------------------------------------------------------
  -- AVALON
  -----------------------------------------------------------------------------
  avalon_enabled : if AVALON_ENABLE = 1 generate
    signal is_writing : std_logic;
    signal is_reading : std_logic;
    signal write_ack  : std_logic;

    signal ack_mask : std_logic;
  begin
    core_data_readdata <= avm_data_readdata;

    core_data_ack  <= avm_data_readdatavalid or write_ack;
    avm_data_write <= is_writing;
    avm_data_read  <= is_reading;
    process(clk)

    begin
      if rising_edge(clk) then

        if (is_writing or is_reading) = '1' and avm_data_waitrequest = '1' then

        else
          is_reading          <= core_data_read;
          avm_data_address    <= core_data_address;
          is_writing          <= core_data_write;
          avm_data_writedata  <= core_data_writedata;
          avm_data_byteenable <= core_data_byteenable;
        end if;

        write_ack <= '0';
        if is_writing = '1' and avm_data_waitrequest = '0' then
          write_ack <= '1';
        end if;
      end if;

    end process;

    avm_instruction_address        <= core_instruction_address;
    avm_instruction_read           <= core_instruction_read;
    core_instruction_readdata      <= avm_instruction_readdata;
    core_instruction_waitrequest   <= avm_instruction_waitrequest;
    core_instruction_readdatavalid <= avm_instruction_readdatavalid;

    sp_address              <= avm_scratch_address;
    sp_byte_en              <= avm_scratch_byteenable;
    sp_read_en              <= avm_scratch_read;
    sp_write_en             <= avm_scratch_write;
    sp_writedata            <= avm_scratch_writedata;
    avm_scratch_readdata    <= sp_readdata;
    avm_scratch_waitrequest <= '0';
    process(clk)
    begin
      if rising_edge(clk) then
        if sp_ack = '1' then
          ack_mask <= '0';
        end if;
        if sp_read_en = '1' then
          ack_mask <= '1';
        end if;
      end if;
    end process;
    avm_scratch_readdatavalid <= sp_ack and ack_mask;

  end generate avalon_enabled;

  -----------------------------------------------------------------------------
  -- WISHBONE
  -----------------------------------------------------------------------------
  wishbone_enabled : if WISHBONE_ENABLE = 1 generate
    signal is_read_transaction : std_logic;
  begin
    core_data_readdata <= data_DAT_I;
    core_data_ack      <= data_ACK_I;

    instr_ADR_O                    <= core_instruction_address;
    instr_CYC_O                    <= core_instruction_read;
    instr_STB_O                    <= core_instruction_read;
    core_instruction_readdata      <= instr_DAT_I;
    core_instruction_waitrequest   <= instr_STALL_I;
    core_instruction_readdatavalid <= instr_ACK_I;

    process(clk)
    begin
      if rising_edge(clk) then
        if data_STALL_I = '0' then
          data_ADR_O <= core_data_address;
          data_SEL_O <= core_data_byteenable;
          data_CYC_O <= core_data_read or core_data_write;
          data_STB_O <= core_data_read or core_data_write;
          data_WE_O  <= core_data_write;
          data_DAT_O <= core_data_writedata;
        end if;
      end if;
    end process;

    --scrachpad slave
    sp_address   <= sp_ADR_I;
    sp_DAT_O     <= sp_readdata;
    sp_writedata <= sp_DAT_I;
    sp_write_en  <= sp_WE_I and sp_STB_I and sp_CYC_I;
    sp_read_en   <= not sp_WE_I and sp_STB_I and sp_CYC_I;
    sp_byte_en   <= sp_SEL_I;
    sp_ACK_O     <= sp_ack;
    sp_STALL_O   <= '0';


  end generate wishbone_enabled;

  axi_enabled : if AXI_ENABLE = 1 generate
    -- 1 transfer
    constant BURST_LEN  : std_logic_vector(3 downto 0) := "0000";
    -- 4 bytes in transfer
    constant BURST_SIZE : std_logic_vector(2 downto 0) := "010";
    -- incremental bursts
    constant BURST_INCR : std_logic_vector(1 downto 0) := "01";

    signal axi_reset : std_logic;

    signal instr_AWID    : std_logic_vector(3 downto 0);
    signal instr_AWADDR  : std_logic_vector(REGISTER_SIZE-1 downto 0);
    signal instr_AWLEN   : std_logic_vector(3 downto 0);
    signal instr_AWSIZE  : std_logic_vector(2 downto 0);
    signal instr_AWBURST : std_logic_vector(1 downto 0); 

    signal instr_AWLOCK  : std_logic_vector(1 downto 0);
    signal instr_AWCACHE : std_logic_vector(3 downto 0);
    signal instr_AWPROT  : std_logic_vector(2 downto 0);
    signal instr_AWVALID : std_logic;
    signal instr_AWREADY : std_logic;

    signal instr_WID     : std_logic_vector(3 downto 0);
    signal instr_WDATA   : std_logic_vector(REGISTER_SIZE-1 downto 0);
    signal instr_WSTRB   : std_logic_vector(REGISTER_SIZE/BYTE_SIZE-1 downto 0);
    signal instr_WLAST   : std_logic;
    signal instr_WVALID  : std_logic;
    signal instr_WREADY  : std_logic;

    signal instr_BID     : std_logic_vector(3 downto 0);
    signal instr_BRESP   : std_logic_vector(1 downto 0);
    signal instr_BVALID  : std_logic;
    signal instr_BREADY  : std_logic;

    signal instr_ARID    : std_logic_vector(3 downto 0);
    signal instr_ARADDR  : std_logic_vector(REGISTER_SIZE-1 downto 0);
    signal instr_ARLEN   : std_logic_vector(3 downto 0);
    signal instr_ARSIZE  : std_logic_vector(2 downto 0);
    signal instr_ARBURST : std_logic_vector(1 downto 0);
    signal instr_ARLOCK  : std_logic_vector(1 downto 0);
    signal instr_ARCACHE : std_logic_vector(3 downto 0);
    signal instr_ARPROT  : std_logic_vector(2 downto 0);
    signal instr_ARVALID : std_logic;
    signal instr_ARREADY : std_logic;
    
    signal instr_RID     : std_logic_vector(3 downto 0);
    signal instr_RDATA   : std_logic_vector(REGISTER_SIZE -1 downto 0);
    signal instr_RRESP   : std_logic_vector(1 downto 0);
    signal instr_RLAST   : std_logic;
    signal instr_RVALID  : std_logic;
    signal instr_RREADY  : std_logic;



    signal core_instruction_write : std_logic;
    signal core_instruction_writedata : std_logic_vector(REGISTER_SIZE-1 downto 0);

  begin
--BUG: this logic disregards the write response data

		axi_reset <= not reset;
    core_instruction_write <= '0';
    core_instruction_writedata <= (others => '0');

    data_master : axi_master
      generic map (
        ADDR_WIDTH    => REGISTER_SIZE,
        REGISTER_SIZE => REGISTER_SIZE,
        BYTE_SIZE     => BYTE_SIZE
      )
      port map (
        clk                     => clk,
        aresetn                 => axi_reset,

        core_data_address       => core_data_address, 
        core_data_byteenable    => core_data_byteenable,  
        core_data_read          => core_data_read,         
        core_data_readdata      => core_data_readdata,    
        core_data_write         => core_data_write,        
        core_data_writedata     => core_data_writedata,    
        core_data_ack           => core_data_ack,

        AWID                    => data_AWID, 
        AWADDR                  => data_AWADDR, 
        AWLEN                   => data_AWLEN,
        AWSIZE                  => data_AWSIZE,
        AWBURST                 => data_AWBURST,
        AWLOCK                  => data_AWLOCK, 
        AWCACHE                 => data_AWCACHE,
        AWPROT                  => data_AWPROT,
        AWVALID                 => data_AWVALID,
        AWREADY                 => data_AWREADY,

        WID                     => data_WID,
        WSTRB                   => data_WSTRB,
        WLAST                   => data_WLAST,
        WVALID                  => data_WVALID,
        WDATA                   => data_WDATA,
        WREADY                  => data_WREADY,
        
        BID                     => data_BID,
        BRESP                   => data_BRESP,
        BVALID                  => data_BVALID,
        BREADY                  => data_BREADY,

        ARID                    => data_ARID, 
        ARADDR                  => data_ARADDR,
        ARLEN                   => data_ARLEN, 
        ARSIZE                  => data_ARSIZE,
        ARLOCK                  => data_ARLOCK,
        ARCACHE                 => data_ARCACHE,
        ARPROT                  => data_ARPROT,
        ARBURST                 => data_ARBURST,
        ARVALID                 => data_ARVALID,
        ARREADY                 => data_ARREADY,

        RID                     => data_RID, 
        RDATA                   => data_RDATA, 
        RRESP                   => data_RRESP,
        RLAST                   => data_RLAST, 
        RVALID                  => data_RVALID,
        RREADY                  => data_RREADY
      );

    -- Instruction read port
    instruction_master : axi_instruction_master
      generic map (
        REGISTER_SIZE => REGISTER_SIZE,
        BYTE_SIZE     => BYTE_SIZE
      )
      port map (
        clk                            => clk,
        aresetn                        => axi_reset,
        core_instruction_address       => core_instruction_address, 
        core_instruction_read          => core_instruction_read,         
        core_instruction_readdata      => core_instruction_readdata,    
        core_instruction_readdatavalid => core_instruction_readdatavalid,
        core_instruction_write         => core_instruction_write,        
        core_instruction_writedata     => core_instruction_writedata,    
        core_instruction_waitrequest   => core_instruction_waitrequest,

        AWID                           => instr_AWID, 
        AWADDR                         => instr_AWADDR, 
        AWLEN                          => instr_AWLEN,
        AWSIZE                         => instr_AWSIZE,
        AWBURST                        => instr_AWBURST,
        AWLOCK                         => instr_AWLOCK, 
        AWCACHE                        => instr_AWCACHE,
        AWPROT                         => instr_AWPROT,
        AWVALID                        => instr_AWVALID,
        AWREADY                        => instr_AWREADY,

        WID                            => instr_WID,
        WSTRB                          => instr_WSTRB,
        WLAST                          => instr_WLAST,
        WVALID                         => instr_WVALID,
        WDATA                          => instr_WDATA,
        WREADY                         => instr_WREADY,
        
        BID                            => instr_BID,
        BRESP                          => instr_BRESP,
        BVALID                         => instr_BVALID,
        BREADY                         => instr_BREADY,

        ARID                           => instr_ARID, 
        ARADDR                         => instr_ARADDR,
        ARLEN                          => instr_ARLEN, 
        ARSIZE                         => instr_ARSIZE,
        ARLOCK                         => instr_ARLOCK,
        ARCACHE                        => instr_ARCACHE,
        ARPROT                         => instr_ARPROT,
        ARBURST                        => instr_ARBURST,
        ARVALID                        => instr_ARVALID,
        ARREADY                        => instr_ARREADY,

        RID                            => instr_RID, 
        RDATA                          => instr_RDATA, 
        RRESP                          => instr_RRESP,
        RLAST                          => instr_RLAST, 
        RVALID                         => instr_RVALID,
        RREADY                         => instr_RREADY
      );

		cache : if CACHE_ENABLE = 1 generate 

			signal cache_AWID    : std_logic_vector(3 downto 0);
			signal cache_AWADDR  : std_logic_vector(REGISTER_SIZE-1 downto 0);
			signal cache_AWLEN   : std_logic_vector(3 downto 0);
			signal cache_AWSIZE  : std_logic_vector(2 downto 0);
			signal cache_AWBURST : std_logic_vector(1 downto 0); 

			signal cache_AWLOCK  : std_logic_vector(1 downto 0);
			signal cache_AWCACHE : std_logic_vector(3 downto 0);
			signal cache_AWPROT  : std_logic_vector(2 downto 0);
			signal cache_AWVALID : std_logic;
			signal cache_AWREADY : std_logic;

			signal cache_WID     : std_logic_vector(3 downto 0);
			signal cache_WDATA   : std_logic_vector(REGISTER_SIZE -1 downto 0);
			signal cache_WSTRB   : std_logic_vector(REGISTER_SIZE/BYTE_SIZE-1 downto 0);
			signal cache_WLAST   : std_logic;
			signal cache_WVALID  : std_logic;
			signal cache_WREADY  : std_logic;

			signal cache_BID     : std_logic_vector(3 downto 0);
			signal cache_BRESP   : std_logic_vector(1 downto 0);
			signal cache_BVALID  : std_logic;
			signal cache_BREADY  : std_logic;

			signal cache_ARID    : std_logic_vector(3 downto 0);
			signal cache_ARADDR  : std_logic_vector(REGISTER_SIZE-1 downto 0);
			signal cache_ARLEN   : std_logic_vector(3 downto 0);
			signal cache_ARSIZE  : std_logic_vector(2 downto 0);
			signal cache_ARBURST : std_logic_vector(1 downto 0);
			signal cache_ARLOCK  : std_logic_vector(1 downto 0);
			signal cache_ARCACHE : std_logic_vector(3 downto 0);
			signal cache_ARPROT  : std_logic_vector(2 downto 0);
			signal cache_ARVALID : std_logic;
			signal cache_ARREADY : std_logic;

			signal cache_RID     : std_logic_vector(3 downto 0);
			signal cache_RDATA   : std_logic_vector(REGISTER_SIZE -1 downto 0);
			signal cache_RRESP   : std_logic_vector(1 downto 0);
			signal cache_RLAST   : std_logic;
			signal cache_RVALID  : std_logic;
			signal cache_RREADY  : std_logic;

		begin

			instruction_cache_mux : cache_mux
				generic map (
					TCRAM_SIZE => TCRAM_SIZE, 
					ADDR_WIDTH => REGISTER_SIZE,
					REGISTER_SIZE => REGISTER_SIZE,
					BYTE_SIZE => BYTE_SIZE
				)
				port map (
					clk => clk,
					reset => reset,
					
					in_AWID       =>  instr_AWID,      
					in_AWADDR     =>  instr_AWADDR, 
					in_AWLEN      =>  instr_AWLEN,  
					in_AWSIZE     =>  instr_AWSIZE, 
					in_AWBURST    =>  instr_AWBURST,
																			
					in_AWLOCK     =>  instr_AWLOCK, 
					in_AWCACHE    =>  instr_AWCACHE,
					in_AWPROT     =>  instr_AWPROT, 
					in_AWVALID    =>  instr_AWVALID,
					in_AWREADY    =>  instr_AWREADY,
																			
					in_WID        =>  instr_WID,    
					in_WDATA      =>  instr_WDATA,  
					in_WSTRB      =>  instr_WSTRB,  
					in_WLAST      =>  instr_WLAST,  
					in_WVALID     =>  instr_WVALID, 
					in_WREADY     =>  instr_WREADY, 
																			
					in_BID        =>  instr_BID,    
					in_BRESP      =>  instr_BRESP,  
					in_BVALID     =>  instr_BVALID, 
					in_BREADY     =>  instr_BREADY, 
																			
					in_ARID       =>  instr_ARID,   
					in_ARADDR     =>  instr_ARADDR,
					in_ARLEN      =>  instr_ARLEN, 
					in_ARSIZE     =>  instr_ARSIZE, 
					in_ARBURST    =>  instr_ARBURST,
					in_ARLOCK     =>  instr_ARLOCK, 
					in_ARCACHE    =>  instr_ARCACHE,
					in_ARPROT     =>  instr_ARPROT, 
					in_ARVALID    =>  instr_ARVALID,
					in_ARREADY    =>  instr_ARREADY,
																			
					in_RID        =>  instr_RID,    
					in_RDATA      =>  instr_RDATA,  
					in_RRESP      =>  instr_RRESP,  
					in_RLAST      =>  instr_RLAST,  
					in_RVALID     =>  instr_RVALID, 
					in_RREADY     =>  instr_RREADY, 
					
					cache_AWID    =>  cache_AWID,   
					cache_AWADDR  =>  cache_AWADDR, 
					cache_AWLEN   =>  cache_AWLEN,  
					cache_AWSIZE  =>  cache_AWSIZE, 
					cache_AWBURST =>  cache_AWBURST,
																				 
					cache_AWLOCK  =>  cache_AWLOCK, 
					cache_AWCACHE =>  cache_AWCACHE,
					cache_AWPROT  =>  cache_AWPROT, 
					cache_AWVALID =>  cache_AWVALID,
					cache_AWREADY =>  cache_AWREADY,
																				 
					cache_WID     =>  cache_WID,    
					cache_WDATA   =>  cache_WDATA,  
					cache_WSTRB   =>  cache_WSTRB,  
					cache_WLAST   =>  cache_WLAST,  
					cache_WVALID  =>  cache_WVALID, 
					cache_WREADY  =>  cache_WREADY, 
																				 
					cache_BID     =>  cache_BID,    
					cache_BRESP   =>  cache_BRESP,  
					cache_BVALID  =>  cache_BVALID, 
					cache_BREADY  =>  cache_BREADY, 
																				 
					cache_ARID    =>  cache_ARID,  
					cache_ARADDR  =>  cache_ARADDR, 
					cache_ARLEN   =>  cache_ARLEN,  
					cache_ARSIZE  =>  cache_ARSIZE, 
					cache_ARBURST =>  cache_ARBURST,
					cache_ARLOCK  =>  cache_ARLOCK, 
					cache_ARCACHE =>  cache_ARCACHE,
					cache_ARPROT  =>  cache_ARPROT, 
					cache_ARVALID =>  cache_ARVALID,
					cache_ARREADY =>  cache_ARREADY,
																				 
					cache_RID     =>  cache_RID,    
					cache_RDATA   =>  cache_RDATA,  
					cache_RRESP   =>  cache_RRESP,  
					cache_RLAST   =>  cache_RLAST,  
					cache_RVALID  =>  cache_RVALID, 
					cache_RREADY  =>  cache_RREADY, 

					tcram_AWID    =>  itcram_AWID,    
					tcram_AWADDR  =>  itcram_AWADDR,  
					tcram_AWLEN   =>  itcram_AWLEN,   
					tcram_AWSIZE  =>  itcram_AWSIZE,  
					tcram_AWBURST =>  itcram_AWBURST, 
																				 
					tcram_AWLOCK  =>  itcram_AWLOCK,  
					tcram_AWCACHE =>  itcram_AWCACHE, 
					tcram_AWPROT  =>  itcram_AWPROT,  
					tcram_AWVALID =>  itcram_AWVALID, 
					tcram_AWREADY =>  itcram_AWREADY, 
																				 
					tcram_WID     =>  itcram_WID,     
					tcram_WDATA   =>  itcram_WDATA,   
					tcram_WSTRB   =>  itcram_WSTRB,   
					tcram_WLAST   =>  itcram_WLAST,   
					tcram_WVALID  =>  itcram_WVALID,  
					tcram_WREADY  =>  itcram_WREADY,  
																				 
					tcram_BID     =>  itcram_BID,     
					tcram_BRESP   =>  itcram_BRESP,   
					tcram_BVALID  =>  itcram_BVALID,  
					tcram_BREADY  =>  itcram_BREADY,  
																				 
					tcram_ARID    =>  itcram_ARID,   
					tcram_ARADDR  =>  itcram_ARADDR,  
					tcram_ARLEN   =>  itcram_ARLEN,   
					tcram_ARSIZE  =>  itcram_ARSIZE,  
					tcram_ARBURST =>  itcram_ARBURST, 
					tcram_ARLOCK  =>  itcram_ARLOCK,  
					tcram_ARCACHE =>  itcram_ARCACHE, 
					tcram_ARPROT  =>  itcram_ARPROT,  
					tcram_ARVALID =>  itcram_ARVALID, 
					tcram_ARREADY =>  itcram_ARREADY, 
																				 
					tcram_RID     =>  itcram_RID,     
					tcram_RDATA   =>  itcram_RDATA,   
					tcram_RRESP   =>  itcram_RRESP,   
					tcram_RLAST   =>  itcram_RLAST,   
					tcram_RVALID  =>  itcram_RVALID,  
					tcram_RREADY  =>  itcram_RREADY  
				);

			instruction_cache : icache
				generic map (
					CACHE_SIZE => CACHE_SIZE, -- Byte size of cache
					LINE_SIZE  => LINE_SIZE,    -- Bytes per cache line 
					ADDR_WIDTH => REGISTER_SIZE,
					ORCA_WIDTH => REGISTER_SIZE,
					DRAM_WIDTH => DRAM_WIDTH, 
					BYTE_SIZE  => BYTE_SIZE,
					BURST_EN   => BURST_EN,
					FAMILY		 => FAMILY
				)
				port map (
					clk          => clk, 
					reset        => reset, 

					orca_AWID    => cache_AWID,
					orca_AWADDR  => cache_AWADDR,
					orca_AWLEN   => cache_AWLEN,
					orca_AWSIZE  => cache_AWSIZE,
					orca_AWBURST => cache_AWBURST,
																			 
					orca_AWLOCK  => cache_AWLOCK,
					orca_AWCACHE => cache_AWCACHE,
					orca_AWPROT  => cache_AWPROT,
					orca_AWVALID => cache_AWVALID,
					orca_AWREADY => cache_AWREADY,
																			 
					orca_WID     => cache_WID,
					orca_WDATA   => cache_WDATA,
					orca_WSTRB   => cache_WSTRB,
					orca_WLAST   => cache_WLAST,
					orca_WVALID  => cache_WVALID,
					orca_WREADY  => cache_WREADY,
																			 
					orca_BID     => cache_BID,
					orca_BRESP   => cache_BRESP,
					orca_BVALID  => cache_BVALID,
					orca_BREADY  => cache_BREADY,
																			 
					orca_ARID    => cache_ARID,
					orca_ARADDR  => cache_ARADDR,
					orca_ARLEN   => cache_ARLEN,
					orca_ARSIZE  => cache_ARSIZE,
					orca_ARBURST => cache_ARBURST,
					orca_ARLOCK  => cache_ARLOCK,
					orca_ARCACHE => cache_ARCACHE,
					orca_ARPROT  => cache_ARPROT,
					orca_ARVALID => cache_ARVALID,
					orca_ARREADY => cache_ARREADY,
																			 
					orca_RID     => cache_RID,
					orca_RDATA   => cache_RDATA,
					orca_RRESP   => cache_RRESP,
					orca_RLAST   => cache_RLAST,
					orca_RVALID  => cache_RVALID,
					orca_RREADY  => cache_RREADY,

					dram_AWID    => iram_AWID,
					dram_AWADDR  => iram_AWADDR,
					dram_AWLEN   => iram_AWLEN,
					dram_AWSIZE  => iram_AWSIZE,
					dram_AWBURST => iram_AWBURST,
																		 
					dram_AWLOCK  => iram_AWLOCK,
					dram_AWCACHE => iram_AWCACHE,
					dram_AWPROT  => iram_AWPROT,
					dram_AWVALID => iram_AWVALID,
					dram_AWREADY => iram_AWREADY,
																		 
					dram_WID     => iram_WID,
					dram_WDATA   => iram_WDATA,
					dram_WSTRB   => iram_WSTRB,
					dram_WLAST   => iram_WLAST,
					dram_WVALID  => iram_WVALID,
					dram_WREADY  => iram_WREADY,
																		 
					dram_BID     => iram_BID,
					dram_BRESP   => iram_BRESP,
					dram_BVALID  => iram_BVALID,
					dram_BREADY  => iram_BREADY,
																		 
					dram_ARID    => iram_ARID,
					dram_ARADDR  => iram_ARADDR,
					dram_ARLEN   => iram_ARLEN,
					dram_ARSIZE  => iram_ARSIZE,
					dram_ARBURST => iram_ARBURST,
					dram_ARLOCK  => iram_ARLOCK,
					dram_ARCACHE => iram_ARCACHE,
					dram_ARPROT  => iram_ARPROT,
					dram_ARVALID => iram_ARVALID,
					dram_ARREADY => iram_ARREADY,
																		 
					dram_RID     => iram_RID,
					dram_RDATA   => iram_RDATA,
					dram_RRESP   => iram_RRESP,
					dram_RLAST   => iram_RLAST,
					dram_RVALID  => iram_RVALID,
					dram_RREADY  => iram_RREADY
				);

		end generate cache;

		no_cache: if CACHE_ENABLE /= 1 generate
		begin

			iram_AWID    <= (others => '0');
			iram_AWADDR  <= (others => '0');
			iram_AWLEN	 <= (others => '0'); 
			iram_AWSIZE  <= (others => '0');
			iram_AWBURST <= (others => '0'); 
								 
			iram_AWLOCK  <= (others => '0');
			iram_AWCACHE <= (others => '0'); 
			iram_AWPROT  <= (others => '0');
			iram_AWVALID <= '0'; 
								 
			iram_WID		 <= (others => '0'); 
			iram_WDATA	 <= (others => '0'); 
			iram_WSTRB   <= (others => '0'); 
			iram_WLAST   <= '0'; 
			iram_WVALID  <= '0';
								 
			iram_BREADY  <= '0';
								 
			iram_ARID    <= (others => '0');	
			iram_ARADDR  <= (others => '0');	
			iram_ARLEN   <= (others => '0');	
			iram_ARSIZE  <= (others => '0'); 	
			iram_ARBURST <= (others => '0');	
			iram_ARLOCK  <= (others => '0');	
			iram_ARCACHE <= (others => '0');	
			iram_ARPROT  <= (others => '0');	
			iram_ARVALID <= '0';	
									 	
			iram_RREADY  <= '0';	
		
			itcram_AWID    <= instr_AWID;    
			itcram_AWADDR  <= instr_AWADDR;  
			itcram_AWLEN   <= instr_AWLEN;   
			itcram_AWSIZE  <= instr_AWSIZE;  
			itcram_AWBURST <= instr_AWBURST; 
												 		 
			itcram_AWLOCK  <= instr_AWLOCK;  
			itcram_AWCACHE <= instr_AWCACHE; 
			itcram_AWPROT  <= instr_AWPROT;  
			itcram_AWVALID <= instr_AWVALID; 
			instr_AWREADY  <= itcram_AWREADY; 
												 	 
			itcram_WID     <= instr_WID;     
			itcram_WDATA   <= instr_WDATA;   
			itcram_WSTRB   <= instr_WSTRB;   
			itcram_WLAST   <= instr_WLAST;   
			itcram_WVALID  <= instr_WVALID;  
			instr_WREADY	 <= itcram_WREADY;
												 		 
			instr_BID      <= itcram_BID;     
			instr_BRESP    <= itcram_BRESP;   
			instr_BVALID   <= itcram_BVALID;  
			itcram_BREADY  <= instr_BREADY;  
												 		 
			itcram_ARID    <= instr_ARID;   
			itcram_ARADDR  <= instr_ARADDR;  
			itcram_ARLEN   <= instr_ARLEN;   
			itcram_ARSIZE  <= instr_ARSIZE;  
			itcram_ARBURST <= instr_ARBURST; 
			itcram_ARLOCK  <= instr_ARLOCK;  
			itcram_ARCACHE <= instr_ARCACHE; 
			itcram_ARPROT  <= instr_ARPROT;  
			itcram_ARVALID <= instr_ARVALID; 
			instr_ARREADY  <= itcram_ARREADY; 
												 		 
			instr_RID      <= itcram_RID;     
			instr_RDATA    <= itcram_RDATA;   
			instr_RRESP    <= itcram_RRESP;   
			instr_RLAST    <= itcram_RLAST;   
			instr_RVALID   <= itcram_RVALID;  
			itcram_RREADY  <= instr_RREADY;  
		
		end generate no_cache;

  end generate axi_enabled;

  core : orca_core
    generic map(
      REGISTER_SIZE      => REGISTER_SIZE,
      RESET_VECTOR       => RESET_VECTOR,
			INTERRUPT_VECTOR	 => INTERRUPT_VECTOR,
      MULTIPLY_ENABLE    => MULTIPLY_ENABLE,
      DIVIDE_ENABLE      => DIVIDE_ENABLE,
      SHIFTER_MAX_CYCLES => SHIFTER_MAX_CYCLES,
      POWER_OPTIMIZED    => POWER_OPTIMIZED,
      COUNTER_LENGTH     => COUNTER_LENGTH,
      ENABLE_EXCEPTIONS  => ENABLE_EXCEPTIONS,
      BRANCH_PREDICTORS  => BRANCH_PREDICTORS,
      PIPELINE_STAGES    => PIPELINE_STAGES,
      LVE_ENABLE         => LVE_ENABLE,
      NUM_EXT_INTERRUPTS => CONDITIONAL(ENABLE_EXT_INTERRUPTS > 0, NUM_EXT_INTERRUPTS, 0),
      SCRATCHPAD_SIZE    => CONDITIONAL(LVE_ENABLE = 1, 2**SCRATCHPAD_ADDR_BITS, 0),
      FAMILY             => FAMILY)

    port map(
      clk            => clk,
      scratchpad_clk => scratchpad_clk,
      reset          => reset,

                                        --avalon master bus
      core_data_address              => core_data_address,
      core_data_byteenable           => core_data_byteenable,
      core_data_read                 => core_data_read,
      core_data_readdata             => core_data_readdata,
      core_data_write                => core_data_write,
      core_data_writedata            => core_data_writedata,
      core_data_ack                  => core_data_ack,
                                        --avalon master bus
      core_instruction_address       => core_instruction_address,
      core_instruction_read          => core_instruction_read,
      core_instruction_readdata      => core_instruction_readdata,
      core_instruction_waitrequest   => core_instruction_waitrequest,
      core_instruction_readdatavalid => core_instruction_readdatavalid,

      sp_address   => sp_address(CONDITIONAL(LVE_ENABLE = 1, SCRATCHPAD_ADDR_BITS, 0)-1 downto 0),
      sp_byte_en   => sp_byte_en,
      sp_write_en  => sp_write_en,
      sp_read_en   => sp_read_en,
      sp_writedata => sp_writedata,
      sp_readdata  => sp_readdata,
      sp_ack       => sp_ack,

      external_interrupts => global_interrupts(CONDITIONAL(ENABLE_EXT_INTERRUPTS > 0, NUM_EXT_INTERRUPTS, 0)-1 downto 0));

end architecture rtl;
