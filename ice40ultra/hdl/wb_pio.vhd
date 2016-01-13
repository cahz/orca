library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity wb_pio is
  generic (
    DATA_WIDTH   : integer := 32;
    ALLOW_INPUT  : boolean := true;
    ALLOW_OUTPUT : boolean := true);
  port (
    CLK_I : in std_logic;
    RST_I : in std_logic;

    ADR_I        : in    std_logic_vector(31 downto 0);
    DAT_I        : in    std_logic_vector(DATA_WIDTH-1 downto 0);
    WE_I         : in    std_logic;
    CYC_I        : in    std_logic;
    STB_I        : in    std_logic;
    SEL_I        : in    std_logic_vector(DATA_WIDTH/8-1 downto 0);
    CTI_I        : in    std_logic_vector(2 downto 0);
    BTE_I        : in    std_logic_vector(1 downto 0);
    LOCK_I       : in    std_logic;
    ACK_O        : out   std_logic;
    STALL_O      : out   std_logic;
    DATA_O       : out   std_logic_vector(DATA_WIDTH -1 downto 0);
    ERR_O        : out   std_logic;
    RTY_O        : out   std_logic;
    input_output : inout std_logic_vector(DATA_WIDTH -1 downto 0)
    );
end entity;



architecture rtl of wb_pio is
  --when control bit is one,
  signal control     : std_logic_vector(DATA_WIDTH -1 downto 0);
  signal in_reg      : std_logic_vector(DATA_WIDTH -1 downto 0);
  signal out_reg     : std_logic_vector(DATA_WIDTH -1 downto 0);
  signal valid_cycle : std_logic;
begin
  assert ALLOW_INPUT or ALLOW_OUTPUT report "Must allow input or output" severity failure;

  valid_cycle <= STB_I and CYC_I;
  ERR_O       <= '0';
  RTY_O       <= '0';
  STALL_O     <= '0';

  ALLOW_INPUT_OUTPUT_GEN : if ALLOW_INPUT and ALLOW_OUTPUT generate
    process(CLK_I)
    begin
      if rising_edge(CLK_I) then
        ACK_O <= valid_cycle;
        if (WE_I and valid_cycle) = '1' then
          if adr_i(2) = '0' then
            out_reg <= DAT_I;
          else
            control <= DAT_I;
          end if;
        end if;

        if adr_i(2) = '0' then
          DATA_O <= in_reg;
        else
          DATA_O <= control;
        end if;
        if RST_I = '1' then
          control <= (others => '0');
        end if;
        in_reg <= input_output;
      end if;
    end process;


    in_or_out : for i in control'range generate
      input_output(i) <= out_reg(i) when control(i) = '1' else 'Z';
    end generate in_or_out;

  end generate ALLOW_INPUT_OUTPUT_GEN;

  ALLOW_INPUT_GEN : if ALLOW_INPUT and not ALLOW_OUTPUT generate
    process(CLK_I)
    begin
      if rising_edge(CLK_I) then
        ACK_O <= valid_cycle;
        if adr_i(2) = '0' then
          DATA_O <= in_reg;
        else
          DATA_O <= (others => '0');
        end if;
        in_reg <= input_output;
      end if;
    end process;

  end generate ALLOW_INPUT_GEN;

  ALLOW_OUTPUT_GEN : if not ALLOW_INPUT and ALLOW_OUTPUT generate
    process(CLK_I)
    begin
      if rising_edge(CLK_I) then
        ACK_O <= valid_cycle;
        if (WE_I and valid_cycle) = '1' then
          if adr_i(2) = '0' then
            out_reg <= DAT_I;
          end if;
        end if;

        if adr_i(2) = '0' then
          DATA_O <= out_reg;
        else
          DATA_O <= (others => '1');
        end if;

      end if;
    end process;
    input_output <= out_reg;
  end generate ALLOW_OUTPUT_GEN;

end architecture rtl;
