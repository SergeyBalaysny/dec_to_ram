library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;


entity counter_tb is
end entity ; -- counter_tb

architecture counter_tb_behav of counter_tb is

	 component counter is
	  	port ( 	p_i_clk:		in std_logic;
	  			p_i_rst:		in std_logic;
	  			p_o_time:		out std_logic_vector(31 downto 0)
	  	) ;
	end component ; -- counter

	SIGNAL s_CLK:	std_logic;
	SIGNAL s_RST:	std_logic;
	SIGNAL s_TIME:	std_logic_vector(31 downto 0);

begin

	counter_mod: entity work.counter port map (
									p_i_clk	=> s_CLK,
									p_i_rst => s_RST,
									p_o_time => s_TIME
									);

	process begin
		s_CLK <= '1';
		wait for 1 ns;
		s_CLK <= '0';
		wait for 1 ns;
	end process;

	s_RST <= '0';

end architecture ; -- co