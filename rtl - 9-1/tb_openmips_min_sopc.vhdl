library ieee;
use ieee.std_logic_1164.all;
use work.cpu_package.all;

entity tb_openmips_min_sopc is

end entity tb_openmips_min_sopc;

architecture dut of tb_openmips_min_sopc is
	signal clk		: std_ulogic := '0';
	signal rst		: std_ulogic;
	
	component openmips_min_sopc 
	port(
		clk		: in std_ulogic;
		rst		: in std_ulogic
	);
	end component openmips_min_sopc;
begin
	inst_dut : openmips_min_sopc
	port map(
		clk		=> clk,
		rst		=> rst
	);
	
	clk <= not clk after 50 ns;
	sim : process 
	begin
		rst <= '0';
		wait for 300 ns;
		rst <= '1';
		wait;
	end process sim;
	
end dut;