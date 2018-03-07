library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.utils.all;
use work.constants_pkg.all;

entity system_calls is
  generic (
    REGISTER_SIZE    : positive range 32 to 32;
    COUNTER_LENGTH   : natural;
    POWER_OPTIMIZED  : boolean;
    INTERRUPT_VECTOR : std_logic_vector(31 downto 0);

    ENABLE_EXCEPTIONS     : boolean;
    ENABLE_EXT_INTERRUPTS : boolean;
    NUM_EXT_INTERRUPTS    : positive range 1 to 32;

    VCP_ENABLE : vcp_type;

    AUX_MEMORY_REGIONS : natural range 0 to 4;
    AMR0_ADDR_BASE     : std_logic_vector(31 downto 0);
    AMR0_ADDR_LAST     : std_logic_vector(31 downto 0);

    UC_MEMORY_REGIONS : natural range 0 to 4;
    UMR0_ADDR_BASE    : std_logic_vector(31 downto 0);
    UMR0_ADDR_LAST    : std_logic_vector(31 downto 0);

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

    to_syscall_valid   : in  std_logic;
    current_pc         : in  unsigned(REGISTER_SIZE-1 downto 0);
    instruction        : in  std_logic_vector(31 downto 0);
    rs1_data           : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
    from_syscall_ready : out std_logic;

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

    amr_base_addrs : out std_logic_vector((imax(AUX_MEMORY_REGIONS, 1)*REGISTER_SIZE)-1 downto 0);
    amr_last_addrs : out std_logic_vector((imax(AUX_MEMORY_REGIONS, 1)*REGISTER_SIZE)-1 downto 0);
    umr_base_addrs : out std_logic_vector((imax(UC_MEMORY_REGIONS, 1)*REGISTER_SIZE)-1 downto 0);
    umr_last_addrs : out std_logic_vector((imax(UC_MEMORY_REGIONS, 1)*REGISTER_SIZE)-1 downto 0);
    pause_ifetch   : out std_logic;

    vcp_writeback_en   : in std_logic;
    vcp_writeback_data : in std_logic_vector(REGISTER_SIZE-1 downto 0)
    );
end entity system_calls;

architecture rtl of system_calls is
  component instruction_legal is
    generic (
      CHECK_LEGAL_INSTRUCTIONS : boolean;
      VCP_ENABLE               : vcp_type
      );
    port (
      instruction : in  std_logic_vector(31 downto 0);
      legal       : out std_logic
      );
  end component;

  -- CSR signals. These are initialized to zero so that if any bits are never
  -- assigned, they act like constants.
  signal mstatus      : std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
  signal mepc         : std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
  signal mcause       : std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
  signal mbadaddr     : std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
  signal mtime        : std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
  signal mtimeh       : std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
  signal meimask      : std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
  signal meimask_full : std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
  signal meipend      : std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
  signal mcache       : std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
  signal misa         : std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
  --Assign csr_select instead of alias to get csr_select'right = 0 for indexing
  signal csr_select   : std_logic_vector(CSR_ADDRESS'length-1 downto 0);
  alias func3 is instruction(INSTR_FUNC3'range);
  alias imm is instruction(CSR_ZIMM'range);

  alias bit_sel             : std_logic_vector(REGISTER_SIZE-1 downto 0) is rs1_data;
  signal csr_readdata       : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal csr_writedata      : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal last_csr_writedata : std_logic_vector(REGISTER_SIZE-1 downto 0);

  signal legal_instr : std_logic;

  signal was_mret      : std_logic;
  signal was_illegal   : std_logic;
  signal was_fence_i   : std_logic;
  signal next_fence_pc : unsigned(REGISTER_SIZE-1 downto 0);

  signal fence_pending                 : std_logic;
  signal interrupt_pending             : std_logic;
  signal interrupt_pc_correction_valid : std_logic;

  signal time_counter : unsigned(63 downto 0);

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
  instr_check : instruction_legal
    generic map (
      CHECK_LEGAL_INSTRUCTIONS => ENABLE_EXCEPTIONS,
      VCP_ENABLE               => VCP_ENABLE
      )
    port map (
      instruction => instruction,
      legal       => legal_instr
      );

  -- Process for the timer counter.
  process(clk)
  begin
    if rising_edge(clk) then
      time_counter <= time_counter + 1;
      if reset = '1' then
        time_counter <= (others => '0');
      end if;
    end if;
  end process;

  mtime  <= std_logic_vector(time_counter(REGISTER_SIZE-1 downto 0)) when COUNTER_LENGTH /= 0 else (others => '0');
  mtimeh <= std_logic_vector(time_counter(time_counter'left downto time_counter'left-REGISTER_SIZE+1))
            when REGISTER_SIZE = 32 and COUNTER_LENGTH = 64 else (others => '0');
  misa(misa'left downto misa'left-1) <= "01";
  misa(23)                           <= '0' when VCP_ENABLE = DISABLED else '1';
  csr_select                         <= instruction(CSR_ADDRESS'range);
  with csr_select select
    csr_readdata <=
    misa            when CSR_MISA,
    mstatus         when CSR_MSTATUS,
    mepc            when CSR_MEPC,
    mcause          when CSR_MCAUSE,
    mbadaddr        when CSR_MBADADDR,
    meimask         when CSR_MEIMASK,
    meipend         when CSR_MEIPEND,
    mtime           when CSR_MTIME,
    mtimeh          when CSR_MTIMEH,
    mtime           when CSR_UTIME,
    mtimeh          when CSR_UTIMEH,
    mcache          when CSR_MCACHE,
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
    rs1_data
    when CSRRW_FUNC3,
    csr_readdata or bit_sel
    when CSRRS_FUNC3,
    csr_readdata(31 downto 5) & (csr_readdata(CSR_ZIMM'length-1 downto 0) or imm)
    when CSRRSI_FUNC3,
    csr_readdata and (not bit_sel)
    when CSRRC_FUNC3,
    csr_readdata(31 downto 5) & (csr_readdata(CSR_ZIMM'length-1 downto 0) and (not imm))
    when CSRRCI_FUNC3,
    csr_readdata
    when others;

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

        if to_syscall_valid = '1' then
          if legal_instr /= '1' then
            -----------------------------------------------------------------------------
            -- Handle Illegal Instructions
            -----------------------------------------------------------------------------
            mstatus(CSR_MSTATUS_MIE)      <= '0';
            mstatus(CSR_MSTATUS_MPIE)     <= mstatus(CSR_MSTATUS_MIE);
            mcause(mcause'left)           <= '0';
            mcause(CSR_MCAUSE_CODE'range) <= std_logic_vector(to_unsigned(CSR_MCAUSE_ILLEGAL, CSR_MCAUSE_CODE'length));
            mepc                          <= std_logic_vector(current_pc);
            was_illegal                   <= '1';
          elsif instruction(MAJOR_OP'range) = SYSTEM_OP then
            if func3 /= "000" then
              -----------------------------------------------------------------------------
              -- CSR Read/Write
              -----------------------------------------------------------------------------
              case csr_select is
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
                when CSR_MBADADDR =>
                  mbadaddr <= csr_writedata;
                when CSR_MEIMASK =>
                  meimask_full <= csr_writedata;
                --Note that meipend is read-only
                when others => null;
              end case;
            elsif instruction(SYSTEM_NOT_CSR'range) = SYSTEM_NOT_CSR then
              -----------------------------------------------------------------------------
              -- Other System Instructions
              -----------------------------------------------------------------------------
              if instruction(31 downto 30) = "00" and instruction(27 downto 20) = "00000010" then
                -- MRET
                -- We only have one privilege level (M), so treat all [USHM]RET instructions
                -- as the same.
                mstatus(CSR_MSTATUS_MIE)  <= mstatus(CSR_MSTATUS_MPIE);
                mstatus(CSR_MSTATUS_MPIE) <= '0';
                was_mret                  <= '1';
              else
                -- Illegal or ECALL/EBREAK
                mstatus(CSR_MSTATUS_MIE)  <= '0';
                mstatus(CSR_MSTATUS_MPIE) <= mstatus(CSR_MSTATUS_MIE);
                mcause(mcause'left)       <= '0';
                case csr_select is
                  when SYSTEM_ECALL =>
                    mcause(CSR_MCAUSE_CODE'range) <=
                      std_logic_vector(to_unsigned(CSR_MCAUSE_MECALL, CSR_MCAUSE_CODE'length));
                  when SYSTEM_EBREAK =>
                    mcause(CSR_MCAUSE_CODE'range) <=
                      std_logic_vector(to_unsigned(CSR_MCAUSE_EBREAK, CSR_MCAUSE_CODE'length));
                  when others =>
                    mcause(CSR_MCAUSE_CODE'range) <=
                      std_logic_vector(to_unsigned(CSR_MCAUSE_ILLEGAL, CSR_MCAUSE_CODE'length));
                end case;
                mepc        <= std_logic_vector(current_pc);
                was_illegal <= '1';
              end if;
            else
              -- Illegal
              mstatus(CSR_MSTATUS_MIE)  <= '0';
              mstatus(CSR_MSTATUS_MPIE) <= mstatus(CSR_MSTATUS_MIE);
              mcause(mcause'left)       <= '0';
              mcause(CSR_MCAUSE_CODE'range) <=
                std_logic_vector(to_unsigned(CSR_MCAUSE_ILLEGAL, CSR_MCAUSE_CODE'length));
              mepc        <= std_logic_vector(current_pc);
              was_illegal <= '1';
            end if;
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
          mepc                          <= std_logic_vector(program_counter);
          mstatus(CSR_MSTATUS_MIE)      <= '0';
          mstatus(CSR_MSTATUS_MPIE)     <= '1';
          mcause(mcause'left)           <= '1';
          mcause(CSR_MCAUSE_CODE'range) <= std_logic_vector(to_unsigned(CSR_MCAUSE_MEXT, CSR_MCAUSE_CODE'length));
          mcause(mcause'left)           <= '1';
        end if;

        if reset = '1' then
          was_mret                      <= '0';
          was_illegal                   <= '0';
          interrupt_pc_correction_valid <= '0';
          --Note that meipend is read-only
          mstatus(CSR_MSTATUS_MIE)      <= '0';
          mstatus(CSR_MSTATUS_MPIE)     <= '0';
          mepc                          <= (others => '0');
          mcause(mcause'left)           <= '0';
          mcause(CSR_MCAUSE_CODE'range) <= (others => '0');
          meimask_full                  <= (others => '0');
        end if;
      end if;
    end process;
    mstatus(REGISTER_SIZE-1 downto CSR_MSTATUS_MPIE+1)   <= (others => '0');
    mstatus(CSR_MSTATUS_MPIE-1 downto CSR_MSTATUS_MIE+1) <= (others => '0');
    mstatus(CSR_MSTATUS_MIE-1 downto 0)                  <= (others => '0');
    mcause(mcause'left-1 downto CSR_MCAUSE_CODE'left+1)  <= (others => '0');
  end generate exceptions_gen;
  no_exceptions_gen : if not ENABLE_EXCEPTIONS generate
    was_mret                      <= '0';
    was_illegal                   <= '0';
    interrupt_pc_correction_valid <= '0';
    mstatus                       <= (others => '0');
    mepc                          <= (others => '0');
    mcause                        <= (others => '0');
  end generate no_exceptions_gen;

  memory_region_registers_gen : for gregister in 3 downto 0 generate
    amr_gen : if (AUX_MEMORY_REGIONS > gregister) and ((UC_MEMORY_REGIONS /= 0) or HAS_ICACHE or HAS_DCACHE) generate
      amr_base_select(gregister) <=
        '1' when (csr_select(csr_select'left downto 3) = CSR_MAMR0_BASE(CSR_MAMR0_BASE'left downto 3) and
                  unsigned(csr_select(2 downto 0)) = to_unsigned(gregister, 3)) else
        '0';
      amr_last_select(gregister) <=
        '1' when (csr_select(csr_select'left downto 3) = CSR_MAMR0_LAST(CSR_MAMR0_LAST'left downto 3) and
                  unsigned(csr_select(2 downto 0)) = to_unsigned(gregister, 3)) else
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
              mamr_base(gregister) <= (others => '0');
              mamr_last(gregister) <= (others => '0');
            end if;
          end if;
        end if;
      end process;
    end generate amr_gen;
    no_amr_gen : if ((AUX_MEMORY_REGIONS <= gregister) or
                     ((UC_MEMORY_REGIONS = 0) and (not HAS_ICACHE) and (not HAS_DCACHE))) generate
      amr_base_select(gregister) <= '0';
      amr_last_select(gregister) <= '0';
      mamr_base(gregister)       <= (others => '0');
      mamr_last(gregister)       <= (others => '0');
    end generate no_amr_gen;
    umr_gen : if (UC_MEMORY_REGIONS > gregister) and ((AUX_MEMORY_REGIONS /= 0) or HAS_ICACHE or HAS_DCACHE) generate
      umr_base_select(gregister) <=
        '1' when (csr_select(csr_select'left downto 3) = CSR_MUMR0_BASE(CSR_MUMR0_BASE'left downto 3) and
                  unsigned(csr_select(2 downto 0)) = to_unsigned(gregister, 3)) else
        '0';
      umr_last_select(gregister) <=
        '1' when (csr_select(csr_select'left downto 3) = CSR_MUMR0_LAST(CSR_MUMR0_LAST'left downto 3) and
                  unsigned(csr_select(2 downto 0)) = to_unsigned(gregister, 3)) else
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
              mumr_base(gregister) <= (others => '0');
              mumr_last(gregister) <= (others => '0');
            end if;
          end if;
        end if;
      end process;
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
        was_fence_i <= '0';

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

      if to_syscall_valid = '1' then
        next_fence_pc <= unsigned(current_pc) + to_unsigned(4, next_fence_pc'length);

        if legal_instr = '1' then
          if instruction(MAJOR_OP'range) = SYSTEM_OP then
            if func3 /= "000" then
              -----------------------------------------------------------------------------
              -- CSR Read/Write
              -----------------------------------------------------------------------------
              from_syscall_valid <= '1';
              from_syscall_data  <= csr_readdata;
              last_csr_writedata <= csr_writedata;

              --Changing cacheability flushes the pipeline and clears the
              --memory interface before resuming.
              if or_slv(amr_base_select or amr_last_select or umr_base_select or umr_last_select) = '1' then
                was_fence_i   <= '1';
                fence_pending <= '1';
              end if;
              amr_base_write <= amr_base_select;
              amr_last_write <= amr_last_select;
              umr_base_write <= umr_base_select;
              umr_last_write <= umr_last_select;
            end if;
          elsif instruction(MAJOR_OP'range) = FENCE_OP then
            to_icache_control_command <= INVALIDATE;
            to_dcache_control_command <= WRITEBACK;
            -- A FENCE instruction is a NOP.
            -- A FENCE.I instruction is a pipeline flush.
            if instruction(12) = '1' then
              was_fence_i             <= '1';
              fence_pending           <= '1';
              to_icache_control_valid <= '1';
              to_dcache_control_valid <= '1';
            end if;
          end if;
        end if;
      end if;

      if VCP_ENABLE /= DISABLED and vcp_writeback_en = '1' then
        -- To avoid having a 4 5o one mux in execute, We add
        -- the writebacks from the vcp here. Since the writebacks
        -- are from vbx_get, which are sort of control/status
        -- registers it could be construed that this is an
        -- appropriate place for this logic
        from_syscall_data  <= vcp_writeback_data;
        from_syscall_valid <= '1';
      end if;

      if reset = '1' then
        was_fence_i             <= '0';
        fence_pending           <= '0';
        to_icache_control_valid <= '0';
        to_dcache_control_valid <= '0';
        amr_base_write          <= (others => '0');
        amr_last_write          <= (others => '0');
        umr_base_write          <= (others => '0');
        umr_last_write          <= (others => '0');
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
  interrupt_pending <= mstatus(CSR_MSTATUS_MIE) when unsigned(meimask and meipend) /= 0 else '0';

  pause_ifetch <= fence_pending or interrupt_pending;

  -- There are several reasons that sys_calls might send a pc correction
  -- global interrupt
  -- illegal instruction
  -- mret instruction
  -- fence.i  (flush pipeline, and start over)
  to_pc_correction_valid <= was_fence_i or was_mret or was_illegal or interrupt_pc_correction_valid;
  to_pc_correction_data <=
    next_fence_pc when was_fence_i = '1' else
    unsigned(INTERRUPT_VECTOR(REGISTER_SIZE-1 downto 0)) when (was_illegal = '1' or
                                                               interrupt_pc_correction_valid = '1') else
    unsigned(mepc) when was_mret = '1' else
    (others => '-');

end architecture rtl;


--------------------------------------------------------------------------------
-- Legal instruction checker
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants_pkg.all;
use work.utils.all;

entity instruction_legal is
  generic (
    CHECK_LEGAL_INSTRUCTIONS : boolean;
    VCP_ENABLE               : vcp_type
    );
  port (
    instruction : in  std_logic_vector(31 downto 0);
    legal       : out std_logic
    );
end entity;

architecture rtl of instruction_legal is
  alias opcode7 is instruction(6 downto 0);
  alias func3 is instruction(INSTR_FUNC3'range);
  alias func7 is instruction(31 downto 25);
  alias csr_num is instruction(SYSTEM_MINOR_OP'range);
begin
  legal <=
    '1' when (CHECK_LEGAL_INSTRUCTIONS = false or
              opcode7 = LUI_OP or
              opcode7 = AUIPC_OP or
              opcode7 = JAL_OP or
              (opcode7 = JALR_OP and func3 = "000") or
              (opcode7 = BRANCH_OP and func3 /= "010" and func3 /= "011") or
              (opcode7 = LOAD_OP and func3 /= "011" and func3 /= "110" and func3 /= "111") or
              (opcode7 = STORE_OP and (func3 = "000" or func3 = "001" or func3 = "010")) or
              opcode7 = ALUI_OP or      -- Does not catch illegal
                                        -- shift amounts
              (opcode7 = ALU_OP and (func7 = ALU_F7 or func7 = MUL_F7 or func7 = SUB_F7))or
              (opcode7 = SYSTEM_OP) or  --Illegal sysops checked in exception handling
              (opcode7 = FENCE_OP) or   -- All fence ops are treated as legal
              (opcode7 = LVE32_OP and VCP_ENABLE /= DISABLED)or
              (opcode7 = LVE64_OP and VCP_ENABLE = SIXTY_FOUR_BIT)) else '0';
end architecture;
