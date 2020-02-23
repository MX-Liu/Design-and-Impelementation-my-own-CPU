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
	
	signal ram_data_i	: std_ulogic_vector(RegBus - 1 downto 0);
	signal ram_addr_o	: std_ulogic_vector(RegBus - 1 downto 0);
	signal ram_we_o		: std_ulogic;
	signal ram_sel_o	: std_ulogic_vector(3 downto 0);
	signal ram_data_o	: std_ulogic_vector(RegBus - 1 downto 0);
	signal ram_ce_o		: std_ulogic;
	
	
	component openmips 
	port(
		clk			: in std_ulogic;
		rst			: in std_ulogic;
		
		rom_data_i	: in std_ulogic_vector(RegBus - 1 downto 0);
		rom_addr_o  : out std_ulogic_vector(RegBus - 1 downto 0);
		rom_ce_o 	: out std_ulogic;
		
		ram_data_i	: in std_ulogic_vector(RegBus - 1 downto 0);
		ram_addr_o	: out std_ulogic_vector(RegBus - 1 downto 0);
		ram_we_o	: out std_ulogic;
		ram_sel_o	: out std_ulogic_vector(3 downto 0);
		ram_data_o	: out std_ulogic_vector(RegBus - 1 downto 0);
		ram_ce_o	: out std_ulogic
	);
	end component openmips;

	component inst_rom 
	port(
		ce 		: in std_ulogic;
		addr	: in std_ulogic_vector(InstAddrBus - 1 downto 0);
		
		inst	: out std_ulogic_vector(InstAddrBus - 1 downto 0)
	);
	end component inst_rom;
	
	component data_ram 
	port(
		clk		: in std_ulogic;
		rst		: in std_ulogic;
		ce		: in std_ulogic;
		we		: in std_ulogic;
		addr	: in std_ulogic_vector(DataAddrBus - 1 downto 0);
		sel		: in std_ulogic_vector(3 downto 0);
		data_i	: in std_ulogic_vector(DataBus - 1 downto 0);
		data_o	: out std_ulogic_vector(DataBus - 1 downto 0)
	);
	end component data_ram;

begin
	inst_openmips	: openmips
	port map(
		clk			=> clk,
		rst			=> rst,
		
		rom_data_i	=> inst,
		rom_addr_o  => inst_addr,
		rom_ce_o 	=> rom_ce,
		
		ram_data_i  => ram_data_i,		
		ram_addr_o	=> ram_addr_o,	
		ram_we_o	=> ram_we_o,	
		ram_sel_o	=> ram_sel_o,	
		ram_data_o	=> ram_data_o,	
		ram_ce_o	=> ram_ce_o
	);
	
	int_inst_rom	: inst_rom
	port map(
		ce 		=> rom_ce,
		addr	=> inst_addr,
		
		inst	=> inst
	);
	
	inst_ram : data_ram
	port map(
		clk		=> clk,
		rst		=> rst,
		ce		=> ram_ce_o, 
		we		=> ram_we_o,
		addr	=> ram_addr_o,
		sel		=> ram_sel_o,
		data_i	=> ram_data_o,
		data_o	=> ram_data_i
	);
end rtl;
