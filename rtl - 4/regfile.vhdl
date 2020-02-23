library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu_package.all;

entity regfile is
	port(
		rst		: in std_ulogic;
		clk		: in std_ulogic;
		
		we		: in std_ulogic;
		waddr	: in std_ulogic_vector(RegAddrBus - 1 downto 0);
		wdata	: in std_ulogic_vector(RegBus - 1 downto 0);
		
		re1		: in std_ulogic;
		raddr1	: in std_ulogic_vector(RegAddrBus - 1 downto 0);
		rdata1	: out std_ulogic_vector(RegBus - 1 downto 0);
		
		re2		: in std_ulogic;
		raddr2	: in std_ulogic_vector(RegAddrBus - 1 downto 0);
		rdata2	: out std_ulogic_vector(RegBus - 1 downto 0)
		
	);
end entity regfile;

architecture rtl of regfile is

	type reg_t is array (0 to RegNum - 1) of std_ulogic_vector(RegBus - 1 downto 0);
	signal regs 		: reg_t;
	
begin

	write_prc : process(clk)
	begin
		if(rising_edge(clk)) then
			if(we = '1' and waddr /= b"00000") then
				regs(to_integer(unsigned(waddr))) <= wdata;
			end if;
		end if;
	end process write_prc;
	
	read_1_comb : process(raddr1, waddr, we, wdata, regs, re1)
	begin
		
		if(raddr1 = b"00000") then 
			rdata1	<= (others => '0');
		elsif(raddr1 = waddr and we = '1' and re1 = '1') then
			rdata1	<= wdata;
		elsif(re1 = '1') then
			rdata1 <= regs(to_integer(unsigned(raddr1)));
		else
			rdata1	<= (others => '0');
		end if;
	end process read_1_comb;
	
	read_2_comb : process(raddr2, waddr, we, wdata, regs, re2)
	begin
		if(raddr2 = b"00000") then 
			rdata2	<= (others => '0');
		elsif(raddr2 = waddr and we = '1' and re2 = '1') then
			rdata2	<= wdata;
		elsif(re2 = '1') then
			rdata2 <= regs(to_integer(unsigned(raddr2)));
		else
			rdata2	<= (others => '0');
		end if;
	end process read_2_comb;
	
end rtl;
	
	
	
	