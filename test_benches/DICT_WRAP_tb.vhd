-------------------------------------------------------------------------------
-- Title      : Testbench for design "DICT_WRAP_tb"
-- Project    : Dictaphone
-------------------------------------------------------------------------------
-- File       : DICT_WRAP_tb.vhd
-- Author     : Clara Schjoett
-- Company    : BFH-TI-EKT
-- Created    : 2019-05-06
-- Last update: 2019-05-06
-- Platform   : Xilinx ISE 14.7
-- Standard   : VHDL'93/02, Math Packages
-------------------------------------------------------------------------------
-- Description:	Testbench that simulates dipswitches
-------------------------------------------------------------------------------
-- Copyright (c) 2015 BFH-TI-EKT
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2019-05-09  1.0      Clara	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-------------------------------------------------------------------------------

entity DICT_WRAP_tb is

end entity DICT_WRAP_tb;

-------------------------------------------------------------------------------

architecture bench of DICT_WRAP_tb is

	-- component ports
	signal  CLK 	: STD_LOGIC := '0'; -- 50MHz system clock. We must assign the literal '0' to the signal CLK because not undefined is still undefined. 
	signal	RST 	: STD_LOGIC; 		-- Reset 
	signal 	SW		: STD_LOGIC_VECTOR(2 downto 0);
	signal	MCLK	: STD_LOGIC;
	signal	SCLK	: STD_LOGIC;
	signal	WS		: STD_LOGIC;
	signal	DOUT 	: STD_LOGIC;

	-- stimuli constants
	constant T_WAIT 		: time := 1 ms;      				-- wait time between stimuli changes
	constant CLK_PERIOD 	: time := (1.0 / 50.0e6) * 1 sec;	-- 50MHz -> 20ns cycle
	
	-- testbench signals
	signal tests_done		: boolean := false;

begin  -- architecture bench

	-- component instantiation
	DUT: entity work.DICT_WRAP(str)

		-- Connect pins of parallel/serial converter to pins of testbench.
		port map (			
			CLK  => CLK,
			RST  => RST,
			SW   => SW,
			DOUT => DOUT,
			WS	 => WS,
			SCLK => SCLK,
			MCLK => MCLK);
	  
	-- clock and reset generation
	CLK <= not CLK after 0.5 * CLK_PERIOD when not tests_done else '0';
	RST <= 	'1', 
			'0' after 2.5 * CLK_PERIOD,
			'1' after 3.5 * CLK_PERIOD;

	-- stimuli generation
	STIM: process
	begin
  
		SW <= "000"; 						-- all switches 
		wait for 2500000* CLK_PERIOD;			-- Wait clock cycles
		SW <= "001"; 						
		wait for 2500000* CLK_PERIOD;		-- Wait clock cycles
		SW <= "011";		
		wait for 1000000* CLK_PERIOD;		-- Wait clock cycles
		SW <= "010";
		wait for 1000000* CLK_PERIOD;		
		SW <= "101";	
		wait for 2000000* CLK_PERIOD;		-- Wait clock cycles
		SW <= "111";	
		wait for 2000000* CLK_PERIOD;		-- Wait clock cycles

		tests_done <= true;

		-- stop the stimuli generation
		wait;
	end process STIM;

end architecture bench;

-------------------------------------------------------------------------------
