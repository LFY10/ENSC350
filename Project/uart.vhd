library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity uart is
    Port ( CLOCK_50    : in  STD_LOGIC;

			  KEY 		  : in std_logic_vector(3 downto 0);        
           SW          : in  STD_LOGIC_VECTOR(7 downto 0); -- Switches for data input
			  LEDG : OUT std_logic_vector(7 DOWNTO 0);
           UART_TXD    : out STD_LOGIC; -- UART transmit signal
           done        : out STD_LOGIC  -- Transmission done signal
          );
end uart;

architecture Behavioral of uart is
    -- Instantiate the uart_tx component
    component uart_tx is
        Port ( clk      : in  STD_LOGIC;
               rst_n    : in  STD_LOGIC;
               start    : in  STD_LOGIC;
               data     : in  STD_LOGIC_VECTOR(7 downto 0);
               rs232_tx : out STD_LOGIC;
               done     : out STD_LOGIC
              );
    end component;
	 --debouncer
    component debouncer is
			port( btn:		in std_logic;	--buttum selected 
					rst:	in std_logic;		--reset buttum KEY(3)
					CLOCK_50:in std_logic;
					btn_clock:out std_logic);-- buttom react 
	end component;
   
    -- Signals for debounced keys
    signal key0_debounced : STD_LOGIC;
    signal key1_debounced : STD_LOGIC;
	 signal start : STD_LOGIC;
	 signal reset :STD_LOGIC;

begin
     -- Debouncer for key(0)
    debouncer_key0 : debouncer
        Port map (
            btn       => KEY(0),
            rst       => KEY(3), --key(3) is the reset signal for the debouncer
            CLOCK_50  => CLOCK_50,
            btn_clock => key0_debounced
        );
    
    -- Debouncer for key(1)
    debouncer_key1 : debouncer
        Port map (
            btn       => KEY(1),
            rst       => KEY(3), 
            CLOCK_50  => CLOCK_50,
            btn_clock => key1_debounced
        );


    -- uart_tx instantiation
    uart_instance : uart_tx
        Port map (
            clk      => CLOCK_50,
            rst_n    => reset,
            start    => start,
            data     => SW,
            rs232_tx => UART_TXD,
            done     => done
        );
		  
   process(CLOCK_50,KEY)
	begin
		 if rising_edge(CLOCK_50) then
			  if key0_debounced = '0' then
					reset <= '1';
			  else
					reset <= '0';
			  end if;

			  if key1_debounced = '0' then
					start <= '1';
				   LEDG(0) <= '1';
			  else
					start <= '0';
					LEDG(1) <= '1';
			  end if;
		 end if;
	end process;


end Behavioral;
