library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_TEXTIO.all;
use STD.TEXTIO.all;

library work;
use work.utils.all;

entity ram_1port is

  generic (
    MEM_DEPTH : natural := 1024;
    MEM_WIDTH : natural := 32;
    FAMILY    : string  := "ALTERA");

  port (
    clk        : in  std_logic;
    byte_en_d1 : in  std_logic_vector(MEM_WIDTH/8-1 downto 0);
    wr_en_d1   : in  std_logic;
    chip_sel   : in  std_logic;
    addr_d1    : in  std_logic_vector(log2(MEM_DEPTH)-1 downto 0);
    data_in_d1 : in  std_logic_vector(MEM_WIDTH-1 downto 0);
    data_out   : out std_logic_vector(MEM_WIDTH-1 downto 0)
    );

end entity ram_1port;


architecture behav of ram_1port is


  component SB_SPRAM256KA is
    port (
      ADDRESS    : in  std_logic_vector(13 downto 0);
      DATAIN     : in  std_logic_vector(15 downto 0);
      MASKWREN   : in  std_logic_vector(3 downto 0);
      WREN       : in  std_logic;
      CHIPSELECT : in  std_logic;
      CLOCK      : in  std_logic;
      STANDBY    : in  std_logic;
      SLEEP      : in  std_logic;
      POWEROFF   : in  std_logic;
      DATAOUT    : out std_logic_vector(15 downto 0));
  end component;

begin

  behavioural_ram : if FAMILY /= "LATTICE" generate
    type ram_type is array (0 to MEM_DEPTH-1) of std_logic_vector(MEM_WIDTH-1 downto 0);
    signal ram : ram_type;
    signal Q   : std_logic_vector(MEM_WIDTH-1 downto 0);
  begin
    process (clk)
    begin
      if rising_edge(clk) then
        Q        <= ram(to_integer(unsigned(addr_d1)));
        data_out <= Q;
        for b in 0 to MEM_WIDTH/8 -1 loop
          if wr_en_d1 = '1' and byte_en_d1(b) = '1' then
            ram(to_integer(unsigned(addr_d1)))((b+1)*8 -1 downto b*8) <= data_in_d1(8*(b+1)-1 downto 8*b);
          end if;
        end loop;  -- b
      end if;
    end process;

  end generate behavioural_ram;

  lattice_ram : if FAMILY = "LATTICE" generate
    constant SPRAM_ADDR_BITS : positive := 14;
    constant SPRAM_WIDTH     : positive := 16;
    constant MEM_DEPTH_RAMS  : positive := (MEM_DEPTH+(2**SPRAM_ADDR_BITS)-1)/(2**SPRAM_ADDR_BITS);

    signal spram_address : std_logic_vector(SPRAM_ADDR_BITS-1 downto 0);
    type mask_wren_vector is array (natural range <>) of std_logic_vector(3 downto 0);
    signal mask_wren     : mask_wren_vector((MEM_WIDTH/SPRAM_WIDTH)-1 downto 0);

    signal we_depth       : std_logic_vector(MEM_DEPTH_RAMS-1 downto 0);
    type data_out_vector is array (natural range <>) of std_logic_vector(MEM_WIDTH-1 downto 0);
    signal data_out_depth : data_out_vector(MEM_DEPTH_RAMS-1 downto 0);
  begin
    spram_address <= std_logic_vector(resize(unsigned(addr_d1), SPRAM_ADDR_BITS));

    one_deep_gen : if MEM_DEPTH <= (2**SPRAM_ADDR_BITS) generate
      we_depth(0) <= wr_en_d1;

      data_register : process (clk) is
      begin  -- process data_register
        if rising_edge(clk) then
          data_out <= data_out_depth(0);
        end if;
      end process data_register;
    end generate one_deep_gen;
    multiple_deep_gen : if MEM_DEPTH > (2**SPRAM_ADDR_BITS) generate
      signal depth_select_in  : unsigned((log2(MEM_DEPTH)-SPRAM_ADDR_BITS)-1 downto 0);
      signal depth_select_out : unsigned((log2(MEM_DEPTH)-SPRAM_ADDR_BITS)-1 downto 0);
    begin
      depth_select_in <= unsigned(addr_d1(addr_d1'left downto SPRAM_ADDR_BITS));

      deep_ram_gen : for gdepth in MEM_DEPTH_RAMS-1 downto 0 generate
        we_depth(gdepth) <= wr_en_d1 when (depth_select_in = to_unsigned(gdepth, log2(MEM_DEPTH)-SPRAM_ADDR_BITS)) else
                            '0';
      end generate deep_ram_gen;

      data_register : process (clk) is
      begin  -- process data_register
        if rising_edge(clk) then
          depth_select_out <= depth_select_in;
          data_out         <= data_out_depth(to_integer(depth_select_out));
        end if;
      end process data_register;
    end generate multiple_deep_gen;

    parallel_ram_gen : for gram in (MEM_WIDTH/SPRAM_WIDTH)-1 downto 0 generate
      mask_wren(gram) <= byte_en_d1((gram*2)+1) & byte_en_d1((gram*2)+1) & byte_en_d1((gram*2)+0) & byte_en_d1((gram*2)+0);

      deep_ram_gen : for gdepth in MEM_DEPTH_RAMS-1 downto 0 generate
        SPRAM : component SB_SPRAM256KA
          port map (
            ADDRESS    => spram_address,
            DATAIN     => data_in_d1(((gram+1)*SPRAM_WIDTH)-1 downto gram*SPRAM_WIDTH),
            MASKWREN   => mask_wren(gram),
            WREN       => we_depth(gdepth),
            CHIPSELECT => chip_sel,
            CLOCK      => clk,
            STANDBY    => '0',
            SLEEP      => '0',
            POWEROFF   => '1',
            DATAOUT    => data_out_depth(gdepth)(((gram+1)*SPRAM_WIDTH)-1 downto gram*SPRAM_WIDTH)
            );
      end generate deep_ram_gen;
    end generate parallel_ram_gen;
  end generate lattice_ram;

end architecture behav;



library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_TEXTIO.all;
use STD.TEXTIO.all;

library work;
use work.utils.all;

entity ram_4port is
  generic(
    MEM_DEPTH : natural;
    MEM_WIDTH : natural;
    FAMILY    : string := "ALTERA");
  port(
    clk            : in std_logic;
    scratchpad_clk : in std_logic;
    reset          : in std_logic;

    pause_lve_in  : in  std_logic;
    pause_lve_out : out std_logic;
                                        --read source A
    raddr0        : in  std_logic_vector(log2(MEM_DEPTH)-1 downto 0);
    ren0          : in  std_logic;
    scalar_value  : in  std_logic_vector(MEM_WIDTH-1 downto 0);
    scalar_enable : in  std_logic;
    data_out0     : out std_logic_vector(MEM_WIDTH-1 downto 0);
                                        --read source B
    raddr1      : in  std_logic_vector(log2(MEM_DEPTH)-1 downto 0);
    ren1        : in  std_logic;
    enum_value  : in  std_logic_vector(MEM_WIDTH-1 downto 0);
    enum_enable : in  std_logic;
    data_out1   : out std_logic_vector(MEM_WIDTH-1 downto 0);
    ack01       : out std_logic;
                                        --write dest
    waddr2      : in  std_logic_vector(log2(MEM_DEPTH)-1 downto 0);
    byte_en2    : in  std_logic_vector(MEM_WIDTH/8-1 downto 0);
    wen2        : in  std_logic;
    data_in2    : in  std_logic_vector(MEM_WIDTH-1 downto 0);
                                        --external slave port
    rwaddr3     : in  std_logic_vector(log2(MEM_DEPTH)-1 downto 0);
    wen3        : in  std_logic;
    ren3        : in  std_logic;        --cannot be asserted same cycle as wen3
    byte_en3    : in  std_logic_vector(MEM_WIDTH/8-1 downto 0);
    data_in3    : in  std_logic_vector(MEM_WIDTH-1 downto 0);
    ack3        : out std_logic;
    data_out3   : out std_logic_vector(MEM_WIDTH-1 downto 0)
    );
end entity;

architecture rtl of ram_4port is

  component ram_1port is
    generic (
      MEM_DEPTH : natural := 1024;
      MEM_WIDTH : natural := 32;
      FAMILY    : string  := "ALTERA");
    port (
      clk        : in  std_logic;
      byte_en_d1 : in  std_logic_vector(MEM_WIDTH/8-1 downto 0);
      wr_en_d1   : in  std_logic;
      chip_sel   : in  std_logic;
      addr_d1    : in  std_logic_vector(log2(MEM_DEPTH)-1 downto 0);
      data_in_d1 : in  std_logic_vector(MEM_WIDTH-1 downto 0);
      data_out   : out std_logic_vector(MEM_WIDTH-1 downto 0));
  end component;

  type port_sel_t is (SLAVE_ACCESS, LVE_ACCESS);
  signal last_port_sel : port_sel_t;

  signal actual_byte_en_d1 : std_logic_vector(MEM_WIDTH/8-1 downto 0);
  signal actual_wr_en_d1   : std_logic;
  signal actual_chip_sel   : std_logic;
  signal actual_addr_d1    : std_logic_vector(log2(MEM_DEPTH)-1 downto 0);
  signal actual_data_in_d1 : std_logic_vector(MEM_WIDTH-1 downto 0);
  signal actual_data_out   : std_logic_vector(MEM_WIDTH-1 downto 0);

  signal data_out0_latch : std_logic_vector(MEM_WIDTH-1 downto 0);
  signal data_out1_latch : std_logic_vector(MEM_WIDTH-1 downto 0);

  signal data_out0_tmp : std_logic_vector(MEM_WIDTH-1 downto 0);
  signal data_out1_tmp : std_logic_vector(MEM_WIDTH-1 downto 0);

  type cycle_count_t is (WRITE_CYC, READ0_CYC, READ1_CYC);
  signal cycle_count      : cycle_count_t;
  signal last_cycle_count : cycle_count_t;

  signal toggle        : std_logic;
  signal delay_toggle  : std_logic;
  signal delay2_toggle : std_logic;
  signal toggles       : std_logic_vector(2 downto 0);

  signal pause_lve_internal : std_logic;

  signal ren0_0 : std_logic;

  signal ack3_int    : std_logic;
  signal raddr0_d1   : std_logic_vector(log2(MEM_DEPTH)-1 downto 0);
  signal raddr1_d1   : std_logic_vector(log2(MEM_DEPTH)-1 downto 0);
  signal waddr2_d1   : std_logic_vector(log2(MEM_DEPTH)-1 downto 0);
  signal byte_en2_d1 : std_logic_vector(MEM_WIDTH/8-1 downto 0);
  signal wen2_d1     : std_logic;
  signal data_in2_d1 : std_logic_vector(MEM_WIDTH-1 downto 0);
  signal rwaddr3_d1  : std_logic_vector(log2(MEM_DEPTH)-1 downto 0);
  signal ren3_d1     : std_logic;
  signal byte_en3_d1 : std_logic_vector(MEM_WIDTH/8-1 downto 0);
  signal wen3_d1     : std_logic;
  signal data_in3_d1 : std_logic_vector(MEM_WIDTH-1 downto 0);
begin  -- architecture rtl
  last_port_sel <= SLAVE_ACCESS when (ren3_d1 or wen3_d1) = '1' else LVE_ACCESS;

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        toggle <= '0';
      else
        toggle <= not toggle;
      end if;
    end if;
  end process;

  process(scratchpad_clk)
  begin
    if rising_edge(scratchpad_clk) then
      delay_toggle     <= toggle;
      delay2_toggle    <= delay_toggle;
      last_cycle_count <= cycle_count;
      case toggles is
        when "100" | "011" =>
          cycle_count <= READ1_CYC;
        when "110" | "001" =>
          cycle_count <= WRITE_CYC;
        when others =>
          cycle_count <= READ0_CYC;
      end case;

      raddr0_d1   <= raddr0;
      raddr1_d1   <= raddr1;
      waddr2_d1   <= waddr2;
      byte_en2_d1 <= byte_en2;
      wen2_d1     <= wen2;
      data_in2_d1 <= data_in2;
      rwaddr3_d1  <= rwaddr3;
      ren3_d1     <= ren3;
      byte_en3_d1 <= byte_en3;
      wen3_d1     <= wen3;
      data_in3_d1 <= data_in3;
    end if;
  end process;
  toggles <= toggle & delay_toggle & delay2_toggle;


  actual_byte_en_d1 <= byte_en3_d1 when last_port_sel = SLAVE_ACCESS else byte_en2_d1;
  actual_wr_en_d1   <= wen2_d1     when last_cycle_count = WRITE_CYC else
                     wen3_d1 when last_port_sel = SLAVE_ACCESS else
                     '0';
  actual_addr_d1 <= waddr2_d1 when last_cycle_count = WRITE_CYC else
                    rwaddr3_d1 when last_port_sel = SLAVE_ACCESS else
                    raddr0_d1  when last_cycle_count = READ0_CYC else
                    raddr1_d1;

  actual_data_in_d1 <= data_in2_d1 when last_cycle_count = WRITE_CYC else
                       data_in3_d1;

  process(scratchpad_clk)
  begin
    if rising_edge(scratchpad_clk) then
      if cycle_count = READ0_CYC then
        data_out0_tmp <= actual_data_out;
      end if;
      if cycle_count = READ1_CYC then
        data_out1_tmp <= actual_data_out;
      end if;

    end if;
  end process;

  --save values for entire 1x clock
  process(clk)
  begin
    if rising_edge(clk) then
      data_out0_latch <= data_out0_tmp;
      data_out1_latch <= actual_data_out;
      data_out0       <= data_out0_tmp;
      data_out1       <= data_out1_tmp;



      if scalar_enable = '1' then
        data_out0 <= scalar_value;
      end if;
      if enum_enable = '1' then
        data_out1 <= enum_value;
      end if;
      data_out3 <= data_out0_tmp;

      pause_lve_internal <= pause_lve_in;
      pause_lve_out      <= pause_lve_internal;

      ren0_0   <= ren0;
      ack01    <= ren0_0;
      ack3_int <= ren3;
      ack3     <= ack3_int or wen3;
    end if;
  end process;

  actual_ram : component ram_1port
    generic map (
      MEM_DEPTH => MEM_DEPTH,
      MEM_WIDTH => MEM_WIDTH,
      FAMILY    => FAMILY)
    port map(
      clk        => scratchpad_clk,
      byte_en_d1 => actual_byte_en_d1,
      wr_en_d1   => actual_wr_en_d1,
      chip_sel   => '1',
      addr_d1    => actual_addr_d1,
      data_in_d1 => actual_data_in_d1,
      data_out   => actual_data_out);

end architecture rtl;
