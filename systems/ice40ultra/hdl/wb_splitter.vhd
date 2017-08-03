library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.top_component_pkg.all;
-------------------------------------------------------------------------------
-- This is a wishbone splitter, it supports up to 5 slaves, but can
-- be modified fairly obviously to support more. to define a slave
-- address space, use the following generic
--    slaveX_address => (ADR_START,SIZE)
--
-- All slave address spaces must be a power of two in size
-------------------------------------------------------------------------------

entity wb_splitter is

  generic (
    SUB_ADDRESS_BITS : positive range 1 to 29 := 16;
    NUM_MASTERS      : positive range 2 to 8  := 2;

    JUST_OR_ACKS : boolean := false;

    DATA_WIDTH : natural := 32
    );
  port(
    CLK_I : in std_logic;
    RST_I : in std_logic;

    slave_ADR_I   : in  std_logic_vector(31 downto 0);
    slave_DAT_I   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    slave_WE_I    : in  std_logic;
    slave_CYC_I   : in  std_logic;
    slave_STB_I   : in  std_logic;
    slave_SEL_I   : in  std_logic_vector(DATA_WIDTH/8-1 downto 0);
    slave_CTI_I   : in  std_logic_vector(2 downto 0);
    slave_BTE_I   : in  std_logic_vector(1 downto 0);
    slave_LOCK_I  : in  std_logic;
    slave_STALL_O : out std_logic;
    slave_DAT_O   : out std_logic_vector(DATA_WIDTH-1 downto 0);
    slave_ACK_O   : out std_logic;
    slave_ERR_O   : out std_logic;
    slave_RTY_O   : out std_logic;


    master0_ADR_O   : out std_logic_vector(31 downto 0);
    master0_DAT_O   : out std_logic_vector(DATA_WIDTH-1 downto 0);
    master0_WE_O    : out std_logic;
    master0_CYC_O   : out std_logic;
    master0_STB_O   : out std_logic;
    master0_SEL_O   : out std_logic_vector(DATA_WIDTH/8-1 downto 0);
    master0_CTI_O   : out std_logic_vector(2 downto 0);
    master0_BTE_O   : out std_logic_vector(1 downto 0);
    master0_LOCK_O  : out std_logic;
    master0_STALL_I : in  std_logic                               := '0';
    master0_DAT_I   : in  std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    master0_ACK_I   : in  std_logic                               := '0';
    master0_ERR_I   : in  std_logic                               := '0';
    master0_RTY_I   : in  std_logic                               := '0';

    master1_ADR_O   : out std_logic_vector(31 downto 0);
    master1_DAT_O   : out std_logic_vector(DATA_WIDTH-1 downto 0);
    master1_WE_O    : out std_logic;
    master1_CYC_O   : out std_logic;
    master1_STB_O   : out std_logic;
    master1_SEL_O   : out std_logic_vector(DATA_WIDTH/8-1 downto 0);
    master1_CTI_O   : out std_logic_vector(2 downto 0);
    master1_BTE_O   : out std_logic_vector(1 downto 0);
    master1_LOCK_O  : out std_logic;
    master1_STALL_I : in  std_logic                               := '0';
    master1_DAT_I   : in  std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    master1_ACK_I   : in  std_logic                               := '0';
    master1_ERR_I   : in  std_logic                               := '0';
    master1_RTY_I   : in  std_logic                               := '0';

    master2_ADR_O   : out std_logic_vector(31 downto 0);
    master2_DAT_O   : out std_logic_vector(DATA_WIDTH-1 downto 0);
    master2_WE_O    : out std_logic;
    master2_CYC_O   : out std_logic;
    master2_STB_O   : out std_logic;
    master2_SEL_O   : out std_logic_vector(DATA_WIDTH/8-1 downto 0);
    master2_CTI_O   : out std_logic_vector(2 downto 0);
    master2_BTE_O   : out std_logic_vector(1 downto 0);
    master2_LOCK_O  : out std_logic;
    master2_STALL_I : in  std_logic                               := '0';
    master2_DAT_I   : in  std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    master2_ACK_I   : in  std_logic                               := '0';
    master2_ERR_I   : in  std_logic                               := '0';
    master2_RTY_I   : in  std_logic                               := '0';

    master3_ADR_O   : out std_logic_vector(31 downto 0);
    master3_DAT_O   : out std_logic_vector(DATA_WIDTH-1 downto 0);
    master3_WE_O    : out std_logic;
    master3_CYC_O   : out std_logic;
    master3_STB_O   : out std_logic;
    master3_SEL_O   : out std_logic_vector(DATA_WIDTH/8-1 downto 0);
    master3_CTI_O   : out std_logic_vector(2 downto 0);
    master3_BTE_O   : out std_logic_vector(1 downto 0);
    master3_LOCK_O  : out std_logic;
    master3_STALL_I : in  std_logic                               := '0';
    master3_DAT_I   : in  std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    master3_ACK_I   : in  std_logic                               := '0';
    master3_ERR_I   : in  std_logic                               := '0';
    master3_RTY_I   : in  std_logic                               := '0';

    master4_ADR_O   : out std_logic_vector(31 downto 0);
    master4_DAT_O   : out std_logic_vector(DATA_WIDTH-1 downto 0);
    master4_WE_O    : out std_logic;
    master4_CYC_O   : out std_logic;
    master4_STB_O   : out std_logic;
    master4_SEL_O   : out std_logic_vector(DATA_WIDTH/8-1 downto 0);
    master4_CTI_O   : out std_logic_vector(2 downto 0);
    master4_BTE_O   : out std_logic_vector(1 downto 0);
    master4_LOCK_O  : out std_logic;
    master4_STALL_I : in  std_logic                               := '0';
    master4_DAT_I   : in  std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    master4_ACK_I   : in  std_logic                               := '0';
    master4_ERR_I   : in  std_logic                               := '0';
    master4_RTY_I   : in  std_logic                               := '0';

    master5_ADR_O   : out std_logic_vector(31 downto 0);
    master5_DAT_O   : out std_logic_vector(DATA_WIDTH-1 downto 0);
    master5_WE_O    : out std_logic;
    master5_CYC_O   : out std_logic;
    master5_STB_O   : out std_logic;
    master5_SEL_O   : out std_logic_vector(DATA_WIDTH/8-1 downto 0);
    master5_CTI_O   : out std_logic_vector(2 downto 0);
    master5_BTE_O   : out std_logic_vector(1 downto 0);
    master5_LOCK_O  : out std_logic;
    master5_STALL_I : in  std_logic                               := '0';
    master5_DAT_I   : in  std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    master5_ACK_I   : in  std_logic                               := '0';
    master5_ERR_I   : in  std_logic                               := '0';
    master5_RTY_I   : in  std_logic                               := '0';

    master6_ADR_O   : out std_logic_vector(31 downto 0);
    master6_DAT_O   : out std_logic_vector(DATA_WIDTH-1 downto 0);
    master6_WE_O    : out std_logic;
    master6_CYC_O   : out std_logic;
    master6_STB_O   : out std_logic;
    master6_SEL_O   : out std_logic_vector(DATA_WIDTH/8-1 downto 0);
    master6_CTI_O   : out std_logic_vector(2 downto 0);
    master6_BTE_O   : out std_logic_vector(1 downto 0);
    master6_LOCK_O  : out std_logic;
    master6_STALL_I : in  std_logic                               := '0';
    master6_DAT_I   : in  std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    master6_ACK_I   : in  std_logic                               := '0';
    master6_ERR_I   : in  std_logic                               := '0';
    master6_RTY_I   : in  std_logic                               := '0';

    master7_ADR_O   : out std_logic_vector(31 downto 0);
    master7_DAT_O   : out std_logic_vector(DATA_WIDTH-1 downto 0);
    master7_WE_O    : out std_logic;
    master7_CYC_O   : out std_logic;
    master7_STB_O   : out std_logic;
    master7_SEL_O   : out std_logic_vector(DATA_WIDTH/8-1 downto 0);
    master7_CTI_O   : out std_logic_vector(2 downto 0);
    master7_BTE_O   : out std_logic_vector(1 downto 0);
    master7_LOCK_O  : out std_logic;
    master7_STALL_I : in  std_logic                               := '0';
    master7_DAT_I   : in  std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    master7_ACK_I   : in  std_logic                               := '0';
    master7_ERR_I   : in  std_logic                               := '0';
    master7_RTY_I   : in  std_logic                               := '0');
end entity wb_splitter;

architecture rtl of wb_splitter is
  constant REGISTER_SIZE : natural := 32;

  signal master0_stb : std_logic;
  signal master1_stb : std_logic;
  signal master2_stb : std_logic;
  signal master3_stb : std_logic;
  signal master4_stb : std_logic;
  signal master5_stb : std_logic;
  signal master6_stb : std_logic;
  signal master7_stb : std_logic;

  signal master_stall_i : std_logic_vector(7 downto 0);
  signal master_ack_i   : std_logic_vector(7 downto 0);
  type data_array is array (natural range <>) of std_logic_vector(DATA_WIDTH-1 downto 0);
  signal master_dat_i   : data_array(7 downto 0);

  signal choice      : unsigned(2 downto 0);
  signal last_choice : unsigned(2 downto 0);
begin  -- architecture rtl

  master0_gen : if NUM_MASTERS > 0 generate
    master0_stb <=
      slave_STB_I when slave_ADR_I(SUB_ADDRESS_BITS+2 downto SUB_ADDRESS_BITS) = std_logic_vector(to_unsigned(0, 3))
      else '0';
    master_stall_i(0) <= master0_STALL_I;
    master_ack_i(0)   <= master0_ACK_I;
    master_dat_i(0)   <= master0_DAT_I;
  end generate master0_gen;
  nmaster0_gen : if NUM_MASTERS <= 0 generate
    master0_stb       <= '0';
    master_stall_i(0) <= '0';
    master_ack_i(0)   <= '0';
    master_dat_i(0)   <= (others => '0');
  end generate nmaster0_gen;

  master1_gen : if NUM_MASTERS > 1 generate
    master1_stb <=
      slave_STB_I when slave_ADR_I(SUB_ADDRESS_BITS+2 downto SUB_ADDRESS_BITS) = std_logic_vector(to_unsigned(1, 3))
      else '0';
    master_stall_i(1) <= master1_STALL_I;
    master_ack_i(1)   <= master1_ACK_I;
    master_dat_i(1)   <= master1_DAT_I;
  end generate master1_gen;
  nmaster1_gen : if NUM_MASTERS <= 1 generate
    master1_stb       <= '0';
    master_stall_i(1) <= '0';
    master_ack_i(1)   <= '0';
    master_dat_i(1)   <= (others => '0');
  end generate nmaster1_gen;

  master2_gen : if NUM_MASTERS > 2 generate
    master2_stb <=
      slave_STB_I when slave_ADR_I(SUB_ADDRESS_BITS+2 downto SUB_ADDRESS_BITS) = std_logic_vector(to_unsigned(2, 3))
      else '0';
    master_stall_i(2) <= master2_STALL_I;
    master_ack_i(2)   <= master2_ACK_I;
    master_dat_i(2)   <= master2_DAT_I;
  end generate master2_gen;
  nmaster2_gen : if NUM_MASTERS <= 2 generate
    master2_stb       <= '0';
    master_stall_i(2) <= '0';
    master_ack_i(2)   <= '0';
    master_dat_i(2)   <= (others => '0');
  end generate nmaster2_gen;

  master3_gen : if NUM_MASTERS > 3 generate
    master3_stb <=
      slave_STB_I when slave_ADR_I(SUB_ADDRESS_BITS+2 downto SUB_ADDRESS_BITS) = std_logic_vector(to_unsigned(3, 3))
      else '0';
    master_stall_i(3) <= master3_STALL_I;
    master_ack_i(3)   <= master3_ACK_I;
    master_dat_i(3)   <= master3_DAT_I;
  end generate master3_gen;
  nmaster3_gen : if NUM_MASTERS <= 3 generate
    master3_stb       <= '0';
    master_stall_i(3) <= '0';
    master_ack_i(3)   <= '0';
    master_dat_i(3)   <= (others => '0');
  end generate nmaster3_gen;

  master4_gen : if NUM_MASTERS > 4 generate
    master4_stb <=
      slave_STB_I when slave_ADR_I(SUB_ADDRESS_BITS+2 downto SUB_ADDRESS_BITS) = std_logic_vector(to_unsigned(4, 3))
      else '0';
    master_stall_i(4) <= master4_STALL_I;
    master_ack_i(4)   <= master4_ACK_I;
    master_dat_i(4)   <= master4_DAT_I;
  end generate master4_gen;
  nmaster4_gen : if NUM_MASTERS <= 4 generate
    master4_stb       <= '0';
    master_stall_i(4) <= '0';
    master_ack_i(4)   <= '0';
    master_dat_i(4)   <= (others => '0');
  end generate nmaster4_gen;

  master5_gen : if NUM_MASTERS > 5 generate
    master5_stb <=
      slave_STB_I when slave_ADR_I(SUB_ADDRESS_BITS+2 downto SUB_ADDRESS_BITS) = std_logic_vector(to_unsigned(5, 3))
      else '0';
    master_stall_i(5) <= master5_STALL_I;
    master_ack_i(5)   <= master5_ACK_I;
    master_dat_i(5)   <= master5_DAT_I;
  end generate master5_gen;
  nmaster5_gen : if NUM_MASTERS <= 5 generate
    master5_stb       <= '0';
    master_stall_i(5) <= '0';
    master_ack_i(5)   <= '0';
    master_dat_i(5)   <= (others => '0');
  end generate nmaster5_gen;

  master6_gen : if NUM_MASTERS > 6 generate
    master6_stb <=
      slave_STB_I when slave_ADR_I(SUB_ADDRESS_BITS+2 downto SUB_ADDRESS_BITS) = std_logic_vector(to_unsigned(6, 3))
      else '0';
    master_stall_i(6) <= master6_STALL_I;
    master_ack_i(6)   <= master6_ACK_I;
    master_dat_i(6)   <= master6_DAT_I;
  end generate master6_gen;
  nmaster6_gen : if NUM_MASTERS <= 6 generate
    master6_stb       <= '0';
    master_stall_i(6) <= '0';
    master_ack_i(6)   <= '0';
    master_dat_i(6)   <= (others => '0');
  end generate nmaster6_gen;

  master7_gen : if NUM_MASTERS > 7 generate
    master7_stb <=
      slave_STB_I when slave_ADR_I(SUB_ADDRESS_BITS+2 downto SUB_ADDRESS_BITS) = std_logic_vector(to_unsigned(7, 3))
      else '0';
    master_stall_i(7) <= master7_STALL_I;
    master_ack_i(7)   <= master7_ACK_I;
    master_dat_i(7)   <= master7_DAT_I;
  end generate master7_gen;
  nmaster7_gen : if NUM_MASTERS <= 7 generate
    master7_stb       <= '0';
    master_stall_i(7) <= '0';
    master_ack_i(7)   <= '0';
    master_dat_i(7)   <= (others => '0');
  end generate nmaster7_gen;

  -----------------------------------------------------------------------------
  -- hook up the stb signals that are generated above,
  -- and hookup the passthrough signals
  -----------------------------------------------------------------------------

  master0_STB_O  <= master0_stb;
  master0_ADR_O  <= slave_ADR_I;
  master0_DAT_O  <= slave_DAT_I;
  master0_WE_O   <= slave_WE_I;
  master0_CYC_O  <= slave_CYC_I;
  master0_SEL_O  <= slave_SEL_I;
  master0_CTI_O  <= slave_CTI_I;
  master0_BTE_O  <= slave_BTE_I;
  master0_LOCK_O <= slave_LOCK_I;

  master1_STB_O  <= master1_stb;
  master1_ADR_O  <= slave_ADR_I;
  master1_DAT_O  <= slave_DAT_I;
  master1_WE_O   <= slave_WE_I;
  master1_CYC_O  <= slave_CYC_I;
  master1_SEL_O  <= slave_SEL_I;
  master1_CTI_O  <= slave_CTI_I;
  master1_BTE_O  <= slave_BTE_I;
  master1_LOCK_O <= slave_LOCK_I;

  master2_STB_O  <= master2_stb;
  master2_ADR_O  <= slave_ADR_I;
  master2_DAT_O  <= slave_DAT_I;
  master2_WE_O   <= slave_WE_I;
  master2_CYC_O  <= slave_CYC_I;
  master2_SEL_O  <= slave_SEL_I;
  master2_CTI_O  <= slave_CTI_I;
  master2_BTE_O  <= slave_BTE_I;
  master2_LOCK_O <= slave_LOCK_I;

  master3_STB_O  <= master3_stb;
  master3_ADR_O  <= slave_ADR_I;
  master3_DAT_O  <= slave_DAT_I;
  master3_WE_O   <= slave_WE_I;
  master3_CYC_O  <= slave_CYC_I;
  master3_SEL_O  <= slave_SEL_I;
  master3_CTI_O  <= slave_CTI_I;
  master3_BTE_O  <= slave_BTE_I;
  master3_LOCK_O <= slave_LOCK_I;

  master4_STB_O  <= master4_stb;
  master4_ADR_O  <= slave_ADR_I;
  master4_DAT_O  <= slave_DAT_I;
  master4_WE_O   <= slave_WE_I;
  master4_CYC_O  <= slave_CYC_I;
  master4_SEL_O  <= slave_SEL_I;
  master4_CTI_O  <= slave_CTI_I;
  master4_BTE_O  <= slave_BTE_I;
  master4_LOCK_O <= slave_LOCK_I;

  master5_STB_O  <= master5_stb;
  master5_ADR_O  <= slave_ADR_I;
  master5_DAT_O  <= slave_DAT_I;
  master5_WE_O   <= slave_WE_I;
  master5_CYC_O  <= slave_CYC_I;
  master5_SEL_O  <= slave_SEL_I;
  master5_CTI_O  <= slave_CTI_I;
  master5_BTE_O  <= slave_BTE_I;
  master5_LOCK_O <= slave_LOCK_I;

  master6_STB_O  <= master6_stb;
  master6_ADR_O  <= slave_ADR_I;
  master6_DAT_O  <= slave_DAT_I;
  master6_WE_O   <= slave_WE_I;
  master6_CYC_O  <= slave_CYC_I;
  master6_SEL_O  <= slave_SEL_I;
  master6_CTI_O  <= slave_CTI_I;
  master6_BTE_O  <= slave_BTE_I;
  master6_LOCK_O <= slave_LOCK_I;

  master7_STB_O  <= master7_stb;
  master7_ADR_O  <= slave_ADR_I;
  master7_DAT_O  <= slave_DAT_I;
  master7_WE_O   <= slave_WE_I;
  master7_CYC_O  <= slave_CYC_I;
  master7_SEL_O  <= slave_SEL_I;
  master7_CTI_O  <= slave_CTI_I;
  master7_BTE_O  <= slave_BTE_I;
  master7_LOCK_O <= slave_LOCK_I;




  -------------------------------------------------------------------------------
  -- The output signals are multiplexed below
  -------------------------------------------------------------------------------
  choice <= to_unsigned(0, choice'length) when master0_stb = '1' else
            to_unsigned(1, choice'length) when master1_stb = '1' else
            to_unsigned(2, choice'length) when master2_stb = '1' else
            to_unsigned(3, choice'length) when master3_stb = '1' else
            to_unsigned(4, choice'length) when master4_stb = '1' else
            to_unsigned(5, choice'length) when master5_stb = '1' else
            to_unsigned(6, choice'length) when master6_stb = '1' else
            to_unsigned(7, choice'length);

  process(clk_i)
  begin
    if rising_edge(clk_I) then
      if slave_CYC_I = '1' then
        last_choice <= choice;
      end if;
    end if;
  end process;


  slave_stall_O <= master_stall_i(to_integer(choice));

  select_ack : if (not JUST_OR_ACKS) generate
    slave_ack_O <= master_ack_i(to_integer(last_choice));
  end generate select_ack;
  or_acks : if JUST_OR_ACKS generate
    slave_ack_O <=
      master0_ACK_I or
      master1_ACK_I or
      master2_ACK_I or
      master3_ACK_I or
      master4_ACK_I or
      master5_ACK_I or
      master6_ACK_I or
      master7_ACK_I;
  end generate or_acks;

  slave_dat_O <= master_dat_i(to_integer(last_choice));

  slave_ERR_O <= '0';
  slave_RTY_O <= '0';


end architecture rtl;
