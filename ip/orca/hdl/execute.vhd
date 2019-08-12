library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.std_logic_textio.all;          -- I/O for logic types

library work;
use work.rv_components.all;
use work.utils.all;
use work.constants_pkg.all;

library STD;
use STD.textio.all;                     -- basic I/O

entity execute is
  generic (
    REGISTER_SIZE         : positive range 32 to 32;
    SIGN_EXTENSION_SIZE   : positive;
    INTERRUPT_VECTOR      : std_logic_vector(31 downto 0);
    BTB_ENTRIES           : natural;
    POWER_OPTIMIZED       : boolean;
    MULTIPLY_ENABLE       : boolean;
    DIVIDE_ENABLE         : boolean;
    SHIFTER_MAX_CYCLES    : positive range 1 to 32;
    ENABLE_EXCEPTIONS     : boolean;
    ENABLE_EXT_INTERRUPTS : boolean;
    NUM_EXT_INTERRUPTS    : positive range 1 to 32;
    VCP_ENABLE            : vcp_type;
    FAMILY                : string;

    AUX_MEMORY_REGIONS : natural range 0 to 4;
    AMR0_ADDR_BASE     : std_logic_vector(31 downto 0);
    AMR0_ADDR_LAST     : std_logic_vector(31 downto 0);
    AMR0_READ_ONLY     : boolean;

    UC_MEMORY_REGIONS : natural range 0 to 4;
    UMR0_ADDR_BASE    : std_logic_vector(31 downto 0);
    UMR0_ADDR_LAST    : std_logic_vector(31 downto 0);
    UMR0_READ_ONLY    : boolean;

    HAS_ICACHE : boolean;
    HAS_DCACHE : boolean
    );
  port (
    clk   : in std_logic;
    reset : in std_logic;

    global_interrupts     : in std_logic_vector(NUM_EXT_INTERRUPTS-1 downto 0);
    program_counter       : in unsigned(REGISTER_SIZE-1 downto 0);
    core_idle             : in std_logic;
    memory_interface_idle : in std_logic;

    to_execute_valid            : in     std_logic;
    to_execute_program_counter  : in     unsigned(REGISTER_SIZE-1 downto 0);
    to_execute_predicted_pc     : in     unsigned(REGISTER_SIZE-1 downto 0);
    to_execute_instruction      : in     std_logic_vector(INSTRUCTION_SIZE(VCP_ENABLE)-1 downto 0);
    to_execute_next_instruction : in     std_logic_vector(31 downto 0);
    to_execute_next_valid       : in     std_logic;
    to_execute_rs1_data         : in     std_logic_vector(REGISTER_SIZE-1 downto 0);
    to_execute_rs2_data         : in     std_logic_vector(REGISTER_SIZE-1 downto 0);
    to_execute_rs3_data         : in     std_logic_vector(REGISTER_SIZE-1 downto 0);
    to_execute_sign_extension   : in     std_logic_vector(SIGN_EXTENSION_SIZE-1 downto 0);
    from_execute_ready          : buffer std_logic;

    --quash_execute input isn't needed as mispredicts have already resolved
    execute_idle : out std_logic;

    --To PC correction
    to_pc_correction_data        : out    unsigned(REGISTER_SIZE-1 downto 0);
    to_pc_correction_source_pc   : out    unsigned(REGISTER_SIZE-1 downto 0);
    to_pc_correction_valid       : buffer std_logic;
    to_pc_correction_predictable : out    std_logic;
    from_pc_correction_ready     : in     std_logic;

    --To register file
    to_rf_select : buffer std_logic_vector(REGISTER_NAME_SIZE-1 downto 0);
    to_rf_data   : buffer std_logic_vector(REGISTER_SIZE-1 downto 0);
    to_rf_valid  : buffer std_logic;

    --Data ORCA-internal memory-mapped master
    lsu_oimm_address       : buffer std_logic_vector(REGISTER_SIZE-1 downto 0);
    lsu_oimm_byteenable    : out    std_logic_vector((REGISTER_SIZE/8)-1 downto 0);
    lsu_oimm_requestvalid  : buffer std_logic;
    lsu_oimm_readnotwrite  : buffer std_logic;
    lsu_oimm_writedata     : out    std_logic_vector(REGISTER_SIZE-1 downto 0);
    lsu_oimm_readdata      : in     std_logic_vector(REGISTER_SIZE-1 downto 0);
    lsu_oimm_readdatavalid : in     std_logic;
    lsu_oimm_waitrequest   : in     std_logic;

    --ICache control (Invalidate/flush/writeback)
    from_icache_control_ready : in     std_logic;
    to_icache_control_valid   : buffer std_logic;
    to_icache_control_command : out    cache_control_command;

    --DCache control (Invalidate/flush/writeback)
    from_dcache_control_ready : in     std_logic;
    to_dcache_control_valid   : buffer std_logic;
    to_dcache_control_command : out    cache_control_command;

    --Cache control common signals
    to_cache_control_base : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    to_cache_control_last : out std_logic_vector(REGISTER_SIZE-1 downto 0);

    --Auxiliary/Uncached memory regions
    amr_base_addrs : out std_logic_vector((imax(AUX_MEMORY_REGIONS, 1)*REGISTER_SIZE)-1 downto 0);
    amr_last_addrs : out std_logic_vector((imax(AUX_MEMORY_REGIONS, 1)*REGISTER_SIZE)-1 downto 0);
    umr_base_addrs : out std_logic_vector((imax(UC_MEMORY_REGIONS, 1)*REGISTER_SIZE)-1 downto 0);
    umr_last_addrs : out std_logic_vector((imax(UC_MEMORY_REGIONS, 1)*REGISTER_SIZE)-1 downto 0);

    pause_ifetch : out std_logic;

    --Timer signals
    timer_value     : in std_logic_vector(63 downto 0);
    timer_interrupt : in std_logic;

    --Vector coprocessor port
    vcp_data0            : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    vcp_data1            : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    vcp_data2            : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    vcp_instruction      : out std_logic_vector(40 downto 0);
    vcp_valid_instr      : out std_logic;
    vcp_ready            : in  std_logic;
    vcp_illegal          : in  std_logic;
    vcp_writeback_data   : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
    vcp_writeback_en     : in  std_logic;
    vcp_alu_data1        : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
    vcp_alu_data2        : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
    vcp_alu_source_valid : in  std_logic;
    vcp_alu_result       : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    vcp_alu_result_valid : out std_logic
    );
end entity execute;

architecture behavioural of execute is
  constant INSTRUCTION32 : std_logic_vector(31 downto 0) := (others => '-');

  alias opcode    : std_logic_vector(6 downto 0) is to_execute_instruction(INSTR_OPCODE'range);
  alias rd_select : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) is
    to_execute_instruction(REGISTER_RD'range);
  alias rs1_select : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) is
    to_execute_instruction(REGISTER_RS1'range);
  alias rs2_select : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) is
    to_execute_instruction(REGISTER_RS2'range);
  alias rs3_select : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) is
    to_execute_instruction(REGISTER_RD'range);

  signal use_after_produce_stall : std_logic;
  signal to_rf_select_writeable  : std_logic;

  signal rs1_data : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal rs2_data : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal rs3_data : std_logic_vector(REGISTER_SIZE-1 downto 0);

  alias next_rs1_select : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) is
    to_execute_next_instruction(REGISTER_RS1'range);
  alias next_rs2_select : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) is
    to_execute_next_instruction(REGISTER_RS2'range);
  alias next_rs3_select : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) is
    to_execute_next_instruction(REGISTER_RD'range);

  type fwd_mux_t is (ALU_FWD, NO_FWD);
  signal rs1_mux : fwd_mux_t;
  signal rs2_mux : fwd_mux_t;
  signal rs3_mux : fwd_mux_t;

  --Writeback data sources (VCP writes back through syscall)
  signal alu_select           : std_logic;
  signal to_alu_valid         : std_logic;
  signal from_alu_ready       : std_logic;
  signal from_alu_illegal     : std_logic;
  signal from_alu_valid       : std_logic;
  signal from_alu_data        : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal branch_select        : std_logic;
  signal to_branch_valid      : std_logic;
  --signal from_branch_ready  : std_logic; --Branch unit always ready
  signal from_branch_illegal  : std_logic;
  signal from_branch_valid    : std_logic;
  signal from_branch_data     : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal lsu_select           : std_logic;
  signal to_lsu_valid         : std_logic;
  signal from_lsu_ready       : std_logic;
  signal from_lsu_illegal     : std_logic;
  signal from_lsu_misalign    : std_logic;
  signal from_lsu_valid       : std_logic;
  signal from_lsu_data        : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal syscall_select       : std_logic;
  signal to_syscall_valid     : std_logic;
  signal from_syscall_ready   : std_logic;
  signal from_syscall_illegal : std_logic;
  signal from_syscall_valid   : std_logic;
  signal from_syscall_data    : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal vcp_select           : std_logic;
  signal to_vcp_valid         : std_logic;

  signal new_instret : std_logic;

  signal from_opcode_illegal : std_logic;
  signal illegal_instruction : std_logic;

  signal to_alu_rs1_data : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal to_alu_rs2_data : std_logic_vector(REGISTER_SIZE-1 downto 0);

  signal branch_to_pc_correction_valid : std_logic;
  signal branch_to_pc_correction_data  : unsigned(REGISTER_SIZE-1 downto 0);

  signal writeback_stall_from_lsu : std_logic;
  signal load_in_progress         : std_logic;

  signal lsu_idle    : std_logic;
  signal memory_idle : std_logic;

  signal syscall_to_pc_correction_valid : std_logic;
  signal syscall_to_pc_correction_data  : unsigned(REGISTER_SIZE-1 downto 0);

  signal from_writeback_ready : std_logic;
  signal to_rf_mux            : std_logic_vector(1 downto 0);
  signal vcp_writeback_select : std_logic;

  signal from_branch_misaligned : std_logic;
begin
  --Decode instruction; could get pushed back to decode stage
  process (opcode) is
  begin
    alu_select     <= '0';
    branch_select  <= '0';
    lsu_select     <= '0';
    syscall_select <= '0';
    vcp_select     <= '0';

    from_opcode_illegal <= '0';

    --Decode OPCODE to select submodule.  All paths must decode to exactly one
    --submodule.
    --If ENABLE_EXCEPTIONS is false decode illegal instructions to ALU ops as
    --the default way to handle.
    case opcode is
      when ALU_OP | ALUI_OP | LUI_OP | AUIPC_OP =>
        alu_select <= '1';
      when JAL_OP | JALR_OP | BRANCH_OP =>
        branch_select <= '1';
      when LOAD_OP | STORE_OP =>
        lsu_select <= '1';
      when SYSTEM_OP | MISC_MEM_OP =>
        syscall_select <= '1';
      when VCP32_OP =>
        if VCP_ENABLE /= DISABLED then
          vcp_select <= '1';
        else
          if ENABLE_EXCEPTIONS then
            from_opcode_illegal <= '1';
          else
            alu_select <= '1';
          end if;
        end if;
      when VCP64_OP =>
        if VCP_ENABLE = SIXTY_FOUR_BIT then
          vcp_select <= '1';
        else
          if ENABLE_EXCEPTIONS then
            from_opcode_illegal <= '1';
          else
            alu_select <= '1';
          end if;
        end if;
      when others =>
        if ENABLE_EXCEPTIONS then
          from_opcode_illegal <= '1';
        else
          alu_select <= '1';
        end if;
    end case;
  end process;
  --Currently only set valid/ready for execute when writeback is ready.  This
  --means that any instruction that completes in the execute cycle will be able to
  --writeback without a stall; i.e. alu/branch/syscall instructions merely
  --assert valid for once cycle and are done.
  --Could be changed to have components hold their output if to_execute_ready
  --was not true, which might slightly complicate logic but would allow some
  --optimizations such as allowing a multicycle ALU op
  --(multiply/shift/div/etc.) to start while waiting for a load to return.
  to_alu_valid     <= alu_select and to_execute_valid and from_writeback_ready;
  to_branch_valid  <= branch_select and to_execute_valid and from_writeback_ready;
  to_lsu_valid     <= lsu_select and to_execute_valid and from_writeback_ready;
  to_syscall_valid <= syscall_select and to_execute_valid and from_writeback_ready;
  to_vcp_valid     <= vcp_select and to_execute_valid and from_writeback_ready;

  from_execute_ready <= (not to_execute_valid) or (from_writeback_ready and
                                                   (((not lsu_select) or from_lsu_ready) and
                                                    ((not alu_select) or from_alu_ready) and
                                                    ((not syscall_select) or from_syscall_ready) and
                                                    ((not vcp_select) or vcp_ready)));



  illegal_instruction <= to_execute_valid and from_writeback_ready and (from_opcode_illegal or
                                                                        (alu_select and from_alu_illegal) or
                                                                        (branch_select and from_branch_illegal) or
                                                                        (lsu_select and from_lsu_illegal) or
                                                                        (syscall_select and from_syscall_illegal) or
                                                                        (vcp_select and vcp_illegal));

  --New instruction retired, for incrementing MINSTRET(H).
  new_instret <= to_execute_valid and from_execute_ready and (not illegal_instruction);


  -----------------------------------------------------------------------------
  -- REGISTER FORWADING
  -- Knowing the next instruction coming downt the pipeline, we can
  -- generate the mux select bits for the next cycle.
  -- there are several functional units that could generate a writeback. ALU,
  -- JAL, Syscalls, load_store. the ALU forward directly to the next
  -- instruction, The others stall the pipeline to wait for the registers to
  -- propogate if the next instruction uses them.
  --
  -----------------------------------------------------------------------------
  rs1_data <= from_alu_data when rs1_mux = ALU_FWD else
              to_execute_rs1_data;
  rs2_data <= from_alu_data when rs2_mux = ALU_FWD else
              to_execute_rs2_data;
  rs3_data <= from_alu_data when rs3_mux = ALU_FWD else
              to_execute_rs3_data;

  --No forward stall; system calls, loads, and branches aren't forwarded.
  use_after_produce_stall <=
    to_rf_select_writeable and (from_syscall_valid or load_in_progress or from_branch_valid) when
    to_rf_select = rs1_select or to_rf_select = rs2_select or ((to_rf_select = rs3_select) and VCP_ENABLE /= DISABLED)
    else '0';

  --Calculate forwarding muxes for next instruction in advance in order to
  --minimize execute cycle time.
  process(clk)
  begin
    if rising_edge(clk) then
      if from_writeback_ready = '1' then
        rs1_mux <= NO_FWD;
        rs2_mux <= NO_FWD;
        rs3_mux <= NO_FWD;
      end if;
      if to_alu_valid = '1' and from_alu_ready = '1' then
        if rd_select /= REGISTER_ZERO then
          if rd_select = next_rs1_select then
            rs1_mux <= ALU_FWD;
          end if;
          if rd_select = next_rs2_select then
            rs2_mux <= ALU_FWD;
          end if;
          if rd_select = next_rs3_select then
            rs3_mux <= ALU_FWD;
          end if;
        end if;
      end if;
    end if;
  end process;

  to_alu_rs1_data <= vcp_alu_data1 when vcp_select = '1' else
                     rs1_data;
  to_alu_rs2_data <= vcp_alu_data2 when vcp_select = '1' else
                     rs2_data;
  alu : arithmetic_unit
    generic map (
      REGISTER_SIZE       => REGISTER_SIZE,
      SIGN_EXTENSION_SIZE => SIGN_EXTENSION_SIZE,
      POWER_OPTIMIZED     => POWER_OPTIMIZED,
      MULTIPLY_ENABLE     => MULTIPLY_ENABLE,
      DIVIDE_ENABLE       => DIVIDE_ENABLE,
      SHIFTER_MAX_CYCLES  => SHIFTER_MAX_CYCLES,
      ENABLE_EXCEPTIONS   => ENABLE_EXCEPTIONS,
      FAMILY              => FAMILY
      )
    port map (
      clk => clk,

      to_alu_valid     => to_alu_valid,
      to_alu_rs1_data  => to_alu_rs1_data,
      to_alu_rs2_data  => to_alu_rs2_data,
      from_alu_ready   => from_alu_ready,
      from_alu_illegal => from_alu_illegal,

      vcp_source_valid => vcp_alu_source_valid,
      vcp_select       => vcp_select,

      from_execute_ready => from_execute_ready,
      instruction        => to_execute_instruction(INSTRUCTION32'range),
      sign_extension     => to_execute_sign_extension,
      current_pc         => to_execute_program_counter,

      from_alu_data  => from_alu_data,
      from_alu_valid => from_alu_valid
      );

  branch : branch_unit
    generic map (
      REGISTER_SIZE       => REGISTER_SIZE,
      SIGN_EXTENSION_SIZE => SIGN_EXTENSION_SIZE,
      BTB_ENTRIES         => BTB_ENTRIES,
      ENABLE_EXCEPTIONS   => ENABLE_EXCEPTIONS
      )
    port map (
      clk   => clk,
      reset => reset,

      to_branch_valid     => to_branch_valid,
      from_branch_illegal => from_branch_illegal,

      rs1_data       => rs1_data,
      rs2_data       => rs2_data,
      current_pc     => to_execute_program_counter,
      predicted_pc   => to_execute_predicted_pc,
      instruction    => to_execute_instruction(INSTRUCTION32'range),
      sign_extension => to_execute_sign_extension,

      from_branch_valid          => from_branch_valid,
      from_branch_data           => from_branch_data,
      to_branch_ready            => from_writeback_ready,
      target_misaligned          => from_branch_misaligned,
      to_pc_correction_data      => branch_to_pc_correction_data,
      to_pc_correction_source_pc => to_pc_correction_source_pc,
      to_pc_correction_valid     => branch_to_pc_correction_valid,
      from_pc_correction_ready   => from_pc_correction_ready
      );

  ls_unit : load_store_unit
    generic map (
      REGISTER_SIZE       => REGISTER_SIZE,
      SIGN_EXTENSION_SIZE => SIGN_EXTENSION_SIZE,
      ENABLE_EXCEPTIONS   => ENABLE_EXCEPTIONS
      )
    port map (
      clk   => clk,
      reset => reset,

      lsu_idle => lsu_idle,

      to_lsu_valid      => to_lsu_valid,
      from_lsu_illegal  => from_lsu_illegal,
      from_lsu_misalign => from_lsu_misalign,

      rs1_data       => rs1_data,
      rs2_data       => rs2_data,
      instruction    => to_execute_instruction(INSTRUCTION32'range),
      sign_extension => to_execute_sign_extension,

      load_in_progress         => load_in_progress,
      writeback_stall_from_lsu => writeback_stall_from_lsu,

      lsu_ready      => from_lsu_ready,
      from_lsu_data  => from_lsu_data,
      from_lsu_valid => from_lsu_valid,

      oimm_address       => lsu_oimm_address,
      oimm_byteenable    => lsu_oimm_byteenable,
      oimm_requestvalid  => lsu_oimm_requestvalid,
      oimm_readnotwrite  => lsu_oimm_readnotwrite,
      oimm_writedata     => lsu_oimm_writedata,
      oimm_readdata      => lsu_oimm_readdata,
      oimm_readdatavalid => lsu_oimm_readdatavalid,
      oimm_waitrequest   => lsu_oimm_waitrequest
      );

  memory_idle <= memory_interface_idle and lsu_idle;
  syscall : sys_call
    generic map (
      REGISTER_SIZE    => REGISTER_SIZE,
      POWER_OPTIMIZED  => POWER_OPTIMIZED,
      INTERRUPT_VECTOR => INTERRUPT_VECTOR,

      ENABLE_EXCEPTIONS     => ENABLE_EXCEPTIONS,
      ENABLE_EXT_INTERRUPTS => ENABLE_EXT_INTERRUPTS,
      NUM_EXT_INTERRUPTS    => NUM_EXT_INTERRUPTS,

      VCP_ENABLE      => VCP_ENABLE,
      MULTIPLY_ENABLE => MULTIPLY_ENABLE,

      AUX_MEMORY_REGIONS => AUX_MEMORY_REGIONS,
      AMR0_ADDR_BASE     => AMR0_ADDR_BASE,
      AMR0_ADDR_LAST     => AMR0_ADDR_LAST,
      AMR0_READ_ONLY     => AMR0_READ_ONLY,

      UC_MEMORY_REGIONS => UC_MEMORY_REGIONS,
      UMR0_ADDR_BASE    => UMR0_ADDR_BASE,
      UMR0_ADDR_LAST    => UMR0_ADDR_LAST,
      UMR0_READ_ONLY    => UMR0_READ_ONLY,

      HAS_ICACHE => HAS_ICACHE,
      HAS_DCACHE => HAS_DCACHE
      )
    port map (
      clk   => clk,
      reset => reset,

      global_interrupts => global_interrupts,
      core_idle         => core_idle,
      memory_idle       => memory_idle,
      program_counter   => program_counter,

      to_syscall_valid     => to_syscall_valid,
      from_syscall_illegal => from_syscall_illegal,
      rs1_data             => rs1_data,
      rs2_data             => rs2_data,
      instruction          => to_execute_instruction(INSTRUCTION32'range),
      current_pc           => to_execute_program_counter,
      from_syscall_ready   => from_syscall_ready,

      new_instret => new_instret,

      from_branch_misaligned => from_branch_misaligned,
      illegal_instruction    => illegal_instruction,
      from_lsu_addr_misalign => from_lsu_misalign,
      from_lsu_address       => lsu_oimm_address,
      from_syscall_valid     => from_syscall_valid,
      from_syscall_data      => from_syscall_data,

      to_pc_correction_data    => syscall_to_pc_correction_data,
      to_pc_correction_valid   => syscall_to_pc_correction_valid,
      from_pc_correction_ready => from_pc_correction_ready,

      from_icache_control_ready => from_icache_control_ready,
      to_icache_control_valid   => to_icache_control_valid,
      to_icache_control_command => to_icache_control_command,

      from_dcache_control_ready => from_dcache_control_ready,
      to_dcache_control_valid   => to_dcache_control_valid,
      to_dcache_control_command => to_dcache_control_command,

      to_cache_control_base => to_cache_control_base,
      to_cache_control_last => to_cache_control_last,

      amr_base_addrs => amr_base_addrs,
      amr_last_addrs => amr_last_addrs,
      umr_base_addrs => umr_base_addrs,
      umr_last_addrs => umr_last_addrs,

      pause_ifetch => pause_ifetch,

      timer_value     => timer_value,
      timer_interrupt => timer_interrupt,

      vcp_writeback_data => vcp_writeback_data,
      vcp_writeback_en   => vcp_writeback_en
      );

  vcp_port : vcp_handler
    generic map (
      REGISTER_SIZE => REGISTER_SIZE,
      VCP_ENABLE    => VCP_ENABLE
      )
    port map (
      clk   => clk,
      reset => reset,

      instruction  => to_execute_instruction,
      to_vcp_valid => to_vcp_valid,
      vcp_select   => vcp_select,

      rs1_data => rs1_data,
      rs2_data => rs2_data,
      rs3_data => rs3_data,

      vcp_data0 => vcp_data0,
      vcp_data1 => vcp_data1,
      vcp_data2 => vcp_data2,

      vcp_instruction      => vcp_instruction,
      vcp_valid_instr      => vcp_valid_instr,
      vcp_writeback_select => vcp_writeback_select
      );
  vcp_alu_result_valid <= from_alu_valid;
  vcp_alu_result       <= from_alu_data;

  ------------------------------------------------------------------------------
  -- PC correction (branch mispredict, interrupt, etc.)
  ------------------------------------------------------------------------------
  to_pc_correction_data <= syscall_to_pc_correction_data when syscall_to_pc_correction_valid = '1' else
                           branch_to_pc_correction_data;
  to_pc_correction_valid       <= syscall_to_pc_correction_valid or branch_to_pc_correction_valid;
  --Don't put syscalls in the BTB as they have side effects and must flush the
  --pipeline anyway.
  to_pc_correction_predictable <= not syscall_to_pc_correction_valid;

  --Intuitively execute_idle is lsu_idle and alu_idle and branch_idle etc. for
  --all the functional units.  In practice the idle signal is only needed for
  --interrupts, and it's fine to take an interrupt as long as the branch and
  --syscall units have finished updating the PC and we're not waiting on a
  --load.  Even though for instance the ALU may have some internal state, since
  --the execute unit is serialized it won't assert ready back to the decode
  --unit until it has finished the instruction.
  --Also note intuitively we'd want a writeback_idle signal as interrupts can
  --be taken before writeback has occurred; however since there's no
  --backpressure from writeback we can always guarantee that the writeback will
  --occur before the interrupt handler decodes an instruction and reads a
  --register.
  execute_idle <= lsu_idle and (not to_pc_correction_valid);


  ------------------------------------------------------------------------------
  -- Writeback
  ------------------------------------------------------------------------------
  from_writeback_ready <= (not use_after_produce_stall) and (not writeback_stall_from_lsu);

  process(clk)
  begin
    if rising_edge(clk) then
      if from_writeback_ready = '1' then
        to_rf_select <= rd_select;
        if rd_select = REGISTER_ZERO then
          to_rf_select_writeable <= '0';
        else
          to_rf_select_writeable <= '1';
        end if;
      end if;
    end if;
  end process;

  to_rf_mux <= "00" when from_syscall_valid = '1' else
               "01" when load_in_progress = '1' else
               "10" when from_branch_valid = '1' else
               "11";

  with to_rf_mux select
    to_rf_data <=
    from_syscall_data when "00",
    from_lsu_data     when "01",
    from_branch_data  when "10",
    from_alu_data     when others;

  to_rf_valid <= to_rf_select_writeable and (from_syscall_valid or
                                             from_lsu_valid or
                                             from_branch_valid or
                                             (from_alu_valid and (not vcp_writeback_select)));



  -------------------------------------------------------------------------------
  -- Simulation assertions and debug
  -------------------------------------------------------------------------------
--pragma translate_off
  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '0' then
        assert (bool_to_int(from_syscall_valid) +
                bool_to_int(from_lsu_valid) +
                bool_to_int(from_branch_valid) +
                bool_to_int(from_alu_valid)) <= 1 report "Multiple Data Enables Asserted" severity failure;
      end if;
    end if;
  end process;

  my_print : process(clk)
    variable my_line          : line;   -- type 'line' comes from textio
    variable last_valid_pc    : unsigned(REGISTER_SIZE-1 downto 0);
    type register_list is array(0 to 31) of std_logic_vector(REGISTER_SIZE-1 downto 0);
    variable shadow_registers : register_list := (others => (others => '0'));

    constant DEBUG_WRITEBACK : boolean := false;

  begin
    if rising_edge(clk) then

      if to_rf_valid = '1' and DEBUG_WRITEBACK then
        write(my_line, string'("WRITEBACK: PC = "));
        hwrite(my_line, std_logic_vector(last_valid_pc));
        shadow_registers(to_integer(unsigned(to_rf_select))) := to_rf_data;
        write(my_line, string'(" REGISTERS = {"));
        for i in shadow_registers'range loop
          hwrite(my_line, shadow_registers(i));
          if i /= shadow_registers'right then
            write(my_line, string'(","));
          end if;

        end loop;  -- i
        write(my_line, string'("}"));
        writeline(output, my_line);
      end if;


      if to_execute_valid = '1' then
        write(my_line, string'("executing pc = "));   -- formatting
        hwrite(my_line, (std_logic_vector(to_execute_program_counter)));  -- format type std_logic_vector as hex
        write(my_line, string'(" instr =  "));        -- formatting
        if opcode = VCP64_OP then
          hwrite(my_line, (to_execute_instruction));  -- format type std_logic_vector as hex
        else
          hwrite(my_line, (to_execute_instruction(31 downto 0)));  -- format type std_logic_vector as hex
        end if;

        if from_execute_ready = '0' then
          write(my_line, string'(" stalling"));  -- formatting
        else
          last_valid_pc := to_execute_program_counter;
        end if;
        writeline(output, my_line);              -- write to "output"
      else
      --write(my_line, string'("bubble"));  -- formatting
      --writeline(output, my_line);     -- write to "output"
      end if;

    end if;
  end process my_print;
--pragma translate_on

end architecture;
