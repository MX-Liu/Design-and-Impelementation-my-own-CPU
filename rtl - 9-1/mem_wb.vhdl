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
		
		mem_whilo	: in std_ulogic;
		mem_hi		: in std_ulogic_vector(RegBus - 1 downto 0);
		mem_lo		: in std_ulogic_vector(RegBus - 1 downto 0);
		stall 		: in std_ulogic_vector(5 downto 0);
		
		wb_whilo	: out std_ulogic;
		wb_hi		: out std_ulogic_vector(RegBus - 1 downto 0);
		wb_lo		: out std_ulogic_vector(RegBus - 1 downto 0);
		
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