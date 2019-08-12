library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.utils.all;

package constants_pkg is
  constant SIGN_EXTENSION_SIZE : positive := 20;

  --REGISTER NAMES
  constant REGISTER_NAME_SIZE : positive := 5;

  constant REGISTER_ZERO : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) := "00000";
  constant REGISTER_RA   : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) := "00001";
  constant REGISTER_SP   : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) := "00010";
  constant REGISTER_GP   : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) := "00011";
  constant REGISTER_TP   : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) := "00100";
  constant REGISTER_T0   : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) := "00101";
  constant REGISTER_T1   : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) := "00110";
  constant REGISTER_T2   : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) := "00111";
  constant REGISTER_S0   : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) := "01000";
  constant REGISTER_S1   : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) := "01001";
  constant REGISTER_A0   : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) := "01010";
  constant REGISTER_A1   : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) := "01011";
  constant REGISTER_A2   : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) := "01100";
  constant REGISTER_A3   : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) := "01101";
  constant REGISTER_A4   : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) := "01110";
  constant REGISTER_A5   : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) := "01111";
  constant REGISTER_A6   : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) := "10000";
  constant REGISTER_A7   : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) := "10001";
  constant REGISTER_S2   : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) := "10010";
  constant REGISTER_S3   : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) := "10011";
  constant REGISTER_S4   : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) := "10100";
  constant REGISTER_S5   : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) := "10101";
  constant REGISTER_S6   : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) := "10110";
  constant REGISTER_S7   : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) := "10111";
  constant REGISTER_S8   : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) := "11000";
  constant REGISTER_S9   : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) := "11001";
  constant REGISTER_S10  : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) := "11010";
  constant REGISTER_S11  : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) := "11011";
  constant REGISTER_T3   : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) := "11100";
  constant REGISTER_T4   : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) := "11101";
  constant REGISTER_T5   : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) := "11110";
  constant REGISTER_T6   : std_logic_vector(REGISTER_NAME_SIZE-1 downto 0) := "11111";

  constant REGISTER_RS1 : std_logic_vector(19 downto 15) := (others => '-');
  constant REGISTER_RS2 : std_logic_vector(24 downto 20) := (others => '-');
  constant REGISTER_RD  : std_logic_vector(11 downto 7)  := (others => '-');

  constant INSTR_OPCODE : std_logic_vector(6 downto 0)   := (others => '-');
  constant INSTR_FUNC3  : std_logic_vector(14 downto 12) := (others => '-');
  constant INSTR_FUNC7  : std_logic_vector(31 downto 25) := (others => '-');

--Major OP codes instr(6 downto 0)
  constant JAL_OP      : std_logic_vector(6 downto 0) := "1101111";
  constant JALR_OP     : std_logic_vector(6 downto 0) := "1100111";
  constant LUI_OP      : std_logic_vector(6 downto 0) := "0110111";
  constant AUIPC_OP    : std_logic_vector(6 downto 0) := "0010111";
  constant ALU_OP      : std_logic_vector(6 downto 0) := "0110011";
  constant ALUI_OP     : std_logic_vector(6 downto 0) := "0010011";
  constant LOAD_OP     : std_logic_vector(6 downto 0) := "0000011";
  constant STORE_OP    : std_logic_vector(6 downto 0) := "0100011";
  constant MISC_MEM_OP : std_logic_vector(6 downto 0) := "0001111";
  constant SYSTEM_OP   : std_logic_vector(6 downto 0) := "1110011";
  constant CUSTOM0_OP  : std_logic_vector(6 downto 0) := "0101011";
  constant CUSTOM1_OP  : std_logic_vector(6 downto 0) := "0111111";
  constant VCP32_OP    : std_logic_vector(6 downto 0) := CUSTOM0_OP;
  constant VCP64_OP    : std_logic_vector(6 downto 0) := CUSTOM1_OP;
  constant BRANCH_OP   : std_logic_vector(6 downto 0) := "1100011";

  constant OP_IMM_IMMEDIATE_SIZE : integer                        := 12;
  constant CSR_ZIMM              : std_logic_vector(19 downto 15) := (others => '-');

--MISC-MEM functions
  constant FENCE_FUNC3 : std_logic_vector(2 downto 0) := "000";

  constant FENCE_SW_BIT : natural := 20;
  constant FENCE_SR_BIT : natural := 21;
  constant FENCE_SO_BIT : natural := 22;
  constant FENCE_SI_BIT : natural := 23;
  constant FENCE_PW_BIT : natural := 24;
  constant FENCE_PR_BIT : natural := 25;
  constant FENCE_PO_BIT : natural := 26;
  constant FENCE_PI_BIT : natural := 27;

  constant REGION_FUNC3          : std_logic_vector(2 downto 0) := "001";
  constant FENCE_I_FUNC7         : std_logic_vector(6 downto 0) := "0000000";
  constant FENCE_RD_FUNC7        : std_logic_vector(6 downto 0) := "0000010";
  constant FENCE_RI_FUNC7        : std_logic_vector(6 downto 0) := "0000011";
  constant CACHE_WRITEBACK_FUNC7 : std_logic_vector(6 downto 0) := "0000100";
  constant CACHE_FLUSH_FUNC7     : std_logic_vector(6 downto 0) := "0000101";
  constant CACHE_DISCARD_FUNC7   : std_logic_vector(6 downto 0) := "0000110";


--CSR Addresses
  constant CSR_ADDRESS   : std_logic_vector(31 downto 20) := (others => '-');
  constant CSR_MSTATUS   : std_logic_vector(11 downto 0)  := x"300";
  constant CSR_MISA      : std_logic_vector(11 downto 0)  := x"301";
  constant CSR_MIE       : std_logic_vector(11 downto 0)  := x"304";
  constant CSR_MTVEC     : std_logic_vector(11 downto 0)  := x"305";
  constant CSR_MSCRATCH  : std_logic_vector(11 downto 0)  := x"340";
  constant CSR_MEPC      : std_logic_vector(11 downto 0)  := x"341";
  constant CSR_MCAUSE    : std_logic_vector(11 downto 0)  := x"342";
  constant CSR_MTVAL     : std_logic_vector(11 downto 0)  := x"343";
  constant CSR_MIP       : std_logic_vector(11 downto 0)  := x"344";
  constant CSR_UTIME     : std_logic_vector(11 downto 0)  := x"C01";
  constant CSR_UTIMEH    : std_logic_vector(11 downto 0)  := x"C81";
  constant CSR_MCYCLE    : std_logic_vector(11 downto 0)  := x"F00";
  constant CSR_MTIME     : std_logic_vector(11 downto 0)  := x"F01";
  constant CSR_MINSTRET  : std_logic_vector(11 downto 0)  := x"F02";
  constant CSR_MCYCLEH   : std_logic_vector(11 downto 0)  := x"F80";
  constant CSR_MTIMEH    : std_logic_vector(11 downto 0)  := x"F81";
  constant CSR_MINSTRETH : std_logic_vector(11 downto 0)  := x"F82";

--NON-STANDARD
  constant CSR_MEIMASK    : std_logic_vector(11 downto 0) := x"7C0";
  constant CSR_MEIPEND    : std_logic_vector(11 downto 0) := x"FC0";
  constant CSR_MCACHE     : std_logic_vector(11 downto 0) := x"BC0";
  constant CSR_MAMR0_BASE : std_logic_vector(11 downto 0) := x"BD0";
  constant CSR_MAMR1_BASE : std_logic_vector(11 downto 0) := x"BD1";
  constant CSR_MAMR2_BASE : std_logic_vector(11 downto 0) := x"BD2";
  constant CSR_MAMR3_BASE : std_logic_vector(11 downto 0) := x"BD3";
  constant CSR_MAMR0_LAST : std_logic_vector(11 downto 0) := x"BD8";
  constant CSR_MAMR1_LAST : std_logic_vector(11 downto 0) := x"BD9";
  constant CSR_MAMR2_LAST : std_logic_vector(11 downto 0) := x"BDA";
  constant CSR_MAMR3_LAST : std_logic_vector(11 downto 0) := x"BDB";
  constant CSR_MUMR0_BASE : std_logic_vector(11 downto 0) := x"BE0";
  constant CSR_MUMR1_BASE : std_logic_vector(11 downto 0) := x"BE1";
  constant CSR_MUMR2_BASE : std_logic_vector(11 downto 0) := x"BE2";
  constant CSR_MUMR3_BASE : std_logic_vector(11 downto 0) := x"BE3";
  constant CSR_MUMR0_LAST : std_logic_vector(11 downto 0) := x"BE8";
  constant CSR_MUMR1_LAST : std_logic_vector(11 downto 0) := x"BE9";
  constant CSR_MUMR2_LAST : std_logic_vector(11 downto 0) := x"BEA";
  constant CSR_MUMR3_LAST : std_logic_vector(11 downto 0) := x"BEB";

--CSR_MSTATUS BITS
  constant CSR_MSTATUS_MIE  : natural := 3;
  constant CSR_MSTATUS_MPIE : natural := 7;

--CSR_MCACHE BITS
  constant CSR_MCACHE_IEXISTS : natural                        := 0;
  constant CSR_MCACHE_DEXISTS : natural                        := 1;
  constant CSR_MCACHE_AMRS    : std_logic_vector(19 downto 16) := (others => '-');
  constant CSR_MCACHE_UMRS    : std_logic_vector(23 downto 20) := (others => '-');

  constant CSR_MCAUSE_CODE : std_logic_vector(3 downto 0) := (others => '-');

  constant CSR_MCAUSE_MTIMER         : std_logic_vector(CSR_MCAUSE_CODE'range) := x"7";
  constant CSR_MCAUSE_MEXT           : std_logic_vector(CSR_MCAUSE_CODE'range) := x"B";
  constant CSR_MCAUSE_ILLEGAL        : std_logic_vector(CSR_MCAUSE_CODE'range) := x"2";
  constant CSR_MCAUSE_EBREAK         : std_logic_vector(CSR_MCAUSE_CODE'range) := x"3";
  constant CSR_MCAUSE_MECALL         : std_logic_vector(CSR_MCAUSE_CODE'range) := x"B";
  constant CSR_MCAUSE_FETCH_MISALIGN : std_logic_vector(CSR_MCAUSE_CODE'range) := x"0";
  constant CSR_MCAUSE_LOAD_MISALIGN  : std_logic_vector(CSR_MCAUSE_CODE'range) := x"4";
  constant CSR_MCAUSE_STORE_MISALIGN : std_logic_vector(CSR_MCAUSE_CODE'range) := x"6";
--Priveleged FUNC3
  constant PRIV_FUNC3                : std_logic_vector(2 downto 0)            := "000";

  constant SYSTEM_ECALL  : std_logic_vector(11 downto 0) := x"000";
  constant SYSTEM_EBREAK : std_logic_vector(11 downto 0) := x"001";
  constant SYSTEM_MRET   : std_logic_vector(11 downto 0) := x"302";

--CSR FUNC3
  constant CSRRW_FUNC3  : std_logic_vector(2 downto 0) := "001";
  constant CSRRS_FUNC3  : std_logic_vector(2 downto 0) := "010";
  constant CSRRC_FUNC3  : std_logic_vector(2 downto 0) := "011";
  constant CSRRWI_FUNC3 : std_logic_vector(2 downto 0) := "101";
  constant CSRRSI_FUNC3 : std_logic_vector(2 downto 0) := "110";
  constant CSRRCI_FUNC3 : std_logic_vector(2 downto 0) := "111";

--JALR FUNC3
  constant JALR_FUNC3 : std_logic_vector(2 downto 0) := "000";

--Branch FUNC3
  constant BEQ_FUNC3  : std_logic_vector(2 downto 0) := "000";
  constant BNE_FUNC3  : std_logic_vector(2 downto 0) := "001";
  constant BLT_FUNC3  : std_logic_vector(2 downto 0) := "100";
  constant BGE_FUNC3  : std_logic_vector(2 downto 0) := "101";
  constant BLTU_FUNC3 : std_logic_vector(2 downto 0) := "110";
  constant BGEU_FUNC3 : std_logic_vector(2 downto 0) := "111";

--Load/store FUNC3
  constant LS_BYTE_FUNC3  : std_logic_vector(2 downto 0) := "000";
  constant LS_HALF_FUNC3  : std_logic_vector(2 downto 0) := "001";
  constant LS_WORD_FUNC3  : std_logic_vector(2 downto 0) := "010";
  constant LS_DUBL_FUNC3  : std_logic_vector(2 downto 0) := "011";
  constant LS_UBYTE_FUNC3 : std_logic_vector(2 downto 0) := "100";
  constant LS_UHALF_FUNC3 : std_logic_vector(2 downto 0) := "101";
  constant LS_UWORD_FUNC3 : std_logic_vector(2 downto 0) := "110";
  constant LS_UDUBL_FUNC3 : std_logic_vector(2 downto 0) := "111";

--ALU FUNC3
  constant ADDSUB_FUNC3 : std_logic_vector(2 downto 0) := "000";
  constant SLL_FUNC3    : std_logic_vector(2 downto 0) := "001";
  constant SLT_FUNC3    : std_logic_vector(2 downto 0) := "010";
  constant SLTU_FUNC3   : std_logic_vector(2 downto 0) := "011";
  constant XOR_FUNC3    : std_logic_vector(2 downto 0) := "100";
  constant SR_FUNC3     : std_logic_vector(2 downto 0) := "101";
  constant OR_FUNC3     : std_logic_vector(2 downto 0) := "110";
  constant AND_FUNC3    : std_logic_vector(2 downto 0) := "111";

--Multipy FUNC3
  constant MUL_FUNC3    : std_logic_vector(2 downto 0) := "000";
  constant MULH_FUNC3   : std_logic_vector(2 downto 0) := "001";
  constant MULHSU_FUNC3 : std_logic_vector(2 downto 0) := "010";
  constant MULHU_FUNC3  : std_logic_vector(2 downto 0) := "011";
  constant DIV_FUNC3    : std_logic_vector(2 downto 0) := "100";
  constant DIVU_FUNC3   : std_logic_vector(2 downto 0) := "101";
  constant REM_FUNC3    : std_logic_vector(2 downto 0) := "110";
  constant REMU_FUNC3   : std_logic_vector(2 downto 0) := "111";

--ALU FUNC7
  constant ALU_FUNC7         : std_logic_vector(6 downto 0) := "0000000";
  constant ADDSUB_ADD_FUNC7  : std_logic_vector(6 downto 0) := "0000000";
  constant ADDSUB_SUB_FUNC7  : std_logic_vector(6 downto 0) := "0100000";
  constant SHIFT_LOGIC_FUNC7 : std_logic_vector(6 downto 0) := "0000000";
  constant SHIFT_ARITH_FUNC7 : std_logic_vector(6 downto 0) := "0100000";
  constant MUL_FUNC7         : std_logic_vector(6 downto 0) := "0000001";


------------------------------------------------------------------------------
-- Types
------------------------------------------------------------------------------
  type cache_policy is (READ_ONLY, WRITE_THROUGH, WRITE_BACK);
  type cache_control_command is (INITIALIZE, INVALIDATE, FLUSH, WRITEBACK);
  type request_register_type is (OFF, LIGHT, FULL);
  type vcp_type is (DISABLED, THIRTY_TWO_BIT, SIXTY_FOUR_BIT);

  function INSTRUCTION_SIZE (
    VCP_ENABLE : vcp_type
    )
    return positive;

end package constants_pkg;

package body constants_pkg is

  function INSTRUCTION_SIZE (
    VCP_ENABLE : vcp_type
    )
    return positive is
  begin
    if VCP_ENABLE /= DISABLED then
      return 64;
    end if;
    return 32;
  end function INSTRUCTION_SIZE;

end package body constants_pkg;
