library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.rv_components.all;

entity microsemi_wrapper is

  generic (
    REGISTER_SIZE         : integer								:= 32;
    RESET_VECTOR          : natural              	:= 16#00000000#;
    MULTIPLY_ENABLE       : natural range 0 to 1 	:= 1;
    DIVIDE_ENABLE         : natural range 0 to 1 	:= 1;
    SHIFTER_MAX_CYCLES    : natural              	:= 1;
    COUNTER_LENGTH        : natural              	:= 32;
    ENABLE_EXCEPTIONS     : natural              	:= 1;
    BRANCH_PREDICTORS     : natural              	:= 0;
    PIPELINE_STAGES       : natural range 4 to 5 	:= 5;
    LVE_ENABLE            : natural range 0 to 1 	:= 0;
    ENABLE_EXT_INTERRUPTS : natural range 0 to 1 	:= 0;
    NUM_EXT_INTERRUPTS    : natural range 1 to 32 := 1;
    SCRATCHPAD_ADDR_BITS  : integer               := 10;
    FORWARD_ALU_ONLY			: natural range 0 to 1  := 1;
    TCRAM_SIZE         		: natural               := 32768;
		POWER_OPTIMIZED				: integer range 0 to 1  := 0;
    BYTE_SIZE         		: integer               := 8);

  port (clk : in std_logic;
        clk_2x : in std_logic;
        reset : in std_logic;
        
        data_AWID    : out std_logic_vector(3 downto 0);
        data_AWADDR  : out std_logic_vector(REGISTER_SIZE -1 downto 0);
        data_AWLEN   : out std_logic_vector(3 downto 0);
        data_AWSIZE  : out std_logic_vector(2 downto 0);
        data_AWBURST : out std_logic_vector(1 downto 0); 
        
        data_AWLOCK  : out std_logic_vector(1 downto 0);
        data_AWCACHE : out std_logic_vector(3 downto 0);
        data_AWPROT  : out std_logic_vector(2 downto 0);
        data_AWVALID : out std_logic;
        data_AWREADY : in std_logic;

        data_WID     : out std_logic_vector(3 downto 0);
        data_WDATA   : out std_logic_vector(REGISTER_SIZE -1 downto 0);
        data_WSTRB   : out std_logic_vector(REGISTER_SIZE/BYTE_SIZE -1 downto 0);
        data_WLAST   : out std_logic;
        data_WVALID  : out std_logic;
        data_WREADY  : in std_logic;

        data_BID     : in std_logic_vector(3 downto 0);
        data_BRESP   : in std_logic_vector(1 downto 0);
        data_BVALID  : in std_logic;
        data_BREADY  : out std_logic;

        data_ARID    : out std_logic_vector(3 downto 0);
        data_ARADDR  : out std_logic_vector(REGISTER_SIZE -1 downto 0);
        data_ARLEN   : out std_logic_vector(3 downto 0);
        data_ARSIZE  : out std_logic_vector(2 downto 0);
        data_ARBURST : out std_logic_vector(1 downto 0);
        data_ARLOCK  : out std_logic_vector(1 downto 0);
        data_ARCACHE : out std_logic_vector(3 downto 0);
        data_ARPROT  : out std_logic_vector(2 downto 0);
        data_ARVALID : out std_logic;
        data_ARREADY : in std_logic;

        data_RID     : in std_logic_vector(3 downto 0);
        data_RDATA   : in std_logic_vector(REGISTER_SIZE -1 downto 0);
        data_RRESP   : in std_logic_vector(1 downto 0);
        data_RLAST   : in std_logic;
        data_RVALID  : in std_logic;
        data_RREADY  : out std_logic;
        
        ram_AWID    : in std_logic_vector(3 downto 0);
        ram_AWADDR  : in std_logic_vector(REGISTER_SIZE -1 downto 0);
        ram_AWLEN   : in std_logic_vector(3 downto 0);
        ram_AWSIZE  : in std_logic_vector(2 downto 0);
        ram_AWBURST : in std_logic_vector(1 downto 0); 

        ram_AWLOCK  : in std_logic_vector(1 downto 0);
        ram_AWCACHE : in std_logic_vector(3 downto 0);
        ram_AWPROT  : in std_logic_vector(2 downto 0);
        ram_AWVALID : in std_logic;
        ram_AWREADY : out std_logic;

        ram_WID     : in std_logic_vector(3 downto 0);
        ram_WDATA   : in std_logic_vector(REGISTER_SIZE -1 downto 0);
        ram_WSTRB   : in std_logic_vector(REGISTER_SIZE/BYTE_SIZE -1 downto 0);
        ram_WLAST   : in std_logic;
        ram_WVALID  : in std_logic;
        ram_WREADY  : out std_logic;

        ram_BID     : out std_logic_vector(3 downto 0);
        ram_BRESP   : out std_logic_vector(1 downto 0);
        ram_BVALID  : out std_logic;
        ram_BREADY  : in std_logic;

        ram_ARID    : in std_logic_vector(3 downto 0);
        ram_ARADDR  : in std_logic_vector(REGISTER_SIZE -1 downto 0);
        ram_ARLEN   : in std_logic_vector(3 downto 0);
        ram_ARSIZE  : in std_logic_vector(2 downto 0);
        ram_ARBURST : in std_logic_vector(1 downto 0);
        ram_ARLOCK  : in std_logic_vector(1 downto 0);
        ram_ARCACHE : in std_logic_vector(3 downto 0);
        ram_ARPROT  : in std_logic_vector(2 downto 0);
        ram_ARVALID : in std_logic;
        ram_ARREADY : out std_logic;

        ram_RID     : out std_logic_vector(3 downto 0);
        ram_RDATA   : out std_logic_vector(REGISTER_SIZE -1 downto 0);
        ram_RRESP   : out std_logic_vector(1 downto 0);
        ram_RLAST   : out std_logic;
        ram_RVALID  : out std_logic;
        ram_RREADY  : in std_logic;

        -- INSTRUCTION 
        -- state machine feeds into mux (include SEL)
        -- avalon feeds into mux
        -- mux feeds into RAM
        
        -- INSTRUCTION NVM INPUT
        -- feeds into state machine so init can access IRAM
        nvm_PADDR : in std_logic_vector(REGISTER_SIZE-1 downto 0);
        nvm_PENABLE : in std_logic;
        nvm_PWRITE : in std_logic;
        nvm_PRDATA : out std_logic_vector(REGISTER_SIZE-1 downto 0);
        nvm_PWDATA : in std_logic_vector(REGISTER_SIZE-1 downto 0);
        nvm_PREADY : out std_logic;
        nvm_PSEL : in std_logic
      );

end entity microsemi_wrapper;

architecture rtl of microsemi_wrapper is

  signal orca_reset             : std_logic;

  signal itcram_AWID    : std_logic_vector(3 downto 0);
  signal itcram_AWADDR  : std_logic_vector(REGISTER_SIZE -1 downto 0);
  signal itcram_AWLEN   : std_logic_vector(3 downto 0);
  signal itcram_AWSIZE  : std_logic_vector(2 downto 0);
  signal itcram_AWBURST : std_logic_vector(1 downto 0); 
  signal itcram_AWLOCK  : std_logic_vector(1 downto 0);
  signal itcram_AWCACHE : std_logic_vector(3 downto 0);
  signal itcram_AWPROT  : std_logic_vector(2 downto 0);
  signal itcram_AWVALID : std_logic;
  signal itcram_AWREADY : std_logic;
  signal itcram_WID     : std_logic_vector(3 downto 0);
  signal itcram_WDATA   : std_logic_vector(REGISTER_SIZE -1 downto 0);
  signal itcram_WSTRB   : std_logic_vector(REGISTER_SIZE/BYTE_SIZE -1 downto 0);
  signal itcram_WLAST   : std_logic;
  signal itcram_WVALID  : std_logic;
  signal itcram_WREADY  : std_logic;
  signal itcram_BID     : std_logic_vector(3 downto 0);
  signal itcram_BRESP   : std_logic_vector(1 downto 0);
  signal itcram_BVALID  : std_logic;
  signal itcram_BREADY  : std_logic;
  signal itcram_ARID    : std_logic_vector(3 downto 0);
  signal itcram_ARADDR  : std_logic_vector(REGISTER_SIZE -1 downto 0);
  signal itcram_ARLEN   : std_logic_vector(3 downto 0);
  signal itcram_ARSIZE  : std_logic_vector(2 downto 0);
  signal itcram_ARBURST : std_logic_vector(1 downto 0);
  signal itcram_ARLOCK  : std_logic_vector(1 downto 0);
  signal itcram_ARCACHE : std_logic_vector(3 downto 0);
  signal itcram_ARPROT  : std_logic_vector(2 downto 0);
  signal itcram_ARVALID : std_logic;
  signal itcram_ARREADY : std_logic;
  signal itcram_RID     : std_logic_vector(3 downto 0);
  signal itcram_RDATA   : std_logic_vector(REGISTER_SIZE -1 downto 0);
  signal itcram_RRESP   : std_logic_vector(1 downto 0);
  signal itcram_RLAST   : std_logic;
  signal itcram_RVALID  : std_logic;
  signal itcram_RREADY  : std_logic;

  -- APB bus
  signal nvm_addr : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal nvm_wdata : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal nvm_wen : std_logic;
  signal nvm_byte_sel : std_logic_vector(REGISTER_SIZE/8 -1 downto 0);
  signal nvm_strb : std_logic;
  signal nvm_ack : std_logic;
  signal nvm_rdata : std_logic_vector(REGISTER_SIZE-1 downto 0);
  
  -- INSTR MUX
  signal SEL : std_logic;
  signal iram_addr : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal iram_wdata : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal iram_wen : std_logic;
  signal iram_byte_sel : std_logic_vector(REGISTER_SIZE/BYTE_SIZE -1 downto 0);
  signal iram_strb : std_logic;
  signal iram_ack : std_logic;
  signal iram_rdata : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal data_ram_addr : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal data_ram_wdata : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal data_ram_wen : std_logic;
  signal data_ram_byte_sel : std_logic_vector(REGISTER_SIZE/BYTE_SIZE -1 downto 0);
  signal data_ram_strb : std_logic;
  signal data_ram_ack : std_logic;
  signal data_ram_rdata : std_logic_vector(REGISTER_SIZE-1 downto 0);

  -- AXI Bus signals 
  signal ARESETN : std_logic;
  signal data_sel : std_logic;
  signal data_sel_prev : std_logic;

  constant BURST_LEN    : std_logic_vector(3 downto 0) := "0001";
  constant BURST_SIZE   : std_logic_vector(2 downto 0) := "010";
  constant BURST_FIXED  : std_logic_vector(1 downto 0) := "00";
  constant DATA_ACCESS  : std_logic_vector(2 downto 0) := "001";
  constant INSTR_ACCESS : std_logic_vector(2 downto 0) := "101"; 
  constant NORMAL_MEM   : std_logic_vector(3 downto 0) := "0011";

begin

  ARESETN <= not reset;

  rv : entity work.orca(rtl)
    generic map (
      REGISTER_SIZE         => REGISTER_SIZE,
			BYTE_SIZE							=> BYTE_SIZE,
      AVALON_ENABLE         => 0,
      WISHBONE_ENABLE       => 0,
      AXI_ENABLE            => 1,
      RESET_VECTOR          => RESET_VECTOR,
      MULTIPLY_ENABLE       => MULTIPLY_ENABLE,
      DIVIDE_ENABLE         => DIVIDE_ENABLE,
      SHIFTER_MAX_CYCLES    => SHIFTER_MAX_CYCLES,
      COUNTER_LENGTH        => COUNTER_LENGTH,
      ENABLE_EXCEPTIONS     => ENABLE_EXCEPTIONS,
      BRANCH_PREDICTORS     => BRANCH_PREDICTORS,
      PIPELINE_STAGES       => PIPELINE_STAGES,
      LVE_ENABLE            => LVE_ENABLE,
      ENABLE_EXT_INTERRUPTS => ENABLE_EXT_INTERRUPTS,
      NUM_EXT_INTERRUPTS    => NUM_EXT_INTERRUPTS,
      SCRATCHPAD_ADDR_BITS  => SCRATCHPAD_ADDR_BITS,
			TCRAM_SIZE						=> TCRAM_SIZE,
			POWER_OPTIMIZED				=> POWER_OPTIMIZED,
			CACHE_ENABLE 					=> 0,
      -- Hardcoded because string generics not supported by Libero
      FAMILY                => "MICROSEMI")
    port map (
      clk => clk,
      scratchpad_clk => clk_2x,
      reset => orca_reset, -- while the iram is being initialized, don't start

      avm_data_address              => OPEN, 
      avm_data_byteenable           => OPEN, 
      avm_data_read                 => OPEN, 
      avm_data_readdata             => (others => '-'), 
      avm_data_write                => OPEN, 
      avm_data_writedata            => OPEN, 
      avm_data_waitrequest          => '-', 
      avm_data_readdatavalid        => '-', 
                               
      avm_instruction_address       => OPEN, 
      avm_instruction_read          => OPEN, 
      avm_instruction_readdata      => OPEN, 
      avm_instruction_waitrequest   => '-', 
      avm_instruction_readdatavalid => OPEN, 
                          
      data_ADR_O                    => OPEN, 
      data_DAT_I                    => (others => '-'), 
      data_DAT_O                    => OPEN, 
      data_WE_O                     => OPEN, 
      data_SEL_O                    => OPEN, 
      data_STB_O                    => OPEN, 
      data_ACK_I                    => '-', 
      data_CYC_O                    => OPEN, 
      data_CTI_O                    => OPEN, 
      data_STALL_I                  => '-', 
                                 
      instr_ADR_O                   => OPEN, 
      instr_DAT_I                   => (others => '-'), 
      instr_STB_O                   => OPEN, 
      instr_ACK_I                   => '-', 
      instr_CYC_O                   => OPEN, 
      instr_CTI_O                   => OPEN, 
      instr_STALL_I                 => '-', 
                                  
      data_AWID                     => data_AWID, 
      data_AWADDR                   => data_AWADDR,
      data_AWLEN                    => data_AWLEN, 
      data_AWSIZE                   => data_AWSIZE, 
      data_AWBURST                  => data_AWBURST,
      data_AWLOCK                   => data_AWLOCK, 
      data_AWCACHE                  => data_AWCACHE,
      data_AWPROT                   => data_AWPROT, 
      data_AWVALID                  => data_AWVALID,
      data_AWREADY                  => data_AWREADY,
                               
      data_WID                      => data_WID, 
      data_WDATA                    => data_WDATA, 
      data_WSTRB                    => data_WSTRB, 
      data_WLAST                    => data_WLAST, 
      data_WVALID                   => data_WVALID, 
      data_WREADY                   => data_WREADY, 
                                   
      data_BID                      => data_BID, 
      data_BRESP                    => data_BRESP,
      data_BVALID                   => data_BVALID,
      data_BREADY                   => data_BREADY, 
                                 
      data_ARID                     => data_ARID, 
      data_ARADDR                   => data_ARADDR, 
      data_ARLEN                    => data_ARLEN, 
      data_ARSIZE                   => data_ARSIZE, 
      data_ARBURST                  => data_ARBURST, 
      data_ARLOCK                   => data_ARLOCK, 
      data_ARCACHE                  => data_ARCACHE, 
      data_ARPROT                   => data_ARPROT, 
      data_ARVALID                  => data_ARVALID, 
      data_ARREADY                  => data_ARREADY, 
                              
      data_RID                      => data_RID, 
      data_RDATA                    => data_RDATA, 
      data_RRESP                    => data_RRESP, 
      data_RLAST                    => data_RLAST, 
      data_RVALID                   => data_RVALID, 
      data_RREADY                   => data_RREADY, 
                                              
      itcram_ARID                   => itcram_ARID,     
      itcram_ARADDR                 => itcram_ARADDR,  
      itcram_ARLEN                  => itcram_ARLEN,   
      itcram_ARSIZE                 => itcram_ARSIZE,  
      itcram_ARBURST                => itcram_ARBURST, 
      itcram_ARLOCK                 => itcram_ARLOCK, 
      itcram_ARCACHE                => itcram_ARCACHE, 
      itcram_ARPROT                 => itcram_ARPROT,  
      itcram_ARVALID                => itcram_ARVALID, 
      itcram_ARREADY                => itcram_ARREADY, 
                                         
      itcram_RID                    => itcram_RID,
      itcram_RDATA                  => itcram_RDATA,
      itcram_RRESP                  => itcram_RRESP,
      itcram_RLAST                  => itcram_RLAST,
      itcram_RVALID                 => itcram_RVALID,
      itcram_RREADY                 => itcram_RREADY,
                                             
      itcram_AWID                   => itcram_AWID,
      itcram_AWADDR                 => itcram_AWADDR,
      itcram_AWLEN                  => itcram_AWLEN,
      itcram_AWSIZE                 => itcram_AWSIZE,
      itcram_AWBURST                => itcram_AWBURST,
      itcram_AWLOCK                 => itcram_AWLOCK,
      itcram_AWCACHE                => itcram_AWCACHE,
      itcram_AWPROT                 => itcram_AWPROT,
      itcram_AWVALID                => itcram_AWVALID,
      itcram_AWREADY                => itcram_AWREADY,
                                          
      itcram_WID                    => itcram_WID,
      itcram_WDATA                  => itcram_WDATA,
      itcram_WSTRB                  => itcram_WSTRB,
      itcram_WLAST                  => itcram_WLAST,
      itcram_WVALID                 => itcram_WVALID,
      itcram_WREADY                 => itcram_WREADY,
                                             
      itcram_BID                    => itcram_BID,
      itcram_BRESP                  => itcram_BRESP ,
      itcram_BVALID                 => itcram_BVALID,
      itcram_BREADY                 => itcram_BREADY,

      iram_ARID										  => OPEN,     
      iram_ARADDR                	  => OPEN,  
      iram_ARLEN                 	  => OPEN,   
      iram_ARSIZE                	  => OPEN,  
      iram_ARBURST               	  => OPEN, 
      iram_ARLOCK                	  => OPEN, 
      iram_ARCACHE               	  => OPEN, 
      iram_ARPROT                	  => OPEN,  
      iram_ARVALID               	  => OPEN, 
      iram_ARREADY               	  => '-', 
                                 	         
      iram_RID                   	  => (others => '-'),
      iram_RDATA                 	  => (others => '-'),
      iram_RRESP                 	  => (others => '-'),
      iram_RLAST                 	  => '-',
      iram_RVALID                	  => '-',
      iram_RREADY                	  => OPEN,
                                 	             
      iram_AWID                  	  => OPEN,
      iram_AWADDR                	  => OPEN,
      iram_AWLEN                 	  => OPEN,
      iram_AWSIZE                	  => OPEN,
      iram_AWBURST               	  => OPEN,
      iram_AWLOCK                	  => OPEN,
      iram_AWCACHE               	  => OPEN,
      iram_AWPROT                	  => OPEN,
      iram_AWVALID               	  => OPEN,
      iram_AWREADY               	  => '-',
                                 	          
      iram_WID                   	  => OPEN,
      iram_WDATA                 	  => OPEN,
      iram_WSTRB                 	  => OPEN, 
      iram_WLAST                 	  => OPEN,
      iram_WVALID                	  => OPEN,
      iram_WREADY                	  => '-',
                                 	             
      iram_BID                   	  => (others => '-'),
      iram_BRESP                 	  => (others => '-'),
      iram_BVALID                	  => '-',
      iram_BREADY                	  => OPEN,
                                
      avm_scratch_address           => (others => '-'), 
      avm_scratch_byteenable        => (others => '-'), 
      avm_scratch_read              => '-', 
      avm_scratch_readdata          => OPEN, 
      avm_scratch_write             => '-', 
      avm_scratch_writedata         => (others => '-'), 
      avm_scratch_waitrequest       => OPEN, 
      avm_scratch_readdatavalid     => OPEN, 
                                  
      sp_ADR_I                      => (others => '-'),
      sp_DAT_O                      => OPEN, 
      sp_DAT_I                      => (others => '-'), 
      sp_WE_I                       => '-', 
      sp_SEL_I                      => (others => '-'), 
      sp_STB_I                      => '-', 
      sp_ACK_O                      => OPEN, 
      sp_CYC_I                      => '-', 
      sp_CTI_I                      => (others => '-'),
      sp_STALL_O                    => OPEN, 
                        
      global_interrupts             => (others => '0')
    );

  mux : entity work.ram_mux(rtl)
    generic map (
      DATA_WIDTH => REGISTER_SIZE,
      ADDR_WIDTH => REGISTER_SIZE
    )
    port map (
      nvm_addr => nvm_addr,
      nvm_wdata => nvm_wdata,
      nvm_wen => nvm_wen,
      nvm_byte_sel => nvm_byte_sel,
      nvm_strb => nvm_strb,
      nvm_ack => nvm_ack,
      nvm_rdata => nvm_rdata,

      user_ARREADY => itcram_ARREADY,
      user_ARADDR => itcram_ARADDR,
      user_ARVALID => itcram_ARVALID,

      user_RREADY => itcram_RREADY,
      user_RDATA => itcram_RDATA, 
      user_RVALID => itcram_RVALID,
      
      user_AWADDR => itcram_AWADDR, 
      user_AWVALID => itcram_AWVALID,
      user_AWREADY => itcram_AWREADY, 

      user_WDATA => itcram_WDATA,
      user_WVALID => itcram_WVALID,

      user_BREADY => itcram_BREADY, 
      user_BVALID => itcram_BVALID,

      SEL => SEL,
      ram_addr => iram_addr,
      ram_wdata => iram_wdata, 
      ram_wen => iram_wen,
      ram_byte_sel => iram_byte_sel,
      ram_strb => iram_strb,
      ram_ack => iram_ack,
      ram_rdata => iram_rdata
    );

  apb_bus : entity work.apb_to_ram(rtl)
    generic map (
      REGISTER_SIZE => REGISTER_SIZE,
      RAM_SIZE => TCRAM_SIZE
    )
    port map (
      reset => reset,
      clk => clk,
      SEL => SEL,
      nvm_PADDR => nvm_PADDR,
      nvm_PENABLE => nvm_PENABLE,
      nvm_PWRITE => nvm_PWRITE,
      nvm_PRDATA => nvm_PRDATA,
      nvm_PWDATA => nvm_PWDATA,
      nvm_PREADY => nvm_PREADY,
      nvm_PSEL => nvm_PSEL,
      nvm_addr => nvm_addr,
      nvm_wdata => nvm_wdata,
      nvm_wen => nvm_wen,
      nvm_byte_sel => nvm_byte_sel,
      nvm_strb => nvm_strb,
      nvm_ack => nvm_ack,
      nvm_rdata => nvm_rdata
    );

  iram : entity work.iram(rtl)
    generic map (
      SIZE => TCRAM_SIZE,
      RAM_WIDTH => REGISTER_SIZE,
      BYTE_SIZE => BYTE_SIZE 
    )
    port map (
      clk => clk,
      reset => reset,

      addr => iram_addr,
      wdata => iram_wdata,
      wen => iram_wen,
      byte_sel => iram_byte_sel,
      strb => iram_strb,
      ack => iram_ack,
      rdata => iram_rdata,

      ram_AWID    => ram_AWID,   
      ram_AWADDR  => ram_AWADDR, 
      ram_AWLEN   => ram_AWLEN, 
      ram_AWSIZE  => ram_AWSIZE, 
      ram_AWBURST => ram_AWBURST,

      ram_AWLOCK  => ram_AWLOCK, 
      ram_AWCACHE => ram_AWCACHE,
      ram_AWPROT  => ram_AWPROT, 
      ram_AWVALID => ram_AWVALID,
      ram_AWREADY => ram_AWREADY,
                                
      ram_WID     => ram_WID,    
      ram_WDATA   => ram_WDATA,  
      ram_WSTRB   => ram_WSTRB,  
      ram_WLAST   => ram_WLAST,  
      ram_WVALID  => ram_WVALID, 
      ram_WREADY  => ram_WREADY, 
                                
      ram_BID     => ram_BID,    
      ram_BRESP   => ram_BRESP,  
      ram_BVALID  => ram_BVALID, 
      ram_BREADY  => ram_BREADY, 
                                
      ram_ARID    => ram_ARID,   
      ram_ARADDR  => ram_ARADDR, 
      ram_ARLEN   => ram_ARLEN,  
      ram_ARSIZE  => ram_ARSIZE, 
      ram_ARBURST => ram_ARBURST,
      ram_ARLOCK  => ram_ARLOCK, 
      ram_ARCACHE => ram_ARCACHE,
      ram_ARPROT  => ram_ARPROT, 
      ram_ARVALID => ram_ARVALID,
      ram_ARREADY => ram_ARREADY,
                                
      ram_RID     => ram_RID,    
      ram_RDATA   => ram_RDATA,  
      ram_RRESP   => ram_RRESP,  
      ram_RLAST   => ram_RLAST,  
      ram_RVALID  => ram_RVALID, 
      ram_RREADY  => ram_RREADY 
    );
  
  orca_reset <= reset or (not SEL);

end architecture rtl;
