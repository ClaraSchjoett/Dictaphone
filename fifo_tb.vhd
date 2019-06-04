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
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
-- Text from file libraries
use ieee.std_logic_textio.all;
use std.textio.all;

ENTITY fifo_tb IS
END fifo_tb;

ARCHITECTURE behavior OF fifo_tb IS 

	-- generics
	constant ADDR_WIDTH		: positive 		:= 10;
	constant DATA_WIDTH  	: positive 		:= 16;
	
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
	signal imp				: std_logic;
	
	-- Clock period and other time definitions
	constant CLK_PERIOD 	: time := 20 ns;
	
	-- testbench signals
	signal tests_done		: boolean := false;
	signal read_write_done	: boolean := false;

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
			almost_full => almost_full
		);
	
	-- Instantiate strobe generator for read/write signals
	STR: entity work.strobe_gen(rtl)
		generic map(
			INTERVAL	=> 4)
		port map(
			CLK			=> clk,
			RST			=> reset,
			IMP			=> imp);
		
	-- clock and reset generation
	clk <= 		not clk after 0.5 * CLK_PERIOD when not tests_done else 
				'0';
	reset <= 	'1', 
				'0' after 0.25 * CLK_PERIOD,
				'1' after 1.75 * CLK_PERIOD;
	-- testbench process, encapsules stimuli generation process and check results process
	-- TB: process
	-- begin
	
		-- Stimuli generation: Write and successively read process
		STIM : process
			--variable counter : unsigned (DATA_WIDTH-1 downto 0) := (others => '0');
				
			-- File and line buffer declaration
			file dataIn			: text;
			file dataOut 		: text;
			variable line_in	: line;
			variable line_out	: line;
			variable bit_width 	: std_logic_vector(0 to DATA_WIDTH-1);
			
		begin		
			
			wait for CLK_PERIOD * 5;
			wr <= '1';
			rd <= '1';
			
			-- Open source and destination text files
			file_open(dataIn, "data_in.txt", read_mode);	-- dataIn is the file handle for the text file containing test data
			file_open(dataOut,"data_out.txt", write_mode);	-- dataOut is the file handle for the text file where FIFO data is written to
			--wait for CLK_PERIOD * 1;						-- Uncomment to provoke a report from assertion in process CHK.
			
			-- Problem to resolve: loop stops at last entry in dataIn. Which means last entries in dataOut are missing.
			while not endfile(dataIn) loop 					-- line number is looped automatically
			
				readline(dataIn, line_in); 					-- paramenter: file handle, line number (iterated automatically)
				read(line_in, bit_width);					-- tell how many characters to read (16 in this case)
				data_in <= bit_width;						-- Write data to FIFO
				wait for CLK_PERIOD * 1;
				if data_out /= "UUUUUUUUUUUUUUUU" then
					write(line_out, data_out); 				-- Write data in FIFO to line_out
					writeline(dataOut, line_out);			-- Write line_out to text file "data_out.txt"
				end if;
				
			end loop;
			
			-- Close source and destination text files (good practice to close files after use!)
			file_close(dataIn);
			file_close(dataOut);
			
			wait for CLK_PERIOD * 20;
			
			read_write_done <= true;
			
			--wait;
		end process STIM;
		
		-- Monitoring and checks
		CHK: process
		
			-- TODO: how to write report into error log??
			
			-- File and line buffer declaration
			file dataIn				: text;
			file dataOut 			: text;
			file errorLog			: text;
			variable line_in		: line;
			variable line_out		: line;
			variable error_line		: line;
			variable PLACEHOLDER1	: std_logic_vector(0 to DATA_WIDTH-1);
			variable PLACEHOLDER2	: std_logic_vector(0 to DATA_WIDTH-1);
			
			-- Procedure compare used in this process to compare assumed identical lines from dataIn and dataOut
			procedure compare(	variable din : inout std_logic_vector; 
								variable dout: inout std_logic_vector) is
			begin
				-- TODO: write report to log file
				assert  din = dout
				report "Data discrepancy: Data in " & integer'image(to_integer(unsigned(din))) 
				& " is not consistent with data out " & integer'image(to_integer(unsigned(dout)))
				severity error;
			end procedure compare;
			
		begin
		
			-- Pseudo decription: read same line in dataIn and dataOut. Compare the read values. If they are not identical, report an error using assert.
			if read_write_done <= true then
				-- Open source and destination text files
				file_open(dataIn, "data_in.txt", read_mode);	-- dataIn is the file handle for the text file containing test data
				file_open(dataOut,"data_out.txt", read_mode);	-- dataOut is the file handle for the text file where FIFO data was written to
				
				
				while not endfile(dataIn) loop 					-- line number is looped automatically
					--if not endfile(dataOut) then
						readline(dataIn, line_in); 				-- parameter: file handle, line number (iterated automatically)
						read(line_in, PLACEHOLDER1);				

						readline(dataOut, line_in); 			-- parameter: file handle, line number (iterated automatically)
						read(line_in, PLACEHOLDER2);				
						
						compare(PLACEHOLDER1, PLACEHOLDER2);
						
						wait for CLK_PERIOD * 1;
					--end if;
					
				end loop;
				
				-- Close source and destination text files (good practice to close files after use!)
				file_close(dataIn);
				file_close(dataOut);
				
				tests_done <= true;
				wait;
			end if;

		end process CHK;
		
		
	
	--end process TB;
	
END;