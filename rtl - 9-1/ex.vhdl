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
		
		-- this auxiliary input signals are used for division
		div_result_i : in std_ulogic_vector(63 downto 0);
		div_ready_i	 : in std_ulogic;
		
		hilo_temp_i	: in std_ulogic_vector(2*RegBus - 1 downto 0); -- for madd/sub to store the temporary result
		cnt_i		: in std_ulogic_vector(1 downto 0);
		
		hilo_temp_o	: out std_ulogic_vector(2*RegBus - 1 downto 0); -- for madd/sub to store the temporary result
		cnt_o		: out std_ulogic_vector(1 downto 0);
		
		stallreq	: out std_ulogic;
		
		whilo_o		: out std_ulogic;
		hi_o		: out std_ulogic_vector(RegBus - 1 downto 0);
		lo_o		: out std_ulogic_vector(RegBus - 1 downto 0);
		
		wd_o		: out std_ulogic_vector(RegAddrBus - 1 downto 0);
		wreg_o		: out std_ulogic;
		wdata_o		: out std_ulogic_vector(RegBus - 1 downto 0);
		
		-- this auxiliary output signals are used for division 
		signed_div_o : out std_ulogic;
		div_opdata1_o: out std_ulogic_vector(31 downto 0); -- dividend
		div_opdata2_o: out std_ulogic_vector(31 downto 0); -- divisor
		div_start_o	 : out std_ulogic;
		
		is_in_delay_slot_i	: in std_ulogic;
		link_address_i		: in std_ulogic_vector(RegBus - 1 downto 0);
		
		inst_i				: in std_ulogic_vector(RegBus - 1 downto 0);
		aluop_o				: out std_ulogic_vector(AluOpBus - 1 downto 0);
		mem_addr_o			: out std_ulogic_vector(RegBus - 1 downto 0);
		reg2_o				: out std_ulogic_vector(RegBus - 1 downto 0)
		
	);
end entity ex;

architecture rtl of ex is 

	signal logic_result 	: std_ulogic_vector(RegBus - 1 downto 0);
	signal shift_result 	: std_ulogic_vector(RegBus - 1 downto 0);
	signal shift_offset 	: std_ulogic_vector(RegBus - 1 downto 0);
	
	signal move_result 		: std_ulogic_vector(RegBus - 1 downto 0);
	signal hi 				: std_ulogic_vector(RegBus - 1 downto 0);
	signal lo 				: std_ulogic_vector(RegBus - 1 downto 0);
	
	signal ov_sum			: std_ulogic;
	signal reg1_eq_reg2		: std_ulogic; -- = 1 when reg1 = reg2
	signal reg1_lt_reg2		: std_ulogic; -- = 1 when reg1 <= reg2
	signal arith_result 	: std_ulogic_vector(RegBus - 1 downto 0);
	signal reg2_i_mux	 	: std_ulogic_vector(RegBus - 1 downto 0);
	signal reg1_i_not	 	: std_ulogic_vector(RegBus - 1 downto 0);
	signal sum_result		: std_ulogic_vector(RegBus - 1 downto 0);
	signal opdata1_mult		: std_ulogic_vector(RegBus - 1 downto 0);
	signal opdata2_mult 	: std_ulogic_vector(RegBus - 1 downto 0);
	signal hilo_temp		: std_ulogic_vector(2*RegBus - 1 downto 0);
	signal mul_result		: std_ulogic_vector(2*RegBus - 1 downto 0);
	
	signal hilo_temp1		: std_ulogic_vector(2*RegBus - 1 downto 0);
	signal stallreq_for_madd_msub	: std_ulogic;
	signal stallreg_for_div			: std_ulogic;
	signal mem_addr_offset			: std_ulogic_vector(15 downto 0);
	
begin
	
	-- this signal is used for load and store instruction
	aluop_o			<= aluop_i;
	reg2_o			<= reg2_i;
	mem_addr_offset <= (others => inst_i(15));
	mem_addr_o		<= mem_addr_offset & inst_i(15 downto 0);
	
	-- if there is subration, the 2nd operand is complement
	reg2_i_mux <= complement(reg2_i) when ((aluop_i = EXE_SUB_OP) or (aluop_i = EXE_SUBU_OP) or (aluop_i = EXE_SLT_OP)) 
				  else reg2_i;
	sum_result <= std_ulogic_vector(unsigned(reg1_i) + unsigned(reg2_i_mux));
	
	-- is there overflow, there are two case:
	-- operand1 and operand2 are positive, but the sum of them is negative;
	-- operand1 and operand2 are negative, but the sum of them is positive;
	ov_sum <= (((not reg1_i(31)) and (not reg2_i_mux(31)) and      sum_result(31)) or 
	          ((     reg1_i(31)) and (    reg2_i_mux(31)) and (not sum_result(31))));
	
	-- compute operand1 < operand2 
	-- if aluop_i is EXE_SLT_OP, it is sigend compere
		-- if reg1_i is negative, reg2_i is positive, reg1_i < reg2_i
		-- if reg1_i is positive, reg2_i is positive, reg1_i - reg2_i < 0
		-- if reg1_i is negative, reg2_i is negative, reg1_i - reg2_i < 0
	
	reg1_lt_reg2 <= (reg1_i(31) and not(reg2_i(31))) or 
					(not(reg1_i(31)) and not(reg2_i(31) and sum_result(31))) or 
					(   (reg1_i(31)) and    (reg2_i(31) and sum_result(31)))
					when aluop_i = EXE_SLT_OP else '1' when (reg1_i < reg2_i) else '0';

	reg1_i_not <= not reg1_i;
	
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
	
	arith_compute : process(rst,aluop_i,reg1_lt_reg2,sum_result,reg1_i,reg1_i_not)
	begin
		if(rst = '0') then
			arith_result <= (others => '0');
		else
			case aluop_i is 
				when EXE_SLT_OP | EXE_SLTU_OP =>
					arith_result(0) <= reg1_lt_reg2;
				when EXE_ADD_OP | EXE_ADDU_OP | EXE_ADDI_OP | EXE_ADDIU_OP =>
					arith_result <= sum_result;
				when EXE_SUBU_OP | EXE_SUB_OP =>
					arith_result <= sum_result;
				when EXE_CLZ_OP =>
					arith_result <= X"00000000" when reg1_i(31) else x"00000001" when reg1_i(30) else x"00000002"
									  when reg1_i(29) else x"00000003" when reg1_i(28) else x"00000004"
									  when reg1_i(27) else x"00000005" when reg1_i(26) else x"00000006"
									  when reg1_i(25) else x"00000007" when reg1_i(24) else x"00000008"
									  when reg1_i(23) else x"00000009" when reg1_i(22) else x"0000000A"
									  when reg1_i(21) else x"0000000B" when reg1_i(20) else x"0000000C"
									  when reg1_i(19) else x"0000000D" when reg1_i(18) else x"0000000E"
									  when reg1_i(17) else x"0000000F" when reg1_i(16) else x"00000010"
									  when reg1_i(15) else x"00000011" when reg1_i(14) else x"00000012"
									  when reg1_i(13) else x"00000013" when reg1_i(12) else x"00000014"
									  when reg1_i(11) else x"00000015" when reg1_i(10) else x"00000016"
									  when reg1_i(09) else x"00000017" when reg1_i(08) else x"00000018"
									  when reg1_i(07) else x"00000019" when reg1_i(06) else x"0000001A"
									  when reg1_i(05) else x"0000001B" when reg1_i(04) else x"0000001C"
									  when reg1_i(03) else x"0000001D" when reg1_i(02) else x"0000001E"
									  when reg1_i(01) else x"0000001F" when reg1_i(00) else x"00000020";
				when EXE_CLO_OP =>
					arith_result <= X"00000000" when reg1_i_not(31) else x"00000001" when reg1_i_not(30) else x"00000002"
									  when reg1_i_not(29) else x"00000003" when reg1_i_not(28) else x"00000004"
									  when reg1_i_not(27) else x"00000005" when reg1_i_not(26) else x"00000006"
									  when reg1_i_not(25) else x"00000007" when reg1_i_not(24) else x"00000008"
									  when reg1_i_not(23) else x"00000009" when reg1_i_not(22) else x"0000000A"
									  when reg1_i_not(21) else x"0000000B" when reg1_i_not(20) else x"0000000C"
									  when reg1_i_not(19) else x"0000000D" when reg1_i_not(18) else x"0000000E"
									  when reg1_i_not(17) else x"0000000F" when reg1_i_not(16) else x"00000010"
									  when reg1_i_not(15) else x"00000011" when reg1_i_not(14) else x"00000012"
									  when reg1_i_not(13) else x"00000013" when reg1_i_not(12) else x"00000014"
									  when reg1_i_not(11) else x"00000015" when reg1_i_not(10) else x"00000016"
									  when reg1_i_not(09) else x"00000017" when reg1_i_not(08) else x"00000018"
									  when reg1_i_not(07) else x"00000019" when reg1_i_not(06) else x"0000001A"
									  when reg1_i_not(05) else x"0000001B" when reg1_i_not(04) else x"0000001C"
									  when reg1_i_not(03) else x"0000001D" when reg1_i_not(02) else x"0000001E"
									  when reg1_i_not(01) else x"0000001F" when reg1_i_not(00) else x"00000020";
									  
									  
				when others =>
					arith_result <= (others => '0');
			end case;
		end if;
	end process arith_compute;
	
	---------------------------------------------------------------------
	-- division ---------------------------------------------------------
	---------------------------------------------------------------------
	div_prc : process(rst,aluop_i,reg1_i,reg2_i,div_ready_i)
	begin
		if(rst = '0') then
			stallreg_for_div 	<= '0';
			div_opdata1_o 		<= (others => '0');
			div_opdata2_o 		<= (others => '0');
			div_start_o			<= '0';
			signed_div_o		<= '0';
		else
			stallreg_for_div <= '0';
			div_opdata1_o 		<= (others => '0');
			div_opdata2_o 		<= (others => '0');
			div_start_o			<= '0';
			signed_div_o		<= '0';
			case aluop_i is 
				when EXE_DIV_OP =>
					if(div_ready_i = '0') then
						stallreg_for_div <= '1';
						div_opdata1_o 		<= reg1_i;
						div_opdata2_o 		<= reg2_i;
						div_start_o			<= '1';
						signed_div_o		<= '1';
					elsif(div_ready_i = '1') then
						stallreg_for_div <= '0';
						div_opdata1_o 		<= reg1_i;
						div_opdata2_o 		<= reg2_i;
						div_start_o			<= '0';
						signed_div_o		<= '0';
					else
						stallreg_for_div <= '0';
						div_opdata1_o 		<= (others => '0');
						div_opdata2_o 		<= (others => '0');
						div_start_o			<= '0';
						signed_div_o		<= '0';
					end if;
				
				when EXE_DIVU_OP =>
					if(div_ready_i = '0') then
						stallreg_for_div <= '1';
						div_opdata1_o 		<= reg1_i;
						div_opdata2_o 		<= reg2_i;
						div_start_o			<= '1';
						signed_div_o		<= '0';
					elsif(div_ready_i = '1') then
						stallreg_for_div <= '0';
						div_opdata1_o 		<= reg1_i;
						div_opdata2_o 		<= reg2_i;
						div_start_o			<= '0';
						signed_div_o		<= '0';
					else
						stallreg_for_div <= '0';
						div_opdata1_o 		<= (others => '0');
						div_opdata2_o 		<= (others => '0');
						div_start_o			<= '0';
						signed_div_o		<= '0';
					end if;
					
				when others => 
					null;
				
			end case;
		
		end if;
	end process div_prc;
	---------------------------------------------------------------------
	-- multiplication----------------------------------------------------
	---------------------------------------------------------------------
	
	---------------------------------------------------------------------
	-- preprocess the multiplicand and multiplicator according the signed
	---------------------------------------------------------------------
	opdata_prc : process(aluop_i,reg1_i,reg2_i)
	begin
		if((aluop_i = EXE_MUL_OP) or (aluop_i = EXE_MULT_OP) or (aluop_i = EXE_MADD_OP) or (aluop_i = EXE_MSUB_OP)) then 
			if(reg1_i(31) = '1') then 
				opdata1_mult <= complement(reg1_i);
			else
				opdata1_mult <= reg1_i;
			end if;
			
			if(reg2_i(31) = '1') then 
				opdata2_mult <= complement(reg2_i);
			else
				opdata2_mult <= reg2_i;
			end if;
		else
			opdata1_mult <= reg1_i;
			opdata2_mult <= reg2_i;
		end if;
	end process opdata_prc;
	
	
	------------------------------------------------------------------------------------------
	-- compute the temporary multiplication result
	------------------------------------------------------------------------------------------
	hilo_temp <= std_ulogic_vector(unsigned(opdata1_mult) * unsigned(opdata2_mult));
	
	-------------------------------------------------------------------------------------------
	-- write the temporary result of multiplication into mul_result
	-------------------------------------------------------------------------------------------
	mul_result_updata : process(rst, aluop_i,reg1_i,reg2_i,hilo_temp)
	begin
		if(rst = '0') then
			mul_result <= (others => '0');
		elsif((aluop_i = EXE_MULT_OP) or (aluop_i = EXE_MUL_OP) or (aluop_i = EXE_MADD_OP) or (aluop_i = EXE_MSUB_OP)) then
			if(reg1_i(31) /= reg2_i(31))then
				mul_result <= std_ulogic_vector(unsigned(not hilo_temp) + 1);
			else
				mul_result <= hilo_temp;
			end if;
		else
			mul_result <= hilo_temp;
		end if;
	end process mul_result_updata;
	
	-------------------------------------------------------------------------------
	-- compute the madd/u  and msub/u
	--------------------------------------------------------------------------------
	madd_sub_prc : process(rst,aluop_i,cnt_i,mul_result,hilo_temp_i,hi,lo)
	begin
		if(rst = '0') then
			hilo_temp_o 			<= (others => '0');
			cnt_o					<= (others => '0');
			stallreq_for_madd_msub	<= '0';
		else
			case aluop_i is 
				when EXE_MADD_OP | EXE_MADDU_OP =>
					if(cnt_i = b"00") then
						hilo_temp_o <= mul_result;
						cnt_o 		<= b"01";
						hilo_temp1	<= (others => '0');
						stallreq_for_madd_msub	<= '1';
					elsif(cnt_i = b"01") then
						hilo_temp_o <= (others => '0');
						cnt_o		<= b"10";
						hilo_temp1	<= std_ulogic_vector(signed(hilo_temp_i) + signed(hi&lo));
						stallreq_for_madd_msub <= '0';
					end if;
				when EXE_MSUB_OP | EXE_MSUBU_OP =>
					if(cnt_i = b"00") then
						hilo_temp_o <= std_ulogic_vector( signed(not mul_result) + 1);
						cnt_o 		<= b"01";
						hilo_temp1	<= (others => '0');
						stallreq_for_madd_msub	<= '1';
					elsif(cnt_i = b"01") then
						hilo_temp_o <= (others => '0');
						cnt_o		<= b"10";
						hilo_temp1	<= std_ulogic_vector(signed(hilo_temp_i) + signed(hi&lo));
						stallreq_for_madd_msub <= '0';
					end if;
					
				when others =>
					hilo_temp_o	<= (others => '0');
					cnt_o		<= (others => '0');
					stallreq_for_madd_msub	<= '0';
			end case;
		end if;
	end process madd_sub_prc;
	
	-- stop the pipline
	stallreq <= stallreq_for_madd_msub or stallreg_for_div;
	
	
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
	
	hilo_compute : process(rst,aluop_i,reg1_i,lo,hi,mul_result,hilo_temp1, div_result_i)
	begin
		if(rst = '0') then
			whilo_o <= '0';
			hi_o <= (others => '0');
			lo_o <= (others => '0');
		elsif(aluop_i = EXE_MSUBU_OP OR aluop_i = EXE_MSUB_OP) then
			whilo_o <= '1';
			hi_o <= hilo_temp1(63 downto 32);
			lo_o <= hilo_temp1(31 downto 0);
		elsif(aluop_i = EXE_MADDU_OP OR aluop_i = EXE_MADD_OP) then
			whilo_o <= '1';
			hi_o <= hilo_temp1(63 downto 32);
			lo_o <= hilo_temp1(31 downto 0);
		elsif(aluop_i = EXE_MTHI_OP) then
			whilo_o <= '1';
			hi_o <= reg1_i;
			lo_o <= lo;
		elsif(aluop_i = EXE_MTLO_OP) then
			whilo_o <= '1';
			hi_o <= hi;
			lo_o <= reg1_i;
		elsif((aluop_i = EXE_MULT_OP) OR (aluop_i = EXE_MULTU_OP)) then
			whilo_o <= '1';
			hi_o <= mul_result(63 downto 32);
			lo_o <= mul_result(31 downto 0);
		elsif(aluop_i = EXE_MTHI_OP) then
			whilo_o <= '1';
			hi_o <= reg1_i;
			lo_o <= lo;
		elsif(aluop_i = EXE_MTLO_OP) then
			whilo_o <= '1';
			hi_o <= hi;
			lo_o <= reg1_i;
		elsif(aluop_i = EXE_DIV_OP or aluop_i = EXE_DIVU_OP) then
			whilo_o <= '1';
			hi_o <= div_result_i(63 downto 32);
			lo_o <= div_result_i(31 downto 0);
		else
			whilo_o <= '0';
			hi_o <= (others => '0');
			lo_o <= (others => '0');
		end if;
	end process hilo_compute;
	
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
	
	result_out : process(link_address_i,wd_i,aluop_i, ov_sum, wreg_i, alusel_i,logic_result,shift_result,move_result,mul_result,arith_result)
	begin
		wd_o 	<= wd_i;
		
		if(((aluop_i = EXE_ADD_OP) or (aluop_i = EXE_ADDI_OP) or (aluop_i = EXE_SUB_OP)) and (ov_sum = '1')) then
			wreg_o <= '0';
		else
			wreg_o	<= wreg_i;
		end if;
		
		case alusel_i is
			when EXE_RES_LOGIC =>
				wdata_o <= logic_result;
			when EXE_RES_SHIFT =>
				wdata_o <= shift_result;
			when EXE_RES_MOVE =>
				wdata_o <= move_result;
			when EXE_RES_ARITHMETIC =>
				wdata_o <= arith_result;
			when EXE_RES_MUL =>
				wdata_o <= mul_result(31 downto 0);
			when EXE_RES_JUMP_BRANCH =>
				wdata_o	<= link_address_i;
			when others =>
				wdata_o <= (others => '0');
		end case;
	end process result_out;
	
	-- hilo_write : process(rst, aluop_i, mul_result, reg1_i, hi, hi)
	-- begin
		-- if(rst = '0') then 
			-- whilo_o <= '0';
			-- hi_o	<= (others => '0');
			-- lo_o	<= (others => '0');
		-- elsif((aluop_i = EXE_MULT_OP) OR (aluop_i = EXE_MULTU_OP)) then
			-- whilo_o <= '1';
			-- hi_o <= mul_result(63 downto 32);
			-- lo_o <= mul_result(31 downto 0);
		-- elsif(aluop_i = EXE_MTHI_OP) then
			-- whilo_o <= '1';
			-- hi_o <= reg1_i;
			-- lo_o <= lo;
		-- elsif(aluop_i = EXE_MTLO_OP) then
			-- whilo_o <= '1';
			-- hi_o <= hi;
			-- lo_o <= reg1_i;
		-- else
			-- whilo_o <= '0';
			-- hi_o	<= (others => '0');
			-- lo_o	<= (others => '0');
		-- end if;
	
	-- end process hilo_write;
	
end rtl;
	
	
	
	
	
	
	
	
	
	
	
	
	
	