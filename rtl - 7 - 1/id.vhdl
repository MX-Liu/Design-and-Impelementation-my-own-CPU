library ieee;
use ieee.std_logic_1164.all;
use work.cpu_package.all;

entity id is
	port(
		rst			: in std_ulogic;
		
		pc_i		: in std_ulogic_vector(InstAddrBus - 1 downto 0);
		inst_i		: in std_ulogic_vector(InstAddrBus - 1 downto 0);
		
		-- interface signal for the regfile 
		reg1_data_i	: in std_ulogic_vector(RegBus - 1 downto 0);
		reg2_data_i	: in std_ulogic_vector(RegBus - 1 downto 0);
		
		reg1_read_o	: out std_ulogic;  -- read enable signal 1, read regfile 
		reg2_read_o	: out std_ulogic;  -- read enable signal 2, read regfile 
		
		reg1_addr_o : out std_ulogic_vector(RegAddrBus - 1 downto 0); -- read address 
		reg2_addr_o : out std_ulogic_vector(RegAddrBus - 1 downto 0);
		
		-- interface signal for excute module 
		aluop_o		: out std_ulogic_vector(AluOpBus - 1 downto 0);
		alusel_o	: out std_ulogic_vector(AluSelBus - 1 downto 0);
		
		reg1_o		: out std_ulogic_vector(RegBus - 1 downto 0); 	-- operand 1 
		reg2_o		: out std_ulogic_vector(RegBus - 1 downto 0); 	-- operand 2 
		
		wd_o		: out std_ulogic_vector(RegAddrBus - 1 downto 0);	-- the address of the destination register that will be written.
		wreg_o		: out std_ulogic;		-- write enable signal
		
		-- to solve the data involved proplem, when the second instruction want to access the register that will be written by the first second
		-- in excutation stage
		ex_wd_i		: in std_ulogic_vector(RegAddrBus - 1 downto 0);
		ex_wreg_i	: in std_ulogic;
		ex_wdata_i	: in std_ulogic_vector(RegBus - 1 downto 0);
		
		-- to solve the data involved proplem, when the third instruction want to access the register that will be written by the first second
		-- in memory access stage
		mem_wd_i	: in std_ulogic_vector(RegAddrBus - 1 downto 0);
		mem_wreg_i	: in std_ulogic;
		mem_wdata_i	: in std_ulogic_vector(RegBus - 1 downto 0)
		
	);
end entity id;

architecture rtl of id is 
 
	signal op 		: std_ulogic_vector(5 downto 0);
	signal op2 		: std_ulogic_vector(4 downto 0);
	signal op3 		: std_ulogic_vector(5 downto 0);
	signal op4 		: std_ulogic_vector(4 downto 0);
	
	signal imm		: std_ulogic_vector(RegBus - 1 downto 0);
	signal inst_offset : std_ulogic_vector(15 downto 0);
	signal instvalid: std_ulogic; -- is the instruction valid?
	
begin
    -------------------------------------------------------
	-- all process is combinational circuit 
	-------------------------------------------------------
	
	-- fetch the instruction bit and function bit 
	op	<= inst_i(31 downto 26);
	op2 <= inst_i(10 downto 6);
	op3 <= inst_i(5 downto 0);
	op4 <= inst_i(20 downto 16);
	
	-------------------------------------------------
	-- Decoding instructions
	-------------------------------------------------
	inst_decode_prc : process(rst,inst_i,op,op2,op3,op4,reg2_o,inst_offset)
	begin
		if(rst = '0') then 
			aluop_o		<= EXE_NOP_OP;
			alusel_o	<= EXE_RES_NOP;
			wd_o		<= NOPRegAddr;
			wreg_o		<= '0';
			instvalid	<= '1';
				
			reg1_read_o	<= '0';
			reg2_read_o	<= '0';
				
			reg1_addr_o	<= NOPRegAddr;
			reg2_addr_o	<= NOPRegAddr;
				
			imm			<= (others => '0');
		else 
			aluop_o		<= EXE_NOP_OP;
			alusel_o	<= EXE_RES_NOP;
			wd_o		<= inst_i(15 downto 11);
			inst_offset <= (others => inst_i(15));
			wreg_o		<= '0';
			instvalid	<= '0';
				
			reg1_read_o	<= '0';
			reg2_read_o	<= '0';
				
			reg1_addr_o	<= inst_i(25 downto 21);
			reg2_addr_o	<= inst_i(20 downto 16);
				
			imm			<= (others => '0');
			case op is
				when EXE_SPECIAL_INST =>
					case op2 is
						when b"00000" =>
							case op3 is
								when EXE_OR =>
									wreg_o		<= '1';
									aluop_o		<= EXE_OR_OP;
									alusel_o	<= EXE_RES_LOGIC;
									reg1_read_o	<= '1';
									reg2_read_o	<= '1';
									instvalid	<= '1';
									
								when EXE_AND =>
									wreg_o		<= '1';
									aluop_o		<= EXE_AND_OP;
									alusel_o	<= EXE_RES_LOGIC;
									reg1_read_o	<= '1';
									reg2_read_o	<= '1';
									instvalid	<= '1';
								when EXE_XOR =>
									wreg_o		<= '1';
									aluop_o		<= EXE_XOR_OP;
									alusel_o	<= EXE_RES_LOGIC;
									reg1_read_o	<= '1';
									reg2_read_o	<= '1';
									instvalid	<= '1';
								when EXE_NOR =>
									wreg_o		<= '1';
									aluop_o		<= EXE_NOR_OP;
									alusel_o	<= EXE_RES_LOGIC;
									reg1_read_o	<= '1';
									reg2_read_o	<= '1';
									instvalid	<= '1';
								
								when EXE_SLLV =>
									wreg_o		<= '1';
									aluop_o		<= EXE_SLL_OP;
									alusel_o	<= EXE_RES_SHIFT;
									reg1_read_o	<= '1';
									reg2_read_o	<= '1';
									instvalid	<= '1';
								when EXE_SRLV =>
									wreg_o		<= '1';
									aluop_o		<= EXE_SRL_OP;
									alusel_o	<= EXE_RES_SHIFT;
									reg1_read_o	<= '1';
									reg2_read_o	<= '1';
									instvalid	<= '1';
								when EXE_SRAV =>
									wreg_o		<= '1';
									aluop_o		<= EXE_SRL_OP;
									alusel_o	<= EXE_RES_SHIFT;
									reg1_read_o	<= '1';
									reg2_read_o	<= '1';
									instvalid	<= '1';
								when EXE_SYNC =>
									wreg_o		<= '1';
									aluop_o		<= EXE_NOP_OP;
									alusel_o	<= EXE_RES_NOP;
									reg1_read_o	<= '1';
									reg2_read_o	<= '1';
									instvalid	<= '1';
								when EXE_MFHI =>
									wreg_o		<= '1';
									aluop_o		<= EXE_MFHI_OP;
									alusel_o	<= EXE_RES_MOVE;
									reg1_read_o	<= '0';
									reg2_read_o	<= '0';
									instvalid	<= '1';
								when EXE_MFLO =>
									wreg_o		<= '1';
									aluop_o		<= EXE_MFLO_OP;
									alusel_o	<= EXE_RES_MOVE;
									reg1_read_o	<= '0';
									reg2_read_o	<= '0';
									instvalid	<= '1';
								when EXE_MTHI =>
									wreg_o		<= '0';
									aluop_o		<= EXE_MTHI_OP;
									reg1_read_o	<= '1';
									reg2_read_o	<= '0';
									instvalid	<= '1';
								when EXE_MTLO =>
									wreg_o		<= '0';
									aluop_o		<= EXE_MTLO_OP;
									reg1_read_o	<= '1';
									reg2_read_o	<= '0';
									instvalid	<= '1';
								when EXE_MOVN =>
									aluop_o		<= EXE_MOVN_OP;
									alusel_o	<= EXE_RES_MOVE;
									reg1_read_o	<= '1';
									reg2_read_o	<= '1';
									instvalid	<= '1';
									if(reg2_o /= x"00000000") then
										wreg_o		<= '1';
									else
										wreg_o		<= '0';
									end if;
								when EXE_MOVZ =>
									aluop_o		<= EXE_MOVZ_OP;
									alusel_o	<= EXE_RES_MOVE;
									reg1_read_o	<= '1';
									reg2_read_o	<= '1';
									instvalid	<= '1';
									if(reg2_o = x"00000000") then
										wreg_o		<= '1';
									else
										wreg_o		<= '0';
									end if;
								when EXE_SLT =>		-- signed compare
									wreg_o		<= '1';
									aluop_o		<= EXE_SLT_OP;
									alusel_o	<= EXE_RES_ARITHMETIC;
									reg1_read_o	<= '1';
									reg2_read_o	<= '1';
									instvalid	<= '1';
								when EXE_SLTU =>  	-- unsigned compare
									wreg_o		<= '1';
									aluop_o		<= EXE_SLTU_OP;
									alusel_o	<= EXE_RES_ARITHMETIC;
									reg1_read_o	<= '1';
									reg2_read_o	<= '1';
									instvalid	<= '1';
								when EXE_ADD =>   -- 加法运算，检查结果是否溢出，如果溢出，那么不保存结果
									wreg_o		<= '1';
									aluop_o		<= EXE_ADD_OP;
									alusel_o	<= EXE_RES_ARITHMETIC;
									reg1_read_o	<= '1';
									reg2_read_o	<= '1';
									instvalid	<= '1';
								when EXE_ADDU =>  -- 加法运算，检查结果是否溢出，如果溢出，也保存结果
									wreg_o		<= '1';
									aluop_o		<= EXE_ADDU_OP;
									alusel_o	<= EXE_RES_ARITHMETIC;
									reg1_read_o	<= '1';
									reg2_read_o	<= '1';
									instvalid	<= '1';
								when EXE_SUB => 	-- 减法运算，检查结果是否溢出，如果溢出，那么不保存结果
									wreg_o		<= '1';
									aluop_o		<= EXE_SUB_OP;
									alusel_o	<= EXE_RES_ARITHMETIC;
									reg1_read_o	<= '1';
									reg2_read_o	<= '1';
									instvalid	<= '1';
								when EXE_SUBU =>
									wreg_o		<= '1';
									aluop_o		<= EXE_SUBU_OP;
									alusel_o	<= EXE_RES_ARITHMETIC;
									reg1_read_o	<= '1';
									reg2_read_o	<= '1';
									instvalid	<= '1';
								when EXE_MULT =>	-- {hi,lo} <= rs X rt
									wreg_o		<= '0';
									aluop_o		<= EXE_MULT_OP;
									reg1_read_o	<= '1';
									reg2_read_o	<= '1';
									instvalid	<= '1';
								when EXE_MULTU =>
									wreg_o		<= '0';
									aluop_o		<= EXE_MULTU_OP;
									reg1_read_o	<= '1';
									reg2_read_o	<= '1';
									instvalid	<= '1';
							
								when others =>
									null;
							end case;
						when others =>
							null;
					end case;
					
				when EXE_ORI => 
					wreg_o		<= '1';
					aluop_o		<= EXE_OR_OP;
					alusel_o	<= EXE_RES_LOGIC;
					-- only need to read the register 1.
					reg1_read_o	<= '1';
					reg2_read_o	<= '0';
					-- this instruction need the immediate number	
					imm 		<= x"0000"&inst_i(15 downto 0);
					-- the destination address
					wd_o 		<= inst_i(20 downto 16);
					-- the instruction is valid
					instvalid	<= '1';
				when EXE_ANDI =>
					wreg_o		<= '1';
					aluop_o		<= EXE_AND_OP;
					alusel_o	<= EXE_RES_LOGIC;
					reg1_read_o	<= '1';
					reg2_read_o	<= '0';
					imm 		<= x"0000"&inst_i(15 downto 0);
					wd_o 		<= inst_i(20 downto 16);
					instvalid	<= '1';
				when EXE_XORI =>
					wreg_o		<= '1';
					aluop_o		<= EXE_XOR_OP;
					alusel_o	<= EXE_RES_LOGIC;
					reg1_read_o	<= '1';
					reg2_read_o	<= '0';	
					imm 		<= x"0000"&inst_i(15 downto 0);
					wd_o 		<= inst_i(20 downto 16);
					instvalid	<= '1';
				when EXE_SLTI =>
					wreg_o		<= '1';
					aluop_o		<= EXE_SLT_OP;
					alusel_o	<= EXE_RES_ARITHMETIC;
					reg1_read_o	<= '1';
					reg2_read_o	<= '0';	
					imm 		<= inst_offset&inst_i(15 downto 0);
					wd_o 		<= inst_i(20 downto 16);
					instvalid	<= '1';
				when EXE_SLTIU =>
					wreg_o		<= '1';
					aluop_o		<= EXE_SLTU_OP;
					alusel_o	<= EXE_RES_ARITHMETIC;
					reg1_read_o	<= '1';
					reg2_read_o	<= '0';	
					imm 		<= inst_offset&inst_i(15 downto 0);
					wd_o 		<= inst_i(20 downto 16);
					instvalid	<= '1';
				when EXE_ADDI =>
					wreg_o		<= '1';
					aluop_o		<= EXE_ADDI_OP;
					alusel_o	<= EXE_RES_ARITHMETIC;
					reg1_read_o	<= '1';
					reg2_read_o	<= '0';	
					imm 		<= inst_offset&inst_i(15 downto 0);
					wd_o 		<= inst_i(20 downto 16);
					instvalid	<= '1';
				when EXE_ADDIU =>
					wreg_o		<= '1';
					aluop_o		<= EXE_ADDIU_OP;
					alusel_o	<= EXE_RES_ARITHMETIC;
					reg1_read_o	<= '1';
					reg2_read_o	<= '0';	
					imm 		<= inst_offset&inst_i(15 downto 0);
					wd_o 		<= inst_i(20 downto 16);
					instvalid	<= '1';
				
				when EXE_LUI =>
					wreg_o		<= '1';
					aluop_o		<= EXE_OR_OP;
					alusel_o	<= EXE_RES_LOGIC;
					reg1_read_o	<= '1';
					reg2_read_o	<= '0';	
					imm 		<= inst_i(15 downto 0)&x"0000";
					wd_o 		<= inst_i(20 downto 16);
					instvalid	<= '1';
				when EXE_PREF =>
					wreg_o		<= '1';
					aluop_o		<= EXE_NOP_OP;
					alusel_o	<= EXE_RES_NOP;
					reg1_read_o	<= '0';
					reg2_read_o	<= '0';	
					instvalid	<= '1';
				when EXE_SPECIAL2_INST =>
					case op3 is
						when EXE_CLZ =>
							wreg_o		<= '1';
							aluop_o		<= EXE_CLZ_OP;
							alusel_o	<= EXE_RES_ARITHMETIC;
							reg1_read_o	<= '1';
							reg2_read_o	<= '0';	
							instvalid	<= '1';
						when EXE_CLO =>
							wreg_o		<= '1';
							aluop_o		<= EXE_CLO_OP;
							alusel_o	<= EXE_RES_ARITHMETIC;
							reg1_read_o	<= '1';
							reg2_read_o	<= '0';	
							instvalid	<= '1';
						when EXE_MUL =>
							wreg_o		<= '1';
							aluop_o		<= EXE_MUL_OP;
							alusel_o	<= EXE_RES_MUL;
							reg1_read_o	<= '1';
							reg2_read_o	<= '1';	
							instvalid	<= '1';
						when others =>
							null;
					end case;
				when others =>
					null;
			end case;
			
			if(inst_i(31 downto 21) = b"00000000000") then
				case op3 is
					when EXE_SLL =>
						wreg_o		<= '1';
						aluop_o		<= EXE_SLL_OP;
						alusel_o	<= EXE_RES_SHIFT;
						reg1_read_o	<= '0';
						reg2_read_o	<= '1';	
						imm(4 downto 0) <= inst_i(10 downto 6);
						wd_o 		<= inst_i(15 downto 11);
						instvalid	<= '1';
					when EXE_SRL =>
						wreg_o		<= '1';
						aluop_o		<= EXE_SRL_OP;
						alusel_o	<= EXE_RES_SHIFT;
						reg1_read_o	<= '0';
						reg2_read_o	<= '1';	
						imm(4 downto 0) <= inst_i(10 downto 6);
						wd_o 		<= inst_i(15 downto 11);
						instvalid	<= '1';
					when EXE_SRA =>
						wreg_o		<= '1';
						aluop_o		<= EXE_SRA_OP;
						alusel_o	<= EXE_RES_SHIFT;
						reg1_read_o	<= '0';
						reg2_read_o	<= '1';	
						imm(4 downto 0) <= inst_i(10 downto 6);
						wd_o 		<= inst_i(15 downto 11);
						instvalid	<= '1';
					when others =>
						null;
				end case;
			end if;
		end if;
	end process inst_decode_prc;
	
	------------------------------------------------------------------
	-- determin the second source operand 1 
	------------------------------------------------------------------
	
	determin_1_op : process(rst,reg1_read_o,reg1_data_i,imm, ex_wreg_i, ex_wd_i, reg1_addr_o,ex_wdata_i, mem_wdata_i,mem_wreg_i, mem_wd_i)
	begin
		
		if(rst = '0') then
			reg1_o	<= (others => '0');
		elsif(reg1_read_o = '1' and ex_wreg_i = '1' and ex_wd_i = reg1_addr_o) then
			reg1_o <= ex_wdata_i;
		elsif(reg1_read_o = '1' and mem_wreg_i = '1' and mem_wd_i = reg1_addr_o) then
			reg1_o <= mem_wdata_i;
		elsif(reg1_read_o = '1') then
			reg1_o <= reg1_data_i;
		elsif(reg1_read_o = '0') then
			reg1_o <= imm;
		else
			reg1_o	<= (others => '0');
		end if;
		
		
	end process determin_1_op;
	
	
	------------------------------------------------------------------
	-- determin the second source operand 2 
	------------------------------------------------------------------
	
	determin_2_op : process(rst,reg2_read_o,reg2_data_i,imm, ex_wreg_i, ex_wd_i, ex_wdata_i, mem_wreg_i, mem_wd_i, reg2_addr_o, mem_wdata_i)
	begin
		
		if(rst = '0') then
			reg2_o	<= (others => '0');
		elsif(reg2_read_o = '1' and ex_wreg_i = '1' and ex_wd_i = reg2_addr_o) then
			reg2_o <= ex_wdata_i;
		elsif(reg2_read_o = '1' and mem_wreg_i = '1' and mem_wd_i = reg2_addr_o) then
			reg2_o <= mem_wdata_i;
		elsif(reg2_read_o = '1') then
			reg2_o <= reg2_data_i;
		elsif(reg2_read_o = '0') then
			reg2_o <= imm;
		else
			reg2_o	<= (others => '0');
		end if;
		
		
	end process determin_2_op;
end rtl;