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
	constant EXE_ORI  			: std_ulogic_vector(5 downto 0) := b"001101";
    constant EXE_NOP 			: std_ulogic_vector(5 downto 0) := b"000000";
    
    --AluOp
    constant EXE_OR_OP    		: std_ulogic_vector(7 downto 0) := b"00100101";
    constant EXE_ORI_OP  		: std_ulogic_vector(7 downto 0) := b"01011010";
    constant EXE_NOP_OP    		: std_ulogic_vector(7 downto 0) := b"00000000"; 
    
    --AluSel
    constant EXE_RES_LOGIC 		: std_ulogic_vector(2 downto 0) := b"001";
    constant EXE_RES_NOP 		: std_ulogic_vector(2 downto 0) := b"000";
    
    
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
		wreg_o		: out std_ulogic									-- write enable signal
		
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
		
		wd_o		: out std_ulogic_vector(RegAddrBus - 1 downto 0);
		wreg_o		: out std_ulogic;
		wdata_o		: out std_ulogic_vector(RegBus - 1 downto 0)
	);
	end component ex;
	
	component ex_mem 
	port(
		clk			: in std_ulogic;
		rst			: in std_ulogic;
		
		ex_wd		: in std_ulogic_vector(RegAddrBus - 1 downto 0);
		ex_wreg		: in std_ulogic;
		ex_wdata	: in std_ulogic_vector(RegBus - 1 downto 0);
		
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
		
		wb_wd		: out std_ulogic_vector(RegAddrBus - 1 downto 0);
		wb_wreg		: out std_ulogic;
		wb_wdata	: out std_ulogic_vector(RegBus - 1 downto 0)
	);
	end component mem_wb;


end cpu_package;

package body cpu_package is

end cpu_package;
	