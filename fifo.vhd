-------------------------------------------------------------------------------
-- Title      	: 	fifo
-- Project    	: 	Dictaphone
-------------------------------------------------------------------------------
-- File       	: 	fifo.vhd
-- Author     	: 	Peter Wuethrich
-- Company    	: 	BFH
-- Created    	: 	2019-05-20
-- Last update	: 	2019
-- Platform   	: 	Xilinx ISE 14.7
-- Standard   	: 	VHDL'93/02, Math Packages
-- Sources			:		http://www.deathbylogic.com/2013/07/vhdl-standard-fifo/
--
-------------------------------------------------------------------------------
-- Description	: 	Standard FIFO-Buffer
-- 					Additional Output Flags for memory use level

-------------------------------------------------------------------------------
-- Revisions  	:
-- Date        	Version		Author	Description
-- 2019-05-20		1.0				Peter		Created
-------------------------------------------------------------------------------
-- Inputs		:
-- clk					Audio sampling rate
-- reset				Resets the internal pointers and sets data to zero
-- data_in			Input Data
-- wr						write input: if wr is high, data_in is written on positive edge
--							of clk
-- rs						read input: if rd is high, data appears on data_out
--							on positive edge of clk
--
-- Outputs	:
-- data_out			Output Data
-- full					is high if fifo-buffer is full
-- empty				is high if fifo-buffer is empty
-- almost_full	is high if fifo-buffer is more than 75% full
-- almost_empty	is high if fifo-buffer is less than 25% full
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity FIFO is

generic(	ADDR_WIDTH					: positive	:= 10;
					DATA_WIDTH					: positive	:= 16;
					ALMOST_FULL_RATIO		:	real			:= 0.75;
					ALMOST_EMPTY_RATIO	:	real			:= 0.25);

	port( clk, reset, wr, rd				:	in std_logic;
				data_in										:	in std_logic_vector(DATA_WIDTH-1 downto 0);
				data_out									:	out std_logic_vector(DATA_WIDTH-1 downto 0);
				full, empty								:	out std_logic;
				almost_full, almost_empty	:	out std_logic);
end entity FIFO;




architecture rtl of FIFO is
	type	memory_type is array(0 to 2**ADDR_WIDTH-1)	--creating datatype for the memory
		of	std_logic_vector(DATA_WIDTH-1 downto 0);
begin -- architecture rtl
	process(clk)

		constant 	fifo_depth 				:	positive := 2**ADDR_WIDTH;
		constant	almost_full_num		:	positive	:= 768;
		constant	almost_empty_num	:	positive	:= 256;

		variable	mem			:	memory_type;	--create an instance of the memory
	  variable	head		:	natural range 0 to 2**ADDR_WIDTH-1;	--write pointer (head of the buffer, is ahead)
		variable	tail		:	natural range 0 to 2**ADDR_WIDTH-1;	--read pointer (tail of the buffer)
		variable	looped	:	boolean;		--looped means head is behind tail (head looped to the beginning of the memory range --> tail is infront of head)

		begin
			if rising_edge(clk) then
				--set to inital conditions
				if reset = '1' then
					head := 0;
					tail := 0;

					looped := false;

					almost_full <= '0';
					almost_empty <= '1';
					full <= '0';
					empty <= '1';

				else
					--read data out of fifo buffer
					if rd = '1' then
						if looped = true or head /= tail then
							data_out <= mem(tail);
							--Update read pointer
							if tail = fifo_depth - 1 then
								tail := 0;
								looped := false;
							else
								tail := tail + 1;
							end if;
						end if;
					end if;

					--write data into fifo buffer
					if wr = '1' then
						if looped = false or head /= tail then
							mem(head) := data_in;
							--update write pointer
							if head = fifo_depth - 1 then
								head := 0;
								looped := true;
							else
								head := head + 1;
							end if;
						end if;
					end if;

				end if;

				-- Update Flags empty and full
				if head = tail then
					if looped then
						full <= '1';
					else
						empty <= '1';
					end if;
				else
					empty <= '0';
					full <= '0';
				end if;

				-- Update Flags almost_empty and almost_full
				if looped then
					if (head - tail) >= (almost_full_num) then
						almost_full <= '1';
					else
						almost_full <= '0';
					end if;

					if (head - tail) <= (almost_empty_num) then
						almost_empty <= '1';
					else
						almost_empty <= '0';
					end if;

				else -- if head looped calcuation of used memory is a bit more complex
					if (head + fifo_depth - tail) >= (almost_full_num) then
						almost_full <= '1';
					else
						almost_full <= '0';
					end if;
					if (head + fifo_depth - tail) <= (almost_empty_num) then
						almost_empty <= '1';
					else
						almost_empty <= '0';
					end if;

				end if;
			end if;
		end process;
end rtl;
