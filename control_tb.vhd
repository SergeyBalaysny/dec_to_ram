library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_tb is
end entity ; -- control_tb

architecture control_tb_behav of control_tb is

	component control is
	  port(	
	 -- периферия	
	  		p_i_clk:		in std_logic;
	  		p_i_btn_run:	in std_logic;
	  		p_i_rg_off:		in std_logic;
	  		p_i_rg_cont:	in std_logic;
	  		p_i_rg_pack:	in std_logic;
	  		
	-- детекторы
			p_o_dec_stop:	out std_logic;		-- сигнал остановки работы детекторов
			p_o_dec_rst:	out std_logic; 		-- сигнгал сброса детекторов
	-- счетчик
			p_o_cnt_rst:	out std_logic; 		-- сигнал сброса счетчика времени
			p_i_cnt_ena:	in std_logic;		-- сигнал завершения сброса памяти
	-- генератор
			p_o_gen_rst:	out std_logic; 		-- сигнал сброса генератора импульсов
			p_o_mode:		out std_logic_vector(1 downto 0); -- режим работы генератора импульсов

			p_i_gen_end_work: in std_logic;		-- сигнал окончания работы генератора импульсов в режиме пачки
			p_i_las_imp:	in std_logic; 		-- импульс запуска лезера
	-- фильтр
			p_o_flt_rst:	out std_logic; 		-- сигнал сброса фильтра
			p_o_flt_ena:	out std_logic; 		-- сигнал разрешения работы фильтра

			p_i_flt_end_work: in std_logic; 	-- сигнал от фильтра о окончании работы
	-- выдача сигналов
			p_o_out_rst:	out std_logic;		-- сигнал сброса модулей выдачи
			p_o_out_ena:	out std_logic 		-- сигнал разрешения работы модулей выдачи
	  ) ;
	end component; -- control

	SIGNAL s_CLK:	std_logic;
	SIGNAL s_BTN_RUN: std_logic;
	SIGNAL s_INP_MODE: std_logic_vector(2 downto 0);
	SIGNAL s_DEC_STOP, s_DEC_RST:	std_logic;
	SIGNAL s_CNT_RST:	std_logic;
	SIGNAL s_GEN_RST, s_GEN_END, s_GEN_LAS: std_logic;
	SIGNAL s_GEN_MODE: std_logic_vector(1 downto 0);
	SIGNAL s_FLT_RST, s_FLT_ENA, s_FLT_END: std_logic;
	SIGNAL s_OUT_RST, s_OUT_ENA: std_logic;
	SIGNAL s_CNT_ENA:	std_logic;


begin

	control_module: control port map (	p_i_clk		=> s_CLK,
										p_i_btn_run	=> s_BTN_RUN,
										p_i_rg_off	=> s_INP_MODE(0),
										p_i_rg_cont	=> s_INP_MODE(1),
										p_i_rg_pack	=> s_INP_MODE(2),
										p_o_dec_stop=> s_DEC_STOP,
										p_o_dec_rst	=> s_DEC_RST,
										p_o_cnt_rst	=> s_CNT_RST,
										p_o_gen_rst	=> s_GEN_RST,
										p_o_mode	=> s_GEN_MODE,
										p_i_gen_end_work => s_GEN_END,
										p_i_las_imp	=> s_GEN_LAS,
										p_o_flt_rst	=> s_FLT_RST,
										p_o_flt_ena => s_FLT_ENA,
										p_i_flt_end_work => s_FLT_END,
										p_o_out_rst => s_OUT_RST,
										p_o_out_ena => s_OUT_ENA,
										p_i_cnt_ena => s_CNT_ENA
									);

	process begin
		s_CLK <= '1';
		wait for 1 ns;
		s_CLK <= '0';
		wait for 1 ns;
	end process;

	process begin
		s_BTN_RUN <= '0';
		s_INP_MODE <= "000";
		wait for 30 ns;
		s_INP_MODE <= "010";
		s_BTN_RUN <= '1';
		wait for 10 ns;
		s_BTN_RUN <= '0';
		wait;
		wait for 300 ns;
		s_BTN_RUN <= '1';
		s_INP_MODE <= "000";
		wait for 3 ns;
		s_BTN_RUN <= '0';
		wait;
	end process;


	process begin
		s_GEN_LAS <= '1';
		s_GEN_END <= '0';
		s_CNT_ENA <= '1';
		wait until s_GEN_RST = '1';
		wait for 100 ns;
		s_GEN_LAS <= '0';
		wait for 10 ns;
		s_GEN_LAS <= '1';
		wait;


	end process;

	process begin
		s_FLT_END <= '0';
		wait until s_FLT_ENA = '1';
		wait for 3 ns;
		s_FLT_END <= '1';
		wait for 3 ns;
--		s_FLT_END <= '0';
--		wait;
	end process;

end architecture ; -- arch
