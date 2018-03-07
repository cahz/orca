library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
library work;
use work.utils.all;
use work.constants_pkg.all;
use work.constants_pkg.all;

entity arithmetic_unit is
  generic (
    REGISTER_SIZE       : positive range 32 to 32;
    SIMD_ENABLE         : boolean;
    SIGN_EXTENSION_SIZE : positive;
    MULTIPLY_ENABLE     : boolean;
    POWER_OPTIMIZED     : boolean;
    DIVIDE_ENABLE       : boolean;
    SHIFTER_MAX_CYCLES  : positive range 1 to 32;
    FAMILY              : string
    );
  port (
    clk                : in  std_logic;
    valid_instr        : in  std_logic;
    vcp_alu_used       : in  std_logic;
    from_execute_ready : in  std_logic;
    rs1_data           : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
    rs2_data           : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
    instruction        : in  std_logic_vector(31 downto 0);
    sign_extension     : in  std_logic_vector(SIGN_EXTENSION_SIZE-1 downto 0);
    current_pc         : in  unsigned(REGISTER_SIZE-1 downto 0);
    data_out           : out std_logic_vector(REGISTER_SIZE-1 downto 0);

    data_out_valid : out std_logic;
    alu_ready      : out std_logic;

    lve_data1        : in std_logic_vector(REGISTER_SIZE-1 downto 0);
    lve_data2        : in std_logic_vector(REGISTER_SIZE-1 downto 0);
    lve_source_valid : in std_logic
    );
end entity arithmetic_unit;

architecture rtl of arithmetic_unit is
  constant SHIFTER_USE_MULTIPLIER : boolean := MULTIPLY_ENABLE;

  alias func3  : std_logic_vector(2 downto 0) is instruction(INSTR_FUNC3'range);
  alias func7  : std_logic_vector(6 downto 0) is instruction(31 downto 25);
  alias opcode : std_logic_vector(6 downto 0) is instruction(6 downto 0);

  signal data1 : unsigned(REGISTER_SIZE-1 downto 0);
  signal data2 : unsigned(REGISTER_SIZE-1 downto 0);

  signal source_valid : std_logic;

  signal shift_amt            : unsigned(log2(REGISTER_SIZE)-1 downto 0);
  signal shift_value          : signed(REGISTER_SIZE downto 0);
  signal lshifted_result      : unsigned(REGISTER_SIZE-1 downto 0);
  signal rshifted_result      : unsigned(REGISTER_SIZE-1 downto 0);
  signal shifted_result_valid : std_logic;
  signal sub                  : signed(REGISTER_SIZE downto 0);
  signal sub_valid            : std_logic;
  signal slt_result           : unsigned(REGISTER_SIZE-1 downto 0);
  signal slt_result_valid     : std_logic;

  signal upper_immediate : signed(REGISTER_SIZE-1 downto 0);

  signal mul_srca          : signed(REGISTER_SIZE downto 0);
  signal mul_srcb          : signed(REGISTER_SIZE downto 0);
  signal mul_src_shift_amt : unsigned(log2(REGISTER_SIZE)-1 downto 0);
  signal mul_src_valid     : std_logic;

  signal mul_dest           : signed((REGISTER_SIZE+1)*2-1 downto 0);
  signal mul_dest_shift_amt : unsigned(log2(REGISTER_SIZE)-1 downto 0);
  signal mul_dest_valid     : std_logic;

  signal mul_ready  : std_logic;
  signal mul_select : std_logic;

  signal div_op1          : unsigned(REGISTER_SIZE-1 downto 0);
  signal div_op2          : unsigned(REGISTER_SIZE-1 downto 0);
  signal div_result       : signed(REGISTER_SIZE-1 downto 0);
  signal div_result_valid : std_logic;
  signal rem_result       : signed(REGISTER_SIZE-1 downto 0);
  signal quotient         : unsigned(REGISTER_SIZE-1 downto 0);
  signal remainder        : unsigned(REGISTER_SIZE-1 downto 0);

  --min signed value
  signal min_s : std_logic_vector(REGISTER_SIZE-1 downto 0);

  signal zero : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal neg1 : std_logic_vector(REGISTER_SIZE-1 downto 0);

  signal div_neg     : std_logic;
  signal div_neg_op1 : std_logic;
  signal div_neg_op2 : std_logic;
  signal div_ready   : std_logic;
  signal div_enable  : std_logic;
  signal div_select  : std_logic;

  signal sh_ready  : std_logic;
  signal sh_enable : std_logic;
  signal sh_select : std_logic;

  component shifter is
    generic (
      REGISTER_SIZE      : positive range 32 to 32;
      SHIFTER_MAX_CYCLES : positive range 1 to 32
      );
    port (
      clk                  : in  std_logic;
      shift_amt            : in  unsigned(log2(REGISTER_SIZE)-1 downto 0);
      shift_value          : in  signed(REGISTER_SIZE downto 0);
      lshifted_result      : out unsigned(REGISTER_SIZE-1 downto 0);
      rshifted_result      : out unsigned(REGISTER_SIZE-1 downto 0);
      shifted_result_valid : out std_logic;
      sh_enable            : in  std_logic
      );
  end component shifter;

  component divider is
    generic (
      REGISTER_SIZE : positive range 32 to 32
      );
    port (
      clk          : in std_logic;
      div_enable   : in std_logic;
      unsigned_div : in std_logic;
      rs1_data     : in unsigned(REGISTER_SIZE-1 downto 0);
      rs2_data     : in unsigned(REGISTER_SIZE-1 downto 0);

      quotient         : out unsigned(REGISTER_SIZE-1 downto 0);
      remainder        : out unsigned(REGISTER_SIZE-1 downto 0);
      div_result_valid : out std_logic
      );
  end component;

  signal func7_shift : boolean;

  --operand creation signals
  alias not_immediate is instruction(5);
  signal immediate_value  : unsigned(REGISTER_SIZE-1 downto 0);
  signal shifter_multiply : signed(REGISTER_SIZE downto 0);
  signal m_op1_msk        : std_logic;
  signal m_op2_msk        : std_logic;
  signal m_op1            : signed(REGISTER_SIZE downto 0);
  signal m_op2            : signed(REGISTER_SIZE downto 0);

  signal unsigned_div : std_logic;


  signal is_add : boolean;
  signal is_sub : std_logic;

  signal add : signed(REGISTER_SIZE downto 0);

  signal lve_instr      : std_logic;
  signal arith_msb_mask : std_logic_vector(3 downto 0);

  signal op1 : signed(REGISTER_SIZE downto 0);
  signal op2 : signed(REGISTER_SIZE downto 0);

  signal op1_msb, op2_msb : std_logic;

begin
  lve_instr <= vcp_alu_used when opcode = LVE32_OP or opcode = LVE64_OP else '0';

  immediate_value <= unsigned(sign_extension(REGISTER_SIZE-OP_IMM_IMMEDIATE_SIZE-1 downto 0) &
                              instruction(31 downto 20));
  data1 <= (others => '0') when source_valid = '0' and POWER_OPTIMIZED else
           unsigned(rs1_data);
  data2 <= (others => '0') when source_valid = '0' and POWER_OPTIMIZED else
           unsigned(rs2_data) when not_immediate = '1' else immediate_value;



  shift_amt <= data2(log2(REGISTER_SIZE)-1 downto 0) when not SHIFTER_USE_MULTIPLIER else
               data2(log2(REGISTER_SIZE)-1 downto 0) when instruction(14) = '0'else
               unsigned(-signed(data2(log2(REGISTER_SIZE)-1 downto 0)));
  shift_value <= signed((instruction(30) and rs1_data(rs1_data'left)) & rs1_data);




  with instruction(6 downto 5) select
    is_add <=
    instruction(14 downto 12) = "000"                           when "00",
    instruction(14 downto 12) = "000" and instruction(30) = '0' when "01",
    false                                                       when others;

  is_sub <= '0' when is_add else '1';

  with instruction(14 downto 12) select
    op1_msb <=
    '0'               when "110",
    '0'               when "111",
    '0'               when "011",
    data1(data1'left) when others;
  with instruction(14 downto 12) select
    op2_msb <=
    '0'               when "110",
    '0'               when "111",
    '0'               when "011",
    data2(data1'left) when others;

  op1 <= signed(op1_msb & data1);
  op2 <= signed(op2_msb & data2);

  add       <= op2 + op1;
  sub       <= add when is_add else op1 - op2;
  sub_valid <= source_valid;




  m_op1_msk <= '0' when instruction(13 downto 12) = "11" else '1';
  m_op2_msk <= not instruction(13);
  m_op1     <= signed((m_op1_msk and rs1_data(data1'left)) & data1);
  m_op2     <= signed((m_op2_msk and rs2_data(data2'left)) & data2);

  mul_srca          <= signed(m_op1) when instruction(25) = '1' or not SHIFTER_USE_MULTIPLIER else shifter_multiply;
  mul_srcb          <= signed(m_op2) when instruction(25) = '1' or not SHIFTER_USE_MULTIPLIER else shift_value;
  mul_src_shift_amt <= shift_amt;
  mul_src_valid     <= source_valid;


  source_valid <= lve_source_valid when lve_instr = '1' else
                  valid_instr;

  func7_shift <= func7 = "0000000" or func7 = "0100000";
  sh_enable   <= source_valid and sh_select;
  sh_select   <= '1' when
               (((opcode = ALU_OP and func7_shift) or
                 (opcode = ALUI_OP) or
                 (lve_instr = '1' and lve_source_valid = '1')) and
                (func3 = "001" or func3 = "101")) else
               '0';
  sh_ready <= shifted_result_valid or (not sh_select);

  SH_GEN0 : if SHIFTER_USE_MULTIPLIER generate
    shift_mul_gen : for n in shifter_multiply'left-1 downto 0 generate
      shifter_multiply(n) <= '1' when std_logic_vector(shift_amt) = std_logic_vector(to_unsigned(n, shift_amt'length)) else '0';
    end generate shift_mul_gen;
    shifter_multiply(shifter_multiply'left) <= '0';
    process(clk) is
    begin
      if rising_edge(clk) then
        lshifted_result <= unsigned(mul_dest(REGISTER_SIZE-1 downto 0));
        rshifted_result <= unsigned(mul_dest(REGISTER_SIZE*2-1 downto REGISTER_SIZE));
        if mul_dest_shift_amt = to_unsigned(0, mul_dest_shift_amt'length) then
          rshifted_result <= unsigned(mul_dest(REGISTER_SIZE-1 downto 0));
        end if;
        shifted_result_valid <= mul_dest_valid and sh_enable;
        if from_execute_ready = '1' then
          shifted_result_valid <= '0';
        end if;
      end if;
    end process;
  end generate SH_GEN0;
  SH_GEN1 : if not SHIFTER_USE_MULTIPLIER generate
    sh : shifter
      generic map (
        REGiSTER_SIZE      => REGISTER_SIZE,
        SHIFTER_MAX_CYCLES => SHIFTER_MAX_CYCLES
        )
      port map (
        clk                  => clk,
        shift_amt            => shift_amt,
        shift_value          => shift_value,
        lshifted_result      => lshifted_result,
        rshifted_result      => rshifted_result,
        shifted_result_valid => shifted_result_valid,
        sh_enable            => sh_enable
        );
  end generate SH_GEN1;

  slt_result       <= to_unsigned(1, REGISTER_SIZE) when sub(sub'left) = '1' else to_unsigned(0, REGISTER_SIZE);
  slt_result_valid <= sub_valid;

  upper_immediate(31 downto 12) <= signed(instruction(31 downto 12));
  upper_immediate(11 downto 0)  <= (others => '0');

  alu_proc : process(clk) is
    variable func              : std_logic_vector(2 downto 0);
    variable base_result       : unsigned(REGISTER_SIZE-1 downto 0);
    variable base_result_valid : std_logic;
    variable mul_result        : unsigned(REGISTER_SIZE-1 downto 0);
    variable mul_result_valid  : std_logic;
  begin
    if rising_edge(clk) then
      func := instruction(14 downto 12);

      base_result       := (others => '-');
      base_result_valid := '0';
      case func is
        when ADD_OP =>
          base_result       := unsigned(sub(REGISTER_SIZE-1 downto 0));
          base_result_valid := sub_valid;
        when SLL_OP =>
          base_result       := lshifted_result;
          base_result_valid := shifted_result_valid;
        when SLT_OP =>
          base_result       := slt_result;
          base_result_valid := slt_result_valid;
        when SLTU_OP =>
          base_result       := slt_result;
          base_result_valid := slt_result_valid;
        when XOR_OP =>
          base_result       := data1 xor data2;
          base_result_valid := source_valid;
        when SR_OP =>
          base_result       := rshifted_result;
          base_result_valid := shifted_result_valid;
        when OR_OP =>
          base_result       := data1 or data2;
          base_result_valid := source_valid;
        when AND_OP =>
          base_result       := data1 and data2;
          base_result_valid := source_valid;
        when others =>
          null;
      end case;

      mul_result       := (others => '-');
      mul_result_valid := '0';
      case func is
        when MUL_OP =>
          mul_result       := unsigned(mul_dest(REGISTER_SIZE-1 downto 0));
          mul_result_valid := mul_dest_valid;
        when MULH_OP =>
          mul_result       := unsigned(mul_dest(REGISTER_SIZE*2-1 downto REGISTER_SIZE));
          mul_result_valid := mul_dest_valid;
        when MULHSU_OP =>
          mul_result       := unsigned(mul_dest(REGISTER_SIZE*2-1 downto REGISTER_SIZE));
          mul_result_valid := mul_dest_valid;
        when MULHU_OP =>
          mul_result       := unsigned(mul_dest(REGISTER_SIZE*2-1 downto REGISTER_SIZE));
          mul_result_valid := mul_dest_valid;
        when DIV_OP =>
          mul_result       := unsigned(div_result);
          mul_result_valid := div_result_valid;
        when DIVU_OP =>
          mul_result       := unsigned(div_result);
          mul_result_valid := div_result_valid;
        when REM_OP =>
          mul_result       := unsigned(rem_result);
          mul_result_valid := div_result_valid;
        when REMU_OP =>
          mul_result       := unsigned(rem_result);
          mul_result_valid := div_result_valid;
        when others =>
          null;
      end case;

      data_out_valid <= '0';
      case OPCODE is
        when ALU_OP =>
          if func7 = mul_f7 and MULTIPLY_ENABLE then
            data_out       <= std_logic_vector(mul_result);
            data_out_valid <= mul_result_valid;
          else
            data_out       <= std_logic_vector(base_result);
            data_out_valid <= base_result_valid;
          end if;
        when LVE32_OP |LVE64_OP =>
          if vcp_alu_used = '1' then
            if instruction(25) = '1' and lve_instr = '1' and MULTIPLY_ENABLE then
              data_out       <= std_logic_vector(mul_result);
              data_out_valid <= mul_result_valid;
            else
              data_out       <= std_logic_vector(base_result);
              data_out_valid <= base_result_valid;
            end if;
          else
            data_out       <= (others => '-');
            data_out_valid <= '0';
          end if;
        when ALUI_OP =>
          data_out       <= std_logic_vector(base_result);
          data_out_valid <= base_result_valid;
        when LUI_OP =>
          data_out       <= std_logic_vector(upper_immediate);
          data_out_valid <= source_valid;
        when AUIPC_OP =>
          data_out       <= std_logic_vector(upper_immediate + signed(current_pc));
          data_out_valid <= source_valid;
        when others =>
          data_out       <= (others => '-');
          data_out_valid <= '0';
      end case;
    end if;
  end process;

  mul_gen : if MULTIPLY_ENABLE generate
    signal mul_enable : std_logic;

    signal mul_a            : signed(mul_srca'range);
    signal mul_b            : signed(mul_srcb'range);
    signal mul_ab_shift_amt : unsigned(log2(REGISTER_SIZE)-1 downto 0);
    signal mul_ab_valid     : std_logic;
  begin
    mul_select <= '1' when (((func7 = mul_f7 and opcode = ALU_OP) or
                             (instruction(30) = '0' and instruction(25) = '1' and lve_instr = '1'))
                            and instruction(14) = '0') else
                  '0';
    mul_enable <= source_valid and mul_select;
    mul_ready  <= mul_dest_valid or (not mul_select);

    lattice_mul_gen : if FAMILY = "LATTICE" generate
      signal afix  : unsigned(mul_a'length-2 downto 0);
      signal bfix  : unsigned(mul_b'length-2 downto 0);
      signal abfix : unsigned(mul_a'length-2 downto 0);

      signal mul_a_unsigned    : unsigned(mul_a'length-2 downto 0);
      signal mul_b_unsigned    : unsigned(mul_b'length-2 downto 0);
      signal mul_dest_unsigned : unsigned((mul_a_unsigned'length+mul_b_unsigned'length)-1 downto 0);
    begin
      afix <= unsigned(mul_a(mul_a'length-2 downto 0)) when mul_b(mul_b'left) = '1' else
              to_unsigned(0, afix'length);
      bfix <= unsigned(mul_b(mul_b'length-2 downto 0)) when mul_a(mul_a'left) = '1' else
              to_unsigned(0, afix'length);

      mul_a_unsigned <= unsigned(mul_a(mul_a'length-2 downto 0));
      mul_b_unsigned <= unsigned(mul_b(mul_b'length-2 downto 0));

      process(clk)
      begin
        if rising_edge(clk) then
          -- The multiplication of the absolute value of the source operands.
          mul_dest_unsigned <= mul_a_unsigned * mul_b_unsigned;
          abfix             <= afix + bfix;
        end if;
      end process;

      mul_dest(mul_a_unsigned'length-1 downto 0) <= signed(mul_dest_unsigned(mul_a_unsigned'length-1 downto 0));
      mul_dest(mul_dest_unsigned'left downto mul_a_unsigned'length) <=
        signed(mul_dest_unsigned(mul_dest_unsigned'left downto mul_a_unsigned'length) - abfix);
    end generate lattice_mul_gen;

    default_mul_gen : if FAMILY /= "LATTICE" generate
    begin
      process(clk)
      begin
        if rising_edge(clk) then
          mul_dest <= mul_a * mul_b;
        end if;
      end process;
    end generate default_mul_gen;

    process(clk)
    begin
      if rising_edge(clk) then
        --Register multiplier inputs

        mul_a <= mul_srca;
        mul_b <= mul_srcb;
        if POWER_OPTIMIZED and mul_enable = '0' and sh_enable = '0' then
          mul_a <= (others => '0');
          mul_b <= (others => '0');
        end if;
        mul_ab_shift_amt <= mul_src_shift_amt;
        mul_ab_valid     <= mul_src_valid;

        --Register multiplier output
        mul_dest_shift_amt <= mul_ab_shift_amt;
        mul_dest_valid     <= mul_ab_valid;

        --If we don't want to pipeline multiple multiplies (as is the case when we are not using LVE)
        --we only want mul_dest_valid to be high for one cycle
        if from_execute_ready = '1' then
          mul_ab_valid   <= '0';
          mul_dest_valid <= '0';
        end if;
      end if;
    end process;
  end generate mul_gen;

  no_mul_gen : if not MULTIPLY_ENABLE generate
    mul_dest_valid     <= '0';
    mul_dest_shift_amt <= (others => '-');
    mul_dest           <= (others => '-');
    mul_ready          <= '1';
  end generate no_mul_gen;

  divide_gen : if DIVIDE_ENABLE generate
  begin
    div_enable <= source_valid and div_select;
    div_select <= '1' when (func7 = mul_f7 and opcode = ALU_OP and instruction(14) = '1') else '0';
    div : divider
      generic map (
        REGISTER_SIZE => REGISTER_SIZE
        )
      port map (
        clk              => clk,
        div_enable       => div_enable,
        unsigned_div     => instruction(12),
        rs1_data         => unsigned(rs1_data),
        rs2_data         => unsigned(rs2_data),
        quotient         => quotient,
        remainder        => remainder,
        div_result_valid => div_result_valid
        );

    div_result <= signed(quotient);
    rem_result <= signed(remainder);

    div_ready <= div_result_valid or (not div_select);
  end generate divide_gen;
  no_divide_gen : if not DIVIDE_ENABLE generate
  begin
    div_ready        <= '1';
    div_result       <= (others => 'X');
    rem_result       <= (others => 'X');
    div_result_valid <= '0';
  end generate;

  alu_ready <= div_ready and mul_ready and sh_ready;
end architecture;


-------------------------------------------------------------------------------
-- Shifter
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
library work;
use work.utils.all;

entity shifter is
  generic (
    REGISTER_SIZE      : positive range 32 to 32;
    SHIFTER_MAX_CYCLES : positive range 1 to 32
    );
  port (
    clk                  : in  std_logic;
    shift_amt            : in  unsigned(log2(REGISTER_SIZE)-1 downto 0);
    shift_value          : in  signed(REGISTER_SIZE downto 0);
    lshifted_result      : out unsigned(REGISTER_SIZE-1 downto 0);
    rshifted_result      : out unsigned(REGISTER_SIZE-1 downto 0);
    shifted_result_valid : out std_logic;
    sh_enable            : in  std_logic
    );
end entity shifter;

architecture rtl of shifter is

  constant SHIFT_AMT_SIZE : natural := shift_amt'length;
  signal left_tmp         : signed(REGISTER_SIZE downto 0);
  signal right_tmp        : signed(REGISTER_SIZE downto 0);
begin
  assert SHIFTER_MAX_CYCLES = 1 or SHIFTER_MAX_CYCLES = 8 or SHIFTER_MAX_CYCLES = 32 report "Bad SHIFTER_MAX_CYCLES Value" severity failure;

  cycle1 : if SHIFTER_MAX_CYCLES = 1 generate
    left_tmp             <= SHIFT_LEFT(shift_value, to_integer(shift_amt));
    right_tmp            <= SHIFT_RIGHT(shift_value, to_integer(shift_amt));
    shifted_result_valid <= sh_enable;
  end generate cycle1;

  cycle4N : if SHIFTER_MAX_CYCLES = 8 generate
    signal left_nxt   : signed(REGISTER_SIZE downto 0);
    signal right_nxt  : signed(REGISTER_SIZE downto 0);
    signal count      : unsigned(SHIFT_AMT_SIZE downto 0);
    signal count_next : unsigned(SHIFT_AMT_SIZE downto 0);
    signal count_sub4 : unsigned(SHIFT_AMT_SIZE downto 0);
    signal shift4     : std_logic;
    type state_t is (IDLE, RUNNING, DONE);
    signal state      : state_t;
  begin
    count_sub4 <= count -4;
    shift4     <= not count_sub4(count_sub4'left);
    count_next <= count_sub4                when shift4 = '1' else count-1;
    left_nxt   <= SHIFT_LEFT(left_tmp, 4)   when shift4 = '1' else SHIFT_LEFT(left_tmp, 1);
    right_nxt  <= SHIFT_RIGHT(right_tmp, 4) when shift4 = '1' else SHIFT_RIGHT(right_tmp, 1);

    process(clk)
    begin
      if rising_edge(clk) then
        shifted_result_valid <= '0';
        if sh_enable = '1' then
          case state is
            when IDLE =>
              left_tmp  <= shift_value;
              right_tmp <= shift_value;
              count     <= unsigned("0" & shift_amt);
              if shift_amt /= 0 then
                state <= RUNNING;
              else
                state                <= IDLE;
                shifted_result_valid <= '1';
              end if;
            when RUNNING =>
              left_tmp  <= left_nxt;
              right_tmp <= right_nxt;
              count     <= count_next;
              if count = 1 or count = 4 then
                shifted_result_valid <= '1';
                state                <= DONE;
              end if;
            when Done =>
              state <= IDLE;
            when others =>
              null;
          end case;
        else
          state <= IDLE;
        end if;
      end if;
    end process;
  end generate cycle4N;

  cycle1N : if SHIFTER_MAX_CYCLES = 32 generate
    signal left_nxt  : signed(REGISTER_SIZE downto 0);
    signal right_nxt : signed(REGISTER_SIZE downto 0);
    signal count     : signed(SHIFT_AMT_SIZE-1 downto 0);
    type state_t is (IDLE, RUNNING, DONE);
    signal state     : state_t;
  begin
    left_nxt  <= SHIFT_LEFT(left_tmp, 1);
    right_nxt <= SHIFT_RIGHT(right_tmp, 1);

    process(clk)
    begin
      if rising_edge(clk) then
        shifted_result_valid <= '0';
        if sh_enable = '1' then
          case state is
            when IDLE =>
              left_tmp  <= shift_value;
              right_tmp <= shift_value;
              count     <= signed(shift_amt);
              if shift_amt /= 0 then
                state <= RUNNING;
              else
                state                <= IDLE;
                shifted_result_valid <= '1';
              end if;
            when RUNNING =>
              left_tmp  <= left_nxt;
              right_tmp <= right_nxt;
              count     <= count-1;
              if count = 1 then
                shifted_result_valid <= '1';
                state                <= DONE;
              end if;
            when Done =>
              state <= IDLE;
            when others =>
              null;
          end case;
        else
          state <= IDLE;
        end if;
      end if;
    end process;

  end generate cycle1N;

  rshifted_result <= unsigned(right_tmp(REGISTER_SIZE-1 downto 0));
  lshifted_result <= unsigned(left_tmp(REGISTER_SIZE-1 downto 0));

end architecture rtl;


-------------------------------------------------------------------------------
-- Divider
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
library work;
use work.utils.all;

entity divider is
  generic (
    REGISTER_SIZE : positive range 32 to 32
    );
  port (
    clk              : in  std_logic;
    div_enable       : in  std_logic;
    unsigned_div     : in  std_logic;
    rs1_data         : in  unsigned(REGISTER_SIZE-1 downto 0);
    rs2_data         : in  unsigned(REGISTER_SIZE-1 downto 0);
    quotient         : out unsigned(REGISTER_SIZE-1 downto 0);
    remainder        : out unsigned(REGISTER_SIZE-1 downto 0);
    div_result_valid : out std_logic
    );
end entity;

architecture rtl of divider is
  type div_state is (IDLE, DIVIDING, DONE);
  signal state       : div_state;
  signal count       : natural range REGISTER_SIZE-1 downto 0;
  signal numerator   : unsigned(REGISTER_SIZE-1 downto 0);
  signal denominator : unsigned(REGISTER_SIZE-1 downto 0);

  signal div_neg_op1       : std_logic;
  signal div_neg_op2       : std_logic;
  signal div_neg_quotient  : std_logic;
  signal div_neg_remainder : std_logic;

  signal div_zero     : boolean;
  signal div_overflow : boolean;

  signal div_res    : unsigned(REGISTER_SIZE-1 downto 0);
  signal rem_res    : unsigned(REGISTER_SIZE-1 downto 0);
  signal min_signed : unsigned(REGISTER_SIZE-1 downto 0);
begin

  div_neg_op1 <= not unsigned_div when signed(rs1_data) < 0 else '0';
  div_neg_op2 <= not unsigned_div when signed(rs2_data) < 0 else '0';

  min_signed(min_signed'left)            <= '1';
  min_signed(min_signed'left-1 downto 0) <= (others => '0');

  div_zero <= rs2_data = to_unsigned(0, REGISTER_SIZE);
  div_overflow <= (rs1_data = min_signed and
                   rs2_data = unsigned(to_signed(-1, REGISTER_SIZE)) and
                   unsigned_div = '0');


  numerator   <= unsigned(rs1_data) when div_neg_op1 = '0' else unsigned(-signed(rs1_data));
  denominator <= unsigned(rs2_data) when div_neg_op2 = '0' else unsigned(-signed(rs2_data));


  div_proc : process(clk)
    variable D     : unsigned(REGISTER_SIZE-1 downto 0);
    variable N     : unsigned(REGISTER_SIZE-1 downto 0);
    variable R     : unsigned(REGISTER_SIZE-1 downto 0);
    variable Q     : unsigned(REGISTER_SIZE-1 downto 0);
    variable sub   : unsigned(REGISTER_SIZE downto 0);
    variable Q_lsb : std_logic;
  begin

    if rising_edge(clk) then
      div_result_valid <= '0';
      if div_enable = '1' then
        case state is
          when IDLE =>
            div_neg_quotient  <= div_neg_op2 xor div_neg_op1;
            div_neg_remainder <= div_neg_op1;
            D                 := denominator;
            N                 := numerator;
            R                 := (others => '0');
            if div_zero then
              Q                := (others => '1');
              R                := rs1_data;
              div_result_valid <= '1';
            elsif div_overflow then
              Q                := min_signed;
              div_result_valid <= '1';
            else
              state <= DIVIDING;
              count <= Q'length - 1;
            end if;
          when DIVIDING =>
            R(REGISTER_SIZE-1 downto 1) := R(REGISTER_SIZE-2 downto 0);
            R(0)                        := N(N'left);
            N                           := SHIFT_LEFT(N, 1);

            Q_lsb := '0';
            sub   := ("0"&R)-("0"&D);
            if sub(sub'left) = '0' then
              R     := sub(R'range);
              Q_lsb := '1';
            end if;
            Q := Q(Q'left-1 downto 0) & Q_lsb;
            if count /= 0 then
              count <= count - 1;
            else
              div_result_valid <= '1';
              state            <= DONE;
            end if;
          when DONE =>
            state <= IDLE;
        end case;
        div_res <= Q;
        rem_res <= R;
      else
        state <= IDLE;
      end if;

    end if;  -- clk
  end process;

  remainder <= rem_res when div_neg_remainder = '0' else unsigned(-signed(rem_res));
  quotient  <= div_res when div_neg_quotient = '0'  else unsigned(-signed(div_res));
end architecture rtl;
