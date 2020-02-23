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
		wreg_o		: out std_ulogic		-- write enable signal
		
		
		
	);
end entity id;

architecture rtl of id is 
 
	signal op 		: std_ulogic_vector(5 downto 0);
	signal op2 		: std_ulogic_vector(4 downto 0);
	signal op3 		: std_ulogic_vector(5 downto 0);
	signal op4 		: std_ulogic_vector(4 downto 0);
	
	signal imm		: std_ulogic_vector(RegBus - 1 downto 0);
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
	inst_decode_prc : process(rst,inst_i,op)
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
			wreg_o		<= '0';
			instvalid	<= '0';
				
			reg1_read_o	<= '0';
			reg2_read_o	<= '0';
				
			reg1_addr_o	<= inst_i(25 downto 21);
			reg2_addr_o	<= inst_i(20 downto 16);
				
			imm			<= (others => '0');
			case op is
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
					
				when others =>
					null;
			end case;		
		end if;
	end process inst_decode_prc;
	
	------------------------------------------------------------------
	-- determin the second source operand 1 
	------------------------------------------------------------------
	
	determin_1_op : process(rst,reg1_read_o,reg1_data_i,imm)
	begin
		
		if(rst = '0') then
			reg1_o	<= (others => '0');
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
	
	determin_2_op : process(rst,reg2_read_o,reg2_data_i,imm)
	begin
		
		if(rst = '0') then
			reg2_o	<= (others => '0');
		elsif(reg2_read_o = '1') then
			reg2_o <= reg2_data_i;
		elsif(reg2_read_o = '0') then
			reg2_o <= imm;
		else
			reg2_o	<= (others => '0');
		end if;
		
		
	end process determin_2_op;
end rtl;