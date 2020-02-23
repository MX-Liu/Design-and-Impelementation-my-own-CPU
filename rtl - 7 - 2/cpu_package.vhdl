library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package cpu_package is
	constant RstEnable 			: std_ulogic	:= '1';
    constant RstDisable     	: std_ulogic	:= '0';
    constant ZeroWord 			: std_ulogic_vector(31 downto 0) := (others => '0'); 
    constant WriteEnable 		: std_ulogic	:= '1';
    constant WriteDisable 		: std_ulogic	:= '0';
    constant ReadEnable 		: std_ulogic	:= '1';
    constant ReadDisable 		: std_ulogic	:= '0';
    constant AluOpBus 			: integer 		:= 8; --7:0 the width of aluop_o
    constant AluSelBus 			: integer 		:= 3; --2:0 the width of alusel_o
    constant InstValid 			: std_ulogic	:= '0';
    constant InstInvalid 		: std_ulogic	:= '1';
    constant Stop 				: std_ulogic	:= '1';
    constant NoStop 			: std_ulogic	:= '0';
    constant InDelaySlot 		: std_ulogic	:= '1';
    constant NotInDelaySlot 	: std_ulogic	:= '0';
    constant Branch 			: std_ulogic	:= '1';
    constant NotBranch 			: std_ulogic	:= '0';
    constant InterruptAssert 	: std_ulogic	:= '1';
    constant InterruptNotAssert : std_ulogic	:= '0';
    constant TrapAssert 		: std_ulogic	:= '1';
    constant TrapNotAssert 		: std_ulogic	:= '0';
    constant True_v 			: std_ulogic	:= '1';
    constant False_v 			: std_ulogic	:= '0';
    constant ChipEnable 		: std_ulogic	:= '1';
    constant ChipDisable 		: std_ulogic	:= '0';
	
	--INSTRUCTOR
	constant EXE_AND  			: std_ulogic_vector(5 downto 0) := b"100100";
	constant EXE_OR   			: std_ulogic_vector(5 downto 0) := b"100101";
	constant EXE_XOR 			: std_ulogic_vector(5 downto 0) := b"100110";
	constant EXE_NOR 			: std_ulogic_vector(5 downto 0) := b"100111";
	constant EXE_ANDI 			: std_ulogic_vector(5 downto 0) := b"001100";
	constant EXE_ORI  			: std_ulogic_vector(5 downto 0) := b"001101";
	constant EXE_XORI 			: std_ulogic_vector(5 downto 0) := b"001110";
	constant EXE_LUI 			: std_ulogic_vector(5 downto 0) := b"001111";

	constant EXE_SLL  			: std_ulogic_vector(5 downto 0) := b"000000";
	constant EXE_SLLV  			: std_ulogic_vector(5 downto 0) := b"000100";
	constant EXE_SRL  			: std_ulogic_vector(5 downto 0) := b"000010";
	constant EXE_SRLV  			: std_ulogic_vector(5 downto 0) := b"000110";
	constant EXE_SRA  			: std_ulogic_vector(5 downto 0) := b"000011";
	constant EXE_SRAV  			: std_ulogic_vector(5 downto 0) := b"000111";
	constant EXE_SYNC  			: std_ulogic_vector(5 downto 0) := b"001111";
	constant EXE_PREF  			: std_ulogic_vector(5 downto 0) := b"110011";
	
	constant EXE_MOVZ  			: std_ulogic_vector(5 downto 0) := b"001010";
	constant EXE_MOVN  			: std_ulogic_vector(5 downto 0) := b"001011";
	constant EXE_MFHI  			: std_ulogic_vector(5 downto 0) := b"010000";
	constant EXE_MTHI  			: std_ulogic_vector(5 downto 0) := b"010001";
	constant EXE_MFLO  			: std_ulogic_vector(5 downto 0) := b"010010";
	constant EXE_MTLO  			: std_ulogic_vector(5 downto 0) := b"010011";
	
	constant EXE_SLT  			: std_ulogic_vector(5 downto 0) := b"101010";
	constant EXE_SLTU  			: std_ulogic_vector(5 downto 0) := b"101011";
	constant EXE_SLTI  			: std_ulogic_vector(5 downto 0) := b"001010";
	constant EXE_SLTIU  		: std_ulogic_vector(5 downto 0) := b"001011";   
	constant EXE_ADD  			: std_ulogic_vector(5 downto 0) := b"100000";
	constant EXE_ADDU  			: std_ulogic_vector(5 downto 0) := b"100001";
	constant EXE_SUB  			: std_ulogic_vector(5 downto 0) := b"100010";
	constant EXE_SUBU  			: std_ulogic_vector(5 downto 0) := b"100011";
	constant EXE_ADDI  			: std_ulogic_vector(5 downto 0) := b"001000";
	constant EXE_ADDIU  		: std_ulogic_vector(5 downto 0) := b"001001";
	constant EXE_CLZ  			: std_ulogic_vector(5 downto 0) := b"100000";
	constant EXE_CLO  			: std_ulogic_vector(5 downto 0) := b"100001";

	constant EXE_MULT  			: std_ulogic_vector(5 downto 0) := b"011000";
	constant EXE_MULTU  		: std_ulogic_vector(5 downto 0) := b"011001";
	constant EXE_MUL  			: std_ulogic_vector(5 downto 0) := b"000010";
	
	constant EXE_MADD  			: std_ulogic_vector(5 downto 0) := b"000000";
	constant EXE_MADDU  		: std_ulogic_vector(5 downto 0) := b"000001";
	
	constant EXE_MSUB  			: std_ulogic_vector(5 downto 0) := b"000100";
	constant EXE_MSUBU  		: std_ulogic_vector(5 downto 0) := b"000101";
	
	constant EXE_DIV  			: std_ulogic_vector(5 downto 0) := b"011010";
	constant EXE_DIVU  			: std_ulogic_vector(5 downto 0) := b"011011";

	constant EXE_NOP 			: std_ulogic_vector(5 downto 0) := b"000000";
	constant SSNOP 				: std_ulogic_vector(31 downto 0) := x"00000040"; --'b000000000000000000000000 0100 0000

	constant EXE_SPECIAL_INST 	: std_ulogic_vector(5 downto 0) := b"000000";
	constant EXE_REGIMM_INST 	: std_ulogic_vector(5 downto 0) := b"000001";
	constant EXE_SPECIAL2_INST 	: std_ulogic_vector(5 downto 0) := b"011100";

	--AluOp
	constant EXE_AND_OP   		: std_ulogic_vector(7 downto 0) := b"00100100";
	constant EXE_OR_OP    		: std_ulogic_vector(7 downto 0) := b"00100101";
	constant EXE_XOR_OP  		: std_ulogic_vector(7 downto 0) := b"00100110";
	constant EXE_NOR_OP  		: std_ulogic_vector(7 downto 0) := b"00100111";
	constant EXE_ANDI_OP  		: std_ulogic_vector(7 downto 0) := b"01011001";
	constant EXE_ORI_OP  		: std_ulogic_vector(7 downto 0) := b"01011010";
	constant EXE_XORI_OP  		: std_ulogic_vector(7 downto 0) := b"01011011";
	constant EXE_LUI_OP  		: std_ulogic_vector(7 downto 0) := b"01011100";   

	constant EXE_SLL_OP  		: std_ulogic_vector(7 downto 0) := b"01111100";
	constant EXE_SLLV_OP  		: std_ulogic_vector(7 downto 0) := b"00000100";
	constant EXE_SRL_OP  		: std_ulogic_vector(7 downto 0) := b"00000010";
	constant EXE_SRLV_OP  		: std_ulogic_vector(7 downto 0) := b"00000110";
	constant EXE_SRA_OP  		: std_ulogic_vector(7 downto 0) := b"00000011";
	constant EXE_SRAV_OP  		: std_ulogic_vector(7 downto 0) := b"00000111";
	
	constant EXE_MOVZ_OP  		: std_ulogic_vector(7 downto 0) := b"00001010";
	constant EXE_MOVN_OP  		: std_ulogic_vector(7 downto 0) := b"00001011";
	constant EXE_MFHI_OP  		: std_ulogic_vector(7 downto 0) := b"00010000";
	constant EXE_MTHI_OP  		: std_ulogic_vector(7 downto 0) := b"00010001";
	constant EXE_MFLO_OP  		: std_ulogic_vector(7 downto 0) := b"00010010";
	constant EXE_MTLO_OP  		: std_ulogic_vector(7 downto 0) := b"00010011";
	
	constant EXE_SLT_OP  		: std_ulogic_vector(7 downto 0) := b"00101010";
	constant EXE_SLTU_OP  		: std_ulogic_vector(7 downto 0) := b"00101011";
	constant EXE_SLTI_OP  		: std_ulogic_vector(7 downto 0) := b"01010111";
	constant EXE_SLTIU_OP  		: std_ulogic_vector(7 downto 0) := b"01011000";   
	constant EXE_ADD_OP  		: std_ulogic_vector(7 downto 0) := b"00100000";
	constant EXE_ADDU_OP  		: std_ulogic_vector(7 downto 0) := b"00100001";
	constant EXE_SUB_OP  		: std_ulogic_vector(7 downto 0) := b"00100010";
	constant EXE_SUBU_OP  		: std_ulogic_vector(7 downto 0) := b"00100011";
	constant EXE_ADDI_OP  		: std_ulogic_vector(7 downto 0) := b"01010101";
	constant EXE_ADDIU_OP  		: std_ulogic_vector(7 downto 0) := b"01010110";
	constant EXE_CLZ_OP  		: std_ulogic_vector(7 downto 0) := b"10110000";
	constant EXE_CLO_OP  		: std_ulogic_vector(7 downto 0) := b"10110001";

	constant EXE_MULT_OP  		: std_ulogic_vector(7 downto 0) := b"00011000";
	constant EXE_MULTU_OP  		: std_ulogic_vector(7 downto 0) := b"00011001";
	constant EXE_MUL_OP  		: std_ulogic_vector(7 downto 0) := b"10101001";
	
	constant EXE_MADD_OP  		: std_ulogic_vector(7 downto 0) := b"10100110";
	constant EXE_MADDU_OP  		: std_ulogic_vector(7 downto 0) := b"10101000";
	constant EXE_MSUB_OP  		: std_ulogic_vector(7 downto 0) := b"10101010";
	constant EXE_MSUBU_OP  		: std_ulogic_vector(7 downto 0) := b"10101011";
	
	constant EXE_DIV_OP  		: std_ulogic_vector(7 downto 0) := b"00011010";
	constant EXE_DIVU_OP  		: std_ulogic_vector(7 downto 0) := b"00011011";

	constant EXE_NOP_OP    		: std_ulogic_vector(7 downto 0) := b"00000000";
    
    
    --AluSel
    constant EXE_RES_LOGIC 		: std_ulogic_vector(2 downto 0) := b"001";
    constant EXE_RES_NOP 		: std_ulogic_vector(2 downto 0) := b"000";
    constant EXE_RES_SHIFT 		: std_ulogic_vector(2 downto 0) := b"010";
	constant EXE_RES_MOVE 		: std_ulogic_vector(2 downto 0) := b"011";
	constant EXE_RES_ARITHMETIC : std_ulogic_vector(2 downto 0) := b"100";	
	constant EXE_RES_MUL 		: std_ulogic_vector(2 downto 0) := b"101";

    --instructor register inst_rom
    constant InstAddrBus 		: integer := 32; --31:0
    constant InstBus 			: integer := 32; --31:0
    constant InstMemNum 		: integer := 131071;
    constant InstMemNumLog2 	: integer := 17;
    
    
    --generic register regfile
    constant RegAddrBus 		: integer := 5; --4:0
    constant RegBus 			: integer := 32; --31:0
    constant RegWidth 			: integer := 32;
    constant DoubleRegWidth 	: integer := 64;
    constant DoubleRegBus 		: integer := 64; --63:0
    constant RegNum 			: integer := 32;
    constant RegNumLog2 		: integer := 5;
    constant NOPRegAddr 		: std_ulogic_vector(4 downto 0) := b"00000";
	
	
	component pc_reg 
	port(
		rst		: in std_ulogic;
		clk		: in std_ulogic;
		
		stall	: in std_ulogic_vector(5 downto 0);
		pc		: out std_ulogic_vector(InstAddrBus - 1 downto 0);
		ce 		: out std_ulogic
	);
	end component pc_reg;
	
	component if_id 
	port(
		rst		: in std_ulogic;
		clk		: in std_ulogic;
		
		if_pc	: in std_ulogic_vector(InstAddrBus - 1 downto 0);  -- the address of the instruction during during fetch
		if_inst	: in std_ulogic_vector(InstAddrBus - 1 downto 0);  -- the instruction during fetch
		
		stall 	: in std_ulogic_vector(5 downto 0);
		id_pc	: out std_ulogic_vector(InstAddrBus - 1 downto 0); -- the address of the instruction during decode
		id_inst	: out std_ulogic_vector(InstAddrBus - 1 downto 0)  -- the instruction during decode;
	);
	end component if_id;
	
	component id 
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
		
		stallreq	: out std_ulogic;
		
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
	end component id;
	
	component regfile 
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
	end component regfile;

	component id_ex 
	port(
		clk			: in std_ulogic;
		rst			: in std_ulogic;
		
		id_aluop	: in std_ulogic_vector(AluOpBus - 1 downto 0);
		id_alusel	: in std_ulogic_vector(AluSelBus - 1 downto 0);
		
		id_reg1		: in std_ulogic_vector(RegBus - 1 downto 0); 	-- source operand 1 
		id_reg2		: in std_ulogic_vector(RegBus - 1 downto 0); 	-- source operand 2
		
		id_wd		: in std_ulogic_vector(RegAddrBus - 1 downto 0);	-- the address of the destination register that will be written.
		id_wreg		: in std_ulogic;									-- write enable signal
		
		stall 		: in std_ulogic_vector(5 downto 0);
		ex_aluop	: out std_ulogic_vector(AluOpBus - 1 downto 0);
		ex_alusel	: out std_ulogic_vector(AluSelBus - 1 downto 0);
		
		ex_reg1		: out std_ulogic_vector(RegBus - 1 downto 0); 	-- source operand 1 
		ex_reg2		: out std_ulogic_vector(RegBus - 1 downto 0); 	-- source operand 2
		
		ex_wd		: out std_ulogic_vector(RegAddrBus - 1 downto 0);	-- the address of the destination register that will be written.
		ex_wreg		: out std_ulogic									-- write enable signal
		
	);
	end component id_ex;
	
	component ex 
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
		div_start_o	 : out std_ulogic
	);
	end component ex;
	
	component ex_mem 
	port(
		clk			: in std_ulogic;
		rst			: in std_ulogic;
		
		ex_wd		: in std_ulogic_vector(RegAddrBus - 1 downto 0);
		ex_wreg		: in std_ulogic;
		ex_wdata	: in std_ulogic_vector(RegBus - 1 downto 0);
		
		ex_whilo	: in std_ulogic;
		ex_hi		: in std_ulogic_vector(RegBus - 1 downto 0);
		ex_lo		: in std_ulogic_vector(RegBus - 1 downto 0);
		stall 		: in std_ulogic_vector(5 downto 0);
		
		hilo_i		: in std_ulogic_vector(2*RegBus - 1 downto 0);
		cnt_i		: in std_ulogic_vector(1 downto 0);
		hilo_o		: out std_ulogic_vector(2*RegBus - 1 downto 0);
		cnt_o		: out std_ulogic_vector(1 downto 0);
		
		mem_whilo	: out std_ulogic;
		mem_hi		: out std_ulogic_vector(RegBus - 1 downto 0);
		mem_lo		: out std_ulogic_vector(RegBus - 1 downto 0);
		
		mem_wd		: out std_ulogic_vector(RegAddrBus - 1 downto 0);
		mem_wreg	: out std_ulogic;
		mem_wdata	: out std_ulogic_vector(RegBus - 1 downto 0)
	);
	end component ex_mem;
	
	component mem  
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
		wdata_o		: out std_ulogic_vector(RegBus - 1 downto 0)
	);
	end component mem;
	
	component mem_wb 
	port(
		clk			: in std_ulogic;
		rst			: in std_ulogic;
		
		mem_wd		: in std_ulogic_vector(RegAddrBus - 1 downto 0);
		mem_wreg	: in std_ulogic;
		mem_wdata	: in std_ulogic_vector(RegBus - 1 downto 0);
		
		mem_whilo	: in std_ulogic;
		mem_hi		: in std_ulogic_vector(RegBus - 1 downto 0);
		mem_lo		: in std_ulogic_vector(RegBus - 1 downto 0);
		stall 		: in std_ulogic_vector(5 downto 0);
		
		wb_whilo	: out std_ulogic;
		wb_hi		: out std_ulogic_vector(RegBus - 1 downto 0);
		wb_lo		: out std_ulogic_vector(RegBus - 1 downto 0);
		
		wb_wd		: out std_ulogic_vector(RegAddrBus - 1 downto 0);
		wb_wreg		: out std_ulogic;
		wb_wdata	: out std_ulogic_vector(RegBus - 1 downto 0)
	);
	end component mem_wb;
	
	component hilo 
	port(
		clk			: in std_ulogic;
		rst			: in std_ulogic;
		
		we 			: in std_ulogic;
		hi_i		: in std_ulogic_vector(RegBus - 1 downto 0);
		lo_i		: in std_ulogic_vector(RegBus - 1 downto 0);
		
		hi_o		: out std_ulogic_vector(RegBus - 1 downto 0);
		lo_o	: out std_ulogic_vector(RegBus - 1 downto 0)	
	);
	end component hilo;
	
	component ctrl 
	port(
		rst				: in std_ulogic;
		
		stall_from_id 	: in std_ulogic;
		stall_from_ex	: in std_ulogic;
		
		stall 			: out std_ulogic_vector(5 downto 0)
	);
	end component ctrl;
	
	component div  
	port(
		clk			: in std_ulogic;
		rst			: in std_ulogic;
		
		signed_div_i: in std_ulogic;
		opdata1_i	: in std_ulogic_vector(31 downto 0);
		opdata2_i	: in std_ulogic_vector(31 downto 0);
		
		start_i		: in std_ulogic;
		annul_i		: in std_ulogic;
		
		result_o 	: out std_ulogic_vector(63 downto 0);
		ready_o		: out std_ulogic
	);
	end component div;

	function complement(A : std_ulogic_vector) return std_ulogic_vector;
	
end cpu_package;

package body cpu_package is

	function complement(A : std_ulogic_vector) return std_ulogic_vector is
		variable temp : std_ulogic_vector(31 downto 0);
		variable result : std_ulogic_vector(31 downto 0);
	begin
		 temp := not A;
		 result := std_ulogic_vector(unsigned(temp) + 1);
		 
		 return result;
	end function complement;
	
end cpu_package;
	