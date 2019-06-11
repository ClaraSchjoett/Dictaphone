-------------------------------------------------------------------------------
-- Title      : Testbench for design "PAR2SER"
-- Project    : Dictaphone
-------------------------------------------------------------------------------
-- File       : triangle_ctrl_tb.vhd
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
-- 2019-05-06  1.0      Clara	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------

entity triangle_ctrl_tb is

end entity triangle_ctrl_tb;

-------------------------------------------------------------------------------

architecture bench of triangle_ctrl_tb is
	
	-- component ports
	signal  CLK 	: STD_LOGIC := '0';					-- 50MHz system clock. We must assign the literal '0' to the signal CLK because not undefined is still undefined. 
	signal	RST 	: STD_LOGIC; 						-- simulates reset button
	signal	speed_n	: STD_LOGIC_VECTOR( 1 downto 0); 	-- simulates dip switches
	signal 	data_ack: STD_LOGIC;						-- strobe signal
	signal	data 	: STD_LOGIC_VECTOR(7 downto 0); 	-- parallel data out					


	-- stimuli constants
	constant T_WAIT 		: time := 1 ms;      				-- wait time between stimuli changes
	constant CLK_PERIOD 	: time := (1.0 / 50.0e6) * 1 sec;	-- 20 ns clock cycle
	constant STABLE_TIME 	: time := 12 ms;
	
	-- testbench signals
	signal tests_done		: boolean := false;

begin  -- architecture bench

  -- component instantiation
  DUT: entity work.triangle_ctrl(functional_level)

    port map (			-- Connect pins of parallel/serial converter to pins of testbench.
		CLK  	=> clk,
		RST  	=> rst,
		data_ack=> data_ack,
		speed_n => speed_n,
		data 	=> data);
	  
  -- clock and reset generation
  CLK <= not CLK after 0.5 * CLK_PERIOD when not tests_done else '0';
  RST <= 	'0', 
			'1' after 2 * CLK_PERIOD,
			'0' after 3.5 * CLK_PERIOD;

  -- stimuli generation
  STIM: process
  begin
	speed_n <= "00";
	wait for 500 * CLK_PERIOD;
	
	data_ack <= '0';
	--		'1' after 1 * CLK_PERIOD;
	wait for 1 * CLK_PERIOD;
	data_ack <= '1';
	wait for 2 * CLK_PERIOD;
	data_ack <= '0';
	wait for 20 * CLK_PERIOD;
	data_ack <= '1';
	
    wait for 2000* CLK_PERIOD;		-- Wait clock cycles
	
	speed_n <= "01";
	--  data_ack <= '1'; 
	--		'0' after 5 * CLK_PERIOD;
			
    wait for 800* CLK_PERIOD;		-- Wait clock cycles
	
	speed_n <= "10";
	
	wait for 800* CLK_PERIOD;		-- Wait clock cycles
	
	data_ack <= '0'; 
	--		'0' after 5 * CLK_PERIOD;
			
    wait for 800* CLK_PERIOD;		-- Wait clock cycles
	
		speed_n <= "11";
	data_ack <= '1', 
			'0' after 5 * CLK_PERIOD;
			
    wait for 1000* CLK_PERIOD;		-- Wait clock cycles
	
	tests_done <= true;

    -- stop the stimuli generation
    wait;
  end process STIM;

end architecture bench;

-------------------------------------------------------------------------------
