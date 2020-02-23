library ieee;
use ieee.std_logic_1164.all;
use work.cpu_package.all;

entity id_ex is
	port(
		clk			: in std_ulogic;
		rst			: in std_ulogic;
		
		id_aluop	: in std_ulogic_vector(AluOpBus - 1 downto 0);
		id_alusel	: in std_ulogic_vector(AluSelBus - 1 downto 0);
		
		id_reg1		: in std_ulogic_vector(RegBus - 1 downto 0); 	-- source operand 1 
		id_reg2		: in std_ulogic_vector(RegBus - 1 downto 0); 	-- source operand 2
		
		id_wd		: in std_ulogic_vector(RegAddrBus - 1 downto 0);	-- the address of the destination register that will be written.
		id_wreg		: in std_ulogic;									-- write enable signal
		
		ex_aluop		: out std_ulogic_vector(AluOpBus - 1 downto 0);
		ex_alusel	: out std_ulogic_vector(AluSelBus - 1 downto 0);
		
		ex_reg1		: out std_ulogic_vector(RegBus - 1 downto 0); 	-- source operand 1 
		ex_reg2		: out std_ulogic_vector(RegBus - 1 downto 0); 	-- source operand 2
		
		ex_wd		: out std_ulogic_vector(RegAddrBus - 1 downto 0);	-- the address of the destination register that will be written.
		ex_wreg		: out std_ulogic									-- write enable signal
		
	);
end entity id_ex;

architecture rtl of id_ex is

begin 
	reg_prc : process(clk,rst)
	begin
		if(rst = '0') then
			ex_aluop	<= EXE_NOP_OP;
			ex_alusel	<= EXE_RES_NOP;
			ex_reg1		<= (others => '0');
			ex_reg2		<= (others => '0');
			
			ex_wd		<= (others => '0');
			ex_wreg		<= '0';
		elsif(rising_edge(clk)) then
			ex_aluop	<= id_aluop;
			ex_alusel	<= id_alusel;
			ex_reg1		<= id_reg1;
			ex_reg2		<= id_reg2;
			
			ex_wd		<= id_wd;
			ex_wreg		<= id_wreg;
		end if;
	end process reg_prc;
	
end rtl;










