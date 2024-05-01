library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Circuit is
  port(
    KEY      : in  std_logic_vector(3 downto 0);
    CLOCK_50 : in  std_logic;                
    SW       : in  std_logic_vector(17 downto 0);
    colour   : out std_logic_vector(2 downto 0);
    x        : out std_logic_vector(7 downto 0);
    y        : out std_logic_vector(6 downto 0);
    plot     : out std_logic
  );
end Circuit;

-- Architecture definition for your "Circuit"
architecture Behavioral of Circuit is
	signal reset_signal : std_logic;

begin

  -- Logic for output 'colour' based on SW(2 downto 0)
  colour <= SW(2 downto 0); -- Adjust the indices based on your requirement

  -- Logic for output 'x' based on SW(17 downto 10)
  x <= SW(17 downto 10);

  -- Logic for output 'y' based on SW(9 downto 3)
  y <= SW(9 downto 3);

  -- Example logic for output 'plot'
  -- Here we check if KEY(0) is pressed to set 'plot'
  -- This is a simplified version and does not include debouncing logic
  plot <= '1' when KEY(0) = '0' else '0';

  -- Add any additional logic you need here

end Behavioral;
