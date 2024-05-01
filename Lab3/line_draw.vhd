library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity line_drawer is
  port(
    clk       : in std_logic;
    start     : in std_logic; -- Signal to indicate readiness to draw
    KEY       : in std_logic_vector(3 downto 0); -- Input keys
    x1        : in integer range 0 to 159; -- Starting x-coordinate
    y1        : in integer range 0 to 119; -- Starting y-coordinate
    color     : in std_logic_vector(2 downto 0); -- Color of the line
    plot      : out std_logic; -- Signal to plot a point
    x         : out std_logic_vector(7 downto 0); -- X coordinate to plot
    y         : out std_logic_vector(6 downto 0); -- Y coordinate to plot
    done      : out std_logic  -- Signal when drawing is complete
  );
end entity;

architecture behavior of line_drawer is
  constant center_x : integer range 0 to 159 := 80; -- Center x-coordinate
  constant center_y : integer range 0 to 119 := 60; -- Center y-coordinate
  type state_type is (idle, draw, done_state);
  signal curr_state, next_state : state_type := idle;

  signal curr_x, curr_y : integer range 0 to 159 := 0;
  signal dx, dy, sx, sy, err, e2 : integer;

begin

  -- FSM Process that combines state transition and output logic
  process(clk)
  begin
    if rising_edge(clk) then
      case curr_state is
        when idle =>
          if start = '1' and KEY(1) = '0' then -- Check for start condition
            -- Initialize for line drawing
            curr_x <= x1;
            curr_y <= y1;
            dx <= abs(center_x - x1);
            dy <= abs(center_y - y1) * (-1); -- dy is negative because screen coordinates go top-down
          
				if x1 < center_x then
				sx <= -1;
				else
				sx <= 1;
				end if;
            
				if y1 < center_y then
				sy <= -1;
				else
				sy <= 1;
				end if;
            err <= dx + dy;
            next_state <= draw; -- Transition to draw state
          else
            next_state <= idle;
          end if;

        when draw =>
          -- Perform a drawing step
          e2 <= 2 * err;
          if e2 >= dy then
            err <= err + dy;
            curr_x <= curr_x + sx;
          end if;
          if e2 <= dx then
            err <= err + dx;
            curr_y <= curr_y + sy;
          end if;
          if curr_x = center_x and curr_y = center_y then
            next_state <= done_state; -- Drawing complete
          else
            next_state <= draw; -- Continue drawing
          end if;

        when done_state =>
          -- Cleanup or reset for the next drawing
          next_state <= idle;

        when others =>
          next_state <= idle;
      end case;

      case curr_state is
        when idle =>
          plot <= '0';
          done <= '0';

        when draw =>
          plot <= '1';
          x <= std_logic_vector(to_unsigned(curr_x, x'length));
          y <= std_logic_vector(to_unsigned(curr_y, y'length));

        when done_state =>
          plot <= '0';
          done <= '1'; -- Signal drawing completion

        when others =>
          plot <= '0';
          done <= '0';
      end case;

      curr_state <= next_state; -- Update state
    end if;
  end process;

end architecture;
