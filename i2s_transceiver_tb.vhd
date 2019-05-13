-------------------------------------------------------------------------------
-- Title      : Testbench for design "i2s_transceiver"
-- Project    : Dictaphone
-------------------------------------------------------------------------------
-- File       : i2s_transceiver_tb.vhd
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


-------------------------------------------------------------------------------

entity i2s_transceiver_tb is

end entity i2s_transceiver_tb;

-------------------------------------------------------------------------------

architecture bench of i2s_transceiver_tb is

	-- component ports
	signal  CLK 	: STD_LOGIC := '0'; -- 50MHz system clock. We must assign the literal '0' to the signal CLK because not undefined is still undefined. 
	signal	RST 	: STD_LOGIC; 
	signal 	DIN		: STD_LOGIC_VECTOR(23 downto 0);
	signal	DOUT 	: STD_LOGIC; 		
	signal	SCLK	: STD_LOGIC;
	signal	WS		: STD_LOGIC;


	-- stimuli constants
	constant T_WAIT 		: time := 1 ms;      -- wait time between stimuli changes
	constant CLK_PERIOD 	: time := (1.0 / 50.0e6) * 1 sec;
	constant STABLE_TIME 	: time := 12 ms;
	
	-- testbench signals
	signal tests_done		: boolean := false;

begin  -- architecture bench

  -- component instantiation
  DUT: entity work.i2s_transceiver(logic)

    port map (			-- Connect pins of parallel/serial converter to pins of testbench.
		mclk => CLK,
		reset_n => RST,
		l_data_tx => DIN,
		r_data_tx => DIN,
		sd_rx => '0',
		sd_tx => DOUT,
		ws	 => WS,
		sclk => SCLK);
	  
  -- clock and reset generation
  CLK <= not CLK after 0.5 * CLK_PERIOD when not tests_done else '0';
  RST <= 	'1', 
			'0' after 2.5 * CLK_PERIOD,
			'1' after 3.5 * CLK_PERIOD;

  -- stimuli generation
  STIM: process
  begin
  
    DIN <= "110100110101100011010011";		-- Parallel data
			
    wait for 800* CLK_PERIOD;		-- Wait clock cycles
	
	tests_done <= true;

    -- stop the stimuli generation
    wait;
  end process STIM;

end architecture bench;