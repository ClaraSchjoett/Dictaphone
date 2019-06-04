-------------------------------------------------------------------------------
-- Title      	: 	LEDmatrix
-- Project    	: 	Dictaphone
-------------------------------------------------------------------------------
-- File       	: 	LEDmatrix.vhd
-- Author     	: 	Clara Schjoett
-- Company    	: 	BFH
-- Created    	: 	2019-06-04
-- Last update	: 	2019
-- Platform   	: 	Xilinx ISE 14.7
-- Standard   	: 	VHDL'93/02, Math Packages
-- Sources		:	http://www.deathbylogic.com/2013/07/vhdl-standard-fifo/
-------------------------------------------------------------------------------
-- Description	: 	Testbench for standard FIFO-Buffer
-------------------------------------------------------------------------------
-- Revisions  	:
-- Date        		Version		Author		Description
-- 2019-06-04		1.0			Clara		Created
-------------------------------------------------------------------------------
-- Inputs		:
-- CLK				System clock
-- RST				Low active reset
-- STATE			2 bit coded state indicating PLAY, RECORD, DELETE
--
-- Outputs		:
-- LED				7x12 LED matrix (8th row alwas off, last two rows controlled by microphone)
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Own packages
use work.gecko4_education_pkg.all;

entity LEDmatrix is

	port(	CLK		: in std_logic;
			RST		: in std_logic;			
			STATE	: in std_logic_vector(1 downto 0);			

			LED		: out std_logic_matrix(1 to 7, 1 to 12));

end entity LEDmatrix;

architecture rtl of LEDmatrix is
	signal tenths_reg, tenths_next 	: std_logic_vector(3 downto 0);
	signal ones_reg, ones_next		: std_logic_vector(3 downto 0);
	signal tens_reg, tens_next		: std_logic_vector(3 downto 0);
	signal impulse					: std_logic;
begin -- architecture rtl

	-- Instantiate strobe generator for incrementing least signifcant digit (tenths)
	STR: entity work.strobe_gen(rtl)
		generic map(
			INTERVAL	=> 5000000)
		port map(
			CLK			=> CLK,
			RST			=> RST,
			IMP			=> impulse);

	-- Clock in new values into registers
	-- Type: Sequential
	REG: process(CLK, RST) is
	begin -- process REG
		if RST = '0' then						-- Asynchronous low active reset sets all registers (except for edge_pos_reg) to zero
			tenths_reg 	<= (others => '0');
			ones_reg 	<= (others => '0');
			tens_reg 	<= (others => '0');
		elsif rising_edge(CLK) then			-- Clock in values into registers
			tenths_reg 	<= tenths_next;
			ones_reg 	<= ones_next;
			tens_reg 	<= tens_next;
		end if;
	end process REG;
	
	NSL: process(STATE, impulse, tenths_reg, ones_reg, tens_reg)is
	begin -- process NSL
		tenths_next <= tenths_reg;				-- this assignment is used in case of no state IMP. 
		ones_next	<= ones_reg;				-- Always the last assignment is valid in a process!
		tens_next	<= tens_reg;

		case STATE is 
			when "01" | "10" =>				-- PLAYING or RECORDING	
				if impulse = '1' then
					tenths_next <= tenths_reg + '1';
					if tenths_reg = 9 then
						ones_next <= ones_reg + 1;
						tenths_next <= (others => '0');
						if ones_reg = 9 then
							tens_next <= tens_reg + 1;
							ones_next <= (others => '0');
						end if;
					end if;	
				end if;		
			when others => null;				-- all other states
				tenths_reg 	<= (others => '0');
				ones_reg 	<= (others => '0');
				tens_reg 	<= (others => '0');
		end case;
				
	end process NSL;
	
	-- Evaluate current value of tenths, ones and tens and write to LED matrix
	-- Type: Combinational
	OL : process (tenths_reg, ones_reg, tens_reg) is	
	begin  -- process OL
	
		-- LEDs are off by default
		LED <= (others => (others => '0'));
		
		-- MUX for digit tenths 
		case (tenths_reg) is
			when "0000" => 		-- 0
				LED(1,11)  <= '1';
				LED(2,10)  <= '1';
				LED(2,12)  <= '1';
				LED(3,10)  <= '1';
				LED(3,12)  <= '1';
				LED(4,10)  <= '1';
				LED(4,12)  <= '1';
				LED(5,10)  <= '1';
				LED(5,12)  <= '1';
				LED(6,10)  <= '1';
				LED(6,12)  <= '1';
				LED(7,11)  <= '1';
			when "0001" =>   	-- 1
				LED(1,11)  <= '1';
				LED(2,10)  <= '1';
				LED(2,11)  <= '1';
				LED(3,11)  <= '1';
				LED(4,11)  <= '1';
				LED(5,11)  <= '1';
				LED(6,11)  <= '1';
				LED(7,10)  <= '1';
				LED(7,11)  <= '1';
				LED(7,12)  <= '1';
			when "0010" => 		-- 2
				LED(1,11)  <= '1';
				LED(2,10)  <= '1';
				LED(2,12)  <= '1';
				LED(3,12)  <= '1';
				LED(4,11)  <= '1';
				LED(5,11)  <= '1';
				LED(6,10)  <= '1';
				LED(7,10)  <= '1';
				LED(7,11)  <= '1';
				LED(7,12)  <= '1';
			when "0011" => 		-- 3
				LED(1,11)  <= '1';
				LED(2,10)  <= '1';
				LED(2,12)  <= '1';
				LED(3,12)  <= '1';
				LED(4,11)  <= '1';
				LED(5,12)  <= '1';
				LED(6,10)  <= '1';
				LED(6,12)  <= '1';
				LED(7,11)  <= '1';
			when "0100" =>		-- 4
				LED(1,12)  <= '1';
				LED(2,11)  <= '1';
				LED(2,12)  <= '1';
				LED(3,11)  <= '1';
				LED(3,12)  <= '1';
				LED(4,10)  <= '1';
				LED(4,12)  <= '1';
				LED(5,10)  <= '1';
				LED(5,12)  <= '1';
				LED(6,12)  <= '1';
				LED(7,12)  <= '1';
			when "0101" => 		-- 5
				LED(1,10)  <= '1';
				LED(1,11)  <= '1';
				LED(1,12)  <= '1';
				LED(2,10)  <= '1';
				LED(3,10)  <= '1';
				LED(4,10)  <= '1';
				LED(4,11)  <= '1';
				LED(5,12)  <= '1';
				LED(6,10)  <= '1';
				LED(6,12)  <= '1';
				LED(7,11)  <= '1';
			when "0110" =>		-- 6
				LED(1,11)  <= '1';
				LED(1,12)  <= '1';
				LED(2,10)  <= '1';
				LED(3,10)  <= '1';
				LED(4,10)  <= '1';
				LED(4,11)  <= '1';
				LED(5,10)  <= '1';
				LED(5,12)  <= '1';
				LED(6,10)  <= '1';
				LED(6,12)  <= '1';
				LED(7,11)  <= '1';
			when "0111" => 		-- 7
				LED(1,10)  <= '1';
				LED(1,11)  <= '1';
				LED(1,12)  <= '1';
				LED(2,12)  <= '1';
				LED(3,12)  <= '1';
				LED(4,11)  <= '1';
				LED(5,11)  <= '1';
				LED(6,11)  <= '1';
				LED(7,11)  <= '1';
			when "1000" => 		-- 8
				LED(1,11)  <= '1';
				LED(2,10)  <= '1';
				LED(2,12)  <= '1';
				LED(3,10)  <= '1';
				LED(3,12)  <= '1';
				LED(4,11)  <= '1';
				LED(5,10)  <= '1';
				LED(5,12)  <= '1';
				LED(6,10)  <= '1';
				LED(6,12)  <= '1';
				LED(7,11)  <= '1';
			when "1001" => 		-- 9
				LED(1,11)  <= '1';
				LED(2,10)  <= '1';
				LED(2,12)  <= '1';
				LED(3,10)  <= '1';
				LED(3,12)  <= '1';
				LED(4,11)  <= '1';
				LED(5,12)  <= '1';
				LED(6,10)  <= '1';
				LED(6,12)  <= '1';
				LED(7,11)  <= '1';
			when others => 		-- LEDs off
				LED <= (others => (others => '0'));
		end case;	 
			
		-- MUX for digit ones
		case (ones_reg) is
			when "0000" => 		-- 0
				LED(1,5)   <= '1';
				LED(2,4)   <= '1';
				LED(2,6)   <= '1';
				LED(3,4)   <= '1';
				LED(3,6)   <= '1';
				LED(4,4)   <= '1';
				LED(4,6)   <= '1';
				LED(5,4)   <= '1';
				LED(5,6)   <= '1';
				LED(6,4)   <= '1';
				LED(6,6)   <= '1';
				LED(7,5)   <= '1';
			when "0001" =>   	-- 1
				LED(1,5)   <= '1';
				LED(2,4)   <= '1';
				LED(2,5)   <= '1';
				LED(3,5)   <= '1';
				LED(4,5)   <= '1';
				LED(5,5)   <= '1';
				LED(6,5)   <= '1';
				LED(7,4)   <= '1';
				LED(7,5)   <= '1';
				LED(7,6)   <= '1'; 
			when "0010" => 		-- 2
				LED(1,5)   <= '1';
				LED(2,4)   <= '1';
				LED(2,6)   <= '1';
				LED(3,6)   <= '1';
				LED(4,5)   <= '1';
				LED(5,5)   <= '1';
				LED(6,4)   <= '1';
				LED(7,4)   <= '1';
				LED(7,5)   <= '1';
				LED(7,6)   <= '1';
			when "0011" => 		-- 3
				LED(1,5)   <= '1';
				LED(2,4)   <= '1';
				LED(2,6)   <= '1';
				LED(3,6)   <= '1';
				LED(4,5)   <= '1';
				LED(5,6)   <= '1';
				LED(6,4)   <= '1';
				LED(6,6)   <= '1';
				LED(7,5)   <= '1';
			when "0100" =>		-- 4
				LED(1,6)   <= '1';
				LED(2,5)   <= '1';
				LED(2,6)   <= '1';
				LED(3,5)   <= '1';
				LED(3,6)   <= '1';
				LED(4,4)   <= '1';
				LED(4,6)   <= '1';
				LED(5,4)   <= '1';
				LED(5,6)   <= '1';
				LED(6,6)   <= '1';
				LED(7,6)   <= '1';
			when "0101" => 		-- 5
				LED(1,4)   <= '1';
				LED(1,5)   <= '1';
				LED(1,6)   <= '1';
				LED(2,4)   <= '1';
				LED(3,4)   <= '1';
				LED(4,4)   <= '1';
				LED(4,5)   <= '1';
				LED(5,6)   <= '1';
				LED(6,4)   <= '1';
				LED(6,6)   <= '1';
				LED(7,5)   <= '1';
			when "0110" =>		-- 6
				LED(1,5)   <= '1';
				LED(1,6)   <= '1';
				LED(2,4)   <= '1';
				LED(3,4)   <= '1';
				LED(4,4)   <= '1';
				LED(4,5)   <= '1';
				LED(5,4)   <= '1';
				LED(5,6)   <= '1';
				LED(6,4)   <= '1';
				LED(6,6)   <= '1';
				LED(7,5)   <= '1';
			when "0111" => 		-- 7
				LED(1,4)   <= '1';
				LED(1,5)   <= '1';
				LED(1,6)   <= '1';
				LED(2,6)   <= '1';
				LED(3,6)   <= '1';
				LED(4,5)   <= '1';
				LED(5,5)   <= '1';
				LED(6,5)   <= '1';
				LED(7,5)   <= '1';
			when "1000" => 		-- 8
				LED(1,5)   <= '1';
				LED(2,4)   <= '1';
				LED(2,6)   <= '1';
				LED(3,4)   <= '1';
				LED(3,6)   <= '1';
				LED(4,5)   <= '1';
				LED(5,4)   <= '1';
				LED(5,6)   <= '1';
				LED(6,4)   <= '1';
				LED(6,6)   <= '1';
				LED(7,5)   <= '1';
			when "1001" => 		-- 9
				LED(1,5)   <= '1';
				LED(2,4)   <= '1';
				LED(2,6)   <= '1';
				LED(3,4)   <= '1';
				LED(3,6)   <= '1';
				LED(4,5)   <= '1';
				LED(5,6)   <= '1';
				LED(6,4)   <= '1';
				LED(6,6)   <= '1';
				LED(7,5)   <= '1';
			when others => 		-- LEDs off
				LED <= (others => (others => '0'));
		end case;
		
		-- MUX for digit tens
		case (tens_reg) is
			when "0000" => 		-- 0
				LED(1,2)   <= '1';
				LED(2,1)   <= '1';
				LED(2,3)   <= '1';
				LED(3,1)   <= '1';
				LED(3,3)   <= '1';
				LED(4,1)   <= '1';
				LED(4,3)   <= '1';
				LED(5,1)   <= '1';
				LED(5,3)   <= '1';
				LED(6,1)   <= '1';
				LED(6,3)   <= '1';
				LED(7,2)   <= '1';
			when "0001" =>   	-- 1
				LED(1,2)   <= '1';
				LED(2,1)   <= '1';
				LED(2,2)   <= '1';
				LED(3,2)   <= '1';
				LED(4,2)   <= '1';
				LED(5,2)   <= '1';
				LED(6,2)   <= '1';
				LED(7,1)   <= '1';
				LED(7,2)   <= '1';
				LED(7,3)   <= '1';
			when "0010" => 		-- 2
				LED(1,2)   <= '1';
				LED(2,1)   <= '1';
				LED(2,3)   <= '1';
				LED(3,3)   <= '1';
				LED(4,2)   <= '1';
				LED(5,2)   <= '1';
				LED(6,1)   <= '1';
				LED(7,1)   <= '1';
				LED(7,2)   <= '1';
				LED(7,3)   <= '1';
			when "0011" => 		-- 3
				LED(1,2)   <= '1';
				LED(2,1)   <= '1';
				LED(2,3)   <= '1';
				LED(3,3)   <= '1';
				LED(4,2)   <= '1';
				LED(5,3)   <= '1';
				LED(6,1)   <= '1';
				LED(6,3)   <= '1';
				LED(7,2)   <= '1';
			when "0100" =>		-- 4
				LED(1,3)   <= '1';
				LED(2,2)   <= '1';
				LED(2,3)   <= '1';
				LED(3,2)   <= '1';
				LED(3,3)   <= '1';
				LED(4,1)   <= '1';
				LED(4,3)   <= '1';
				LED(5,1)   <= '1';
				LED(5,3)   <= '1';
				LED(6,3)   <= '1';
				LED(7,3)   <= '1';
			when "0101" => 		-- 5
				LED(1,1)   <= '1';
				LED(1,2)   <= '1';
				LED(1,3)   <= '1';
				LED(2,1)   <= '1';
				LED(3,1)   <= '1';
				LED(4,1)   <= '1';
				LED(4,2)   <= '1';
				LED(5,3)   <= '1';
				LED(6,1)   <= '1';
				LED(6,3)   <= '1';
				LED(7,2)   <= '1';
			when "0110" =>		-- 6
				LED(1,2)   <= '1';
				LED(1,3)   <= '1';
				LED(2,1)   <= '1';
				LED(3,1)   <= '1';
				LED(4,1)   <= '1';
				LED(4,2)   <= '1';
				LED(5,1)   <= '1';
				LED(5,3)   <= '1';
				LED(6,1)   <= '1';
				LED(6,3)   <= '1';
				LED(7,2)   <= '1';
			when "0111" => 		-- 7
				LED(1,1)   <= '1';
				LED(1,2)   <= '1';
				LED(1,3)   <= '1';
				LED(2,3)   <= '1';
				LED(3,3)   <= '1';
				LED(4,2)   <= '1';
				LED(5,2)   <= '1';
				LED(6,2)   <= '1';
				LED(7,2)   <= '1';
			when "1000" => 		-- 8
				LED(1,2)   <= '1';
				LED(2,1)   <= '1';
				LED(2,3)   <= '1';
				LED(3,1)   <= '1';
				LED(3,3)   <= '1';
				LED(4,2)   <= '1';
				LED(5,1)   <= '1';
				LED(5,3)   <= '1';
				LED(6,1)   <= '1';
				LED(6,3)   <= '1';
				LED(7,2)   <= '1';
			when "1001" => 		-- 9
				LED(1,2)   <= '1';
				LED(2,1)   <= '1';
				LED(2,3)   <= '1';
				LED(3,1)   <= '1';
				LED(3,3)   <= '1';
				LED(4,2)   <= '1';
				LED(5,3)   <= '1';
				LED(6,1)   <= '1';
				LED(6,3)   <= '1';
				LED(7,2)   <= '1';
			when others => 		-- LEDs off
				LED <= (others => (others => '0'));
		end case;
	
	end process OL;
	
end architecture rtl;
