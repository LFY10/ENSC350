library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity part of the description.  Describes inputs and outputs

entity ksa is
  port(CLOCK_50 : in  std_logic;  -- Clock pin
       KEY : in  std_logic_vector(3 downto 0);  -- push button switches
       SW : in  std_logic_vector(17 downto 0);  -- slider switches
		 LEDG : out std_logic_vector(7 downto 0);  -- green lights
		 LEDR : out std_logic_vector(17 downto 0));  -- red lights
end ksa;

-- Architecture part of the description

architecture rtl of ksa is

   -- Declare the component for the ram.  This should match the entity description 
	-- in the entity created by the megawizard. If you followed the instructions in the 
	-- handout exactly, it should match.  If not, look at s_memory.vhd and make the
	-- changes to the component below
	
   COMPONENT s_memory IS
	   PORT (
		   address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		   clock		: IN STD_LOGIC  := '1';
		   data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		   wren		: IN STD_LOGIC ;
		   q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0));
   END component;
	
	COMPONENT m_memory IS
		PORT
		(
			address		: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			clock		: IN STD_LOGIC  := '1';
			data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			wren		: IN STD_LOGIC ;
			q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT rom IS
		PORT
		(
			address		: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			clock		: IN STD_LOGIC  := '1';
			q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
		);
	END COMPONENT;

	-- Enumerated type for the state variable.  You will likely be adding extra
	-- state names here as you complete your design
	
	type state_type is (state_init,
							  state_fill,
							  state_fill_read1,
							  state_fill_read2,
							  state_fill_write,
							  state_dec,
							  state_dec_read1,
							  state_dec_read2,
							  state_dec_read3,
							  state_dec_write1,
							  state_dec_write2,
   	 					  state_done);
							  
	 signal state: state_type := state_init;
								
    -- These are signals that are used to connect to the memory													 
	 signal address : STD_LOGIC_VECTOR (7 DOWNTO 0) := (others => '0');	 
	 signal data : STD_LOGIC_VECTOR (7 DOWNTO 0) := (others => '0');
	 signal wren : STD_LOGIC := '0';
	 signal q : STD_LOGIC_VECTOR (7 DOWNTO 0);	
	 
	 -- (Also functions as the ROM address)
	 signal m_address : STD_LOGIC_VECTOR (4 DOWNTO 0) := (others => '0');	 
	 signal m_data : STD_LOGIC_VECTOR (7 DOWNTO 0) := (others => '0');
	 signal m_wren : STD_LOGIC := '0';
	 signal m_q : STD_LOGIC_VECTOR (7 DOWNTO 0);
	 
	 signal rom_q : STD_LOGIC_VECTOR (7 downto 0);

	 begin
	    -- Include the S memory structurally
		 LEDG <= (others => '0');
		 LEDR <= (others => '0');
	
       u0: s_memory port map (
	        address, CLOCK_50, data, wren, q);
			  
--		 u1: m_memory port map (
--			  m_address, CLOCK_50, m_data, m_wren, m_q);
--			  
--		 r1: rom port map (
--			  m_address, CLOCK_50, rom_q);
			  
       -- write your code here.  As described in the slide set, this 
       -- code will drive the address, data, and wren signals to
       -- fill the memory with the values 0...255
         
       -- You will be likely writing this is a state machine. Ensure
       -- that after the memory is filled, you enter a DONE state which
       -- does nothing but loop back to itself.
		 process(CLOCK_50, KEY(0))
			variable i: unsigned(7 downto 0) := (others => '0');
			variable j: unsigned(7 downto 0) := (others => '0');
			variable mi: unsigned(4 downto 0) := (others => '0');
			variable s1: std_logic_vector(7 downto 0) := (others => '0');
			variable s2: std_logic_vector(7 downto 0) := (others => '0');
			variable offset: unsigned(1 downto 0) := (others => '0');
			variable secret_key: std_logic_vector(23 downto 0) := (others => '0');
		 begin
			if (KEY(0)='0') then
				state <= state_init;
				address <= (others => '0');
				data <= (others => '0');
				wren <= '0';
				m_address <= (others => '0');
				m_data <= (others => '0');
				m_wren <= '0';
				i := (others => '0');
				j := (others => '0');
				mi := (others => '0');
				s1 := (others => '0');
				s2 := (others => '0');
				offset := (others => '0');
				secret_key := (others => '0');
			elsif falling_edge(CLOCK_50) then
				case state is
					when state_init =>
						-- s[i] = i;
						wren <= '1';
						address <= std_logic_vector(i);
						data <= std_logic_vector(i);
						if (i=255) then
							-- start filling out `s`
							-- we have to keep track of an "offset" which is
							-- modulo 3 because computing a modulo by 3 is a lot harder.
							i := to_unsigned(0, 8);
							j := to_unsigned(0, 8);
							offset := to_unsigned(0, 2);
							secret_key := "000000" & SW(17 downto 0);
							state <= state_fill;
						else
							i := i + 1;
						end if;
					when state_fill =>
						-- read s[i]
						wren <= '0';
						address <= std_logic_vector(i);
						state <= state_fill_read1;
					when state_fill_read1 =>
						-- store s[i] for later; compute next j, read s[j]
						s1 := q;
						j := j + unsigned(s1);
						-- the secret keys given in the lab document are big endian, For Some Reason,
						-- and thus require different interpretation of the switches to the output.
						-- This is effectively a requirement because the upper 6 bits are zeroes.
						-- For example, message 1 requires the secret key to be 0x003C5F03 on a little-endian machine,
						-- where `03` must have the upper 6 bits zeroed.
						if (offset=0) then
							j := j + unsigned(secret_key(23 downto 16));
							offset := to_unsigned(1, 2);
						elsif (offset=1) then
							j := j + unsigned(secret_key(15 downto 8));
							offset := to_unsigned(2, 2);
						else
							j := j + unsigned(secret_key(7 downto 0));
							offset := to_unsigned(0, 2);
						end if;
						address <= std_logic_vector(j);
						state <= state_fill_read2;
					when state_fill_read2 =>
						-- store s[j], write to s[j] the value of s[i] (s1)
						s2 := q;
						wren <= '1';
						data <= s1;
						state <= state_fill_write;
					when state_fill_write =>
						-- write to s[i] the value of s[j] (s2), evaluate whether to
						-- terminate the loop.
						data <= s2;
						address <= std_logic_vector(i);
						if (i=255) then
							-- initialize i as 1 because it is incremented
							-- at the start of the loop.
							i := to_unsigned(1, 8);
							j := to_unsigned(0, 8);
							mi := to_unsigned(0, 5);
							state <= state_dec;
						else
							i := i + 1;
							state <= state_fill;
						end if;
					when state_dec =>
						-- read s[i]
						-- previous states might have m_wren or wren
						-- set to 1, so unset them here.
						m_wren <= '0';
						wren <= '0';
						address <= std_logic_vector(i);
						state <= state_dec_read1;
					when state_dec_read1 =>
						-- compute j; read s[j]
						s1 := q;
						j := j + unsigned(s1);
						address <= std_logic_vector(j);
						state <= state_dec_read2;
					when state_dec_read2 =>
						-- get s[j], swap s[i] and s[j]
						-- first, write s[i] to s[j] (address is already j)
						s2 := q;
						wren <= '1';
						data <= s1;
						state <= state_dec_write1;
					when state_dec_write1 =>
						-- write s[j] to s[i]
						data <= s2;
						address <= std_logic_vector(i);
						state <= state_dec_write2;
					when state_dec_write2 =>
						-- read at s[i] + s[j]. we only swapped the two, so we can still
						-- use s1 and s2 to refer to them.
						s1 := std_logic_vector(unsigned(s1) + unsigned(s2));
						wren <= '0';
						address <= s1;
						state <= state_dec_read3;
						-- also get ROM data
						m_address <= std_logic_vector(mi);
					when state_dec_read3 =>
						-- `q` (s[t]) contains keystream, add ciphertext to keystream
						-- by XORing it. We prepared rom_q earlier.
						s1 := rom_q xor q;
						m_wren <= '1';
						-- (not sure if this is necessary)
						m_address <= std_logic_vector(mi);
						m_data <= s1;
						if (mi=31) then
							-- hlt
							state <= state_done;
						else
							i := i + 1;
							mi := mi + 1;
							state <= state_dec;
						end if;
					when state_done =>
						m_wren <= '0';
						wren <= '0';
				end case;
			end if;
		 end process;
end RTL;


