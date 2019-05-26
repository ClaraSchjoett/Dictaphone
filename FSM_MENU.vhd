-------------------------------------------------------------------------------
-- Title      	: 	FSM_MENU
-- Project    	: 	Dictaphone
-------------------------------------------------------------------------------
-- File       	: 	FSM_MENU.vhd
-- Author     	: 	Clara Schjoett
-- Company    	: 	BFH-TI-EKT
-- Created    	: 	2019-05-13
-- Last update	: 	2019-05-13
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
-- PLUS				One track forwards
-- MINUS			One track backwards
--
-- Outputs:
-- STATE			Current state of FSM (two bits). '00' = static (default), '01' = dynamic, '10' = xy-diagram
-- SSD				Seven segment display control. First 5 bits = track no. Last 5 bits = free slots.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

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
			SSD			: out std_logic_vector(9 downto 0));	 

end entity FSM_MENU;

-------------------------------------------------------------------------------

architecture rtl of FSM_MENU is

  type states is (PLAYING, RECORDING, DELETING, IDLE); 		-- declare new type "states". We don't know how many bits Quartus chooses to represent these states (could be 2 or could be "one hot")
  signal state_next, state_reg: states;						-- state register
 
begin -- architecture rtl

	-- state register
	REG: process(CLK, RST)									-- reset is asynchronous, thus it must appear in the sensitivity list
	begin --process REG
		if RST = '0' then									-- asynchronous reset (low active)
			state_reg <= IDLE;
		elsif CLK'event and CLK = '1' then
			state_reg <= state_next;
		end if;
	end process REG;
		
	-- next state logic
	NSL: process(SHIFT, state_reg)
	begin -- process Next State Logic
		state_next <= state_reg;							-- This assignment is used in case of no button push. Always the last assignment is valid!
		case state_reg is
			when IDLE =>									-- when the state is IDLE, the condition for it to change 
				-- if SHIFT = '1' then
					-- state_next <= DYN;
				-- end if;
			when PLAYING =>									-- when the state is PLAYING, the condition for it to change
				-- if SHIFT = '1' then
					-- state_next <= DYN;
				-- end if;
			when RECORDING =>								-- when the state is RECORDING, the condition for it to change
				-- if SHIFT = '1' then
					-- state_next <= LED;
				-- end if;
			when DELETING =>								-- when the state is DELETING, the condition for it to change
				-- if SHIFT = '1' then
					-- state_next <= STAT;
				-- end if;
			when others => null;
		end case;
	end process NSL;
	
	-- selected signal assigment, concurrent form
	with state_reg select 			-- assing output value to STATE, depending on the current state
		STATE <= "00" when IDLE,
		         "01" when PLAYING,
				 "10" when RECORDING,
				 "11" when DELETING,
				 "00" when others;			 
	
end architecture rtl;