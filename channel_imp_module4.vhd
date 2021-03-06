library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity channel_imp_module4 is
	port(
			p_i_clk:		in std_logic;
			p_i_rst:		in std_logic;						-- сброс

			p_i_imp0:		in std_logic;						-- вход 0
			p_i_imp1:		in std_logic; 						-- вход 1
			p_i_imp2:		in std_logic;						-- вход 2
			p_i_imp3:		in std_logic;						-- вход 3

			p_i_stop:		in std_logic;						-- сигнал окончания детектирования входных импульсов
			p_i_mode:		in std_logic;						-- режим прямой передачи входа на выход
			p_i_out_ena:	in std_logic;						-- разрешение выдачи сигнала

			p_o_addr:		inout std_logic_vector(6 downto 0);	-- адрес памяти
			p_o_frontback: 	out std_logic;						-- сигнал переднего/заднего фронта принимаемого импульса
			p_o_wren:		inout std_logic;					-- разрешение записи в память
			p_o_rden:		inout std_logic;					-- разрешение чтения из памяти
			p_i_data:		in std_logic_vector(31 downto 0); 	-- данные для памяти

			p_o_out0:		out std_logic;						-- выход 0
			p_o_out1:		out std_logic; 						-- выход 1
			p_o_out2:		out std_logic;						-- выход 2
			p_o_out3:		out std_logic;						-- выход 3

			p_o_end_out:	out std_logic;						-- окончание выдачи даных в режиме выдачи

			p_i_mem_rst:	in std_logic;						-- запрос на обнуление памяти
			p_o_mem_rst_end:out std_logic 						-- подтверждение сброса пямяти
		);
end entity ; -- channel_imp_module4

architecture channel_imp_module4_behav of channel_imp_module4 is

	SIGNAL s_IMP0_FILTER:	std_logic_vector(3 downto 0);
	SIGNAL s_IMP1_FILTER:	std_logic_vector(3 downto 0);
	SIGNAL s_IMP2_FILTER:	std_logic_vector(3 downto 0);
	SIGNAL s_IMP3_FILTER:	std_logic_vector(3 downto 0);


	SIGNAL s_ADDR0, s_ADDR1, s_ADDR2, s_ADDR3: std_logic_vector(4 downto 0);
	SIGNAL s_TEMP_ADDR:	std_logic_vector(7 downto 0);

	SIGNAL s_FB: std_logic_vector(3 downto 0);
	SIGNAL s_E: std_logic_vector(3 downto 0);

	SIGNAL s_STOP_FLAG: std_logic;

	SIGNAL s_TEMP0, s_TEMP1, s_TEMP2, s_TEMP3: std_logic_vector(31 downto 0);

	SIGNAL s_MEM_RST_FLAG: std_logic;
	SIGNAL s_END_MEM_MASK: std_logic_vector(3 downto 0);

	type t_state is (st_idle, st_read_mem, st_save_0, st_save_1, st_save_2, st_save_3, st_out_imp, st_delay0, st_delay1, st_delay2, st_delay3);
	SIGNAL s_FSM: t_state;

	SIGNAL s_OUT_ENA_FILTER: std_logic_vector (3 downto 0);
	SIGNAL s_OUT_ENA_FLAG: std_logic;



	--SIGNAL s_BTN_FILTER: std_logic_vector(3 downto 0);

	
begin
	process(p_i_clk) begin
		if rising_edge(p_i_clk) then

			--s_BTN_FILTER <= p_btn1 & s_BTN_FILTER(3 downto 1);

			if p_i_mem_rst = '1' then
				s_MEM_RST_FLAG <= '1';
			end if;

			s_OUT_ENA_FILTER <= p_i_out_ena & s_OUT_ENA_FILTER(3 downto 1);

			if s_OUT_ENA_FILTER(1) = '1' and s_OUT_ENA_FILTER(0) = '0' then
				s_OUT_ENA_FLAG <= '1';
			end if;


			if p_i_rst = '1' then 
				s_ADDR0 <= (others => '0');
				s_ADDR1 <= (others => '0');
				s_ADDR2 <= (others => '0');
				s_ADDR3 <= (others => '0');		

				s_FB <= "0000";
				s_E <= "0000";

				p_o_wren <= 'Z';
				p_o_rden <= 'Z';

				s_STOP_FLAG <= '0';

				p_o_out0 <= '1';
				p_o_out1 <= '1';
				p_o_out2 <= '1';
				p_o_out3 <= '1';

				s_TEMP0 <= (others => '0');
				s_TEMP1 <= (others => '0');
				s_TEMP2 <= (others => '0');
				s_TEMP3 <= (others => '0');

				p_o_mem_rst_end <= '0';
				s_TEMP_ADDR <= "00000000";
				s_MEM_RST_FLAG <='0';

				p_o_end_out <= '0';

				s_OUT_ENA_FLAG <= '0';

			else

-- в режиме прямой связи входов с выходами
				if p_i_mode = '0' then 

					p_o_out0 <= p_i_imp0;
					p_o_out1 <= p_i_imp1;
					p_o_out2 <= p_i_imp2;
					p_o_out3 <= p_i_imp3;

					p_o_addr <= (others => 'Z');
					p_o_rden <= 'Z';
					p_o_wren <= 'Z';
					p_o_frontback <= '0';
					p_o_mem_rst_end <= '1';

				else
		-- прием выходных импульсов по отсутствию сигнала сброса
					s_IMP0_FILTER <= p_i_imp0 & s_IMP0_FILTER(3 downto 1);
					s_IMP1_FILTER <= p_i_imp1 & s_IMP1_FILTER(3 downto 1);
					s_IMP2_FILTER <= p_i_imp2 & s_IMP2_FILTER(3 downto 1);
					s_IMP3_FILTER <= p_i_imp3 & s_IMP3_FILTER(3 downto 1);

					if p_i_stop = '1' then 
						s_STOP_FLAG <= '1';
					end if;

		-- фиксация информации о принятых импульсах
					if s_IMP0_FILTER(0) = '1' and s_IMP0_FILTER(1) = '0' then 
						s_FB(0) <= '1';
						s_E(0) <= '1';
					elsif s_IMP0_FILTER(0) = '0' and s_IMP0_FILTER(1) = '1' then 
						s_FB(0) <= '0';
						s_E(0) <= '1';
					end if;

					if s_IMP1_FILTER(0) = '1' and s_IMP1_FILTER(1) = '0' then 
						s_FB(1) <= '1';
						s_E(1) <= '1';
					elsif s_IMP1_FILTER(0) = '0' and s_IMP1_FILTER(1) = '1' then 
						s_FB(1) <= '0';
						s_E(1) <= '1';
					end if;


					if s_IMP2_FILTER(0) = '1' and s_IMP2_FILTER(1) = '0' then 
						s_FB(2) <= '1';
						s_E(2) <= '1';
					elsif s_IMP2_FILTER(0) = '0' and s_IMP2_FILTER(1) = '1' then 
						s_FB(2) <= '0';
						s_E(2) <= '1';
					end if;


					if s_IMP3_FILTER(0) = '1' and s_IMP3_FILTER(1) = '0' then 
						s_FB(3) <= '1';
						s_E(3) <= '1';
					elsif s_IMP3_FILTER(0) = '0' and s_IMP3_FILTER(1) = '1' then 
						s_FB(3) <= '0';
						s_E(3) <= '1';
					end if;

 		-- режим приемника входных импульсов и записи их в память
 					if p_i_out_ena = '0' and s_MEM_RST_FLAG = '0' then

 						if s_STOP_FLAG = '1' then
							p_o_rden <= '0';
							p_o_frontback <= '0';

							if s_E(0) = '1' then
								p_o_wren <= '1';
								p_o_addr <= "00" & s_ADDR0;
								s_E(0) <= '0';
							elsif s_E(1) = '1' then
								p_o_wren <= '1';
								p_o_addr <= "01" & s_ADDR1;
								s_E(1) <= '0';
							elsif s_E(2) = '1' then
								p_o_wren <= '1';
								p_o_addr <= "10" & s_ADDR2;
								s_E(2) <= '0';
							elsif s_E(3) = '1' then
								p_o_wren <= '1';
								p_o_addr <= "11" & s_ADDR3;
								s_E(3) <= '0';
							else 
								s_STOP_FLAG <= '0';
							end if;

						else
							p_o_rden <= '0';
							if s_E(0) = '1' then
								p_o_addr <= "00" & s_ADDR0;
								s_ADDR0 <= s_ADDR0 + '1';
								p_o_wren <= '1';
								s_E(0) <= '0';
								p_o_frontback <= s_FB(0);
							elsif s_E(1) = '1' then
								p_o_addr <= "01" & s_ADDR1;
								s_ADDR1 <= s_ADDR1 + '1';
								p_o_wren <= '1';
								s_E(1) <= '0';
								p_o_frontback <= s_FB(1);
							elsif s_E(2) = '1' then
								p_o_addr <= "10" & s_ADDR2;
								s_ADDR2 <= s_ADDR2 + '1';
								p_o_wren <= '1';
								s_E(2) <= '0';
								p_o_frontback <= s_FB(2);
							elsif s_E(3) = '1' then
								p_o_addr <= "11" & s_ADDR3;
								s_ADDR3 <= s_ADDR3 + '1';
								p_o_wren <= '1';
								s_E(3) <= '0';
								p_o_frontback <= s_FB(3);
							else
								p_o_addr <= (others => 'Z');
								p_o_wren <= '0';
								p_o_frontback <= '0';
							end if;

						end if;
-- режим сброса памяти
					elsif p_i_out_ena = '0' and s_MEM_RST_FLAG = '1' then	
						if s_TEMP_ADDR = "10000000" then
						 	s_MEM_RST_FLAG <= '0';
						 	p_o_wren <= '0';
						 	p_o_mem_rst_end <= '0';
						else
							p_o_wren <= '1';
							p_o_mem_rst_end <= '1';
							p_o_addr <= s_TEMP_ADDR(6 downto 0);
							s_TEMP_ADDR <= s_TEMP_ADDR + '1';
						end if;
						 	
-- режим выдачи импульсов из памяти
					elsif  p_i_out_ena = '1' and s_MEM_RST_FLAG = '0' then					

						case s_FSM is
		-- начальное состояние
							when st_idle => 	if s_OUT_ENA_FLAG = '1' and s_MEM_RST_FLAG = '0' then
													p_o_wren <= '0';
													p_o_rden <= '0';
													p_o_addr <= (others => 'Z');
													s_END_MEM_MASK <= "0000";
													s_E <= "1111";
													s_FSM <= st_read_mem;
												end if;

							when st_read_mem =>	if s_END_MEM_MASK(0) = '0' and s_E(0) = '1' then
													p_o_rden <= '1';
													p_o_addr <= "00" & s_ADDR0;
													
													s_FSM <= st_delay0;
												elsif s_END_MEM_MASK(1) = '0' and s_E(1) = '1' then
													p_o_rden <= '1';
													p_o_addr <= "01" & s_ADDR1;
													
													s_FSM <= st_delay1;
												elsif s_END_MEM_MASK(2) = '0' and s_E(2) = '1' then
													p_o_rden <= '1';
													p_o_addr <= "10" & s_ADDR2;
													
													s_FSM <= st_delay2;

												elsif s_END_MEM_MASK(3) = '0' and s_E(3) = '1' then
													p_o_rden <= '1';
													p_o_addr <= "11" & s_ADDR3;
													s_FSM <= st_delay3;

												elsif s_END_MEM_MASK = "1111" then 
													p_o_end_out <= '1';
													s_OUT_ENA_FLAG <= '0';
													s_FSM <= st_idle;
												else
													s_FSM <= st_out_imp;
												end if;

							when st_delay0 => 	p_o_rden <= '0';
												s_ADDR0 <= s_ADDR0 + '1';
												s_FSM <= st_save_0;

							when st_delay1 => 	p_o_rden <= '0';
												s_ADDR1 <= s_ADDR1 + '1';
												s_FSM <= st_save_1;

							when st_delay2 => 	p_o_rden <= '0';
												s_ADDR2 <= s_ADDR2 + '1';
												s_FSM <= st_save_2;

							when st_delay3 => 	p_o_rden <= '0';
												s_ADDR3 <= s_ADDR3 + '1';
												s_FSM <= st_save_3;



							when st_save_0 =>	s_E(0) <= '0';
												p_o_addr <= (others => 'Z');
											 	if p_i_data(31 downto 2) = X"0000000"&"00" then
													s_END_MEM_MASK(0) <= '1';
													s_FSM <= st_read_mem;

												elsif p_i_data = X"FFFFFFFE" then
													s_E(0) <= '1';
													s_FSM <= st_read_mem;



												else
													s_TEMP0 <= p_i_data;
													s_FSM <= st_out_imp;
												end if;

							when st_save_1 =>	s_E(1) <= '0';
												p_o_addr <= (others => 'Z');
											 	if p_i_data(31 downto 2) = X"0000000"&"00" then
													s_END_MEM_MASK(1) <= '1';
													s_FSM <= st_read_mem;

												elsif p_i_data = X"FFFFFFFE" then
													s_E(1) <= '1';
													s_FSM <= st_read_mem;	

												else
													s_TEMP1 <= p_i_data;
													s_FSM <= st_out_imp;
												end if;

							when st_save_2 =>	s_E(2) <= '0';
												p_o_addr <= (others => 'Z');
											 	if p_i_data(31 downto 2) = X"0000000"&"00" then
													s_END_MEM_MASK(2) <= '1';
													s_FSM <= st_read_mem;

												elsif p_i_data = X"FFFFFFFE" then
													s_E(2) <= '1';
													s_FSM <= st_read_mem;

												else
													s_TEMP2 <= p_i_data;
													s_FSM <= st_out_imp;
												end if;

							when st_save_3 =>	s_E(3) <= '0';
												p_o_addr <= (others => 'Z');
											 	if p_i_data(31 downto 2) = X"0000000"&"00" then
													s_END_MEM_MASK(3) <= '1';
													s_FSM <= st_read_mem;
													
												elsif p_i_data = X"FFFFFFFE" then
													s_E(3) <= '1';
													s_FSM <= st_read_mem;

												else
													s_TEMP3 <= p_i_data;
													s_FSM <= st_out_imp;
												end if;

							when st_out_imp => 	--if s_BTN_FILTER(0) = '1' and s_BTN_FILTER(1) = '0' then 
													if s_TEMP0(31 downto 2) = X"0000000"&"00" then
														s_E(0) <= '1';
														p_o_out0 <= '1';
													else
														s_TEMP0(31 downto 2) <= s_TEMP0(31 downto 2) - '1';
														p_o_out0 <= not s_TEMP0(1);
													end if;

													if s_TEMP1(31 downto 2) = X"0000000"&"00" then
														s_E(1) <= '1';
														p_o_out1 <= '1';
													else
														s_TEMP1(31 downto 2) <= s_TEMP1(31 downto 2) - '1';
														p_o_out1 <= not s_TEMP1(1);
													end if;

													if s_TEMP2(31 downto 2) = X"0000000"&"00" then
														s_E(2) <= '1';
														p_o_out2 <= '1';
													else
														s_TEMP2(31 downto 2) <= s_TEMP2(31 downto 2) - '1';
														p_o_out2 <= not s_TEMP2(1);
													end if;

													if s_TEMP3(31 downto 2) = X"0000000"&"00" then
														s_E(3) <= '1';
														p_o_out3 <= '1';
													else
														s_TEMP3(31 downto 2) <= s_TEMP3(31 downto 2) - '1';
														p_o_out3 <= not s_TEMP3(1);
													end if;
													s_FSM <= st_read_mem;
												--end if;
													
							when others => 	s_FSM <= st_idle;
						end case;
										
					end if;

				end if;

			end if;

		end if;
	end process;


end architecture ; -- arch
