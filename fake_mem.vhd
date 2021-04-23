library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fake_mem is
  port (
			p_i_clk:	in std_logic;
			p_i_addr:	in std_logic_vector(6 downto 0);
			p_i_data:	in std_logic_vector(30 downto 0);
			p_i_fb:		in std_logic;
			p_o_data:	out std_logic_vector(31 downto 0);
			p_i_rd:		in std_logic;
			p_i_wr:		in std_logic
  ) ;
end entity ; -- fake_mem


architecture fake_mem_behav of fake_mem is


	type t_mem is array (127 downto 0) of std_logic_vector (31 downto 0);
	SIGNAL s_MEM: t_mem;

	SIGNAL s_RD_FILTER: std_logic_vector(3 downto 0);
	SIGNAL s_WR_FILTER:	std_logic_vector(3 downto 0);

begin
	process(p_i_clk) begin
		if rising_edge(p_i_clk) then

			s_RD_FILTER <= p_i_rd & s_RD_FILTER(3 downto 1);
			s_WR_FILTER <= p_i_wr & s_WR_FILTER(3 downto 1);


			if p_i_rd = '1' then --s_RD_FILTER(0) = '0' and s_RD_FILTER(1) = '1' then
				
				p_o_data <= s_MEM(to_integer(IEEE.NUMERIC_STD.unsigned(p_i_addr)));

			elsif p_i_wr = '1' then --s_WR_FILTER(0) = '0' and s_WR_FILTER(1) = '1' then
				
				s_MEM(to_integer(IEEE.NUMERIC_STD.unsigned(p_i_addr))) <= p_i_data(30 downto 0) & p_i_fb;

			end if;

		end if;
	end process;



end architecture ; -- 