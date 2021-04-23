library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;


entity out_port is
  port(	p_i_clk:		in std_logic;
  		p_i_rst:		in std_logic;
  		p_i_ena:		in std_logic;
  		p_o_addr:		inout std_logic_vector(4 downto 0);
  		p_o_rd_ena:		inout std_logic;
  		p_i_data:		in std_logic_vector(31 downto 0);
  		p_i_mode:		in std_logic;
  		p_i_inp:		in std_logic;
  		p_o_port: 		out std_logic
  ) ;
end entity ; -- out_port


architecture out_port_behav of out_port is
	
	SIGNAL s_TEMP: 	std_logic_vector(31 downto 0);
	SIGNAL s_ADDR: 	std_logic_vector(4 downto 0);
	SIGNAL s_FB:	std_logic;
	SIGNAL s_COUNT: integer range 0 to 3;

	type t_state is (st_idle, st_read_data, st_save_data, st_an_data, st_out_data);
	SIGNAL s_FSM: t_state;

begin

	process(p_i_clk) begin
		if rising_edge(p_i_clk) then

		if p_i_rst = '0' and p_i_mode = '0' then
			p_o_port <= p_i_inp;
		else


			case s_FSM is
-- инициализация
				when st_idle	=> 	if p_i_rst = '1' then
										s_TEMP <= (others => '0');
										s_ADDR <= "00000";
										p_o_addr <= (others => 'Z');
										p_o_rd_ena <= 'Z';
										s_FB <= '0';
										p_o_port <= '1';

										s_FSM <= st_read_data;

									end if;
-- выставление адреса и сигнала разрешения чтения по сигналу разрешения
				when st_read_data => 	if p_i_ena = '1' then
											p_o_addr <= s_ADDR;
											p_o_rd_ena <= '1';
											s_COUNT <= 0;
											s_FSM <= st_save_data;
										end if;
-- сохранение прочитанных данных
				when st_save_data => 	s_COUNT <= s_COUNT + 1;
										if s_COUNT >= 2 then
											s_TEMP <= p_i_data;
											s_FSM <= st_an_data;
										end if;

-- проверка прочитанных данных на нулевое значение (окончание чтения данных)
				when st_an_data =>	if s_TEMP = X"00000000" then
										p_o_addr <= "ZZZZZ";
										p_o_rd_ena <= 'Z';
										p_o_port <= '1';
										s_FSM <= st_idle;
									else
										s_FB <= s_TEMP(1);
										s_FSM <= st_out_data;
									end if;
-- выдача сигнала в на внешний порт, тип сигнала определяется младшим битом прочитанных данных
-- длительность сигннала - значение прочитанных данных
				when st_out_data => if s_TEMP(31 downto 2) = X"0000000"&"00" then
										s_ADDR <= s_ADDR + '1';
										p_o_rd_ena <= 'Z';
										p_o_port <= '1';
										s_FSM <= st_read_data;
									else
										s_TEMP(31 downto 2) <= s_TEMP(31 downto 2) - '1';
										p_o_port <= s_FB;
										s_FSM <= st_out_data;
									end if;

				when others 	=> s_FSM <= st_idle;
			end case;


		end if;
		end if;
	end process;

end architecture ; -- 
