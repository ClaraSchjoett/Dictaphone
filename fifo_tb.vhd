-------------------------------------------------------------------------------
-- Title      	: 	fifo_tb
-- Project    	: 	Dictaphone
-------------------------------------------------------------------------------
-- File       	: 	fifo_tb.vhd
-- Author     	: 	Clara Schjoett
-- Company    	: 	BFH
-- Created    	: 	2019-06-01
-- Last update	: 	2019
-- Platform   	: 	Xilinx ISE 14.7
-- Standard   	: 	VHDL'93/02, Math Packages
-- Sources		:	http://www.deathbylogic.com/2013/07/vhdl-standard-fifo/
-------------------------------------------------------------------------------
-- Description	: 	Testbench for standard FIFO-Buffer
-------------------------------------------------------------------------------
-- Revisions  	:
-- Date        		Version		Author		Description
-- 2019-06-01		1.0			Peter		Created
-------------------------------------------------------------------------------
-- Inputs		:
-- clk				Audio sampling rate
-- reset			Resets the internal pointers and sets data to zero
-- data_in			Input Data
-- wr				write input: if wr is high, data_in is written on positive edge of clk
-- rs				read input: if rd is high, data appears on data_out on positive edge of clk
--
-- Outputs		:
-- data_out			Output Data
-- full				is high if fifo-buffer is full
-- empty			is high if fifo-buffer is empty
-- almost_full		is high if fifo-buffer is more than 75% full
-- almost_empty		is high if fifo-buffer is less than 25% full
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY fifo_tb IS
END fifo_tb;

ARCHITECTURE behavior OF fifo_tb IS 
	
	constant ADDR_WIDTH		: positive 		:= 10;
	constant DATA_WIDTH  	: positive 		:= 16;
	
	--Inputs
	signal clk			: std_logic := '0';
	signal reset		: std_logic := '1';
	signal data_in		: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal rd			: std_logic := '0';
	signal wr			: std_logic := '0';
	
	--Outputs
	signal data_out		: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal empty		: std_logic;
	signal full			: std_logic;
	signal almost_empty	: std_logic;
	signal almost_full	: std_logic;
	
	-- Clock period definitions
	constant CLK_PERIOD : time := 20 ns;
	
	-- testbench signals
	signal tests_done	: boolean := false;

BEGIN

	-- Instantiate the Device Under Test (DUT)
	DUT: entity work.fifo
		PORT MAP (
			clk		=> clk,
			reset	=> reset,
			data_in	=> data_in,
			wr		=> wr,
			rd		=> rd,
			data_out=> data_out,
			full	=> full,
			empty	=> empty,
			almost_empty => almost_empty,
			almost_full  => almost_full
		);
	
	
	
	-- clock and reset generation
	clk <= not clk after 0.5 * CLK_PERIOD when not tests_done else
				'0';
	reset <= 	'1', 
				'0' after 0.25 * CLK_PERIOD,
				'1' after 1.75 * CLK_PERIOD;
	
	-- Write and successively read process
	STIM : process
		variable counter : unsigned (DATA_WIDTH-1 downto 0) := (others => '0');
	begin		
		wait for CLK_PERIOD * 20;

		wr <= '1';
		
		for i in 1 to 1050 loop
			counter := counter + 1;		
			data_in <= std_logic_vector(counter);		
			wait for CLK_PERIOD * 1;		
		end loop;		
		
		wait for CLK_PERIOD * 20;
		
		wr <= '0';
		rd <= '1';
		
		for k in 1 to 1050 loop
			rd <= '1';
			wait for CLK_PERIOD * 1;
		end loop;	
		
		wait for CLK_PERIOD * 40;

		
		tests_done <= true;
		
		wait;
	end process STIM;
	
END;