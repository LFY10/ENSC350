library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Circuit_tb is
-- Testbench has no ports
end Circuit_tb;

architecture tb of Circuit_tb is
    -- Instantiate the signals to connect to the DUT (Device Under Test)
    signal KEY      : std_logic_vector(3 downto 0) := (others => '1'); -- Default to not pressed ('1')
    signal CLOCK_50 : std_logic := '0'; -- Initialize to '0'
    signal SW       : std_logic_vector(17 downto 0) := (others => '0'); -- Initialize switches to '0'
    signal colour   : std_logic_vector(2 downto 0);
    signal x        : std_logic_vector(7 downto 0);
    signal y        : std_logic_vector(6 downto 0);
    signal plot     : std_logic;

    -- Clock process
    constant clock_period : time := 40 ns; -- 50MHz clock
begin
    process -- This is the correct place for the clock process
        begin
            while true loop
                CLOCK_50 <= not CLOCK_50;
                wait for clock_period / 2;
            end loop;
        end process;

    -- Instantiate the DUT
    dut: entity work.Circuit
        port map(
            KEY      => KEY,
            CLOCK_50 => CLOCK_50,
            SW       => SW,
            colour   => colour,
            x        => x,
            y        => y,
            plot     => plot
        );

    -- Stimulus process to generate test vectors
    process
    begin
        -- Reset the system (assuming KEY(3) is the reset and active low)
        KEY(3) <= '0'; 
        wait for 80 ns; -- Wait for two clock cycles
        KEY(3) <= '1';

        -- Draw first pixel (Red at (15, 62))
        SW(2 downto 0) <= "010"; -- Red colour
        SW(9 downto 3) <= "0111110"; -- y = 62
        SW(17 downto 10) <= "00001111"; -- x = 15
        KEY(0) <= '0'; -- Simulate plot (KEY(0) pressed)
        wait for 40 ns; -- Wait for one clock cycle

        

        -- Draw second pixel (Yellow at (109, 12))
        SW(2 downto 0) <= "110"; -- Yellow colour
        SW(9 downto 3) <= "0001100"; -- y = 12
        SW(17 downto 10) <= "01101101"; -- x = 109
        KEY(0) <= '0'; -- Simulate plot (KEY(0) pressed)
        wait for 40 ns; -- Wait for one clock cycle
        KEY(0) <= '1'; -- Release plot (KEY(0) released)

        -- Finish the simulation after some time
        wait for 100 ns;
        report "Simulation finished" severity note;
        wait;
    end process;

end architecture tb;
