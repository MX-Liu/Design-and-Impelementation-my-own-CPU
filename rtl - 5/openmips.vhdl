library ieee;
use ieee.std_logic_1164.all;
use work.cpu_package.all;

entity openmips is
	port(
		clk			: in std_ulogic;
		rst			: in std_ulogic;
		
		rom_data_i	: in std_ulogic_vector(RegBus - 1 downto 0);
		rom_addr_o  : out std_ulogic_vector(RegBus - 1 downto 0);
		rom_ce_o 	: out std_ulogic
	);
end entity openmips;

architecture rtl of openmips is
	-- interface between if_id and id 
	signal pc			: std_ulogic_vector(InstAddrBus - 1 downto 0);
	signal id_pc_i		: std_ulogic_vector(InstAddrBus - 1 downto 0);
	signal id_inst_i	: std_ulogic_vector(InstBus - 1 downto 0);
	
	-- interface between id and id_ex
	signal id_aluop_o	: std_ulogic_vector(AluOpBus - 1 downto 0);
	signal id_alusel_o	: std_ulogic_vector(AluSelBus - 1 downto 0);
	signal id_reg1_o	: std_ulogic_vector(RegBus - 1 downto 0);
	signal id_reg2_o	: std_ulogic_vector(RegBus - 1 downto 0);
	signal id_wreg_o	: std_ulogic;
	signal id_wd_o		: std_ulogic_vector(RegAddrBus - 1 downto 0);
	-- interface between id_ex and ex 
	signal ex_aluop_i	: std_ulogic_vector(AluOpBus - 1 downto 0);
	signal ex_alusel_i	: std_ulogic_vector(AluSelBus - 1 downto 0);
	signal ex_reg1_i	: std_ulogic_vector(RegBus - 1 downto 0);
	signal ex_reg2_i	: std_ulogic_vector(RegBus - 1 downto 0);
	signal ex_wreg_i	: std_ulogic;
	signal ex_wd_i		: std_ulogic_vector(RegAddrBus - 1 downto 0);
	
	-- interface between ex and ex_mem
	signal ex_wreg_o 	: std_ulogic;
	signal ex_wd_o 		: std_ulogic_vector(RegAddrBus - 1 downto 0);
	signal ex_wdata_o	: std_ulogic_vector(RegBus - 1 downto 0);
	
	-- interface between ex_mem and mem
	signal mem_wreg_i 	: std_ulogic;
	signal mem_wd_i 	: std_ulogic_vector(RegAddrBus - 1 downto 0);
	signal mem_wdata_i	: std_ulogic_vector(RegBus - 1 downto 0);
	
	-- interface between mem and mem_wb
	signal mem_wreg_o 	: std_ulogic;
	signal mem_wd_o 	: std_ulogic_vector(RegAddrBus - 1 downto 0);
	signal mem_wdata_o	: std_ulogic_vector(RegBus - 1 downto 0);
	
	-- interface between mem_wb and register_file
	signal wb_wreg_i 	: std_ulogic;
	signal wb_wd_i 		: std_ulogic_vector(RegAddrBus - 1 downto 0);
	signal wb_wdata_i	: std_ulogic_vector(RegBus - 1 downto 0);
	
	-- interface between id and regfile 
	signal reg1_read 	: std_ulogic;
	signal reg2_read	: std_ulogic;
	
	signal reg1_data	: std_ulogic_vector(RegBus - 1 downto 0);
	signal reg2_data	: std_ulogic_vector(RegBus - 1 downto 0);
	
	signal reg1_addr	: std_ulogic_vector(RegAddrBus - 1 downto 0);
	signal reg2_addr	: std_ulogic_vector(RegAddrBus - 1 downto 0);
	
	
	
begin
	inst_pc_reg	: pc_reg
	port map(
		clk		=> clk,
		rst		=> rst,
		pc		=> pc,
		ce		=> rom_ce_o
	);
	
	rom_addr_o <= pc;
	
	inst_if_id	: if_id
	port map(
		clk		=> clk,
		rst		=> rst,
		
		if_pc	=> pc,
		if_inst	=> rom_data_i,
		
		id_pc	=> id_pc_i, 
		id_inst	=> id_inst_i
	);
	
	inst_id	: id
	port map(
		rst			=> rst,
		
		pc_i		=> id_pc_i,
		inst_i		=> id_inst_i,
		
		-- interface signal for the regfile 
		reg1_data_i	=> reg1_data,
		reg2_data_i	=> reg2_data,
		
		reg1_read_o	=> reg1_read,
		reg2_read_o	=> reg2_read,
		
		reg1_addr_o => reg1_addr, 
		reg2_addr_o => reg2_addr, 
		
		-- interface signal for excute module 
		aluop_o		=> id_aluop_o,
		alusel_o	=> id_alusel_o,
		
		reg1_o		=> id_reg1_o,
		reg2_o		=> id_reg2_o,
		
		wd_o		=> id_wd_o,	-- the address of the destination register that will be written.
		wreg_o		=> id_wreg_o, -- write enable signal
		
		-- to solve the data involved proplem, when the second instruction want to access the register that will be written by the first second
		-- in excutation stage
		ex_wd_i		=> ex_wd_o,
		ex_wreg_i	=> ex_wreg_o,
		ex_wdata_i	=> ex_wdata_o,
		
		-- to solve the data involved proplem, when the third instruction want to access the register that will be written by the first second
		-- in memory access stage
		mem_wd_i	=> mem_wd_o,
		mem_wreg_i	=> mem_wreg_o,
		mem_wdata_i	=> mem_wdata_o
	);
	
	inst_regfile	: regfile
	port map(
		rst		=> rst,
		clk		=> clk,
		
		we		=> wb_wreg_i,
		waddr	=> wb_wd_i,
		wdata	=> wb_wdata_i,
		
		re1		=> reg1_read,
		raddr1	=> reg1_addr,
		rdata1	=> reg1_data,
		
		re2		=> reg2_read,
		raddr2	=> reg2_addr,
		rdata2	=> reg2_data
	);
	
	inst_id_ex	: id_ex
	port map(
		clk			=> clk,
		rst			=> rst,
		
		id_aluop	=> id_aluop_o,
		id_alusel	=> id_alusel_o,
		
		id_reg1		=> id_reg1_o, 	-- source operand 1 
		id_reg2		=> id_reg2_o,	-- source operand 2
		
		id_wd		=> id_wd_o,		-- the address of the destination register that will be written.
		id_wreg		=> id_wreg_o,								-- write enable signal
		
		ex_aluop	=> ex_aluop_i,
		ex_alusel	=> ex_alusel_i,
		
		ex_reg1		=> ex_reg1_i, 	-- source operand 1 
		ex_reg2		=> ex_reg2_i, 	-- source operand 2
		
		ex_wd		=> ex_wd_i,		-- the address of the destination register that will be written.
		ex_wreg		=> ex_wreg_i									-- write enable signal
	);
	
	inst_ex	: ex
	port map(
		rst			=> rst,
		
		aluop_i		=> ex_aluop_i,
		alusel_i	=> ex_alusel_i,
		
		reg1_i		=> ex_reg1_i, 	-- source operand 1 
		reg2_i		=> ex_reg2_i, 	-- source operand 2
		
		wd_i		=> ex_wd_i,		-- the address of the destination register that will be written.
		wreg_i		=> ex_wreg_i,	-- write enable signal	
		
		wd_o		=> ex_wd_o,
		wreg_o		=> ex_wreg_o,
		wdata_o		=> ex_wdata_o
	);
	
	inst_ex_mem	: ex_mem
	port map(
		clk			=> clk,
		rst			=> rst,
		
		ex_wd		=> ex_wd_o,
		ex_wreg		=> ex_wreg_o,
		ex_wdata	=> ex_wdata_o,
		
		mem_wd		=> mem_wd_i,
		mem_wreg	=> mem_wreg_i,
		mem_wdata	=> mem_wdata_i
	);
	
	inst_mem	: mem
	port map(
		rst			=> rst,
		
		wd_i		=> mem_wd_i,
		wreg_i		=> mem_wreg_i,
		wdata_i		=> mem_wdata_i,
		
		wd_o		=> mem_wd_o,
		wreg_o		=> mem_wreg_o,
		wdata_o		=> mem_wdata_o
	);
	
	inst_mem_wb	: mem_wb
	port map(
		clk			=> clk,
		rst			=> rst,
		
		mem_wd		=> mem_wd_o,
		mem_wreg	=> mem_wreg_o,
		mem_wdata	=> mem_wdata_o,
		
		wb_wd		=> wb_wd_i,
		wb_wreg		=> wb_wreg_i,
		wb_wdata	=> wb_wdata_i
	);

end rtl;
	
		
	
	
	
	
	