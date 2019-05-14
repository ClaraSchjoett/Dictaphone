-------------------------------------------------------------------------------
-- Title      	: 	PAR2SER_I2S
-- Project    	: 	Dictaphone
-------------------------------------------------------------------------------
-- File       	: 	MyFile.vhd
-- Author     	: 	Peter Wuethrich
-- Company    	: 	BFH
-- Created    	: 	2019-05-10
-- Last update	: 	2019
-- Platform   	: 	Xilinx ISE 14.7
-- Standard   	: 	VHDL'93/02, Math Packages
-- Sources		:	https://www.digikey.com/eewiki/pages/viewpage.action?pageId=84738137#I2STransceiver(VHDL)-CodeDownload
-------------------------------------------------------------------------------
-- Description	: 	converts 16 bit SPI serial data to parallel data for
-- 					transmitting data from PMOD_MIC to FIFO.
--					Serial data is represented in two's compliment (signed).
-------------------------------------------------------------------------------
-- Revisions  	:
-- Date        		Version  	Author  	Description
-- 2019-05-10		1.0			Peter		Created
-------------------------------------------------------------------------------
-- Inputs		:
-- CLK				Onboard system clock (50MHz)
-- RST				Resets the internal counters and sets data to zero
-- SDI				Serial data in
--
-- Outputs		:
-- SCLK				Serial clock for SPI interface (50MHz)
-- DOUT				Parallel data out. Side note: resolution of MIC is 12 bit,
--					  but gets upscaled to 16bit

-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SER2PAR_SPI is

	generic(	CLK_SCLK_RATIO	: integer:= 4;		-- number of clock periods per serial clock period. specs: CLK 50MHz, SCLK 12.5MHz, ratio: 4
            BITWIDTHIN		: integer:= 16;		-- parallel data width
            BITWIDTHOUT		: integer:= 16);	-- serial data width

	port( CLK       : in std_logic;		-- system clock (50MHz)
        SCLK      : out std_logic;   -- serial clock (12.5MHz)
				RST       : in std_logic;		-- asynchronous active low reset
				DOUT      : out std_logic_vector(BITWIDTHIN-1 downto 0);
				SDI    	  : in std_logic;
        CS        : out std_logic);

end SER2PAR_SPI;


architecture rtl of SER2PAR_SPI is
	signal S_SCLK				: std_logic := '0';	-- same here
	signal S_DATA				: std_logic_vector(BITWIDTHIN-1 downto 0);
  signal S_CS         : std_logic := '0';
begin -- architecture rtl

	-- Ouput signal match
	SCLK <= S_SCLK;									-- output serial clock

	-- Conversion from parallel to serial and expanding vector length from BITWIDTHIN to BITWIDTHOUT
	CONVERSION: process (RST, CLK)
		variable sclk_cnt		: integer := 0; 	-- counter of master clock during half period of serial clock
    variable inbit_cnt  : integer := 0;
    variable wait_cnt   : integer := 0;
	begin -- process CONVERSION

		if RST = '0' then							-- assume reset low-active
			S_DATA <= (others => '0');	-- clear input shift register
			sclk_cnt := 0;							-- clear serial clock counter
			S_SCLK <= '1';							-- clear serial clock signal


		elsif CLK'event and CLK = '1' and sclk_cnt < (CLK_SCLK_RATIO/2-1) then			-- if not reset, wait for system clock raising edge

			if sclk_cnt < (CLK_SCLK_RATIO/2-1) then-- 16 system clock periods per serial clock period
				sclk_cnt := sclk_cnt + 1;
			else
				sclk_cnt := 0;						-- reset master clock counter
				S_SCLK <= not S_SCLK;				-- toggle serial clock

        if S_SCLK = '1' and S_CS = '1' then
          if wait_cnt <2 then
            wait_cnt := wait_cnt + 1;
          else
            wait_cnt := 0;
            S_CS <= '0';
          end if;
        end if;

        if S_SCLK = '0' and S_CS = '0' then
          if inbit_cnt < BITWIDTHIN then
            inbit_cnt := inbit_cnt + 1;
            S_DATA <= S_DATA(BITWIDTHIN-2 downto 0) & SDI; --shift SDI into register
          else
            inbit_cnt := '0';
            DOUT <= S_DATA(BITWIDTHIN-5) & "000";
            S_DATA <= (others => '0');
            S_CS <= '1';
          end if;
        end if;
      end if;
    end if;
	end process; -- CONVERSION


end rtl;
