LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY uart_rx_tb IS
END uart_rx_tb;

ARCHITECTURE behavior OF uart_rx_tb IS 

    COMPONENT uart_tx
    PORT(
         clk : IN  std_logic;
         rst_n : IN  std_logic;
         start : IN  std_logic;
         data : IN  std_logic_vector(7 downto 0);
         rs232_tx : OUT  std_logic;
         done : OUT  std_logic
        );
    END COMPONENT;
	 
	 COMPONENT uart_rx
    PORT(
         clk : IN  std_logic;
         rst_n : IN  std_logic;
         rs232 : IN  std_logic;
         rx_data : OUT  std_logic_vector(7 downto 0);
         done : OUT  std_logic
        );
    END COMPONENT;
        
	 
    signal clk : std_logic := '0';
    signal rst_n : std_logic := '0';
    signal start : std_logic := '0';
    signal data : std_logic_vector(7 downto 0) := (others => '0');
    signal rs232_tx : std_logic;
	 signal rs232 : std_logic := '0';
	 signal rx_data : std_logic_vector(7 downto 0) := (others => '0');
    signal done_tx : std_logic;
	 signal done_rx : std_logic;
    constant clk_period : time := 10 ns;
 
BEGIN 

	 -- UART Transmitter Instantiation
    uart_tx_inst: uart_tx PORT MAP (
          clk => clk,
          rst_n => rst_n,
          start => start,
          data => data,
          rs232_tx => rs232_tx,
          done => done_tx
        );

    -- UART Receiver Instantiation, connecting rs232_tx to rs232
    uart_rx_inst: uart_rx PORT MAP (
          clk => clk,
          rst_n => rst_n,
          rs232 => rs232_tx,
          rx_data => rx_data,
          done => done_rx
        );

    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    stim_proc: process
    begin       
        -- Initial reset
        rst_n <= '0';
        wait for 100 ns;  
        rst_n <= '1';
        wait for 100 ns;
        
        -- First Test: Send a byte
        data <= "10101010";
        start <= '1'; 
        wait for 90 ns;
        start <= '0'; 
        
        -- Wait for the first transmission to complete
        wait for 600000 ns; 
        
        -- Second Test: Send a different byte after a pause
        -- Ensure UART transmitter can handle consecutive transmissions
        wait for 200 ns; -- A pause between transmissions
        data <= "11001100"; -- New data pattern
        start <= '1';
        wait for 20 ns;
        start <= '0';
       
        
        -- Terminate simulation
        wait;
    end process;

END behavior;
