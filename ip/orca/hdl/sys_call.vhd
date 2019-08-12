library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.utils.all;
use work.constants_pkg.all;

entity sys_call is
  generic (
    REGISTER_SIZE    : positive range 32 to 32;
    POWER_OPTIMIZED  : boolean;
    INTERRUPT_VECTOR : std_logic_vector(31 downto 0);

    ENABLE_EXCEPTIONS     : boolean;
    ENABLE_EXT_INTERRUPTS : boolean;
    NUM_EXT_INTERRUPTS    : positive range 1 to 32;

    VCP_ENABLE      : vcp_type;
    MULTIPLY_ENABLE : boolean;

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

    global_interrupts : in std_logic_vector(NUM_EXT_INTERRUPTS-1 downto 0);
    core_idle         : in std_logic;
    memory_idle       : in std_logic;
    program_counter   : in unsigned(REGISTER_SIZE-1 downto 0);

    to_syscall_valid     : in  std_logic;
    from_syscall_illegal : out std_logic;
    current_pc           : in  unsigned(REGISTER_SIZE-1 downto 0);
    instruction          : in  std_logic_vector(31 downto 0);
    rs1_data             : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
    rs2_data             : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
    from_syscall_ready   : out std_logic;

    new_instret : in std_logic;

    from_branch_misaligned : in std_logic;

    illegal_instruction : in std_logic;

    from_lsu_addr_misalign : in std_logic;
    from_lsu_address       : in std_logic_vector(REGISTER_SIZE-1 downto 0);

    from_syscall_valid : out std_logic;
    from_syscall_data  : out std_logic_vector(REGISTER_SIZE-1 downto 0);

    to_pc_correction_data    : out unsigned(REGISTER_SIZE-1 downto 0);
    to_pc_correction_valid   : out std_logic;
    from_pc_correction_ready : in  std_logic;

    from_icache_control_ready : in     std_logic;
    to_icache_control_valid   : buffer std_logic;
    to_icache_control_command : out    cache_control_command;

    from_dcache_control_ready : in     std_logic;
    to_dcache_control_valid   : buffer std_logic;
    to_dcache_control_command : out    cache_control_command;

    to_cache_control_base : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    to_cache_control_last : out std_logic_vector(REGISTER_SIZE-1 downto 0);

    amr_base_addrs : out std_logic_vector((imax(AUX_MEMORY_REGIONS, 1)*REGISTER_SIZE)-1 downto 0);
    amr_last_addrs : out std_logic_vector((imax(AUX_MEMORY_REGIONS, 1)*REGISTER_SIZE)-1 downto 0);
    umr_base_addrs : out std_logic_vector((imax(UC_MEMORY_REGIONS, 1)*REGISTER_SIZE)-1 downto 0);
    umr_last_addrs : out std_logic_vector((imax(UC_MEMORY_REGIONS, 1)*REGISTER_SIZE)-1 downto 0);

    pause_ifetch : out std_logic;

    timer_value     : in std_logic_vector(63 downto 0);
    timer_interrupt : in std_logic;

    vcp_writeback_en   : in std_logic;
    vcp_writeback_data : in std_logic_vector(REGISTER_SIZE-1 downto 0)
    );
end entity sys_call;

architecture rtl of sys_call is
  signal fence_select  : std_logic;
  signal fencei_select : std_logic;
  signal cache_select  : std_logic;
  signal csr_select    : std_logic;
  signal ebreak_select : std_logic;
  signal ecall_select  : std_logic;
  signal mret_select   : std_logic;

  -- CSR signals. These are initialized to zero so that if any bits are never
  -- assigned, they act like constants.
  signal mstatus      : std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
  signal mscratch     : std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
  signal mepc         : std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
  signal mcause       : std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
  signal mtval        : std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
  signal mtime        : std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
  signal mtimeh       : std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
  signal mcycle       : std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
  signal mcycleh      : std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
  signal minstret     : std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
  signal minstreth    : std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
  signal meimask      : std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
  signal meimask_full : std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
  signal meipend      : std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
  signal mcache       : std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
  signal misa         : std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
  signal mtvec        : std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');

  signal cycle   : unsigned(63 downto 0);
  signal instret : unsigned(63 downto 0);

  alias csr_number : std_logic_vector(CSR_ADDRESS'length-1 downto 0) is instruction(CSR_ADDRESS'range);
  alias opcode     : std_logic_vector(INSTR_OPCODE'length-1 downto 0) is instruction(INSTR_OPCODE'range);
  alias func3      : std_logic_vector(INSTR_FUNC3'length-1 downto 0) is instruction(INSTR_FUNC3'range);
  alias func7      : std_logic_vector(INSTR_FUNC7'length-1 downto 0) is instruction(INSTR_FUNC7'range);
  alias imm        : std_logic_vector(CSR_ZIMM'length-1 downto 0) is instruction(CSR_ZIMM'range);
  alias rs1_select : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) is instruction(REGISTER_RS1'range);
  alias rd_select  : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) is instruction(REGISTER_RD'range);

  alias mcause_exc_code : std_logic_vector is mcause(CSR_MCAUSE_CODE'range);
  alias bit_sel         : std_logic_vector(REGISTER_SIZE-1 downto 0) is rs1_data;

  signal csr_readdata       : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal csr_writedata      : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal last_csr_writedata : std_logic_vector(REGISTER_SIZE-1 downto 0);

  signal was_mret                  : std_logic;
  signal was_illegal               : std_logic;
  signal fence_pc_correction_valid : std_logic;
  signal next_fence_pc             : unsigned(REGISTER_SIZE-1 downto 0);

  signal fence_pending                 : std_logic;
  signal interrupt_pending             : std_logic;
  signal interrupt_pc_correction_valid : std_logic;


  --Uncached/Auxiliary memory region CSR signals.  Will be assigned 0's if unused.
  type csr_vector is array (natural range <>) of std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal mamr_base       : csr_vector(3 downto 0);
  signal mamr_last       : csr_vector(3 downto 0);
  signal mumr_base       : csr_vector(3 downto 0);
  signal mumr_last       : csr_vector(3 downto 0);
  signal amr_base_select : std_logic_vector(3 downto 0);
  signal amr_last_select : std_logic_vector(3 downto 0);
  signal umr_base_select : std_logic_vector(3 downto 0);
  signal umr_last_select : std_logic_vector(3 downto 0);
  signal amr_base_write  : std_logic_vector(3 downto 0);
  signal amr_last_write  : std_logic_vector(3 downto 0);
  signal umr_base_write  : std_logic_vector(3 downto 0);
  signal umr_last_write  : std_logic_vector(3 downto 0);
begin
  --Decode instruction to select submodule.  All paths must decode to exactly
  --one submodule.
  --ASSUMES only SYSTEM_OP | MISC_MEM_OP for opcode.
  process (opcode, func3, func7) is
  begin
    fence_select         <= '0';
    fencei_select        <= '0';
    cache_select         <= '0';
    csr_select           <= '0';
    ebreak_select        <= '0';
    ecall_select         <= '0';
    mret_select          <= '0';
    from_syscall_illegal <= '0';

    if opcode(6) = SYSTEM_OP(6) then
      if ENABLE_EXCEPTIONS then
        case func3 is
          when PRIV_FUNC3 =>
            if rs1_select /= REGISTER_ZERO or rd_select /= REGISTER_ZERO then
              from_syscall_illegal <= '1';
            else
              case csr_number is
                when SYSTEM_ECALL =>
                  ecall_select <= '1';
                when SYSTEM_EBREAK =>
                  ebreak_select <= '1';
                when SYSTEM_MRET =>
                  mret_select <= '1';
                when others =>
                  from_syscall_illegal <= '1';
              end case;
            end if;
          when "100" =>
            from_syscall_illegal <= '1';
          when others =>
            csr_select <= '1';
        end case;
      else
        csr_select <= '1';
      end if;
    else
      case func3 is
        when FENCE_FUNC3 =>
          fence_select <= '1';
        when REGION_FUNC3 =>
          case func7 is
            when FENCE_I_FUNC7 | FENCE_RI_FUNC7 =>
              fencei_select <= '1';
            when FENCE_RD_FUNC7 =>
              fence_select <= '1';
            when CACHE_WRITEBACK_FUNC7 | CACHE_FLUSH_FUNC7 | CACHE_DISCARD_FUNC7 =>
              if HAS_DCACHE then
                cache_select <= '1';
              else
                fence_select <= '1';
              end if;
            when others =>
              if ENABLE_EXCEPTIONS then
                from_syscall_illegal <= '1';
              else
                fence_select <= '1';
              end if;
          end case;
        when others =>
          if ENABLE_EXCEPTIONS then
            from_syscall_illegal <= '1';
          else
            fence_select <= '1';
          end if;
      end case;
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      cycle <= cycle + to_unsigned(1, cycle'length);
      if new_instret = '1' then
        instret <= instret + to_unsigned(1, instret'length);
      end if;

      if reset = '1' then
        cycle   <= to_unsigned(0, cycle'length);
        instret <= to_unsigned(0, instret'length);
      end if;
    end if;
  end process;
  mcycle    <= std_logic_vector(cycle(31 downto 0));
  mcycleh   <= std_logic_vector(cycle(63 downto 32));
  minstret  <= std_logic_vector(instret(31 downto 0));
  minstreth <= std_logic_vector(instret(63 downto 32));

  mtime  <= std_logic_vector(timer_value(REGISTER_SIZE-1 downto 0));
  mtimeh <= std_logic_vector(timer_value(timer_value'left downto timer_value'left-REGISTER_SIZE+1));

  misa(misa'left downto misa'left-1) <= "01";
  misa(23)                           <= '0' when VCP_ENABLE = DISABLED else '1';
  misa(8)                            <= '1';  --I
  misa(12)                           <= '1' when MULTIPLY_ENABLE       else '0';

  with csr_number select
    csr_readdata <=
    misa            when CSR_MISA,
    mscratch        when CSR_MSCRATCH,
    mstatus         when CSR_MSTATUS,
    mepc            when CSR_MEPC,
    mcause          when CSR_MCAUSE,
    mtval           when CSR_MTVAL,
    meimask         when CSR_MEIMASK,
    meipend         when CSR_MEIPEND,
    mtime           when CSR_MTIME,
    mtimeh          when CSR_MTIMEH,
    mtime           when CSR_UTIME,
    mtimeh          when CSR_UTIMEH,
    mcycle          when CSR_MCYCLE,
    mcycleh         when CSR_MCYCLEH,
    minstret        when CSR_MINSTRET,
    minstreth       when CSR_MINSTRETH,
    mcache          when CSR_MCACHE,
    mtvec           when CSR_MTVEC,
    mamr_base(0)    when CSR_MAMR0_BASE,
    mamr_base(1)    when CSR_MAMR1_BASE,
    mamr_base(2)    when CSR_MAMR2_BASE,
    mamr_base(3)    when CSR_MAMR3_BASE,
    mamr_last(0)    when CSR_MAMR0_LAST,
    mamr_last(1)    when CSR_MAMR1_LAST,
    mamr_last(2)    when CSR_MAMR2_LAST,
    mamr_last(3)    when CSR_MAMR3_LAST,
    mumr_base(0)    when CSR_MUMR0_BASE,
    mumr_base(1)    when CSR_MUMR1_BASE,
    mumr_base(2)    when CSR_MUMR2_BASE,
    mumr_base(3)    when CSR_MUMR3_BASE,
    mumr_last(0)    when CSR_MUMR0_LAST,
    mumr_last(1)    when CSR_MUMR1_LAST,
    mumr_last(2)    when CSR_MUMR2_LAST,
    mumr_last(3)    when CSR_MUMR3_LAST,
    (others => '0') when others;

  with func3 select
    csr_writedata <=
    csr_readdata(31 downto 5) & (csr_readdata(CSR_ZIMM'length-1 downto 0) and (not imm)) when CSRRCI_FUNC3,
    csr_readdata(31 downto 5) & (csr_readdata(CSR_ZIMM'length-1 downto 0) or imm)        when CSRRSI_FUNC3,
    std_logic_vector(resize(unsigned(imm), csr_writedata'length))                        when CSRRWI_FUNC3,
    csr_readdata and (not rs1_data)                                                      when CSRRC_FUNC3,
    csr_readdata or rs1_data                                                             when CSRRS_FUNC3,
    rs1_data                                                                             when others;  --CSRRW_FUNC3,

  --Currently all syscall instructions execute without backpressure
  from_syscall_ready <= '1';

  exceptions_gen : if ENABLE_EXCEPTIONS generate
    process(clk)
    begin
      if rising_edge(clk) then
        --Hold pc_correction causing signals until they have been processed
        if from_pc_correction_ready = '1' then
          was_mret    <= '0';
          was_illegal <= '0';
        end if;

        if(illegal_instruction = '1' or
           from_lsu_addr_misalign = '1' or
           from_branch_misaligned = '1' or
           (to_syscall_valid = '1' and (ebreak_select = '1' or ecall_select = '1'))) then
          --Handle Illegal Instructions
          mstatus(CSR_MSTATUS_MIE)  <= '0';
          mstatus(CSR_MSTATUS_MPIE) <= mstatus(CSR_MSTATUS_MIE);
          mcause(mcause'left)       <= '0';
          if from_branch_misaligned = '1' then
            mcause(CSR_MCAUSE_CODE'range) <= CSR_MCAUSE_FETCH_MISALIGN;
            --according to the tests its legal to put zero in this register
            mtval                         <= std_logic_vector(to_unsigned(0, mtval'length));
          elsif illegal_instruction = '1' then
            mcause(CSR_MCAUSE_CODE'range) <= CSR_MCAUSE_ILLEGAL;
            mtval                         <= instruction(mtval'range);
          elsif from_lsu_addr_misalign = '1' then
            mtval                         <= from_lsu_address;
            mcause(CSR_MCAUSE_CODE'range) <= CSR_MCAUSE_LOAD_MISALIGN;
            if instruction(5) = '1' then
              mcause(CSR_MCAUSE_CODE'range) <= CSR_MCAUSE_STORE_MISALIGN;
            end if;

          else
            if ebreak_select = '1' then
              mcause(CSR_MCAUSE_CODE'range) <= CSR_MCAUSE_EBREAK;
            else
              mcause(CSR_MCAUSE_CODE'range) <= CSR_MCAUSE_MECALL;
            end if;
          end if;
          mepc        <= std_logic_vector(current_pc);
          was_illegal <= '1';
        end if;

        if to_syscall_valid = '1' then
          if csr_select = '1' then
            --CSR Read/Write
            case csr_number is
              when CSR_MTVEC =>
                -- Only direct exceptions are available; zero lower two bits
                mtvec(REGISTER_SIZE-1 downto 2) <= csr_writedata(REGISTER_SIZE-1 downto 2);
              when CSR_MSTATUS =>
                -- Only 2 bits are writeable.
                mstatus(CSR_MSTATUS_MIE)  <= csr_writedata(CSR_MSTATUS_MIE);
                mstatus(CSR_MSTATUS_MPIE) <= csr_writedata(CSR_MSTATUS_MPIE);
              when CSR_MEPC =>
                mepc <= csr_writedata;
              when CSR_MCAUSE =>
                --MCAUSE is WLRL so only legal values need to be supported
                mcause(mcause'left)           <= csr_writedata(mcause'left);
                mcause(CSR_MCAUSE_CODE'range) <= csr_writedata(CSR_MCAUSE_CODE'range);
              when CSR_MTVAL =>
                mtval <= csr_writedata;
              when CSR_MEIMASK =>
                meimask_full <= csr_writedata;
              when CSR_MSCRATCH =>
                mscratch <= csr_writedata;
              when others => null;
            end case;
          end if;

          if mret_select = '1' then
            --MRET
            mstatus(CSR_MSTATUS_MIE)  <= mstatus(CSR_MSTATUS_MPIE);
            mstatus(CSR_MSTATUS_MPIE) <= '0';
            was_mret                  <= '1';
          end if;
        end if;

        if from_pc_correction_ready = '1' then
          interrupt_pc_correction_valid <= '0';
        end if;

        if interrupt_pending = '1' and core_idle = '1' then
          interrupt_pc_correction_valid <= '1';

          -- Latch in mepc the cycle before interrupt_pc_correction_valid goes high.
          -- When interrupt_pc_correction_valid goes high, the next_pc of the instruction fetch will
          -- be corrected to the interrupt reset vector.
          mepc                      <= std_logic_vector(program_counter);
          mstatus(CSR_MSTATUS_MIE)  <= '0';
          mstatus(CSR_MSTATUS_MPIE) <= '1';
          mcause(mcause'left)       <= '1';
          mcause_exc_code           <= CSR_MCAUSE_MEXT;
          if timer_interrupt = '1' then
            mcause_exc_code <= CSR_MCAUSE_MTIMER;
          end if;
        end if;

        if reset = '1' then
          was_mret                        <= '0';
          was_illegal                     <= '0';
          interrupt_pc_correction_valid   <= '0';
          mtvec(REGISTER_SIZE-1 downto 2) <= INTERRUPT_VECTOR(REGISTER_SIZE-1 downto 2);
          mstatus(CSR_MSTATUS_MIE)        <= '0';
          mstatus(CSR_MSTATUS_MPIE)       <= '0';
          mepc                            <= (others => '0');
          mcause(mcause'left)             <= '0';
          mcause_exc_code                 <= (others => '0');
          meimask_full                    <= (others => '0');
        end if;
        mepc(1 downto 0) <= "00";
      end if;
    end process;
    mtvec(1 downto 0)                                    <= (others => '0');
    mstatus(REGISTER_SIZE-1 downto CSR_MSTATUS_MPIE+1)   <= (others => '0');
    mstatus(CSR_MSTATUS_MPIE-1 downto CSR_MSTATUS_MIE+1) <= (others => '0');
    mstatus(CSR_MSTATUS_MIE-1 downto 0)                  <= (others => '0');
    mcause(mcause'left-1 downto CSR_MCAUSE_CODE'left+1)  <= (others => '0');
  end generate exceptions_gen;
  no_exceptions_gen : if not ENABLE_EXCEPTIONS generate
    mtvec                         <= (others => '0');
    was_mret                      <= '0';
    was_illegal                   <= '0';
    interrupt_pc_correction_valid <= '0';
    mstatus                       <= (others => '0');
    mepc                          <= (others => '0');
    mcause                        <= (others => '0');
  end generate no_exceptions_gen;

  memory_region_registers_gen : for gregister in 3 downto 0 generate
    amr_gen : if (AUX_MEMORY_REGIONS > gregister) and ((UC_MEMORY_REGIONS /= 0) or HAS_ICACHE or HAS_DCACHE) generate
      read_only_amr_gen : if gregister = 0 and AMR0_READ_ONLY generate
        amr_base_select(gregister) <= '0';
        amr_last_select(gregister) <= '0';
        mamr_base(gregister)       <= AMR0_ADDR_BASE;
        mamr_last(gregister)       <= AMR0_ADDR_LAST;
      end generate read_only_amr_gen;
      writeable_amr_gen : if gregister /= 0 or (not AMR0_READ_ONLY) generate
        amr_base_select(gregister) <=
          '1' when (csr_number(csr_number'left downto 3) = CSR_MAMR0_BASE(CSR_MAMR0_BASE'left downto 3) and
                    unsigned(csr_number(2 downto 0)) = to_unsigned(gregister, 3)) else
          '0';
        amr_last_select(gregister) <=
          '1' when (csr_number(csr_number'left downto 3) = CSR_MAMR0_LAST(CSR_MAMR0_LAST'left downto 3) and
                    unsigned(csr_number(2 downto 0)) = to_unsigned(gregister, 3)) else
          '0';

        process(clk)
        begin
          if rising_edge(clk) then
            --Don't write the new AMR until the pipeline and memory interface are
            --flushed
            if from_pc_correction_ready = '1' then
              if (memory_idle = '1' and
                  (from_icache_control_ready = '1' or to_icache_control_valid = '0') and
                  (from_dcache_control_ready = '1' or to_dcache_control_valid = '0')) then
                if amr_base_write(gregister) = '1' then
                  mamr_base(gregister) <= last_csr_writedata;
                end if;
                if amr_last_write(gregister) = '1' then
                  mamr_last(gregister) <= last_csr_writedata;
                end if;
              end if;
            end if;

            if reset = '1' then
              if gregister = 0 then
                mamr_base(gregister) <= AMR0_ADDR_BASE;
                mamr_last(gregister) <= AMR0_ADDR_LAST;
              else
                mamr_base(gregister) <= (others => '1');
                mamr_last(gregister) <= (others => '0');
              end if;
            end if;
          end if;
        end process;
      end generate writeable_amr_gen;
    end generate amr_gen;
    no_amr_gen : if ((AUX_MEMORY_REGIONS <= gregister) or
                     ((UC_MEMORY_REGIONS = 0) and (not HAS_ICACHE) and (not HAS_DCACHE))) generate
      amr_base_select(gregister) <= '0';
      amr_last_select(gregister) <= '0';
      mamr_base(gregister)       <= (others => '0');
      mamr_last(gregister)       <= (others => '0');
    end generate no_amr_gen;
    umr_gen : if (UC_MEMORY_REGIONS > gregister) and ((AUX_MEMORY_REGIONS /= 0) or HAS_ICACHE or HAS_DCACHE) generate
      read_only_umr_gen : if gregister = 0 and UMR0_READ_ONLY generate
        umr_base_select(gregister) <= '0';
        umr_last_select(gregister) <= '0';
        mumr_base(gregister)       <= UMR0_ADDR_BASE;
        mumr_last(gregister)       <= UMR0_ADDR_LAST;
      end generate read_only_umr_gen;
      writeable_umr_gen : if gregister /= 0 or (not UMR0_READ_ONLY) generate
        umr_base_select(gregister) <=
          '1' when (csr_number(csr_number'left downto 3) = CSR_MUMR0_BASE(CSR_MUMR0_BASE'left downto 3) and
                    unsigned(csr_number(2 downto 0)) = to_unsigned(gregister, 3)) else
          '0';
        umr_last_select(gregister) <=
          '1' when (csr_number(csr_number'left downto 3) = CSR_MUMR0_LAST(CSR_MUMR0_LAST'left downto 3) and
                    unsigned(csr_number(2 downto 0)) = to_unsigned(gregister, 3)) else
          '0';

        process(clk)
        begin
          if rising_edge(clk) then
            --Don't write the new UMR until the pipeline and memory interface are
            --flushed
            if from_pc_correction_ready = '1' then
              if (memory_idle = '1' and
                  (from_icache_control_ready = '1' or to_icache_control_valid = '0') and
                  (from_dcache_control_ready = '1' or to_dcache_control_valid = '0')) then
                if umr_base_write(gregister) = '1' then
                  mumr_base(gregister) <= last_csr_writedata;
                end if;
                if umr_last_write(gregister) = '1' then
                  mumr_last(gregister) <= last_csr_writedata;
                end if;
              end if;
            end if;

            if reset = '1' then
              if gregister = 0 then
                mumr_base(gregister) <= UMR0_ADDR_BASE;
                mumr_last(gregister) <= UMR0_ADDR_LAST;
              else
                mumr_base(gregister) <= (others => '1');
                mumr_last(gregister) <= (others => '0');
              end if;
            end if;
          end if;
        end process;
      end generate writeable_umr_gen;
    end generate umr_gen;
    no_umr_gen : if ((UC_MEMORY_REGIONS <= gregister) or
                     ((AUX_MEMORY_REGIONS = 0) and (not HAS_ICACHE) and (not HAS_DCACHE))) generate
      umr_base_select(gregister) <= '0';
      umr_last_select(gregister) <= '0';
      mumr_base(gregister)       <= (others => '0');
      mumr_last(gregister)       <= (others => '0');
    end generate no_umr_gen;
  end generate memory_region_registers_gen;
  amr_gen : for gregister in imax(AUX_MEMORY_REGIONS, 1)-1 downto 0 generate
    amr_base_addrs(((gregister+1)*REGISTER_SIZE)-1 downto gregister*REGISTER_SIZE) <= mamr_base(gregister);
    amr_last_addrs(((gregister+1)*REGISTER_SIZE)-1 downto gregister*REGISTER_SIZE) <= mamr_last(gregister);
  end generate amr_gen;
  umr_gen : for gregister in imax(UC_MEMORY_REGIONS, 1)-1 downto 0 generate
    umr_base_addrs(((gregister+1)*REGISTER_SIZE)-1 downto gregister*REGISTER_SIZE) <= mumr_base(gregister);
    umr_last_addrs(((gregister+1)*REGISTER_SIZE)-1 downto gregister*REGISTER_SIZE) <= mumr_last(gregister);
  end generate umr_gen;

  has_icache_gen : if HAS_ICACHE generate
    mcache(CSR_MCACHE_IEXISTS) <= '1';
  end generate has_icache_gen;
  no_icache_gen : if not HAS_ICACHE generate
    mcache(CSR_MCACHE_IEXISTS) <= '0';
  end generate no_icache_gen;
  has_dcache_gen : if HAS_DCACHE generate
    mcache(CSR_MCACHE_DEXISTS) <= '1';
  end generate has_dcache_gen;
  no_dcache_gen : if not HAS_DCACHE generate
    mcache(CSR_MCACHE_DEXISTS) <= '0';
  end generate no_dcache_gen;
  mcache(REGISTER_SIZE-1 downto CSR_MCACHE_DEXISTS+1) <= (others => '0');

  process(clk)
  begin
    if rising_edge(clk) then
      from_syscall_valid <= '0';

      --Hold pc_correction causing signals until they have been processed
      if from_pc_correction_ready = '1' then
        fence_pc_correction_valid <= '0';

        --On FENCE.I hold the PC correction until all pending writebacks have
        --occurred and the ICache is flushed (from_icache_control_ready is
        --hardwired to '1' when no ICache is present).
        if (memory_idle = '1' and
            (from_icache_control_ready = '1' or to_icache_control_valid = '0') and
            (from_dcache_control_ready = '1' or to_dcache_control_valid = '0')) then
          fence_pending <= '0';

          amr_base_write <= (others => '0');
          amr_last_write <= (others => '0');
          umr_base_write <= (others => '0');
          umr_last_write <= (others => '0');
        end if;
      end if;

      if from_icache_control_ready = '1' then
        to_icache_control_valid <= '0';
      end if;
      if from_dcache_control_ready = '1' then
        to_dcache_control_valid <= '0';
      end if;

      if illegal_instruction = '0' and to_syscall_valid = '1' then
        if csr_select = '1' then
          --CSR Read/Write
          from_syscall_valid <= '1';
          from_syscall_data  <= csr_readdata;
          last_csr_writedata <= csr_writedata;

          --Changing cacheability flushes the pipeline and clears the
          --memory interface before resuming.
          if or_slv(amr_base_select or amr_last_select or umr_base_select or umr_last_select) = '1' then
            fence_pc_correction_valid <= '1';
            fence_pending             <= '1';
          end if;
          amr_base_write <= amr_base_select;
          amr_last_write <= amr_last_select;
          umr_base_write <= umr_base_select;
          umr_last_write <= umr_last_select;
        end if;

        next_fence_pc             <= unsigned(current_pc) + to_unsigned(4, next_fence_pc'length);
        to_icache_control_command <= INVALIDATE;
        to_dcache_control_command <= WRITEBACK;

        to_cache_control_base <= rs1_data;
        to_cache_control_last <= rs2_data;

        if fencei_select = '1' then
          --FENCE.I/FENCE.RI
          fence_pc_correction_valid <= '1';
          fence_pending             <= '1';
          to_icache_control_valid   <= '1';
          to_dcache_control_valid   <= '1';

          if func7(1) = '0' then
            --FENCE.I does not take base/last parameters; applies to all of cache
            to_cache_control_base <= (others => '0');
            to_cache_control_last <= (others => '1');
          end if;

        --Unclear from the REGION draft spec if FENCE.RI should return a
        --value or not, since it can't partially complete.  Omitting for now
        --as it doesn't seem useful.
        end if;

        if cache_select = '1' then
          --CACHE control instructions

          --A FENCE is implied by all cache control instructions.
          fence_pc_correction_valid <= '1';
          fence_pending             <= '1';

          --Cache control instructions must return a value > rs2 on completion,
          --corresponding to the start of memory not affected.  Since if all
          --memory is affected it's valid to return 0, just return 0 for all
          --these instructions.
          from_syscall_valid <= '1';
          from_syscall_data  <= (others => '0');

          to_dcache_control_valid <= '1';
          case func7(1 downto 0) is
            when "00" =>                --CACHE_WRITEBACK_FUNC7(1 downto 0)
              to_dcache_control_command <= WRITEBACK;
            when "01" =>                --CACHE_FLUSH_FUNC7(1 downto 0)
              to_dcache_control_command <= FLUSH;
            when others =>  --CACHE_DISCARD_FUNC7(1 downto 0) + don't care
              --Currently INVALIDATE invalidates the entire cache which is not
              --safe.  Until region support is added just flush the cache which
              --is always safe.
              to_dcache_control_command <= FLUSH;
          end case;
        end if;

        if fence_select = '1' then
          --FENCE

          --All interfaces are strictly ordered and when switching between
          --interfaces (via AMR/UMR writes) a FENCE is performed, so FENCEs
          --don't need to do anything.

          --Unclear from the REGION draft spec if FENCE.RI should return a
          --value or not, since it can't partially complete.  Omitting for now
          --as it doesn't seem useful.
          null;
        end if;
      end if;

      if VCP_ENABLE /= DISABLED and vcp_writeback_en = '1' then
        -- To avoid having a 5 to one mux in execute, we add
        -- the writebacks from the vcp here. Since the writebacks
        -- are from vbx_get, which are sort of control/status
        -- registers it could be construed that this is an
        -- appropriate place for this logic
        from_syscall_data  <= vcp_writeback_data;
        from_syscall_valid <= '1';
      end if;

      if reset = '1' then
        from_syscall_valid        <= '0';
        fence_pc_correction_valid <= '0';
        fence_pending             <= '0';
        to_icache_control_valid   <= '0';
        to_dcache_control_valid   <= '0';
        amr_base_write            <= (others => '0');
        amr_last_write            <= (others => '0');
        umr_base_write            <= (others => '0');
        umr_last_write            <= (others => '0');
      end if;
    end if;
  end process;

--------------------------------------------------------------------------------
-- Handle Global Interrupts
--
-- If interrupt is pending and enabled, slip the pipeline. This is done by
-- sending the interrupt_pending signal to the instruction_fetch.
--
-- Once the pipeline is empty, then correct the PC.
--------------------------------------------------------------------------------
  interrupts_gen : if ENABLE_EXT_INTERRUPTS generate
    process(clk)
    begin
      if rising_edge(clk) then
        meipend(NUM_EXT_INTERRUPTS-1 downto 0) <= global_interrupts;
      end if;
    end process;
    meimask(NUM_EXT_INTERRUPTS-1 downto 0) <= meimask_full(NUM_EXT_INTERRUPTS-1 downto 0);
    not_all_interrupts_gen : if NUM_EXT_INTERRUPTS < REGISTER_SIZE generate
      meipend(REGISTER_SIZE-1 downto NUM_EXT_INTERRUPTS) <= (others => '0');
      meimask(REGISTER_SIZE-1 downto NUM_EXT_INTERRUPTS) <= (others => '0');
    end generate not_all_interrupts_gen;
  end generate interrupts_gen;
  no_interrupts_gen : if not ENABLE_EXT_INTERRUPTS generate
    meipend <= (others => '0');
    meimask <= (others => '0');
  end generate no_interrupts_gen;
  interrupt_pending <= mstatus(CSR_MSTATUS_MIE) when unsigned(meimask and meipend) /= 0 or timer_interrupt = '1' else '0';

  pause_ifetch <= fence_pending or interrupt_pending;

  -- There are several reasons that sys_calls might send a pc correction
  -- global interrupt
  -- illegal instruction
  -- mret instruction
  -- fence.i  (flush pipeline, and start over)
  to_pc_correction_valid <= fence_pc_correction_valid or was_mret or was_illegal or interrupt_pc_correction_valid;
  to_pc_correction_data <=
    next_fence_pc   when fence_pc_correction_valid = '1' else
    unsigned(mtvec) when (was_illegal = '1' or interrupt_pc_correction_valid = '1') else
    unsigned(mepc)  when was_mret = '1' else
    (others => '-');

end architecture rtl;
