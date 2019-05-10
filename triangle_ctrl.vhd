LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY triangle_ctrl IS
PORT (
	clk, rst		 		: IN STD_LOGIC;							-- internal clock, reset button
	speed_n					: IN STD_LOGIC_VECTOR (1 DOWNTO 0);		-- dipswitch
	data_ack				: IN STD_LOGIC;							-- outputs new data when high, holds old data when low
	data					: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)		-- parallel data out, amplitude of signal
	);
END triangle_ctrl;


ARCHITECTURE functional_level OF triangle_ctrl IS

	-- generic signals
	SIGNAL s_count_stop		: STD_LOGIC_VECTOR (15 DOWNTO 0);

	-- digital signals
	SIGNAL s_count_out		: STD_LOGIC;
	SIGNAL s_speed			: STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL s_data			: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL s_data_next		: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL s_data_triangle	: STD_LOGIC_VECTOR (7 DOWNTO 0);

	-- component declarations
	COMPONENT generic_counter IS	-- frequency generator
	PORT (
		clk,rst 			: IN STD_LOGIC;
		count_stop			: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		count_out 			: OUT STD_LOGIC
		);
	END COMPONENT generic_counter;

	COMPONENT Ramp_Ctrl IS
	PORT (
		clk,count,rst 		: IN STD_LOGIC;
		data				: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		start 				: OUT STD_LOGIC
		);
	END COMPONENT Ramp_Ctrl;

BEGIN

	-- Input Signal wiring
	s_speed <= not speed_n;	-- low-active dipswitch

	-- Output Signal wiring
	data <= s_data;

	-- Triangle frequency selection logic
	speed_select : PROCESS ( clk, rst ) IS
	BEGIN
		IF (RISING_EDGE(clk)) THEN
			IF (rst = '0') THEN
				s_count_stop <= (OTHERS => '0');

			ELSE
				CASE (s_speed) IS

					WHEN "00" =>
						--s_count_stop <= std_logic_vector(to_unsigned(97,16));			-- Entspricht 1000Hz
						s_count_stop <= "0000000001100001";			-- Entspricht 1000Hz

					WHEN "01" =>
						--s_count_stop <=  std_logic_vector(to_unsigned(196,16));			-- Entspricht 500Hz
						s_count_stop <= "0000000011000100";			-- Entspricht 500Hz

					WHEN "10" =>
						--s_count_stop <=  std_logic_vector(to_unsigned(392,16));			-- Entspricht 250Hz
						s_count_stop <= "0000000110001000";			-- Entspricht 250Hz

					WHEN "11" =>
						--s_count_stop <=  std_logic_vector(to_unsigned(980,16));		-- Entspricht 100Hz
						s_count_stop <= "0000001111010100";			-- Entspricht 100Hz

					WHEN others =>
						s_count_stop <= "0000000001100010";			-- Entspricht 1000Hz

				END CASE;

			END IF;
		END IF;
	END PROCESS ;

	dff_data : PROCESS (clk, rst) IS
	BEGIN
		IF (RISING_EDGE(clk)) THEN
			IF (rst = '0') THEN
				s_data <= (OTHERS => '0');
			ELSE
				s_data <= s_data_next;
			END IF;
		END IF;
	END PROCESS;

	-- mux
	s_data_next <= s_data_triangle WHEN (data_ack = '1') ELSE s_data;


	-- Instantiation of components
	inst1_generic_counter : generic_counter
	PORT MAP(
		clk 		=> clk,
		rst 		=> rst,
		count_stop 	=> s_count_stop,
		count_out 	=> s_count_out
	);

	inst1_Ramp_Ctrl : Ramp_Ctrl
	PORT MAP(
		clk 		=> clk,
		count 		=> s_count_out,
		rst 		=> rst,
		data 		=> s_data_triangle,
		start 		=> open
	);

END functional_level;
