LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY win IS
    PORT(
        spin_result_latched : in unsigned(5 downto 0);  -- Winning number, 0 to 36
        bet1_value : in unsigned(5 downto 0);           -- Bet on a specific number
        bet2_colour : in std_logic;                     -- Bet on color, '1' for red, '0' for black
        bet3_dozen : in unsigned(1 downto 0);           -- Bet on a dozen: "00", "01", "10"
        bet1_wins : out std_logic;                      -- Outcome of bet 1
        bet2_wins : out std_logic;                      -- Outcome of bet 2
        bet3_wins : out std_logic                       -- Outcome of bet 3
    );
END win;

ARCHITECTURE behavioural OF win IS
    SIGNAL color_result : std_logic;  -- Holds the color result for comparison in bet 2
BEGIN
    -- Bet 1 Logic: Win if the bet number matches the spin result
    bet1_wins <= '1' WHEN spin_result_latched = bet1_value ELSE '0';

    -- Bet 2 Logic: Determine the color of the spin result
    -- Red numbers are explicitly listed; all others are considered black
    -- The spin result of 0 is a special case and does not match either color bet
    PROCESS(spin_result_latched)
    BEGIN
        IF spin_result_latched = "000000" THEN  -- Special handling for 0
            color_result <= 'X';  -- 'X' indicates a non-red/non-black result, handling the green 0
        ELSIF spin_result_latched = "000001" OR spin_result_latched = "000011" OR spin_result_latched = "000101" OR
              spin_result_latched = "000111" OR spin_result_latched = "001001" OR spin_result_latched = "001100" OR
              spin_result_latched = "001110" OR spin_result_latched = "010000" OR spin_result_latched = "010011" OR
              spin_result_latched = "010111" OR spin_result_latched = "011001" OR spin_result_latched = "011011" OR
              spin_result_latched = "011101" OR spin_result_latched = "100000" OR spin_result_latched = "100010" OR
              spin_result_latched = "100100" THEN
            color_result <= '1';  -- Red
        ELSE
            color_result <= '0';  -- Black
        END IF;
    END PROCESS;

    -- Bet 2 Wins: Check if the bet matches the color result. Special handling for spin result of 0.
    bet2_wins <= '0' WHEN color_result = 'X' ELSE  -- No win if spin result is 0
                 '1' WHEN bet2_colour = color_result ELSE '0';

    -- Bet 3 Logic: Win based on the dozen bet
    bet3_wins <= '1' WHEN (spin_result_latched >= "000001" AND spin_result_latched <= "001100" AND bet3_dozen = "00") OR
                          (spin_result_latched >= "001101" AND spin_result_latched <= "011000" AND bet3_dozen = "01") OR
                          (spin_result_latched >= "011001" AND spin_result_latched <= "100100" AND bet3_dozen = "10") ELSE '0';
END behavioural;
