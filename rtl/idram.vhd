library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.rv_components.all;
use work.utils.all;

entity idram is

  generic (
    SIZE        : integer := 32768;
    RAM_WIDTH   : integer := 32;
    ADDR_WIDTH  : integer := 32;
    BYTE_SIZE   : integer := 8);    
  port (
    clk : in std_logic;
    reset : in std_logic;

    instr_AWID    : in std_logic_vector(4 downto 0);
    instr_AWADDR  : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    instr_AWLEN   : in std_logic_vector(3 downto 0);
    instr_AWSIZE  : in std_logic_vector(2 downto 0);
    instr_AWBURST : in std_logic_vector(1 downto 0); 

    instr_AWLOCK  : in std_logic_vector(1 downto 0);
    instr_AWCACHE : in std_logic_vector(3 downto 0);
    instr_AWPROT  : in std_logic_vector(2 downto 0);
    instr_AWVALID : in std_logic;
    instr_AWREADY : out std_logic;

    instr_WID     : in std_logic_vector(4 downto 0);
    instr_WDATA   : in std_logic_vector(RAM_WIDTH -1 downto 0);
    instr_WSTRB   : in std_logic_vector(RAM_WIDTH/BYTE_SIZE -1 downto 0);
    instr_WLAST   : in std_logic;
    instr_WVALID  : in std_logic;
    instr_WREADY  : out std_logic;

    instr_BID     : out std_logic_vector(4 downto 0);
    instr_BRESP   : out std_logic_vector(1 downto 0);
    instr_BVALID  : out std_logic;
    instr_BREADY  : in std_logic;

    instr_ARID    : in std_logic_vector(4 downto 0);
    instr_ARADDR  : in std_logic_vector(ADDR_WIDTH -1 downto 0);
    instr_ARLEN   : in std_logic_vector(3 downto 0);
    instr_ARSIZE  : in std_logic_vector(2 downto 0);
    instr_ARBURST : in std_logic_vector(1 downto 0);
    instr_ARLOCK  : in std_logic_vector(1 downto 0);
    instr_ARCACHE : in std_logic_vector(3 downto 0);
    instr_ARPROT  : in std_logic_vector(2 downto 0);
    instr_ARVALID : in std_logic;
    instr_ARREADY : out std_logic;

    instr_RID     : out std_logic_vector(4 downto 0);
    instr_RDATA   : out std_logic_vector(RAM_WIDTH -1 downto 0);
    instr_RRESP   : out std_logic_vector(1 downto 0);
    instr_RLAST   : out std_logic;
    instr_RVALID  : out std_logic;
    instr_RREADY  : in std_logic;

    data_AWID    : in std_logic_vector(4 downto 0);
    data_AWADDR  : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    data_AWLEN   : in std_logic_vector(3 downto 0);
    data_AWSIZE  : in std_logic_vector(2 downto 0);
    data_AWBURST : in std_logic_vector(1 downto 0); 

    data_AWLOCK  : in std_logic_vector(1 downto 0);
    data_AWCACHE : in std_logic_vector(3 downto 0);
    data_AWPROT  : in std_logic_vector(2 downto 0);
    data_AWVALID : in std_logic;
    data_AWREADY : out std_logic;

    data_WID     : in std_logic_vector(4 downto 0);
    data_WDATA   : in std_logic_vector(RAM_WIDTH -1 downto 0);
    data_WSTRB   : in std_logic_vector(RAM_WIDTH/BYTE_SIZE -1 downto 0);
    data_WLAST   : in std_logic;
    data_WVALID  : in std_logic;
    data_WREADY  : out std_logic;

    data_BID     : out std_logic_vector(4 downto 0);
    data_BRESP   : out std_logic_vector(1 downto 0);
    data_BVALID  : out std_logic;
    data_BREADY  : in std_logic;

    data_ARID    : in std_logic_vector(4 downto 0);
    data_ARADDR  : in std_logic_vector(ADDR_WIDTH -1 downto 0);
    data_ARLEN   : in std_logic_vector(3 downto 0);
    data_ARSIZE  : in std_logic_vector(2 downto 0);
    data_ARBURST : in std_logic_vector(1 downto 0);
    data_ARLOCK  : in std_logic_vector(1 downto 0);
    data_ARCACHE : in std_logic_vector(3 downto 0);
    data_ARPROT  : in std_logic_vector(2 downto 0);
    data_ARVALID : in std_logic;
    data_ARREADY : out std_logic;

    data_RID     : out std_logic_vector(4 downto 0);
    data_RDATA   : out std_logic_vector(RAM_WIDTH -1 downto 0);
    data_RRESP   : out std_logic_vector(1 downto 0);
    data_RLAST   : out std_logic;
    data_RVALID  : out std_logic;
    data_RREADY  : in std_logic

  );
end entity idram;

architecture rtl of idram is

  constant BYTES_PER_WORD : integer := RAM_WIDTH/8;

  signal address : std_logic_vector(log2(SIZE/BYTES_PER_WORD)-1 downto 0);
  signal write_en : std_logic;

  signal instr_address : std_logic_vector(log2(SIZE/BYTES_PER_WORD)-1 downto 0);
  signal instr_write_en : std_logic;
  signal instr_byte_sel : std_logic_vector(RAM_WIDTH/8-1 downto 0);
  signal instr_en : std_logic;

  signal data_address : std_logic_vector(log2(SIZE/BYTES_PER_WORD)-1 downto 0);
  signal data_write_en : std_logic;
  signal data_byte_sel : std_logic_vector(RAM_WIDTH/8-1 downto 0);
  signal data_en : std_logic;

  type state_t is (IDLE);
  signal state_i : state_t;
  signal state_d : state_t;

begin  
  instr_RRESP <= (others => '0');
  instr_BRESP <= (others => '0');
  instr_ARREADY <= instr_ARVALID;
  instr_AWREADY <= instr_AWVALID and instr_WVALID;
  instr_WREADY <= instr_AWVALID and instr_WVALID;
  instr_address <= instr_ARADDR(instr_address'left+log2(BYTES_PER_WORD) downto log2(BYTES_PER_WORD)) when instr_ARVALID = '1' else instr_AWADDR(data_address'left+log2(BYTES_PER_WORD) downto log2(BYTES_PER_WORD));
  instr_write_en <= (instr_AWVALID and instr_WVALID);
  instr_byte_sel <= (others => '1') when instr_ARVALID = '1' else instr_WSTRB;
  instr_en <= (instr_AWVALID and instr_WVALID) or instr_ARVALID;

  data_RRESP <= (others => '0');
  data_BRESP <= (others => '0');
  data_ARREADY <= data_ARVALID;
  data_AWREADY <= data_AWVALID and data_WVALID;
  data_WREADY <= data_AWVALID and data_WVALID;
  data_address <= data_ARADDR(data_address'left+log2(BYTES_PER_WORD) downto log2(BYTES_PER_WORD)) when data_ARVALID = '1' else data_AWADDR(data_address'left+log2(BYTES_PER_WORD) downto log2(BYTES_PER_WORD));
  data_write_en <= (data_AWVALID and data_WVALID); 
  data_byte_sel <= (others => '1') when data_ARVALID = '1' else data_WSTRB;
  data_en <= (data_AWVALID and data_WVALID) or data_ARVALID;

  instruction_port : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        state_i <= IDLE;
        instr_RVALID <= '0';
        instr_BVALID <= '0';
        instr_RLAST <= '0';
      else
        case state_i is
          when IDLE =>
            instr_RVALID <= '0';
            instr_RLAST <= '0';
            instr_BVALID <= '0';
            state_i <= IDLE;
            if instr_ARVALID = '1' then
              instr_RVALID <= '1';
              instr_RLAST <= '1';
              instr_RID <= instr_ARID;
            elsif (instr_AWVALID = '1') and (instr_WVALID = '1') then
              instr_BVALID <= '1';
              instr_BID <= instr_AWID;
            end if;

          when others =>
            state_i <= IDLE;
               
        end case;
      end if;
    end if;
  end process;

  data_port : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        state_d <= IDLE;
        data_RVALID <= '0';
        data_BVALID <= '0';
        data_RLAST <= '0';
      else
        case state_d is
          when IDLE =>
            data_RVALID <= '0';
            data_RLAST <= '0';
            data_BVALID <= '0';
            state_d <= IDLE;
            if data_ARVALID = '1' then
              data_RVALID <= '1';
              data_RLAST <= '1';
              data_RID <= data_ARID;
            elsif (data_AWVALID = '1') and (data_WVALID = '1') then
              data_BVALID <= '1';
              data_BID <= instr_AWID;
            end if;

          when others =>
            state_d <= IDLE;
               
        end case;
      end if;
    end if;
  end process;

  ram : component idram_xilinx
    generic map (
      RAM_DEPTH => SIZE/4,
      RAM_WIDTH => RAM_WIDTH,
      BYTE_SIZE => BYTE_SIZE)
    port map (
      clock    => clk,

      instr_address  => instr_address,
      instr_data_in  => instr_WDATA,
      instr_we       => instr_write_en,
      instr_en       => instr_en,
      instr_be       => instr_byte_sel,
      instr_readdata => instr_RDATA,

      data_address => data_address,
      data_data_in => data_WDATA,
      data_we => data_write_en,
      data_en => data_en,
      data_be => data_byte_sel,
      data_readdata => data_RDATA
    );

end architecture rtl;
