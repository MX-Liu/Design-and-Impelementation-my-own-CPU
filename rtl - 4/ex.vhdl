library ieee;
use ieee.std_logic_1164.all;
use work.cpu_package.all;

entity ex is
	port(
		rst			: in std_ulogic;
		
		aluop_i		: in std_ulogic_vector(AluOpBus - 1 downto 0);
		alusel_i	: in std_ulogic_vector(AluSelBus - 1 downto 0);
		
		reg1_i		: in std_ulogic_vector(RegBus - 1 downto 0); 	-- source operand 1 
		reg2_i		: in std_ulogic_vector(RegBus - 1 downto 0); 	-- source operand 2
		
		wd_i		: in std_ulogic_vector(RegAddrBus - 1 downto 0);	-- the address of the destination register that will be written.
		wreg_i		: in std_ulogic;									-- write enable signal	
		
		wd_o		: out std_ulogic_vector(RegAddrBus - 1 downto 0);
		wreg_o		: out std_ulogic;
		wdata_o		: out std_ulogic_vector(RegBus - 1 downto 0)
	);
end entity ex;

architecture rtl of ex is 

	signal logic_result 	: std_ulogic_vector(RegBus - 1 downto 0);
begin	
	comput_prc : process(rst,aluop_i,reg1_i,reg2_i)
	begin
		if(rst = '0') then
			logic_result <= (others => '0');
		else
			case aluop_i is 
				when EXE_OR_OP =>
					logic_result <= reg1_i or reg2_i;
				when others =>
					logic_result <= (others => '0');
			end case;
		end if;
	end process comput_prc;
	
	result_out : process(wd_i, wreg_i, alusel_i,logic_result)
	begin
		wd_o 	<= wd_i;
		wreg_o	<= wreg_i;
		
		case alusel_i is
			when EXE_RES_LOGIC =>
				wdata_o <= logic_result;
			when others =>
				wdata_o <= (others => '0');
		end case;
	end process result_out;
	
end rtl;
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	