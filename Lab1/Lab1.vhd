library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std;
--use work.ascii_pkg.all;

entity lab1 is
    port(
        CLOCK_50 : in std_logic;  -- Main clock input
        KEY : in std_logic_vector(3 downto 0);  -- Pushbutton switches
        SW : in std_logic_vector(8 downto 0);  -- Slide switches
        LEDG : out std_logic_vector(7 downto 0); -- Green LEDs
		  LEDR : out std_logic_vector(7 downto 0);
        LCD_RW : out std_logic;  -- R/W control signal for the LCD
        LCD_EN : out std_logic;  -- Enable control signal for the LCD
        LCD_RS : out std_logic;  -- Instruction/Data select for the LCD
        LCD_ON : out std_logic;  -- Turn on the LCD
        LCD_BLON : out std_logic; -- Turn on the backlight
        LCD_DATA : out std_logic_vector(7 downto 0)  -- Send instructions or characters
    );
end lab1;

architecture behavioural of lab1 is
    type STATE is (st_A, st_B, st_c, st_D, st_E, s1, s2, s3, s4, s5, s6, clear_screen);
    signal st: STATE := s1;

    -- Clock divider signals
    signal counter : unsigned(25 downto 0) := (others => '0');
    signal slow_clock : std_logic := '0';
	 
	 -- Additional signal for debugging
	 signal state_leds_g: std_logic_vector(7 downto 0);
	 signal state_leds_r : std_logic_vector(7 downto 0);
	 
	 -- Character count and screen full signals
    signal char_count : integer := 0;
    constant max_chars : integer := 16;  -- adjust this based on your LCD's character limit
	 

begin
	 
	 -- LCD control signals
    LCD_BLON <= '1';
    LCD_ON <= '1';
    LCD_EN <= slow_clock;  -- Use the slow clock for LCD_EN
    LCD_RW <= '0';

    LEDG <= state_leds_g;
	 LEDR <= state_leds_r;
		

    -- Clock divider process
    process(CLOCK_50)
    begin
        if rising_edge(CLOCK_50) then
            counter <= counter + 1;
            if counter = (2**26 - 1) then
                slow_clock <= not slow_clock;
                counter <= (others => '0');
            end if;
        end if;
    end process;

    -- State machine process
    process(slow_clock)
    begin
        if rising_edge(slow_clock) then
            if KEY(3) = '0' then
                st <= s1;
					 char_count <= 0;
            else
                case st is
							when s1 =>
                        LCD_RS <= '0';
                        LCD_DATA <= "00111000";  -- Function Set
								state_leds_g <= "00000001";
							   state_leds_r <= "00000000";
                        st <= s2;
                    when s2 =>
                        LCD_DATA <= "00111000";  -- Function Set
                        st <= s3;
								state_leds_g <= "00000010";
							   state_leds_r <= "00000000";
                    when s3 =>
                        LCD_DATA <= "00001100";  -- Display ON
                        st <= s4;
								state_leds_g <= "00000100";
							   state_leds_r <= "00000000";
                    when s4 =>
                        LCD_DATA <= "00000001";  -- Clear Display
                        st <= s5;
								state_leds_g <= "00001000";
			  				   state_leds_r <= "00000000";
                    when s5 =>
                        LCD_DATA <= "00000110";  -- Entry Mode Set
                        st <= s6;
							   state_leds_g <= "00010000";
							   state_leds_r <= "00000000";
                    when s6 =>
                        LCD_DATA <= "10000000";  -- Set DDRAM Address
                        st <= st_A;
								state_leds_g <= "00100000";
							   state_leds_r <= "00000000";
                    when st_A =>
                        LCD_RS <= '1';
                        LCD_DATA <= "01000001";  -- ASCII 'A'
								state_leds_g <= "00000000";
							   state_leds_r <= "00000001";
								
								-- Increase character count when a character is printed
                        char_count <= char_count + 1;
                        -- Check if screen is full
                        if char_count >= max_chars then
                            st <= clear_screen;
                        else
									if SW(0) = '0' then
										 st <= st_B;
									else
										 st <= st_E;
									end if;
								end if;
                    when st_B =>
                        LCD_DATA <= "01000010";  -- ASCII 'B'
								state_leds_g <= "00000000";
								state_leds_r <= "00000010";
                        								-- Increase character count when a character is printed
                        char_count <= char_count + 1;
                        -- Check if screen is full
                        if char_count >= max_chars then
                            st <= clear_screen;
                        else
									if SW(0) = '0' then
										 st <= st_C;
									else
										 st <= st_A;
									end if;
								end if;
                    when st_C =>
                        LCD_DATA <= "01000011";  -- ASCII 'C'
								state_leds_g <= "00000000";
							   state_leds_r <= "00000100";
                        								-- Increase character count when a character is printed
                        char_count <= char_count + 1;
                        -- Check if screen is full
                        if char_count >= max_chars then
                            st <= clear_screen;
                        else
									if SW(0) = '0' then
										 st <= st_D;
									else
										 st <= st_B;
									end if;
								end if;
							when st_D =>
                        LCD_DATA <= "01000100";  -- ASCII 'D'
								state_leds_g <= "00000000";
							   state_leds_r <= "00001000";
                        								-- Increase character count when a character is printed
                        char_count <= char_count + 1;
                        -- Check if screen is full
                        if char_count >= max_chars then
                            st <= clear_screen;
                        else
									if SW(0) = '0' then
										 st <= st_E;
									else
										 st <= st_C;
									end if;
								end if;
							when st_E =>
                        LCD_DATA <= "01000101";  -- ASCII 'E'
								state_leds_g <= "00000000";
							   state_leds_r <= "00010000";
                        								-- Increase character count when a character is printed
                        char_count <= char_count + 1;
                        -- Check if screen is full
                        if char_count >= max_chars then
                            st <= clear_screen;
                        else
									if SW(0) = '0' then
										 st <= st_A;
									else
										 st <= st_D;
									end if;
								end if;
							when clear_screen =>
                        LCD_RS <= '0';
                        LCD_DATA <= "00000001";  -- Clear Display command
                        st <= s1;
                        char_count <= 0;  -- Reset character count after clearing screen
								
--							when display =>
--								LCD_RS <= '1';
--								LCD_DATA <= decimal_to_ascii(char_count - 1);
--								st <= s1;
							when others =>
                        st <= s1;
                end case;
            end if;
        end if;
    end process;



end behavioural;
