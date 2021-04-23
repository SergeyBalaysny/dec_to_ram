--модуль счетчика временм работы модуля считает тики, выдает количество тиков по запросу (типа времени)
--вести счет по десяткам, чтобы сократить разрядность переменной для хранения времени

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity counter_1 is
	port(p_i_clk: 		in std_logic;
		 p_i_mode: 		in std_logic_vector(1 downto 0);
		 p_i_rst: 		in std_logic;
		 p_i_end_pack:	in std_logic;
		 p_o_time: 		out std_logic_vector(31 downto 0);
		 p_i_ena:		in std_logic 									
		);
end counter_1;

architecture counter_behav of counter_1 is
	signal s_count:		std_logic_vector(31 downto 0) := (others => '0');
	signal s_int_72:	integer range 0 to 72 :=0;
	signal s_end_pack_filter: std_logic_vector(3 downto 0);
begin

	
	process(p_i_clk)
		--variable v_count: integer;
	begin
		if rising_edge(p_i_clk) then
			s_end_pack_filter <= p_i_end_pack & s_end_pack_filter(3 downto 1);

			if s_end_pack_filter(0) = '1' and s_end_pack_filter(1) = '0' then
				s_int_72 <= 0;
			end if;

			if p_i_rst='1' then
				p_o_time <= (others => 'Z');
				s_count <= (others => '0');
				s_int_72 <= 0;

			elsif p_i_rst = '0' then

				p_o_time <= s_count;

				if (p_i_mode = "01" or (p_i_mode = "10" and p_i_end_pack = '0')) and p_i_ena = '0'  then
					s_count <= s_count + '1';

				elsif p_i_mode = "10" and p_i_end_pack = '1' and p_i_ena = '0' then
					s_int_72 <= s_int_72 + 1;

					if s_int_72 = 71 then
						s_int_72 <= 0;
						s_count <= s_count + '1';
					end if;
				elsif p_i_ena = '1'  then
					s_count <= (others => '0');

				end if;
			end if;


				
		end if;
	end process;
	

end architecture;
