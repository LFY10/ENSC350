library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity diagonal_line_drawer is
    port(
        clk     : in std_logic;
        start   : in std_logic; -- Start signal for drawing the line
        x_start : in integer range 0 to 159; -- Starting x-coordinate of the dot
        y_start : in integer range 0 to 119; -- Starting y-coordinate of the line
        plot    : out std_logic; -- Signal to plot a point, active for one clock cycle
        x       : out std_logic_vector(7 downto 0); -- X coordinate to plot
        y_out   : out std_logic_vector(6 downto 0); -- Y coordinate to plot
        done    : out std_logic  -- Signal when drawing is complete
    );
end diagonal_line_drawer;

architecture behavior of diagonal_line_drawer is
    signal dx, dy, err, two_dx, two_dy: integer;
    signal x_inc, y_inc: integer range -1 to 1; -- Direction of increment
    signal initial, plot_now: std_logic := '1';
begin
    process(clk)
        variable current_x : integer range 0 to 159;
        variable current_y : integer range 0 to 119;
        variable error : integer;
    begin
        if rising_edge(clk) then
            plot <= '0'; -- Reset plot every cycle unless actively plotting
            if start = '1' and initial = '1' then
                -- Initial setup
					 if x_start <= 80 then
                    x_inc <= 1;  -- Move right
                    dx <= 80 - x_start;
                else
                    x_inc <= -1; -- Move left
                    dx <= x_start - 80;
                end if;

                if y_start <= 60 then
                    y_inc <= 1;  -- Move down
                    dy <= 60 - y_start;
                else
                    y_inc <= -1; -- Move up
                    dy <= y_start - 60;
                end if;

                two_dx <= 2 * dx;
                two_dy <= 2 * dy;
                err <= two_dy - dx; -- Initial error
                current_x := x_start;
                current_y := y_start;
                error := err; -- Synchronize variable with initial error signal
                initial <= '0';

            elsif start = '1' and initial = '0' then
                -- Drawing process
                if (current_x /= 80 or current_y /= 60) and (current_x >= 0 and current_x < 160 and current_y >= 0 and current_y < 120) then
                    plot <= '1'; -- Plot this cycle
                    x <= std_logic_vector(to_unsigned(current_x, 8));
                    y_out <= std_logic_vector(to_unsigned(current_y, 7));
                    
						  if error < 0 then
                        error := error + two_dy;
                    else
                        error := error + two_dy - two_dx;
                        current_y := current_y + y_inc;
                    end if;
                    current_x := current_x + x_inc;

                else
                    -- Finished drawing the line
                    done <= '1';
                    initial <= '1'; -- Reset for next drawing
                end if;
            else
                -- Reset if start is not asserted
                done <= '0';
                initial <= '1';
            end if;
        end if;
    end process;
end behavior;