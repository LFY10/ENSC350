library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debouncer is
	port( btn:		in std_logic;	--buttum selected 
			rst:	in std_logic;		--reset buttum KEY(3)
			CLOCK_50:in std_logic;
			btn_clock:out std_logic);-- buttom react 
end debouncer; 

architecture rtl of debouncer is
	SIGNAL slow_clk: std_logic := '0';
	signal wait_count: unsigned(18 downto 0) := (others => '0');
begin
	btn_clock <= slow_clk;
	
	process(CLOCK_50, btn, rst)
	begin
		if(rst = '0') then
			slow_clk <= '1';
			wait_count <= (others => '0');
		elsif (rising_edge(CLOCK_50)) then	
			if (wait_count = 0) then	-- Check if wating has completed.
				-- Check for a state change in the debounced signal.
				if (btn /= slow_clk) then	-- 
					-- Update the debounced signal to match the current input state.
					slow_clk <= not(slow_clk);
					-- Reset the wating time to start the debounce period.
					wait_count <= to_unsigned(5000000, 19); --0.1s
				end if;
			else
				wait_count <= wait_count - 1;
			end if;
		end if;
	 end process;
end rtl;