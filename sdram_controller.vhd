-------------------------------------------------------------------------------
-- Title      	: 	sdram_controller
-- Project    	: 	Dictaphone
-------------------------------------------------------------------------------
-- File       	: 	sdram_controller.vhd
-- Author     	: 	Torsten Maehne
-- Company    	: 	BFH
-- Platform   	: 	Xilinx ISE 14.7
-- Standard   	: 	VHDL'93/02, Math Packages
-------------------------------------------------------------------------------
-- Description	: 	SDRAM controller
-------------------------------------------------------------------------------
-- Revisions  	:
-- Date        		Version  	Author  	Description	
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity sdram_controller is

  generic (
    -- memory profile
    NBITSDATA         : positive     := 16;  -- data width
    NBITSBANK         : positive     := 2;   -- Number of bits for bank address
    NBITSROW          : positive     := 13;  -- Number of bits for row address
    NBITSCOL          : positive     := 9;   -- Number of bits for columns address
    -- timing
    FREQCLOCK         : real         := 50.0e6;     -- clock frequency / MHz
    CASLATENCYCYCLES  : positive     := 3;          -- CAS latency cycles
    INITREFRESHCYCLES : positive     := 2;          -- initialization refresh cycles
    REFRESHPERIOD     : delay_length := 7.8125 us;  -- max. refresh command period
    POWERUP2INIT      : delay_length := 100.0 us;   -- delay after power-up, before initialization
    TRFC              : delay_length := 80.0 ns;    -- duration of refresh command
    TRP               : delay_length := 22.5 ns;    -- duration of precharge command
    TRCD              : delay_length := 22.5 ns;    -- ACTIVE to READ or WRITE delay
    TAC               : delay_length := 8.0 ns;     -- access time
    TWR               : delay_length := 22.5 ns;    -- write recovery time (no auto precharge)
    MRDCYCLES         : positive     := 3;          -- Number of clock cycles between
                                                    -- load mode register command and
                                                    -- active or refresh command
    -- debug interface
    DEBUG             : boolean      := true);  -- enable simulation debug messages

  port (
    clock          : in  std_logic;     -- clock
    reset_n        : in  std_logic;     -- (low-active) reset
    -- command interface
    cmd_ready      : out std_logic;     -- new command can be processed
    cmd_strobe     : in  std_logic;     -- issue a new read/write command
    cmd_wr         : in  std_logic;     -- write access
    cmd_address    : in  unsigned(NBITSBANK+NBITSROW+NBITSCOL-1 downto 0);  -- word address for read/write
    cmd_data_in    : in  std_logic_vector(NBITSDATA-1 downto 0);    -- data for write command
    data_out       : out std_logic_vector(NBITSDATA-1 downto 0);    -- read word from SDRAM
    data_out_ready : out std_logic;     -- new data from SDRAM is ready
    -- SDRAM interface
    sdram_clk      : out std_logic;     -- SDRAM clock (half speed of clock)
    sdram_cke      : out std_logic;     -- clock enable
    sdram_cs_n     : out std_logic;     -- (low-active) chip select
    sdram_ras_n    : out std_logic;     -- (low-active) row access strobe
    sdram_cas_n    : out std_logic;     -- (low-active) column access strobe
    sdram_we_n     : out std_logic;     -- (low-active) write enable
    sdram_dqm_n    : out std_logic_vector(NBITSDATA/8-1 downto 0);  -- data mask
    sdram_addr     : out std_logic_vector(NBITSROW-1 downto 0);     -- row/column address
    sdram_ba       : out std_logic_vector(NBITSBANK-1 downto 0);    -- bank address
    sdram_data     : inout std_logic_vector(NBITSDATA-1 downto 0)); -- data input/output

begin

  assert NBITSDATA / 8 = positive(ceil(real(NBITSDATA) / 8.0))
    report "NBITSDATA is not a multiple of 8!"
    severity failure;

  assert (CASLATENCYCYCLES = 2) or (CASLATENCYCYCLES = 3)
    report "CAS latency needs to be 2 or 3!"
    severity failure;

  assert NBITSROW > NBITSCOL
    report "Implementation of SDRAM controller requires NBITSROW > NBITSCOL!"
    severity failure;

end entity sdram_controller;