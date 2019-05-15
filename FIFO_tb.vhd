-------------------------------------------------------------------------------
-- Title      : Testbench for design "FIFO"
-- Project    : Dictaphone
-------------------------------------------------------------------------------
-- File       : FIFO_tb.vhd
-- Author     : Clara Schjoett
-- Company    : BFH-TI-EKT
-- Created    : 2019-05-15
-- Last update: 2019-05-15
-- Platform   : Xilinx ISE 14.7
-- Standard   : VHDL'93/02, Math Packages
-------------------------------------------------------------------------------
-- Description:	Testbench that simulates filling and emptying of FIFO buffer
-------------------------------------------------------------------------------
-- Copyright (c) 2015 BFH-TI-EKT
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2019-05-15  1.0      Clara	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-------------------------------------------------------------------------------

entity FIFO_tb is

end entity FIFO_tb;

-------------------------------------------------------------------------------

architecture bench of FIFO_tb is

	-- component ports
	signal  clk 			: STD_LOGIC := '0'; 				-- 50MHz system clock. We must assign the literal '0' to the signal CLK because not(undefined) is still undefined. 
	signal	rst 			: STD_LOGIC; 						-- Reset 
	signal	wr				: STD_LOGIC;						-- Write control signal
	signal	rd				: STD_LOGIC;						-- Read control signal
	signal 	data_in			: STD_LOGIC_VECTOR(15 downto 0);	-- 16 bit data vector
	signal	data_out		: STD_LOGIC_VECTOR(15 downto 0);	-- 16 bit data vector
	signal	full			: STD_LOGIC;						-- Signalisation buffer full
	signal	empty			: STD_LOGIC;						-- Signalisation buffer empty
	signal	almost_full 	: STD_LOGIC;						-- Signalisation when 3/4 full
	signal	almost_empty	: STD_LOGIC;						-- Signalisation when 1/4 empty

	-- stimuli constants
	constant T_WAIT 		: time := 1 ms;      				-- wait time between stimuli changes
	constant CLK_PERIOD 	: time := (1.0 / 50.0e6) * 1 sec;	-- 50MHz -> 20ns cycle
	
	-- testbench signals
	signal tests_done		: boolean := false;

begin  -- architecture bench

	-- component instantiation
	DUT: entity work.FIFO
	
		-- Apply component generics from FIFO
		generic map (
			ADDR_WIDTH	=> ADDR_WIDTH,							-- Data "depth"
			DATA_WIDTH	=> DATA_WIDTH);

		-- Connect pins of testbench to pins of FIFO.
		port map (			
			clk			=> clk,
			rst			=> rst,
			wr			=> wr,
			rd			=> rd,
			data_in		=> data_in,
			data_out	=> data_out,
			full		=> full,
			empty		=> empty,
			almost_full	=> almost_full,
			almost_empty=> almost_empty);

	-- clock and reset generation
	clk <= not clk after 0.5 * CLK_PERIOD when not tests_done else '0';
	rst <= 	'1', 
			'0' after 2.5 * CLK_PERIOD,
			'1' after 3.5 * CLK_PERIOD;

	-- stimuli generation
	STIM: process
	begin
  
		data_in 	<= "0000000000000001" 				-- decimal 1 
		rd 			<= '1';								-- tell FIFO to read 
		wr			<= '0';								-- tell FIFO not to write
		wait for 10*CLK_PERIOD;
		
		for i in 1 to 10 loop							-- Write decimal 8
			data_in <= conv_std_logic_vector(i, 8);
			wait for CLK_PERIOD;
		end loop;
		
		
		
		-- SW <= "001"; 						
		-- wait for 2500000* CLK_PERIOD;		-- Wait clock cycles
		-- SW <= "011";		
		-- wait for 1000000* CLK_PERIOD;		-- Wait clock cycles
		-- SW <= "010";
		-- wait for 1000000* CLK_PERIOD;		
		-- SW <= "101";	
		-- wait for 2000000* CLK_PERIOD;		-- Wait clock cycles
		-- SW <= "111";	
		-- wait for 2000000* CLK_PERIOD;		-- Wait clock cycles

		tests_done <= true;

		-- stop the stimuli generation
		wait;
	end process STIM;

end architecture bench;

-------------------------------------------------------------------------------