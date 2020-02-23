library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu_package.all;

entity data_ram is
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
end entity data_ram;

architecture rtl of data_ram is
	type t_ram is array(0 to DataMemNum - 1) of std_ulogic_vector(ByteWidth - 1 downto 0);
	signal data_mem0	: t_ram;
	signal data_mem1	: t_ram;
	signal data_mem2	: t_ram;
	signal data_mem3	: t_ram;
	
begin
	-- write 
	write_prc : process(clk, rst)
	begin
		if (rst = '0') then
			data_mem0 <= (others => (others => '0'));
			data_mem1 <= (others => (others => '0'));
			data_mem2 <= (others => (others => '0'));
			data_mem3 <= (others => (others => '0'));
		elsif(rising_edge(clk)) then
			if (ce = '1' and we = '1') then
				if (sel(3) = '1') then
					data_mem3(to_integer(unsigned(addr(DataMemNumLog2 + 1 downto 2)))) <= data_i(31 downto 24);
				end if;
				if (sel(2) = '1') then
					data_mem2(to_integer(unsigned(addr(DataMemNumLog2 + 1 downto 2)))) <= data_i(23 downto 16);
				end if;
				if (sel(1) = '1') then
					data_mem1(to_integer(unsigned(addr(DataMemNumLog2 + 1 downto 2)))) <= data_i(15 downto 8);
				end if;
				if (sel(0) = '1') then
					data_mem0(to_integer(unsigned(addr(DataMemNumLog2 + 1 downto 2)))) <= data_i(7 downto 0);
				end if;
			end if;	
		end if;
	end process write_prc;
	
	-- read 
	read_prc : process(ce, we, data_mem0, data_mem1, data_mem2, data_mem3, rst,addr)
	begin
		if (rst = '0') then
			data_o <= (others => '0');
		elsif(ce = '0') then
			data_o <= (others => '0');
		elsif(ce = '1' and we = '0') then
			data_o <= 	data_mem3(to_integer(unsigned(addr(DataMemNumLog2 + 1 downto 2))))&
						data_mem2(to_integer(unsigned(addr(DataMemNumLog2 + 1 downto 2))))&
						data_mem1(to_integer(unsigned(addr(DataMemNumLog2 + 1 downto 2))))&
						data_mem0(to_integer(unsigned(addr(DataMemNumLog2 + 1 downto 2))));
		else
			data_o <= (others => '0');
		end if;
	end process read_prc;


end rtl;