library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
library work;
use work.rv_components.all;
use work.utils.all;

entity Orca is
  generic (
    REGISTER_SIZE   : integer              := 32;
    --BUS Select
    AVALON_ENABLE   : integer range 0 to 1 := 0;
    WISHBONE_ENABLE : integer range 0 to 1 := 0;
    AXI_ENABLE      : integer range 0 to 1 := 0;

    RESET_VECTOR          : integer               := 16#00000000#;
    MULTIPLY_ENABLE       : natural range 0 to 1  := 0;
    DIVIDE_ENABLE         : natural range 0 to 1  := 0;
    SHIFTER_MAX_CYCLES    : natural               := 1;
    COUNTER_LENGTH        : natural               := 0;
    ENABLE_EXCEPTIONS     : natural               := 1;
    BRANCH_PREDICTORS     : natural               := 0;
    PIPELINE_STAGES       : natural range 4 to 5  := 5;
    LVE_ENABLE            : natural range 0 to 1  := 0;
    ENABLE_EXT_INTERRUPTS : natural range 0 to 1  := 0;
    NUM_EXT_INTERRUPTS    : integer range 1 to 32 := 1;
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
    avm_data_readdata             : in  std_logic_vector(REGISTER_SIZE-1 downto 0) := x"00000000";
    avm_data_write                : out std_logic;
    avm_data_writedata            : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    avm_data_waitrequest          : in  std_logic                                  := '0';
    avm_data_readdatavalid        : in  std_logic                                  := '0';
    --avalon instruction bus
    avm_instruction_address       : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    avm_instruction_read          : out std_logic;
    avm_instruction_readdata      : in  std_logic_vector(REGISTER_SIZE-1 downto 0) := x"00000000";
    avm_instruction_waitrequest   : in  std_logic                                  := '0';
    avm_instruction_readdatavalid : in  std_logic                                  := '0';
    --wishbone data bus
    data_ADR_O                    : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    data_DAT_I                    : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
    data_DAT_O                    : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    data_WE_O                     : out std_logic;
    data_SEL_O                    : out std_logic_vector(REGISTER_SIZE/8 -1 downto 0);
    data_STB_O                    : out std_logic;
    data_ACK_I                    : in  std_logic;
    data_CYC_O                    : out std_logic;
    data_CTI_O                    : out std_logic_vector(2 downto 0);
    data_STALL_I                  : in  std_logic;
    --wishbone instruction bus
    instr_ADR_O                   : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    instr_DAT_I                   : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
    instr_STB_O                   : out std_logic;
    instr_ACK_I                   : in  std_logic;
    instr_CYC_O                   : out std_logic;
    instr_CTI_O                   : out std_logic_vector(2 downto 0);
    instr_STALL_I                 : in  std_logic;

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
    data_AWREADY : in  std_logic;

    data_WID    : out std_logic_vector(3 downto 0);
    data_WDATA  : out std_logic_vector(REGISTER_SIZE -1 downto 0);
    data_WSTRB  : out std_logic_vector(REGISTER_SIZE/8 -1 downto 0);
    data_WLAST  : out std_logic;
    data_WVALID : out std_logic;
    data_WREADY : in  std_logic;

    data_BID    : in  std_logic_vector(3 downto 0);
    data_BRESP  : in  std_logic_vector(1 downto 0);
    data_BVALID : in  std_logic;
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
    data_ARREADY : in  std_logic;

    data_RID    : in  std_logic_vector(3 downto 0);
    data_RDATA  : in  std_logic_vector(REGISTER_SIZE -1 downto 0);
    data_RRESP  : in  std_logic_vector(1 downto 0);
    data_RLAST  : in  std_logic;
    data_RVALID : in  std_logic;
    data_RREADY : out std_logic;

    instr_ARID    : out std_logic_vector(3 downto 0);
    instr_ARADDR  : out std_logic_vector(REGISTER_SIZE -1 downto 0);
    instr_ARLEN   : out std_logic_vector(3 downto 0);
    instr_ARSIZE  : out std_logic_vector(2 downto 0);
    instr_ARBURST : out std_logic_vector(1 downto 0);
    instr_ARLOCK  : out std_logic_vector(1 downto 0);
    instr_ARCACHE : out std_logic_vector(3 downto 0);
    instr_ARPROT  : out std_logic_vector(2 downto 0);
    instr_ARVALID : out std_logic;
    instr_ARREADY : in  std_logic;

    instr_RID    : in  std_logic_vector(3 downto 0);
    instr_RDATA  : in  std_logic_vector(REGISTER_SIZE -1 downto 0);
    instr_RRESP  : in  std_logic_vector(1 downto 0);
    instr_RLAST  : in  std_logic;
    instr_RVALID : in  std_logic;
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
    instr_AWREADY : in  std_logic;
    instr_WID     : out std_logic_vector(3 downto 0);
    instr_WDATA   : out std_logic_vector(REGISTER_SIZE -1 downto 0);
    instr_WSTRB   : out std_logic_vector(REGISTER_SIZE/8 -1 downto 0);
    instr_WLAST   : out std_logic;
    instr_WVALID  : out std_logic;
    instr_WREADY  : in  std_logic;
    instr_BID     : in  std_logic_vector(3 downto 0);
    instr_BRESP   : in  std_logic_vector(1 downto 0);
    instr_BVALID  : in  std_logic;
    instr_BREADY  : out std_logic;

    -------------------------------------------------------------------------------
    -- Scratchpad Slave
    -------------------------------------------------------------------------------
    --avalon
    avm_scratch_address       : in  std_logic_vector(SCRATCHPAD_ADDR_BITS-1 downto 0);
    avm_scratch_byteenable    : in  std_logic_vector(REGISTER_SIZE/8 -1 downto 0);
    avm_scratch_read          : in  std_logic;
    avm_scratch_readdata      : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    avm_scratch_write         : in  std_logic;
    avm_scratch_writedata     : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
    avm_scratch_waitrequest   : out std_logic;
    avm_scratch_readdatavalid : out std_logic;

    --wishbone
    sp_ADR_I   : in  std_logic_vector(SCRATCHPAD_ADDR_BITS-1 downto 0);
    sp_DAT_O   : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    sp_DAT_I   : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
    sp_WE_I    : in  std_logic;
    sp_SEL_I   : in  std_logic_vector(REGISTER_SIZE/8 -1 downto 0);
    sp_STB_I   : in  std_logic;
    sp_ACK_O   : out std_logic;
    sp_CYC_I   : in  std_logic;
    sp_CTI_I   : in  std_logic_vector(2 downto 0);
    sp_STALL_O : out std_logic; 

    global_interrupts : in std_logic_vector(NUM_EXT_INTERRUPTS-1 downto 0) := (others => '0')
    );

end entity Orca;

architecture rtl of Orca is

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

  signal rom_instruction_address        : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal rom_instruction_read           : std_logic;
  signal rom_instruction_readdata       : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal rom_instruction_waitrequest    : std_logic;
  signal rom_instruction_readdatavalid  : std_logic;

  signal sp_address   : std_logic_vector(SCRATCHPAD_ADDR_BITS-1 downto 0);
  signal sp_byte_en   : std_logic_vector(REGISTER_SIZE/8 -1 downto 0);
  signal sp_write_en  : std_logic;
  signal sp_read_en   : std_logic;
  signal sp_writedata : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal sp_readdata  : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal sp_ack       : std_logic;




begin  -- architecture rtl
  assert AVALON_ENABLE + WISHBONE_ENABLE + AXI_ENABLE = 1 report "Exactly one bus type must be enabled" severity failure;


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

    signal core_instruction_stall4 : std_logic := '0';

    signal axi_reset : std_logic;

  begin

    axi_reset <= not reset;

    axi_data_master : axi_master
      generic map (
        ADDR_WIDTH    => REGISTER_SIZE,
        REGISTER_SIZE => REGISTER_SIZE,
        BYTE_SIZE     => 8
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
    instr_ARID                     <= (others => '0');
    instr_ARADDR                   <= core_instruction_address;
    instr_ARLEN                    <= BURST_LEN;
    instr_ARSIZE                   <= BURST_SIZE;
    instr_ARBURST                  <= BURST_INCR;
    instr_ARLOCK                   <= (others => '0');
    instr_ARCACHE                  <= (others => '0');
    instr_ARPROT                   <= (others => '0');
    instr_ARVALID                  <= core_instruction_read;
    core_instruction_stall4        <= not instr_ARREADY;
                                        -- instr_RID
    core_instruction_readdata      <= instr_RDATA;
                                        --instr_RRESP
                                        --instr_RLAST
    core_instruction_readdatavalid <= instr_RVALID;
    instr_RREADY                   <= '1';

    core_instruction_waitrequest <= core_instruction_stall4;

    instr_AWID    <= (others => '0');
    instr_AWADDR  <= (others => '0');
    instr_AWLEN   <= (others => '0');
    instr_AWSIZE  <= (others => '0');
    instr_AWBURST <= (others => '0');
    instr_AWLOCK  <= (others => '0');
    instr_AWCACHE <= (others => '0');
    instr_AWPROT  <= (others => '0');
    instr_AWVALID <= '0';
    instr_WID     <= (others => '0');
    instr_WDATA   <= (others => '0');
    instr_WSTRB   <= (others => '0');
    instr_WLAST   <= '0';
    instr_WVALID  <= '0';
    instr_BREADY  <= '1';


  end generate axi_enabled;

  core : orca_core
    generic map(
      REGISTER_SIZE      => REGISTER_SIZE,
      RESET_VECTOR       => RESET_VECTOR,
      MULTIPLY_ENABLE    => MULTIPLY_ENABLE,
      DIVIDE_ENABLE      => DIVIDE_ENABLE,
      SHIFTER_MAX_CYCLES => SHIFTER_MAX_CYCLES,
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
