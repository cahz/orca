library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use work.constants_pkg.all;
use work.utils.all;
--use IEEE.std_logic_arith.all;

entity branch_unit is
  generic (
    REGISTER_SIZE       : positive range 32 to 32;
    SIGN_EXTENSION_SIZE : positive;
    BTB_ENTRIES         : natural
    );
  port (
    clk   : in std_logic;
    reset : in std_logic;

    to_branch_valid   : in  std_logic;
    rs1_data          : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
    rs2_data          : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
    current_pc        : in  unsigned(REGISTER_SIZE-1 downto 0);
    predicted_pc      : in  unsigned(REGISTER_SIZE-1 downto 0);
    instruction       : in  std_logic_vector(31 downto 0);
    sign_extension    : in  std_logic_vector(SIGN_EXTENSION_SIZE-1 downto 0);

    from_branch_valid : out std_logic;
    from_branch_data  : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    to_branch_ready   : in  std_logic;

    to_pc_correction_data      : out unsigned(REGISTER_SIZE-1 downto 0);
    to_pc_correction_source_pc : out unsigned(REGISTER_SIZE-1 downto 0);
    to_pc_correction_valid     : out std_logic;
    from_pc_correction_ready   : in  std_logic
    );
end entity branch_unit;


architecture rtl of branch_unit is
  --These signals must be one bit larger than a register
  signal op1      : signed(REGISTER_SIZE downto 0);
  signal op2      : signed(REGISTER_SIZE downto 0);
  signal sub      : signed(REGISTER_SIZE downto 0);
  signal msb_mask : std_logic;

  signal jal_imm        : unsigned(REGISTER_SIZE-1 downto 0);
  signal jalr_imm       : unsigned(REGISTER_SIZE-1 downto 0);
  signal b_imm          : unsigned(REGISTER_SIZE-1 downto 0);
  signal branch_target  : unsigned(REGISTER_SIZE-1 downto 0);
  signal nbranch_target : unsigned(REGISTER_SIZE-1 downto 0);
  signal jalr_target    : unsigned(REGISTER_SIZE-1 downto 0);
  signal jal_target     : unsigned(REGISTER_SIZE-1 downto 0);
  signal target_pc      : unsigned(REGISTER_SIZE-1 downto 0);

  signal lt_flag : std_logic;
  signal eq_flag : std_logic;

  signal take_if_branch : std_logic;

  alias func3  : std_logic_vector(2 downto 0) is instruction(INSTR_FUNC3'range);
  alias opcode : std_logic_vector(6 downto 0) is instruction(6 downto 0);

  signal is_jal_op  : std_logic;
  signal is_jalr_op : std_logic;
  signal is_br_op   : std_logic;
begin
  with func3 select
    msb_mask <=
    '0' when BLTU_OP,
    '0' when BGEU_OP,
    '1' when others;

  op1 <= signed((msb_mask and rs1_data(rs1_data'left)) & rs1_data);
  op2 <= signed((msb_mask and rs2_data(rs2_data'left)) & rs2_data);
  sub <= op1 - op2;

  eq_flag <= '1' when rs1_data = rs2_data else '0';
  lt_flag <= sub(sub'left);

  with func3 select
    take_if_branch <=
    eq_flag                  when beq_OP,
    not eq_flag              when bne_OP,
    lt_flag                  when blt_OP,
    (not lt_flag) or eq_flag when bge_OP,
    lt_flag                  when bltu_OP,
    (not lt_flag) or eq_flag when bgeu_OP,
    '0'                      when others;

  b_imm <= unsigned(sign_extension(REGISTER_SIZE-13 downto 0) &
                    instruction(7) & instruction(30 downto 25) &instruction(11 downto 8) & "0");

  jalr_imm <= unsigned(sign_extension(REGISTER_SIZE-12-1 downto 0) &
                       instruction(31 downto 21) & "0");
  jal_imm <= unsigned(RESIZE(signed(instruction(31) & instruction(19 downto 12) & instruction(20) &
                                    instruction(30 downto 21)&"0"), REGISTER_SIZE));

  no_predictor_gen : if BTB_ENTRIES = 0 generate
    signal mispredict : std_logic;
  begin
    --If there's no branch predictor, any taken branch/jump is a mispredict, and
    --there's no need to use PC+4 (nbranch_target) as a correction
    target_pc <=
      jal_target  when is_jal_op = '1' else
      jalr_target when is_jalr_op = '1' else
      branch_target;
    mispredict <= (take_if_branch and is_br_op) or is_jal_op or is_jalr_op;
    process(clk)
    begin
      if rising_edge(clk) then
        if from_pc_correction_ready = '1' then
          to_pc_correction_valid <= '0';
        end if;

        if to_branch_ready = '1' then
          if to_branch_valid = '1' then
            to_pc_correction_data      <= target_pc;
            to_pc_correction_source_pc <= current_pc;

            if mispredict = '1' then
              to_pc_correction_valid <= '1';
            end if;
          end if;
        end if;

        if reset = '1' then
          to_pc_correction_valid <= '0';
        end if;
      end if;
    end process;
  end generate no_predictor_gen;
  has_predictor_gen : if BTB_ENTRIES > 0 generate
    signal previously_targeted_pc                 : unsigned(REGISTER_SIZE-1 downto 0);
    signal previously_predicted_pc                : unsigned(REGISTER_SIZE-1 downto 0);
    signal to_pc_correction_valid_if_mispredicted : std_logic;
    signal was_mispredicted                       : std_logic;
  begin
    target_pc <=
      jalr_target   when is_jalr_op = '1' else
      jal_target    when is_jal_op = '1' else
      branch_target when is_br_op = '1' and take_if_branch = '1' else
      nbranch_target;
    process(clk)
    begin
      if rising_edge(clk) then
        if from_pc_correction_ready = '1' then
          to_pc_correction_valid_if_mispredicted <= '0';
        end if;

        if to_branch_ready = '1' then
          if to_branch_valid = '1' then
            previously_targeted_pc     <= target_pc;
            to_pc_correction_source_pc <= current_pc;
            previously_predicted_pc    <= predicted_pc;

            to_pc_correction_valid_if_mispredicted <= '1';
          end if;
        end if;

        if reset = '1' then
          to_pc_correction_valid_if_mispredicted <= '0';
        end if;
      end if;
    end process;
    to_pc_correction_data  <= previously_targeted_pc;
    --Note that computing mispredict during the execute cycle (as is done in
    --the no BTB generate) is more readable/consistent.  The latter part of the
    --mispredict calculation was moved to the next cycle only because there is
    --a long combinational path and it can be the critical path in
    --implementations that don't do register retiming.
    was_mispredicted       <= '1' when previously_targeted_pc /= previously_predicted_pc else '0';
    to_pc_correction_valid <= to_pc_correction_valid_if_mispredicted and was_mispredicted;
  end generate has_predictor_gen;

  branch_target  <= b_imm + current_pc;
  nbranch_target <= to_unsigned(4, REGISTER_SIZE) + current_pc;
  jalr_target    <= jalr_imm + unsigned(rs1_data);
  jal_target     <= jal_imm + current_pc;

  is_jal_op  <= '1' when opcode = JAL_OP    else '0';
  is_jalr_op <= '1' when opcode = JALR_OP   else '0';
  is_br_op   <= '1' when opcode = BRANCH_OP else '0';

  process(clk)
  begin
    if rising_edge(clk) then
      from_branch_valid <= '0';

      if to_branch_ready = '1' then
        from_branch_data  <= std_logic_vector(nbranch_target);
        from_branch_valid <= to_branch_valid and (is_jal_op or is_jalr_op);
      end if;

      if reset = '1' then
        from_branch_valid <= '0';
      end if;
    end if;
  end process;
end architecture;
