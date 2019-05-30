LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY peak_level_ctrl IS
PORT (
	clk, rst		 			: IN STD_LOGIC;
	audioDataL				: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	audioDataR				: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	audioLevelLedL		: OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
	audioLevelLedR  	: OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
	);
END peak_level_ctrl;


ARCHITECTURE functional_level OF peak_level_ctrl IS

	-- generic signals
	CONSTANT g_MClkFreq	: integer := 50; -- Master Clock in MHz

	-- digital signals
	SIGNAL s_clk_1kHz_en : STD_LOGIC;
	SIGNAL	s_AudioDataL			: STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL	s_AudioDataR			: STD_LOGIC_VECTOR(15 DOWNTO 0);
	-- component declarations
	COMPONENT clk_divider_1khz
  PORT(
    CLK      		: IN STD_LOGIC;
    RST      		: IN STD_LOGIC;
	 	clk_en	 		: OUT STD_LOGIC;
	 	clk_1kHz_en : OUT STD_LOGIC
  );
	END COMPONENT ;

	COMPONENT PeakLevelMeter
	GENERIC(
		MClkFreq	: integer := 50 -- Master Clock in MHz
	);
	PORT(
		MClk						: IN STD_LOGIC;
		Clk1msEn				: IN STD_LOGIC;
		AudioDataL			: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		AudioDataR			: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		AudioLevelL			: OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
		AudioLevelR			: OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
		AudioLevelLedL	: OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
  	AudioLevelLedR  : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
		ClipL						: OUT STD_LOGIC;
		ClipR						: OUT STD_LOGIC
	);
	END COMPONENT;

BEGIN

	-- Input Signal wiring
	s_AudioDataL <= not(audioDataL(15)) & audioDataL(14 downto 0);
	s_AudioDataR <= not(audioDataR(15)) & audioDataR(14 downto 0);

	-- Instantiation of components
	inst1_clk_divider_1khz : clk_divider_1khz
	PORT MAP(
		CLK => clk,
		RST => rst,
		clk_en => open,
		clk_1kHz_en => s_clk_1kHz_en
	);

	inst1_PeakLevelMeter : PeakLevelMeter
	GENERIC MAP(
		MClkFreq => g_MClkFreq
	)
	PORT MAP(
		MCLK => clk,
		Clk1msEn => s_clk_1kHz_en,
		AudioDataL => s_AudioDataL,
		AudioDataR => s_AudioDataR,
		AudioLevelL => open,
		AudioLevelR => open,
		AudioLevelLedL => audioLevelLedL,
		AudioLevelLedR => audioLevelLedR,
		ClipL => open,
		ClipR => open
	);

END functional_level;
