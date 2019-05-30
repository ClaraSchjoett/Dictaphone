----------------------------------------------------------------------------------
-- www.Beis.de
-- Uwe Beis
--
-- Create Date:		2006-04-01
-- Project Name:	DigitalLevelMeter
-- Design Name:		DigitalLevelMeter
-- Module Name:		PeakLevelMeter - Behavioral
-- Description:		Detects the peak level
--             		and decreases it with a time constant of 20 dB per 1.5s
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PeakLevelMeter is
	generic
	(	MClkFreq	: integer := 50 -- Master Clock in MHz
	);
	port
	(	MClk		: in std_logic;
		Clk1msEn	: in std_logic;
		AudioDataL	: in std_logic_vector(15 downto 0);
		AudioDataR	: in std_logic_vector(15 downto 0);
		AudioLevelL	: out std_logic_vector(14 downto 0);
		AudioLevelR	: out std_logic_vector(14 downto 0);
		AudioLevelLedL	: out std_logic_vector(11 downto 0);
  	AudioLevelLedR  : out std_logic_vector(11 downto 0);
		ClipL		: out std_logic;
		ClipR		: out std_logic
	);
end PeakLevelMeter;

architecture Behavioral of PeakLevelMeter is

constant TimerInterval	: integer := 1000; -- Update timer interval in us
signal absAudioDataL	: std_logic_vector(14 downto 0); -- The sign bit less than AudioData
signal absAudioDataR	: std_logic_vector(14 downto 0);
signal iAudioLevelL		: std_logic_vector(31 downto 0) := (others => '0');
signal iAudioLevelR		: std_logic_vector(31 downto 0) := (others => '0');
signal MultiplyInL		: std_logic_vector(31 downto 0) := (others => '0');
signal MultiplyInR		: std_logic_vector(31 downto 0) := (others => '0');
signal MultiplyOutL		: std_logic_vector(49 downto 0);
signal MultiplyOutR		: std_logic_vector(49 downto 0);

--	For the standardized PPM characteristics of 20dB within 1.5 seconds and an update
--	interval of 1 ms the multiplier must decrease each ms the actual level by 10^(1/1500),
--	i. e. multiply by 1/(10^(1/1500)), which is very close to 1, but lower.
--	As multiplicand for an 18 bit multiplier 1 corresponds to 2^18 and
--	(2^18)/(10^(1/1500)) = 261741.903
component Mult32x18
	port
	(	clock		: in std_logic;
		dataa		: in std_logic_vector (31 downto 0);
		datab		: in std_logic_vector (17 downto 0);
		result		: out std_logic_vector (49 downto 0)
	);
end component;

begin
	Multiply32X18L : MULT32X18
	port map
	(	clock	=> MClk,
		dataa	=> MultiplyInL,
		datab	=> conv_std_logic_vector(261742, 18),
		result	=> MultiplyOutL
	);

	Multiply32X18R : MULT32X18
	port map
	(	clock	=> MClk,
		dataa	=> MultiplyInR,
		datab	=> conv_std_logic_vector(261742, 18),
		result	=> MultiplyOutR
	);

	absAudioDataL <= AudioDataL(14 downto 0) when AudioDataL(15) = '0' else (not AudioDataL(14 downto 0));
	absAudioDataR <= AudioDataR(14 downto 0) when AudioDataR(15) = '0' else (not AudioDataR(14 downto 0));
	MultiplyInL	<= iAudioLevelL;
	MultiplyInR	<= iAudioLevelR;

	PeakDetectAndDecay : process (MClk,Clk1msEn,iAudioLevelL,iAudioLevelR)
	begin
		if MClk = '1' and MClk'event then
				-- Decay 20 dB in 1.5s:
				if Clk1msEn = '1' then
				iAudioLevelL <= MultiplyOutL(49 downto 18);
				iAudioLevelR <= MultiplyOutR(49 downto 18);
				ClipL <= '0';
				ClipR <= '0';
			end if;
			-- Attack has priority:
            if iAudioLevelL(31 downto 17) < absAudioDataL then
                iAudioLevelL <= absAudioDataL & "00000000000000000";
            end if;
            if (not absAudioDataL) = 0 then
                ClipL <= '1';
            end if;

            -- Attack has priority:
            if iAudioLevelR(31 downto 17) < absAudioDataR then
                iAudioLevelR <= absAudioDataR & "00000000000000000";
            end if;
            if (not absAudioDataR) = 0 then
                ClipR <= '1';
			end if;

            case iAudioLevelL(31 downto 28) is
               when "1111" => AudioLevelLedL <= x"FFF";
               when "1110" => AudioLevelLedL <= x"7FF";
               when "1101" => AudioLevelLedL <= x"3FF";
               when "1100" => AudioLevelLedL <= x"1FF";
               when "1011" => AudioLevelLedL <= x"0FF";
               when "1010" => AudioLevelLedL <= x"07F";
               when "1001" => AudioLevelLedL <= x"03F";
               when "1000" => AudioLevelLedL <= x"01F";
               when "0111" => AudioLevelLedL <= x"00F";
               when "0110" => AudioLevelLedL <= x"007";
               when "0101" => AudioLevelLedL <= x"003";
               when "0100" => AudioLevelLedL <= x"001";
               when others => AudioLevelLedL <= x"000";
            end case;

            case iAudioLevelR(31 downto 28) is
               when "1111" => AudioLevelLedR <= x"FFF";
               when "1110" => AudioLevelLedR <= x"7FF";
               when "1101" => AudioLevelLedR <= x"3FF";
               when "1100" => AudioLevelLedR <= x"1FF";
               when "1011" => AudioLevelLedR <= x"0FF";
               when "1010" => AudioLevelLedR <= x"07F";
               when "1001" => AudioLevelLedR <= x"03F";
               when "1000" => AudioLevelLedR <= x"01F";
               when "0111" => AudioLevelLedR <= x"00F";
               when "0110" => AudioLevelLedR <= x"007";
               when "0101" => AudioLevelLedR <= x"003";
               when "0100" => AudioLevelLedR <= x"001";
               when others => AudioLevelLedR <= x"000";
            end case;
		end if;
	end process PeakDetectAndDecay;

	AudioLevelL <= iAudioLevelL(31 downto 17);
	AudioLevelR <= iAudioLevelR(31 downto 17);

end  Behavioral;
