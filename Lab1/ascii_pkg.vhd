library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package ascii_pkg is
    function decimal_to_ascii(val : integer) return std_logic_vector;
end package;

package body ascii_pkg is
    function decimal_to_ascii(val : integer) return std_logic_vector is
        variable ascii_val : std_logic_vector(7 downto 0);
    begin
        case val is
            when 0 => ascii_val := "00110000"; -- ASCII for '0'
            when 1 => ascii_val := "00110001"; -- ASCII for '1'
            when 2 => ascii_val := "00110010"; -- ASCII for '2'
            when 3 => ascii_val := "00110011"; -- ASCII for '3'
            when 4 => ascii_val := "00110100"; -- ASCII for '4'
            when 5 => ascii_val := "00110101"; -- ASCII for '5'
            when 6 => ascii_val := "00110110"; -- ASCII for '6'
            when 7 => ascii_val := "00110111"; -- ASCII for '7'
            when 8 => ascii_val := "00111000"; -- ASCII for '8'
            when 9 => ascii_val := "00111001"; -- ASCII for '9'
				when 10 => ascii_val := "01000001"; -- ASCII for 'A'
            when 11 => ascii_val := "01000010"; -- ASCII for 'B'
            when 12 => ascii_val := "01000011"; -- ASCII for 'C'
            when 13 => ascii_val := "01000100"; -- ASCII for 'D'
            when 14 => ascii_val := "01000101"; -- ASCII for 'E'
            when 15 => ascii_val := "01000110"; -- ASCII for 'F'
            when 16 => ascii_val := "01000111"; -- ASCII for 'G'
            when others => ascii_val := "00111111"; -- ASCII for '?' (unknown)
        

        end case;
        return ascii_val;
    end function;
end package body;
