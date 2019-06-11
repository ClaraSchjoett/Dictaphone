LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Ramp_Ctrl IS
	PORT (
		clk,count,rst 			: IN STD_LOGIC;
		data					: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		start 					: OUT STD_LOGIC
		);
END Ramp_Ctrl;

ARCHITECTURE functional_level OF Ramp_Ctrl IS

	TYPE StateType IS (IDLE, COUNT_START);
	SIGNAL s_cur_state, s_next_state : StateType;

	SIGNAL s_data				: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL s_data_next			: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL s_start				: STD_LOGIC;
	SIGNAL s_start_next			: STD_LOGIC;
	SIGNAL s_count				: STD_LOGIC;
	SIGNAL s_count_delayed		: STD_LOGIC;
	SIGNAL s_count_down			: STD_LOGIC;
	SIGNAL s_count_down_next	: STD_LOGIC;
	SIGNAL s_countvalue			: UNSIGNED (7 DOWNTO 0);
	SIGNAL s_countvalue_next	: UNSIGNED (7 DOWNTO 0);


BEGIN

	-- Input Signals match
	s_count <= count;

	-- Output signal match
	start <= s_start;
	data <= s_data;


	dff : PROCESS (clk, rst)
	BEGIN
		IF (RISING_EDGE(clk)) THEN
			IF (rst = '0') THEN
				s_cur_state <= IDLE;
			ELSE
				s_cur_state <= s_next_state;
			END IF;
		END IF;
	END PROCESS dff;

	dff_1 : PROCESS (clk)
	BEGIN
		IF (RISING_EDGE(clk)) THEN
							-- storing s_start
			s_count_delayed <= s_count;

		END IF;
	END PROCESS dff_1;

	dff_2 : PROCESS (clk,rst)
	BEGIN
		IF (RISING_EDGE(clk)) THEN
			IF (rst = '0') THEN
				s_data <= "00000000";
				s_start <= '0';
				s_count_down <= '0';
				s_countvalue <= "00000000";
			ELSE
				s_data <= s_data_next;
				s_start <= s_start_next;
				s_count_down <= s_count_down_next;
				s_countvalue <= s_countvalue_next;
			END IF;
		END IF;
	END PROCESS dff_2;



	-- IMPORTANT CHANGE BY CS: s_countvalue, s_data and s_start were added to sensitivity list
	transition : PROCESS (s_count, s_count_delayed, s_cur_state, rst, s_countvalue, s_count_down, s_data, s_start)	-- this FSM generates the countvalue for the DAC
	BEGIN
		CASE (s_cur_state) IS

			WHEN IDLE =>

				IF ((s_count = '1') or (s_count_delayed = '1')) THEN
					s_start_next <= '0';

					IF (s_countvalue = 0) THEN
						s_countvalue_next <= to_unsigned(1,8);
						s_count_down_next<= '0';
					ELSIF (s_countvalue = 255) THEN
						s_countvalue_next <= to_unsigned(254,8);
						s_count_down_next <= '1';
					ELSIF (s_count_down = '1') THEN
						s_countvalue_next <= s_countvalue -1;
						s_count_down_next <= s_count_down;
					ELSE
						s_countvalue_next <= s_countvalue +1;
						s_count_down_next <= s_count_down;
					END IF;

					s_next_state <= COUNT_START;
					s_data_next <= s_data;


				ELSE
					s_next_state <= IDLE;
					s_start_next <= '0';
					s_countvalue_next <= s_countvalue;
					s_count_down_next <= s_count_down;
					s_data_next <= s_data;
				END IF;

			WHEN COUNT_START =>

				s_data_next <= std_logic_vector(s_countvalue);
				s_start_next <= '1';
				s_next_state <= IDLE;
				s_countvalue_next <= s_countvalue;
				s_count_down_next <= s_count_down;

			WHEN OTHERS =>
				s_next_state <= IDLE;
				s_countvalue_next <= s_countvalue;
				s_count_down_next <= s_count_down;
				s_start_next <= s_start;
				s_data_next <= s_data;

		END CASE ;

	END PROCESS transition;

END functional_level;
