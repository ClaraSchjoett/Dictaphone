-------------------------------------------------------------------------------
-- Title      : Testbench for design "PAR2SER_I2S"
-- Project    : Dictaphone
-------------------------------------------------------------------------------
-- File       : SER2PAR_SPI_tb.vhd
-- Author     : Peter Wuethrich
-- Company    : BFH-TI-EKT
-- Created    : 2019-05-13
-- Last update: 2019-05-14
-- Platform   : Xilinx ISE 14.7
-- Standard   : VHDL'93/02, Math Packages
-------------------------------------------------------------------------------
-- Description:	Testbench that simulates parallel data
-------------------------------------------------------------------------------
-- Copyright (c) 2015 BFH-TI-EKT
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2019-05-13  1.0      Peter	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-------------------------------------------------------------------------------

entity SER2PAR_SPI_tb is

end entity SER2PAR_SPI_tb;

-------------------------------------------------------------------------------

architecture bench of SER2PAR_SPI_tb is

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
  DUT: entity work.SER2PAR_SPI(rtl)

	-- Connect pins of parallel/serial converter to pins of testbench.
    port map (
		CLK  => CLK,
		RST  => RST,
		DOUT => DOUT,
		SCLK => SCLK,
		CS => CS,
		SDI => SDI);

  -- clock and reset generation
  CLK <= not CLK after 0.5 * CLK_PERIOD when not tests_done else '0';
  RST <= 	'1',
			'0' after 2.5 * CLK_PERIOD,
			'1' after 3.5 * CLK_PERIOD;

  -- stimuli generation
  STIM: process
  begin

  SDI <= '1'
	wait for 2000* CLK_PERIOD;		-- Wait clock cycles

	tests_done <= true;

    -- stop the stimuli generation
    wait;
  end process STIM;

end architecture bench;

-------------------------------------------------------------------------------
