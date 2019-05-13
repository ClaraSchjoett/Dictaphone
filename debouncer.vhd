-------------------------------------------------------------------------------
-- Title      : debouncer
-- Project    : Miniproject PmodACL
-------------------------------------------------------------------------------
-- File       : debouncer.vhd
-- Author     : Clara Schjoett
-- Company    : BFH
-- Created    : 2018-12-23
-- Last update: 2019-01-19
-- Platform   : Xilinx ISE 14.7
-- Standard   : VHDL'93/02, Math Packages
-------------------------------------------------------------------------------
-- Description: debouncer circuit for mechanical buttons/switches
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2018-12-23  1.0      Clara	Created
-- 2019-01-19  1.1		Clara	Changed, comments added
-------------------------------------------------------------------------------
--  Inputs:
--		CLK				Onboard system clock
--		RST				Resets the internal counter
--		I				Button/switch input
--
--  Outputs:
--		O				Debounced button/switch signal (only positive edge)
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debouncer is
	generic(CNT_SIZE	: positive := 23); 	-- Note that because of the missing apostrophes, we assign 23 bits to the constant CNT_SIZE
											-- counter size, 84 ms bouncing -> 22 bit counter with 50MHz system clock

	Port (  CLK 		: in  STD_LOGIC; 		-- 50MHz system clock
			RST 		: in  STD_LOGIC; 		-- Reset 
			I 			: in  STD_LOGIC; 		-- Input from mechanical button
			O 	 		: out  STD_LOGIC); 		-- Debounced signal					

end debouncer;

architecture rtl of debouncer is

	signal D1		: std_logic;
	signal CNT_SET 	: std_logic;
	signal CNT_OUT 	: unsigned(CNT_SIZE-1 downto 0) := (others => '0');	
	
begin -- architecture debouncer

	CNT_SET <= I xor D1; 							-- if Input and D1 are inequal, CNT_SET is set to 1

	-- D flip flop
	REG: process(CLK, RST) is						-- reset is asynchronous, hence is must occur in sensitivity list
	begin -- process REG

		if RST = '1' then							-- reset is high-active 
			D1 <= '0';	
			CNT_OUT <= (others => '0');
			O <= '0';			
			
		elsif rising_edge(clk) then
		-- or clk'event and clk = '1'
			D1 <= I;	
			if CNT_SET = '1' then					-- Input and D2 are unequal, hence the counter is reset
				CNT_OUT <= (others => '0');
				O <= '0';
			elsif CNT_OUT(CNT_SIZE-1) = '0' then 	-- Counter hasn't yet counted to the stable input time
				CNT_OUT <= CNT_OUT + 1;
				O <= '0';
			else									-- Counter has reached set time value, Input has been equal to D1 for 10.5ms
				O <= D1; 							-- Output is then set to value of DFF
				CNT_OUT <= to_unsigned(0, CNT_SIZE);-- Reset counter
			end if;
		end if;
	end process REG;
	
end rtl; -- architecture of debouncer

