library ieee;
use ieee.std_logic_1164.all;
use work.cpu_package.all;

entity mem is 
	port(
		rst			: in std_ulogic;
		
		wd_i		: in std_ulogic_vector(RegAddrBus - 1 downto 0);
		wreg_i		: in std_ulogic;
		wdata_i		: in std_ulogic_vector(RegBus - 1 downto 0);
		
		whilo_i		: in std_ulogic;
		hi_i		: in std_ulogic_vector(RegBus - 1 downto 0);
		lo_i		: in std_ulogic_vector(RegBus - 1 downto 0);
		
		whilo_o		: out std_ulogic;
		hi_o		: out std_ulogic_vector(RegBus - 1 downto 0);
		lo_o		: out std_ulogic_vector(RegBus - 1 downto 0);
		
		wd_o		: out std_ulogic_vector(RegAddrBus - 1 downto 0);
		wreg_o		: out std_ulogic;
		wdata_o		: out std_ulogic_vector(RegBus - 1 downto 0)
	);
end entity mem;

architecture rtl of mem is
begin
	comb_prc : process(rst, wd_i, wreg_i, wdata_i,whilo_i,hi_i,lo_i)
	begin
		if(rst = '0') then
			wd_o 	<= (others => '0');
			wreg_o 	<= '0';
			wdata_o	<= (others => '0');
			
			whilo_o <= '0';
			hi_o 	<= (others => '0');
			lo_o  	<= (others => '0');
		else
			wd_o 	<= wd_i;
			wreg_o 	<= wreg_i;
			wdata_o	<= wdata_i;
			whilo_o <= whilo_i;
			hi_o 	<= hi_i;
			lo_o  	<= lo_i;
		end if;
	end process comb_prc;
end rtl;
