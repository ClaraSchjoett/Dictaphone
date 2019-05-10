-------------------------------------------------------------------------------
-- Title      : Testbench for design "PAR2SER_I2S"
-- Project    : Dictaphone
-------------------------------------------------------------------------------
-- File       : PAR2SER_I2S_tb.vhd
-- Author     : Clara Schjoett
-- Company    : BFH-TI-EKT
-- Created    : 2019-05-06
-- Last update: 2019-05-06
-- Platform   : Xilinx ISE 14.7
-- Standard   : VHDL'93/02, Math Packages
-------------------------------------------------------------------------------
-- Description:	Testbench that simulates parallel data
-------------------------------------------------------------------------------
-- Copyright (c) 2015 BFH-TI-EKT
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2019-05-08  1.0      Clara	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-------------------------------------------------------------------------------

entity PAR2SER_I2S_tb is

end entity PAR2SER_I2S_tb;

-------------------------------------------------------------------------------

architecture bench of PAR2SER_I2S_tb is

	-- component ports
	signal  CLK 	: STD_LOGIC := '0'; -- 50MHz system clock. We must assign the literal '0' to the signal CLK because not undefined is still undefined. 
	signal	RST 	: STD_LOGIC; 		-- Reset 
	signal 	DIN		: STD_LOGIC_VECTOR(7 downto 0);
	signal	DOUT 	: STD_LOGIC; 		
	signal	MCLK	: STD_LOGIC;
	signal	SCLK	: STD_LOGIC;
	signal	WS		: STD_LOGIC;


	-- stimuli constants
	constant T_WAIT 		: time := 1 ms;      				-- wait time between stimuli changes
	constant CLK_PERIOD 	: time := (1.0 / 50.0e6) * 1 sec;	-- 50MHz -> 20ns cycle
	
	-- testbench signals
	signal tests_done		: boolean := false;

begin  -- architecture bench

  -- component instantiation
  DUT: entity work.PAR2SER_I2S(rtl)

	-- Connect pins of parallel/serial converter to pins of testbench.
    port map (			
		CLK  => CLK,
		RST  => RST,
		DIN  => DIN,
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
  
    DIN <= "00000011"; --00000000";		-- Parallel data
			
    wait for 2000* CLK_PERIOD;		-- Wait clock cycles
	
	DIN <= "00001100"; --11111111";		-- Parallel data
	
	wait for 2000* CLK_PERIOD;		-- Wait clock cycles
	
	DIN <= "10101010"; --00000011";		-- Parallel data
	
	wait for 2000* CLK_PERIOD;		-- Wait clock cycles
	
	tests_done <= true;

    -- stop the stimuli generation
    wait;
  end process STIM;

end architecture bench;

-------------------------------------------------------------------------------
