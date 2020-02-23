library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu_package.all;
use work.mips_application_image.all;

entity inst_rom is
	port(
		ce 		: in std_ulogic;
		addr	: in std_ulogic_vector(InstAddrBus - 1 downto 0);
		
		inst	: out std_ulogic_vector(InstAddrBus - 1 downto 0)
	);
end entity inst_rom;

architecture rtl of inst_rom is
	type inst_mem_t is array(0 to InstMemNum/2 - 1) of std_ulogic_vector(InstBus - 1 downto 0);
	
	impure function init_imem(init : application_init_image_t) return inst_mem_t is
		variable mem_v	: inst_mem_t;
	begin
		for i in 0 to InstMemNum/2 -1 loop
		
			mem_v(i) := init(i);
			 
		end loop; 
		return mem_v;
	end function init_imem;
	
	constant inst_mem	: inst_mem_t := init_imem(application_init_image);
begin
	read_prc : process(ce,addr)
	begin
		if(ce = '0') then
			inst <= (others => '0');
		elsif(ce = '1') then
			inst <= inst_mem(to_integer(unsigned(addr(InstAddrBus - 1 downto 2))));
		end if;
	end process read_prc;
end rtl;

















