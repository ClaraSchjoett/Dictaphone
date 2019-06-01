-------------------------------------------------------------------------------
-- Title      	:	strobe_gen_tb
-- Project   	:	Dictaphone
-------------------------------------------------------------------------------
-- File       	:	strobe_gen_tb.vhd
-- Author     	:	Clara Schjoett
-- Company    	:	BFH-TI-EKT
-- Created    	:	2019-06-01
-- Last update	:	2019
-- Platform   	:	Xilinx ISE 14.7
-- Standard   	:	VHDL'93/02, Math Packages
-------------------------------------------------------------------------------
-- Description	:	Testbench for timer that generates a strobe from falling edge of clock, one clock cycle.
--					Time interval parametrizeable with generic INTERVAL
-------------------------------------------------------------------------------
-- Revisions  	:
-- Date        		Version  	Author  	Description
-- 2019-06-01  		1.0      	Clara		Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------
-- Entity declaration
entity strobe_gen_tb is
end entity strobe_gen_tb;

-------------------------------------------------------------------------------
-- Architecture declaration
architecture bench of strobe_gen_tb is

	-- -- Instantiate strobe generator block
	-- component strobe_gen
	-- generic (	INTERVAL	: integer :=6);
	-- port(		CLK			: in std_logic;
				-- RST			: in std_logic;
				-- IMP			: in std_logic);
	-- end component;
	
	-- component ports
	signal  CLK 	: STD_LOGIC := '0'; -- 50MHz system clock. We must assign the literal '0' to the signal CLK because not undefined is still undefined. 
	signal	RST 	: STD_LOGIC; -- Reset 
	signal	IMP	 	: STD_LOGIC; -- Impulse generated every second					


	-- stimuli constants
	constant T_WAIT 		: time := 0.01 sec;      -- wait time between stimuli changes
	constant CLK_PERIOD 	: time := (1.0 / 50.0e6) * 1 sec;
	
	-- testbench signals
	signal tests_done		: boolean := false;

begin  -- architecture bench

	-- DUT: strobe_gen
	-- generic map(	INTERVAL	=> INTERVAL)
	-- port map(		CLK			=> CLK,
					-- RST			=> RST,
					-- IMP			=> IMP);
					
	-- -- component instantiation
	DUT: entity work.strobe_gen(rtl)
	
	-- Connect pins of strobe generator to pins of testbench.
    port map (			
      CLK  => CLK,
      RST  => RST,
      IMP  => IMP);
	  
	-- clock and reset generation
	CLK <= 	not CLK after 0.5 * CLK_PERIOD when not tests_done else 
			'0';
	RST <= 	'1', 
			'0' after 0.25 * CLK_PERIOD,
			'1' after 1.75 * CLK_PERIOD;

	-- stimuli generation
	STIM: process
	begin

		wait for T_WAIT;		-- Wait 10ms
	
		tests_done <= true;

		-- stop the stimuli generation
		wait;
	end process STIM;

end architecture bench;

-------------------------------------------------------------------------------
