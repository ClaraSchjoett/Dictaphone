-------------------------------------------------------------------------------
-- Title      	:	strobe_gen
-- Project   	:	Dictaphone
-------------------------------------------------------------------------------
-- File       	:	strobe_gen.vhd
-- Author     	:	Clara Schjoett
-- Company    	:	BFH-TI-EKT
-- Created    	:	2019-06-01
-- Last update	:	2019-06-10
-- Platform   	:	Xilinx ISE 14.7
-- Standard   	:	VHDL'93/02, Math Packages
-------------------------------------------------------------------------------
-- Description	:	Timer that generates a strobe from falling edge of clock, one clock cycle.
--					Time interval parametrizeable with generic INTERVAL
-------------------------------------------------------------------------------
-- Revisions  	:
-- Date        		Version  	Author  	Description
-- 2019-06-01  		1.0      	Clara		Created
-- 2019-06-10		1.1			Clara		Comments added
-------------------------------------------------------------------------------
-- Inputs		:		
-- CLK				System clock
-- RST				Reset timer
-- EN				Enable strobe generation
-- Outputs		:	
-- IMP				Impulses with parametrizeable interval, duration one clock cycle
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity strobe_gen is
	generic(	INTERVAL	: integer := 6);		-- Number of clock cycles between same edge of two successive strobes
    port( 		CLK 		: in STD_LOGIC;			-- 50MHz onboard clock
				RST 		: in STD_LOGIC;			-- Reset
				EN			: in STD_LOGIC;			-- Enable strobe 
				IMP 		: out STD_LOGIC);		-- Strobe output
end strobe_gen;

architecture rtl of strobe_gen is
begin

	STROBE: process(CLK, RST) 
		variable counter : integer := 1;
	begin 
		if(RST = '0')  then							-- Reset low active and asynchronous
			counter := 1;
		elsif falling_edge(CLK) then				-- Update on falling edge
			if EN = '1' then
				if counter = INTERVAL then
					IMP <= '1';
					counter := 1;
				else
					IMP <= '0';
					counter := counter + 1;
				end if;
			else 
				IMP <= '0';
				counter := 1;
			end if;
		end if;
	end process;
end rtl;