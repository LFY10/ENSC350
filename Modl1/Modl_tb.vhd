LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY lab1_tb IS
END lab1_tb;

ARCHITECTURE behavior OF lab1_tb IS 

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT lab1
    PORT(
         KEY : IN  std_logic_vector(3 downto 0);
         SW : IN  std_logic_vector(8 downto 0);
         LEDG : OUT  std_logic_vector(7 downto 0);
         LEDR : OUT  std_logic_vector(7 downto 0);
         LCD_RW : OUT  std_logic;
         LCD_EN : OUT  std_logic;
         LCD_RS : OUT  std_logic;
         LCD_ON : OUT  std_logic;
         LCD_BLON : OUT  std_logic;
         LCD_DATA : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
   
    --Inputs
    signal KEY : std_logic_vector(3 downto 0) := (others => '1');
    signal SW : std_logic_vector(8 downto 0) := (others => '0');

    --Outputs
    signal LEDG : std_logic_vector(7 downto 0);
    signal LEDR : std_logic_vector(7 downto 0);
    signal LCD_RW : std_logic;
    signal LCD_EN : std_logic;
    signal LCD_RS : std_logic;
    signal LCD_ON : std_logic;
    signal LCD_BLON : std_logic;
    signal LCD_DATA : std_logic_vector(7 downto 0);

BEGIN 

    -- Instantiate the Unit Under Test (UUT)
    uut: lab1 PORT MAP (
          KEY => KEY,
          SW => SW,
          LEDG => LEDG,
          LEDR => LEDR,
          LCD_RW => LCD_RW,
          LCD_EN => LCD_EN,
          LCD_RS => LCD_RS,
          LCD_ON => LCD_ON,
          LCD_BLON => LCD_BLON,
          LCD_DATA => LCD_DATA
        );

    -- Stimulus process
    stim_proc: process
    begin		
        -- Reset
        KEY(3) <= '0';
        wait for 6 ns;  
        KEY(3) <= '1';

        -- Initialize the SW(0) to run the LED sequence normally
        SW(0) <= '0'; -- Normal LED sequence
        wait for 6 ns;

        -- Toggle KEY(0) to simulate the clock and observe LED changes
        for i in 1 to 20 loop
            KEY(0) <= NOT KEY(0); -- Toggle clock
            wait for 6 ns; -- Wait for the next clock edge
        end loop;

        -- Change SW(0) to run the LED sequence backwards
        SW(0) <= '1'; -- Reverse LED sequence
        wait for 6 ns;

        -- Toggle KEY(0) again to observe reverse LED changes
        for i in 1 to 20 loop
            KEY(0) <= NOT KEY(0); -- Toggle clock
            wait for 6 ns; -- Wait for the next clock edge
        end loop;

        wait;
    end process;

END behavior;

