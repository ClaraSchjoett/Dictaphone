-------------------------------------------------------------------------------
-- Title      	: 	BCD2SSD
-- Project    	: 	Dictaphone
-------------------------------------------------------------------------------
-- File       	: 	BCD2SSD.vhd
-- Author     	: 	Clara Schjoett
-- Company    	: 	BFH-TI-EKT
-- Created    	: 	2019-05-26
-- Last update	: 	2019-05-26
-- Platform   	: 	Xilinx ISE 14.7
-- Standard   	: 	VHDL'93/02, Math Packages
-------------------------------------------------------------------------------
-- Description	: 	Conversion of 2 BCD numbers to display on the 4 seven segment 
--					display on the Gecko4Education FPGA Board.
--					The design is purely combinational and thus requires no clock.
-------------------------------------------------------------------------------
-- Revisions  	:
-- Date				Version		Author  	Description
-- 2019-05-26		1.0      	Clara		Created
-------------------------------------------------------------------------------
-- Inputs		:
-- BCD				10 bits, separated into 2x5 bits.
--
-- Outputs:
-- SSD				Seven segment display control. 32 bits (4x8 bits)
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity BCD2SSD is

  port (	BCD        	: in std_logic_vector(9 downto 0);   
			SSD			: out std_logic_vector(31 downto 0));	 

end entity BCD2SSD;

-------------------------------------------------------------------------------

architecture rtl of BCD2SSD is
 
begin -- architecture rtl
	
	-- set all dots to zero
	SSD(31) <= '0';
	SSD(23) <= '0';
	SSD(15) <= '0';
	SSD(7)  <= '0';
	
	
	-- MUX for bit 4 ... 0, last two cifres
	case (BCD(4 downto 0)) is
		when "00000" => 					-- 00
			SSD(30 downto 24) <= "1111110";  
			SSD(22 downto 16) <= "1111110";
		when "00001" =>   					-- 01
			SSD(30 downto 24) <= "1111110";  
			SSD(22 downto 16) <= "0110000";
		when "00010" => 					-- 02
			SSD(30 downto 24) <= "1111110";  
			SSD(22 downto 16) <= "1101101";
		when "00011" => 					-- 03
			SSD(30 downto 24) <= "1111110";  
			SSD(22 downto 16) <= "1111001";
		when "00100" =>						-- 04
			SSD(30 downto 24) <= "1111110";  
			SSD(22 downto 16) <= "0110011";
		when "00101" => 					-- 05
			SSD(30 downto 24) <= "1111110";  
			SSD(22 downto 16) <= "1011011";
		when "00110" =>						-- 06
			SSD(30 downto 24) <= "1111110";  
			SSD(22 downto 16) <= "1011111";
		when "00111" => 					-- 07
			SSD(30 downto 24) <= "1111110";  
			SSD(22 downto 16) <= "1110000";
		when "01000" => 					-- 08
			SSD(30 downto 24) <= "1111110";  
			SSD(22 downto 16) <= "1111111";
		when "01001" => 					-- 09
			SSD(30 downto 24) <= "1111110";  
			SSD(22 downto 16) <= "1111011";
		when "01010" => 					-- 10
			SSD(30 downto 24) <= "0110000";  
			SSD(22 downto 16) <= "1111110";
		when "01011" => 					-- 11
			SSD(30 downto 24) <= "0110000";  
			SSD(22 downto 16) <= "0110000";
		when "01100" => 					-- 12
			SSD(30 downto 24) <= "0110000";  
			SSD(22 downto 16) <= "1101101";
		when "01101" => 					-- 13
			SSD(30 downto 24) <= "0110000";  
			SSD(22 downto 16) <= "1111001";
		when "01110" => 					-- 14
			SSD(30 downto 24) <= "0110000";  
			SSD(22 downto 16) <= "0110011";
		when "01111" => 					-- 15
			SSD(30 downto 24) <= "0110000";  
			SSD(22 downto 16) <= "1011011";
		when "10000" => 					-- 16
			SSD(30 downto 24) <= "0110000";  
			SSD(22 downto 16) <= "1011111";
		when "10001" => 					-- 17
			SSD(30 downto 24) <= "0110000";  
			SSD(22 downto 16) <= "1110000";
		when "10010" => 					-- 18
			SSD(30 downto 24) <= "0110000";  
			SSD(22 downto 16) <= "1111111";
		when "10011" => 					-- 19
			SSD(30 downto 24) <= "0110000";  
			SSD(22 downto 16) <= "1111011";
		when "10100" => 					-- 20
			SSD(30 downto 24) <= "1101101";  
			SSD(22 downto 16) <= "1111110";
		when "10101" => 					-- 21
			SSD(30 downto 24) <= "1101101";  
			SSD(22 downto 16) <= "0110000";
		when others => 
			SSD(30 downto 24) <= "1111110";  
			SSD(22 downto 16) <= "1111110";
	end case;	 
	
	
		-- MUX for bit 9 ... 5, first two cifres
	case (BCD(9 downto 5)) is
		when "00000" => 					-- 00
			SSD(30 downto 24) <= "1111110";  
			SSD(22 downto 16) <= "1111110";
		when "00001" =>   					-- 01
			SSD(30 downto 24) <= "1111110";  
			SSD(22 downto 16) <= "0110000";
		when "00010" => 					-- 02
			SSD(30 downto 24) <= "1111110";  
			SSD(22 downto 16) <= "1101101";
		when "00011" => 					-- 03
			SSD(30 downto 24) <= "1111110";  
			SSD(22 downto 16) <= "1111001";
		when "00100" =>						-- 04
			SSD(30 downto 24) <= "1111110";  
			SSD(22 downto 16) <= "0110011";
		when "00101" => 					-- 05
			SSD(30 downto 24) <= "1111110";  
			SSD(22 downto 16) <= "1011011";
		when "00110" =>						-- 06
			SSD(30 downto 24) <= "1111110";  
			SSD(22 downto 16) <= "1011111";
		when "00111" => 					-- 07
			SSD(30 downto 24) <= "1111110";  
			SSD(22 downto 16) <= "1110000";
		when "01000" => 					-- 08
			SSD(30 downto 24) <= "1111110";  
			SSD(22 downto 16) <= "1111111";
		when "01001" => 					-- 09
			SSD(30 downto 24) <= "1111110";  
			SSD(22 downto 16) <= "1111011";
		when "01010" => 					-- 10
			SSD(30 downto 24) <= "0110000";  
			SSD(22 downto 16) <= "1111110";
		when "01011" => 					-- 11
			SSD(30 downto 24) <= "0110000";  
			SSD(22 downto 16) <= "0110000";
		when "01100" => 					-- 12
			SSD(30 downto 24) <= "0110000";  
			SSD(22 downto 16) <= "1101101";
		when "01101" => 					-- 13
			SSD(30 downto 24) <= "0110000";  
			SSD(22 downto 16) <= "1111001";
		when "01110" => 					-- 14
			SSD(30 downto 24) <= "0110000";  
			SSD(22 downto 16) <= "0110011";
		when "01111" => 					-- 15
			SSD(30 downto 24) <= "0110000";  
			SSD(22 downto 16) <= "1011011";
		when "10000" => 					-- 16
			SSD(30 downto 24) <= "0110000";  
			SSD(22 downto 16) <= "1011111";
		when "10001" => 					-- 17
			SSD(30 downto 24) <= "0110000";  
			SSD(22 downto 16) <= "1110000";
		when "10010" => 					-- 18
			SSD(30 downto 24) <= "0110000";  
			SSD(22 downto 16) <= "1111111";
		when "10011" => 					-- 19
			SSD(30 downto 24) <= "0110000";  
			SSD(22 downto 16) <= "1111011";
		when "10100" => 					-- 20
			SSD(30 downto 24) <= "1101101";  
			SSD(22 downto 16) <= "1111110";
		when "10101" => 					-- 21
			SSD(30 downto 24) <= "1101101";  
			SSD(22 downto 16) <= "0110000";
		when others => 
			SSD(30 downto 24) <= "1111110";  
			SSD(22 downto 16) <= "1111110";
	end case;	 
	
end architecture rtl;