library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu_package.all;

entity hilo is
	port(
		clk			: in std_ulogic;
		rst			: in std_ulogic;
		
		we 			: in std_ulogic;
		hi_i		: in std_ulogic_vector(RegBus - 1 downto 0);
		lo_i		: in std_ulogic_vector(RegBus - 1 downto 0);
		
		hi_o		: out std_ulogic_vector(RegBus - 1 downto 0);
		lo_o	: out std_ulogic_vector(RegBus - 1 downto 0)	
	);
end entity hilo;

architecture rtl of hilo is 

begin
	reg_prc : process(clk)
	begin
		if(rising_edge(clk)) then
			if(rst = '0') then
				hi_o <= (others => '0');
				lo_o <= (others => '0');
			elsif(we = '1') then
				hi_o <= hi_i;
				lo_o <= lo_i;
			end if;
		end if;
	end process reg_prc;
end rtl;
