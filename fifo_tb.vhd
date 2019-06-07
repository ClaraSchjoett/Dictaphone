-------------------------------------------------------------------------------
-- Title      	: 	fifo_tb
-- Project    	: 	Dictaphone
-------------------------------------------------------------------------------
-- File       	: 	fifo_tb.vhd
-- Author     	: 	Clara Schjoett
-- Company    	: 	BFH
-- Created    	: 	2019-06-01
-- Last update	: 	2019
-- Platform   	: 	Xilinx ISE 14.7
-- Standard   	: 	VHDL'93/02, Math Packages
-- Sources		:	http://www.deathbylogic.com/2013/07/vhdl-standard-fifo/
-------------------------------------------------------------------------------
-- Description	: 	Testbench for standard FIFO-Buffer
-------------------------------------------------------------------------------
-- Revisions  	:
-- Date        		Version		Author		Description
-- 2019-06-01		1.0			Clara		Created
-- 2019-06-02		1.1			Clara		Text I/O from files implemented
-- 2019-06-07		1.1			Clara		Required functionalities implemented
-------------------------------------------------------------------------------
-- Inputs		:
-- clk				Audio sampling rate
-- reset			Resets the internal pointers and sets data to zero
-- data_in			Input Data
-- wr				write input: if wr is high, data_in is written on positive edge of clk
-- rs				read input: if rd is high, data appears on data_out on positive edge of clk
--
-- Outputs		:
-- data_out			Output Data
-- full				is high if fifo-buffer is full
-- empty			is high if fifo-buffer is empty
-- almost_full		is high if fifo-buffer is more than 75% full
-- almost_empty		is high if fifo-buffer is less than 25% full
-------------------------------------------------------------------------------

LIBRARY IEEE;
-- needed for std_logic data types
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
-- Text from file libraries, needed for calls to WRITE(LINE, std_logic)
use ieee.std_logic_textio.all;
-- needed for the write and read calls
use std.textio.all;

ENTITY fifo_tb IS
END fifo_tb;

ARCHITECTURE behavior OF fifo_tb IS 

	-- generics
	constant ADDR_WIDTH		: positive := 10;
	constant DATA_WIDTH  	: positive := 16;
	
	--Inputs
	signal clk				: std_logic := '0';
	signal reset			: std_logic := '1';
	signal data_in			: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal rd				: std_logic := '0';
	signal wr				: std_logic := '0';
	
	--Outputs
	signal data_out			: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal empty			: std_logic;
	signal full				: std_logic;
	signal almost_empty		: std_logic;
	signal almost_full		: std_logic;
	
	-- Clock period and other time definitions
	constant CLK_PERIOD 	: time := 20 ns;
	
	-- testbench signals
	signal tests_done		: boolean := false; -- true when all test bench processes are finished
	signal write_done		: boolean := false;	-- true when process writing to FIFO is finished
	signal read_done		: boolean := false;	-- true when process reading from FIFO is finished
	signal seq				: std_logic_vector(0 to 2);
	signal seq_r			: std_logic_vector(0 to 2) := "000";
	signal seq_w			: std_logic_vector(0 to 2) := "000";
	
	
BEGIN
	-- Instantiate the Device Under Test (DUT)
	DUT: entity work.fifo
		PORT MAP (
			clk			=> clk,
			reset		=> reset,
			data_in		=> data_in,
			wr			=> wr,
			rd			=> rd,
			data_out	=> data_out,
			full		=> full,
			empty		=> empty,
			almost_empty=> almost_empty,
			almost_full => almost_full);
		
	-- clock and reset generation
	clk <= 		not clk after 0.5 * CLK_PERIOD when not tests_done else 
				'0';
	reset <= 	'1', 
				'0' after 0.25 * CLK_PERIOD,
				'1' after 1.75 * CLK_PERIOD;
	
	-- Compares seq_w and seq_r, assigns larger value to seq (if statement must be within a process)
	MAX_PROC : process(CLK)
	begin
		if unsigned(seq_w) > unsigned(seq_r) then
			seq <= seq_w;
		else
			seq <= seq_r;
		end if;
	end process MAX_PROC;
	
	-- Stimuli generation: Write into FIFO
	WRITE_PROC : process		
		-- File and line buffer declaration
		file dataIn			: text;
		variable line_in	: line;
		variable data 		: std_logic_vector(DATA_WIDTH-1 downto 0);	
	begin		
		
		wait for CLK_PERIOD * 3;						-- wait for reset
	
		-- Open source text file
		file_open(dataIn, "data_in.txt", read_mode);	-- dataIn is the file handle for the text file containing test data
		
		-- SEQUENCE 0
		-- This while loop writes data with system clock rate into FIFO
		if seq = "000" then								-- Sequence is incremented when FIFO is full
			L1 : loop
				exit L1 when seq > "000";
				if not endfile(dataIn) then
					readline(dataIn, line_in); 			-- parameter: file handle, line number (iterated automatically)
					read(line_in, data);					
					wait until rising_edge(clk);
						wr <= '1';
						data_in <= data;				-- Write data to FIFO
				end if;
				if full = '1' then
					seq_w <= "001";						-- Increment sequence to 1	
				end if;
			end loop;
			wr <= '0';
		end if;
		
		-- SEQUENCE 1
		wait until empty = '1';
		seq_w <= "010";									-- Increment sequence to 2
		wait for CLK_PERIOD * 1;
	
		-- SEQUENCE 2, 3, 4 and 5
		-- This while loop writes data with 1/3 system clock rate into FIFO
		if seq > "001" and seq < "110" then				-- Sequence is incremented by reading process
			L2 : loop									
				exit L2 when seq > "101";
				wait until rising_edge(CLK);
				wr <= '0';
				wait until rising_edge(CLK);
				wait until rising_edge(CLK);
					if not endfile(dataIn) then
						readline(dataIn, line_in); 		-- parameter: file handle, line number (iterated automatically)
						read(line_in, data);					
							wr <= '1';
							data_in <= data;			-- Write data to FIFO
					end if;
				if almost_full = '1' and seq = "010" then
					seq_w <= "011";							-- Increment sequence to 3
				end if;
				if almost_full = '1' and seq = "100" then	
					seq_w <= "101";							-- Increment sequence to 5
				end if;	
			end loop;
			wr <= '0';
		end if;
					
		file_close(dataIn);								-- Close text file (good practice to close files after use!)
		
		write_done <= true;								-- Set flag for CHK process
		
		--wait;	-- forever, do not repeat process
	end process WRITE_PROC;
	
	-- Stimuli generation: Read out of FIFO
	READ_PROC: process
		-- File and line buffer declaration
		file dataOut 		: text;
		variable line_out	: line;
	begin
		
		wait for CLK_PERIOD * 8;						-- wait for reset and valid value in FIFO
		
		-- Open destination text file
		file_open(dataOut,"data_out.txt", write_mode);	-- dataOut is the file handle for the text file where FIFO data is written to
		
		-- SEQUENCE 0 and 1
		-- This while loop reads data from FIFO with 1/3 of system clock rate
		if seq = "000" or seq = "001" then
			L1: loop 										-- line number is looped automatically
				exit L1 when seq > "001";
				wait until rising_edge(CLK);
				
				wait until rising_edge(CLK);
				rd <= '1';									-- rd must be '1' on pos. clock edge to clock out data
				wait until rising_edge(CLK);				-- Data is clocked out because rd is '1'
				if data_out /= "UUUUUUUUUUUUUUUU" then
					rd <= '1';
					write(line_out, data_out); 				-- Write data in FIFO to line_out
					writeline(dataOut, line_out);			-- Write line_out to text file "data_out.txt"
				end if;
				rd <= '0';
			end loop;
		end if;
		
		wait for CLK_PERIOD * 1;
		
		-- SEQUENCE 3		
		-- This while loop reads data from FIFO with system clock rate
		if seq = "011" then
			L2: loop										
				exit L2 when seq = "100"; 
				rd <= '1';
				wait until rising_edge(CLK);				-- Data is clocked out because rd is '1'
				if data_out /= "UUUUUUUUUUUUUUUU" then
					rd <= '1';
					write(line_out, data_out); 				-- Write data in FIFO to line_out
					writeline(dataOut, line_out);			-- Write line_out to text file "data_out.txt"
				end if;
				rd <= '0';
				if almost_empty = '1' and seq = "011" then
					seq_r <= "100"; 							--4
				end if;
			end loop;
		end if;
		
		-- SEQUENCE 5		
		-- This while loop reads data from FIFO with system clock rate
		if seq = "101" then
			L3: loop	
				exit L3 when seq > "101";
				rd <= '1';
				wait until rising_edge(CLK);				-- Data is clocked out because rd is '1'
				if data_out /= "UUUUUUUUUUUUUUUU" then
					rd <= '1';
					write(line_out, data_out); 				-- Write data in FIFO to line_out
					writeline(dataOut, line_out);			-- Write line_out to text file "data_out.txt"
				end if;
				rd <= '0';
				if almost_empty = '1' and seq = "101" then
					seq_r <= "110";								--6;
				end if;
			end loop;
		end if;
		
		wait for CLK_PERIOD * 1;
		
		file_close(dataOut);
		
		read_done <= true;									-- Set flag for CHK process
		
		--wait;	-- forever, do not repeat process
	end process READ_PROC;
	
	-- Monitoring and checks
	CHK: process
	
		-- File and line buffer declaration
		file dataIn				: text;
		file dataOut 			: text;
		variable line_in		: line;
		variable line_out		: line;
		variable PLACEHOLDER1	: std_logic_vector(0 to DATA_WIDTH-1);
		variable PLACEHOLDER2	: std_logic_vector(0 to DATA_WIDTH-1);
		
		-- Procedure compare used in this process to compare assumed identical lines from data_in.txt and data_out.txt
		procedure compare(	variable din : inout std_logic_vector; 
							variable dout: inout std_logic_vector) is
		begin
			assert  din = dout
			report "Data discrepancy: Data in " & integer'image(to_integer(unsigned(din))) 
			& " is not consistent with data out " & integer'image(to_integer(unsigned(dout)))
			severity error;
		end procedure compare;
		
	begin
	
		-- Pseudo decription: read same line in dataIn and dataOut. Compare the read values. If they are not identical, report an error using assert.
		wait until write_done = true and read_done = true;
		wait for CLK_PERIOD * 20;
			-- Open source and destination text files
			file_open(dataIn, "data_in.txt", read_mode);	-- dataIn is the file handle for the text file containing test data
			file_open(dataOut,"data_out.txt", read_mode);	-- dataOut is the file handle for the text file where FIFO data was written to
			
			
			while not endfile(dataOut) loop 				-- line number is looped automatically
					readline(dataIn, line_in); 				-- parameter: file handle, line number (iterated automatically)
					read(line_in, PLACEHOLDER1);				

					readline(dataOut, line_in); 			-- parameter: file handle, line number (iterated automatically)
					read(line_in, PLACEHOLDER2);				
					
					compare(PLACEHOLDER1, PLACEHOLDER2);
					
					wait for CLK_PERIOD * 1;
				
			end loop;
			
			-- Close source and destination text files (good practice to close files after use!)
			file_close(dataIn);
			file_close(dataOut);
			
			tests_done <= true;
			wait;

	end process CHK;
	
END;