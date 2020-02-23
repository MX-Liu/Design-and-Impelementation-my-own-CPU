library ieee;
use ieee.std_logic_1164.all;
use work.cpu_package.all;

entity ex_mem is
	port(
		clk			: in std_ulogic;
		rst			: in std_ulogic;
		
		ex_wd		: in std_ulogic_vector(RegAddrBus - 1 downto 0);
		ex_wreg		: in std_ulogic;
		ex_wdata	: in std_ulogic_vector(RegBus - 1 downto 0);
		
		mem_wd		: out std_ulogic_vector(RegAddrBus - 1 downto 0);
		mem_wreg	: out std_ulogic;
		mem_wdata	: out std_ulogic_vector(RegBus - 1 downto 0)
	);
end entity ex_mem;

architecture rtl of ex_mem is 
begin
	reg_prc : process(clk, rst)
	begin
		if(rst = '0') then
			mem_wd		<= (others => '0');
			mem_wreg	<= '0';
			mem_wdata	<= (others => '0');
		elsif(rising_edge(clk)) then
			mem_wd		<= ex_wd;
			mem_wreg	<= ex_wreg;
			mem_wdata	<= ex_wdata;
		end if;
	end process reg_prc;
end rtl;
