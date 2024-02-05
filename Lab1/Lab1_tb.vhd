library ieee;
use ieee.std_logic_1164.all;

entity lab1_tb is
-- Testbench has no ports
end lab1_tb;

architecture behavior of lab1_tb is 
    -- Component Declaration for the Unit Under Test (UUT)
    component lab1
    port(
         KEY : in  std_logic_vector(3 downto 0);
         SW : in  std_logic_vector(8 downto 0);
         LEDG : out  std_logic_vector(7 downto 0);
         LCD_RW : out  std_logic;
         LCD_EN : out  std_logic;
         LCD_RS : out  std_logic;
         LCD_ON : out  std_logic;
         LCD_BLON : out  std_logic;
         LCD_DATA : out  std_logic_vector(7 downto 0)
        );
    end component;

    --Inputs
    signal KEY : std_logic_vector(3 downto 0) := (others => '0');
    signal SW : std_logic_vector(8 downto 0) := (others => '0');

    --Outputs
    signal LEDG : std_logic_vector(7 downto 0);
    signal LCD_RW : std_logic;
    signal LCD_EN : std_logic;
    signal LCD_RS : std_logic;
    signal LCD_ON : std_logic;
    signal LCD_BLON : std_logic;
    signal LCD_DATA : std_logic_vector(7 downto 0);

begin 
    -- Instantiate the Unit Under Test (UUT)
    uut: lab1 port map (
          KEY => KEY,
          SW => SW,
          LEDG => LEDG,
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
        -- hold reset state for 100 ns.
        KEY(3) <= '0';
        wait for 100 ns;  
        KEY(3) <= '1';
        
        -- insert stimulus here 
        for i in 0 to 5 loop
            KEY(0) <= '1';
            wait for 6 ns;
            KEY(0) <= '0';
            wait for 6 ns;
        end loop;

        wait for 80 ns;
        wait; -- will wait forever
    end process;
end behavior;
