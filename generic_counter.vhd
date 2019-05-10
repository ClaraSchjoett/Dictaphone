LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY generic_counter IS
	PORT ( 
		clk,rst 					: IN STD_LOGIC;
		count_stop					: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		count_out 					: OUT STD_LOGIC			-- strobe when set value is reached
		);
END generic_counter;

ARCHITECTURE functional_level OF generic_counter IS

	SIGNAL s_count_out				: STD_LOGIC;
	SIGNAL s_counter_value			: UNSIGNED (15 DOWNTO 0);
	SIGNAL s_count_stop				: UNSIGNED (15 DOWNTO 0);
	
BEGIN
	
	-- Input Signal match
	s_count_stop <= unsigned(count_stop);					-- typecast std_logic_vector --> unsigned
	
	-- Output signal match
	count_out <= s_count_out;								-- typecast not neccesary, both signals are std_logic 
	
	counter : PROCESS (clk, rst)
	BEGIN
		IF (RISING_EDGE(clk)) THEN
			IF (rst = '0') THEN 							-- synchronous reset
				s_count_out <= '0';							-- reset counter
				s_counter_value <= (others => '0');			-- reset counter register
			ELSE
				IF (s_counter_value >= s_count_stop) THEN	-- when set value is reached
					s_counter_value <= (others => '0');		-- reset counter register
					s_count_out <= '1';						-- generate strobe
				ELSE										-- when set value is not yet reached
					s_count_out <= '0';
					s_counter_value <= s_counter_value +1;	-- increment counter register
				END IF;
			END IF;
		END IF;
	END PROCESS counter;	
END functional_level;