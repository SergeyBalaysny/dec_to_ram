-- модуль оброаботки данных, записанный в стеки


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;


entity mem_filter is
	port (
			p_i_clk:		in std_logic;
			p_i_rst:		in std_logic;
			p_i_ena:		in std_logic;

			p_o_addr:		inout std_logic_vector(6 downto 0);
			p_o_wr_ena:		inout std_logic_vector(15 downto 0);
			p_o_rd_ena:		inout std_logic_vector(15 downto 0);
			p_i_rddata:		in std_logic_vector (31 downto 0);
			p_o_wrdata:		inout std_logic_vector(31 downto 0);
			p_o_end_work:	out std_logic


  ) ;
end entity ; -- mem_filter


architecture mem_filter_behav of mem_filter is

type t_state is (st_idle, st_read_data,  st_save_data, st_analyse_data, st_write_data, st_end_iter, st_mul_data, st_check_data);
SIGNAL s_FSM: t_state;

SIGNAL s_ADDR: std_logic_vector(4 downto 0);
SIGNAL s_BASE: std_logic_vector(1 downto 0);

SIGNAL s_TEMP_FRONT: std_logic_vector(31 downto 0);
SIGNAL s_TEMP_DATA: std_logic_vector(31 downto 0);
	
SIGNAL s_MEM_MOD_ADDR: std_logic_vector(15 downto 0);
SIGNAL s_COUNT:	integer := 0;
SIGNAL s_MOD_COUNT: integer := 0;

begin
	process(p_i_clk) begin
		if rising_edge(p_i_clk) then
		
		case s_FSM is
-- сигнал сброса
			when st_idle 	=>	if p_i_rst = '1' then
								
									p_o_addr <= (others => 'Z');
									p_o_wr_ena <= (others => 'Z');
									p_o_rd_ena <= (others => 'Z');
									p_o_wrdata <= (others => 'Z');
									s_ADDR <= "00000";
									s_BASE <= "00";
									s_TEMP_DATA <= X"00000000";
									s_TEMP_FRONT <= X"00000000";
									
									p_o_end_work <= '0';

									s_MEM_MOD_ADDR <= (0 => '1', others => '0');
									s_COUNT <= 0;
									s_MOD_COUNT <= 0;

									s_FSM <= st_read_data;

								end if;
-- считывание данных по адресу
			when st_read_data	=>	if p_i_ena = '1' then
										p_o_addr <= s_BASE & s_ADDR;
										p_o_rd_ena <= s_MEM_MOD_ADDR;
										
										s_COUNT <= 0;

										s_FSM <= st_save_data;
									end if;
-- сохренение прочитанных данных
			when st_save_data 	=> 

										s_COUNT <= s_COUNT + 1;
										if s_COUNT >= 2 then
											s_COUNT <= 0;
											s_TEMP_DATA <= p_i_rddata;
											s_FSM <= st_analyse_data;
										end if;
										
				

-- анализ данных, прочитанных из памяти
			when st_analyse_data =>	if s_TEMP_DATA = X"00000000" then		-- если прочитанные данные равны нулю => прочитаны все данные
										p_o_addr <= (others =>'Z');
										p_o_wr_ena <= (others => 'Z');
										p_o_rd_ena <= (others => 'Z');
										p_o_wrdata <= (others => 'Z');

										if s_BASE = "11" then 				-- базовый регистр достиг максимального значения

											if s_MOD_COUNT < 15 then		-- если при этом еще не прочитали все ячейки памяти
												s_BASE <= "00";
												s_MOD_COUNT <= s_MOD_COUNT + 1;
												s_MEM_MOD_ADDR <= s_MEM_MOD_ADDR(14 downto 0) & '0';
												s_ADDR <= (others => '0');
												s_FSM <= st_read_data;
											else 							-- если обработали все ячейки памяти
												p_o_end_work <= '1';
												s_MOD_COUNT <= 0;
												s_FSM <= st_idle;
											end if;
										else 							-- базовый регистр не достиг максимального значения
											s_BASE <= s_BASE + '1';
											s_ADDR <= (others => '0');
											s_FSM <= st_read_data;
										end if;
-- КОСТЫЛЬ
									elsif s_TEMP_DATA = X"FFFFFFFE" then
										p_o_addr <= (others =>'Z');
										p_o_wr_ena <= (others => 'Z');
										p_o_rd_ena <= (others => 'Z');
										p_o_wrdata <= (others => 'Z');

										s_FSM <= st_end_iter;


									else

										if s_TEMP_DATA(0) = '1' then					-- если принятые данные соответсввуют фронту
											s_TEMP_FRONT <= s_TEMP_DATA;				-- установка текущего вронта как последнего найденного
											s_TEMP_DATA(31 downto 1) <= s_TEMP_DATA(31 downto 1) - s_TEMP_FRONT(31 downto 1); 	-- вычисление длительности паузы между импульсами

											s_FSM <= st_mul_data;

										elsif s_TEMP_DATA(0) = '0' then 				-- если принятые данные соответсвуют срезу 
											s_TEMP_DATA(31 downto 1) <= s_TEMP_DATA(31 downto 1) - s_TEMP_FRONT(31 downto 1);	-- вычисление длительности импульса

											s_FSM <= st_check_data;

										end if;
									

									end if;

	-- возможно добавить альтернативное действие при длительности мпульса больше заданного

	-- проверка принятого импульса на длительность (импульсы длинее и короче заданного времени отсеиваются)
	-- длительность импульса больше 2 мкс (80 тиков) и меньше 10 мкс (200 тиков)
			when st_check_data =>	if (s_TEMP_DATA(31 downto 1) < ("000" & X"0000050")) and (s_TEMP_DATA(31 downto 1) > ("000" & X"0000200")) then
										s_TEMP_DATA(31 downto 1) <= (others => '0');
									end if;

									s_FSM <= st_mul_data;

	-- масштабирование вычесленного времени(сдвиг на 12 разрядов влево - умножение на 8192)
			when st_mul_data 	=> 	s_TEMP_DATA(31 downto 1) <= s_TEMP_DATA(18 downto 1) & "000000000000" & s_TEMP_DATA(0);
									s_FSM <= st_write_data;

	-- запись расчитанной длительности импульса обратно в память
			when st_write_data 	=> 	p_o_addr <= s_BASE & s_ADDR;
									p_o_rd_ena <=(others => '0');
									p_o_wr_ena <= s_MEM_MOD_ADDR;
									p_o_wrdata <= s_TEMP_DATA;
									s_FSM <= st_end_iter;
-- окончание процедуры записи в память
			when st_end_iter 	=> 	s_ADDR <= s_ADDR + '1';
									p_o_wr_ena <= (others => '0');
									p_o_wrdata <= (others => 'Z');
									s_FSM <= st_read_data;

			when others 		=> 	s_FSM <= st_idle;				
		end case;	

		end if;
	end process;
end architecture ; -- 