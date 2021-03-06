-------------------------------------------------------------------------------
-- Title      	: 	FSM_MENU
-- Project    	: 	Dictaphone
-------------------------------------------------------------------------------
-- File       	: 	FSM_MENU.vhd
-- Author     	: 	Clara Schjoett
-- Company    	: 	BFH-TI-EKT
-- Created    	: 	2019-05-13
-- Last update	: 	2019-06-10
-- Platform   	: 	Xilinx ISE 14.7
-- Standard   	: 	VHDL'93/02, Math Packages
-------------------------------------------------------------------------------
-- Description	: 	Menu navigation of dictaphone
-------------------------------------------------------------------------------
-- Revisions  	:
-- Date				Version		Author  	Description
-- 2019-05-13		1.0      	Clara		Created
-- 2019-06-07		1.1			Peter		Condition for states changed to fulfill requirements
-- 2019-06-10		1.1			Clara 		Refinements
-------------------------------------------------------------------------------
-- Inputs		:
-- CLK				Onboard system clock
-- RST				Resets the state to default state
-- PLAY				Sets FSM to state PLAYING (debounced impulse, clock cycle duration)
-- RCRD				RECORDING(debounced impulse, clock cycle duration)
-- DLT				DELETING selected track (debounced impulse, clock cycle duration)
-- PLUS				One track forwards (debounced impulse, clock cycle duration)
-- MINUS			One track backwards (debounced impulse, clock cycle duration)
-- REC_PLAY_FINISHED Strobe when recording or track is finished
-- OCCUPIED			Low if selected track is free, high if occupied
--
-- Outputs:
-- DELETE			Delete selected track
-- STATE			Current state of FSM (two bits). '00' = IDLE, '01' = PLAYING, '10' = RECORDING
-- TRACK			Seven segment display control, SEG1 and SEG1
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-------------------------------------------------------------------------------
entity FSM_MENU is

  port (	CLK        			: in std_logic;				-- system clock (50 MHz)
			RST					: in std_logic;				-- asynchronous reset (low active)
			
			PLAY				: in std_logic;				-- button play
			RCRD				: in std_logic;				-- button record
			DLT					: in std_logic;				-- button delete
			PLUS				: in std_logic;				-- button plus
			MINUS				: in std_logic;				-- button minus
			
			REC_PLAY_FINISHED	: in std_logic;				-- Strobe when recording or track is finished
			OCCUPIED			: in std_logic;				-- flag shows if selected track is free (low) or occupied (high)
			
			DELETE				: out std_logic;			-- delete selected track
			STATE				: out std_logic_vector(1 downto 0);
			TRACK				: out std_logic_vector(3 downto 0));

end entity FSM_MENU;
-------------------------------------------------------------------------------
architecture rtl of FSM_MENU is

	type states is (PLAYING, RECORDING, IDLE); 				-- declare new type "states". We don't know how many bits Quartus chooses to represent these states (could be 2 or could be "one hot")
	signal state_next, state_reg: states;					-- state register
	signal track_next, track_number: unsigned(3 downto 0); 

begin -- architecture rtl

	-- state registers for menu state and track number
	REG: process(CLK, RST)									-- reset is asynchronous, thus it must appear in the sensitivity list
	begin --process REG
		if RST = '0' then									-- asynchronous reset (low active)
			state_reg <= IDLE;
			track_number <= "0000";
		elsif CLK'event and CLK = '1' then
			state_reg <= state_next;
			track_number <= track_next;
		end if;
	end process REG;
		
	-- next state logic MUST BE PURELY COMBINATORIAL!
	NSL: process(PLAY, RCRD, DLT, state_reg, OCCUPIED, REC_PLAY_FINISHED)
	begin -- process NSL
		state_next <= state_reg;							-- This assignment is used in case of no button push. Always the last assignment is valid!
		DELETE <= '0';
		case state_reg is
			when IDLE =>									-- when the state is IDLE, the condition for it to change TODO
				if PLAY = '1' and OCCUPIED = '1' then
					state_next <= PLAYING;
				elsif RCRD = '1' and OCCUPIED = '0' then 
					state_next <= RECORDING;
				elsif DLT = '1' and OCCUPIED = '1' then
					DELETE <= '1';
				end if;
			when PLAYING =>									-- when the state is PLAYING, go back to IDLE when strobe at REC_PLAY_FINISHED
				if REC_PLAY_FINISHED = '1' then 
					state_next <= IDLE;
				end if;
			when RECORDING =>								-- when the state is RECORDING, go back to IDLE when strobe at REC_PLAY_FINISHED
				if REC_PLAY_FINISHED = '1' then
					state_next <= IDLE;
				end if;
			when others => null;
		end case;
	end process NSL;
	
	-- selected signal assigment, concurrent form
	with state_reg select 									-- assing output value to STATE, depending on the current state
		STATE <= "00" when IDLE,
				 "01" when PLAYING,
				 "10" when RECORDING,
				 "00" when others;		
				 
	-- Track number control, must be purely combinatorial!
	TRACK_PROC: process(PLUS, MINUS, track_number, state_reg)
	begin -- process TRACK_PROC
		track_next <= track_number;
		if state_reg = IDLE	then							-- only change track in IDLE
			if PLUS = '1' then
				track_next <= track_number + 1; 			-- If no overflow, increment variable track_number
				if track_number = 15 then					-- Check for overflow
					track_next <= "0000";
				end if;										-- variableA := variableA + 1; NOT ALLOWED
			elsif MINUS = '1' then
				track_next <= track_number - 1;				-- If no underflow, decrement variable track_number
				if track_number = 0	then					-- Check for underflow
					track_next <= "1111";
				end if;
			end if;
		end if;
	end process TRACK_PROC;
		
	-- evalutation of current track number for display on SSD
	TRACK <= std_logic_vector(track_number);				-- Typecast from unsigned to std_logic_vector

end architecture rtl;