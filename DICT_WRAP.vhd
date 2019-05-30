-------------------------------------------------------------------------------
-- Title      	: 	DICT_WRAP
-- Project    	: 	Dictaphone
-------------------------------------------------------------------------------
-- File       	: 	DICT_WRAP.vhd
-- Author     	: 	Clara Schjoett
-- Company    	: 	BFH
-- Created    	: 	2019-05-08
-- Last update	: 	2019-05-28
-- Platform   	: 	Xilinx ISE 14.7
-- Standard   	: 	VHDL'93/02, Math Packages
-------------------------------------------------------------------------------
-- Description	: 	Wrapper file for dictaphone project
-------------------------------------------------------------------------------
-- Revisions  	:
-- Date        		Version  	Author  	Description
-- 2019-05-08		1.0			Clara		Created
-------------------------------------------------------------------------------
-- Inputs		:
-- CLK				Onboard system clock (50MHz)
-- RST				Button on board
-- SW<0>			Selects y-axis data for display
-- SW<1>			Selects z-axis data for display
-- SW<2>			Data acknowledge for triangle_ctrl block
--
-- PLAY				Play current record button
-- DLT				Delete current track button
-- RCRD				Record on set track button
-- PLUS				Increase track number button
-- MINUS			Decrease track number button
--
-- Outputs		:
-- MCLK				Master clock (25MHz)
-- SCLK				Serial clock (bit clock, 3.125MHz)
-- WS				Word select signal for I2S bus. High: R channel, low: L channel (48.8kHz)
-- DOUT				Serial data out. Side note: resolution of DAC is 24 bit,
--					thus we must shift incoming 16 bit vector 8 bits left.
--
-- SSD				Seven segment display control

-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


-- Own packages
use work.gecko4_education_pkg.all;


entity DICT_WRAP is
    Port (  CLK 	: in std_logic;
			RST 	: in std_logic;							-- button "RST" (lower push-button)
			SW 		: in std_logic_vector(2 downto 0);		-- dip switch
			PLAY	: in std_logic;							-- button "PLAY" (4th from l.t.r.)
			DLT		: in std_logic;							-- button "DELETE" (5th from l.t.r)
			RCRD	: in std_logic;							-- button "RECORD" (3rd from l.t.r)
			PLUS	: in std_logic;							-- button "PLUS" (2nd from l.t.r)
			MINUS	: in std_logic;							-- button "MINUS" (1st from l.t.r)

			CLKO	: out std_logic;
			MCLK 	: out std_logic;						-- master clock for I2S (25MHz)
			SCLK	: out std_logic;						-- serial clock for I2S (3.125MHz)
      WS 		: out std_logic;						-- word select (48.8kHz)
			DOUT	: out std_logic;						-- serial data out for I2S
			SSD		: out std_logic_vector(31 downto 0);	-- Seven segment display control
			LED		: out std_logic_matrix(1 to 10, 1 to 12);

      SCLK_SPI  : out std_logic;
      CS        : out std_logic;
      SDI     	 : in  std_logic);

end DICT_WRAP;

architecture str of DICT_WRAP is

	signal S_DATA 	: std_logic_vector(15 downto 0);
	signal S_PLAY	: std_logic;
	signal S_DLT	: std_logic;
	signal S_RCRD	: std_logic;
	signal S_PLUS	: std_logic;
	signal S_MINUS	: std_logic;
	signal S_BCD	: std_logic_vector(9 downto 0);

	signal S_NPLAY	: std_logic;
	signal S_NDLT	: std_logic;
	signal S_NRCRD	: std_logic;
	signal S_NPLUS	: std_logic;
	signal S_NMINUS	: std_logic;
	signal S_STATE	: std_logic_vector(1 downto 0);

begin

	-- assign inputs and outputs
	-- invert logical level of following buttons to avoid changing debouncer
	S_PLAY <= not PLAY;
	S_DLT  <= not DLT;
	S_RCRD <= not RCRD;
	S_PLUS <= not PLUS;
	S_MINUS <= not MINUS;

	-- Test lines to visualise current state
	LED(1, 1) <= S_STATE(0);
	LED(1, 2) <= S_STATE(1);

	CLKO <= CLK;




	CONV: entity work.PAR2SER_I2S		-- direct instantiation of component conversion to serial data
		port map(	CLK 	=> CLK,
					RST 	=> RST,
					DIN 	=> S_DATA,
					MCLK 	=> MCLK,
					SCLK 	=> SCLK,
					WS 		=> WS,
					DOUT 	=> DOUT);

	DEB_PLAY: entity work.debouncer		-- direct instantiation of component debouncer for play button
	port map(
					CLK 	=> CLK,
					RST 	=> RST,
					I 		=> S_PLAY,
					O		=> S_NPLAY);

	DEB_DLT: entity work.debouncer		-- direct instantiation of component debouncer for delete button
	port map(
					CLK 	=> CLK,
					RST 	=> RST,
					I 		=> S_DLT,
					O		=> S_NDLT);

	DEB_RCRD: entity work.debouncer		-- direct instantiation of component debouncer for record button
	port map(
					CLK 	=> CLK,
					RST 	=> RST,
					I 		=> S_RCRD,
					O		=> S_NRCRD);

	DEB_PLUS: entity work.debouncer		-- direct instantiation of component debouncer for track+ button
	port map(
					CLK 	=> CLK,
					RST 	=> RST,
					I 		=> S_PLUS,
					O		=> S_NPLUS);

	DEB_MINUS: entity work.debouncer	-- direct instantiation of component debouncer for track- button
	port map(
					CLK 	=> CLK,
					RST 	=> RST,
					I 		=> S_MINUS,
					O		=> S_NMINUS);

	MENU: entity work.FSM_MENU			-- direct instantiation of component FSM_MENU, the menu control
		port map(	CLK 	=> CLK,
					RST 	=> RST,
					PLAY 	=> S_NPLAY,
					DLT 	=> S_NDLT,
					RCRD	=> S_NRCRD,
					PLUS 	=> S_NPLUS,
					MINUS	=> S_NMINUS,
					STATE	=> S_STATE,
					BCD		=> S_BCD);

	TRANS: entity work.BCD2SSD			-- direct instantiation of component translation BCD to SSD control signal
		port map(	BCD 	=> S_BCD,
					SSD 	=> SSD);


  PLVL: entity work.peak_level_ctrl		-- direct instantiation of component peak level control
    port map(
          clk 	=> CLK,
          rst 	=> RST,
          audioDataL => S_DATA,
          audioDataR => S_DATA,
          audioLevelLedR(0) => LED(10,1),
          audioLevelLedR(1) => LED(10,2),
          audioLevelLedR(2) => LED(10,3),
          audioLevelLedR(3) => LED(10,4),
          audioLevelLedR(4) => LED(10,5),
          audioLevelLedR(5) => LED(10,6),
          audioLevelLedR(6) => LED(10,7),
          audioLevelLedR(7) => LED(10,8),
          audioLevelLedR(8) => LED(10,9),
          audioLevelLedR(9) => LED(10,10),
          audioLevelLedR(10) => LED(10,11),
          audioLevelLedR(11) => LED(10,12));

  ICNV: entity work.SER2PAR_SPI		-- direct instantiation of component conversion to parallel data
    port map(	CLK 	=> CLK,
          RST 	=> RST,
          SCLK 	=> SCLK_SPI,
          DOUT 	=> S_DATA,
          SDI => SDI,
          CS => CS);

end; -- architecture str
