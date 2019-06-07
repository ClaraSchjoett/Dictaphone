-------------------------------------------------------------------------------
-- Title      	: 	DEC2SSD
-- Project    	: 	Dictaphone
-------------------------------------------------------------------------------
-- File       	: 	DEC2SSD.vhd
-- Author     	: 	Clara Schjoett
-- Company    	: 	BFH-TI-EKT
-- Created    	: 	2019-05-26
-- Last update	: 	2019-05-26
-- Platform   	: 	Xilinx ISE 14.7
-- Standard   	: 	VHDL'93/02, Math Packages
-------------------------------------------------------------------------------
-- Description	: 	Conversion of 2 numbers to display on the 4 seven segment 
--					display on the Gecko4Education FPGA Board.
--					The design is purely combinational and thus requires no clock.
-------------------------------------------------------------------------------
-- Revisions  	:
-- Date				Version		Author  	Description
-- 2019-05-26		1.0      	Clara		Created
-- 2019-06-07		1.1			Clara		Small refinements
-------------------------------------------------------------------------------
-- Inputs:
-- TRACK				Current track number, represented by 4 bits
-- FREE_SLOTS			Number of free slots, represented by 5 bits
--
-- Outputs:
-- SSD					Seven segment display control. 32 bits (4x8 bits)
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity DEC2SSD is

  port (	TRACK      	: in std_logic_vector(3 downto 0); 
			FREE_SLOTS	: in std_logic_vector(4 downto 0);
			OCCUPIED	: in std_logic;
			SSD			: out std_logic_vector(31 downto 0));	 

end entity DEC2SSD;

-------------------------------------------------------------------------------

architecture rtl of DEC2SSD is
 
begin -- architecture rtl
	
	-- set 3 dots to zero 
	SSD(31) <= '0';
	SSD(23) <= OCCUPIED;
	SSD(15) <= '0';
	SSD(7)  <= '0';
	
	-- Switch-case must be encapsulated inside a process to work!				 
	TRANS: process(TRACK, FREE_SLOTS)
	begin
		-- MUX for bit 4 ... 0, last two cifres
		case (FREE_SLOTS) is
			when "00000" => 					-- 0
				SSD(30 downto 24) <= "0111111"; -- 4th display from l.t.r
				SSD(22 downto 16) <= "0000000"; -- 3rd display from l.t.r
			when "00001" =>   					-- 1
				SSD(30 downto 24) <= "0000110";   
				SSD(22 downto 16) <= "0000000"; 
			when "00010" => 					-- 2
				SSD(30 downto 24) <= "1011011"; 
				SSD(22 downto 16) <= "0000000";
			when "00011" => 					-- 3
				SSD(30 downto 24) <= "1001111";  
				SSD(22 downto 16) <= "0000000";
			when "00100" =>						-- 4
				SSD(30 downto 24) <= "1100110"; 
				SSD(22 downto 16) <= "0000000";
			when "00101" => 					-- 5
				SSD(30 downto 24) <= "1101101"; 
				SSD(22 downto 16) <= "0000000";
			when "00110" =>						-- 6
				SSD(30 downto 24) <= "1111101"; 
				SSD(22 downto 16) <= "0000000";
			when "00111" => 					-- 7
				SSD(30 downto 24) <= "0000111";
				SSD(22 downto 16) <= "0000000";
			when "01000" => 					-- 8
				SSD(30 downto 24) <= "1111111"; 
				SSD(22 downto 16) <= "0000000";
			when "01001" => 					-- 9
				SSD(30 downto 24) <= "1101111";
				SSD(22 downto 16) <= "0000000";
			when "01010" => 					-- 10
				SSD(30 downto 24) <= "0111111";
				SSD(22 downto 16) <= "0000110";
			when "01011" => 					-- 11
				SSD(30 downto 24) <= "0000110";
				SSD(22 downto 16) <= "0000110";
			when "01100" => 					-- 12
				SSD(30 downto 24) <= "1011011"; 
				SSD(22 downto 16) <= "0000110";
			when "01101" => 					-- 13
				SSD(30 downto 24) <= "1001111"; 
				SSD(22 downto 16) <= "0000110";
			when "01110" => 					-- 14
				SSD(30 downto 24) <= "1100110"; 
				SSD(22 downto 16) <= "0000110";
			when "01111" => 					-- 15
				SSD(30 downto 24) <= "1101101"; 
				SSD(22 downto 16) <= "0000110";
			when "10000" => 					-- 16
				SSD(30 downto 24) <= "1111101"; 
				SSD(22 downto 16) <= "0000110";
			when others => 						-- display off
				SSD(30 downto 24) <= "0000000"; 
				SSD(22 downto 16) <= "0000000";
		end case;	 
		
		
			-- MUX for bit 9 ... 5, first two cifres
		case (TRACK) is
			when "0000" =>   					-- 1
				SSD(14 downto 8)  <= "0000110"; -- 2nd display from l.t.r
				SSD(6 downto 0)   <= "0000000"; -- 1st display from l.t.r
			when "0001" => 						-- 2
				SSD(14 downto 8)  <= "1011011"; 
				SSD(6 downto 0)   <= "0000000";
			when "0010" => 						-- 3
				SSD(14 downto 8)  <= "1001111";  
				SSD(6 downto 0)   <= "0000000";
			when "0011" =>						-- 4
				SSD(14 downto 8)  <= "1100110"; 
				SSD(6 downto 0)   <= "0000000";
			when "0100" => 						-- 5
				SSD(14 downto 8)  <= "1101101"; 
				SSD(6 downto 0)   <= "0000000";
			when "0101" =>						-- 6
				SSD(14 downto 8)  <= "1111101"; 
				SSD(6 downto 0)   <= "0000000";
			when "0110" => 						-- 7
				SSD(14 downto 8)  <= "0000111";
				SSD(6 downto 0)   <= "0000000";
			when "0111" => 						-- 8
				SSD(14 downto 8)  <= "1111111"; 
				SSD(6 downto 0)   <= "0000000";
			when "1000" => 						-- 9
				SSD(14 downto 8)  <= "1101111";
				SSD(6 downto 0)   <= "0000000";
			when "1001" => 						-- 10
				SSD(14 downto 8)  <= "0111111";
				SSD(6 downto 0)   <= "0000110";
			when "1010" => 						-- 11
				SSD(14 downto 8)  <= "0000110";
				SSD(6 downto 0)   <= "0000110";
			when "1011" => 						-- 12
				SSD(14 downto 8)  <= "1011011"; 
				SSD(6 downto 0)   <= "0000110";
			when "1100" => 						-- 13
				SSD(14 downto 8)  <= "1001111"; 
				SSD(6 downto 0)   <= "0000110";
			when "1101" => 						-- 14
				SSD(14 downto 8)  <= "1100110"; 
				SSD(6 downto 0)   <= "0000110";
			when "1110" => 						-- 15
				SSD(14 downto 8)  <= "1101101"; 
				SSD(6 downto 0)   <= "0000110";
			when "1111" => 						-- 16
				SSD(14 downto 8)  <= "1111101"; 
				SSD(6 downto 0)   <= "0000110";
			when others => 						-- Display off
				SSD(14 downto 8)  <= "0000000"; 
				SSD(6 downto 0)   <= "0000000";
		end case;	 
	end process;
	
end architecture rtl;