library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.rv_components.all;
use work.utils.all;

entity iram is

  generic (
    SIZE        : integer := 4096;
    RAM_WIDTH   : integer := 32;
    BYTE_SIZE   : integer := 8);    
  port (
    clk : in std_logic;
    reset : in std_logic;

    addr : in std_logic_vector(RAM_WIDTH-1 downto 0);
    wdata : in std_logic_vector(RAM_WIDTH-1 downto 0);
    wen  : in std_logic;
    byte_sel : in std_logic_vector(RAM_WIDTH/8-1 downto 0);
    strb  : in std_logic;
    ack   : out std_logic;
    rdata   : out std_logic_vector(RAM_WIDTH-1 downto 0);
    
    ram_AWID    : in std_logic_vector(3 downto 0);
    ram_AWADDR  : in std_logic_vector(RAM_WIDTH-1 downto 0);
    ram_AWLEN   : in std_logic_vector(3 downto 0);
    ram_AWSIZE  : in std_logic_vector(2 downto 0);
    ram_AWBURST : in std_logic_vector(1 downto 0); 

    ram_AWLOCK  : in std_logic_vector(1 downto 0);
    ram_AWCACHE : in std_logic_vector(3 downto 0);
    ram_AWPROT  : in std_logic_vector(2 downto 0);
    ram_AWVALID : in std_logic;
    ram_AWREADY : out std_logic;

    ram_WID     : in std_logic_vector(3 downto 0);
    ram_WDATA   : in std_logic_vector(RAM_WIDTH -1 downto 0);
    ram_WSTRB   : in std_logic_vector(RAM_WIDTH/BYTE_SIZE -1 downto 0);
    ram_WLAST   : in std_logic;
    ram_WVALID  : in std_logic;
    ram_WREADY  : out std_logic;

    ram_BID     : out std_logic_vector(3 downto 0);
    ram_BRESP   : out std_logic_vector(1 downto 0);
    ram_BVALID  : out std_logic;
    ram_BREADY  : in std_logic;

    ram_ARID    : in std_logic_vector(3 downto 0);
    ram_ARADDR  : in std_logic_vector(RAM_WIDTH -1 downto 0);
    ram_ARLEN   : in std_logic_vector(3 downto 0);
    ram_ARSIZE  : in std_logic_vector(2 downto 0);
    ram_ARBURST : in std_logic_vector(1 downto 0);
    ram_ARLOCK  : in std_logic_vector(1 downto 0);
    ram_ARCACHE : in std_logic_vector(3 downto 0);
    ram_ARPROT  : in std_logic_vector(2 downto 0);
    ram_ARVALID : in std_logic;
    ram_ARREADY : out std_logic;

    ram_RID     : out std_logic_vector(3 downto 0);
    ram_RDATA   : out std_logic_vector(RAM_WIDTH -1 downto 0);
    ram_RRESP   : out std_logic_vector(1 downto 0);
    ram_RLAST   : out std_logic;
    ram_RVALID  : out std_logic;
    ram_RREADY  : in std_logic

  );
end entity iram;

architecture rtl of iram is

  constant BYTES_PER_WORD : integer := RAM_WIDTH/8;

  signal address : std_logic_vector(log2(SIZE/BYTES_PER_WORD)-1 downto 0);
  signal write_en : std_logic;

  signal data_address : std_logic_vector(log2(SIZE/BYTES_PER_WORD)-1 downto 0);
  signal data_wdata : std_logic_vector(RAM_WIDTH-1 downto 0);
  signal data_write_en : std_logic;
  signal data_byte_sel : std_logic_vector(RAM_WIDTH/8-1 downto 0);
  signal data_rdata : std_logic_vector(RAM_WIDTH-1 downto 0);

  type state_t is (IDLE, WAITING_WVALID, WAITING_AWVALID, READ_1, READ_2, WRITE);
  signal state : state_t;

begin  
  
  address <= addr(address'left+log2(BYTES_PER_WORD) downto log2(BYTES_PER_WORD));
  write_en <= wen and strb; 

  
  ram_BID <= (others => '0');
  ram_RID <= (others => '0');
  ram_RDATA <= data_rdata;
  
  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        state <= IDLE;
        ram_ARREADY <= '1';
        ram_AWREADY <= '1';
        ram_WREADY <= '1';
        ram_RVALID <= '0';
        ram_RLAST <= '0';
        ram_BRESP <= (others => '0');
        ram_RRESP <= (others => '0');
        data_address <= (others => '0');
        data_write_en <= '0';
        data_byte_sel <= (others => '0');
      else
        case state is
          when IDLE =>
            ram_ARREADY <= '1';
            ram_AWREADY <= '1';
            ram_WREADY <= '1';
            ram_RVALID <= '0';
            ram_RLAST <= '0';
            ram_BVALID <= '0';
            data_address <= (others => '0');
            data_write_en <= '0';
            if ram_ARVALID = '1' then
              ram_ARREADY <= '0';
              ram_AWREADY <= '0';
              ram_WREADY <= '0';
              ram_RRESP <= (others => '0');
              data_address <= ram_ARADDR(address'left+log2(BYTES_PER_WORD) downto log2(BYTES_PER_WORD));
              data_write_en <= '0';
              data_byte_sel <= (others => '1');
              state <= READ_1;
            elsif (ram_AWVALID = '1') and (ram_WVALID = '1') then
              ram_ARREADY <= '0';
              ram_AWREADY <= '0';
              ram_WREADY <= '0';
              data_address <= ram_AWADDR(address'left+log2(BYTES_PER_WORD) downto log2(BYTES_PER_WORD));
              data_wdata <= ram_WDATA;
              data_write_en <= '1';
              data_byte_sel <= ram_WSTRB;
              state <= WRITE;
            elsif (ram_AWVALID = '1') then
              ram_ARREADY <= '0';
              ram_AWREADY <= '0';
              data_address <= ram_AWADDR(address'left+log2(BYTES_PER_WORD) downto log2(BYTES_PER_WORD));
              state <= WAITING_WVALID;
            elsif (ram_WVALID = '1') then
              ram_ARREADY <= '0';
              ram_WREADY <= '0';
              data_wdata <= ram_WDATA;
              data_byte_sel <= ram_WSTRB;
              state <= WAITING_AWVALID;
            end if;
          
          when WAITING_WVALID =>
            if ram_WVALID = '1' then
              ram_WREADY <= '0';
              data_wdata <= ram_WDATA;
              data_write_en <= '1';
              data_byte_sel <= ram_WSTRB;
              state <= WRITE;
            end if;

          when WAITING_AWVALID =>
            if ram_AWVALID = '1' then
              ram_AWREADY <= '0';
              data_address <= ram_AWADDR(address'left+log2(BYTES_PER_WORD) downto log2(BYTES_PER_WORD));
              data_write_en <= '1';
              state <= WRITE;
            end if;
              
          when READ_1 =>
            ram_RVALID <= '1'; 
            ram_RLAST <= '1';
            ram_RRESP <= (others => '0');
            state <= READ_2;

          when READ_2 =>
            if ram_RREADY = '1' then
              ram_RVALID <= '0';
              ram_RLAST <= '0';
              ram_ARREADY <= '1';
              ram_AWREADY <= '1';
              ram_WREADY <= '1';
              state <= IDLE;
            end if;
          
          when WRITE => 
            ram_BVALID <= '1';
            ram_BRESP <= (others => '0');
            ram_ARREADY <= '1';
            ram_AWREADY <= '1';
            ram_WREADY <= '1';
            state <= IDLE;     
    
          when others =>
            state <= IDLE;
               
        end case;
      end if;
    end if;
  end process;


  ram : entity work.bram_microsemi(rtl)
    generic map (
      RAM_DEPTH => SIZE/4,
      RAM_WIDTH => RAM_WIDTH,
      BYTE_SIZE => BYTE_SIZE)
    port map (
      clock    => clk,

      address  => address,
      data_in  => wdata,
      we       => write_en,
      be       => byte_sel,
      readdata => rdata,

      data_address => data_address,
      data_data_in => data_wdata,
      data_we => data_write_en,
      data_be => data_byte_sel,
      data_readdata => data_rdata
      );
    process(clk)
    begin
      if rising_edge(clk) then
        ack <= strb and (not wen);
      end if;
    end process;

end architecture rtl;
