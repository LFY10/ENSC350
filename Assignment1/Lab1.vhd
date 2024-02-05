library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Lab1 is
    port(
        CLK : in std_logic;  -- Clock input
        KEY : in std_logic_vector(3 downto 0);  -- pushbutton switches
        SW : in std_logic_vector(8 downto 0);  -- slide switches
        LEDG : out std_logic_vector(7 downto 0); -- green LED's
        LCD_RW : out std_logic;  -- R/W control signal for the LCD
        LCD_EN : out std_logic;  -- Enable control signal for the LCD
        LCD_RS : out std_logic;  -- Whether or not you are sending an instruction or character
        LCD_ON : out std_logic;  -- used to turn on the LCD
        LCD_BLON : out std_logic; -- used to turn on the backlight
        LCD_DATA : out std_logic_vector(7 downto 0) -- used to send instructions or characters
    );
end Lab1;

architecture behavioural of Lab1 is
    type state_type is (INIT1, INIT2, INIT3, INIT4, INIT5, INIT6, DISPLAY_A, DISPLAY_B, DISPLAY_C, DISPLAY_D, DISPLAY_E);
    signal state, next_state: state_type;
    signal char_count: integer range 0 to 4 := 0; -- Counter for cycling through characters
    signal counter: natural := 0;
    constant counter_max: natural := 100000000; -- Adjust this for 2-second delay based on clock frequency

begin

    -- Clock Divider Process
    process(CLK)
    begin
        if rising_edge(CLK) then
            if counter < counter_max then
                counter <= counter + 1;
            else
                counter <= 0;
                if state /= next_state then
                    state <= next_state;
                end if;
            end if;
        end if;
    end process;

    -- Constant assignments
    LCD_BLON <= '1';   -- backlight is always on
    LCD_ON <= '1';     -- LCD is always on
    LCD_EN <= KEY(3);  -- connect the clock to the LCD_en input
    LCD_RW <= '0';     -- always writing to the LCD

    -- State Transition Logic
    process(KEY(0), state)
    begin
        if KEY(0) = '0' then
            next_state <= INIT1;  -- Reset state
            char_count <= 0;      -- Reset character counter
        elsif rising_edge(KEY(0)) then
            if counter = counter_max then
                case state is
                    when INIT1 to INIT5 =>
                        next_state <= state_type'val(state_type'pos(state) + 1); -- Move to the next init state
                    when INIT6 =>
                        next_state <= DISPLAY_A; -- Start with displaying 'A'
                    when DISPLAY_A to DISPLAY_E =>
                        if SW(0) = '0' then  -- Forward direction
                            char_count <= (char_count + 1) mod 5;
                        else  -- Backward direction
                            char_count <= (char_count - 1 + 5) mod 5; -- +5 to avoid negative values
                        end if;
                        case char_count is
                            when 0 => next_state <= DISPLAY_A;
                            when 1 => next_state <= DISPLAY_B;
                            when 2 => next_state <= DISPLAY_C;
                            when 3 => next_state <= DISPLAY_D;
                            when 4 => next_state <= DISPLAY_E;
                            when others => null; -- Do nothing
                        end case;
                    when others =>
                        next_state <= INIT1;
                end case;
            end if;
        end if;
    end process;

    -- Output Logic
    process(state)
    begin
        case state is
            when INIT1 =>
                LCD_RS <= '0';
                LCD_DATA <= "00111000"; -- Hex 38
                LEDG(0) <= '1';
				when INIT2 =>
                LCD_RS <= '0';
                LCD_DATA <= "00111000"; -- Hex 38 (repeat)
					 LEDG(1) <= '1';
            when INIT3 =>
                LCD_RS <= '0';
                LCD_DATA <= "00001100"; -- Hex 0C
					 LEDG(2) <= '1';
            when INIT4 =>
                LCD_RS <= '0';
                LCD_DATA <= "00000001"; -- Hex 01
					 LEDG(3) <= '1';
            when INIT5 =>
                LCD_RS <= '0';
                LCD_DATA <= "00000110"; -- Hex 06
					 LEDG(4) <= '1';
            when INIT6 =>
                LCD_RS <= '0';
                LCD_DATA <= "10000000"; -- Hex 80
					 LEDG(5) <= '1';
            when DISPLAY_A =>
                LCD_RS <= '1';
                LCD_DATA <= "01000001"; -- A
					 LEDG(0) <= '1';
            when DISPLAY_B =>
                LCD_RS <= '1';
                LCD_DATA <= "01000010"; -- B
					 LEDG(1) <= '1';
            when DISPLAY_C =>
                LCD_RS <= '1';
                LCD_DATA <= "01000011"; -- C
					 LEDG(2) <= '1';
            when DISPLAY_D =>
                LCD_RS <= '1';
                LCD_DATA <= "01000100"; -- D
					 LEDG(3) <= '1';
            when DISPLAY_E =>
                LCD_RS <= '1';
                LCD_DATA <= "01000101"; -- E
					 LEDG(4) <= '1';
            when others =>
                LCD_RS <= '0';
                LCD_DATA <= (others => '0');
                LEDG(7) <= '1';
        end case;
    end process;

end behavioural;
