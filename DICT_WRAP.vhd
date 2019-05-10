-------------------------------------------------------------------------------
-- Title      	: 	DICT_WRAP
-- Project    	: 	Dictaphone
-------------------------------------------------------------------------------
-- File       	: 	DICT_WRAP.vhd
-- Author     	: 	Clara Schjoett
-- Company    	: 	BFH
-- Created    	: 	2019-05-08
-- Last update	: 	2019-05-08
-- Platform   	: 	Xilinx ISE 14.7
-- Standard   	: 	VHDL'93/02, Math Packages
-------------------------------------------------------------------------------
-- Description	: 	Wrapper file for dictaphone project
-------------------------------------------------------------------------------
-- Revisions  	:
-- Date        		Version  	Author  	Description
-- 2019-05-08		1.0			Clara		Created
-------------------------------------------------------------------------------
-- Inputs		:
-- CLK				Onboard system clock (50MHz)
-- RST				Button on board	
-- SW<0>			Selects y-axis data for display
-- SW<1>			Selects z-axis data for display
-- SW<2>			Data acknowledge for triangle_ctrl block
-- 
--
-- Outputs		:     
-- MCLK				Master clock (25MHz)      
-- SCLK				Serial clock (bit clock, 3.125MHz)  
-- WS				Word select signal for I2S bus. High: R channel, low: L channel (48.8kHz)
-- DOUT				Serial data out. Side note: resolution of DAC is 24 bit, 
--					thus we must shift incoming 16 bit vector 8 bits left. 
        
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity DICT_WRAP is
    Port (  CLK 	: in std_logic;
			RST 	: in std_logic;							-- button "RST" (lower push-button)
			SW 		: in std_logic_vector(2 downto 0);		-- dip switch
            --DATA	: out std_logic_vector(7 downto 0));		-- parallel data 8 bit
			MCLK 	: out std_logic;						-- master clock for I2S (25MHz)
			SCLK	: out std_logic;						-- serial clock for I2S (3.125MHz)
            WS 		: out std_logic;						-- word select (48.8kHz)
			DOUT	: out std_logic);						-- serial data out for I2S

end DICT_WRAP;

architecture str of DICT_WRAP is

	signal S_DATA 	: std_logic_vector(7 downto 0);

begin

	TRIA: entity work.triangle_ctrl		-- direct instantiation of component triangle generator
		port map(	
					clk 	=> CLK,
					rst 	=> RST,
					speed_n => SW(2 downto 1),
					data_ack=> SW(0),
					data 	=> S_DATA);
					
	CONV: entity work.PAR2SER_I2S		-- direct instantiation of component conversion to serial data
		port map(	CLK 	=> CLK,
					RST 	=> RST,
					DIN 	=> S_DATA,
					MCLK 	=> MCLK,
					SCLK 	=> SCLK,
					WS 		=> WS,
					DOUT 	=> DOUT);
				
end; -- architecture str