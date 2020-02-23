library ieee;
use ieee.std_logic_1164.all;
use work.cpu_package.all;

entity mem_wb is
	port(
		clk			: in std_ulogic;
		rst			: in std_ulogic;
		
		mem_wd		: in std_ulogic_vector(RegAddrBus - 1 downto 0);
		mem_wreg	: in std_ulogic;
		mem_wdata	: in std_ulogic_vector(RegBus - 1 downto 0);
		
		wb_wd		: out std_ulogic_vector(RegAddrBus - 1 downto 0);
		wb_wreg		: out std_ulogic;
		wb_wdata	: out std_ulogic_vector(RegBus - 1 downto 0)
	);
end entity mem_wb;

architecture rtl of mem_wb is

begin
	reg_prc : process(clk)
	begin
		if(rising_edge(clk)) then
			if(rst = '0') then
				wb_wd 	<= (others => '0');
				wb_wdata<= (others => '0');
				wb_wreg <= '0';
			else
				wb_wd 	<= mem_wd;
				wb_wdata<= mem_wdata;
				wb_wreg	<= mem_wreg;
			end if;
		end if;
	end process reg_prc;
end rtl;