library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.rv_components.all;

entity axi_master is
  generic (
    ADDR_WIDTH    : integer := 32;
    REGISTER_SIZE : integer := 32;
    BYTE_SIZE     : integer := 8
  );

  port (
    clk : in std_logic;
    aresetn : in std_logic;

    core_data_address : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    core_data_byteenable : in std_logic_vector(REGISTER_SIZE/BYTE_SIZE -1 downto 0);
    core_data_read : in std_logic;
    core_data_readdata : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    core_data_write : in std_logic;
    core_data_writedata : in std_logic_vector(REGISTER_SIZE-1 downto 0);
    core_data_ack : out std_logic;

    AWID : out std_logic_vector(3 downto 0);
    AWADDR : out std_logic_vector(ADDR_WIDTH-1 downto 0);
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
    ARADDR : out std_logic_vector(ADDR_WIDTH-1 downto 0);
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
    
end entity axi_master;

architecture rtl of axi_master is
  constant BURST_LEN    : std_logic_vector(3 downto 0) := "0000";
  constant BURST_SIZE   : std_logic_vector(2 downto 0) := "010";
  constant BURST_INCR   : std_logic_vector(1 downto 0) := "01";
  constant CACHE_VAL    : std_logic_vector(3 downto 0) := "0011";
  constant PROT_VAL     : std_logic_vector(2 downto 0) := "000";
  constant LOCK_VAL     : std_logic_vector(1 downto 0) := "00";

  type state_r_t is (IDLE, WAITING_AR, READ);
  type state_w_t is (IDLE, WAITING_AW, WAITING_W, WAITING_BOTH, WRITE); 

  signal state_r : state_r_t;
  signal state_w : state_w_t;
  signal next_state_r : state_r_t;
  signal next_state_w : state_w_t;

  signal latch_enable_r  : std_logic;
  signal latch_enable_aw : std_logic;
  signal latch_enable_w  : std_logic;

  signal core_data_address_r_l  : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal core_data_address_w_l  : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal core_data_writedata_l  : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal core_data_byteenable_l : std_logic_vector(REGISTER_SIZE/BYTE_SIZE-1 downto 0);

begin

  core_data_readdata <= RDATA;
  core_data_ack <= (RVALID and RLAST) or BVALID;

  AWID <= (others => '0');
  AWLEN <= BURST_LEN;
  AWSIZE <= BURST_SIZE;
  AWBURST <= BURST_INCR;
  AWLOCK <= LOCK_VAL;
  AWCACHE <= CACHE_VAL;
  AWPROT <= PROT_VAL;
  AWBURST <= BURST_INCR;

  WID <= (others => '0');

  ARID <= (others => '0');
  ARLEN <= BURST_LEN;
  ARSIZE <= BURST_SIZE;
  ARLOCK <= LOCK_VAL;
  ARCACHE <= CACHE_VAL;
  ARPROT <= PROT_VAL;
  ARBURST <= BURST_INCR; 

  -- By holding RREADY high, the READ bus will be flushed on startup. 
  RREADY <= '1';

  process(state_r, core_data_address, core_data_read, core_data_address_r_l,
          ARREADY, RVALID, RLAST)
  begin
    case(state_r) is
      when IDLE =>
        ARADDR <= core_data_address;
        ARVALID <= '0';
        --RREADY <= '0';
        latch_enable_r <= '0';
        next_state_r <= IDLE;
        if (core_data_read = '1') then
          latch_enable_r <= '1';
          ARVALID <= '1';
          if (ARREADY = '1') then
            next_state_r <= READ; 
          else
            next_state_r <= WAITING_AR;
          end if; 
        end if;
          
      when WAITING_AR =>
        ARADDR <= core_data_address_r_l;
        ARVALID <= '1';
        --RREADY <= '0';
        latch_enable_r <= '0';
        next_state_r <= WAITING_AR;
        if (ARREADY = '1') then
          next_state_r <= READ;
        end if;

      when READ =>
        ARADDR <= core_data_address;
        ARVALID <= '0';
        --RREADY <= '1';
        latch_enable_r <= '0';
        next_state_r <= READ;
        if ((RVALID = '1') and (RLAST = '1')) then
          if (core_data_read = '1') then
            ARVALID <= '1';
            if (ARREADY = '1') then
              next_state_r <= READ;
            else
              next_state_r <= WAITING_AR; 
            end if;
          else
            next_state_r <= IDLE;
          end if;
        end if;
    end case;
  end process;

  process(state_w, core_data_write, core_data_address, core_data_writedata, 
          core_data_byteenable, core_data_address_w_l, core_data_writedata_l, 
          core_data_byteenable_l, AWREADY, WREADY, BVALID)
  begin
    case(state_w) is
      when IDLE =>
        AWADDR <= core_data_address;
        WDATA <= core_data_writedata;
        WSTRB <= core_data_byteenable;
        WLAST <= '0';
        AWVALID <= '0';
        WVALID <= '0';
        BREADY <= '0';
        latch_enable_aw <= '0';
        latch_enable_w <= '0';
        next_state_w <= IDLE;
        if (core_data_write = '1') then
          latch_enable_aw <= '1';
          latch_enable_w <= '1';
          AWVALID <= '1';
          WVALID <= '1';
          WLAST <= '1';
          if ((AWREADY = '1') and (WREADY = '1')) then
            next_state_w <= WRITE;
          elsif (WREADY = '1') then
            next_state_w <= WAITING_AW;
          elsif (AWREADY = '1') then
            next_state_w <= WAITING_W;
          else
            next_state_w <= WAITING_BOTH; 
          end if;
        end if;

      when WAITING_AW =>
        AWADDR <= core_data_address_w_l;
        WDATA <= core_data_writedata_l;
        WSTRB <= core_data_byteenable_l;
        WLAST <= '0';
        AWVALID <= '1';
        WVALID <= '0';
        BREADY <= '0';
        latch_enable_aw <= '0';
        latch_enable_w <= '0';
        next_state_w <= WAITING_AW;
        if (AWREADY = '1') then
          next_state_w <= WRITE;
        end if;

      when WAITING_W =>
        AWADDR <= core_data_address_w_l;
        WDATA <= core_data_writedata_l;
        WSTRB <= core_data_byteenable_l;
        WLAST <= '1';
        AWVALID <= '0';
        WVALID <= '1';
        BREADY <= '0';
        latch_enable_aw <= '0';
        latch_enable_w <= '0';
        next_state_w <= WAITING_W;
        if (WREADY = '1') then
          next_state_w <= WRITE;
        end if;

      when WAITING_BOTH =>
        AWADDR <= core_data_address_w_l;
        WDATA <= core_data_writedata_l;
        WSTRB <= core_data_byteenable_l;
        WLAST <= '1';
        AWVALID <= '1';
        WVALID <= '1';
        BREADY <= '0';
        latch_enable_aw <= '0';
        latch_enable_w <= '0';
        next_state_w <= WAITING_BOTH;
        if ((AWREADY = '1') and (WREADY = '1')) then
          next_state_w <= WRITE;
        elsif (WREADY = '1') then
          next_state_w <= WAITING_AW;
        elsif (AWREADY = '1') then
          next_state_w <= WAITING_W;
        end if;
        
      when WRITE =>
        AWADDR <= core_data_address;
        WDATA <= core_data_writedata;
        WSTRB <= core_data_byteenable;
        WLAST <= '0';
        AWVALID <= '0';
        WVALID <= '0';
        BREADY <= '1';
        latch_enable_aw <= '0';
        latch_enable_w <= '0';
        next_state_w <= WRITE;
        if (BVALID = '1') then
          if (core_data_write = '1') then
            latch_enable_aw <= '1';
            latch_enable_w <= '1';
            AWVALID <= '1';
            WVALID <= '1';
            WLAST <= '1';
            if ((AWREADY = '1') and (WREADY = '1')) then
              next_state_w <= WRITE;
            elsif (WREADY = '1') then
              next_state_w <= WAITING_AW;
            elsif (AWREADY = '1') then
              next_state_w <= WAITING_W;
            else
              next_state_w <= WAITING_BOTH;
            end if;
          else
            next_state_w <= IDLE;
          end if;
        end if;
    end case;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if (aresetn = '0') then
        core_data_address_r_l <= (others => '0');
        core_data_address_w_l <= (others => '0');
        core_data_writedata_l <= (others => '0');
        core_data_byteenable_l <= (others => '0');
        state_r <= IDLE;
        state_w <= IDLE;
      else
        state_r <= next_state_r;
        state_w <= next_state_w;
        if (latch_enable_r = '1') then
          core_data_address_r_l <= core_data_address;
        end if;
        if (latch_enable_aw = '1') then
          core_data_address_w_l <= core_data_address;
        end if;
        if (latch_enable_w = '1') then
          core_data_writedata_l <= core_data_writedata;
          core_data_byteenable_l <= core_data_byteenable;
        end if;
      end if;
    end if;
  end process;

end architecture;
