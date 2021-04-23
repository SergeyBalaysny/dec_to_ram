
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

-- библиотека для работы со встроенной в микросхему памятью
-- восстановить при синтезе в квартусе
--
-- LIBRARY altera_mf;
-- USE altera_mf.altera_mf_components.all;


entity dec_to_ram is
	port (
			p_CLK:			    in 	std_logic;

	-- входные порты
			p_EXT_INP_PORT_VECTOR0:	in std_logic_vector(15 downto 0);
			p_EXT_INP_PORT_VECTOR1:	in std_logic_vector(15 downto 0);
			p_EXT_INP_PORT_VECTOR2:	in std_logic_vector(15 downto 0);
			p_EXT_INP_PORT_VECTOR3:	in std_logic_vector(15 downto 0);

	-- выходные порты
			p_EXT_OUT_PORT_VECTOR0:	out std_logic_vector(15 downto 0);
			p_EXT_OUT_PORT_VECTOR1:	out std_logic_vector(15 downto 0);
			p_EXT_OUT_PORT_VECTOR2:	out std_logic_vector(15 downto 0);
			p_EXT_OUT_PORT_VECTOR3:	out std_logic_vector(15 downto 0);
			
	-- кнопки, переключатели
			p_EXT_CNTRL_BUTTON_OFF: 	in	std_logic;		-- положение переключателя "ВЫКЛ"
			p_EXT_CNTRL_BUTTON_CONT: 	in	std_logic;		-- положение переключателя "ВНЕШ"
			p_EXT_CNTRL_BUTTON_FOUR: 	in std_logic;		-- положение переключателя "6КГЦ"
			p_EXT_CNTRL_BUTTON_SIX:		in std_logic;		-- положение переключателя "ПАЧКА"
			p_EXT_CNTRL_BUTTON_RUN: 	in	std_logic;		-- кнопка "ЗАПУСК"
			p_EXT_GEN_BUTTON_UP:		in	std_logic;		-- кнопка "+10НС"
			p_EXT_GEN_BUTTON_DWN:		in	std_logic;		-- кнопка "-10НС"
			
	-- сигналы запуска блока и генератора
			p_EXT_IMP_LASER:			out std_logic;
			p_EXT_IMP_GEN:				out std_logic
			
);
end entity ; -- dec_to_ram_tb



architecture dec_to_ram_tb_behav of dec_to_ram is

-- модуль приема и записи в память
	component channel_imp_module4 is
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
	end component; -- channel_imp_module4

-- счетчик времени
	component counter_1 is
	port(p_i_clk: 		in std_logic;
		 p_i_mode: 		in std_logic_vector(1 downto 0);
		 p_i_rst: 		in std_logic;
		 p_i_end_pack:	in std_logic;
		 p_o_time: 		out std_logic_vector(31 downto 0);
		 p_i_ena:		in std_logic 			
		);
	end component;

-- генератор импульсов
	component gen
	port (
			clk:					in std_logic;
			p_in_rst: 				in std_logic;
			imp_laser:				out std_logic;
			imp_gen:				out std_logic;
			sgn_up_delay:			in std_logic;
			sgn_dwn_delay:			in std_logic;
			p_in_select_mode: 		in std_logic_vector(1 downto 0);
			p_out_strobe_end_test: 	out std_logic;
			p_end_pack:				out std_logic
		);
	end component;

-- модуль обработки данных
	component mem_filter is
	port (	p_i_clk:		in std_logic;
			p_i_rst:		in std_logic;
			p_i_ena:		in std_logic;

			p_o_addr:		inout std_logic_vector(6 downto 0);
			p_o_wr_ena:		inout std_logic_vector(15 downto 0);
			p_o_rd_ena:		inout std_logic_vector(15 downto 0);
			p_i_rddata:		in std_logic_vector (31 downto 0);
			p_o_wrdata:		inout std_logic_vector(31 downto 0);
			p_o_end_work:	out std_logic
	  ) ;
	end component;


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
			p_i_flt_end_work: in std_logic 		-- сигнал от фильтра о окончании  о окончании работы
  	) ;
	end component ; -- control_4




	component fake_mem is
  	port (
			p_i_clk:	in std_logic;
			p_i_addr:	in std_logic_vector(6 downto 0);
			p_i_data:	in std_logic_vector(30 downto 0);
			p_i_fb:		in std_logic;
			p_o_data:	out std_logic_vector(31 downto 0);
			p_i_rd:		in std_logic;
			p_i_wr:		in std_logic
	  ) ;
	end component ; -- fake_mem

	SIGNAL s_DEC_STOP:		std_logic;
	SIGNAL s_DEC_RST:		std_logic;
	SIGNAL s_GEN_RST:		std_logic;
	SIGNAL s_GEN_MODE:		std_logic_vector(1 downto 0);
	SIGNAL s_DEC_RW:		std_logic;
	SIGNAL s_DEC_END_OUT:	std_logic_vector(15 downto 0);

	SIGNAL s_ALL_DEC_END_OUT:	std_logic;

	SIGNAL s_END_GEN:		std_logic;
	SIGNAL s_LAS_IMP:		std_logic;
	SIGNAL s_GEN_IMP:		std_logic;
	SIGNAL s_FLT_RST:		std_logic;
	SIGNAL s_FLT_ENA:		std_logic;
	SIGNAL s_END_FLT:		std_logic;
	SIGNAL s_MEM_RST:		std_logic;
	SIGNAL s_OUT_ENA:		std_logic;
	SIGNAL s_CNT_RST:		std_logic;

	SIGNAL s_INP_DATA:		std_logic_vector(31 downto 0);

	SIGNAL s_DEC_END_MEM_RST:	std_logic_vector(15 downto 0);
	SIGNAL s_MEM_RST_ALL:			std_logic;

	type t_mem_data_array is array (0 to 15) of std_logic_vector(31 downto 0);
	SIGNAL s_OUT_DATA: t_mem_data_array;

	type t_mem_addr_array is array (0 to 15) of std_logic_vector(6 downto 0);
	SIGNAL s_MEM_ADDR: t_mem_addr_array;

	SIGNAL s_FLT_ADDR:	std_logic_vector(6 downto 0);
	SIGNAL s_FLT_IN_DATA:	std_logic_vector(31 downto 0);

	SIGNAL s_MEM_RD:		std_logic_vector(15 downto 0);
	SIGNAL s_MEM_WR:		std_logic_vector(15 downto 0);

	SIGNAL s_DEC_FB:		std_logic_vector(15 downto 0);
	SIGNAL s_GEN_END_PACK:	std_logic;

	SIGNAL s_OR_MODE:		std_logic;
	
begin

	p_EXT_IMP_LASER <= s_LAS_IMP;
	p_EXT_IMP_GEN <= s_GEN_IMP;
	s_MEM_ADDR <= (others => s_FLT_ADDR);

	s_OR_MODE <= s_GEN_MODE(1) or s_GEN_MODE(0);

	s_ALL_DEC_END_OUT <= '1' when s_DEC_END_OUT = X"FFFF" else '0';

	s_FLT_IN_DATA <= 	s_OUT_DATA (0) when s_MEM_RD(0) = '1' else
						s_OUT_DATA (1) when s_MEM_RD(1) = '1' else
						s_OUT_DATA (2) when s_MEM_RD(2) = '1' else
						s_OUT_DATA (3) when s_MEM_RD(3) = '1' else
						s_OUT_DATA (4) when s_MEM_RD(4) = '1' else
						s_OUT_DATA (5) when s_MEM_RD(5) = '1' else
						s_OUT_DATA (6) when s_MEM_RD(6) = '1' else
						s_OUT_DATA (7) when s_MEM_RD(7) = '1' else
						s_OUT_DATA (8) when s_MEM_RD(8) = '1' else
						s_OUT_DATA (9) when s_MEM_RD(9) = '1' else
						s_OUT_DATA (10) when s_MEM_RD(10) = '1' else
						s_OUT_DATA (11) when s_MEM_RD(11) = '1' else
						s_OUT_DATA (12) when s_MEM_RD(12) = '1' else
						s_OUT_DATA (13) when s_MEM_RD(13) = '1' else
						s_OUT_DATA (14) when s_MEM_RD(14) = '1' else
						s_OUT_DATA (15) when s_MEM_RD(15) = '1';
						
		
		s_MEM_RST_ALL <= '0' when s_DEC_END_MEM_RST = X"0000" else '1';
	
					 

	out_gen: for i in 0 to 15 generate
		
		channel_imp_module4_mod: channel_imp_module4 port map (
																p_i_clk 	=> p_CLK,
																p_i_rst 	=> s_DEC_RST,
																p_i_imp0 	=> p_EXT_INP_PORT_VECTOR0(i),
																p_i_imp1 	=> p_EXT_INP_PORT_VECTOR1(i),
																p_i_imp2	=> p_EXT_INP_PORT_VECTOR2(i),
																p_i_imp3 	=> p_EXT_INP_PORT_VECTOR3(i),

																p_i_stop	=> s_DEC_STOP,
																p_i_mode	=> s_OR_MODE,
																p_i_out_ena => s_DEC_RW,

																p_o_addr 	=> s_MEM_ADDR(i),
																p_o_frontback => s_DEC_FB(i),
																p_o_wren 	=> s_MEM_WR(i),
																p_o_rden 	=> s_MEM_RD(i),

																p_i_data 	=> s_OUT_DATA(i),

																p_o_out0 	=> p_EXT_OUT_PORT_VECTOR0(i),
																p_o_out1	=> p_EXT_OUT_PORT_VECTOR1(i),
																p_o_out2 	=> p_EXT_OUT_PORT_VECTOR2(i),
																p_o_out3	=> p_EXT_OUT_PORT_VECTOR3(i),

																p_o_end_out => s_DEC_END_OUT(i),

																p_i_mem_rst => s_MEM_RST,
																p_o_mem_rst_end => s_DEC_END_MEM_RST(i)
						);



--		altsyncram_component : altsyncram			
--		GENERIC MAP (
--			clock_enable_input_a => "BYPASS",
--			clock_enable_output_a => "BYPASS",
--			intended_device_family => "Cyclone IV E",
--			lpm_hint => "ENABLE_RUNTIME_MOD=NO",
--			lpm_type => "altsyncram",
--			numwords_a => 32,
--			operation_mode => "SINGLE_PORT",
--			outdata_aclr_a => "NONE",
--			outdata_reg_a => "UNREGISTERED",
--			power_up_uninitialized => "FALSE",
--			read_during_write_mode_port_a => "NEW_DATA_NO_NBE_READ",
--			widthad_a => 7,
--			width_a => 32,
--			width_byteena_a => 1
--		)
--		PORT MAP (
--			address_a => s_MEM_ADDR(i),
--			clock0 => p_CLK,
--			data_a => s_INP_DATA(31 downto 1) & s_DEC_FB(i),
--			rden_a => s_MEM_RD(i),
--			wren_a => s_MEM_WR(i),
--			q_a => s_OUT_DATA(i)
--		);	

	fake_mem_mod: fake_mem port map (
			p_i_clk		=> p_CLK,
			p_i_addr	=> s_MEM_ADDR(i),
			p_i_data 	=> s_INP_DATA(31 downto 1),
			p_i_fb 		=> s_DEC_FB(i),
			p_o_data 	=> s_OUT_DATA(i),
			p_i_rd 		=> s_MEM_RD(i),
			p_i_wr 		=> s_MEM_WR(i)
	);
end generate;



	mem_filter_mod:	mem_filter port map (
									p_i_clk			=> p_CLK,
									p_i_rst			=> s_FLT_RST,
									p_i_ena 		=> s_FLT_ENA,
									p_o_addr		=> s_FLT_ADDR,
									p_o_wr_ena		=> s_MEM_WR,
									p_o_rd_ena		=> s_MEM_RD,
									p_i_rddata		=> s_FLT_IN_DATA,
									p_o_wrdata 		=> s_INP_DATA,
									p_o_end_work	=> s_END_FLT );




	counter_mod: counter_1 port map (p_i_clk 		=> p_CLK,
									p_i_rst 		=> s_CNT_RST,
									p_i_mode 		=> s_GEN_MODE,
									p_i_end_pack 	=> s_GEN_END_PACK,
									p_o_time		=> s_INP_DATA,
									p_i_ena 		=> s_MEM_RST_ALL
									);



	gen_mode: gen port map(	clk	   					=> p_CLK,
							p_in_rst 				=> s_GEN_RST,
							imp_laser 				=> s_LAS_IMP,
							imp_gen 				=> s_GEN_IMP,
							sgn_up_delay			=> p_EXT_GEN_BUTTON_UP,
							sgn_dwn_delay			=> p_EXT_GEN_BUTTON_DWN,
							p_in_select_mode		=> s_GEN_MODE,
							p_out_strobe_end_test 	=> s_END_GEN,
							p_end_pack 				=> s_GEN_END_PACK
						);


	control_4_mod: control_4 port map(	p_i_clk 			=> p_CLK,
										p_i_btn_run			=> p_EXT_CNTRL_BUTTON_RUN,
										p_i_rg_off			=> p_EXT_CNTRL_BUTTON_OFF,
										p_i_rg_cont			=> p_EXT_CNTRL_BUTTON_CONT,
										p_i_rg_pack			=> p_EXT_CNTRL_BUTTON_FOUR,
										p_o_dec_rst 		=> s_DEC_RST,
										p_o_dec_stop 		=> s_DEC_STOP,
										p_o_dec_rd_wr 		=> s_DEC_RW,
										p_o_mem_rst 		=> s_MEM_RST,
										p_i_end_mem_rst		=> s_MEM_RST_ALL,
										p_i_end_out 		=> s_ALL_DEC_END_OUT,
										p_o_cnt_rst 		=> s_CNT_RST,
										p_o_gen_rst 		=> s_GEN_RST,
										p_o_mode 			=> s_GEN_MODE,
										p_i_gen_end_work 	=> s_END_GEN,
										p_i_las_imp			=> s_LAS_IMP,
										p_o_flt_rst 		=> s_FLT_RST,
										p_o_flt_ena 		=> s_FLT_ENA,
										p_i_flt_end_work	=> s_END_FLT);


end architecture ; -- 