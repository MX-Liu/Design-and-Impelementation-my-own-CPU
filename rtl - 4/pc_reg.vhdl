library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu_package.all;

entity pc_reg is
	port(
		rst		: in std_ulogic;
		clk		: in std_ulogic;
		
		pc		: out std_ulogic_vector(InstAddrBus - 1 downto 0);
		ce 		: out std_ulogic
	);
end entity pc_reg;

architecture rtl of pc_reg is
	signal l_pc_nxt 		: std_ulogic_vector(InstAddrBus - 1 downto 0) := (others => '0' );
	signal l_pc		 		: std_ulogic_vector(InstAddrBus - 1 downto 0) := (others => '0' );
begin
	enable_prc : process(clk,rst)
	begin
		if(rst = '0') then
			ce <= ChipDisable;
		elsif(rising_edge(clk)) then
			ce <= ChipEnable;
		end if;
	end process enable_prc;
	
	
	pc_register : process(clk)
	begin
		if(ce = '0') then
			pc <= (others => '0');
		elsif(rising_edge(clk)) then
			--pc <= l_pc_nxt;
			pc <= std_ulogic_vector(unsigned (pc) + 4);
			
		end if;
	end process pc_register;
	
	--counter;
	--l_pc_nxt <= std_ulogic_vector(unsigned (l_pc) + 4);
	-- output
	--pc <= l_pc;

end rtl;

	
	
	
	
	
	
	
	
	
	
	
	
	
		