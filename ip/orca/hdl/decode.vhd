library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.rv_components.all;
use work.constants_pkg.all;
use work.utils.all;

entity decode is
  generic (
    REGISTER_SIZE          : positive range 32 to 32;
    SIGN_EXTENSION_SIZE    : positive;
    VCP_ENABLE             : vcp_type;
    PIPELINE_STAGES        : natural range 1 to 2;
    WRITE_FIRST_SMALL_RAMS : boolean;
    FAMILY                 : string
    );
  port (
    clk   : in std_logic;
    reset : in std_logic;

    to_rf_select : in std_logic_vector(REGISTER_NAME_SIZE-1 downto 0);
    to_rf_data   : in std_logic_vector(REGISTER_SIZE-1 downto 0);
    to_rf_valid  : in std_logic;

    to_decode_instruction              : in     std_logic_vector(INSTRUCTION_SIZE(vcp_type'(DISABLED))-1 downto 0);
    to_decode_program_counter          : in     unsigned(REGISTER_SIZE-1 downto 0);
    to_decode_predicted_pc             : in     unsigned(REGISTER_SIZE-1 downto 0);
    to_decode_valid                    : in     std_logic;
    from_decode_ready                  : buffer std_logic;
    from_decode_incomplete_instruction : out    std_logic;

    quash_decode : in  std_logic;
    decode_idle  : out std_logic;

    from_decode_rs1_data         : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    from_decode_rs2_data         : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    from_decode_rs3_data         : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    from_decode_sign_extension   : out std_logic_vector(SIGN_EXTENSION_SIZE-1 downto 0);
    from_decode_program_counter  : out unsigned(REGISTER_SIZE-1 downto 0);
    from_decode_predicted_pc     : out unsigned(REGISTER_SIZE-1 downto 0);
    from_decode_instruction      : out std_logic_vector(INSTRUCTION_SIZE(VCP_ENABLE)-1 downto 0);
    from_decode_next_instruction : out std_logic_vector(INSTRUCTION_SIZE(vcp_type'(DISABLED))-1 downto 0);
    from_decode_next_valid       : out std_logic;
    from_decode_valid            : out std_logic;
    to_decode_ready              : in  std_logic
    );
end;

architecture rtl of decode is
  signal from_decode_incomplete_instruction_signal : std_logic;
  signal from_decode_instruction_signal            : std_logic_vector(from_decode_instruction'range);
  signal from_decode_valid_signal                  : std_logic;

  alias to_decode_rs1_select : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) is
    to_decode_instruction(REGISTER_RS1'range);
  alias to_decode_rs2_select : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) is
    to_decode_instruction(REGISTER_RS2'range);
  alias to_decode_rs3_select : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) is
    to_decode_instruction(REGISTER_RD'range);

  signal rs1_select : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0);
  signal rs2_select : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0);
  signal rs3_select : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0);

  signal from_stage1_program_counter : unsigned(REGISTER_SIZE-1 downto 0);
  signal from_stage1_predicted_pc    : unsigned(REGISTER_SIZE-1 downto 0);
  signal from_stage1_instruction     : std_logic_vector(from_decode_instruction'range);
  signal from_stage1_valid           : std_logic;
  signal to_stage1_ready             : std_logic;

  alias from_stage1_rs1_select : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) is
    from_stage1_instruction(REGISTER_RS1'range);
  alias from_stage1_rs2_select : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) is
    from_stage1_instruction(REGISTER_RS2'range);
  alias from_stage1_rs3_select : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) is
    from_stage1_instruction(REGISTER_RD'range);

  alias from_decode_rs1_select : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) is
    from_decode_instruction_signal(REGISTER_RS1'range);
  alias from_decode_rs2_select : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) is
    from_decode_instruction_signal(REGISTER_RS2'range);
  alias from_decode_rs3_select : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) is
    from_decode_instruction_signal(REGISTER_RD'range);

  signal rs1_data : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal rs2_data : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal rs3_data : std_logic_vector(REGISTER_SIZE-1 downto 0);

  signal wb_select : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0);
  signal wb_data   : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal wb_enable : std_logic;

  signal to_decode_sixty_four_bit_instruction : std_logic;
  signal from_stage1_incomplete_instruction   : std_logic;
begin
  from_decode_incomplete_instruction <= from_decode_incomplete_instruction_signal;
  from_decode_instruction            <= from_decode_instruction_signal;
  from_decode_valid                  <= from_decode_valid_signal;

  the_register_file : register_file
    generic map (
      REGISTER_SIZE          => REGISTER_SIZE,
      REGISTER_NAME_SIZE     => REGISTER_NAME_SIZE,
      READ_PORTS             => CONDITIONAL(VCP_ENABLE /= DISABLED, 3, 2),
      WRITE_FIRST_SMALL_RAMS => WRITE_FIRST_SMALL_RAMS
      )
    port map(
      clk        => clk,
      rs1_select => rs1_select,
      rs2_select => rs2_select,
      rs3_select => rs3_select,
      wb_select  => wb_select,
      wb_data    => wb_data,
      wb_enable  => wb_enable,
      rs1_data   => rs1_data,
      rs2_data   => rs2_data,
      rs3_data   => rs3_data
      );

  -- This is to handle Microsemi board's inability to initialize RAM to zero on startup.
  reg_rst_en : if FAMILY = "MICROSEMI" generate
    wb_select <= to_rf_select when reset = '0' else (others => '0');
    wb_data   <= to_rf_data   when reset = '0' else (others => '0');
    wb_enable <= to_rf_valid  when reset = '0' else '1';
  end generate reg_rst_en;
  reg_rst_nen : if FAMILY /= "MICROSEMI" generate
    wb_select <= to_rf_select;
    wb_data   <= to_rf_data;
    wb_enable <= to_rf_valid;
  end generate reg_rst_nen;

  ------------------------------------------------------------------------------
  -- 32/64-bit logic
  ------------------------------------------------------------------------------
  sixty_four_bit_gen : if VCP_ENABLE = SIXTY_FOUR_BIT generate
    to_decode_sixty_four_bit_instruction <= (not from_decode_incomplete_instruction_signal) when
                                            to_decode_instruction(6 downto 0) = VCP64_OP else
                                            '0';
    from_decode_incomplete_instruction_signal <= from_stage1_incomplete_instruction;
  end generate sixty_four_bit_gen;
  thirty_two_bit_gen : if VCP_ENABLE /= SIXTY_FOUR_BIT generate
    to_decode_sixty_four_bit_instruction      <= '0';
    from_decode_incomplete_instruction_signal <= '0';
  end generate thirty_two_bit_gen;

  ------------------------------------------------------------------------------
  -- First stage
  ------------------------------------------------------------------------------
  from_decode_ready <= to_stage1_ready or (not from_stage1_valid);

  --Reread registers if stalled
  rs1_select <=
    to_decode_rs1_select when from_decode_ready = '1' and from_decode_incomplete_instruction_signal = '0' else
    from_stage1_rs1_select;
  rs2_select <=
    to_decode_rs2_select when from_decode_ready = '1' and from_decode_incomplete_instruction_signal = '0' else
    from_stage1_rs2_select;
  rs3_select <=
    to_decode_rs3_select when from_decode_ready = '1' and from_decode_incomplete_instruction_signal = '0' else
    from_stage1_rs3_select;

  process (clk) is
  begin
    if rising_edge(clk) then
      if from_decode_ready = '1' then
        from_stage1_instruction(from_stage1_instruction'left downto
                                from_stage1_instruction'left-31) <=
          to_decode_instruction;
      end if;

      if from_decode_incomplete_instruction_signal = '1' then
        if from_decode_ready = '1' and to_decode_valid = '1' then
          from_stage1_incomplete_instruction <= '0';
          from_stage1_valid                  <= '1';
        end if;
      else
        if from_decode_ready = '1' then
          from_stage1_incomplete_instruction <= to_decode_valid and
                                                to_decode_sixty_four_bit_instruction;
          from_stage1_program_counter                          <= to_decode_program_counter;
          from_stage1_predicted_pc                             <= to_decode_predicted_pc;
          from_stage1_instruction(to_decode_instruction'range) <= to_decode_instruction;
          from_stage1_valid                                    <= to_decode_valid and (not to_decode_sixty_four_bit_instruction);
        end if;
      end if;

      if reset = '1' or quash_decode = '1' then
        from_stage1_incomplete_instruction <= '0';
        from_stage1_valid                  <= '0';
      end if;
    end if;
  end process;


  ------------------------------------------------------------------------------
  -- Second stage bypass (if one-stage)
  ------------------------------------------------------------------------------
  one_cycle : if PIPELINE_STAGES = 1 generate
    to_stage1_ready <= to_decode_ready;

    decode_idle <= (not from_decode_valid_signal) and
                   (not from_decode_incomplete_instruction_signal);

    from_decode_rs1_data <= rs1_data;
    from_decode_rs2_data <= rs2_data;
    from_decode_rs3_data <= rs3_data;
    from_decode_sign_extension <=
      std_logic_vector(resize(signed(from_stage1_instruction(from_stage1_instruction'left downto
                                                             from_stage1_instruction'left)),
                              SIGN_EXTENSION_SIZE));
    from_decode_program_counter    <= from_stage1_program_counter;
    from_decode_predicted_pc       <= from_stage1_predicted_pc;
    from_decode_instruction_signal <= from_stage1_instruction;
    from_decode_valid_signal       <= from_stage1_valid;
    from_decode_next_instruction   <= to_decode_instruction;
    from_decode_next_valid         <= to_decode_valid;
  end generate one_cycle;


  ------------------------------------------------------------------------------
  -- Second stage (if two-stage)
  ------------------------------------------------------------------------------
  two_cycle : if PIPELINE_STAGES = 2 generate
    to_stage1_ready <= to_decode_ready or (not from_decode_valid_signal);

    decode_idle <= (not from_stage1_valid) and
                   (not from_decode_valid_signal) and
                   (not from_decode_incomplete_instruction_signal);

    process (clk) is
    begin
      if rising_edge(clk) then
        if to_stage1_ready = '1' then
          from_decode_rs1_data <= rs1_data;
          from_decode_rs2_data <= rs2_data;
          from_decode_rs3_data <= rs3_data;
          from_decode_sign_extension <=
            std_logic_vector(resize(signed(from_stage1_instruction(from_stage1_instruction'left downto
                                                                   from_stage1_instruction'left)),
                                    SIGN_EXTENSION_SIZE));
          from_decode_program_counter    <= from_stage1_program_counter;
          from_decode_predicted_pc       <= from_stage1_predicted_pc;
          from_decode_instruction_signal <= from_stage1_instruction;
          from_decode_valid_signal       <= from_stage1_valid;
        end if;

        --Bypass registers already read out of register file
        if to_rf_valid = '1' then
          if to_stage1_ready = '1' then  --Bypass registers just being read in
            if to_rf_select = from_stage1_rs1_select then
              from_decode_rs1_data <= to_rf_data;
            end if;
            if to_rf_select = from_stage1_rs2_select then
              from_decode_rs2_data <= to_rf_data;
            end if;
            if to_rf_select = from_stage1_rs3_select then
              from_decode_rs3_data <= to_rf_data;
            end if;
          else                           --Bypass data already read in
            if to_rf_select = from_decode_rs1_select then
              from_decode_rs1_data <= to_rf_data;
            end if;
            if to_rf_select = from_decode_rs2_select then
              from_decode_rs2_data <= to_rf_data;
            end if;
            if to_rf_select = from_decode_rs3_select then
              from_decode_rs3_data <= to_rf_data;
            end if;
          end if;
        end if;

        if reset = '1' or quash_decode = '1' then
          from_decode_valid_signal <= '0';
        end if;
      end if;
    end process;
    from_decode_next_instruction <= from_stage1_instruction(from_decode_next_instruction'range);
    from_decode_next_valid       <= from_stage1_valid;
  end generate two_cycle;

end architecture;
