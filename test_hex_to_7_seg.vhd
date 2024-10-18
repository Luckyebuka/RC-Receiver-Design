library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

use std.textio.all ;
use ieee.std_logic_textio.all ;

entity test_hex_to_7_seg is
end;

architecture test of test_hex_to_7_seg is
  
component hex_to_7_seg
  port (seven_seg: 		out std_logic_vector(6 downto 0);
	hex:	in std_logic_vector(3 downto 0));
end component;

signal hex_in : unsigned(3 downto 0);
signal seg_out : std_logic_vector(6 downto 0);
signal expected : std_logic_vector(6 downto 0);

begin
  
dev_to_test:  hex_to_7_seg port map(
  seg_out, std_logic_vector(hex_in));
  
seg_out_proc : process(hex_in)
  begin
    case hex_in is
    when x"0" =>
      expected <= "1000000";
    when x"1" =>
      expected <= "1111001";
    when x"2" =>
      expected <= "0100100";
    when x"3" =>
      expected <= "0110000";
    when x"4" =>
      expected <= "0011001";
    when x"5" =>
      expected <= "0010010";
    when x"6" =>
      expected <= "0000010";
    when x"7" =>
      expected <= "1111000";
    when x"8" =>
      expected <= "0000000";
    when x"9" =>
      expected <= "0010000";
    when x"A" =>
      expected <= "0001000";
    when x"B" =>
      expected <= "0000011";
    when x"C" =>
      expected <= "1000110";
    when x"D" =>
      expected <= "0100001";
    when x"E" =>
      expected <= "0000110";
    when x"F" =>
      expected <= "0001110";
    when others =>
      expected <= (others => 'X');
    end case;
end process seg_out_proc;      

stimulus : process

  -- Variables for testbench
  variable ErrCnt : integer := 0 ;
  variable WriteBuf : line ;
  
  begin
    for i in 0 to 15 loop
      hex_in <= to_unsigned(i,4);
      
      wait for 10 ns;
      
      if(seg_out /= expected) then
        write(WriteBuf, string'("ERROR:  7 seg display failed at hex = "));
        write(WriteBuf, std_logic_vector(hex_in));
        
        writeline(Output, WriteBuf);
        ErrCnt := ErrCnt+1;
      end if;
    end loop;
    
    if (ErrCnt = 0) then 
      report "SUCCESS!!!  hex_to_7_seg Test Completed";
	  else
			report "The hex_to_7_seg device is broken" severity warning;
	  end if;

end process stimulus;

end test;