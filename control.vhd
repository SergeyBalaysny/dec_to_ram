library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control is
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
end entity ; -- control

architecture control_behav of control is
	
	SIGNAL s_COUNT: 	integer;

	SIGNAL s_LASER_FILTER:	std_logic_vector(3 downto 0);
	SIGNAL s_BTN_RUN_FILTER: std_logic_vector(3 downto 0);
	SIGNAL s_RUN_BTN_FLAG: std_logic := '0';

	SIGNAL s_MODE:	std_logic_vector(1 downto 0):="00";

	SIGNAL s_FIRST_RUN_FLAG: std_logic := '0';


	type t_state is (st_idle, st_set_gen_mode, st_all_on, st_wait_las_imp, st_wait_after_las_imp, st_wait_end_filter, st_delay_before_rst_dec, st_wait_mem_rst);
	SIGNAL s_FSM: t_state;

begin

	process(p_i_clk) begin
		if rising_edge(p_i_clk) then

			s_BTN_RUN_FILTER <= p_i_btn_run & s_BTN_RUN_FILTER(3 downto 1);
			s_LASER_FILTER <= p_i_las_imp & s_LASER_FILTER(3 downto 1);

			if s_BTN_RUN_FILTER(0) = '1' and s_BTN_RUN_FILTER(1) = '0' then
				s_RUN_BTN_FLAG <= '1';
			end if;


			case s_FSM is

				when st_idle =>	if s_RUN_BTN_FLAG = '1' then

									if p_i_rg_off = '1' and p_i_rg_pack = '0' and p_i_rg_cont = '0' then
										s_MODE <= "00";
									elsif p_i_rg_off = '0' and p_i_rg_pack = '0' and p_i_rg_cont = '1' then
										s_MODE <= "01";
									elsif p_i_rg_off = '0' and p_i_rg_pack = '1' and p_i_rg_cont = '0' then
										s_MODE <= "10";
									else
										s_MODE <= "00";
									end if;

									s_RUN_BTN_FLAG <= '0';
									s_COUNT <= 0;

									p_o_dec_rst <= '1';
									p_o_cnt_rst <= '1';
									p_o_out_rst <= '1';
									p_o_flt_rst <= '1';

									p_o_flt_ena <= '0';
									p_o_out_ena <= '0';

									s_FSM <= st_set_gen_mode;

								elsif s_MODE = "01" then
									s_COUNT <= 0;
									s_FSM <= st_wait_las_imp;
								elsif s_FIRST_RUN_FLAG = '0' then

									p_o_dec_rst <= '1';
									p_o_cnt_rst <= '1';
									p_o_out_rst <= '1';
									p_o_flt_rst <= '1';
									p_o_gen_rst <= '0';

									p_o_flt_ena <= '0';
									p_o_out_ena <= '0';
									p_o_dec_stop <= '0';
									p_o_mode <= "00";

									s_FIRST_RUN_FLAG <= '1';
								end if;



--установка режима работы генератора импульсов
				when st_set_gen_mode => p_o_gen_rst <= '1';		-- установка режима работы генератора импульсов
										p_o_mode <= s_MODE;
										s_COUNT <= s_COUNT + 1;

										if s_COUNT >= 2 then	-- выждержка времени удержания импульса усброса	
											s_COUNT <= 0;
											p_o_gen_rst <= '0';

											if s_MODE = "00" then	-- если установка режима выключения
												p_o_out_rst <= '0';
												s_FSM <= st_idle;   -- переход в состояние ожидания нажатия кнопки
											else
												if s_MODE = "10" then
													p_o_dec_rst <= '0';
													p_o_cnt_rst <= '0';
													s_FSM <= st_all_on; -- ожидаем импульс лазера
												else 
													s_FSM <= st_wait_las_imp;
												end if;
												
											end if;
										end if;


				when st_all_on	=> if p_i_cnt_ena = '1' then
										p_o_flt_rst <= '0';
										p_o_out_rst <= '0';
										s_FSM <= st_wait_las_imp;
									end if;


-- ожидание импульса запуска лазера
				when st_wait_las_imp => if s_LASER_FILTER(0) = '1' and s_LASER_FILTER(1) = '0' then
											s_COUNT <= 0;
											if s_MODE = "01" then
												p_o_dec_rst <= '1';
												p_o_cnt_rst <= '1';
												p_o_out_rst <= '1';
												p_o_flt_rst <= '1';

												p_o_flt_ena <= '0';
												p_o_out_ena <= '0';

												s_FSM <= st_delay_before_rst_dec;
											else
												s_FSM <= st_wait_after_las_imp;
											end if;
										end if;

-- задержка для формирования сигнала сброса детекторов непрерывном режиме работы
				when st_delay_before_rst_dec => s_COUNT <= s_COUNT + 1;
												if s_COUNT >= 2 then
													s_COUNT <= 0;
													p_o_dec_rst <= '0';
													p_o_cnt_rst <= '0';
													
													s_FSM <= st_wait_mem_rst;
													
												end if;
-- оджидание сброса памяти
				when st_wait_mem_rst 	=> if p_i_cnt_ena = '1' then
												p_o_out_rst <= '0';
												p_o_flt_rst <= '0';
												s_FSM <= st_wait_after_las_imp;
											end if;

-- подача сигнала завершения приема на детекторы для принудителной записи в память времени заднего фронта в случае, если передний фронт поступил на вход 
-- детектора, а задний не появился в заданное время
				when st_wait_after_las_imp =>	s_COUNT <= s_COUNT + 1;

												if s_COUNT >=100 and s_COUNT < 102 then
													p_o_dec_stop <= '1';
												elsif s_COUNT >= 102 then	
													p_o_dec_stop <= '0';


													if (s_MODE = "10" and p_i_gen_end_work = '1') or s_MODE = "01" then
														p_o_flt_ena <= '1';
														p_o_cnt_rst <= '1';
														s_FSM <= st_wait_end_filter;
													elsif s_MODE = "10" and p_i_gen_end_work = '0' then
														s_FSM <= st_wait_las_imp;	
													end if;
												end if;
														
				when st_wait_end_filter =>	if p_i_flt_end_work = '1' then
												p_o_out_ena <= '1';

												s_FSM <= st_idle;

											end if;


				when others 	=> s_FSM <= st_idle;



			end case;



		end if;
	end process;


end architecture ; -- arch