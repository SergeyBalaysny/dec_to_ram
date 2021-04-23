library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity channel_imp_module2_tb is
end entity ; -- channel_imp_module2_tb



architecture channel_imp_module2_tb_behav of channel_imp_module2_tb is

	component channel_imp_module2 is
	  port (
	  			p_clk:				in std_logic;			
	  			p_imp:				in std_logic;						-- входной импульс
	  			p_i_rst:			in std_logic;						-- сигнал сброса
	  			p_i_stop:			in std_logic; 						-- сигнал ококнчания проверки
	  			p_o_addr:			inout std_logic_vector(4 downto 0); -- текущий адрес памяти
	  			p_o_frontback:		out std_logic;						-- бит перезнего - 1 /заднего - 0 фронтов
	  			p_o_wren:			inout std_logic; 					-- сигнал разрешения записи
	  			p_o_rst_ena:		out std_logic 							-- сигнал 1 модуль в процессе сброса ппмяти, 0 - сброс памяти окончен
	  ) ;
	end component ; -- channel_imp_module

	SIGNAL s_CLK: 	std_logic;
	SIGNAL s_ADDR:	std_logic_vector(4 downto 0);
	SIGNAL s_FRONTBACK: std_logic;
	SIGNAL s_WREN:	std_logic;
	SIGNAL s_RST:	std_logic;
	SIGNAL s_END:	std_logic;
	SIGNAL s_RST_ENA:	std_logic;

	SIGNAL s_IN_IMP:	std_logic;

begin
		channel_imp_module2_mod: channel_imp_module2 port map (	p_clk	=> s_CLK,
																p_imp	=> s_IN_IMP,
																p_i_rst => s_RST,
																p_i_stop => s_END,
																p_o_addr => s_ADDR,
																p_o_frontback => s_FRONTBACK,
																p_o_wren => s_WREN,
																p_o_rst_ena => s_RST_ENA
																);



		process begin
			s_CLK <= '1';
			wait for 1 ns;
			s_CLK <= '0';
			wait for 1 ns;
		end process;



		process begin
			s_RST<= '0';
			wait for 10 ns;
			s_RST <= '1';
			wait for 2 ns;
			s_RST <= '0';
			wait;
		end process;


		process begin
			s_IN_IMP <= '1';
			wait for 300 ns;
			s_IN_IMP <= '0';
			wait for 10 ns;
			s_IN_IMP <= '0';
			wait;

		end process;


		process begin
			s_END <= '0';
			wait for 500 ns;
			s_END <= '1';
			wait for 3 ns;
			s_END <= '0';
			wait;
		end process;


end architecture ; -- arch
