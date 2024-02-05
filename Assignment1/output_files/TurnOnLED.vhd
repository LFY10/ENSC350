library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity TurnOnLED is
    port(
        clk : in std_logic;  -- System clock
        LCD_RW : out std_logic;  -- LCD read/write control
        LCD_RS : out std_logic;  -- LCD register select
        LCD_E : out std_logic;  -- LCD enable
        LCD_DATA : out std_logic_vector(7 downto 0)  -- LCD data bus
    );
end TurnOnLED;

architecture Behavioral of TurnOnLED is
    type state_type is (power_up, initialize, display_char, done);
    signal state: state_type := power_up;
    signal clk_count: integer := 0;
    constant freq: integer := 100; -- System clock frequency in MHz
begin
    process(clk)
    begin
        if rising_edge(clk) then
            case state is
                when power_up =>
                    -- Wait for enough time for LCD power-up
                    if clk_count < (50000 * freq) then
                        clk_count <= clk_count + 1;  -- Corrected assignment
                    else
                        clk_count <= 0;  -- Corrected assignment
                        state := initialize;
                    end if;

                when initialize =>
                    -- Initialize the LCD in 2-line mode
                    if clk_count = 0 then
                        LCD_DATA <= "00111000"; -- Function set: 2 lines
                        LCD_RS <= '0';
                        LCD_RW <= '0';
                        LCD_E <= '1';
                        clk_count := clk_count + 1;
                    elsif clk_count < (4100 * freq) then
                        LCD_E <= '0'; -- Enable low
                        clk_count := clk_count + 1;
                    else
                        clk_count := 0;
                        state := display_char;
                    end if;

                when display_char =>
                    -- Display the character 'A'
                    if clk_count = 0 then
                        LCD_DATA <= "01000001"; -- ASCII for 'A'
                        LCD_RS <= '1';
                        LCD_RW <= '0';
                        LCD_E <= '1';
                        clk_count := clk_count + 1;
                    elsif clk_count < (4100 * freq) then
                        LCD_E <= '0'; -- Enable low
                        clk_count := clk_count + 1;
                    else
                        state := done;
                    end if;

                when done =>
                    -- Done, do nothing
                    null;
            end case;
        end if;
    end process;
end Behavioral;
