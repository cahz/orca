-- axi_bram.vhd
-- Copyright (C) 2016 VectorBlox Computing, Inc.
--
-- AXI-4 BRAM slave

-- synthesis library axi_bram_lib
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;


entity axi_bram is
  generic (
    LOG2_DEPTH_BYTES   : integer := 13;
    C_S_AXI_ADDR_WIDTH : integer := 32;
    C_S_AXI_DATA_WIDTH : integer := 32;

    -- 8 for AXI4, 4 for AXI3. Determines size of arlen/awlen ports on AXI master.
    C_S_AXI_LEN_WIDTH : integer := 8
    );
  port(
    clk    : in std_logic;
    resetn : in std_logic;

    -- AXI3/4 Slave
    s_axi_arready : buffer std_logic;
    s_axi_arvalid : in     std_logic;
    s_axi_araddr  : in     std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    s_axi_arlen   : in     std_logic_vector(C_S_AXI_LEN_WIDTH-1 downto 0);
    s_axi_arsize  : in     std_logic_vector(2 downto 0);
    s_axi_arburst : in     std_logic_vector(1 downto 0);
    s_axi_arprot  : in     std_logic_vector(2 downto 0);
    s_axi_arcache : in     std_logic_vector(3 downto 0);

    s_axi_rready : in  std_logic;
    s_axi_rvalid : out std_logic;
    s_axi_rdata  : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    s_axi_rresp  : out std_logic_vector(1 downto 0);
    s_axi_rlast  : out std_logic;

    s_axi_awready : buffer std_logic;
    s_axi_awvalid : in     std_logic;
    s_axi_awaddr  : in     std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    s_axi_awlen   : in     std_logic_vector(C_S_AXI_LEN_WIDTH-1 downto 0);
    s_axi_awsize  : in     std_logic_vector(2 downto 0);
    s_axi_awburst : in     std_logic_vector(1 downto 0);
    s_axi_awprot  : in     std_logic_vector(2 downto 0);
    s_axi_awcache : in     std_logic_vector(3 downto 0);

    s_axi_wready : buffer std_logic;
    s_axi_wvalid : in     std_logic;
    s_axi_wdata  : in     std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    s_axi_wstrb  : in     std_logic_vector((C_S_AXI_DATA_WIDTH)/8 - 1 downto 0);
    s_axi_wlast  : in     std_logic;

    s_axi_bready : in     std_logic;
    s_axi_bvalid : buffer std_logic;
    s_axi_bresp  : out    std_logic_vector(1 downto 0)
    );
end entity axi_bram;

architecture rtl of axi_bram is
  component sp_bram is
    generic (
      LOG2_DEPTH : positive := 10;
      WIDTH      : positive := 8
      );
    port(
      clk : in std_logic;

      write_address : in unsigned(LOG2_DEPTH-1 downto 0);
      write_enable  : in std_logic;
      write_data    : in std_logic_vector(WIDTH-1 downto 0);

      read_address : in  unsigned(LOG2_DEPTH-1 downto 0);
      read_data    : out std_logic_vector(WIDTH-1 downto 0)
      );
  end component sp_bram;

  function log2(
    constant N : integer)
    return integer is
    variable i : integer := 0;
  begin
    while (2**i < n) loop
      i := i + 1;
    end loop;
    return i;
  end log2;

  constant DEPTH : positive := 2**(LOG2_DEPTH_BYTES-log2(C_S_AXI_DATA_WIDTH/8));

  constant AXI_RESP_OKAY     : std_logic_vector(1 downto 0) := "00";
  signal write_address_valid : std_logic;
  signal write_address       : unsigned(log2(DEPTH)-1 downto 0);

  signal write_data_valid : std_logic;
  signal write_data_last  : std_logic;
  signal write_data       : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  signal write_byteenable : std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);

  signal ram_write        : std_logic;
  signal ram_write_enable : std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);

  signal read_address_valid : std_logic;
  signal read_address_ready : std_logic;
  signal read_address_last  : std_logic;
  signal read_address       : unsigned(log2(DEPTH)-1 downto 0);

  signal read_data_valid : std_logic;
  signal read_data_last  : std_logic;
  signal read_data       : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);

  signal latched_data_valid : std_logic;
  signal latched_data       : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);

  signal read_length : unsigned(C_S_AXI_LEN_WIDTH-1 downto 0);
begin
  s_axi_bresp <= AXI_RESP_OKAY;

  s_axi_awready <= resetn and ((not write_address_valid) or (ram_write and write_data_last));
  s_axi_wready  <= resetn and ((not write_data_valid) or ram_write);

  process (clk) is
  begin  -- process
    if clk'event and clk = '1' then     -- rising clock edge
      if s_axi_bready = '1' then
        s_axi_bvalid <= '0';
      end if;

      if ram_write = '1' then
        write_data_valid <= '0';
        write_address    <= write_address + to_unsigned(1, write_address'length);
        if write_data_last = '1' then
          write_address_valid <= '0';
          s_axi_bvalid        <= '1';
        end if;
      end if;

      if s_axi_wvalid = '1' and s_axi_wready = '1' then
        write_data_valid <= '1';
        write_data_last  <= s_axi_wlast;
        write_data       <= s_axi_wdata;
        write_byteenable <= s_axi_wstrb;
      end if;

      if s_axi_awvalid = '1' and s_axi_awready = '1' then
        write_address_valid <= '1';
        write_address       <= unsigned(s_axi_awaddr(LOG2_DEPTH_BYTES-1 downto log2(C_S_AXI_DATA_WIDTH/8)));
      end if;

      if resetn = '0' then              -- synchronous reset (active low)
        s_axi_bvalid        <= '0';
        write_address_valid <= '0';
        write_data_valid    <= '0';
        write_data_last     <= '0';
      end if;
    end if;
  end process;

  ram_write <= write_address_valid and write_data_valid and ((not write_data_last) or ((not s_axi_bvalid) or s_axi_bready));


  s_axi_arready <= resetn and ((not read_address_valid) or (read_address_ready and read_address_last));

  process (clk) is
  begin  -- process
    if clk'event and clk = '1' then     -- rising clock edge
      if read_address_valid = '1' and read_address_ready = '1' then
        read_address <= read_address + to_unsigned(1, read_address'length);
        if read_address_last = '1' then
          read_address_valid <= '0';
        end if;
        if read_length = to_unsigned(0, read_length'length) then
          read_address_last <= '1';
        end if;
        read_length <= read_length - to_unsigned(1, read_length'length);
      end if;

      if s_axi_arvalid = '1' and s_axi_arready = '1' then
        read_address_valid <= '1';
        read_address       <= unsigned(s_axi_araddr(LOG2_DEPTH_BYTES-1 downto log2(C_S_AXI_DATA_WIDTH/8)));
        if unsigned(s_axi_arlen) = to_unsigned(0, s_axi_arlen'length) then
          read_address_last <= '1';
        else
          read_address_last <= '0';
        end if;
        read_length <= unsigned(s_axi_arlen) - to_unsigned(1, read_length'length);
      end if;

      if resetn = '0' then              -- synchronous reset (active low)
        read_address_valid <= '0';
        read_address_last  <= '0';
      end if;
    end if;
  end process;

  ram_gen : for gbyte in (C_S_AXI_DATA_WIDTH/8)-1 downto 0 generate
    ram_write_enable(gbyte) <= write_byteenable(gbyte) and ram_write;
    byte_ram : sp_bram
      generic map (
        LOG2_DEPTH => log2(DEPTH),
        WIDTH      => 8
        )
      port map (
        clk => clk,

        write_address => write_address,
        write_enable  => ram_write_enable(gbyte),
        write_data    => write_data(((gbyte+1)*8)-1 downto gbyte*8),

        read_address => read_address,
        read_data    => read_data(((gbyte+1)*8)-1 downto gbyte*8)
        );
  end generate ram_gen;

  read_address_ready <= (not read_data_valid) or s_axi_rready;

  process (clk) is
  begin  -- process
    if clk'event and clk = '1' then     -- rising clock edge
      if read_data_valid <= '1' then
        latched_data_valid <= '1';
      end if;

      if s_axi_rready = '1' then
        read_data_valid <= '0';
      end if;

      if read_address_valid = '1' and read_address_ready = '1' then
        latched_data_valid <= '0';
        read_data_valid    <= '1';
        read_data_last     <= read_address_last;
      end if;

      if latched_data_valid = '0' then
        latched_data <= read_data;
      end if;

      if resetn = '0' then              -- synchronous reset (active low)
        read_data_valid    <= '0';
        read_data_last     <= '0';
        latched_data_valid <= '0';
      end if;
    end if;
  end process;

  s_axi_rvalid <= read_data_valid;
  s_axi_rdata  <= latched_data when latched_data_valid = '1' else read_data;
  s_axi_rresp  <= AXI_RESP_OKAY;
  s_axi_rlast  <= read_data_last;

end architecture rtl;

