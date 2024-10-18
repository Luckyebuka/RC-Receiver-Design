-- UART receiver testbench
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

use std.textio.all ;
use ieee.std_logic_textio.all ;
use work.sim_mem_init.all;

entity test_rUART is
end;

architecture test of test_rUART is
  
component tUART
generic(
	baud 						: integer := 19200);
port (
	data_out					: out std_logic;
	start						: in std_logic;
	data_in						: in std_logic_vector(7 downto 0);
	reset						: in std_logic;
	clk							: in std_logic);
end component;

component rUART
generic (
	baud 						: integer := 19200);
port (
	data_out					: out std_logic_vector(7 downto 0);
	data_valid					: out std_logic;
	data_in						: in std_logic;
	reset						: in std_logic;
	clk							: in std_logic);
end component;

constant baud 					: integer := 9600;
signal data_line 				: std_logic;
signal recv_out 				: std_logic_vector(7 downto 0) := (others => '0');
signal data_valid 				: std_logic := '0';
signal start 					: std_logic := '1';
signal data_in 					: std_logic_vector(7 downto 0) := (others => '0');
signal reset 					: std_logic := '1';
signal clk 						: std_logic := '0';

constant in_fname 				: string := "rUART_input.csv";
file input_file					: text;

begin
	-- use the tranmitter design in testing the receiver
	dev_to_test:  tUART 
		generic map(baud)
		port map(data_line, start, data_in, reset, clk); 
	recv_under_test: rUART
		generic map(baud)
		port map(recv_out, data_valid, data_line, reset, clk);
	
	clk_proc : process
	begin
		wait for 10 ns;
		clk <= not clk;
	end process clk_proc;
	
	stimulus:  process
	variable input_line			: line;
	variable in_char			: character;
	variable in_slv				: std_logic_vector(7 downto 0);
	variable WriteBuf 			: line ;
	variable ErrCnt 			: integer := 0;
	
	begin
		file_open(input_file, in_fname, read_mode);

		while not(endfile(input_file)) loop
			readline(input_file,input_line);
				
			-- let's read the first character in the row
			read(input_line,in_char);
			in_slv := std_logic_vector(to_unsigned(character'pos(in_char),8));
			data_in(7 downto 4) <= ASCII_to_hex(in_slv);
			read(input_line,in_char);
			in_slv := std_logic_vector(to_unsigned(character'pos(in_char),8));
			data_in(3 downto 0) <= ASCII_to_hex(in_slv);
				
			-- assert the start signal
			wait for 20 ns;
			start <= '0';
			wait for 20 ns;
			start <= '1';
				
			-- We wait until the UARTreceiver is done 
			-- receiving the data
			wait until data_valid = '1';
			wait for 60 us;
			
			if(data_in /= recv_out) then
				write(WriteBuf, string'("ERROR:  UART receiver failed, received data = "));
				write(WriteBuf, recv_out);
				write(WriteBuf, string'(".  expected = "));
				write(WriteBuf, std_logic_vector(data_in));
				
				writeline(Output, WriteBuf);
				ErrCnt := ErrCnt+1;
			end if;
			
		end loop;
		
		file_close(input_file);

		if (ErrCnt = 0) then 
			report "SUCCESS!!!  UART Test Completed";
		else
			report "UART receiver is broken" severity warning;
		end if;			
	end process stimulus;
end test;