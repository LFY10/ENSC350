LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL; -- For 'unsigned' type and arithmetic operations

ENTITY Lab2 IS
    PORT(
		  --FAST_CLOCK : IN STD_LOGIC;
        CLOCK_50 : IN std_logic;  -- 50 MHz clock input
        KEY : IN std_logic_vector(3 DOWNTO 0);  -- Pushbutton switches
        SW : IN std_logic_vector(17 DOWNTO 0);  -- Slide switches for all bet inputs
        LEDG : OUT std_logic_vector(7 DOWNTO 0); -- Green LEDs for indicating something (e.g., win/loss)
		  HEX0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- 7-segment display LSD
        HEX1 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- 7-segment display Middle
        HEX2 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- 7-segment display MSD
		  HEX6 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		  HEX7 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
END Lab2;

ARCHITECTURE behavioural OF Lab2 IS
	 SIGNAL slow_clk: std_logic := '0';
    SIGNAL bet1_value : unsigned(5 downto 0); -- Derived from SW for bet 1
	 SIGNAL bet2_colour : std_logic;  -- colour for bet 2
    SIGNAL bet3_dozen : unsigned(1 downto 0);  -- Derived from SW for bet 3
    SIGNAL bet1_wins, bet2_wins, bet3_wins : std_logic;  -- Whether bets are winners
    --SIGNAL spin_result_latched : unsigned(5 downto 0); -- Assuming spin result is 7 for simulation
    SIGNAL edge_detected : std_logic := '0'; -- Detects the rising edge of KEY(0)
	 SIGNAL color_result : std_logic := '0'; -- default black
	 SIGNAL value1, value2, value3 : unsigned(2 downto 0);
    SIGNAL new_money : unsigned(11 downto 0);
	 SIGNAL money : unsigned(11 downto 0) := to_unsigned(32, 12);
	 
    --SIGNAL display_change : std_logic := '0'; -- Flag to indicate display mode

	 --SIGNAL digit_value_HEX0, digit_value_HEX1, digit_value_HEX2: UNSIGNED(3 DOWNTO 0);
	 --SIGNAL digit_value_HEX6, digit_value_HEX7: UNSIGNED(3 DOWNTO 0);
	 
	 signal slow_spin_result: unsigned(5 downto 0) := (others => '0');
	 signal fast_spin_result: unsigned(5 downto 0);
	 signal cooldown: unsigned(23 downto 0) := (others => '0');
	 
	 SIGNAL debounce_counter : UNSIGNED(19 DOWNTO 0) := (others => '0');  -- 20-bit counter for 10ms debounce
    SIGNAL key_pressed      : STD_LOGIC := '0';  -- Signal to detect the debounced press
    SIGNAL slow_clk_internal: STD_LOGIC := '0';  -- Internal slow clock toggle signal

	 
	 COMPONENT digit7seg
        PORT(
            digit : IN  UNSIGNED(3 DOWNTO 0);
            seg7 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
        );
    END COMPONENT;
	 
	 COMPONENT new_balance
        PORT(
            money : in unsigned(11 downto 0);
            value1 : in unsigned(2 downto 0);
            value2 : in unsigned(2 downto 0);
            value3 : in unsigned(2 downto 0);
            bet1_wins : in std_logic;
            bet2_wins : in std_logic;
            bet3_wins : in std_logic;
            new_money : out unsigned(11 downto 0)
        );
    END COMPONENT;
	 
	 COMPONENT spinwheel
        PORT(
            fast_clock : IN STD_LOGIC;
            resetb : IN STD_LOGIC;
            spin_result : OUT UNSIGNED(5 downto 0)
        );
    END COMPONENT;
	 
	 COMPONENT win IS
			PORT(spin_result_latched : in unsigned(5 downto 0);
						 bet1_value : in unsigned(5 downto 0); 
						 bet2_colour : in std_logic; 
						 bet3_dozen : in unsigned(1 downto 0); 
						 bet1_wins : out std_logic;  
						 bet2_wins : out std_logic; 
						 bet3_wins : out std_logic); 
	 END COMPONENT;
	 
	 

BEGIN
    win_map: win PORT MAP (
		 spin_result_latched => slow_spin_result, 
		 bet1_value => bet1_value, 
		 bet2_colour => bet2_colour, 
		 bet3_dozen => bet3_dozen, 
		 bet1_wins => bet1_wins, 
		 bet2_wins => bet2_wins, 
		 bet3_wins => bet3_wins
	 );
	 
	 nb_map: new_balance PORT MAP(
		 money => money,
		 value1 => value1,
		 value2 => value2,
		 value3 => value3,
		 bet1_wins => bet1_wins,
		 bet2_wins => bet2_wins,
		 bet3_wins => bet3_wins,
		 new_money => new_money 
	);
	
	spin_wheel_map: spinwheel PORT MAP(
        fast_clock => CLOCK_50,
        resetb => KEY(1),
        spin_result => fast_spin_result
    );
	 
	 digit_display6: digit7seg PORT MAP (digit => slow_spin_result(3 downto 0), seg7 => HEX6);
	 digit_display7: digit7seg PORT MAP (digit => B"00" & slow_spin_result(5 downto 4), seg7 => HEX7);
	 digit_display0: digit7seg PORT MAP(digit => new_money(3 downto 0), seg7 => HEX0);
    digit_display1: digit7seg PORT MAP(digit => new_money(7 downto 4), seg7 => HEX1);
    digit_display2: digit7seg PORT MAP(digit => new_money(11 downto 8), seg7 => HEX2);



    -- Update LEDs based on wins
    LEDG(0) <= bet1_wins;
	 LEDG(1) <= bet2_wins;
    LEDG(2) <= bet3_wins;
    -- Set other LEDs or use them to indicate other statuses as needed
    LEDG(7 downto 3) <= (others => '0');
	 
	 process(CLOCK_50, KEY(0))
	 begin
		if (rising_edge(CLOCK_50)) then
			if (cooldown = 0) then
				if (NOT(KEY(0)) /= slow_clk) then
					slow_clk <= NOT(KEY(0));
					cooldown <= to_unsigned(12500000, 24); -- 250ms
				end if;
			else
				cooldown <= cooldown - 1;
			end if;
		end if;
	 end process;
	 
	 
	 process(slow_clk, KEY(1))
	 begin
		if (KEY(1) = '0') then
			--reset
			slow_spin_result <= (others => '0');
			bet1_value <= (others => '0');
			bet2_colour <= '0';
			bet3_dozen <= (others => '0');
			value1 <= (others => '0');
			value2 <= (others => '0');
			value3 <= (others => '0');
			money <= to_unsigned(32, 12);

		elsif (rising_edge(slow_clk)) then
			slow_spin_result <= fast_spin_result;
			bet1_value <= unsigned(SW(8 downto 3));
			bet2_colour <= SW(12);
			bet3_dozen <= unsigned(SW(17 downto 16));
			value1 <= unsigned(SW(2 downto 0));
			value2 <= unsigned(SW(11 downto 9));
			value3 <= unsigned(SW(15 downto 13));
			money <= new_money;
		end if;
	 end process;
	 
END behavioural;
