library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;


entity counter is
  port ( 	p_i_clk:		in std_logic;
  			p_i_rst:		in std_logic;
  			p_o_time:		out std_logic_vector(31 downto 0)
  ) ;
end entity ; -- counter


architecture counter_behav of counter is

	SIGNAL s_COUNT:	std_logic_vector(31 downto 0);

begin
	process(p_i_clk) begin
		if rising_edge(p_i_clk) then

			if p_i_rst = '1' then
				s_COUNT <= (others => '0');
				p_o_time <= (others => 'Z');
			else
				s_COUNT <= s_COUNT + '1';
				p_o_time <= s_COUNT;
			end if;

		end if;
	end process;


end architecture ; -- arch
