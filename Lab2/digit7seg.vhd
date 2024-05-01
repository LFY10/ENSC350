LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY digit7seg IS
    PORT(
        digit : IN  UNSIGNED(3 DOWNTO 0); -- number 0 to 0xF
        seg7 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) -- one per segment
    );
END digit7seg;

ARCHITECTURE behavioral OF digit7seg IS
BEGIN
    -- Mapping the input digit to the 7-segment display output
    WITH digit SELECT
        seg7 <= "1000000" WHEN "0000", -- 0
                "1111001" WHEN "0001", -- 1
                "0100100" WHEN "0010", -- 2
                "0110000" WHEN "0011", -- 3
                "0011001" WHEN "0100", -- 4
                "0010010" WHEN "0101", -- 5
                "0000010" WHEN "0110", -- 6
                "1111000" WHEN "0111", -- 7
                "0000000" WHEN "1000", -- 8
                "0011000" WHEN "1001", -- 9
                "0001000" WHEN "1010", -- A
                "0000011" WHEN "1011", -- b
                "1000110" WHEN "1100", -- C
                "0100001" WHEN "1101", -- d
                "0000110" WHEN "1110", -- E
                "0001110" WHEN "1111", -- F
                "1111111" WHEN OTHERS; -- Default case (optional, for safety)
END behavioral;
