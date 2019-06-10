-------------------------------------------------------------------------------
-- Title      	: 	PAR2SER_I2S
-- Project    	: 	Dictaphone
-------------------------------------------------------------------------------
-- File       	: 	PAR2SER_I2S.vhd
-- Author     	: 	Clara Schjoett
-- Company    	: 	BFH
-- Created    	: 	2019-05-08
-- Last update	: 	2019-05-12
-- Platform   	: 	Xilinx ISE 14.7
-- Standard   	: 	VHDL'93/02, Math Packages
-- Sources		:	https://surf-vhdl.com/how-to-implement-a-parallel-to-serial-converter/
--					https://stackoverflow.com/questions/25045712/vhdl-programming-scale-the-value-from-32-scale-to-100-scale
--					https://www.digikey.com/eewiki/pages/viewpage.action?pageId=84738137#I2STransceiver(VHDL)-CodeDownload
-------------------------------------------------------------------------------
-- Description	: 	converts 16 bit parallel data to serial data for I2S bus for 
-- 					transmitting data from FIFO to Pmod loudspeaker.
--					Serial data is represented in two's compliment (signed).
-------------------------------------------------------------------------------
-- Revisions  	:
-- Date        		Version  	Author  	Description
-- 2019-05-08		1.0			Clara		Created
-- 2019-05-12		1.1			Clara		Correct conversion to two's complement
-------------------------------------------------------------------------------
-- Inputs		:
-- CLK				Onboard system clock (50MHz)
-- RST				Resets the internal counters and sets data to zero	
-- DIN				Parallel data in (vector with 16 bit, default value)
--
-- Outputs		:     
-- MCLK				Master clock (25MHz)      
-- SCLK				Serial clock (bit clock, 3.125MHz)  
-- WS				Word select signal for I2S bus. High: R channel, low: L channel (48.8kHz)
-- DOUT				Serial data out. Side note: resolution of DAC is 24 bit, 
--					thus we must shift incoming 16 bit vector 8 bits left.    
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PAR2SER_I2S is

	generic(	MCLK_SCLK_RATIO	: integer:= 16;		-- number of clock periods per serial clock period. specs: MCLK 25MHz, SCLK 3.125MHz, ratio: 8
				SCLK_WS_RATIO	: integer:= 64;		-- number of serial clock periods per word select phase. specs: WS clock 48.8kHz, ratio 64
				BITWIDTHIN		: integer:= 16;		-- parallel data width
				BITWIDTHOUT		: integer:= 24);	-- serial data width
				
	port( 		CLK            	: in std_logic;		-- system clock (50MHz)
				MCLK			: out std_logic;	-- master clock	(25MHz)
				SCLK			: out std_logic;	-- serial clock (bit clock, 3.125MHz)
				WS				: out std_logic;	-- word select (left-right clock, 48.8kHz)
				RST             : in std_logic;		-- asynchronous active low reset
				DIN          	: in std_logic_vector(BITWIDTHIN-1 downto 0);	-- parallel data in
				DOUT          	: out std_logic);	-- serial data out

end PAR2SER_I2S;


architecture rtl of PAR2SER_I2S is
	signal S_MCLK				: std_logic := '0'; -- must be initialised here
	signal S_SCLK				: std_logic := '0';	-- same here
	signal S_WS					: std_logic := '0'; -- same here
	signal S_L_DATA				: std_logic_vector(BITWIDTHOUT-1 downto 0);
	signal S_R_DATA				: std_logic_vector(BITWIDTHOUT-1 downto 0);
begin -- architecture rtl

	-- Ouput signal match
	MCLK <= S_MCLK;									-- output master clock
	SCLK <= S_SCLK;									-- output serial clock
	WS <= S_WS;										-- output word select
	
	-- Conversion from parallel to serial and expanding vector length from BITWIDTHIN to BITWIDTHOUT
	CONVERSION: process (RST, CLK)
		variable sclk_cnt		: integer := 0; 	-- counter of master clock during half period of serial clock
		variable ws_cnt			: integer := 0; 	-- counter of serial clock toggles during half period of word select
	begin -- process CONVERSION

		if RST = '0' then							-- assume reset low-active
			S_L_DATA <= (others => '0');			-- clear shift register left channel
			S_R_DATA <= (others => '0');			-- same here for right channel
			sclk_cnt := 0;							-- clear master clock counter
			ws_cnt := 0;							-- clear serial clock counter
			S_SCLK <= '0';							-- clear serial clock signal
			S_WS <= '0';							-- clear word select signal
			
		elsif CLK'event and CLK = '1' then			-- if not reset, wait for system clock raising edge
			S_MCLK <= not S_MCLK;					-- toggle master clock every rising edge of system clock to get 25MHz
			
			if sclk_cnt < (MCLK_SCLK_RATIO/2-1) then-- 16 system clock periods per serial clock period
				sclk_cnt := sclk_cnt + 1;
			else 
				sclk_cnt := 0;						-- reset master clock counter
				S_SCLK <= not S_SCLK;				-- toggle serial clock
				if ws_cnt < (SCLK_WS_RATIO-1) then	-- increment word select counter as long as the word has not been completely transmitted
					ws_cnt := ws_cnt + 1;
					
					if S_SCLK = '0' and ws_cnt > 1 and ws_cnt < (2*BITWIDTHOUT+2) then 	--rising edge of sclk during data word
						-- do nothing
					end if;
					
					if S_SCLK = '1' and ws_cnt < (2*BITWIDTHOUT+3) then					-- transmit data on falling edge of SCLK
						------------------------------------------------------------			
						-- the following if else may be left out for mono audio transmission
						if(S_WS = '1') then												-- right channel
							DOUT <= S_R_DATA(BITWIDTHOUT-1);							-- transmit serial data bit 
							S_R_DATA <= S_R_DATA(BITWIDTHOUT-2 downto 0) & '0';			-- shift data of right channel tx data buffer
						else															-- left channel
							DOUT <= S_L_DATA(BITWIDTHOUT-1);							-- transmit serial data bit
							S_L_DATA <= S_L_DATA(BITWIDTHOUT-2 downto 0) & '0';			-- shift data of left channel tx data buffer
						end if;
						------------------------------------------------------------			
					end if;
					
				else																	-- half  period of ws
					ws_cnt := 0;														-- reset serial clock counter
					S_WS <= not S_WS;													-- toggle word select
					S_R_DATA(BITWIDTHOUT-1 downto 0) <= not(DIN(15)) & DIN(14 downto 0) & "00000000"; -- latch in right channel after converting to two's complement
					S_L_DATA(BITWIDTHOUT-1 downto 0) <= not(DIN(15)) & DIN(14 downto 0) & "00000000"; -- latch in left channel after conversions
				end if;
			end if;
		end if;
	end process; -- CONVERSION
end rtl;