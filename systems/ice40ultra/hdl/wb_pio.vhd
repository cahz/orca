library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity wb_pio is
  generic (
    DATA_WIDTH   : integer := 32);
  port (
    CLK_I : in std_logic;
    RST_I : in std_logic;

    ADR_I   : in  std_logic_vector(31 downto 0);
    DAT_I   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    WE_I    : in  std_logic;
    CYC_I   : in  std_logic;
    STB_I   : in  std_logic;
    SEL_I   : in  std_logic_vector(3 downto 0);
    CTI_I   : in  std_logic_vector(2 downto 0);
    BTE_I   : in  std_logic_vector(1 downto 0);
    LOCK_I  : in  std_logic;
    ACK_O   : out std_logic;
    STALL_O : out std_logic;
    DATA_O  : out std_logic_vector(DATA_WIDTH -1 downto 0);
    ERR_O   : out std_logic;
    RTY_O   : out std_logic;

    input     : in  std_logic_vector(DATA_WIDTH -1 downto 0);
    output_en : out std_logic_vector(DATA_WIDTH -1 downto 0);
    output    : out std_logic_vector(DATA_WIDTH -1 downto 0)
    );
end entity;

architecture rtl of wb_pio is
  --when control bit is one,
  signal control     : std_logic_vector(DATA_WIDTH -1 downto 0);
  signal in_reg      : std_logic_vector(DATA_WIDTH -1 downto 0);
  signal out_reg     : std_logic_vector(DATA_WIDTH -1 downto 0);
  signal valid_cycle : std_logic;
begin

  valid_cycle <= STB_I and CYC_I;
  ERR_O       <= '0';
  RTY_O       <= '0';
  STALL_O     <= '0';

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
      in_reg <= input;
      if RST_I = '1' then
        out_reg <= (others => '0');
      end if;
    end if;
  end process;

  output    <= out_reg;
  output_en <= control;

end architecture rtl;
