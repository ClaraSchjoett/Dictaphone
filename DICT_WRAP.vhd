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
-- 2019-06-01		1.1			Peter		Added SER2PAR_SPI
-- 2019-06-04		1.2			Peter		Renamed Siganls
-------------------------------------------------------------------------------
-- Inputs		:
-- CLK				Onboard system clock (50MHz)
-- RST				Button on board

-- MINUS			Decrease track number button
-- PLUS				Increase track number button
-- RCRD				Record on set track button
-- PLAY				Play current record button
-- DLT				Delete current track button

-- Outputs		:
-- MCLK_I2S			Master clock (25MHz)
-- SCLK_I2S			Serial clock (bit clock, 3.125MHz)
-- WS_I2S			Word select signal for I2S bus. High: R channel, low: L channel (48.8kHz)
--					Also used as audio sampling clock
-- SDO_I2S		Serial data out. Side note: resolution of DAC is 24 bit,
--					thus we must shift incoming 16 bit vector 8 bits left.

-- SCLK_SPI			Serial clock for SPI
-- CS_SPI			Chip Select for SPI
-- SDI_SPI			Serial data in

-- SSD				Seven segment display control
-- LED				

-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


-- Own packages
use work.gecko4_education_pkg.all;


entity DICT_WRAP is
	Port (	CLK 		: in std_logic;							-- system clock (50 MHz)
	
			RST 		: in std_logic;							-- button "RST" (lower push-button)
			MINUS		: in std_logic;							-- button "MINUS" (1st from l.t.r)
			RCRD		: in std_logic;							-- button "RECORD" (3rd from l.t.r)
			PLUS		: in std_logic;							-- button "PLUS" (2nd from l.t.r)
			PLAY		: in std_logic;							-- button "PLAY" (4th from l.t.r.)
			DLT			: in std_logic;							-- button "DELETE" (5th from l.t.r)

			MCLK_I2S 	: out std_logic;						-- master clock for I2S (25MHz)
			SCLK_I2S	: out std_logic;						-- serial clock for I2S (3.125MHz)
			WS_I2S		: out std_logic;						-- word select (48.8kHz)
			SDO_I2S		: out std_logic;						-- serial data out for I2S
			SSD			: out std_logic_vector(31 downto 0);	-- Seven segment display control
			LED			: out std_logic_matrix(1 to 10, 1 to 12);

			SCLK_SPI	: out std_logic;
			CS_SPI		: out std_logic;
			SDI_SPI		: in  std_logic);

end DICT_WRAP;

architecture str of DICT_WRAP is

	signal S_FIFO_I_DI 			: std_logic_vector(15 downto 0);
	signal S_FIFO_I_DO			: std_logic_vector(15 downto 0);
	signal S_FIFO_O_DI			: std_logic_vector(15 downto 0);
	signal S_FIFO_O_DO			: std_logic_vector(15 downto 0);
	
	signal S_PLAY				: std_logic;
	signal S_DLT				: std_logic;
	signal S_RCRD				: std_logic;
	signal S_PLUS				: std_logic;
	signal S_MINUS				: std_logic;
	signal S_BCD				: std_logic_vector(9 downto 0);
	signal S_TRACK				: std_logic_vector(3 downto 0);

	signal S_DPLAY				: std_logic;
	signal S_DDLT				: std_logic;
	signal S_DRCRD				: std_logic;
	signal S_DPLUS				: std_logic;
	signal S_DMINUS				: std_logic;
	signal S_STATE				: std_logic_vector(1 downto 0);

	signal S_FIFO_I_RD			: std_logic;
	signal S_FIFO_I_WR			: std_logic;
	signal S_FIFO_I_WR_EN		: std_logic;
	
	signal S_FIFO_I_EMPTY		: std_logic;
	signal S_FIFO_I_ALMOST_FULL	: std_logic;
	signal S_FIFO_I_CLR			: std_logic;


	signal S_FIFO_O_RD			: std_logic;
	signal S_FIFO_I_RD_EN		: std_logic;
	signal S_FIFO_O_WR			: std_logic;
	signal S_FIFO_O_EMPTY		: std_logic;
	signal S_FIFO_O_ALMOST_FULL	: std_logic;
	signal S_WS					: std_logic;

	signal S_LLVL				: std_logic_vector(11 downto 0);
	signal S_RLVL				: std_logic_vector(11 downto 0);


	signal	S_REC_PLAY			: std_logic;
	
	signal	S_RAM_READY			: std_logic;
	signal	S_RAM_STROBE		: std_logic;
	signal	S_RAM_WR			: std_logic;
	signal	S_RAM_ADDRESS		: std_logic_vector(23 downto 0);
	signal	S_RAM_DIN			: std_logic_vector(15 downto 0);
	signal	S_RAM_DOUT			: std_logic_vector(15 downto 0);
	signal	S_RAM_DOUT_READY	: std_logic;
begin

	-- assign inputs and outputs
	-- invert logical level of following buttons to avoid changing debouncer
	S_PLAY <= not PLAY;
	S_DLT  <= not DLT;
	S_RCRD <= not RCRD;
	S_PLUS <= not PLUS;
	S_MINUS <= not MINUS;
	S_TRACK <= S_BCD


	S_FIFO_I_WR <= '1';
	S_FIFO_I_RD <= S_FIFO_O_WR;
	
	WS_I2S <= S_WS;




	CONV: entity work.PAR2SER_I2S		-- direct instantiation of component conversion to serial data
		port map(	CLK 	=> CLK,
					RST 	=> RST,
					DIN 	=> S_FIFO_O_DO,
					MCLK 	=> MCLK_I2S,
					SCLK 	=> SCLK_I2S,
					WS 		=> S_WS,
					DOUT 	=> SDO_I2S);

	DEB_PLAY: entity work.debouncer		-- direct instantiation of component debouncer for play button
		port map(	CLK 	=> CLK,
					RST 	=> RST,
					I 		=> S_PLAY,
					O		=> S_DPLAY);

	DEB_DLT: entity work.debouncer		-- direct instantiation of component debouncer for delete button
		port map(	CLK 	=> CLK,
					RST 	=> RST,
					I 		=> S_DLT,
					O		=> S_DDLT);

	DEB_RCRD: entity work.debouncer		-- direct instantiation of component debouncer for record button
	port map(		CLK 	=> CLK,
					RST 	=> RST,
					I 		=> S_RCRD,
					O		=> S_DRCRD);

	DEB_PLUS: entity work.debouncer		-- direct instantiation of component debouncer for track+ button
		port map(	CLK 	=> CLK,
					RST 	=> RST,
					I 		=> S_PLUS,
					O		=> S_DPLUS);

	DEB_MINUS: entity work.debouncer	-- direct instantiation of component debouncer for track- button
		port map(	CLK 	=> CLK,
					RST 	=> RST,
					I 		=> S_MINUS,
					O		=> S_DMINUS);

	MENU: entity work.FSM_MENU			-- direct instantiation of component FSM_MENU, the menu control
		port map(	CLK 	=> CLK,
					RST 	=> RST,
					PLAY 	=> S_DPLAY,
					DLT 	=> S_DDLT,
					RCRD	=> S_DRCRD,
					PLUS 	=> S_DPLUS,
					MINUS	=> S_DMINUS,
					STATE	=> S_STATE,
					TRACK		=> S_BCD);

	TRANS: entity work.BCD2SSD			-- direct instantiation of component translation TRACK to SSD control signal
		port map(	TRACK 	=> S_BCD,
					SSD 	=> SSD);


	PLVL: entity work.peak_level_ctrl	-- direct instantiation of component peak level control
		port map(	clk 	=> CLK,
					rst 	=> RST,
					
					audioDataL => S_FIFO_I_DI,
					audioDataR => S_FIFO_O_DO,
					audioLevelLedL => S_LLVL,
					audioLevelLedR => S_RLVL);

	ICNV: entity work.SER2PAR_SPI		-- direct instantiation of component conversion to parallel data
		port map(	CLK 	=> CLK,
					RST 	=> RST,
					SCLK	=> SCLK_SPI,
					DOUT 	=> S_FIFO_I_DI,
					SDI 	=> SDI_SPI,
					CS =	> CS_SPI);

	FIFO_IN: entity work.fifo
		port map(	clk 			=> S_WS,
					reset			=> (RST and not S_FIFO_I_CLR),
					rd 				=> S_FIFO_I_RD,
					wr 				=> S_FIFO_I_WR,
					data_in			=> S_FIFO_I_DI,
					data_out		=> S_FIFO_I_DO,
					full 			=> open,
					empty 			=> open,
					almost_full		=> S_FIFO_O_WR,
					almost_empty	=> open);


	FIFO_OUT: entity work.fifo
		port map (	clk 			=> S_WS,
					reset 			=> RST,
					rd 				=> S_FIFO_O_RD,
					wr 				=> S_FIFO_O_WR,
					data_in 		=> S_FIFO_O_DI,
					data_out 		=> S_FIFO_O_DO,
					full 			=> open,
					empty 			=> open,
					almost_full 	=> S_FIFO_O_RD,
					almost_empty	=> open);
					
	NAVI: entity work.LEDmatrix
		port map(	CLK 	=> CLK,
					RST 	=> RST,
					STATE	=> S_STATE,
					MICLVL	=> S_LLVL,
					LSLVL	=> S_RLVL,
					LED 	=> LED);
	
	
	MEMC:	entity work.MEM_CTRL
		port map(	CLK					=> CLK,
					RST					=> RST,
					STATE				=> S_STATE,
					TRACK				=> S_TRACK,
					DELETE				=> '0',
					REC_PLAY			=> S_REC_PLAY,
					OCCUPIED			=> open,
					
					FIFO_I_EMPTY		=> S_FIFO_I_EMPTY,
					FIFO_I_ALMOST_FULL	=> S_FIFO_I_ALMOST_FULL,
					FIFO_I_RD			=> S_FIFO_I_RD,
					FIFO_I_WR			=> S_FIFO_I_WR_EN,
					FIFO_I_CLR			=> S_FIFO_I_CLR,
					FIFO_O_EMPTY		=> S_FIFO_O_EMPTY,
					FIFO_O_ALMOST_FULL	=> S_FIFO_O_ALMOST_FULL,
					FIFO_O_RD			=> S_FIFO_O_RD_EN,
					FIFO_O_WR			=> S_FIFO_O_WR,
					
					cmd_ready			=> S_RAM_READY,
					cmd_strobe			=> S_RAM_STROBE,
					cmd_wr				=> S_RAM_WR,
					cmd_address			=> S_RAM_ADDRESS,
					data_out_ready		=> S_RAM_DOUT_READY,

	STRI:	entity work.strobe_gen
		generic map (
					INTERVAL	=> 1024);
		
		port map (	CLK		=> CLK,
					RST		=> RST,
					INT		=> S_FIFO_I_WR,
					EN		=> S_FIFO_I_WR_EN);
	
	STRO:	entity work.strobe_gen
		generic map (
					INTERVAL	=> 1024);
		
		port map (	CLK		=> CLK,
					RST		=> RST,
					INT		=> S_FIFO_O_RD,
					EN		=> S_FIFO_O_RD_EN);


	SDRAM:	entity sdram_controller
		port map (	clock			=> CLK,
					reset_n			=> RST,
					cmd_ready		=> S_RAM_READY,
					cmd_strobe		=> S_RAM_STROBE,
					cmd_wr			=> S_RAM_WR,
					cmd_address		=> S_RAM_ADDRESS,
					cmd_data_in		=> S_FIFO_I_DO,
					data_out		=> S_FIFO_O_DI,
					data_out_ready	=> S_RAM_DOUT_READY,

					sdram_clk		=> sdram_clk,
					sdram_cke		=> sdram_cke,
					sdram_cs_n		=> sdram_cs_n,
					sdram_ras_n		=> sdram_ras_n,
					sdram_cas_n		=> sdram_cas_n,
					sdram_we_n		=> sdram_we_n,
					sdram_dqm_n		=> sdram_dqm_n,
					sdram_addr		=> sdram_addr,
					sdram_ba		=> sdram_ba,
					sdram_data		=> sdram_data);
end; -- architecture str












