library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;


--entity dec_to_ram_tb is
--end entity ; -- dec_to_ram_tb


architecture dec_to_ram_tb_behav of dec_to_ram_tb is

	component dec_to_ram is
	port (	p_CLK:			    in 	std_logic;


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
	end component ; -- dec_to_ram_tb
		

	SIGNAL s_CLK:		std_logic;
	SIGNAL s_MODE:		std_logic_vector(3 downto 0);
	SIGNAL s_BTN:		std_logic;
	SIGNAL s_LAS:		std_logic;
	SIGNAL s_GEN:		std_logic;
	SIGNAL s_INP1:		std_logic_vector(63 downto 0) := X"FFFFFFFFFFFFFFFE";
	SIGNAL s_INP:		std_logic_vector(63 downto 0) := (others => '1');
	SIGNAL s_OUT:		std_logic_vector(63 downto 0);
	SIGNAL s_BTN_UP:	std_logic;
	SIGNAL s_BTN_DWN:	std_logic;

begin

	s_BTN_DWN <= '0';
	s_BTN_UP <= '0';
	s_MODE <= "0010";
	--s_MODE <= "0000";


	dec_to_ram_mod: entity work.dec_to_ram port map(p_CLK 					=> s_CLK,
													p_EXT_INP_PORT_VECTOR0 	=> s_INP(15 downto 0),
													p_EXT_INP_PORT_VECTOR1 	=> s_INP(31 downto 16),
													p_EXT_INP_PORT_VECTOR2 	=> s_INP(47 downto 32),
													p_EXT_INP_PORT_VECTOR3 	=> s_INP(63 downto 48),

													p_EXT_OUT_PORT_VECTOR0 	=> s_OUT(15 downto 0),
													p_EXT_OUT_PORT_VECTOR1 	=> s_OUT(31 downto 16),
													p_EXT_OUT_PORT_VECTOR2 	=> s_OUT(47 downto 32),
													p_EXT_OUT_PORT_VECTOR3 	=> s_OUT(63 downto 48),

													p_EXT_CNTRL_BUTTON_OFF 	=> s_MODE(0),
													p_EXT_CNTRL_BUTTON_CONT => s_MODE(1),
													p_EXT_CNTRL_BUTTON_FOUR => s_MODE(2),
													p_EXT_CNTRL_BUTTON_SIX 	=> s_MODE(3),
													p_EXT_CNTRL_BUTTON_RUN 	=> s_BTN,
													p_EXT_GEN_BUTTON_UP 	=> s_BTN_UP,
													p_EXT_GEN_BUTTON_DWN 	=> s_BTN_DWN,

													p_EXT_IMP_LASER 		=> s_LAS,
													p_EXT_IMP_GEN 			=> s_GEN
										);

	process begin
		s_CLK <= '1';
		wait for 1 ns;
		s_CLK <= '0';
		wait for 1 ns;
	end process;

	process begin
		s_BTN <= '0';
		wait for 10 ns;
		s_BTN <= '1';
		wait for 3 ns;
		s_BTN <= '0';
		wait;
	end process;

	process begin
		s_INP <= (others => '1');
		wait until s_LAS = '0';
		wait for 100 ns;
		s_INP <= s_INP1;
		--s_INP <= (others => '0');
		wait for 11 ns;
		s_INP1 <= s_INP1(62 downto 0) & '1';
		--s_INP(0) <= '1';
		--wait;
	end process;



end architecture ; -- arch