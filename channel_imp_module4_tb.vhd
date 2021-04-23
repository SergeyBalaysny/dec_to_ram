library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity channel_imp_module4_tb is
end entity ; -- channel_imp_module4_tb

architecture channel_imp_module4_tb_behav of channel_imp_module4_tb is

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
	end component ; -- channel_imp_module4

	SIGNAL s_CLK:			std_logic;
	SIGNAL s_IMP:			std_logic_vector(3 downto 0);
	SIGNAL s_RST, s_STOP:	std_logic;
	SIGNAL s_ADDR:			std_logic_vector(6 downto 0);
	SIGNAL s_WR, s_RD, s_FB:std_logic;
	SIGNAL s_MODE, s_RD_WR:	std_logic;
	SIGNAL s_DATA:			std_logic_vector(31 downto 0);
	SIGNAL s_OUT:			std_logic_vector(3 downto 0);

	SIGNAL s_MEM_RST:		std_logic;
	SIGNAL s_MEM_RST_END:	std_logic;

	SIGNAL s_END_OUT:		std_logic;


begin

s_MODE <= '1';
s_RD_WR <= '0';
--s_MEM_RST <= '0';
--s_DATA <= (others => '0');


	channel_imp_module4_mod: channel_imp_module4 port map (
						p_i_clk 	=> s_CLK,
						p_i_rst 	=> s_RST,
						p_i_imp0 	=> s_IMP(0),
						p_i_imp1 	=> s_IMP(1),
						p_i_imp2	=> s_IMP(2),
						p_i_imp3 	=> s_IMP(3),

						p_i_stop	=> s_STOP,
						p_i_mode	=> s_MODE,
						p_i_out_ena => s_RD_WR,

						p_o_addr 	=> s_ADDR,
						p_o_frontback => s_FB,
						p_o_wren 	=> s_WR,
						p_o_rden 	=> s_RD,

						p_i_data 	=> s_DATA,

						p_o_out0 	=> s_OUT(0),
						p_o_out1	=> s_OUT(1),
						p_o_out2 	=> s_OUT(2),
						p_o_out3	=> s_OUT(3),

						p_o_end_out => s_END_OUT,

						p_i_mem_rst => s_MEM_RST,
						p_o_mem_rst_end => s_MEM_RST_END
						);

	process begin
		s_CLK <= '1';
		wait for 1 ns;
		s_CLK <= '0';
		wait for 1 ns;
	end process;

	process begin
		s_RST <= '0';
		s_STOP <= '0';
		wait for 10 ns;
		s_RST <= '1';
		wait for 3 ns;
		s_RST <= '0';
		wait;
	end process;

--	process begin
--		s_RD_WR <= '0';
--		wait for 20 ns;
--		s_RD_WR <= '1';
--		wait until s_END_OUT = '1';
--		s_RD_WR <= '0';
--		wait;
--	end process;


	process begin
		s_MEM_RST <= '0';
		wait for 20 ns;
		s_MEM_RST <= '1';
		wait until s_MEM_RST_END = '1';
		s_MEM_RST <= '0';
		wait;
	end process;


--	process begin
--		s_IMP <= "1111";
--		wait for 20 ns;
--		s_IMP <= "1110";
--		wait for 10 ns;
--		s_IMP <= "1100";
--		wait for 40 ns;
--		s_IMP <= "1111";
--		wait;
--	end process;

--	process begin
	--0-f
--		s_DATA <= (others => '0');
--		wait until s_RD = '1';
--		s_DATA <= X"000000F0";
		--wait until s_RD = '0';
		--s_DATA <= (others => '0');
	-- 1-f
--		wait until s_RD = '1';
--		s_DATA <= X"00000000";
		--wait until s_RD = '0';
		--s_DATA <= (others => '0');
	-- 2-f
--		wait until s_RD = '1';
--		s_DATA <= X"00000000";
		--wait until s_RD = '0';
		--s_DATA <= (others => '0');
	-- 3-f
--		wait until s_RD = '1';
--		s_DATA <= X"00000000";
		--wait until s_RD = '0';
		--s_DATA <= (others => '0');
	-- 0-b
--		wait until s_RD = '1';
--		s_DATA <= X"0000000F";
		--wait until s_RD = '0';
		--s_DATA <= (others => '0');
	-- 1-b
--		wait until s_RD = '1';
--		s_DATA <= X"00000000";
		--wait until s_RD = '0';
		--s_DATA <= (others => '0');
	-- 2-b
--		wait until s_RD = '1';
--		s_DATA <= X"00000000";
		--wait until s_RD = '0';
		--s_DATA <= (others => '0');
	-- 3-b
--		wait until s_RD = '1';
--		s_DATA <= X"00000000";
		--wait until s_RD = '0';

--		wait for 10 ns;
--		s_DATA <= (others => '0');

--		wait;
--	end process;
end architecture ; -- arch
