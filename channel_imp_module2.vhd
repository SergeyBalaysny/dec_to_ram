library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;


entity channel_imp_module2 is
  port (
  			p_clk:				in std_logic;			
  			p_imp:				in std_logic;							-- входной импульс
  			p_i_rst:			in std_logic;							-- сигнал сброса
  			p_i_stop:			in std_logic; 							-- сигнал ококнчания проверки
  			p_o_addr:			inout std_logic_vector(4 downto 0); 	-- текущий адрес памяти
  			p_o_frontback:		out std_logic;							-- бит перезнего - 1 /заднего - 0 фронтов
  			p_o_wren:			inout std_logic; 						-- сигнал разрешения записи
  			p_o_rst_ena:		out std_logic 							-- сигнал 1 модуль в процессе сброса ппмяти, 0 - сброс памяти окончен
  ) ;
end entity ; -- channel_imp_module


architecture channel_imp_module2_behav of channel_imp_module2 is

	SIGNAL s_ADDR: 	std_logic_vector(4 downto 0);
	SIGNAL s_FRONTORBACK:	std_logic;
	SIGNAL s_INP_IMP_FILTER: std_logic_vector (3 downto 0);
	SIGNAL s_RST_FLAG:		std_logic;


begin
	
	process(p_clk) begin
		if rising_edge(p_clk) then

			s_INP_IMP_FILTER <= p_imp & s_INP_IMP_FILTER(3 downto 1);

			if p_i_rst = '1' then								-- по сигналу сбброса 			
				s_ADDR <= "00001";	 							-- установка начального адреса
				p_o_wren <= '0'; 								-- сброс бита фронта
				s_FRONTORBACK <= '0'; 							-- сброс флага фронта
				s_RST_FLAG <= '1';								-- установка флага сброса

			elsif s_RST_FLAG = '1' then							-- пока флаг сброса установлен
				if s_ADDR = "00000" then 						-- проверка на окончание перебора адресов
					s_RST_FLAG <= '0'; 			
					s_ADDR <= "00000";
					p_o_rst_ena <= '0';
				else  	
					s_ADDR <= s_ADDR + '1';						-- перебор всех адресов для заполенения их нулями
					p_o_wren <= '1';
					p_o_rst_ena <= '1';

				end if;
				p_o_addr <= s_ADDR;
			

			else 												-- режим детектирования входных сигналов

				if p_i_stop = '1' and s_FRONTORBACK = '1' then 	-- если до появления сигнала об останове не был обнаружен задний фронт
					p_o_wren <= '1'; 							-- разрешение записи в память
					p_o_addr <= s_ADDR; 						-- по текущему адресу
					p_o_frontback <= '0'; 			 			-- запись бита заднего фронта
					s_FRONTORBACK <= '0'; 						-- снятие флага переднего фронта
				else


						if s_INP_IMP_FILTER(0) = '1' and s_INP_IMP_FILTER(1) = '0' then 		-- передний фронт входного сигнала
							p_o_addr <= s_ADDR;
							p_o_frontback <= '1';
							p_o_wren<='1';
							s_FRONTORBACK<='1';
							s_ADDR <= s_ADDR + '1';
						elsif s_INP_IMP_FILTER(1) = '1' and s_INP_IMP_FILTER(0) = '0' then 		-- задний фронт входного сигнала
							p_o_addr <= s_ADDR;
							p_o_frontback <= '0';
							p_o_wren<='1';
							s_FRONTORBACK<='0';
							s_ADDR <= s_ADDR + '1';
						else
							p_o_wren <= 'Z';
							p_o_addr <= "ZZZZZ";
							p_o_frontback <= '0';
						end if;
				end if;



			end if;

		end if;
	end process;



end architecture ; -- cha