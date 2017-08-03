library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity memory_mapped_reset is
	generic (
		REGISTER_SIZE : integer := 32;
		ADDR_WIDTH : integer := 2
	);
	port (
		clk								: in  std_logic;
		reset			  			: in  std_logic;
		avm_address       : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
		avm_read					: in  std_logic;
		avm_readdata      : out std_logic_vector(REGISTER_SIZE-1 downto 0);
		avm_readdatavalid : out std_logic;
		avm_write         : in	std_logic;
		avm_writedata     : in 	std_logic_vector(REGISTER_SIZE-1 downto 0);

		reset_out		  : out std_logic
	);
end entity memory_mapped_reset;

architecture rtl of memory_mapped_reset is
	signal reset_out_reg : std_logic;
begin

	process(clk)
	begin
		if rising_edge(clk) then
			avm_readdatavalid <= '0';

			-- reset_out is registered to prevent meta-stability.
			reset_out <= reset_out_reg;

			if reset = '1' then
				reset_out <= '0';	
				reset_out_reg <= '0';
			else
				if avm_address = std_logic_vector(to_unsigned(0, ADDR_WIDTH)) then
					if avm_write = '1' then
						reset_out_reg <= avm_writedata(0);		
					end if;
					if avm_read = '1' then
						avm_readdata <= (0 => reset_out_reg, others => '0');
						avm_readdatavalid <= '1';
					end if;
				end if;
			end if;
		end if;	
	end process;	
end architecture;
