-------------------------------------------------------------------------------
-- Title      	: 	MEM_CTRL
-- Project    	: 	Dictaphone
-------------------------------------------------------------------------------
-- File       	: 	MEM_CTRL.vhd
-- Author     	: 	Peter Wüthrich
-- Company    	: 	BFH
-- Created    	: 	2019-04-06
-- Last update	: 	2019-04-06
-- Platform   	: 	Xilinx ISE 14.7
-- Standard   	: 	VHDL'93/02, Math Packages
-------------------------------------------------------------------------------
-- Description	: 	memory controller for sdram 
-------------------------------------------------------------------------------
-- Revisions  	:
-- Date        		Version  	Author  	Description
-- 2019-05-08		1.0			Peter		Created
-------------------------------------------------------------------------------
-- Inputs		:
-- TODO

-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


-- Own packages
use work.gecko4_education_pkg.all;


entity MEM_CTRL is
	Port (	CLK 				: in std_logic;						-- system clock (50 MHz)
			RST 				: in std_logic;						-- reset signal (low-active)
			
			STATE				: in std_logic_vector(1 downto 0);	-- 00 --> IDLE, 01 --> PLAYING, 02 --> RECORDING
			TRACK				: in std_logic_vector(3 downto 0);	-- track number, is equivalent with the 4 MSBs of the SDRAM address
			DELETE				: in std_logic;						-- high pulse deletes selected track
			REC_PLAY			: out std_logic;					-- is high during playing or recording process
																		-- state must not be changed if this output is high
			REC_PLAY_FINISHED	: out std_logic;
			OCCUPIED			: out std_logic;					-- is high if selected track is occupied
			
			FIFO_I_EMPTY		: in std_logic;						-- input fifo empty
			FIFO_I_ALMOST_FULL	: in std_logic;						-- input fifo more than 75% full
			FIFO_I_RD			: out std_logic;					-- read data from intput fifo
			FIFO_I_WR			: out std_logic;					-- enable writing data from mic into input fifo
			FIFO_I_CLR			: out std_logic;					-- clear input fifo (high active)
			
			FIFO_O_EMPTY		: in std_logic;						-- output fifo empty
			FIFO_O_ALMOST_FULL	: in std_logic;						-- output fifo more than 75% full
			FIFO_O_RD			: out std_logic;					-- enable reading data from output fifo to loudspeaker
			FIFO_O_WR			: out std_logic;					-- write data into output fifo
			

			cmd_ready		: in std_logic;							-- new command can be processed
			cmd_strobe		: out std_logic;						-- issue a new read/write command
			cmd_wr			: out std_logic;						-- write access
			cmd_address		: out unsigned(23 downto 0);			-- word address for read/write
			
			data_out_ready	: in std_logic;							-- new data from SDRAM is ready

end MEM_CTRL;

architecture str of MEM_CTRL is

	signal S_OCCUPIED		: std_logic_vector(15 downto 0);	-- each bit represents a memory block for one track. 1: occupied, 0: free 
	signal S_ADDRESS		: unsigned(19 downto 0);			-- SDRAM address without first 4 bits which represent the track
	
	signal S_WR_IN_PROGR	: std_logic;						-- writing a word into SDRAM
	signal S_WR_DONE		: std_logic;						-- finished writing a word into SDRAM
	signal S_RD_FROM_FIFO	: std_logic;						-- goes to high when input fifo is 75% full, goes to low when empty,
																	-- so reading from fifo starts after buffering enough data
	
	signal S_RD_IN_PROGR	: std_logic;						-- reading a word from SDRAM
	signal S_PLAYING		: std_logic;						-- playing data from output fifo to loudspeaker




begin
	--constants representing states
	constant IDLE		: std_logic_vector(1 downto 0)	:= '00';
	constant PLAYING	: std_logic_vector(1 downto 0)	:= '01';
	constant RECORDING	: std_logic_vector(1 downto 0)	:= '10';
	
	-- assign inputs and outputs
	-- TODO
	process(CLK, RST)
		
		begin
			if RST = '0'
				REC_PLAY <= '0';
				REC_PLAY_FINISHED <= '0';
				OCCUPIED <= '0';
				FIFO_I_RD <= '0';
				FIFO_I_WR <= '0';
				FIFO_I_CLR <= '0';
				FIFO_O_RD <= '0';
				FIFO_O_WR <= '0';
				
				S_OCCUPIED		<= (others => '0');
				S_ADDRESS		<= (others => '0');
				
				S_WR_IN_PROGR	<= '0';
				S_WR_DONE		<= '0';
				S_RD_FROM_FIFO	<= '0';
				
				S_RD_IN_PROGR	<= '0';
				S_PLAYING		<= '0';
				
			elsif rising_edge(CLK) then

				OCCUPIED <= S_OCCUPIED(TRACK);
				
				if STATE = RECORDING then
					cmd_address <= TRACK & S_ADDRESS;	
					
					if not REC_PLAY then 				-- at the beginning set recording/playing flag
						REC_PLAY <= '1';				-- set recording/playing flag
						FIFO_I_WR <= '1';				-- start buffering data into fifo
						FIFO_I_CLR <= '0';				-- release reset of fifo buffer
					end if;

					if FIFO_I_ALMOST_FULL then			-- wait until the fifo buffer is almost full
						S_RD_FROM_FIFO:= '1';			-- then start reading process until fifo is empty
					end if;
					
					if FIFO_I_EMPTY then
						S_RD_FROM_FIFO <= '0';
					end if;
					

					if S_RD_FROM_FIFO then 
						if not S_WR_IN_PROGR
							S_WR_IN_PROGR <= '1';
							FIFO_I_RD <= '1';
						else
							FIFO_I_RD <= '0';
						end if;
						
						if S_WR_IN_PROGR then
							if cmd_ready then
								cmd_wr <= '1';
								cmd_strobe <= '1';
								S_WR_IN_PROGR <= '0';
								S_WR_DONE <= '1';
							end if;
						elsif S_WR_DONE
							if S_ADDRESS < x"FFFFF" then
								S_ADDRESS <= S_ADDRESS + 1;
							else
								S_ADDRESS <= (others => '0');
								FIFO_I_CLR <= '1';
								S_OCCUPIED(TRACK) <= '1';
								REC_PLAY <= '0';
								FIFO_I_WR <= '0';
								REC_PLAY_FINISHED <= '1';
							end if;
							
							cmd_wr <= '0';
							cmd_strobe <= '0';
							S_WR_DONE <= '0';
						end if;
					end if;
					












				elsif STATE = PLAYING
					if not REC_PLAY then						-- at the beginning set recording/playing flag
						REC_PLAY <= '1';				-- set recording/playing flag
						S_ADDRESS <= (others => '0');
						--clear out fifo?? or is it already clear??
					end if;
					
					--wait for cmd ready
					if cmd_ready and not S_RD_IN_PROGR and not FIFO_O_ALMOST_FULL then
						cmd_address <= TRACK & S_ADDRESS;
						cmd_strobe <= '1';
						S_RD_IN_PROGR <= '0';
					end if;
					
					if cmd_strobe then
						cmd_strobe <= '0';
					end if;
					
					if S_RD_IN_PROGR then
					
						if data_out_ready then
							FIFO_O_WR <= '1';
						end if;
						
						if FIFO_O_WR then
						
							FIFO_O_WR <= '0';
							S_RD_IN_PROGR <= '0';
							
							if S_ADDRESS < x"FFFFF" then
								S_ADDRESS <= S_ADDRESS + 1;
							else
								S_ADDRESS <= '0';
								REC_PLAY_FINISHED <= '1';
							end if;
						end if;
					end if;
					
					if FIFO_O_ALMOST_FULL then
						FIFO_O_RD <= '1';
						S_PLAYING <= '1';
					end if;
					
					if FIFO_O_EMPTY and S_PLAYING
						FIFO_O_RD <= '0';
						S_PLAYING <= '0';
						REC_PLAY <= '0';
					end if;


				elsif STATE = IDLE
					REC_PLAY_FINISHED <= '0';
					if DELETE = '1'
						S_OCCUPIED(TRACK) <= '0';
				end if;
	end process


end; -- architecture str




























