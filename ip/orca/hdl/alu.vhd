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
    SIGN_EXTENSION_SIZE : positive;
    POWER_OPTIMIZED     : boolean;
    MULTIPLY_ENABLE     : boolean;
    DIVIDE_ENABLE       : boolean;
    SHIFTER_MAX_CYCLES  : positive range 1 to 32;
    ENABLE_EXCEPTIONS   : boolean;
    FAMILY              : string
    );
  port (
    clk : in std_logic;

    to_alu_valid     : in  std_logic;
    to_alu_rs1_data  : in std_logic_vector(REGISTER_SIZE-1 downto 0);
    to_alu_rs2_data  : in std_logic_vector(REGISTER_SIZE-1 downto 0);
    from_alu_ready   : out std_logic;
    from_alu_illegal : out std_logic;

    vcp_source_valid : in std_logic;
    vcp_select       : in std_logic;

    from_execute_ready : in std_logic;
    instruction        : in std_logic_vector(31 downto 0);
    sign_extension     : in std_logic_vector(SIGN_EXTENSION_SIZE-1 downto 0);
    current_pc         : in unsigned(REGISTER_SIZE-1 downto 0);

    from_alu_data  : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    from_alu_valid : out std_logic
    );
end entity arithmetic_unit;

architecture rtl of arithmetic_unit is
  constant SHIFTER_USE_MULTIPLIER : boolean := MULTIPLY_ENABLE;

  alias func3  : std_logic_vector(2 downto 0) is instruction(INSTR_FUNC3'range);
  alias func7  : std_logic_vector(6 downto 0) is instruction(INSTR_FUNC7'range);
  alias opcode : std_logic_vector(6 downto 0) is instruction(INSTR_OPCODE'range);

  signal data1 : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal data2 : std_logic_vector(REGISTER_SIZE-1 downto 0);

  signal source_valid : std_logic;

  --Submodules: LUI, AUIPC, add/sub/logic, shift, mul, div
  signal lui_select          : std_logic;
  signal auipc_select        : std_logic;
  signal addsub_logic_select : std_logic;
  signal shift_select        : std_logic;
  signal from_shift_ready    : std_logic;
  signal from_shift_valid    : std_logic;
  signal mul_select          : std_logic;
  signal from_mul_ready      : std_logic;
  signal from_mul_data       : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal from_mul_valid      : std_logic;
  signal div_select          : std_logic;
  signal from_div_ready      : std_logic;
  signal from_div_valid      : std_logic;
  signal from_div_data       : std_logic_vector(REGISTER_SIZE-1 downto 0);

  signal from_base_alu_valid : std_logic;
  signal from_base_alu_data  : std_logic_vector(REGISTER_SIZE-1 downto 0);

  signal shift_amt       : unsigned(log2(REGISTER_SIZE)-1 downto 0);
  signal shift_value     : signed(REGISTER_SIZE downto 0);
  signal lshifted_result : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal rshifted_result : std_logic_vector(REGISTER_SIZE-1 downto 0);

  signal upper_immediate : signed(REGISTER_SIZE-1 downto 0);

  signal mul_dest               : std_logic_vector((REGISTER_SIZE+1)*2-1 downto 0);
  signal mul_dest_shift_by_zero : std_logic;
  signal mul_dest_valid         : std_logic;

  component shifter is
    generic (
      REGISTER_SIZE      : positive range 32 to 32;
      SHIFTER_MAX_CYCLES : positive range 1 to 32
      );
    port (
      clk              : in  std_logic;
      shift_amt        : in  unsigned(log2(REGISTER_SIZE)-1 downto 0);
      shift_value      : in  signed(REGISTER_SIZE downto 0);
      lshifted_result  : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      rshifted_result  : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      from_shift_valid : out std_logic;
      shift_enable     : in  std_logic
      );
  end component shifter;

  component divider is
    generic (
      REGISTER_SIZE : positive range 32 to 32
      );
    port (
      clk          : in std_logic;
      div_enable   : in std_logic;
      div_unsigned : in std_logic;
      rs1_data     : in std_logic_vector(REGISTER_SIZE-1 downto 0);
      rs2_data     : in std_logic_vector(REGISTER_SIZE-1 downto 0);

      quotient       : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      remainder      : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      from_div_valid : out std_logic
      );
  end component;

  --operand creation signals
  alias not_immediate     : std_logic is instruction(5);
  signal immediate_value  : signed(REGISTER_SIZE-1 downto 0);
  signal shifter_multiply : signed(REGISTER_SIZE downto 0);
  signal m_op1_mask       : std_logic;
  signal m_op2_mask       : std_logic;
  signal m_op1            : signed(REGISTER_SIZE downto 0);
  signal m_op2            : signed(REGISTER_SIZE downto 0);

  signal is_add     : boolean;
  signal op1        : signed(REGISTER_SIZE downto 0);
  signal op2        : signed(REGISTER_SIZE downto 0);
  signal op1_msb    : std_logic;
  signal op2_msb    : std_logic;
  signal addsub     : signed(REGISTER_SIZE downto 0);
  signal slt_result : std_logic_vector(REGISTER_SIZE-1 downto 0);
begin
  --Decode instruction to select submodule.  All paths must decode to exactly
  --one submodule.
  --ASSUMES only ALU_OP | VCP32_OP | VCP64_OP | ALUI_OP | LUI_OP | AUIPC_OP for opcode.
  process (opcode, func3, func7, vcp_select) is
  begin
    lui_select          <= '0';
    auipc_select        <= '0';
    shift_select        <= '0';
    addsub_logic_select <= '0';
    div_select          <= '0';
    mul_select          <= '0';
    from_alu_illegal    <= '0';

    --Top bit and bottom two bits are identical for all cases we care about
    case opcode(5 downto 2) is
      when "1101" =>                    --LUI_OP(5 downto 2)
        lui_select <= '1';
      when "0101" =>                    --AUIPC_OP(5 downto 2)
        auipc_select <= '1';
      when "0100" =>                    --ALUI_OP(5 downto 2)
        case func3 is
          when SLL_FUNC3 =>
            if ENABLE_EXCEPTIONS then
              if func7 = SHIFT_LOGIC_FUNC7 then
                shift_select <= '1';
              else
                from_alu_illegal <= '1';
              end if;
            else
              shift_select <= '1';
            end if;
          when SR_FUNC3 =>
            if ENABLE_EXCEPTIONS then
              case func7 is
                when SHIFT_LOGIC_FUNC7 | SHIFT_ARITH_FUNC7 =>
                  shift_select <= '1';
                when others =>
                  from_alu_illegal <= '1';
              end case;
            else
              shift_select <= '1';
            end if;
          when others =>
            addsub_logic_select <= '1';
        end case;
      when others =>                    --ALU_OP or from VCP
        if (MULTIPLY_ENABLE and func3(2) = '0' and
            func7(5) = MUL_FUNC7(5) and func7(0) = MUL_FUNC7(0) and
            (vcp_select = '1' or (func7(6) = MUL_FUNC7(6) and func7(4 downto 1) = MUL_FUNC7(4 downto 1)))) then
          mul_select <= '1';
        elsif (ENABLE_EXCEPTIONS and func3(2) = '0' and
               func7(5) = MUL_FUNC7(5) and func7(0) = MUL_FUNC7(0) and
               (vcp_select = '1' or (func7(6) = MUL_FUNC7(6) and func7(4 downto 1) = MUL_FUNC7(4 downto 1)))) then
          from_alu_illegal <= '1';
        elsif (DIVIDE_ENABLE and func3(2) = '1' and
               func7(5) = MUL_FUNC7(5) and func7(0) = MUL_FUNC7(0) and
               (vcp_select = '1' or (func7(6) = MUL_FUNC7(6) and func7(4 downto 1) = MUL_FUNC7(4 downto 1)))) then
          div_select <= '1';
        elsif (ENABLE_EXCEPTIONS and func3(2) = '1' and
               func7(5) = MUL_FUNC7(5) and func7(0) = MUL_FUNC7(0) and
               (vcp_select = '1' or (func7(6) = MUL_FUNC7(6) and func7(4 downto 1) = MUL_FUNC7(4 downto 1)))) then
          from_alu_illegal <= '1';
        else
          case func3 is
            when SLL_FUNC3 =>
              if ENABLE_EXCEPTIONS then
                if func7 = SHIFT_LOGIC_FUNC7 then
                  shift_select <= '1';
                else
                  if vcp_select = '1' then
                    shift_select <= '1';
                  else
                    from_alu_illegal <= '1';
                  end if;
                end if;
              else
                shift_select <= '1';
              end if;
            when SR_FUNC3 =>
              if ENABLE_EXCEPTIONS then
                case func7 is
                  when SHIFT_LOGIC_FUNC7 | SHIFT_ARITH_FUNC7 =>
                    shift_select <= '1';
                  when others =>
                    if vcp_select = '1' then
                      shift_select <= '1';
                    else
                      from_alu_illegal <= '1';
                    end if;
                end case;
              else
                shift_select <= '1';
              end if;
            when ADDSUB_FUNC3 =>
              if ENABLE_EXCEPTIONS then
                case func7 is
                  when ADDSUB_ADD_FUNC7 | ADDSUB_SUB_FUNC7 =>
                    addsub_logic_select <= '1';
                  when others =>
                    if vcp_select = '1' then
                      addsub_logic_select <= '1';
                    else
                      from_alu_illegal <= '1';
                    end if;
                end case;
              else
                addsub_logic_select <= '1';
              end if;
            when others =>  --SLT_FUNC3 | SLTU_FUNC3 | XOR_FUNC3 | OR_FUNC3 | AND_FUNC3
              if ENABLE_EXCEPTIONS then
                if func7 = ALU_FUNC7 then
                  addsub_logic_select <= '1';
                else
                  if vcp_select = '1' then
                    addsub_logic_select <= '1';
                  else
                    from_alu_illegal <= '1';
                  end if;
                end if;
              else
                addsub_logic_select <= '1';
              end if;
          end case;
        end if;
    end case;
  end process;

  immediate_value <= signed(sign_extension(REGISTER_SIZE-OP_IMM_IMMEDIATE_SIZE-1 downto 0) &
                            instruction(31 downto 20));
  data1 <= (others => '0') when source_valid = '0' and POWER_OPTIMIZED else
           to_alu_rs1_data;
  data2 <= (others => '0') when source_valid = '0' and POWER_OPTIMIZED else
           to_alu_rs2_data when not_immediate = '1' else std_logic_vector(immediate_value);



  shift_amt <= unsigned(data2(log2(REGISTER_SIZE)-1 downto 0)) when not SHIFTER_USE_MULTIPLIER else
               unsigned(data2(log2(REGISTER_SIZE)-1 downto 0)) when func3(2) = '0'else
               unsigned(-signed(data2(log2(REGISTER_SIZE)-1 downto 0)));
  shift_value <= signed((instruction(30) and to_alu_rs1_data(to_alu_rs1_data'left)) & to_alu_rs1_data);




  is_add <= func3 = ADDSUB_FUNC3 when instruction(5) = '0' else
            func3 = ADDSUB_FUNC3 and instruction(30) = '0';

  --Sign extend; only matters for SLT{I}/SLT{I}U
  op1_msb <= data1(data1'left) when instruction(12) = '0' else '0';
  op2_msb <= data2(data2'left) when instruction(12) = '0' else '0';

  op1 <= signed(op1_msb & data1);
  op2 <= signed(op2_msb & data2);

  addsub <= op1 + op2 when is_add else op1 - op2;




  m_op1_mask <= '0' when instruction(13 downto 12) = "11" else '1';
  m_op2_mask <= not instruction(13);
  m_op1      <= signed((m_op1_mask and to_alu_rs1_data(data1'left)) & data1);
  m_op2      <= signed((m_op2_mask and to_alu_rs2_data(data2'left)) & data2);

  source_valid <= vcp_source_valid when vcp_select = '1' else
                  to_alu_valid;

  from_shift_ready <= from_shift_valid or (not shift_select);

  shift_using_multiplier_gen : if SHIFTER_USE_MULTIPLIER generate
    assert MULTIPLY_ENABLE report
      "Error; multiplier must be enabled when SHIFTER_USE_MULTIPLIER is true"
      severity failure;

    shift_mul_gen : for gbit in shifter_multiply'left-1 downto 0 generate
      shifter_multiply(gbit) <= '1' when std_logic_vector(shift_amt) = std_logic_vector(to_unsigned(gbit, shift_amt'length)) else '0';
    end generate shift_mul_gen;
    shifter_multiply(shifter_multiply'left) <= '0';

    process(clk) is
    begin
      if rising_edge(clk) then
        lshifted_result <= mul_dest(REGISTER_SIZE-1 downto 0);
        rshifted_result <= mul_dest(REGISTER_SIZE*2-1 downto REGISTER_SIZE);
        if mul_dest_shift_by_zero = '1' then
          rshifted_result <= mul_dest(REGISTER_SIZE-1 downto 0);
        end if;
        from_shift_valid <= mul_dest_valid and shift_select;

        if from_execute_ready = '1' then
          from_shift_valid <= '0';
        end if;
      end if;
    end process;
  end generate shift_using_multiplier_gen;
  shift_using_shifter_gen : if not SHIFTER_USE_MULTIPLIER generate
    signal shift_enable : std_logic;
  begin
    shift_enable <= source_valid and shift_select;
    sh : shifter
      generic map (
        REGiSTER_SIZE      => REGISTER_SIZE,
        SHIFTER_MAX_CYCLES => SHIFTER_MAX_CYCLES
        )
      port map (
        clk              => clk,
        shift_amt        => shift_amt,
        shift_value      => shift_value,
        lshifted_result  => lshifted_result,
        rshifted_result  => rshifted_result,
        from_shift_valid => from_shift_valid,
        shift_enable     => shift_enable
        );
  end generate shift_using_shifter_gen;

  slt_result(slt_result'left downto 1) <= (others => '0');
  slt_result(0)                        <= addsub(addsub'left);

  upper_immediate(31 downto 12) <= signed(instruction(31 downto 12));
  upper_immediate(11 downto 0)  <= (others => '0');

  --Base ALU (Add/sub, logical ops, shifts)
  with func3 select
    from_base_alu_data <=
    data1 and data2                                    when AND_FUNC3,
    data1 or data2                                     when OR_FUNC3,
    rshifted_result                                    when SR_FUNC3,
    data1 xor data2                                    when XOR_FUNC3,
    slt_result                                         when SLT_FUNC3 | SLTU_FUNC3,
    lshifted_result                                    when SLL_FUNC3,
    std_logic_vector(addsub(REGISTER_SIZE-1 downto 0)) when others;

  from_base_alu_valid <=
    source_valid when addsub_logic_select = '1' else
    from_shift_valid;

  --Mux in and register final result
  process(clk) is
  begin
    if rising_edge(clk) then
      if lui_select = '1' then
        from_alu_data  <= std_logic_vector(upper_immediate);
        from_alu_valid <= source_valid;
      elsif auipc_select = '1' then
        from_alu_data  <= std_logic_vector(upper_immediate + signed(current_pc));
        from_alu_valid <= source_valid;
      elsif div_select = '1' then
        from_alu_data  <= from_div_data;
        from_alu_valid <= from_div_valid;
      elsif mul_select = '1' then
        from_alu_data  <= from_mul_data;
        from_alu_valid <= from_mul_valid;
      else
        from_alu_data  <= from_base_alu_data;
        from_alu_valid <= from_base_alu_valid;
      end if;
    end if;
  end process;

  mul_gen : if MULTIPLY_ENABLE generate
    signal mul_enable : std_logic;

    signal mul_srca      : signed(REGISTER_SIZE downto 0);
    signal mul_srcb      : signed(REGISTER_SIZE downto 0);
    signal mul_src_valid : std_logic;

    signal mul_a                : signed(mul_srca'range);
    signal mul_b                : signed(mul_srcb'range);
    signal mul_ab_shift_by_zero : std_logic;
    signal mul_ab_valid         : std_logic;
  begin
    mul_enable <= source_valid and (mul_select or shift_select) when SHIFTER_USE_MULTIPLIER else
                  source_valid and mul_select;
    from_mul_ready <= mul_dest_valid or (not mul_select);

    mul_srca      <= m_op1 when instruction(25) = '1' or (not SHIFTER_USE_MULTIPLIER) else shifter_multiply;
    mul_srcb      <= m_op2 when instruction(25) = '1' or (not SHIFTER_USE_MULTIPLIER) else shift_value;
    mul_src_valid <= source_valid;

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

      mul_dest(mul_a_unsigned'length-1 downto 0) <=
        std_logic_vector(mul_dest_unsigned(mul_a_unsigned'length-1 downto 0));
      mul_dest(mul_dest_unsigned'left downto mul_a_unsigned'length) <=
        std_logic_vector(mul_dest_unsigned(mul_dest_unsigned'left downto mul_a_unsigned'length) - abfix);
    end generate lattice_mul_gen;

    default_mul_gen : if FAMILY /= "LATTICE" generate
    begin
      process(clk)
      begin
        if rising_edge(clk) then
          mul_dest <= std_logic_vector(mul_a * mul_b);
        end if;
      end process;
    end generate default_mul_gen;

    process(clk)
    begin
      if rising_edge(clk) then
        --Register multiplier inputs

        mul_a <= mul_srca;
        mul_b <= mul_srcb;
        if POWER_OPTIMIZED and mul_select = '0' and shift_select = '0' then
          mul_a <= (others => '0');
          mul_b <= (others => '0');
        end if;
        if shift_amt = to_unsigned(0, shift_amt'length) then
          mul_ab_shift_by_zero <= '1';
        else
          mul_ab_shift_by_zero <= '0';
        end if;
        mul_ab_valid <= mul_src_valid;

        --Register multiplier output
        mul_dest_shift_by_zero <= mul_ab_shift_by_zero;
        mul_dest_valid         <= mul_ab_valid;

        --If we don't want to pipeline multiple multiplies (as is the case when we are not using VCP)
        --we only want mul_dest_valid to be high for one cycle
        if from_execute_ready = '1' then
          mul_ab_valid   <= '0';
          mul_dest_valid <= '0';
        end if;
      end if;
    end process;

    --MUL/MULH/MULHSU/MULHU select
    from_mul_data <= mul_dest(REGISTER_SIZE-1 downto 0) when func3(1 downto 0) = MUL_FUNC3(1 downto 0) else
                     mul_dest(REGISTER_SIZE*2-1 downto REGISTER_SIZE);
    from_mul_valid <= mul_dest_valid and mul_select;
  end generate mul_gen;

  no_mul_gen : if not MULTIPLY_ENABLE generate
    mul_dest_valid         <= '0';
    mul_dest_shift_by_zero <= 'X';
    mul_dest               <= (others => 'X');
    from_mul_ready         <= '1';
    from_mul_data          <= (others => 'X');
    from_mul_valid         <= '0';
  end generate no_mul_gen;

  divide_gen : if DIVIDE_ENABLE generate
    signal div_enable : std_logic;
    signal quotient   : std_logic_vector(REGISTER_SIZE-1 downto 0);
    signal remainder  : std_logic_vector(REGISTER_SIZE-1 downto 0);
  begin
    div_enable <= source_valid and div_select;
    div : divider
      generic map (
        REGISTER_SIZE => REGISTER_SIZE
        )
      port map (
        clk            => clk,
        div_enable     => div_enable,
        div_unsigned   => instruction(12),
        rs1_data       => to_alu_rs1_data,
        rs2_data       => to_alu_rs2_data,
        quotient       => quotient,
        remainder      => remainder,
        from_div_valid => from_div_valid
        );

    from_div_data <=
      quotient when func3(1) = '0' else
      remainder;

    from_div_ready <= from_div_valid or (not div_select);
  end generate divide_gen;
  no_divide_gen : if not DIVIDE_ENABLE generate
  begin
    from_div_ready <= '1';
    from_div_data  <= (others => 'X');
    from_div_valid <= '0';
  end generate;

  from_alu_ready <= from_div_ready and from_mul_ready and from_shift_ready;
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
    clk              : in  std_logic;
    shift_amt        : in  unsigned(log2(REGISTER_SIZE)-1 downto 0);
    shift_value      : in  signed(REGISTER_SIZE downto 0);
    lshifted_result  : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    rshifted_result  : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    from_shift_valid : out std_logic;
    shift_enable     : in  std_logic
    );
end entity shifter;

architecture rtl of shifter is

  constant SHIFT_AMT_SIZE : natural := shift_amt'length;
  signal left_tmp         : signed(REGISTER_SIZE downto 0);
  signal right_tmp        : signed(REGISTER_SIZE downto 0);
begin
  assert SHIFTER_MAX_CYCLES = 1 or SHIFTER_MAX_CYCLES = 8 or SHIFTER_MAX_CYCLES = 32 report "Bad SHIFTER_MAX_CYCLES Value" severity failure;

  cycle1 : if SHIFTER_MAX_CYCLES = 1 generate
    left_tmp         <= SHIFT_LEFT(shift_value, to_integer(shift_amt));
    right_tmp        <= SHIFT_RIGHT(shift_value, to_integer(shift_amt));
    from_shift_valid <= shift_enable;
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
    count_sub4 <= count - 4;
    shift4     <= not count_sub4(count_sub4'left);
    count_next <= count_sub4                when shift4 = '1' else count-1;
    left_nxt   <= SHIFT_LEFT(left_tmp, 4)   when shift4 = '1' else SHIFT_LEFT(left_tmp, 1);
    right_nxt  <= SHIFT_RIGHT(right_tmp, 4) when shift4 = '1' else SHIFT_RIGHT(right_tmp, 1);

    process(clk)
    begin
      if rising_edge(clk) then
        from_shift_valid <= '0';
        if shift_enable = '1' then
          case state is
            when IDLE =>
              left_tmp  <= shift_value;
              right_tmp <= shift_value;
              count     <= unsigned("0" & shift_amt);
              if shift_amt /= 0 then
                state <= RUNNING;
              else
                state            <= IDLE;
                from_shift_valid <= '1';
              end if;
            when RUNNING =>
              left_tmp  <= left_nxt;
              right_tmp <= right_nxt;
              count     <= count_next;
              if count = 1 or count = 4 then
                from_shift_valid <= '1';
                state            <= DONE;
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
        from_shift_valid <= '0';
        if shift_enable = '1' then
          case state is
            when IDLE =>
              left_tmp  <= shift_value;
              right_tmp <= shift_value;
              count     <= signed(shift_amt);
              if shift_amt /= 0 then
                state <= RUNNING;
              else
                state            <= IDLE;
                from_shift_valid <= '1';
              end if;
            when RUNNING =>
              left_tmp  <= left_nxt;
              right_tmp <= right_nxt;
              count     <= count-1;
              if count = 1 then
                from_shift_valid <= '1';
                state            <= DONE;
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

  rshifted_result <= std_logic_vector(right_tmp(REGISTER_SIZE-1 downto 0));
  lshifted_result <= std_logic_vector(left_tmp(REGISTER_SIZE-1 downto 0));

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
    clk            : in  std_logic;
    div_enable     : in  std_logic;
    div_unsigned   : in  std_logic;
    rs1_data       : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
    rs2_data       : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
    quotient       : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    remainder      : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    from_div_valid : out std_logic
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

  signal div_by_zero  : boolean;
  signal div_overflow : boolean;

  signal div_res    : unsigned(REGISTER_SIZE-1 downto 0);
  signal rem_res    : unsigned(REGISTER_SIZE-1 downto 0);
  signal min_signed : signed(REGISTER_SIZE-1 downto 0);
begin

  div_neg_op1 <= not div_unsigned when signed(rs1_data) < 0 else '0';
  div_neg_op2 <= not div_unsigned when signed(rs2_data) < 0 else '0';

  min_signed(min_signed'left)            <= '1';
  min_signed(min_signed'left-1 downto 0) <= (others => '0');

  div_by_zero <= unsigned(rs2_data) = to_unsigned(0, REGISTER_SIZE);
  div_overflow <= (signed(rs1_data) = min_signed and
                   signed(rs2_data) = to_signed(-1, REGISTER_SIZE) and
                   div_unsigned = '0');


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
      from_div_valid <= '0';
      if div_enable = '1' then
        case state is
          when IDLE =>
            div_neg_quotient  <= div_neg_op2 xor div_neg_op1;
            div_neg_remainder <= div_neg_op1;
            D                 := denominator;
            N                 := numerator;
            R                 := (others => '0');
            if div_by_zero then
              Q                 := (others => '1');
              R                 := unsigned(rs1_data);
              from_div_valid    <= '1';
              div_neg_remainder <= '0';
              div_neg_quotient  <= '0';
            elsif div_overflow then
              Q                 := unsigned(min_signed);
              from_div_valid    <= '1';
              div_neg_remainder <= '0';
              div_neg_quotient  <= '0';
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
              from_div_valid <= '1';
              state          <= DONE;
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

  remainder <= std_logic_vector(rem_res) when div_neg_remainder = '0' else std_logic_vector(-signed(rem_res));
  quotient  <= std_logic_vector(div_res) when div_neg_quotient = '0'  else std_logic_vector(-signed(div_res));
end architecture rtl;
