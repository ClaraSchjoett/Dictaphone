-------------------------------------------------------------------------------
-- Title      	: 	MEM_CTRL
-- Project    	: 	Dictaphone
-------------------------------------------------------------------------------
-- File       	: 	MEM_CTRL.vhd
-- Author     	: 	Peter Wüthrich
-- Company    	: 	BFH
-- Created    	: 	2019-06-07
-- Last update	: 	
-- Platform   	: 	Xilinx ISE 14.7
-- Standard   	: 	VHDL'93/02, Math Packages
-------------------------------------------------------------------------------
-- Description	: 	memory controller for sdram 
-------------------------------------------------------------------------------
-- Revisions  	:
-- Date        		Version  	Author  	Description
-- 2019-06-07		1.0			Peter		Created
-- 2019-06-09		1.1			Peter		Debugged, added lots of comments
-- 2019-06-09		1.1			Clara		Syntax errors corrected, compiled
-------------------------------------------------------------------------------
-- Inputs		:
-- CLK				Onboard system clock
-- RST				Resets the state to default state
-- STATE			Current state (from FSM_MENU)
-- TRACK			Current track number (from FSM_MENU)
-- DELETE			Delete selected track from SDRAM and update S_OCCUPIED

-- FIFO_I_EMPTY		high when input fifo empty
-- FIFO_I_ALMOST_FULL high when input fifo more than 3/4 full	
-- FIFO_O_EMPTY		high when output fifo empty
-- FIFO_O_ALMOST_FULL high when output fifo more than 3/4 full

-- cmd_ready		new command can be processed (from SDRAM)
-- data_out_ready	new data from SDRAM is ready (from SDRAM)
			
--
-- Outputs		:
-- REC_PLAY_FINISHED high pulse when one track is finished (to FSM_MENU)
-- OCCUPIED			high when current track is occupied (to DEC2SSD)
-- FREE_SLOTS		number of free slots (to DEC2SSD)

-- FIFO_I_RD 		high when reading from input fifo
-- FIFO_I_WR		high when writing to input fifo
-- FIFO_I_CLR		high when clearing input fifo

-- FIFO_O_RD		high when reading from output fifo
-- FIFO_I_WR		high when writing to output fifo

-- cmd_strobe		high (one clk cycle) when issuing a new read/write command (to SDRAM=
-- cmd_wr			high (one clk cycle) when write access required (to SDRAM)
-- cmd_address		SDRAM address to write at (to SDRAM)
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--use IEEE.std_logic_arith.all; 
--This library caused an error message. 
-- Here is the solution: https://www.edaboard.com/showthread.php?272826-more-thn-one-UseClause-imports-declaration-of-simple-name-quot-unsigned-quot-none-of-the-dec
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Own packages
use work.gecko4_education_pkg.all;


entity MEM_CTRL is
	Port (	CLK 				: in std_logic;						-- system clock (50 MHz)
			RST 				: in std_logic;						-- reset signal (low-active)
			
			STATE				: in std_logic_vector(1 downto 0);	-- 00 --> IDLE, 01 --> PLAYING, 02 --> RECORDING
			TRACK				: in std_logic_vector(3 downto 0);	-- track number, is equivalent with the 4 MSBs of the SDRAM address
			DELETE				: in std_logic;						-- high pulse deletes selected track
			REC_PLAY_FINISHED	: out std_logic;					-- is high when playing/recording finished and changes
																		-- back to low when state has changed to IDLE
			
			TEST_LED			: out std_logic;
			
			
			OCCUPIED			: out std_logic;					-- is high if selected track is occupied
			FREE_SLOTS			: out std_logic_vector(4 downto 0);	-- Number of free tracks to display on SSD
			
			FIFO_I_EMPTY		: in std_logic;						-- input fifo empty
			FIFO_I_ALMOST_FULL	: in std_logic;						-- input fifo more than 75% full
			FIFO_I_RD			: out std_logic;					-- read data from intput fifo
			FIFO_I_WR			: out std_logic;					-- enable writing data from mic into input fifo
			FIFO_I_CLR			: out std_logic;					-- clear input fifo (high active)
			
			FIFO_O_EMPTY		: in std_logic;						-- output fifo empty
			FIFO_O_ALMOST_FULL	: in std_logic;						-- output fifo more than 75% full
			FIFO_O_RD			: out std_logic;					-- enable reading data from output fifo to loudspeaker
			FIFO_O_WR			: out std_logic;					-- write data into output fifo
			
			cmd_ready			: in std_logic;						-- new command can be processed
			cmd_strobe			: out std_logic;					-- issue a new read/write command
			cmd_wr				: out std_logic;					-- write access
			cmd_address			: out unsigned(23 downto 0);		-- word address for read/write
			
			data_out_ready		: in std_logic);					-- new data from SDRAM is ready

end entity MEM_CTRL;

architecture str of MEM_CTRL is

	signal S_OCCUPIED		: std_logic_vector(15 downto 0);	-- each bit represents a memory block for one track. 1: occupied, 0: free 
	signal S_ADDRESS		: unsigned(19 downto 0);			-- SDRAM address without first 4 bits which represent the track
	
	signal S_WR_IN_PROGR	: std_logic;						-- writing a word into SDRAM
	signal S_WR_DONE		: std_logic;						-- finished writing a word into SDRAM
	signal S_RD_FROM_FIFO	: std_logic;						-- goes to high when input fifo is 75% full, goes to low when empty,
																	-- so reading from fifo starts after buffering enough data
	
	signal S_RD_IN_PROGR	: std_logic;						-- reading a word from SDRAM
	signal S_PLAYING		: std_logic;						-- playing data from output fifo to loudspeaker

	signal S_FIFO_O_WR		: std_logic;
	
	signal S_ALL_DATA_READ	: std_logic;
	--constants representing states
	constant IDLE		: std_logic_vector(1 downto 0)	:= "00";
	constant PLAYING	: std_logic_vector(1 downto 0)	:= "01";
	constant RECORDING	: std_logic_vector(1 downto 0)	:= "10";

begin

	
	-- assign inputs and outputs
	-- TODO
	FIFO_O_WR <= S_FIFO_O_WR;
	TEST_LED <= S_RD_IN_PROGR;
	
	process(CLK, RST, STATE)
		
	begin
		if RST = '0' then
			REC_PLAY_FINISHED	<= '0';
			OCCUPIED			<= '0';
			FIFO_I_RD			<= '0';
			FIFO_I_WR			<= '0';
			FIFO_I_CLR			<= '0';
			FIFO_O_RD			<= '0';
			S_FIFO_O_WR			<= '0';
			cmd_strobe			<= '0';
			cmd_wr				<= '0';
			cmd_address			<= (others => '0');
			
			S_OCCUPIED			<= (others => '0');
			S_ADDRESS			<= (others => '0');
			
			S_WR_IN_PROGR		<= '0';
			S_WR_DONE			<= '0';
			S_RD_FROM_FIFO		<= '0';
			
			S_RD_IN_PROGR		<= '0';
			S_PLAYING			<= '0';
			S_ALL_DATA_READ		<= '0';
			
		elsif rising_edge(CLK) then
		
			-- Off by default (do not read/write)
			cmd_strobe <= '0';
			-- Zero by default
			FIFO_I_RD <= '0';
			S_FIFO_O_WR <= '0';

			OCCUPIED <= S_OCCUPIED(to_integer(unsigned(TRACK)));	-- set or reset corresponding bit in OCCUPIED bit vector
			
			if STATE = RECORDING then
				cmd_address <= unsigned(TRACK & std_logic_vector(S_ADDRESS));
				
				if S_ADDRESS = x"00000" then 						-- at the beginning
					FIFO_I_WR <= '1';								-- start buffering data into fifo
					FIFO_I_CLR <= '0';								-- release reset of fifo buffer
				end if;

				if FIFO_I_ALMOST_FULL = '1' then					-- wait until the fifo buffer is almost full
					S_RD_FROM_FIFO <= '1';							-- then start reading process until fifo is empty
				end if;
				
				if FIFO_I_EMPTY = '1' then							--when fifo is empty stop reading data and wait until its almost full again
					S_RD_FROM_FIFO <= '0';
				end if;
				

				--this blocks reads one word from the in fifo and writes it into the SDRAM
				if S_RD_FROM_FIFO = '1' then
				
					-- first get the data from the fifo (RD to high and back to low)
					if S_WR_IN_PROGR = '0' then
						S_WR_IN_PROGR <= '1';
						FIFO_I_RD <= '1';
					end if;
					-- if FIFO_I_RD = '1' then							-- FIFO_I_RD must be high for only one cycle, so only one word gets clocked out
						-- FIFO_I_RD <= '0';
					-- end if;
					
					
					
					if S_WR_IN_PROGR = '1' then						-- when data from fifo is ready 
						if cmd_ready = '1' then						-- wait for SDRAM until its ready for a new command
							cmd_wr <= '1';							-- write word into SDRAM
							cmd_strobe <= '1';
							S_WR_IN_PROGR <= '0';
							S_WR_DONE <= '1';						-- signs that write is done and address can be changed in the next cycle
						end if;
						
					elsif S_WR_DONE = '1' then						-- when word has been written into fifo, increment address
						cmd_wr <= '0';
						cmd_strobe <= '0';
						S_WR_DONE <= '0';
						
						if S_ADDRESS < x"FFFFF" then
							S_ADDRESS <= S_ADDRESS + 1;
						else										-- recording track is finished
							S_ADDRESS <= (others => '0');			-- reset address
							FIFO_I_CLR <= '1';						-- clear input fifo
							S_OCCUPIED(to_integer(unsigned(TRACK))) <= '1';	-- set flag 
							FIFO_I_WR <= '0';						-- stop buffering data
							REC_PLAY_FINISHED <= '1';				-- this output shows that state can be changed to idle
						end if;
						
					end if;
				end if;
				

			elsif STATE = PLAYING then

				--wait for cmd ready. if fifo almost full, wait until some data has been clocked out of fifo
				if cmd_ready = '1' and S_RD_IN_PROGR = '0' and FIFO_O_ALMOST_FULL = '0' and S_ALL_DATA_READ = '0' then
					cmd_address <= unsigned(TRACK & std_logic_vector(S_ADDRESS));
					cmd_strobe <= '1';						-- give read command to SDRAM. Must be high for only one cycle, so it gets cleared in the next block
					S_RD_IN_PROGR <= '1';
				end if;
				

				
				if S_RD_IN_PROGR = '1' then					-- read one word from SDRAM
					cmd_strobe <= '0';						-- reset read command flag (it has been set the cycle before
					if data_out_ready = '1' then			-- wait until data from SDRAM is ready
						S_FIFO_O_WR <= '1';					-- write word into output fifo
					end if;
					
					if S_FIFO_O_WR = '1' then					-- when word has been written into fifo
						S_FIFO_O_WR <= '0';
						S_RD_IN_PROGR <= '0';
						
						if S_ADDRESS < x"FFFFF" then		-- increment address
							S_ADDRESS <= S_ADDRESS + 1;
						else								-- when whole track has been shifted to fifo
							S_ADDRESS <= (others => '0');
							S_ALL_DATA_READ <= '1';
							--REC_PLAY_FINISHED <= '1';		-- not yet because probably there is some rest data in fifo, so playing has not finished yet
						end if;
					end if;
				end if;
				
				--when enough data is in fifo, start playing
				if FIFO_O_ALMOST_FULL = '1' then
					FIFO_O_RD <= '1';
					S_PLAYING <= '1';
				end if;
				
				--when fifo is empty, whole track has been played, so state can be changed to IDLE
				if FIFO_O_EMPTY = '1' and S_PLAYING = '1' then
					FIFO_O_RD <= '0';
					S_PLAYING <= '0';
					S_ALL_DATA_READ <= '0';
					cmd_strobe <= '0';
					S_RD_IN_PROGR <= '0';
					S_FIFO_O_WR <= '0';
					S_ADDRESS <= (others => '0');
					REC_PLAY_FINISHED <= '1';
				end if;


			elsif STATE = IDLE then
				REC_PLAY_FINISHED <= '0';					-- FSM has changed STATE, so flag can be reseted
				if DELETE = '1' then						-- delete chosen track
					S_OCCUPIED(to_integer(unsigned(TRACK))) <= '0';	-- set corresponding occupied flag to FREE
				end if;
				cmd_strobe <= '0';
				S_RD_IN_PROGR <= '0';
				
				
			end if;
		end if;
	end process;
	
	-- This process re-calculates number of free slots on every change of signal S_OCCUPIED
	-- Type: combinational
	-- Source: https://vhdlguru.blogspot.com/2017/10/count-number-of-1s-in-binary-number.html
	FREE_PROC: process(S_OCCUPIED)
		variable count : unsigned(4 downto 0) := "00000";
	begin --process FREE_S
		count := "00000";   								-- initialize count variable
		for i in 0 to 15 loop   							-- for all the bits
			if(S_OCCUPIED(i) = '0') then 					--check if the bit is '0'
				count := count + 1; 						--if it's zero, increment the count.
			end if;		
		end loop;
		FREE_SLOTS <= std_logic_vector(count);    			-- assign the count to output
	end process FREE_PROC;

end; -- architecture str
