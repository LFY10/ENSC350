library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab3 is
  port(
    CLOCK_50            : in  std_logic;
    KEY                 : in  std_logic_vector(3 downto 0);
    SW                  : in  std_logic_vector(17 downto 0);
    VGA_R, VGA_G, VGA_B : out std_logic_vector(9 downto 0); -- The outputs to VGA controller
    VGA_HS              : out std_logic;
    VGA_VS              : out std_logic;
    VGA_BLANK           : out std_logic;
    VGA_SYNC            : out std_logic;
    VGA_CLK             : out std_logic);
end lab3;

architecture rtl of lab3 is

  -- Component declarations (Circuit, vga_adapter, horizontal_line_drawer) remain unchanged
    -- Declare the component 'Circuit'
  component Circuit is
    port(
      KEY      : in  std_logic_vector(3 downto 0);
      CLOCK_50 : in  std_logic;
      SW       : in  std_logic_vector(17 downto 0);
      colour   : out std_logic_vector(2 downto 0);
      x        : out std_logic_vector(7 downto 0);
      y        : out std_logic_vector(6 downto 0);
      plot     : out std_logic
    );
  end component;

 --Component from the Verilog file: vga_adapter.v

  component vga_adapter
    generic(RESOLUTION : string);
    port (resetn                                       : in  std_logic;
          clock                                        : in  std_logic;
          colour                                       : in  std_logic_vector(2 downto 0);
          x                                            : in  std_logic_vector(7 downto 0);
          y                                            : in  std_logic_vector(6 downto 0);
          plot                                         : in  std_logic;
          VGA_R, VGA_G, VGA_B                          : out std_logic_vector(9 downto 0);
          VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK : out std_logic);
  end component;
  
  component diagonal_line_drawer is
    port(
        clk    : in  std_logic;
        start  : in  std_logic; -- Start signal for drawing the line
        x_start: in  integer range 0 to 159; -- Starting x-coordinate of the dot
        y_start: in  integer range 0 to 119; -- Constant y-coordinate of the line
        plot   : out std_logic; -- Signal to plot a point
        x      : out std_logic_vector(7 downto 0); -- X coordinate to plot
        y_out  : out std_logic_vector(6 downto 0); -- Y coordinate to plot (constant across the line)
        done   : out std_logic  -- Signal when drawing is complete
    );
end component;

  -- Signals for the Circuit
  signal x, x_for_line_drawer   : std_logic_vector(7 downto 0);
  signal y, y_for_line_drawer   : std_logic_vector(6 downto 0);
  signal colour                 : std_logic_vector(2 downto 0);
  signal plot, plot_for_line_drawer, final_plot : std_logic;
  signal resetn                 : std_logic;

  -- Signals for diagonal_line_drawer
  signal line_start : std_logic;
  signal line_done  : std_logic;
  signal line_x     : std_logic_vector(7 downto 0);
  signal line_y_out : std_logic_vector(6 downto 0);

begin

  -- Instantiate the 'Circuit' component
  myCircuit: Circuit
    port map(
      KEY      => KEY,
      CLOCK_50 => CLOCK_50,
      SW       => SW,
      colour   => colour,
      x        => x,
      y        => y,
      plot     => plot
    );

  -- Control logic to start line drawing
  -- This is an example and might need to be adapted based on your specific requirements
  process(CLOCK_50, KEY)
  begin
    if rising_edge(CLOCK_50) then
      if KEY(1) = '0' then -- Assuming pressing KEY(0) starts the diagonal_line_drawer
        line_start <= '1';
      else
        line_start <= '0';
      end if;
    end if;
  end process;

  -- Instantiate the diagonal_line_drawer component
  line_drawer_inst : diagonal_line_drawer
    port map(
      clk     => CLOCK_50,
      start   => line_start,
      x_start => to_integer(unsigned(x)), -- Use x from Circuit for starting x coordinate
      y_start => to_integer(unsigned(y)), -- Use y from Circuit for constant y coordinate
      plot    => plot_for_line_drawer,
      x       => line_x,
      y_out   => line_y_out,
      done    => line_done
    );

  -- Logic to select between plot signals from Circuit or horizontal_line_drawer
  process(plot, plot_for_line_drawer, line_done)
  begin
    if line_done = '1' then
      -- Once the line drawing is done, revert to using plot signal from Circuit
      final_plot <= plot;
      x_for_line_drawer <= x;
      y_for_line_drawer <= y;
    else
      -- While line is being drawn, use plot signal from horizontal_line_drawer
      final_plot <= plot_for_line_drawer;
      x_for_line_drawer <= line_x;
      y_for_line_drawer <= line_y_out;
    end if;
  end process;
  

  -- Connect to VGA adapter using selected signals
  vga_u0 : vga_adapter
    generic map(RESOLUTION => "160x120")
    port map(
      resetn    => KEY(3),
      clock     => CLOCK_50,
      colour    => colour, -- Assuming colour is managed separately
      x         => x_for_line_drawer,
      y         => y_for_line_drawer,
      plot      => final_plot,
      VGA_R     => VGA_R,
      VGA_G     => VGA_G,
      VGA_B     => VGA_B,
      VGA_HS    => VGA_HS,
      VGA_VS    => VGA_VS,
      VGA_BLANK => VGA_BLANK,
      VGA_SYNC  => VGA_SYNC,
      VGA_CLK   => VGA_CLK
    );

end rtl;