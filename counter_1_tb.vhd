library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity counter_1_tb is
end entity ; -- counter_1_tb

architecture counter_1_tb_behav of counter_1_tb is
	
	component counter_1 is
	port(p_i_clk: 		in std_logic;
		 p_i_mode: 		in std_logic_vector(1 downto 0);
		 p_i_rst: 		in std_logic;
		 p_i_end_pack:	in std_logic;
		 p_o_time: 		out std_logic_vector(31 downto 0);
		 p_i_ena:		in std_logic 	
		);
	end component;
	
	SIGNAL s_CLK:		std_logic;
	SIGNAL s_MODE:		std_logic_vector(1 downto 0);
	SIGNAL s_RST:		std_logic;
	SIGNAL s_END_PACK:	std_logic;
	SIGNAL s_TIME:		std_logic_vector (31 downto 0);
	SIGNAL s_ENA:		std_logic;

begin

	counter_1_mod: entity work.counter_1 port map (
					p_i_clk		=> s_CLK,
					p_i_mode 	=> s_MODE,
					p_i_rst 	=> s_RST,
					p_i_end_pack=> s_END_PACK,
					p_o_time 	=> s_TIME,
					p_i_ena 	=> s_ENA
					);

	process begin
		s_CLK <= '1';
		wait for 1 ns;
		s_CLK <= '0';
		wait for 1 ns;
	end process;

	process begin
		s_MODE <="01";
		s_RST <= '0';
		wait for 10 ns;
		s_RST <= '1';
		wait for 3 ns;
		s_RST <= '0';
		wait;
	end process;


	process begin
		s_END_PACK <= '0';
		wait for 100 ns;
		s_END_PACK <= '1';
		wait for 300 ns;
	end process;	

	process begin
		s_ENA <= '0';
		wait for 30 ns;
		s_ENA <= '1';
		wait;
	end process;


end architecture ; -- 
