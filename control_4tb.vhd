library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_4tb is
end control_4tb;

architecture control_4tb_arc of control_4tb is

	component control_4 is
 	 port (
  	-- периферия
			p_i_clk:		in std_logic;
			p_i_btn_run:	in std_logic;
  			p_i_rg_off:		in std_logic;
  			p_i_rg_cont:	in std_logic;
  			p_i_rg_pack:	in std_logic;

  	-- приемопередатчик
  			p_o_dec_rst:	out std_logic;		-- сброс приемопередачиков
  			p_o_dec_stop:	out std_logic; 		-- остановка приема приемапередаитчика
  			p_o_dec_rd_wr:	out std_logic; 		-- выбор режима работы 1 - передача / 0 - прием
  			p_o_mem_rst:	out std_logic; 		-- импульс запуска очистки памяти 
  			p_i_end_mem_rst:in std_logic;		-- сигнал окончания очистки памяти

	-- счетчик
			p_o_cnt_rst:	out std_logic; 		-- сигнал сброса счетчика времени
	
	-- генератор
			p_o_gen_rst:	out std_logic; 		-- сигнал сброса генератора импульсов
			p_o_mode:		out std_logic_vector(1 downto 0); -- режим работы генератора импульсов
			p_i_gen_end_work: in std_logic;		-- сигнал окончания работы генератора импульсов в режиме пачки
			p_i_las_imp:	in std_logic; 		-- импульс запуска лезера

	-- фильтр
			p_o_flt_rst:	out std_logic; 		-- сигнал сброса фильтра
			p_o_flt_ena:	out std_logic; 		-- сигнал разрешения работы фильтра
			p_i_flt_end_work: in std_logic 		-- сигнал от фильтра о окончании работы
  	) ;
	end component ; -- control_4

	SIGNAL s_CLK: 	std_logic;
	SIGNAL s_RUN:	std_logic;
	SIGNAL s_INP_MODE:	std_logic_vector(2 downto 0);
	SIGNAL s_DEC_RST, s_DEC_STOP, s_DEC_RW, s_DEC_MEM_RST, s_DEC_END_MEMRST: std_logic;
	SIGNAL s_CNT_RST:	std_logic;
	SIGNAL s_GEN_MODE:	std_logic_vector(1 downto 0);
	SIGNAL s_GEN_RST, s_GEN_END, s_LAS_IMP:	std_logic;
	SIGNAL s_FLT_RST, s_FLT_ENA, s_FLT_END_WORK:	std_logic;


begin

	s_INP_MODE <= "010";

	control_4_mod: control_4 port map(	p_i_clk 			=> s_CLK,
										p_i_btn_run 		=> s_RUN,
										p_i_rg_off 			=> s_INP_MODE(0),
										p_i_rg_cont			=> s_INP_MODE(1),
										p_i_rg_pack 		=> s_INP_MODE(2),
										p_o_dec_rst 		=> s_DEC_RST,
										p_o_dec_stop 		=> s_DEC_STOP,
										p_o_dec_rd_wr 		=> s_DEC_RW,
										p_o_mem_rst 		=> s_DEC_MEM_RST,
										p_i_end_mem_rst		=> s_DEC_END_MEMRST,
										p_o_cnt_rst 		=> s_CNT_RST,
										p_o_gen_rst 		=> s_GEN_RST,
										p_o_mode 			=> s_GEN_MODE,
										p_i_gen_end_work 	=> s_GEN_END,
										p_i_las_imp			=> s_LAS_IMP,
										p_o_flt_rst 		=> s_FLT_RST,
										p_o_flt_ena 		=> s_FLT_ENA,
										p_i_flt_end_work	=> s_FLT_END_WORK);

	process begin
		s_CLK <= '1';
		wait for 1 ns;
		s_CLK <= '0';
		wait for 1 ns;
	end process;

	process begin
		s_RUN <= '0';
		wait for 10 ns;
		s_RUN <= '1';
		wait for 3 ns;
		s_RUN <= '0';
		wait;
	end process;
-- сброс памяти
	process begin
		s_DEC_END_MEMRST <= '0';
		wait until s_DEC_MEM_RST = '1';
		wait for 10 ns;
		s_DEC_END_MEMRST <= '1';
		wait for 5 ns;
		s_DEC_END_MEMRST <= '0';
		wait;
	end process;

-- имитация импульса лазера
	process begin
		s_LAS_IMP  <= '1';
		wait for 50 ns;
		s_LAS_IMP <= '0';
		wait for 10 ns;
		s_LAS_IMP <= '1';
		wait;
	end process;

--окончание пработы фильтра
	process begin
		s_FLT_END_WORK <= '0' ;
		wait until s_FLT_ENA = '1';
		wait for 20 ns;
		s_FLT_END_WORK <= '1';
		wait for 10 ns;
		s_FLT_END_WORK <= '0';
		wait;
	end process;

-- окончание работы генератора в режиме выдачи пачек импульсов
		

end control_4tb_arc;
