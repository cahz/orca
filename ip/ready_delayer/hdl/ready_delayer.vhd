-- ready_delayer.vhd
-- Copyright (C) 2018 VectorBlox Computing, Inc.

-------------------------------------------------------------------------------
-- This component delays ready/valid pairs in an AXI-compatible way
-------------------------------------------------------------------------------


-- synthesis library ready_delayer_lib
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ready_delayer is
  generic (
    READY_VALID_PAIRS : positive range 1 to 8 := 1;

    C_S_AXI_DATA_WIDTH : integer := 32;
    C_S_AXI_ADDR_WIDTH : integer := 32
    );
  port (
    S_AXI_ACLK    : in std_logic;
    S_AXI_ARESETN : in std_logic;

    S_AXI_AWADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_AWVALID : in  std_logic;
    S_AXI_AWREADY : out std_logic;

    S_AXI_WDATA  : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_WSTRB  : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    S_AXI_WVALID : in  std_logic;
    S_AXI_WREADY : out std_logic;

    S_AXI_BREADY : in  std_logic;
    S_AXI_BRESP  : out std_logic_vector(1 downto 0);
    S_AXI_BVALID : out std_logic;

    S_AXI_ARADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_ARVALID : in  std_logic;
    S_AXI_ARREADY : out std_logic;

    S_AXI_RREADY : in  std_logic;
    S_AXI_RDATA  : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_RRESP  : out std_logic_vector(1 downto 0);
    S_AXI_RVALID : out std_logic;

    valid0_in  : in  std_logic;
    ready0_in  : in  std_logic;
    valid0_out : out std_logic;
    ready0_out : out std_logic;

    valid1_in  : in  std_logic;
    ready1_in  : in  std_logic;
    valid1_out : out std_logic;
    ready1_out : out std_logic;

    valid2_in  : in  std_logic;
    ready2_in  : in  std_logic;
    valid2_out : out std_logic;
    ready2_out : out std_logic;

    valid3_in  : in  std_logic;
    ready3_in  : in  std_logic;
    valid3_out : out std_logic;
    ready3_out : out std_logic;

    valid4_in  : in  std_logic;
    ready4_in  : in  std_logic;
    valid4_out : out std_logic;
    ready4_out : out std_logic;

    valid5_in  : in  std_logic;
    ready5_in  : in  std_logic;
    valid5_out : out std_logic;
    ready5_out : out std_logic;

    valid6_in  : in  std_logic;
    ready6_in  : in  std_logic;
    valid6_out : out std_logic;
    ready6_out : out std_logic;

    valid7_in  : in  std_logic;
    ready7_in  : in  std_logic;
    valid7_out : out std_logic;
    ready7_out : out std_logic
    );
end;

architecture rtl of ready_delayer is
  constant LOG2_MAX_READY_VALID_PAIRS : positive := 3;
  constant MAX_READY_VALID_PAIRS      : positive := 2**LOG2_MAX_READY_VALID_PAIRS;

  constant LOG2_REGISTERS   : positive := LOG2_MAX_READY_VALID_PAIRS;
  signal axi_write_register : unsigned(LOG2_REGISTERS-1 downto 0);
  signal axi_read_register  : unsigned(LOG2_REGISTERS-1 downto 0);

  constant DELAY_MASK_BITS : positive range 1 to 31                       := 16;
  constant DONT_DELAY      : std_logic_vector(DELAY_MASK_BITS-1 downto 0) := (others => '0');
  subtype delay_mask_type is std_logic_vector(DELAY_MASK_BITS-1 downto 0);
  type delay_mask_vector is array (natural range <>) of delay_mask_type;
  signal delay_mask        : delay_mask_vector(MAX_READY_VALID_PAIRS-1 downto 0);
  signal random_delay      : std_logic_vector(MAX_READY_VALID_PAIRS-1 downto 0);

  signal counter       : unsigned(DELAY_MASK_BITS-1 downto 0);
  signal lfsr32        : std_logic_vector(31 downto 0);
  signal delay_channel : std_logic_vector(MAX_READY_VALID_PAIRS-1 downto 0);

  signal valid_in  : std_logic_vector(MAX_READY_VALID_PAIRS-1 downto 0);
  signal ready_in  : std_logic_vector(MAX_READY_VALID_PAIRS-1 downto 0);
  signal valid_out : std_logic_vector(MAX_READY_VALID_PAIRS-1 downto 0);
  signal ready_out : std_logic_vector(MAX_READY_VALID_PAIRS-1 downto 0);

  signal S_AXI_AWREADY_signal : std_logic;
  signal S_AXI_WREADY_signal  : std_logic;
  signal S_AXI_BVALID_signal  : std_logic;
  signal S_AXI_ARREADY_signal : std_logic;
  signal S_AXI_RVALID_signal  : std_logic;
begin
  S_AXI_AWREADY <= S_AXI_AWREADY_signal;
  S_AXI_WREADY  <= S_AXI_WREADY_signal;
  S_AXI_BVALID  <= S_AXI_BVALID_signal;
  S_AXI_ARREADY <= S_AXI_ARREADY_signal;
  S_AXI_RVALID  <= S_AXI_RVALID_signal;

  --Half throughput (not checking for BREADY/RREADY) but makes timing better
  S_AXI_AWREADY_signal <= S_AXI_WVALID and (not S_AXI_BVALID_signal);
  S_AXI_WREADY_signal  <= S_AXI_AWVALID and (not S_AXI_BVALID_signal);
  S_AXI_ARREADY_signal <= (not S_AXI_RVALID_signal);
  S_AXI_BRESP          <= (others => '0');
  S_AXI_RRESP          <= (others => '0');

  axi_write_register <= unsigned(S_AXI_AWADDR(LOG2_REGISTERS+1 downto 2));
  axi_read_register  <= unsigned(S_AXI_ARADDR(LOG2_REGISTERS+1 downto 2));

  process (S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
      if S_AXI_RREADY = '1' then
        S_AXI_RVALID_signal <= '0';
      end if;
      if S_AXI_BREADY = '1' then
        S_AXI_BVALID_signal <= '0';
      end if;

      if S_AXI_ARVALID = '1' and S_AXI_ARREADY_signal = '1' then
        S_AXI_RVALID_signal                     <= '1';
        S_AXI_RDATA                             <= (others => '0');
        S_AXI_RDATA(DELAY_MASK_BITS-1 downto 0) <= delay_mask(to_integer(axi_read_register));
        S_AXI_RDATA(31)                         <= random_delay(to_integer(axi_read_register));
      end if;

      if S_AXI_AWVALID = '1' and S_AXI_AWREADY_signal = '1' and S_AXI_WVALID = '1' and S_AXI_WREADY_signal = '1' then
        S_AXI_BVALID_signal                          <= '1';
        delay_mask(to_integer(axi_write_register))   <= S_AXI_WDATA(DELAY_MASK_BITS-1 downto 0);
        random_delay(to_integer(axi_write_register)) <= S_AXI_WDATA(31);
      end if;

      if S_AXI_ARESETN = '0' then
        delay_mask          <= (others => (others => '0'));
        random_delay        <= (others => '0');
        S_AXI_RVALID_signal <= '0';
        S_AXI_BVALID_signal <= '0';
      end if;
    end if;
  end process;

  process (S_AXI_ACLK) is
  begin
    if rising_edge(S_AXI_ACLK) then
      counter <= counter + to_unsigned(1, counter'length);

      --taps = 31, 29, 25, 24
      lfsr32(lfsr32'left-1 downto 0) <= lfsr32(lfsr32'left downto 1);
      lfsr32(lfsr32'left)            <= lfsr32(0);
      lfsr32(lfsr32'left-2)          <= lfsr32(lfsr32'left-1) xor lfsr32(0);
      lfsr32(lfsr32'left-6)          <= lfsr32(lfsr32'left-5) xor lfsr32(0);
      lfsr32(lfsr32'left-8)          <= lfsr32(lfsr32'left-7) xor lfsr32(0);

      delay_channel <= (others => '1');
      for ichannel in MAX_READY_VALID_PAIRS-1 downto 0 loop
        if random_delay(ichannel) = '1' then
          if (lfsr32(DELAY_MASK_BITS-1 downto 0) and delay_mask(ichannel)) = DONT_DELAY then
            delay_channel(ichannel) <= '0';
          end if;
        else
          if (std_logic_vector(counter) and delay_mask(ichannel)) = DONT_DELAY then
            delay_channel(ichannel) <= '0';
          end if;
        end if;

        --Illegal to deassert valid in mid-transaction
        if valid_out(ichannel) = '1' and ready_in(ichannel) = '0' then
          delay_channel(ichannel) <= '0';
        end if;
      end loop;  -- ichannel

      if S_AXI_ARESETN = '0' then
        counter <= to_unsigned(0, counter'length);
        lfsr32  <= (others => '1');
      end if;
    end if;
  end process;

  channel_gen : for gchannel in MAX_READY_VALID_PAIRS-1 downto 0 generate
    valid_out(gchannel) <= valid_in(gchannel) and (not delay_channel(gchannel));
    ready_out(gchannel) <= ready_in(gchannel) and (not delay_channel(gchannel));
  end generate channel_gen;

  valid_in(0) <= valid0_in;
  ready_in(0) <= ready0_in;
  valid0_out  <= valid_out(0);
  ready0_out  <= ready_out(0);

  valid_in(1) <= valid1_in;
  ready_in(1) <= ready1_in;
  valid1_out  <= valid_out(1);
  ready1_out  <= ready_out(1);

  valid_in(2) <= valid2_in;
  ready_in(2) <= ready2_in;
  valid2_out  <= valid_out(2);
  ready2_out  <= ready_out(2);

  valid_in(3) <= valid3_in;
  ready_in(3) <= ready3_in;
  valid3_out  <= valid_out(3);
  ready3_out  <= ready_out(3);

  valid_in(4) <= valid4_in;
  ready_in(4) <= ready4_in;
  valid4_out  <= valid_out(4);
  ready4_out  <= ready_out(4);

  valid_in(5) <= valid5_in;
  ready_in(5) <= ready5_in;
  valid5_out  <= valid_out(5);
  ready5_out  <= ready_out(5);

  valid_in(6) <= valid6_in;
  ready_in(6) <= ready6_in;
  valid6_out  <= valid_out(6);
  ready6_out  <= ready_out(6);

  valid_in(7) <= valid7_in;
  ready_in(7) <= ready7_in;
  valid7_out  <= valid_out(7);
  ready7_out  <= ready_out(7);

end rtl;
