library ieee;
use ieee.std_logic_1164.all;
use work.cpu_package.all;

entity if_id is
	port(
		rst		: in std_ulogic;
		clk		: in std_ulogic;
		
		if_pc	: in std_ulogic_vector(InstAddrBus - 1 downto 0);  -- the address of the instruction during during fetch
		if_inst	: in std_ulogic_vector(InstAddrBus - 1 downto 0);  -- the instruction during fetch
		
		id_pc	: out std_ulogic_vector(InstAddrBus - 1 downto 0); -- the address of the instruction during decode
		id_inst	: out std_ulogic_vector(InstAddrBus - 1 downto 0)  -- the instruction during decode;
	);
end entity if_id;

architecture rtl of if_id is

begin 
	reg_prc: process(clk)
	begin
		if(rising_edge(clk))then
			if(rst = '0') then
				id_pc	<= (others => '0');
				id_inst	<= (others => '0');
			else
				id_pc	<= if_pc;
				id_inst	<= if_inst;
			end if;
		end if;
		
	end process reg_prc;
	
end rtl;