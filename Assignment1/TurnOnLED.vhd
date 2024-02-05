library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Entity declaration
entity TurnOnLED is
    Port ( LEDG0 : out STD_LOGIC );  -- Assuming LEDG0 is the LED you want to control
end TurnOnLED;

-- Architecture body
architecture Behavioral of TurnOnLED is
begin
    LEDG0 <= '1';  -- Turn on the LED by setting the pin high
end Behavioral;
