library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu_package.all;

entity LLbit is
	port(
		rst		: in std_ulogic;
		clk		: in std_ulogic;
		flush	: in std_ulogic;
		we		: in std_ulogic;
		LLbit_i	: in std_ulogic;
		LLbit_o	: out std_ulogic
	);
end entity LLbit;

architecture rtl of LLbit is

begin

	ll : process(rst, clk)
	begin 
		if (rst = '0') then
			LLbit_o	<= '0';
		elsif (rising_edge(clk)) then
			if (flush = '1' ) then
				LLbit_o	<= '0';
			elsif (we = '1') then
				LLbit_o	<= LLbit_i;
			end if;
		end if;
	end process ll;
end rtl;