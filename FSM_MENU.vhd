-------------------------------------------------------------------------------
-- Title      	: 	FSM_MENU
-- Project    	: 	Dictaphone
-------------------------------------------------------------------------------
-- File       	: 	FSM_MENU.vhd
-- Author     	: 	Clara Schjoett
-- Company    	: 	BFH-TI-EKT
-- Created    	: 	2019-05-13
-- Last update	: 	2019-05-29
-- Platform   	: 	Xilinx ISE 14.7
-- Standard   	: 	VHDL'93/02, Math Packages
-------------------------------------------------------------------------------
-- Description	: 	Finite State Machine for menu management of dictaphone
-------------------------------------------------------------------------------
-- Revisions  	:
-- Date				Version		Author  	Description
-- 2019-05-13		1.0      	Clara		Created
-------------------------------------------------------------------------------
-- Inputs		:
-- CLK				Onboard system clock
-- RST				Resets the state to default state
-- PLAY				Sets FSM to state PLAYING (debounced impulse, clock cycle duration)
-- RCRD				RECORDING(debounced impulse, clock cycle duration)
-- DLT				DELETING selected track (debounced impulse, clock cycle duration)
-- PLUS				One track forwards (debounced impulse, clock cycle duration)
-- MINUS			One track backwards (debounced impulse, clock cycle duration)
--
-- Outputs:
-- STATE			Current state of FSM (two bits). '00' = static (default), '01' = dynamic, '10' = xy-diagram
-- BCD				Seven segment display control. First 5 bits = track no. Last 5 bits = free slots.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------

entity FSM_MENU is

  port (	CLK        	: in std_logic;   
			RST			: in std_logic;
			PLAY		: in std_logic;
			RCRD		: in std_logic;
			DLT			: in std_logic;		
			PLUS		: in std_logic;
			MINUS		: in std_logic;
			STATE		: out std_logic_vector(1 downto 0);
			BCD			: out std_logic_vector(9 downto 0));	 

end entity FSM_MENU;

-------------------------------------------------------------------------------

architecture rtl of FSM_MENU is

	type states is (PLAYING, RECORDING, DELETING, IDLE); 	-- declare new type "states". We don't know how many bits Quartus chooses to represent these states (could be 2 or could be "one hot")
	signal state_next, state_reg: states;					-- state register
	signal track_next, track_number: unsigned(4 downto 0); -- := "00001";

begin -- architecture rtl

	-- state registers for menu state and track number
	REG: process(CLK, RST)									-- reset is asynchronous, thus it must appear in the sensitivity list
	begin --process REG
		if RST = '0' then									-- asynchronous reset (low active)
			state_reg <= IDLE;
			track_number <= "00001";
		elsif CLK'event and CLK = '1' then
			state_reg <= state_next;
			track_number <= track_next;
		end if;
	end process REG;
		
	-- next state logic MUST BE PURELY COMBINATORIAL!
	NSL: process(PLAY, RCRD, DLT, state_reg)
	begin -- process Next State Logic
		state_next <= state_reg;							-- This assignment is used in case of no button push. Always the last assignment is valid!
		case state_reg is
			when IDLE =>									-- when the state is IDLE, the condition for it to change TODO
				-- TODO
				-- Test lines, adjust 
				if PLAY = '1' then
					state_next <= PLAYING;
				elsif RCRD = '1' then 
					state_next <= RECORDING;
				elsif DLT = '1' then
					state_next <= DELETING;
				end if;
			when PLAYING =>									-- when the state is PLAYING, the condition for it to change TODO
				-- TODO
			when RECORDING =>								-- when the state is RECORDING, the condition for it to change TODO
				-- TODO
			when DELETING =>								-- when the state is DELETING, the condition for it to change TODO
				-- TODO
			when others => null;
		end case;
	end process NSL;
	
	-- selected signal assigment, concurrent form
	with state_reg select 									-- assing output value to STATE, depending on the current state
		STATE <= "00" when IDLE,
		         "01" when PLAYING,
				 "10" when RECORDING,
				 "11" when DELETING,
				 "00" when others;		
				 
	-- Track number control, must be purely combinatorial!
	TRACK: process(PLUS, MINUS, track_number)
	begin -- process TRACK
		track_next <= track_number;
		if PLUS = '1' then
			track_next <= track_number + 1; 				-- If no overflow, increment variable track_number
			if track_number = 16 then						-- Check for overflow
				track_next <= "00001";
			end if;											-- variableA := variableA + 1; NOT ALLOWED
		elsif MINUS = '1' then
			track_next <= track_number - 1;					-- If no underflow, decrement variable track_number
			if track_number = 1	then						-- Check for underflow
				track_next <= "10000";
			end if;
		end if;
	end process;
	
	-- TODO: memory management, evaluation of current track number
	
	-- evalutation of current track number for display on SSD
	BCD(9 downto 5) <= std_logic_vector(track_number);
	-- test line, delete when finished
	BCD(4 downto 0) <= std_logic_vector(track_number);

end architecture rtl;