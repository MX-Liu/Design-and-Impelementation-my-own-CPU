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
		wdata_o		: out std_ulogic_vector(RegBus - 1 downto 0);
		
		aluop_i		: in std_ulogic_vector(AluOpBus - 1 downto 0);
		mem_addr_i	: in std_ulogic_vector(RegBus - 1 downto 0);
		reg2_i		: in std_ulogic_vector(RegBus - 1 downto 0);
		
		-- ram interface
		mem_data_i	: in std_ulogic_vector(RegBus - 1 downto 0);
		mem_addr_o	: out std_ulogic_vector(RegBus - 1 downto 0);
		mem_we_o	: out std_ulogic;
		mem_sel_o	: out std_ulogic_vector(3 downto 0);
		mem_data_o	: out std_ulogic_vector(RegBus - 1 downto 0);
		mem_ce_o	: out std_ulogic;
		
		
		
	);
end entity mem;

architecture rtl of mem is
	signal mem_we 			: std_ulogic;
	signal mem_data_offset31	: std_ulogic_vector(23 downto 0);
	signal mem_data_offset23	: std_ulogic_vector(23 downto 0);
	signal mem_data_offset15	: std_ulogic_vector(23 downto 0);
	signal mem_data_offset7	: std_ulogic_vector(23 downto 0);
	
begin
	mem_we_o			<= mem_we;
	mem_data_offset31	<= (others => mem_data_i(31));
	mem_data_offset23	<= (others => mem_data_i(23));
	mem_data_offset15	<= (others => mem_data_i(15));
	mem_data_offset7	<= (others => mem_data_i(7));
	comb_prc : process(rst, wd_i, wreg_i, wdata_i,whilo_i,hi_i,lo_i,aluop_i,mem_addr_i,
					mem_data_offset31, mem_data_offset23, mem_data_offset15, mem_data_offset7,
					mem_data_i, reg2_i)
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
			mem_we <= '0';
			mem_addr_o <= (others => '0');
			mem_sel_o  <= "1111";
			mem_ce_o   <= '0';			
			case aluop_i is
				when EXE_LB_OP =>
					mem_addr_o 	<= mem_addr_i;
					mem_we	   	<= '0';
					mem_ce_o   	<= '1';
					case mem_addr_i(1 downto 0) is
						when "00" => 
							wdata_o 	<= mem_data_offset31 & mem_data_i(31 downto 24);
							mem_sel_o	<= "1000";
						when "01" => 
							wdata_o 	<= mem_data_offset23 & mem_data_i(23 downto 16);
							mem_sel_o	<= "0100";
						when "10" => 
							wdata_o 	<= mem_data_offset15 & mem_data_i(15 downto 8);
							mem_sel_o	<= "0010";
						when "11" => 
							wdata_o 	<= mem_data_offset7 & mem_data_i(7 downto 0);
							mem_sel_o	<= "0001";
						when others =>
							wdata_o <= (others => '0');
					end case;
				when EXE_LBU_OP =>
					mem_addr_o 	<= mem_addr_i;
					mem_we	   	<= '0';
					mem_ce_o   	<= '1';
					case mem_addr_i(1 downto 0) is
						when "00" => 
							wdata_o 	<= X"000000" & mem_data_i(31 downto 24);
							mem_sel_o	<= "1000";
						when "01" => 
							wdata_o 	<= X"000000" & mem_data_i(23 downto 16);
							mem_sel_o	<= "0100";
						when "10" => 
							wdata_o 	<= X"000000" & mem_data_i(15 downto 8);
							mem_sel_o	<= "0010";
						when "11" => 
							wdata_o 	<= X"000000" & mem_data_i(7 downto 0);
							mem_sel_o	<= "0001";
						when others =>
							wdata_o <= (others => '0');
					end case;
				when EXE_LH_OP =>
					mem_addr_o 	<= mem_addr_i;
					mem_we	   	<= '0';
					mem_ce_o   	<= '1';
					case mem_addr_i(1 downto 0) is
						when "00" =>
							if(mem_data_i(31) = '1') then
								wdata_o 	<= X"FFFF" & mem_data_i(31 downto 16);
							else
								wdata_o 	<= X"0000" & mem_data_i(31 downto 16);
							end if;
							mem_sel_o	<= "1100";
						when "10" => 
							if(mem_data_i(15) = '1') then
								wdata_o 	<= X"FFFF" & mem_data_i(15 downto 0);
							else
								wdata_o 	<= X"0000" & mem_data_i(15 downto 0);
							end if;
							mem_sel_o	<= "0011";
						when others =>
							wdata_o <= (others => '0');
					end case;
				
				when EXE_LHU_OP =>
					mem_addr_o 	<= mem_addr_i;
					mem_we	   	<= '0';
					mem_ce_o   	<= '1';
					case mem_addr_i(1 downto 0) is
						when "00" =>
							wdata_o 	<= X"0000" & mem_data_i(31 downto 16);						
							mem_sel_o	<= "1100";
						when "10" => 
							wdata_o 	<= X"0000" & mem_data_i(15 downto 0);
							mem_sel_o	<= "0011";
						when others =>
							wdata_o <= (others => '0');
					end case;
				when EXE_LW_OP =>
					mem_addr_o 	<= mem_addr_i;
					wdata_o		<= mem_data_i;
					mem_we		<= '0';
					mem_sel_o	<= "1111";
					mem_ce_o	<= '1';
				when EXE_LWL_OP =>
					mem_addr_o 	<= mem_addr_i(31 downto 2)&"00";
					mem_we		<=  '0';
					mem_sel_o	<= "1111";
					mem_ce_o	<= '1';
					case mem_addr_i(1 downto 0) is
						when "00" =>
							wdata_o	<= mem_data_i(31 downto 0);
						when "01" =>
							wdata_o <= mem_data_i(23 downto 0)&reg2_i(7 downto 0);
						when "10" =>
							wdata_o <= mem_data_i(15 downto 0)&reg2_i(15 downto 0);
						when "11" =>
							wdata_o <= mem_data_i(7 downto 0)&reg2_i(23 downto 0);
						when others =>
							wdata_o <= (others => '0');
					end case;
				when EXE_LWR_OP =>
					mem_addr_o 	<= mem_addr_i(31 downto 2)&"00";
					mem_we		<=  '0';
					mem_sel_o	<= "1111";
					mem_ce_o	<= '1';
					case mem_addr_i(1 downto 0) is
						when "00" =>
							wdata_o	<= reg2_i(31 downto 8)&mem_data_i(31 downto 24);
						when "01" =>
							wdata_o <= reg2_i(31 downto 16)&mem_data_i(31 downto 16);
						when "10" =>
							wdata_o <= reg2_i(31 downto 24)&mem_data_i(31 downto 8);
						when "11" =>
							wdata_o <= mem_data_i(31 downto 0);
						when others =>
							wdata_o <= (others => '0');
					end case;
				when EXE_SB_OP =>
					mem_addr_o 	<= mem_addr_i;
					mem_we		<= '1';
					mem_data_o	<= reg2_i(7 downto 0)&reg2_i(7 downto 0)&reg2_i(7 downto 0)&reg2_i(7 downto 0);
					mem_ce_o	<= '1';
					case mem_addr_i(1 downto 0) is
						when "00" => 
							mem_sel_o	<= "1000";
						when "01" => 
							mem_sel_o	<= "0100";
						when "10" => 
							mem_sel_o	<= "0010";
						when "11" => 
							mem_sel_o	<= "0001";
						when others =>
							mem_sel_o	<= "0000";
					end case;
				when EXE_SH_OP =>
					mem_addr_o 	<= mem_addr_i;
					mem_we		<= '1';
					mem_data_o	<= reg2_i(15 downto 0)&reg2_i(15 downto 0);
					mem_ce_o	<= '1';
					case mem_addr_i(1 downto 0) is
						when "00" => 
							mem_sel_o	<= "1100";
						when "10" => 
							mem_sel_o	<= "0011";
						when others =>
							mem_sel_o	<= "0000";
					end case;
				when EXE_SW_OP =>
					mem_addr_o 	<= mem_addr_i;
					mem_we		<= '1';
					mem_data_o	<= reg2_i;
					mem_ce_o	<= '1';
					mem_sel_o	<= "1111";
				when EXE_SWL_OP =>
					mem_addr_o 	<= mem_addr_i(31 downto 2) & "00";
					mem_we		<= '1';
					mem_ce_o	<= '1';
					case mem_addr_i(1 downto 0) is
						when "00" => 
							mem_sel_o	<= "1111";
							mem_data_o	<= reg2_i;
						when "01" => 
							mem_sel_o	<= "0111";
							mem_data_o	<= x"00" & reg2_i(31 downto 8);
						when "10" => 
							mem_sel_o	<= "0011";
							mem_data_o	<= x"0000" & reg2_i(31 downto 16);
						when "11" => 
							mem_sel_o	<= "0001";
							mem_data_o	<= x"000000" & reg2_i(31 downto 24);
						when others =>
							mem_sel_o	<= "0000";
					end case;
				when EXE_SWR_OP =>
					mem_addr_o 	<= mem_addr_i(31 downto 2) & "00";
					mem_we		<= '1';
					mem_ce_o	<= '1';
					case mem_addr_i(1 downto 0) is
						when "00" => 
							mem_sel_o	<= "1000";
							mem_data_o	<= reg2_i(7 downto 0) & x"000000";
						when "01" => 
							mem_sel_o	<= "1100";
							mem_data_o	<= reg2_i(15 downto 0) & x"0000";
						when "10" => 
							mem_sel_o	<= "1110";
							mem_data_o	<= reg2_i(23 downto 0) & x"00";
						when "11" => 
							mem_sel_o	<= "1111";
							mem_data_o	<= reg2_i;
						when others =>
							mem_sel_o	<= "0000";
					end case;
				when others =>
					null;
			end case;
							
		end if;
	end process comb_prc;
end rtl;
