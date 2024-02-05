
-- This is the template for Lab01.  You should start with this;
-- it will make your life easier.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity test_lcd is
     port(
        KEY : in std_logic_vector(3 downto 0);  -- pushbutton switches
        SW : in std_logic_vector(8 downto 0);  -- slide switches
        LEDG : out std_logic_vector(7 downto 0); -- green LED's (you might want to use
                                                 -- this to display your current state)
        LCD_RW : out std_logic;  -- R/W control signal for the LCD
        LCD_EN : out std_logic;  -- Enable control signal for the LCD
        LCD_RS : out std_logic;  -- Whether or not you are sending an instruction or character
        LCD_ON : out std_logic;  -- used to turn on the LCD
        LCD_BLON : out std_logic; -- used to turn on the backlight
        LCD_DATA : out std_logic_vector(7 downto 0));  -- used to send instructions or characters
end test_lcd ;


architecture behavioural of test_lcd is
	type STATE is (st_W,st_e,st_n,st_d,st_y,st_rst1,st_rst2,st_rst3,st_rst4,st_rst5,st_rst6);
	signal st: STATE := st_rst1;
begin

        -- these are constant all the time.  Don't change these.

        LCD_BLON <= '1';   -- backlight is always on
        LCD_ON <= '1';     -- LCD is always on
        LCD_EN <= KEY(3);  -- connect the clock to the LCD_en input
        LCD_RW <= '0';     -- always writing to the LCD

        -- Your state machine goes here
		  state_machine: process(KEY, SW)
		  begin
			if (KEY(3)='1') then
				st <= st_rst1;
				-- set ctr to 0??
			elsif (rising_edge(KEY(0))) then
				case st is
					when st_W =>
						LCD_RS <= '1';
						LCD_DATA <= B"01010111";
						if (SW(0)='0') then
							st <= st_e;
						else
							st <= st_y;
						end if;
					when st_e =>
						LCD_DATA <= B"01100101";
						if (SW(0)='0') then
							st <= st_n;
						else
							st <= st_W;
						end if;
					when st_n =>
						LCD_DATA <= B"01101110";
						if (SW(0)='0') then
							st <= st_d;
						else
							st <= st_e;
						end if;
					when st_d =>
						LCD_DATA <= B"01100100";
						if (SW(0)='0') then
							st <= st_y;
						else
							st <= st_n;
						end if;
					when st_y =>
						LCD_DATA <= B"01111001";
						if (SW(0)='0') then
							st <= st_W;
						else
							st <= st_d;
						end if;
					when st_rst1 =>
						LCD_RS <= '0';
						LCD_DATA <= B"00111000";
						st <= st_rst2;
					when st_rst2 =>
						LCD_DATA <= B"00111000";
						st <= st_rst3;
					when st_rst3 =>
						LCD_DATA <= B"00001100";
						st <= st_rst4;
					when st_rst4 =>
						LCD_DATA <= B"00000001";
						st <= st_rst5;
					when st_rst5 =>
						LCD_DATA <= B"00000110";
						st <= st_rst6;
					when st_rst6 =>
						LCD_DATA <= B"10000000";
						st <= st_W;
				end case;
			end if;
		  end process state_machine;
end behavioural;

