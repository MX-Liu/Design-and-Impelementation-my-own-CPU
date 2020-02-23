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
	
	signal ex_whilo_o   : std_ulogic;
	signal ex_hi_o		: std_ulogic_vector(RegBus - 1 downto 0);
	signal ex_lo_o		: std_ulogic_vector(RegBus - 1 downto 0);
	
	-- interface between ex_mem and mem
	signal mem_wreg_i 	: std_ulogic;
	signal mem_wd_i 	: std_ulogic_vector(RegAddrBus - 1 downto 0);
	signal mem_wdata_i	: std_ulogic_vector(RegBus - 1 downto 0);
	
	signal mem_whilo_i  : std_ulogic;
	signal mem_hi_i		: std_ulogic_vector(RegBus - 1 downto 0);
	signal mem_lo_i		: std_ulogic_vector(RegBus - 1 downto 0);
	
	-- interface between mem and mem_wb
	signal mem_wreg_o 	: std_ulogic;
	signal mem_wd_o 	: std_ulogic_vector(RegAddrBus - 1 downto 0);
	signal mem_wdata_o	: std_ulogic_vector(RegBus - 1 downto 0);
	
	signal mem_whilo_o  : std_ulogic;
	signal mem_hi_o		: std_ulogic_vector(RegBus - 1 downto 0);
	signal mem_lo_o		: std_ulogic_vector(RegBus - 1 downto 0);
	
	-- interface between mem_wb and register_file
	signal wb_wreg_i 	: std_ulogic;
	signal wb_wd_i 		: std_ulogic_vector(RegAddrBus - 1 downto 0);
	signal wb_wdata_i	: std_ulogic_vector(RegBus - 1 downto 0);
	
	-- interface between mem_wb and hilo
	signal wb_whilo_i   : std_ulogic;
	signal wb_hi_i		: std_ulogic_vector(RegBus - 1 downto 0);
	signal wb_lo_i		: std_ulogic_vector(RegBus - 1 downto 0);
	
	---- interface between hilo and ex
	signal wb_hi_o		: std_ulogic_vector(RegBus - 1 downto 0);
	signal wb_lo_o		: std_ulogic_vector(RegBus - 1 downto 0);
	
	-- interface between id and regfile 
	signal reg1_read 	: std_ulogic;
	signal reg2_read	: std_ulogic;
	
	signal reg1_data	: std_ulogic_vector(RegBus - 1 downto 0);
	signal reg2_data	: std_ulogic_vector(RegBus - 1 downto 0);
	
	signal reg1_addr	: std_ulogic_vector(RegAddrBus - 1 downto 0);
	signal reg2_addr	: std_ulogic_vector(RegAddrBus - 1 downto 0);
	
	signal hilo_temp_o	: std_ulogic_vector(2*RegBus - 1 downto 0);
	signal cnt_o		: std_ulogic_vector(1 downto 0);
	signal hilo_temp_i	: std_ulogic_vector(2*RegBus - 1 downto 0);
	signal cnt_i		: std_ulogic_vector(1 downto 0);
	
	signal stall 		: std_ulogic_vector(5 downto 0);
	signal stallreq_from_id : std_ulogic;
	signal stallreq_from_ex	: std_ulogic;
	
	signal signed_div  	: std_ulogic;
	signal div_opdata1	: std_ulogic_vector(RegBus - 1 downto 0);
	signal div_opdata2 	: std_ulogic_vector(RegBus - 1 downto 0);
		
	signal div_start	: std_ulogic;
	signal div_result	: std_ulogic_vector(2*RegBus - 1 downto 0);
	signal div_ready	: std_ulogic;
	
	signal branch_target_address 	: std_ulogic_vector(InstAddrBus - 1 downto 0);
	signal branch_flag				: std_ulogic;
	
	signal id_is_in_delayslot_o		: std_ulogic;
	signal id_link_addr_o				: std_ulogic_vector(RegBus - 1 downto 0);
	signal id_next_inst_in_delayslot_o	: std_ulogic;
	signal id_is_in_delay_slot_i		: std_ulogic;
	
	signal ex_is_in_delayslot_i			: std_ulogic;
	signal ex_link_address_i			: std_ulogic_vector(RegBus - 1 downto 0);
begin
	inst_pc_reg	: pc_reg
	port map(
		clk						=> clk,
		rst						=> rst,
		stall					=> stall,
		branch_flag_i			=> branch_flag,
		branch_target_address_i	=> branch_target_address,
		pc						=> pc,
		ce						=> rom_ce_o
	);
	
	rom_addr_o <= pc;
	
	inst_if_id	: if_id
	port map(
		clk		=> clk,
		rst		=> rst,
		
		if_pc	=> pc,
		if_inst	=> rom_data_i,
		stall	=> stall,
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
		mem_wdata_i	=> mem_wdata_o,
		stallreq 	=> stallreq_from_id,
		
		branch_flag_o 			=> branch_flag, 
		branch_target_address_o	=> branch_target_address,
		is_in_delayslot_o		=> id_is_in_delayslot_o,
		link_addr_o				=> id_link_addr_o,
		next_inst_in_delayslot_o=> id_next_inst_in_delayslot_o,
		is_in_delayslot_i		=> id_is_in_delay_slot_i
	);
	
	inst_regfile : regfile
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
		
		stall		=> stall,
		
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
		ex_wreg		=> ex_wreg_i,									-- write enable signal
		
		id_is_in_delayslot			=> id_is_in_delayslot_o,
		id_link_address				=> id_link_addr_o,
		next_inst_in_delayslot_i 	=> id_next_inst_in_delayslot_o,
		
		ex_is_in_delayslot			=> ex_is_in_delayslot_i,
		ex_link_address				=> ex_link_address_i,
		is_in_delayslot_o			=> id_is_in_delay_slot_i
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
		
		hi_i		=> wb_hi_o,
		lo_i		=> wb_lo_o,
		
		mem_whilo_i	=> mem_whilo_o,
		mem_hi_i	=> mem_hi_o,
		mem_lo_i	=> mem_lo_o,
		
		wb_whilo_i	=> wb_whilo_i,
		wb_hi_i		=> wb_hi_i,
		wb_lo_i		=> wb_lo_i,
		
		-- this auxiliary input signals are used for division
		div_result_i=> div_result,
		div_ready_i	=> div_ready,
		
		whilo_o		=> ex_whilo_o,
		hi_o		=> ex_hi_o,
		lo_o		=> ex_lo_o,
		
		wd_o		=> ex_wd_o,
		wreg_o		=> ex_wreg_o,
		wdata_o		=> ex_wdata_o,
		
		hilo_temp_o => hilo_temp_o,
		cnt_o		=> cnt_o,
		hilo_temp_i => hilo_temp_i,
		cnt_i		=> cnt_i,
		stallreq	=> stallreq_from_ex,
		
		-- this auxiliary output signals are used for division 
		signed_div_o => signed_div,
		div_opdata1_o => div_opdata1,
		div_opdata2_o => div_opdata2,
		div_start_o	  => div_start,
		
		is_in_delay_slot_i	=> ex_is_in_delayslot_i,
		link_address_i		=> ex_link_address_i
	);
	
	inst_ex_mem	: ex_mem
	port map(
		clk			=> clk,
		rst			=> rst,
		
		stall		=> stall,
		
		ex_wd		=> ex_wd_o,
		ex_wreg		=> ex_wreg_o,
		ex_wdata	=> ex_wdata_o,
		
		ex_whilo	=> ex_whilo_o,
		ex_hi		=> ex_hi_o,
		ex_lo		=> ex_lo_o,
		
		mem_whilo	=> mem_whilo_i,
		mem_hi		=> mem_hi_i,
		mem_lo		=> mem_lo_i,
		
		mem_wd		=> mem_wd_i,
		mem_wreg	=> mem_wreg_i,
		mem_wdata	=> mem_wdata_i,
		
		hilo_i		=> hilo_temp_o,
		cnt_i		=> cnt_o,
		
		hilo_o		=> hilo_temp_i,
		cnt_o		=> cnt_i
		
	);
	
	inst_mem	: mem
	port map(
		rst			=> rst,
		
		wd_i		=> mem_wd_i,
		wreg_i		=> mem_wreg_i,
		wdata_i		=> mem_wdata_i,
		
		whilo_i		=> mem_whilo_i,
		hi_i		=> mem_hi_i,
		lo_i		=> mem_lo_i,
		
		whilo_o		=> mem_whilo_o,
		hi_o		=> mem_hi_o,
		lo_o		=> mem_lo_o,
		
		wd_o		=> mem_wd_o,
		wreg_o		=> mem_wreg_o,
		wdata_o		=> mem_wdata_o
	);
	
	inst_mem_wb	: mem_wb
	port map(
		clk			=> clk,
		rst			=> rst,
		stall		=> stall,
		mem_wd		=> mem_wd_o,
		mem_wreg	=> mem_wreg_o,
		mem_wdata	=> mem_wdata_o,
		
		mem_whilo	=> mem_whilo_o,
		mem_hi		=> mem_hi_o,
		mem_lo		=> mem_lo_o,
		
		wb_whilo	=> wb_whilo_i,
		wb_hi		=> wb_hi_i,
		wb_lo		=> wb_lo_i,
		
		wb_wd		=> wb_wd_i,
		wb_wreg		=> wb_wreg_i,
		wb_wdata	=> wb_wdata_i
	);
	
	inst_hilo : hilo
	port map(
		clk			=> clk,
		rst			=> rst,
		
		we 			=> wb_whilo_i,
		hi_i		=> wb_hi_i,
		lo_i		=> wb_lo_i,
		
		hi_o		=> wb_hi_o,
		lo_o		=> wb_lo_o	
	);
	
	inst_ctrl : ctrl
	port map(
		rst 			=> rst,
		stall_from_id	=> stallreq_from_id,
		stall_from_ex	=> stallreq_from_ex,
		stall			=> stall
	);
	
	inst_div : div
	port map(
		clk			=> clk,
		rst			=> rst,
		
		signed_div_i=> signed_div,
		opdata1_i	=> div_opdata1,
		opdata2_i	=> div_opdata2,
		
		start_i		=> div_start,
		annul_i		=> '0',
		
		result_o 	=> div_result,
		ready_o		=> div_ready
	);
	

end rtl;
	
		
	
	
	
	
	