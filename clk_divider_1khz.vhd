library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;



entity clk_divider_1khz is
  Port    (
  --General usage
    CLK      : in std_logic;
    RST      : in std_logic;

	 clk_en	 : out STD_LOGIC;
	 clk_1kHz_en : out STD_LOGIC
            );

end clk_divider_1khz ;

architecture rtl of clk_divider_1khz is

--------------------------------------------------------------------------------
-- Title            : Local signal assignments
--
-- Description      : The following signals will be used to drive the
--                    processes of this VHDL file.
--
--   clk_counter_1   : This counter will be used to create a divided clock signal.
--
--------------------------------------------------------------------------------

signal clk_counter_1   : std_logic_vector(16 downto 0) := (others => '0');
signal s_clk_en, s_clk_en_last : std_logic;

begin

--------------------------------------------------------------------------------
-- Title          :     clock divider process
--
-- Description    : This is the process that will divide the 50 MHz clock
--                  down to a clock speed of 192 kHz to drive the ADC7476 chip.
--------------------------------------------------------------------------------
        clock_divide : process(rst,clk)
        begin
            if rst = '1' then
                clk_counter_1 <= (others => '0');
            elsif (clk = '1' and clk'event) then
                clk_counter_1 <= clk_counter_1 + '1';
				s_clk_en_last <= s_clk_en;

            end if;
        end process;

        s_clk_en <= clk_counter_1(7) and not(clk_counter_1(6)) and not(clk_counter_1(5)) and not(clk_counter_1(4))
		   and not(clk_counter_1(3)) and not(clk_counter_1(2)) and not(clk_counter_1(1)) and not(clk_counter_1(0));

		clk_1kHz_en <= '1' WHEN clk_counter_1 = 0 ELSE '0';
		clk_en <= '1' when (s_clk_en_last = '0') and (s_clk_en = '1') else '0';



end rtl;
