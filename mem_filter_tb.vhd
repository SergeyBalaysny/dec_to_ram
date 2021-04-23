-- модуль оброаботки данных, записанный в стеки


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;


entity mem_filter_tb is
end entity ; -- mem_filter_tb


architecture mem_filter_tb_behav of mem_filter_tb is

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
	end component; -- mem_filter



	SIGNAL s_CLK:		std_logic;
	SIGNAL s_RST, s_ENA:std_logic;
	SIGNAL s_ADDR:		std_logic_vector(6 downto 0);
	SIGNAL s_WR_ENA, s_RD_ENA: std_logic_vector(15 downto 0);
	SIGNAL s_RD_DATA:	std_logic_vector(31 downto 0);
	SIGNAL s_WR_DATA:	std_logic_vector(31 downto 0);
	SIGNAL s_END_WORK:	std_logic;

	SIGNAL s_CONST: std_logic_vector(45 downto 0):=(others => '0');

begin

	mem_filter_module: mem_filter port map (p_i_clk		=> s_CLK,
											p_i_rst 	=> s_RST,
											p_i_ena 	=> s_ENA,
											p_o_addr 	=> s_ADDR,
											p_o_wr_ena 	=> s_WR_ENA,
											p_o_rd_ena 	=> s_RD_ENA,
											p_i_rddata 	=> s_RD_DATA,
											p_o_wrdata 	=> s_WR_DATA,
											p_o_end_work => s_END_WORK
											);


	process begin
		s_CLK <= '1';
		wait for 1 ns;
		s_CLK <= '0';
		wait for 1 ns;
	end process;

	process begin
		s_RST <= '0';
		wait for 10 ns;
		s_RST <= '1';
		wait for 4 ns;
		s_RST <= '0';
		wait;
	end process;

	process begin
		s_ENA <= '0';
		wait for 20 ns;
		s_ENA <= '1';
		wait until s_END_WORK = '1';
		s_ENA <= '0';
		wait;
	end process;

	process begin
		s_RD_DATA <= (others => 'Z');
		wait until s_RD_ENA(0) = '1';
		s_RD_DATA <= X"000000"&"00110011";
		wait until s_RD_ENA(0) = '0';
		s_RD_DATA <= (others => 'Z');

		wait until s_RD_ENA(0) = '1';
		s_RD_DATA <= X"000000"&"01111010";
		wait until s_RD_ENA(0) = '0';
		s_RD_DATA <= (others => 'Z');
		
		s_RD_DATA <= (others => 'Z');
		wait until s_RD_ENA(0) = '1';
		s_RD_DATA <= X"000000"&"10110011";
		wait until s_RD_ENA(0) = '0';
		s_RD_DATA <= (others => 'Z');

		wait until s_RD_ENA(0) = '1';
		s_RD_DATA <= X"000000"&"11111010";
		wait until s_RD_ENA(0) = '0';
		s_RD_DATA <= (others => 'Z');

		wait until s_RD_ENA(0) = '1';
		s_RD_DATA <= X"000000"&"00000000";
		--wait until s_RD_ENA(0) = '0';
		--s_RD_DATA <= (others => 'Z');

		wait;
	end process;


end architecture ; -- 