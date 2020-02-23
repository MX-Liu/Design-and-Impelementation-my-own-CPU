library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu_package.all;

entity ctrl is 
	port(
		rst				: in std_ulogic;
		
		stall_from_id 	: in std_ulogic;
		stall_from_ex	: in std_ulogic;
		
		stall 			: out std_ulogic_vector(5 downto 0)
	);
end entity ctrl;

architecture rtl of ctrl is
	
begin
	comb_prc : process(rst, stall_from_ex, stall_from_id)
	begin
		if(rst = '0') then
			stall <= (others => '0');
		elsif(stall_from_ex = '1') then
			stall <= b"000111";
		elsif(stall_from_id = '1') then
			stall <= b"001111";
		else
			stall <= (others => '0');
		end if;
	end process comb_prc;
	
end rtl;