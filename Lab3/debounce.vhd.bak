library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debounce is
	port(btn: 			in STD_LOGIC; -- button input
		  CLOCK_50: 	in STD_LOGIC; -- 50MHz clock signal to tie debounced output to (rising edge)
		  rst:			in STD_LOGIC; -- async reset
		  debounced: 	out STD_LOGIC -- debounced output that ignores further changes for 250ms
		  );
end debounce;

architecture behaviour of debounce is
	signal cooldown: unsigned(23 downto 0) := (others => '0');
	signal output: std_logic := '1';
begin
	debounced <= output;

	process(CLOCK_50, rst, btn)
	begin
		if (rst='0') then
			output <= '1';
			cooldown <= (others => '0');
		elsif (rising_edge(CLOCK_50)) then
			if (cooldown = 0) then
				if (btn /= output) then
					output <= NOT(output);
					cooldown <= to_unsigned(12500000, 24); -- 250ms
				end if;
			else
				cooldown <= cooldown - 1;
			end if;
		end if;
	end process;
end behaviour;
