
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity imp_module_control is
  port ( 	p_i_clk:	std_logic;
  			p_o_rst:	std_logic
	
  ) ;
end entity ; -- imp_module_control

architecture imp_module_control_behav of imp_module_control is

	signal s_COUNT: integer;

begin

end architecture ; -- 