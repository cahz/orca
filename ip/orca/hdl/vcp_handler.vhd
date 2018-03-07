library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.std_logic_textio.all;          -- I/O for logic types

library work;
use work.rv_components.all;
use work.utils.all;
use work.constants_pkg.all;


entity vcp_handler is
  generic (
    REGISTER_SIZE : positive range 32 to 32;
    VCP_ENABLE    : vcp_type
    );
  port (
    clk   : in std_logic;
    reset : in std_logic;

    instruction : in std_logic_vector(INSTRUCTION_SIZE(VCP_ENABLE)-1 downto 0);
    valid_instr : in std_logic;
    vcp_ready   : in std_logic;

    rs1_data : in std_logic_vector(REGISTER_SIZE-1 downto 0);
    rs2_data : in std_logic_vector(REGISTER_SIZE-1 downto 0);
    rs3_data : in std_logic_vector(REGISTER_SIZE-1 downto 0);

    vcp_data0 : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    vcp_data1 : out std_logic_vector(REGISTER_SIZE-1 downto 0);
    vcp_data2 : out std_logic_vector(REGISTER_SIZE-1 downto 0);

    vcp_instruction   : out std_logic_vector(40 downto 0);
    vcp_valid_instr   : out std_logic;
    vcp_was_executing : out std_logic
    );
end entity vcp_handler;

architecture rtl of vcp_handler is
  signal dsz         : std_logic_vector(1 downto 0);
  signal instr_64bit : boolean;
begin  -- architecture rtl

  --extended bits
  dsz         <= instruction(31) & instruction(29);
  instr_64bit <= instruction(MAJOR_OP'range) = LVE64_OP;

  full_vcp_gen : if VCP_ENABLE = SIXTY_FOUR_BIT generate
    vcp_instruction(40)           <= instruction(40)           when instr_64bit else '0';  --extra instruction
    vcp_instruction(39)           <= instruction(39)           when instr_64bit else '0';  --masked
    vcp_instruction(38)           <= instruction(38)           when instr_64bit else '1';  --bsign
    vcp_instruction(37)           <= instruction(37)           when instr_64bit else '1';  --asign
    vcp_instruction(36)           <= instruction(36)           when instr_64bit else '1';  --opsign
    vcp_instruction(35 downto 34) <= instruction(35 downto 34) when instr_64bit else dsz;  --b size
    vcp_instruction(33 downto 32) <= instruction(33 downto 32) when instr_64bit else dsz;  --b size
  end generate full_vcp_gen;
  light_vcp_gen : if VCP_ENABLE /= SIXTY_FOUR_BIT generate
    vcp_instruction(40)           <= '0';  --extra instruction
    vcp_instruction(39)           <= '0';  --masked
    vcp_instruction(38)           <= '1';  --bsign
    vcp_instruction(37)           <= '1';  --asign
    vcp_instruction(36)           <= '1';  --opsign
    vcp_instruction(35 downto 34) <= dsz;  --b size
    vcp_instruction(33 downto 32) <= dsz;  --b size
  end generate light_vcp_gen;
  vcp_instruction(31 downto 0) <= instruction(31 downto 0);

  vcp_data0 <= rs1_data;
  vcp_data1 <= rs2_data;
  vcp_data2 <= rs3_data;

  vcp_enabled_gen : if VCP_ENABLE /= DISABLED generate
    vcp_valid_instr <= valid_instr when instruction(MAJOR_OP'range) = LVE32_OP or instr_64bit else '0';
    process (clk) is
    begin
      if rising_edge(clk) then
        vcp_was_executing <= not vcp_ready;
      end if;
    end process;
  end generate vcp_enabled_gen;
  vcp_disabled_gen : if VCP_ENABLE = DISABLED generate
    vcp_valid_instr   <= '0';
    vcp_was_executing <= '0';
  end generate vcp_disabled_gen;

end architecture rtl;
