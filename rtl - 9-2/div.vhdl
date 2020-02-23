library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.cpu_package.all;

entity div is 
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
end entity div;

architecture rtl of div is
	signal div_temp		: std_ulogic_vector(32 downto 0);
	signal sub_temp		: std_ulogic_vector(32 downto 0);
	signal cnt			: std_ulogic_vector(5 downto 0);
	signal cnt_nxt		: std_ulogic_vector(5 downto 0);
	signal dividend 	: std_ulogic_vector(64 downto 0);
	signal dividend_nxt : std_ulogic_vector(64 downto 0);
	
	
	signal divisor 		: std_ulogic_vector(31 downto 0);
	signal divisor_nxt 	: std_ulogic_vector(31 downto 0);
	signal temp_op1		: std_ulogic_vector(31 downto 0);
	signal temp_op1_nxt	: std_ulogic_vector(31 downto 0);
	signal temp_op2		: std_ulogic_vector(31 downto 0);
	signal temp_op2_nxt	: std_ulogic_vector(31 downto 0);
	
	signal result_o_nxt : std_ulogic_vector(63 downto 0);
	signal ready_o_nxt	: std_ulogic;
	type state_t is (DivFree, DivByZero, DivOn, DivEnd);
	signal state		: state_t;
	signal state_nxt	: state_t;

begin
	
	div_temp <= std_ulogic_vector(unsigned('0'&dividend(63 downto 32)) - unsigned('0'&divisor));
	--div_temp <= ('0'&dividend(63 downto 32)) - ('0'&divisor);
	state_mashine : process(cnt,state,ready_o,result_o,start_i,annul_i,opdata2_i,opdata1_i,signed_div_i,temp_op1,temp_op2,div_temp,dividend,divisor)
	begin
		state_nxt 	<= state;
		ready_o_nxt <= ready_o;
		result_o_nxt<= result_o;
		cnt_nxt 	<= cnt;
		temp_op1_nxt<= temp_op1;
		temp_op2_nxt<= temp_op2;
		dividend_nxt<= dividend;
		divisor_nxt <= divisor;
		case state is 
			when DivFree =>
				if(start_i = '1' and annul_i = '0') then 
					if(opdata2_i = X"00000000") then
						state_nxt <= DivByZero;
					else
						state_nxt <= DivOn;
						dividend_nxt <= (others => '0');
						cnt_nxt	  <= (others => '0');
						if(signed_div_i = '1' and opdata1_i(31) = '1') then 
							temp_op1_nxt <= std_ulogic_vector(unsigned(not opdata1_i) + 1);
							dividend_nxt(32 downto 1) <= std_ulogic_vector(unsigned(not opdata1_i) + 1);
						else
							temp_op1_nxt <= opdata1_i;
							dividend_nxt(32 downto 1)<= opdata1_i;
						end if;
						
						if(signed_div_i = '1' and opdata2_i(31) = '1') then 
							temp_op2_nxt <= std_ulogic_vector(unsigned(not opdata2_i) + 1); 
							divisor_nxt <=std_ulogic_vector(unsigned(not opdata2_i) + 1);
						else
							temp_op2_nxt <= opdata2_i;
							divisor_nxt <= opdata2_i;
						end if;
						
						-- dividend_nxt <= (others => '0');
						-- dividend_nxt(32 downto 1) <= temp_op1;
						-- divisor_nxt <= temp_op2;
					end if;
				else
					ready_o_nxt <= '0';
					result_o_nxt<= (others => '0');
				end if;
			
			when DivByZero =>
				dividend_nxt <= (others => '0');
				state_nxt <= DivEnd;
			when DivOn =>
				if(annul_i = '0') then
					if(cnt < b"100000") then
						if(div_temp(32) = '1') then -- minuend - n < 0
							dividend_nxt <= dividend(63 downto 0)&'0';
						else
							dividend_nxt <= div_temp(31 downto 0)&dividend(31 downto 0)&'1';
						end if;
						cnt_nxt <= std_ulogic_vector(unsigned(cnt) + 1);
					else
						if(signed_div_i = '1' and opdata1_i(31) /= opdata2_i(31)) then
							dividend_nxt(31 downto 0) <= std_ulogic_vector(unsigned(not dividend(31 downto 0)) + 1);
						end if;
						
						if(signed_div_i = '1' and opdata1_i(31) /= dividend(64)) then
							dividend_nxt(64 downto 33) <= std_ulogic_vector(unsigned(not dividend(64 downto 33)) + 1);
						end if;
						
						state_nxt <= DivEnd;
						cnt_nxt <= (others => '0');
					end if;
				else
					state_nxt <= DivFree;
				end if;
			
			when DivEnd =>
				result_o_nxt <= dividend(64 downto 33)&dividend(31 downto 0);
				ready_o_nxt	 <= '1';
				if(start_i = '0') then
					state_nxt <= DivFree;
					ready_o_nxt <= '0';
					result_o_nxt <= (others => '0');
				end if;
					
			when others =>
				null;
		end case;
	end process state_mashine;
	
	reg_prc	: process(clk)
	begin
		if(rising_edge(clk)) then
			if(rst = '0') then
				state 		<= DivFree;
				ready_o 	<= '0';
				result_o 	<= (others => '0');
				cnt 		<= (others => '0');
				temp_op1 	<= (others => '0');
				temp_op2 	<= (others => '0');
				dividend	<= (others => '0');
				divisor		<= (others => '0');
			else
				state 		<= state_nxt;
				ready_o 	<= ready_o_nxt;
				result_o 	<= result_o_nxt;
				cnt 		<= cnt_nxt;
				temp_op1 	<= temp_op1_nxt;
				temp_op2 	<= temp_op2_nxt;
				dividend	<= dividend_nxt;
				divisor		<= divisor_nxt;
			end if;
		end if;
	end process reg_prc;
		
end rtl;

-- library ieee;
-- use ieee.std_logic_1164.all;
-- use ieee.numeric_std.all;

-- use work.cpu_package.all;

-- entity div is 
	-- port(
		-- clk			: in std_ulogic;
		-- rst			: in std_ulogic;
		
		-- signed_div_i: in std_ulogic;
		-- opdata1_i	: in std_ulogic_vector(31 downto 0);
		-- opdata2_i	: in std_ulogic_vector(31 downto 0);
		
		-- start_i		: in std_ulogic;
		-- annul_i		: in std_ulogic;
		
		-- result_o 	: out std_ulogic_vector(63 downto 0);
		-- ready_o		: out std_ulogic
	-- );
-- end entity div;

-- architecture rtl of div is
	-- signal div_temp		: std_ulogic_vector(32 downto 0);
	-- signal sub_temp		: std_ulogic_vector(32 downto 0);
	-- signal cnt			: std_ulogic_vector(5 downto 0);
	-- signal cnt_nxt		: std_ulogic_vector(5 downto 0);
	-- signal dividend 	: std_ulogic_vector(64 downto 0);
	-- signal dividend_nxt : std_ulogic_vector(64 downto 0);
	-- --signal state		: std_ulogic_vector(1 downto 0);
	
	-- signal divisor 		: std_ulogic_vector(31 downto 0);
	-- signal temp_op1		: std_ulogic_vector(31 downto 0);
	-- signal temp_op1_nxt	: std_ulogic_vector(31 downto 0);
	-- signal temp_op2		: std_ulogic_vector(31 downto 0);
	-- signal temp_op2_nxt	: std_ulogic_vector(31 downto 0);
	
	-- signal result_o_nxt : std_ulogic_vector(63 downto 0);
	-- signal ready_o_nxt	: std_ulogic;
	-- type state_t is (DivFree, DivByZero, DivOn, DivEnd);
	-- signal state		: state_t;
	-- signal state_nxt	: state_t;

-- begin
	
	-- div_temp <= std_ulogic_vector(unsigned('0'&dividend(63 downto 32)) - unsigned('0'&divisor));
	-- --div_temp <= ('0'&dividend(63 downto 32)) - ('0'&divisor);
	-- state_mashine : process(clk)
	-- begin
		-- if(rst = '0') then
			-- state 		<= DivFree;
			-- ready_o 	<= '0';
			-- result_o 	<= (others => '0');
			-- cnt 		<= (others => '0');
			-- temp_op1 	<= (others => '0');
			-- temp_op2 	<= (others => '0');
			-- dividend	<= (others => '0');
		-- elsif(rising_edge(clk)) then
			-- case state is 
				-- when DivFree =>
					-- if(start_i = '1' and annul_i = '0') then 
						-- if(opdata2_i = X"00000000") then
							-- state <= DivByZero;
						-- else
							-- state <= DivOn;
							-- cnt	  <= (others => '0');
							-- if(signed_div_i = '1' and opdata1_i(31) = '1') then 
								-- temp_op1 <= std_ulogic_vector(unsigned(not opdata1_i) + 1); 
								-- dividend(32 downto 1) <= std_ulogic_vector(unsigned(not opdata1_i) + 1);
							-- else
								-- temp_op1 <= opdata1_i;
								-- dividend(32 downto 1) <= opdata1_i;
							-- end if;
							
							-- if(signed_div_i = '1' and opdata2_i(31) = '1') then 
								-- temp_op2 <= std_ulogic_vector(unsigned(not opdata2_i) + 1); 
								-- divisor <= std_ulogic_vector(unsigned(not opdata2_i) + 1); 
							-- else
								-- temp_op2 <= opdata2_i;
								-- divisor <= opdata2_i;
							-- end if;
							
							-- -- dividend <= (others => '0');
							-- -- dividend(32 downto 1) <= temp_op1;
							-- -- divisor <= temp_op2;
						-- end if;
					-- else
						-- ready_o <= '0';
						-- result_o<= (others => '0');
					-- end if;
				
				-- when DivByZero =>
					-- dividend <= (others => '0');
					-- state <= DivEnd;
				-- when DivOn =>
					
					-- if(annul_i = '0') then
						-- if(cnt /= b"100000") then
							-- if(div_temp(32) = '1') then -- minuend - n < 0
								-- dividend <= dividend(63 downto 0)&'0';
							-- else
								-- dividend <= div_temp(31 downto 0)&dividend(31 downto 0)&'1';
							-- end if;
							-- cnt <= std_ulogic_vector(unsigned(cnt) + 1);
						-- else
							-- if(signed_div_i = '1' and opdata1_i(31) /= opdata2_i(31)) then
								-- dividend(31 downto 0) <= std_ulogic_vector(unsigned(not dividend(31 downto 0)) + 1);
							-- end if;
							
							-- if(signed_div_i = '1' and opdata1_i(31) /= dividend(64)) then
								-- dividend(64 downto 33) <= std_ulogic_vector(unsigned(not dividend(64 downto 33)) + 1);
							-- end if;
							
							-- state <= DivEnd;
							-- cnt <= (others => '0');
						-- end if;
					-- else
						-- state <= DivFree;
					-- end if;
				
				-- when DivEnd =>
					-- result_o <= dividend(64 downto 33)&dividend(31 downto 0);
					-- ready_o	 <= '1';
					-- if(start_i = '0') then
						-- state <= DivFree;
						-- ready_o <= '0';
						-- result_o <= (others => '0');
					-- end if;
						
				-- when others =>
					-- null;
			-- end case;
		-- end if;
	-- end process state_mashine;
	
		
-- end rtl;