library ieee;
use ieee.std_logic_1164.all;

entity DisplayA_LCD is
    port(
        CLK : in std_logic;  -- External Clock
        LEDG : out std_logic_vector(7 downto 0); -- Use LEDs to indicate state
        LCD_RS : out std_logic;  -- Register Select
        LCD_EN : out std_logic;  -- Enable
        LCD_RW : out std_logic;  -- Read/Write Select
        LCD_DATA : out std_logic_vector(7 downto 0)  -- Data bus
    );
end DisplayA_LCD;

architecture Behavioral of DisplayA_LCD is
    type state_type is (INIT1, INIT2, INIT3, INIT4, DISPLAY_CHAR, DONE);
    signal state : state_type := INIT1;
    signal clk_count : integer := 0;

begin
    process(CLK)
    begin
        if rising_edge(CLK) then
            clk_count <= clk_count + 1;

            if clk_count = 50000 then  -- Arbitrary count for delay
                clk_count <= 0;

                case state is
                    when INIT1 =>
                        LEDG <= "00000001";  -- Indicate INIT1 state on LEDs
                        LCD_RS <= '0';
                        LCD_RW <= '0';
                        LCD_EN <= '1';
                        LCD_DATA <= "00111000";  -- Function Set
                        state <= INIT2;

                    when INIT2 =>
                        LEDG <= "00000010";  -- Indicate INIT2 state on LEDs
                        LCD_EN <= '1';
                        LCD_DATA <= "00001100";  -- Display ON
                        state <= INIT3;

                    when INIT3 =>
                        LEDG <= "00000100";  -- Indicate INIT3 state on LEDs
                        LCD_EN <= '1';
                        LCD_DATA <= "00000001";  -- Clear Display
                        state <= INIT4;

                    when INIT4 =>
                        LEDG <= "00001000";  -- Indicate INIT4 state on LEDs
                        LCD_EN <= '1';
                        LCD_DATA <= "00000110";  -- Entry Mode Set
                        state <= DISPLAY_CHAR;

                    when DISPLAY_CHAR =>
                        LEDG <= "00010000";  -- Indicate DISPLAY_CHAR state on LEDs
                        LCD_RS <= '1';
                        LCD_EN <= '1';
                        LCD_DATA <= "01000001";  -- ASCII for 'A'
                        state <= DONE;

                    when DONE =>
                        LEDG <= "00100000";  -- Indicate DONE state on LEDs
                        -- State to indicate completion. No further action.
                        null;

                    when others =>
                        state <= INIT1;
                end case;
            end if;
        end if;
    end process;
end Behavioral;
