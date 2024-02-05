
-- This is the template for Lab01.  You should start with this;
-- it will make your life easier.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity lab1 is
     port(
        KEY : in std_logic_vector(3 downto 0);  -- pushbutton switches
        SW : in std_logic_vector(8 downto 0);  -- slide switches
        LEDG : out std_logic_vector(7 downto 0); -- Green LEDs
	LEDR : out std_logic_vector(7 downto 0);
        LCD_RW : out std_logic;  -- R/W control signal for the LCD
        LCD_EN : out std_logic;  -- Enable control signal for the LCD
        LCD_RS : out std_logic;  -- Whether or not you are sending an instruction or character
        LCD_ON : out std_logic;  -- used to turn on the LCD
        LCD_BLON : out std_logic; -- used to turn on the backlight
        LCD_DATA : out std_logic_vector(7 downto 0));  -- used to send instructions or characters
end lab1 ;


architecture behavioural of lab1 is
	type STATE is (s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11);
	signal st: STATE := s1;

	-- Additional signal for debugging
	 signal state_leds_g: std_logic_vector(7 downto 0);
	 signal state_leds_r : std_logic_vector(7 downto 0);
begin

        -- these are constant all the time.  Don't change these.

        LCD_BLON <= '1';   -- backlight is always on
        LCD_ON <= '1';     -- LCD is always on
        LCD_EN <= KEY(0);  -- connect the clock to the LCD_en input
        LCD_RW <= '0';     -- always writing to the LCD
	
 	LEDG <= state_leds_g;
	LEDR <= state_leds_r;
        -- Your state machine goes here
		  state_machine: process(KEY, SW)
		  begin
			if (KEY(3)='0') then
				st <= s1;
			elsif (rising_edge(KEY(0))) then
				case st is
					when s7 =>
						LCD_RS <= '1';
						LCD_DATA <= B"01010111";
						state_leds_g <= "00000000";
							   state_leds_r <= "00000001";
						if (SW(0)='0') then
							st <= s8;
						else
							st <= s11;
						end if;
					when s8 =>
						LCD_DATA <= B"01100101";
						state_leds_g <= "00000000";
								state_leds_r <= "00000010";
						if (SW(0)='0') then
							st <= s9;
						else
							st <= s7;
						end if;
					when s9 =>
						LCD_DATA <= B"01101110";
						state_leds_g <= "00000000";
							   state_leds_r <= "00000100";
						if (SW(0)='0') then
							st <= s10;
						else
							st <= s8;
						end if;
					when s10 =>
						LCD_DATA <= B"01100100";
						state_leds_g <= "00000000";
							   state_leds_r <= "00001000";
						if (SW(0)='0') then
							st <= s11;
						else
							st <= s9;
						end if;
					when s11 =>
						LCD_DATA <= B"01111001";
						state_leds_g <= "00000000";
							   state_leds_r <= "00010000";
						if (SW(0)='0') then
							st <= s7;
						else
							st <= s10;
						end if;
					when s1 =>
						LCD_RS <= '0';
						LCD_DATA <= B"00111000";
						st <= s2;
						state_leds_g <= "00000001";
						state_leds_r <= "00000000";
					when s2 =>
						LCD_DATA <= B"00111000";
						st <= s3;
						state_leds_g <= "00000010";
							   state_leds_r <= "00000000";
					when s3 =>
						LCD_DATA <= B"00001100";
						st <= s4;
						state_leds_g <= "00000100";
							   state_leds_r <= "00000000";
					when s4 =>
						LCD_DATA <= B"00000001";
						st <= s5;
			state_leds_g <= "00001000";
			  				   state_leds_r <= "00000000";
					when s5 =>
						LCD_DATA <= B"00000110";
						st <= s6;
					state_leds_g <= "00010000";
							   state_leds_r <= "00000000";
					when s6 =>
						LCD_DATA <= B"10000000";
						st <= s7;
						state_leds_g <= "00100000";
							   state_leds_r <= "00000000";
				end case;
			end if;
		  end process state_machine;
end behavioural;

