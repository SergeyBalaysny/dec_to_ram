library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity out_port_tb is
end entity ; -- out_port_tb


architecture out_port_tb_behav of out_port_tb is

	component out_port is
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
	end component ; -- out_port


	SIGNAL s_CLK:		std_logic;
	SIGNAL s_RST:		std_logic;
	SIGNAL s_ENA:		std_logic;
	SIGNAL s_ADDR: 		std_logic_vector(4 downto 0);
	SIGNAL s_RD_ENA:	std_logic;
	SIGNAL s_DATA:		std_logic_vector(31 downto 0);
	SIGNAL s_OUT:		std_logic;
	SIGNAL s_MODE:		std_logic;
	SIGNAL s_INP:		std_logic;

begin

	out_module: out_port port map (	p_i_clk		=> s_CLK,
									p_i_rst 	=> s_RST,
									p_i_ena 	=> s_ENA,
									p_o_addr 	=> s_ADDR,
									p_o_rd_ena 	=> s_RD_ENA,
									p_i_data	=> s_DATA,
									p_i_mode 	=> s_MODE,
									p_i_inp 	=> s_INP,
									p_o_port	=> s_OUT
									);


	process begin
		s_CLK <= '1';
		wait for 1 ns;
		s_CLK <= '0';
		wait for 1 ns;
	end process;

	process begin
		s_RST <= '0';
		s_ENA <= '0';
		
		wait for 10 ns;
		s_RST <= '1';
		wait for 3 ns;
		s_RST <= '0';
		wait for 10 ns;
		s_ENA <= '1';
		wait;
	end process;

	process begin
		s_DATA <= (others => 'Z');
		wait until s_RD_ENA = '1';
		s_DATA <= X"000000FF";
		wait until s_RD_ENA = '1';
		s_DATA <= X"000000F0";
		wait until s_RD_ENA = '1';
		s_DATA <= X"00000101";
		wait until s_RD_ENA = '1';
		s_DATA <= X"00000000";
		wait;
	end process;


	process begin
		s_MODE <= '0';
		s_INP <= '1';
		wait for 50 ns;
		s_INP <= '0';
		wait for 50 ns;
	end process;




end architecture ; -- arch
