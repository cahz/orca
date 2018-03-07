library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.utils.all;
use work.rv_components.all;
use work.constants_pkg.all;

-------------------------------------------------------------------------------
-- AXI master from OIMM master.
-------------------------------------------------------------------------------

entity axi_master is
  generic (
    ADDRESS_WIDTH            : positive;
    DATA_WIDTH               : positive;
    ID_WIDTH                 : positive;
    LOG2_BURSTLENGTH         : positive;
    MAX_OUTSTANDING_REQUESTS : natural;
    REQUEST_REGISTER         : request_register_type;
    RETURN_REGISTER          : boolean
    );
  port (
    clk     : in std_logic;
    reset   : in std_logic;
    aresetn : in std_logic;

    master_idle : out std_logic;

    --ORCA-internal memory-mapped slave
    oimm_address            : in  std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    oimm_burstlength_minus1 : in  std_logic_vector(LOG2_BURSTLENGTH-1 downto 0);
    oimm_byteenable         : in  std_logic_vector((DATA_WIDTH/8)-1 downto 0);
    oimm_requestvalid       : in  std_logic;
    oimm_readnotwrite       : in  std_logic;
    oimm_writedata          : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    oimm_writelast          : in  std_logic;
    oimm_readdata           : out std_logic_vector(DATA_WIDTH-1 downto 0);
    oimm_readdatavalid      : out std_logic;
    oimm_waitrequest        : out std_logic;

    --AXI memory-mapped master
    AWID    : out std_logic_vector(ID_WIDTH-1 downto 0);
    AWADDR  : out std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    AWLEN   : out std_logic_vector(LOG2_BURSTLENGTH-1 downto 0);
    AWSIZE  : out std_logic_vector(2 downto 0);
    AWBURST : out std_logic_vector(1 downto 0);
    AWLOCK  : out std_logic_vector(1 downto 0);
    AWCACHE : out std_logic_vector(3 downto 0);
    AWPROT  : out std_logic_vector(2 downto 0);
    AWVALID : out std_logic;
    AWREADY : in  std_logic;

    WID    : out std_logic_vector(ID_WIDTH-1 downto 0);
    WSTRB  : out std_logic_vector((DATA_WIDTH/8)-1 downto 0);
    WVALID : out std_logic;
    WLAST  : out std_logic;
    WDATA  : out std_logic_vector(DATA_WIDTH-1 downto 0);
    WREADY : in  std_logic;

    BID    : in  std_logic_vector(ID_WIDTH-1 downto 0);
    BRESP  : in  std_logic_vector(1 downto 0);
    BVALID : in  std_logic;
    BREADY : out std_logic;

    ARID    : out std_logic_vector(ID_WIDTH-1 downto 0);
    ARADDR  : out std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    ARLEN   : out std_logic_vector(LOG2_BURSTLENGTH-1 downto 0);
    ARSIZE  : out std_logic_vector(2 downto 0);
    ARBURST : out std_logic_vector(1 downto 0);
    ARLOCK  : out std_logic_vector(1 downto 0);
    ARCACHE : out std_logic_vector(3 downto 0);
    ARPROT  : out std_logic_vector(2 downto 0);
    ARVALID : out std_logic;
    ARREADY : in  std_logic;

    RID    : in  std_logic_vector(ID_WIDTH-1 downto 0);
    RDATA  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    RRESP  : in  std_logic_vector(1 downto 0);
    RLAST  : in  std_logic;
    RVALID : in  std_logic;
    RREADY : out std_logic
    );
end entity axi_master;

architecture rtl of axi_master is
  constant BURST_INCR : std_logic_vector(1 downto 0) := "01";
  constant CACHE_VAL  : std_logic_vector(3 downto 0) := "0011";
  constant PROT_VAL   : std_logic_vector(2 downto 0) := "000";
  constant LOCK_VAL   : std_logic_vector(1 downto 0) := "00";

  signal register_idle  : std_logic;
  signal throttler_idle : std_logic;

  signal registered_oimm_address            : std_logic_vector(ADDRESS_WIDTH-1 downto 0);
  signal registered_oimm_burstlength_minus1 : std_logic_vector(LOG2_BURSTLENGTH-1 downto 0);
  signal registered_oimm_byteenable         : std_logic_vector((DATA_WIDTH/8)-1 downto 0);
  signal registered_oimm_requestvalid       : std_logic;
  signal registered_oimm_readnotwrite       : std_logic;
  signal registered_oimm_writedata          : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal registered_oimm_writelast          : std_logic;
  signal unregistered_oimm_readdata         : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal unregistered_oimm_readdatavalid    : std_logic;
  signal unregistered_oimm_waitrequest      : std_logic;

  signal unthrottled_oimm_readcomplete  : std_logic;
  signal unthrottled_oimm_writecomplete : std_logic;
  signal unthrottled_oimm_waitrequest   : std_logic;
  signal throttled_oimm_requestvalid    : std_logic;

  signal AWVALID_signal : std_logic;
  signal WVALID_signal  : std_logic;
  signal aw_sending     : std_logic;
  signal aw_sent        : std_logic;
  signal w_sending      : std_logic;
  signal w_sent         : std_logic;
begin
  master_idle <= register_idle and throttler_idle;

  -----------------------------------------------------------------------------
  -- Optional OIMM register
  -----------------------------------------------------------------------------
  optional_oimm_register : oimm_register
    generic map (
      ADDRESS_WIDTH    => ADDRESS_WIDTH,
      DATA_WIDTH       => DATA_WIDTH,
      LOG2_BURSTLENGTH => LOG2_BURSTLENGTH,
      REQUEST_REGISTER => REQUEST_REGISTER,
      RETURN_REGISTER  => RETURN_REGISTER
      )
    port map (
      clk   => clk,
      reset => reset,

      register_idle => register_idle,

      --ORCA-internal memory-mapped slave
      slave_oimm_address            => oimm_address,
      slave_oimm_burstlength_minus1 => oimm_burstlength_minus1,
      slave_oimm_byteenable         => oimm_byteenable,
      slave_oimm_requestvalid       => oimm_requestvalid,
      slave_oimm_readnotwrite       => oimm_readnotwrite,
      slave_oimm_writedata          => oimm_writedata,
      slave_oimm_writelast          => oimm_writelast,
      slave_oimm_readdata           => oimm_readdata,
      slave_oimm_readdatavalid      => oimm_readdatavalid,
      slave_oimm_waitrequest        => oimm_waitrequest,

      --ORCA-internal memory-mapped master
      master_oimm_address            => registered_oimm_address,
      master_oimm_burstlength_minus1 => registered_oimm_burstlength_minus1,
      master_oimm_byteenable         => registered_oimm_byteenable,
      master_oimm_requestvalid       => registered_oimm_requestvalid,
      master_oimm_readnotwrite       => registered_oimm_readnotwrite,
      master_oimm_writedata          => registered_oimm_writedata,
      master_oimm_writelast          => registered_oimm_writelast,
      master_oimm_readdata           => unregistered_oimm_readdata,
      master_oimm_readdatavalid      => unregistered_oimm_readdatavalid,
      master_oimm_waitrequest        => unregistered_oimm_waitrequest
      );

  -----------------------------------------------------------------------------
  -- Optional OIMM request throttler
  -----------------------------------------------------------------------------
  request_throttler : oimm_throttler
    generic map (
      MAX_OUTSTANDING_REQUESTS => MAX_OUTSTANDING_REQUESTS,
      READ_WRITE_FENCE         => true --AXI lacks intra-channel ordering
      )
    port map (
      clk   => clk,
      reset => reset,

      throttler_idle => throttler_idle,

      --ORCA-internal memory-mapped slave
      slave_oimm_requestvalid => registered_oimm_requestvalid,
      slave_oimm_readnotwrite => registered_oimm_readnotwrite,
      slave_oimm_writelast    => registered_oimm_writelast,
      slave_oimm_waitrequest  => unregistered_oimm_waitrequest,

      --ORCA-internal memory-mapped master
      master_oimm_requestvalid  => throttled_oimm_requestvalid,
      master_oimm_readcomplete  => unthrottled_oimm_readcomplete,
      master_oimm_writecomplete => unthrottled_oimm_writecomplete,
      master_oimm_waitrequest   => unthrottled_oimm_waitrequest
      );


  -----------------------------------------------------------------------------
  -- OIMM to AXI logic
  -----------------------------------------------------------------------------
  unthrottled_oimm_readcomplete  <= RVALID and RLAST;
  unthrottled_oimm_writecomplete <= BVALID;

  unregistered_oimm_readdata      <= RDATA;
  unregistered_oimm_readdatavalid <= RVALID;

  unthrottled_oimm_waitrequest <= (not ARREADY) when registered_oimm_readnotwrite = '1' else
                                  (((not AWREADY) and (not aw_sent) and (registered_oimm_writelast or w_sent)) or
                                   ((not WREADY) and (not w_sent)));

  AWID           <= (others => '0');
  AWADDR         <= registered_oimm_address;
  AWLEN          <= registered_oimm_burstlength_minus1;
  AWSIZE         <= std_logic_vector(to_unsigned(log2(DATA_WIDTH/8), 3));
  AWBURST        <= BURST_INCR;
  AWLOCK         <= LOCK_VAL;
  AWCACHE        <= CACHE_VAL;
  AWPROT         <= PROT_VAL;
  AWVALID_signal <= (throttled_oimm_requestvalid and (not registered_oimm_readnotwrite)) and (not aw_sent);
  AWVALID        <= AWVALID_signal;
  WID            <= (others => '0');
  WSTRB          <= registered_oimm_byteenable;
  WVALID_signal  <= (throttled_oimm_requestvalid and (not registered_oimm_readnotwrite)) and (not w_sent);
  WVALID         <= WVALID_signal;
  WLAST          <= registered_oimm_writelast;
  WDATA          <= registered_oimm_writedata;
  BREADY         <= '1';

  ARID    <= (others => '0');
  ARADDR  <= registered_oimm_address;
  ARLEN   <= registered_oimm_burstlength_minus1;
  ARSIZE  <= std_logic_vector(to_unsigned(log2(DATA_WIDTH/8), 3));
  ARBURST <= BURST_INCR;
  ARLOCK  <= LOCK_VAL;
  ARCACHE <= CACHE_VAL;
  ARPROT  <= PROT_VAL;
  ARVALID <= registered_oimm_readnotwrite and throttled_oimm_requestvalid;
  RREADY  <= '1';

  aw_sending <= AWVALID_signal and AWREADY;
  w_sending  <= WVALID_signal and registered_oimm_writelast and WREADY;
  process (clk) is
  begin
    if rising_edge(clk) then
      if aw_sending = '1' then
        if w_sent = '1' or w_sending = '1' then
          aw_sent <= '0';
          w_sent  <= '0';
        else
          aw_sent <= '1';
        end if;
      end if;
      if w_sending = '1' then
        if aw_sent = '1' or aw_sending = '1' then
          w_sent  <= '0';
          aw_sent <= '0';
        else
          w_sent <= '1';
        end if;
      end if;

      if aresetn = '0' then
        aw_sent <= '0';
        w_sent  <= '0';
      end if;
    end if;
  end process;
end architecture;
