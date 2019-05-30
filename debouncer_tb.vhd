-------------------------------------------------------------------------------
-- Title      : Testbench for design "debouncer"
-- Project    : Dictaphone
-------------------------------------------------------------------------------
-- File       : debouncer_tb.vhd
-- Author     : Clara Schjoett
-- Company    : BFH-TI-EKT
-- Created    : 2019-01-01
-- Last update: 2019-05-30
-- Platform   : Xilinx ISE 14.7
-- Standard   : VHDL'93/02, Math Packages
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Copyright (c) 2015 BFH-TI-EKT
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2019-01-01  1.0      Clara	Created
-- 2019-01-15  1.1		Clara 	Small changes
-- 2019-05-30  1.2		Clara	RST set to low-active instead of high-active
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------

entity debouncer_tb is

end entity debouncer_tb;

-------------------------------------------------------------------------------

architecture bench of debouncer_tb is

	-- component generics
	-- constant CNT_SIZE: integer := 19; -- counter size, 10 ms bouncing -> 19 bit counter with 50MHz system clock

	
	-- component ports
	signal  CLK 	: STD_LOGIC := '0'; -- 50MHz system clock. We must assign the literal '0' to the signal CLK because not undefined is still undefined. 
	signal	RST 	: STD_LOGIC; -- Reset 
	signal	I 		: STD_LOGIC; -- Input from mechanical button
	signal	O 	 	: STD_LOGIC; -- Debounced signal					


	-- stimuli constants
	constant T_WAIT 		: time := 1 ms;      -- wait time between stimuli changes
	constant CLK_PERIOD 	: time := (1.0 / 50.0e6) * 1 sec;
	constant STABLE_TIME 	: time := 12 ms;
	
	-- testbench signals
	signal tests_done		: boolean := false;

begin  -- architecture bench

  -- component instantiation
  DUT: entity work.debouncer(rtl)
    --generic map (
     -- CNT_SIZE => CNT_SIZE)
    port map (			-- Connect pins of debouncer to pins of testbench.
      CLK  => CLK,
      RST  => RST,
      I  => I,
      O => O);
	  
  -- clock and reset generation
  CLK <= not CLK after 0.5 * CLK_PERIOD when not tests_done else
               '0';
  RST <= 	'1', 
			'0' after 0.25 * CLK_PERIOD,
			'1' after 1.75 * CLK_PERIOD;

  -- stimuli generation
  STIM: process
  begin
  
    I <= '1';				-- Set input I to high level
    wait for 9*T_WAIT;		-- Wait 9ms
	
	I <= '0';				-- Set it to low 
    wait for 3*T_WAIT;		-- Wait 3ms

    I <= '1';				-- Set input to high again
	wait for 10*T_WAIT;		-- Wait 10ms
	
	I <= '0';				-- Set to low
	wait for 5*T_WAIT;		-- Wait 5ms
	
	I <= '1';				-- Set to high
	wait for 30*T_WAIT;		-- Wait 30ms
	
	I <= '0';				-- Set to low
	wait for 25*T_WAIT;		-- Wait 25ms
	
	I <= '1';				-- Set to high
	wait for 100*T_WAIT;	-- Wait 100ms
	
	I <= '0';				-- Set to low
	wait for 90*T_WAIT;		-- Wait 90ms
	
	I <= '1';				-- Set to high
	wait for 50*T_WAIT;		-- Wait 50ms
	
	tests_done <= true;

    -- stop the stimuli generation
    wait;
  end process STIM;

end architecture bench;

-------------------------------------------------------------------------------
