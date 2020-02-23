library ieee;
use ieee.std_logic_1164.all;
use work.cpu_package.all;

entity openmips_min_sopc is
	port(
		clk		: in std_ulogic;
		rst		: in std_ulogic
	);	
end entity openmips_min_sopc;

architecture rtl of openmips_min_sopc is

	signal inst_addr	: std_ulogic_vector(InstAddrBus - 1 downto 0);
	signal inst			: std_ulogic_vector(InstAddrBus - 1 downto 0);
	
	signal rom_ce		: std_ulogic;
	
	
	component openmips 
	port(
		clk			: in std_ulogic;
		rst			: in std_ulogic;
		
		rom_data_i	: in std_ulogic_vector(RegBus - 1 downto 0);
		rom_addr_o  : out std_ulogic_vector(RegBus - 1 downto 0);
		rom_ce_o 	: out std_ulogic
	);
	end component openmips;

	component inst_rom 
	port(
		ce 		: in std_ulogic;
		addr	: in std_ulogic_vector(InstAddrBus - 1 downto 0);
		
		inst	: out std_ulogic_vector(InstAddrBus - 1 downto 0)
	);
	end component inst_rom;

begin
	inst_openmips	: openmips
	port map(
		clk			=> clk,
		rst			=> rst,
		
		rom_data_i	=> inst,
		rom_addr_o  => inst_addr,
		rom_ce_o 	=> rom_ce
	);
	
	int_inst_rom	: inst_rom
	port map(
		ce 		=> rom_ce,
		addr	=> inst_addr,
		
		inst	=> inst
	);
end rtl;
