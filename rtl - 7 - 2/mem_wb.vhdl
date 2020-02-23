library ieee;
use ieee.std_logic_1164.all;
use work.cpu_package.all;

entity mem_wb is
	 
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
				wb_whilo<= '0';
				wb_hi	<= (others => '0');
				wb_lo	<= (others => '0');	
			elsif(stall(4) = '1' and stall(5) = '0') then
				wb_wd 	<= (others => '0');
				wb_wdata<= (others => '0');
				wb_wreg <= '0';
				wb_whilo<= '0';
				wb_hi	<= (others => '0');
				wb_lo	<= (others => '0');	
			elsif(stall(4) = '0') then
				wb_wd 	<= mem_wd;
				wb_wdata<= mem_wdata;
				wb_wreg	<= mem_wreg;
				wb_whilo<= mem_whilo;
				wb_hi	<= mem_hi;
				wb_lo	<= mem_lo;	
			end if;
		end if;
	end process reg_prc;
end rtl;