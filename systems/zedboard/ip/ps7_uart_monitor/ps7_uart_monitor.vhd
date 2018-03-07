-- ps7_uart_monitor.vhd
--
-- Monitor the PS7 interface, print to console in simulation, and
-- return valid readdata if the UART is being bypassed.
-- If bypass is hardwired to 0 should get trivially synthesized away.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library STD;
use STD.textio.all;                     -- basic I/O

entity ps7_uart_monitor is
  generic (
    C_S_AXI_ADDR_WIDTH : integer := 32;
    C_S_AXI_DATA_WIDTH : integer := 32;

    C_M_AXI_ADDR_WIDTH : integer := 32;
    C_M_AXI_DATA_WIDTH : integer := 32
    );
  port (
    bypass : in std_logic;

    axi_aclk    : in std_logic;
    axi_aresetn : in std_logic;

    -- AXI4-Lite Slave
    s_axi_awaddr  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    s_axi_awvalid : in  std_logic;
    s_axi_awready : out std_logic;

    s_axi_wdata  : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    s_axi_wstrb  : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    s_axi_wvalid : in  std_logic;
    s_axi_wready : out std_logic;

    s_axi_bready : in  std_logic;
    s_axi_bresp  : out std_logic_vector(1 downto 0);
    s_axi_bvalid : out std_logic;

    s_axi_araddr  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    s_axi_arvalid : in  std_logic;
    s_axi_arready : out std_logic;

    s_axi_rready : in  std_logic;
    s_axi_rdata  : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    s_axi_rresp  : out std_logic_vector(1 downto 0);
    s_axi_rvalid : out std_logic;

    m_axi_awaddr  : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
    m_axi_awvalid : out std_logic;
    m_axi_awready : in  std_logic;

    m_axi_wdata  : out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
    m_axi_wstrb  : out std_logic_vector((C_M_AXI_DATA_WIDTH/8)-1 downto 0);
    m_axi_wvalid : out std_logic;
    m_axi_wready : in  std_logic;

    m_axi_bready : out std_logic;
    m_axi_bresp  : in  std_logic_vector(1 downto 0);
    m_axi_bvalid : in  std_logic;

    m_axi_araddr  : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
    m_axi_arvalid : out std_logic;
    m_axi_arready : in  std_logic;

    m_axi_rready : out std_logic;
    m_axi_rdata  : in  std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
    m_axi_rresp  : in  std_logic_vector(1 downto 0);
    m_axi_rvalid : in  std_logic
    );
end entity ps7_uart_monitor;

architecture rtl of ps7_uart_monitor is
  signal bypass_rvalid : std_logic;
  signal full_lfsr     : std_logic_vector(7 downto 0);
  signal empty_lfsr    : std_logic_vector(7 downto 0);
  signal bypass_rdata  : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  signal bypass_bvalid : std_logic;
begin  -- architecture rtl
  s_axi_awready <= m_axi_awready when bypass = '0' else s_axi_wvalid;
  s_axi_wready  <= m_axi_wready  when bypass = '0' else s_axi_awvalid;
  s_axi_bresp   <= m_axi_bresp   when bypass = '0' else (others => '0');
  s_axi_bvalid  <= m_axi_bvalid  when bypass = '0' else bypass_bvalid;
  s_axi_arready <= m_axi_arready when bypass = '0' else '1';

  s_axi_rdata <= m_axi_rdata when bypass = '0' else bypass_rdata;

  s_axi_rresp   <= m_axi_rresp   when bypass = '0' else (others => '0');
  s_axi_rvalid  <= m_axi_rvalid  when bypass = '0' else bypass_rvalid;
  m_axi_awaddr  <= s_axi_awaddr;
  m_axi_awvalid <= s_axi_awvalid when bypass = '0' else '0';
  m_axi_wdata   <= s_axi_wdata;
  m_axi_wstrb   <= s_axi_wstrb;
  m_axi_wvalid  <= s_axi_wvalid  when bypass = '0' else '0';
  m_axi_bready  <= s_axi_bready  when bypass = '0' else '0';
  m_axi_araddr  <= s_axi_araddr;
  m_axi_arvalid <= s_axi_arvalid when bypass = '0' else '0';
  m_axi_rready  <= s_axi_rready  when bypass = '0' else '0';

  process (axi_aclk) is
  begin  -- process
    if axi_aclk'event and axi_aclk = '1' then  -- rising clock edge
      if s_axi_rready = '1' then
        bypass_rvalid <= '0';
      end if;
      if s_axi_arvalid = '1' then
        bypass_rvalid <= '1';
        bypass_rdata  <= (others => '0');

        --'Randomly' set full bit
        bypass_rdata(4) <= full_lfsr(0);
        --'Randomly' set empty bit
        bypass_rdata(3) <= empty_lfsr(0);

        full_lfsr(7)  <= full_lfsr(0);
        full_lfsr(6)  <= full_lfsr(7);
        full_lfsr(5)  <= full_lfsr(6) xor full_lfsr(0);
        full_lfsr(4)  <= full_lfsr(5) xor full_lfsr(0);
        full_lfsr(3)  <= full_lfsr(4) xor full_lfsr(0);
        full_lfsr(2)  <= full_lfsr(3);
        full_lfsr(1)  <= full_lfsr(2);
        full_lfsr(0)  <= full_lfsr(1);
        empty_lfsr(7) <= empty_lfsr(0);
        empty_lfsr(6) <= empty_lfsr(7);
        empty_lfsr(5) <= empty_lfsr(6) xor empty_lfsr(0);
        empty_lfsr(4) <= empty_lfsr(5) xor empty_lfsr(0);
        empty_lfsr(3) <= empty_lfsr(4) xor empty_lfsr(0);
        empty_lfsr(2) <= empty_lfsr(3);
        empty_lfsr(1) <= empty_lfsr(2);
        empty_lfsr(0) <= empty_lfsr(1);
      end if;
      bypass_bvalid <= s_axi_wvalid and s_axi_awvalid;

      if axi_aresetn = '0' then
        full_lfsr     <= (0      => '1', others => '0');
        empty_lfsr    <= (others => '1');
        bypass_rvalid <= '0';
        bypass_bvalid <= '0';
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- This process does some debug printing during simulation,
  -- it should have no impact on synthesis
  -----------------------------------------------------------------------------
--pragma translate_off
  process(axi_aclk)
    file uart_file            : text open write_mode is "ps7_uart.log";
    variable line_to_output   : line;
    variable string_to_output : string(1 to 40);
    variable time_length      : positive;
  begin
    if rising_edge(axi_aclk) then
      if s_axi_awvalid = '1' and s_axi_wvalid = '1' then
        time_length                        := time'image(now)'length;
        string_to_output                   := (others => ' ');
        string_to_output(1 to time_length) := time'image(now);
        string_to_output(40)               := character'val(to_integer(unsigned(s_axi_wdata(7 downto 0))));
        write(line_to_output, string_to_output);
        writeline(uart_file, line_to_output);
      end if;
    end if;
  end process;
--pragma translate_on

end architecture rtl;
