library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_4 is
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
  			p_i_end_out:	in std_logic;		-- сигнал заврешенния выдачи на импульсов на внешние порты приемопередатчиками

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
end entity ; -- control_4

architecture  control_4_behav of control_4 is

	SIGNAL s_COUNT: 	integer;

	SIGNAL s_LASER_FILTER:	std_logic_vector(3 downto 0);
	SIGNAL s_BTN_RUN_FILTER: std_logic_vector(3 downto 0);
	SIGNAL s_RUN_BTN_FLAG: std_logic := '0';

	SIGNAL s_MODE:	std_logic_vector(1 downto 0):="00";

	SIGNAL s_FIRST_RUN_FLAG: std_logic := '0';


	type t_state is (st_idle, st_mem_rst, st_wait_end_mem_rst, st_end_rst, st_wait_las_imp, st_wait_after_las_imp, st_wait_end_filter, st_wait_end_out,
						st_wait_end_gen, st_dec_rst, st_wait_start_mem_rst);
	SIGNAL s_FSM: t_state;


begin

	process(p_i_clk) begin
		if rising_edge(p_i_clk) then

			s_BTN_RUN_FILTER <= p_i_btn_run & s_BTN_RUN_FILTER(3 downto 1);
			s_LASER_FILTER <= p_i_las_imp & s_LASER_FILTER(3 downto 1);

-- определение нажатия кнопки запуск
			if s_BTN_RUN_FILTER(0) = '1' and s_BTN_RUN_FILTER(1) = '0' then
				s_RUN_BTN_FLAG <= '1';
			end if;


			case s_FSM is
-- по нажатию кнопки запуска
					when st_idle =>	if s_RUN_BTN_FLAG = '1' then
									-- определение нового режима работы
										if p_i_rg_off = '1' and p_i_rg_pack = '0' and p_i_rg_cont = '0' then
											s_MODE <= "00";
										elsif p_i_rg_off = '0' and p_i_rg_pack = '0' and p_i_rg_cont = '1' then
											s_MODE <= "01";
										elsif p_i_rg_off = '0' and p_i_rg_pack = '1' and p_i_rg_cont = '0' then
											s_MODE <= "10";
										else
											s_MODE <= "00";
										end if;
									
										s_COUNT <= 0;
									-- приемопередатчик - сброс
										p_o_dec_rst <= '1';
										p_o_dec_stop <= '0';
										p_o_mem_rst <= '0';
										p_o_dec_rd_wr <= '0';
									-- генератор - ожидание сброса
										p_o_gen_rst <= '0';
									-- счетчик - сброс
										p_o_cnt_rst <= '1';
									-- фильтр - сброс/ ожидание разрешения
										p_o_flt_rst <= '1';
										p_o_flt_ena <= '0';

										--s_FSM <= st_mem_rst;
										s_FSM <= st_dec_rst;

									elsif s_MODE = "01" then
										p_o_dec_rst <= '1';
										p_o_dec_rd_wr <= '0';
										p_o_dec_stop <= '0';
										p_o_cnt_rst <= '1';
										p_o_flt_rst <= '1';
										p_o_flt_ena <= '0';
										p_o_cnt_rst <= '1';
										s_FSM <= st_wait_las_imp;

									elsif s_MODE = "10" then
										p_o_cnt_rst <= '0';
										s_FSM <= st_wait_end_gen;
										

									end if;
-- сброс приемопередатчиков
					when st_dec_rst => s_COUNT <= s_COUNT + 1;
										if s_COUNT >= 2 then
											s_COUNT <= 0;
											p_o_dec_rst <= '0';
											p_o_mode <= s_MODE;
											s_FSM <= st_mem_rst;
										end if;

-- запуск сброса памяти
					when st_mem_rst => 	p_o_dec_rst <= '0';  
										p_o_mem_rst <= '1';
										p_o_dec_rd_wr <= '0';
										

										s_FSM <= st_wait_start_mem_rst;

					when st_wait_start_mem_rst => 	if p_i_end_mem_rst = '1' then
														p_o_mem_rst <= '0';
														p_o_cnt_rst <= '0';
														s_FSM <= st_wait_end_mem_rst;
													end if;		
-- ожидание окончания сброса памяти
					when st_wait_end_mem_rst =>	if p_i_end_mem_rst = '0' then
												-- перевод детектора в режим приема входных данных
													s_FSM <= st_end_rst;
													p_o_dec_rst <= '1';
													p_o_dec_rd_wr <= '0';
												-- если была нажата кнопка запуска, после сброса памяти происходит установка нового режима рботы генератора
													if s_RUN_BTN_FLAG = '1' then
														-- снятие флага нажатия кнопки
														s_RUN_BTN_FLAG <= '0';
														-- установка нового режима работы генератора
														s_COUNT <= 0;
													
														p_o_gen_rst <= '1';
													end if;

													s_FSM <= st_end_rst;
												end if;
-- удержание сигналов сброса два такта
					when st_end_rst 	=> 	s_COUNT <= s_COUNT + 1;
											if s_COUNT >= 2 then
												s_COUNT <= 0;
												p_o_dec_rst <= '0';
												p_o_gen_rst <= '0';
												s_FSM <= st_idle;

											end if;

-- ожидание импульса запуска лазера
					when st_wait_las_imp =>	if s_LASER_FILTER(0) = '1' and s_LASER_FILTER(1) = '0' then
										-- при появлении сигнала лазера на выходе генератора импульсов
										-- разрешение работы модулям приемоепердатчика в режиме приема и счетчика
												p_o_flt_rst <= '0';
												p_o_dec_rst <= '0';		
												p_o_cnt_rst <= '0';
												s_COUNT <= 0;
												s_FSM <= st_wait_after_las_imp;		-- задержка для приема переднего и заднего фронтов ответного импльса
											end if;
-- задержка
					when st_wait_after_las_imp =>	s_COUNT <= s_COUNT + 1;
													if s_COUNT >= 550  and s_COUNT < 552 then	-- 20 тиков - время за которое гарантированно должны прийти передний и задний фронты импульса
														p_o_dec_stop <= '1';					-- после чего принудительно имитируем запись заднего фронта сигнала
													elsif s_COUNT >= 552 then
														p_o_dec_stop <= '0';
														p_o_dec_rst <= '1';
													--	p_o_dec_rd_wr <= '1';
														p_o_cnt_rst <= '1';

														p_o_flt_ena <= '1';

														s_COUNT <= 0;
														s_FSM <= st_wait_end_filter;
													end if;
-- запуск модуля обработки принятых данных
					when st_wait_end_filter =>	if p_i_flt_end_work = '1' then
													p_o_flt_ena <= '0';
													p_o_dec_rst <= '0';
													p_o_dec_rd_wr <= '1';
													p_o_flt_rst <= '1';
													s_FSM <= st_wait_end_out;
												end if;
												
-- ожидание окончания выдачи импульсов на выходные порты
					 when st_wait_end_out =>	if p_i_end_out = '1' then
					 								p_o_dec_rst <= '1';
					 								if s_MODE = "10" then
					 									s_MODE <= "00";
					 									s_FSM <= st_idle;
					 								else
					 									s_FSM <= st_dec_rst;
					 								end if;
					 							end if;

--  ожидание сигнала окончния работы генератора импульсов
					when st_wait_end_gen =>	if p_i_gen_end_work = '1' then
												p_o_flt_rst <= '0';
												p_o_dec_rst <= '0';		
												s_COUNT <= 0;
												s_FSM <= st_wait_after_las_imp;		-- задержка для приема переднего и заднего фронтов ответного импльса
											else
												s_FSM <= st_idle;
											end if;
											

													 	 
					when others => s_FSM <= st_idle;

			end case;


		end if;
	end process;


end architecture ; --  