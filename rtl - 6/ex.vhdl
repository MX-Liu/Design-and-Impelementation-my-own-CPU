library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
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
		
		hi_i		: in std_ulogic_vector(RegBus - 1 downto 0);
		lo_i		: in std_ulogic_vector(RegBus - 1 downto 0);
		
		mem_whilo_i	: in std_ulogic;
		mem_hi_i	: in std_ulogic_vector(RegBus - 1 downto 0);
		mem_lo_i	: in std_ulogic_vector(RegBus - 1 downto 0);
		
		wb_whilo_i	: in std_ulogic;
		wb_hi_i		: in std_ulogic_vector(RegBus - 1 downto 0);
		wb_lo_i		: in std_ulogic_vector(RegBus - 1 downto 0);
		
		whilo_o		: out std_ulogic;
		hi_o		: out std_ulogic_vector(RegBus - 1 downto 0);
		lo_o		: out std_ulogic_vector(RegBus - 1 downto 0);
		
		wd_o		: out std_ulogic_vector(RegAddrBus - 1 downto 0);
		wreg_o		: out std_ulogic;
		wdata_o		: out std_ulogic_vector(RegBus - 1 downto 0)
	);
end entity ex;

architecture rtl of ex is 

	signal logic_result 	: std_ulogic_vector(RegBus - 1 downto 0);
	signal shift_result 	: std_ulogic_vector(RegBus - 1 downto 0);
	signal shift_offset 	: std_ulogic_vector(RegBus - 1 downto 0);
	
	signal move_result 		: std_ulogic_vector(RegBus - 1 downto 0);
	signal hi 				: std_ulogic_vector(RegBus - 1 downto 0);
	signal lo 				: std_ulogic_vector(RegBus - 1 downto 0);
begin
	update_hilo : process(rst,mem_whilo_i,mem_hi_i,mem_lo_i,wb_hi_i, wb_lo_i,hi_i,lo_i)
	begin
		if(rst = '0') then 
			hi <= (others => '0');
			lo <= (others => '0');
		elsif(mem_whilo_i = '1') then
			hi <= mem_hi_i;
			lo <= mem_lo_i;
		elsif(wb_whilo_i = '1') then 
			hi <= wb_hi_i;
			lo <= wb_lo_i;
		else
			hi <= hi_i;
			lo <= lo_i;
		end if;
	end process update_hilo;
	
	move1_compute : process(rst,aluop_i,hi,lo,reg1_i)
	begin
		if(rst = '0') then
			move_result <= (others => '0');
		else
			move_result <= (others => '0');
			case aluop_i is 
				when EXE_MFHI_OP =>
					move_result <= hi;
				when EXE_MFLO_OP =>
					move_result <= lo;
				when EXE_MOVZ_OP =>
					move_result <= reg1_i;
				when EXE_MOVN_OP =>
					move_result <= reg1_i;
				when others =>
					null;
			end case;
		end if;
	end process move1_compute;
	
	move2_compute : process(rst,aluop_i,reg1_i,lo,hi)
	begin
		if(rst = '0') then
			whilo_o <= '0';
			hi_o <= (others => '0');
			lo_o <= (others => '0');
		elsif(aluop_i = EXE_MTHI_OP) then
			whilo_o <= '1';
			hi_o <= reg1_i;
			lo_o <= lo;
		elsif(aluop_i = EXE_MTLO_OP) then
			whilo_o <= '1';
			hi_o <= hi;
			lo_o <= reg1_i;
		else
			whilo_o <= '0';
			hi_o <= (others => '0');
			lo_o <= (others => '0');
		end if;
	end process move2_compute;
	
	logic_compute : process(rst,aluop_i,reg1_i,reg2_i)
	begin
		if(rst = '0') then
			logic_result <= (others => '0');
		else
			case aluop_i is 
				when EXE_OR_OP =>
					logic_result <= reg1_i or reg2_i;
				when EXE_AND_OP =>
					logic_result <= reg1_i and reg2_i;
				when EXE_NOR_OP =>
					logic_result <= not(reg1_i or reg2_i);
					
				when EXE_XOR_OP =>
					logic_result <= reg1_i xor reg2_i;
					
				when others =>
					logic_result <= (others => '0');
			end case;
		end if;
	end process logic_compute;
	
	shift_compute : process(rst,aluop_i,reg1_i,reg2_i,shift_offset)
	begin
		if(rst = '0') then
			shift_result <= (others => '0');
		else
			shift_offset <= (others => reg2_i(31));
			--shift_offset <= (others => '1');
			case aluop_i is 
				when EXE_SLL_OP =>
					shift_result <= reg2_i sll (to_integer(unsigned(reg1_i(4 downto 0))));
				when EXE_SRL_OP =>
					shift_result <= reg2_i srl (to_integer(unsigned(reg1_i(4 downto 0))));
				when EXE_SRA_OP =>
					shift_result <= (reg2_i srl (to_integer(unsigned(reg1_i(4 downto 0))))) or
									(shift_offset sll (32 - to_integer(unsigned(reg1_i(4 downto 0)))));
				when others =>
					shift_result <= (others => '0');
			end case;
		end if;
	end process shift_compute;
	
	result_out : process(wd_i, wreg_i, alusel_i,logic_result,shift_result,move_result)
	begin
		wd_o 	<= wd_i;
		wreg_o	<= wreg_i;
		
		case alusel_i is
			when EXE_RES_LOGIC =>
				wdata_o <= logic_result;
			when EXE_RES_SHIFT =>
				wdata_o <= shift_result;
			when EXE_RES_MOVE =>
				wdata_o <= move_result;
			when others =>
				wdata_o <= (others => '0');
		end case;
	end process result_out;
	
	
	
end rtl;
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	