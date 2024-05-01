LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY uart_rx IS
    PORT(
        clk     : IN  std_logic;
        rst_n   : IN  std_logic;
        rs232   : IN  std_logic;
        rx_data : OUT std_logic_vector(7 downto 0);
        done    : OUT std_logic
    );
END ENTITY uart_rx;

ARCHITECTURE behavior OF uart_rx IS
    SIGNAL rs232_t, rs232_t1, rs232_t2 : std_logic := '1';
    SIGNAL state : std_logic := '0';
    signal baud_cnt : INTEGER := 0;
    SIGNAL bit_flag : std_logic := '0';
    SIGNAL bit_cnt : INTEGER := 0;
    SIGNAL nedge : std_logic;
	 signal done_sig : STD_LOGIC := '0';
BEGIN

    PROCESS(clk, rst_n)
    BEGIN
        IF rst_n = '0' THEN
            rs232_t <= '1';
            rs232_t1 <= '1';
            rs232_t2 <= '1';
        ELSIF rising_edge(clk) THEN
            rs232_t <= rs232;
            rs232_t1 <= rs232_t;
            rs232_t2 <= rs232_t1;
        END IF;
    END PROCESS;
       
--    PROCESS(clk, rst_n)
--    BEGIN
--        IF rst_n = '0' THEN
--            rs232_t <= '1';
--        ELSIF rising_edge(clk) THEN
--            rs232_t <= rs232;
--
--        END IF;
--    END PROCESS;

    nedge <= '1' WHEN rs232_t1 = '0' AND rs232_t2 = '1' ELSE '0';

    -- State control
    PROCESS(clk, rst_n)
    BEGIN
        IF rst_n = '0' THEN
            state <= '0';
        ELSIF rising_edge(clk) THEN
            IF nedge = '1' THEN
                state <= '1';
            ELSIF done_sig = '1' THEN
                state <= '0';
            END IF;
        END IF;
    END PROCESS;

    -- Baud rate counter
    PROCESS(clk, rst_n)
    BEGIN
        IF rst_n = '0' THEN
            baud_cnt <= 0;
        ELSIF rising_edge(clk) THEN
            IF state = '1' THEN
                IF baud_cnt = 5208 then  --100M/9600 = 5208
                    baud_cnt <= 0;
                ELSE
                    baud_cnt <= baud_cnt + 1;
                END IF;
            ELSE
                baud_cnt <= 0;
            END IF;
        END IF;
    END PROCESS;

    -- Bit flag
    PROCESS(clk, rst_n)
    BEGIN
        IF rst_n = '0' THEN
            bit_flag <= '0';
        ELSIF rising_edge(clk) THEN
            IF baud_cnt = 2640 THEN --5280/2
                bit_flag <= '1';
            ELSE
                bit_flag <= '0';
            END IF;
        END IF;
    END PROCESS;

    -- Bit count
    PROCESS(clk, rst_n)
    BEGIN
        IF rst_n = '0' THEN
            bit_cnt <= 0;
        ELSIF rising_edge(clk) THEN
            IF bit_flag = '1' THEN
                IF bit_cnt = 10 THEN
                    bit_cnt <= 0;
                ELSE
                    bit_cnt <= bit_cnt + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- RX Data
    PROCESS(clk, rst_n)
    BEGIN
        IF rst_n = '0' THEN
            rx_data <= (others => '0');
        ELSIF rising_edge(clk) THEN
            IF state = '1' AND bit_flag = '1' THEN
                CASE bit_cnt IS
                    WHEN 1 => rx_data(0) <= rs232;
                    WHEN 2 => rx_data(1) <= rs232;
                    WHEN 3 => rx_data(2) <= rs232;
                    WHEN 4 => rx_data(3) <= rs232;
                    WHEN 5 => rx_data(4) <= rs232;
                    WHEN 6 => rx_data(5) <= rs232;
                    WHEN 7 => rx_data(6) <= rs232;
                    WHEN 8 => rx_data(7) <= rs232;
                    WHEN OTHERS => NULL;
                END CASE;
            END IF;
        END IF;
    END PROCESS;

    -- Done signal
    PROCESS(clk, rst_n)
    BEGIN
        IF rst_n = '0' THEN
            done_sig <= '0';
        ELSIF rising_edge(clk) THEN
            IF bit_flag = '1' AND bit_cnt = 10 THEN
                done_sig <= '1';
            ELSE
                done_sig <= '0';
            END IF;
        END IF;
    END PROCESS;
	 
	 done <= done_sig;
    
END ARCHITECTURE behavior;
