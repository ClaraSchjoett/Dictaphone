-------------------------------------------------------------------------------
-- Title      : Simple generic Single Data Rate (SDR) SDRAM controller
-- Project    : BTE5024
-------------------------------------------------------------------------------
-- File       : sdram_controller.vhdl
-- Author     : Torsten Maehne  <torsten.maehne@bfh.ch>
-- Company    : BFH-EIT
-- Created    : 2019-04-08
-- Last update: 2019-05-28
-- Platform   : Intel Quartus Prime 18.1
-- Standard   : VHDL'93/02, Math Packages
-------------------------------------------------------------------------------
-- Description:
--
-- This simple, but generic, SDRAM controller is optimised for linear
-- read/write access patterns. A row is kept open until a prefetch
-- operation becomes necessary to perform an automatic refresh
-- operation. Refresh cycles are performed automatically by the SDRAM
-- controller. It also handles the details of activating a row on a
-- read or write operation. Therefore, the number of clock cycles to
-- finish an issued read or write may vary. The end of such a user
-- operation is signaled through the output `cmd_ready`.
--
-- Only one row in one bank is active at a time. The prefetch command
-- is always issued with `sdram_addr(10) = '1'` to close the rows of
-- all banks. Burst reads and writes are not supported. The SDRAM
-- clock is generated from the system clock, by dividing the latter by
-- two using a D-Flip-Flop. New commands are issued by the SDRAM
-- controller always on the falling edge of the SDRAM clock so that
-- they are stable when the SDRAM samples them on the rising edge of
-- clock. This approach is simpler and tool-independent compared to
-- the instantiation of a DCM or PLL to synthesise the SDRAM clock
-- with a constant phase relation to the system clock at the expanse
-- of running at half of the possible speed.
--
-- For simplicity, the SDRAM controller keeps always the `sdram_cke`
-- output high and the `sdram_dqm_n` signals at low. I.e., read and
-- writes are always performed on the full word width. Accordingly,
-- the cmd_address is a word address. When the SDRAM controller is
-- idle, it will issue SDRAM NOP commands.
--
-- This SDRAM controller implementation has been tested with the
-- accompanying test bench in simulation and on the GECKO4-EDUCATION
-- FPGA board using the 50 MHz system clock, i.e., the SDRAM of type
-- ISSI IS4242VM16160K (32 MB capacity) is operated with 25 MHZ. The
-- implementation is based on the ISSI IS4242VM16160K data sheet [1],
-- Signal Tap Logic Analyzer measurements of the SDRAM control signals
-- operated by the Avalon SDRAM controller IP core [2] provided with
-- Intel Quartus Prime 18.1 Lite edition in its Platform Designer to
-- design SoPCs as well as loosely on the different SDRAM controller
-- versions developed by Mike Field <hamster@snap.net.nz> [3, 4].
--
-- References:
--
-- [1] ISSI: "IS42/45SM/RM/VM16160K 4M x 16Bits x 4Banks Mobile
--     Synchronous DRAM", data sheet, Rev. B1, Integrated Silicon
--     Solution, Inc., March 2015.
--     <http://www.issi.com/WW/pdf/42-45SM-RM-VM16160K.pdf>,
--     last visited 2019-05-27.
--
-- [2] Intel: "SDRAM Controller Core with Avalon interface" in the
--     "Embedded Peripherals IP User Guide". UG-01085, 2019-04-01.
--     <https://www.intel.com/content/www/us/en/programmable/documentation/sfo1400787952932.html#iga1401314928585>,
--     last visited 2019-05-27.
--
-- [3] Mike Field: "SDRAM Memory Controller", 2013-10-15.
--     <http://hamsterworks.co.nz/mediawiki/index.php/SDRAM_Memory_Controller>,
--     last visited 2019-05-27.
--
-- [4] Mike Field: "Simple SDRAM Controller", 2014-09-13.
--     <http://hamsterworks.co.nz/mediawiki/index.php/Simple_SDRAM_Controller>,
--     last visited 2019-05-27.
--
-------------------------------------------------------------------------------
-- Copyright (c) 2019 BFH-EIT
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2019-05-27  1.0      mht1	Created
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
    DEBUG             : boolean      := true);      -- enable simulation debug messages

  port (
    clock          : in    std_logic;   -- clock
    reset_n        : in    std_logic;   -- (low-active) reset
    -- command interface
    cmd_ready      : out   std_logic;   -- new command can be processed
    cmd_strobe     : in    std_logic;   -- issue a new read/write command
    cmd_wr         : in    std_logic;   -- write access
    cmd_address    : in    unsigned(NBITSBANK+NBITSROW+NBITSCOL-1 downto 0);  -- word address for read/write
    cmd_data_in    : in    std_logic_vector(NBITSDATA-1 downto 0);  -- data for write command
    data_out       : out   std_logic_vector(NBITSDATA-1 downto 0);  -- read word from SDRAM
    data_out_ready : out   std_logic;   -- new data from SDRAM is ready
    -- SDRAM interface
    sdram_clk      : out   std_logic;   -- SDRAM clock (half speed of clock)
    sdram_cke      : out   std_logic;   -- clock enable
    sdram_cs_n     : out   std_logic;   -- (low-active) chip select
    sdram_ras_n    : out   std_logic;   -- (low-active) row access strobe
    sdram_cas_n    : out   std_logic;   -- (low-active) column access strobe
    sdram_we_n     : out   std_logic;   -- (low-active) write enable
    sdram_dqm_n    : out   std_logic_vector(NBITSDATA/8-1 downto 0);  -- data mask
    sdram_addr     : out   std_logic_vector(NBITSROW-1 downto 0);     -- row/column address
    sdram_ba       : out   std_logic_vector(NBITSBANK-1 downto 0);    -- bank address
    sdram_data     : inout std_logic_vector(NBITSDATA-1 downto 0));   -- data input/output

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

  assert NBITSCOL <= 10
    report "Column address has to be at maximum 10 bits wide!"
    severity failure;

end entity sdram_controller;

architecture rtl of sdram_controller is

  -- clock period
  constant CLOCK_PERIOD     : delay_length := (1.0 / FREQCLOCK) * 1 sec;
  constant SDRAM_CLK_PERIOD : delay_length := 2.0 * CLOCK_PERIOD;

  -- purpose: Convert delay length to number of wait cycles based on the clock period
  function delay_to_cycles (
    constant delay        : delay_length;
    constant period : delay_length)
    return natural is
  begin  -- function delay_to_cycles
    return natural(ceil(real(delay / 1 ps) / real(period / 1 ps)));
  end function delay_to_cycles;

  -- power up to initialisation wait cycles
  constant N_POWER_UP_TO_INIT_WAIT_CYCLES : positive := delay_to_cycles(POWERUP2INIT, SDRAM_CLK_PERIOD);
  -- refresh command wait cycles
  constant N_RFC_WAIT_CYCLES : natural := delay_to_cycles(TRFC, SDRAM_CLK_PERIOD);
  -- number of clock cycles between refresh commands
  constant N_REFRESH_PERIOD_CLOCK_CYCLES  : natural := delay_to_cycles(REFRESHPERIOD, SDRAM_CLK_PERIOD) - N_RFC_WAIT_CYCLES;
  -- precharge command wait cycles
  constant N_RP_WAIT_CYCLES  : natural := delay_to_cycles(TRP, SDRAM_CLK_PERIOD);
  -- ACTIVE to READ/WRITE wait cycles
  constant N_RCD_WAIT_CYCLES : natural := delay_to_cycles(TRCD, SDRAM_CLK_PERIOD);
  -- access time wait cycles
  constant N_AC_WAIT_CYCLES  : natural := delay_to_cycles(TAC, SDRAM_CLK_PERIOD);
  -- write recovery time wait cycles (no auto precharge)
  constant N_WR_WAIT_CYCLES  : natural := delay_to_cycles(TWR, SDRAM_CLK_PERIOD);

  -- SDRAM commands (mapped to cs_n & ras_n & cas_n & we_n)
  constant CMD_INHIBIT    : std_logic_vector(3 downto 0) := "1000";
  constant CMD_NOP        : std_logic_vector(3 downto 0) := "0111";
  constant CMD_ACTIVATE   : std_logic_vector(3 downto 0) := "0011";
  constant CMD_READ       : std_logic_vector(3 downto 0) := "0101";
  constant CMD_WRITE      : std_logic_vector(3 downto 0) := "0100";
  constant CMD_PRECHARGE  : std_logic_vector(3 downto 0) := "0010";
  constant CMD_REFRESH    : std_logic_vector(3 downto 0) := "0001";
  constant CMD_SET_MODE   : std_logic_vector(3 downto 0) := "0000";
  constant CMD_BURST_STOP : std_logic_vector(3 downto 0) := "0110";

  -- SDRAM mode register initialisation value
  constant SDRAM_MODE_REG_VALUE : std_logic_vector(NBITSBANK+NBITSROW-1 downto 0) :=
    std_logic_vector(resize(unsigned(
      "00" &                            -- mode register
      "000" &                           -- reserved
      "0" &  -- write burst mode: burst read and burst write
      "00" &                            -- reserved
      std_logic_vector(to_unsigned(CASLATENCYCYCLES, 3)) &  -- CAS latency
      "0" &                             -- burst type: sequential
      "000"),                           -- burst length: 1
                            NBITSBANK+NBITSROW));

  -- SDRAM extended mode register initialisation value
  constant SDRAM_EXTENDED_MODE_REG_VALUE : std_logic_vector(NBITSBANK+NBITSROW-1 downto 0) :=
    std_logic_vector(resize(unsigned(
      std_logic_vector'("10") &         -- extended mode register
      "00000" &
      "000" &                           -- driver strength: full strength
      "00" &
      "000"),                           -- self refresh coverage: all banks
                            NBITSBANK+NBITSROW));

  -- size of counter to be used to wait at start up and between refreshes
  constant NBITS_STARTUP_REFRESH_COUNTER : positive :=
    positive(ceil(log2(real(N_POWER_UP_TO_INIT_WAIT_CYCLES + 1))));

  -- size of command counter
  constant NBITS_CMD_COUNTER : positive := positive(ceil(log2(real(N_RFC_WAIT_CYCLES + 1))));

  -- Aliases to split word address into bank, row, and column
  alias cmd_bank : unsigned(NBITSBANK-1 downto 0) is
    cmd_address(NBITSBANK+NBITSROW+NBITSCOL-1 downto NBITSROW+NBITSCOL);
  alias cmd_row : unsigned(NBITSROW-1 downto 0) is
    cmd_address(NBITSROW+NBITSCOL-1 downto NBITSCOL);
  alias cmd_col : unsigned(NBITSCOL-1 downto 0) is
    cmd_address(NBITSCOL-1 downto 0);

  -- SDRAM controller state register
  type states is (S_STARTUP, S_INIT_PRECHARGE, S_INIT_REFRESH_CYCLES,
                  S_INIT_MODE_REG, S_INIT_EXTENDED_MODE_REG,
                  S_IDLE, S_ROW_ACTIVE, S_READ, S_WRITE,
                  S_PRECHARGE, S_REFRESH);
  signal state_reg, state_next : states;

  -- SDRAM startup and refresh counter register
  signal startup_refresh_counter_reg, startup_refresh_counter_next
    : unsigned(NBITS_STARTUP_REFRESH_COUNTER-1 downto 0);

  -- SDRAM command register: current command for SDRAM
  signal cmd_reg, cmd_next : std_logic_vector(3 downto 0);

  -- SDRAM command counter register: Holds the number of clock cycles to wait
  -- for the current command to finish.
  signal cmd_counter_reg, cmd_counter_next : unsigned(NBITS_CMD_COUNTER-1 downto 0);

  -- SDRAM command ready register: '1' if SDRAM controller is ready to accept a
  -- new read/write command and '0' if initialising or processing a transaction.
  signal cmd_ready_reg, cmd_ready_next : std_logic;

  -- Write command register: '1' if write to SDRAM is pending and '0' otherwise.
  signal cmd_wr_reg, cmd_wr_next : std_logic;

  -- Word address register for pending command
  signal cmd_address_reg, cmd_address_next : unsigned(NBITSBANK+NBITSROW+NBITSCOL-1 downto 0);

  -- Data word register to be written to SDRAM
  signal cmd_data_reg, cmd_data_next : std_logic_vector(NBITSDATA-1 downto 0);

  -- Aliases to split word address into bank, row, and column
  alias cmd_bank_reg : unsigned(NBITSBANK-1 downto 0) is
    cmd_address_reg(NBITSBANK+NBITSROW+NBITSCOL-1 downto NBITSROW+NBITSCOL);
  alias cmd_bank_next : unsigned(NBITSBANK-1 downto 0) is
    cmd_address_next(NBITSBANK+NBITSROW+NBITSCOL-1 downto NBITSROW+NBITSCOL);
  alias cmd_row_reg : unsigned(NBITSROW-1 downto 0) is
    cmd_address_reg(NBITSROW+NBITSCOL-1 downto NBITSCOL);
  alias cmd_row_next : unsigned(NBITSROW-1 downto 0) is
    cmd_address_next(NBITSROW+NBITSCOL-1 downto NBITSCOL);
  alias cmd_col_reg : unsigned(NBITSCOL-1 downto 0) is
    cmd_address_reg(NBITSCOL-1 downto 0);
  alias cmd_col_next : unsigned(NBITSCOL-1 downto 0) is
    cmd_address_next(NBITSCOL-1 downto 0);

  -- SDRAM clock register to divide system clock by 2
  signal sdram_clk_reg, sdram_clk_next : std_logic;

  -- Register for the SDRAM bank output
  signal sdram_ba_reg, sdram_ba_next : std_logic_vector(NBITSBANK-1 downto 0);

  -- Register for the SDRAM address output
  signal sdram_addr_reg, sdram_addr_next : std_logic_vector(NBITSROW-1 downto 0);

  -- SDRAM data input register to sample continuously the SDRAM data inout port
  signal sdram_data_in_reg, sdram_data_in_next : std_logic_vector(NBITSDATA-1 downto 0);

  -- data_out register holding the value from the last SDRAM read transaction
  signal data_out_reg, data_out_next : std_logic_vector(NBITSDATA-1 downto 0);

  -- data_out ready register: '1' if data_out outputs value from the last
  -- SDRAM read transaction
  signal data_out_ready_reg, data_out_ready_next : std_logic;

begin  -- architecture rtl

  -- pragma synthesis_off
  DBG : process is
  begin
    if DEBUG then
      report sdram_controller'instance_name & LF &
             "  generics:" & LF &
             "    NBITSDATA := " & positive'image(NBITSDATA) & LF &
             "    NBITSBANK := " & positive'image(NBITSBANK) & LF &
             "    NBITSROW := " & positive'image(NBITSROW) & LF &
             "    NBITSCOL := " & positive'image(NBITSCOL) & LF &
             "    FREQCLOCK := " & real'image(FREQCLOCK) & " Hz" & LF &
             "    CASLATENCYCYCLES := " & positive'image(CASLATENCYCYCLES) & LF &
             "    INITREFRESHCYCLES := " & positive'image(INITREFRESHCYCLES) & LF &
             "    REFRESHPERIOD := " & delay_length'image(REFRESHPERIOD) & LF &
             "    POWERUP2INIT := " & delay_length'image(POWERUP2INIT) & LF &
             "    TRFC := " & delay_length'image(TRFC) & LF &
             "    TRP := " & delay_length'image(TRP) & LF &
             "    TRCD := " & delay_length'image(TRCD) & LF &
             "    TAC := " & delay_length'image(TAC) & LF &
             "    TWR := " & delay_length'image(TWR) & LF &
             "    MRDCYCLES := " & positive'image(MRDCYCLES) & LF &
             "  internal constants:" & LF &
             "    CLOCK_PERIOD := " & delay_length'image(CLOCK_PERIOD) & LF &
             "    SDRAM_CLK_PERIOD := " & delay_length'image(SDRAM_CLK_PERIOD) & LF &
             "    N_REFRESH_PERIOD_CLOCK_CYCLES := " & natural'image(N_REFRESH_PERIOD_CLOCK_CYCLES) & LF &
             "    N_POWER_UP_TO_INIT_WAIT_CYCLES := " & natural'image(N_POWER_UP_TO_INIT_WAIT_CYCLES) & LF &
             "    N_RFC_WAIT_CYCLES := " & natural'image(N_RFC_WAIT_CYCLES) & LF &
             "    N_RP_WAIT_CYCLES := " & natural'image(N_RP_WAIT_CYCLES) & LF &
             "    N_RCD_WAIT_CYCLES := " & natural'image(N_RCD_WAIT_CYCLES) & LF &
             "    N_AC_WAIT_CYCLES := " & natural'image(N_AC_WAIT_CYCLES) & LF &
             "    N_WR_WAIT_CYCLES := " & natural'image(N_WR_WAIT_CYCLES) & LF &
             "    NBITS_STARTUP_REFRESH_COUNTER := " & positive'image(NBITS_STARTUP_REFRESH_COUNTER) & LF &
             "    NBITS_CMD_COUNTER := " & positive'image(NBITS_CMD_COUNTER) & LF &
             "    SDRAM_MODE_REG_VALUE := " & natural'image(to_integer(unsigned(SDRAM_MODE_REG_VALUE))) & LF &
             "    SDRAM_EXTENDED_MODE_REG_VALUE := " & natural'image(to_integer(unsigned(SDRAM_EXTENDED_MODE_REG_VALUE)))
        severity note;
    end if;
    wait;
  end process DBG;
  -- pragma synthesis_on

  -- purpose: implement registers
  -- type   : sequential
  -- inputs : clock, reset_n, state_next,
  --          startup_refresh_counter_next, cmd_next,
  --          cmd_counter_next, cmd_ready_next, cmd_wr_next,
  --          cmd_address_next, cmd_data_next, sdram_clk_next,
  --          sdram_ba_next, sdram_addr_next, sdram_data_in_next,
  --          data_out_next, data_out_ready_next
  -- outputs: state_reg, startup_refresh_counter_reg, cmd_reg, cmd_counter_reg,
  --          cmd_ready_reg, cmd_wr_reg, cmd_address_reg, cmd_data_reg,
  --          sdram_clk_reg, sdram_ba_reg, sdram_addr_reg, sdram_data_in_reg,
  --          data_out_reg, data_out_ready_reg
  REG : process (clock, reset_n) is
  begin  -- process REG
    if reset_n = '0' then                   -- asynchronous reset (active low)
      state_reg                   <= states'left;
      startup_refresh_counter_reg <= to_unsigned(N_POWER_UP_TO_INIT_WAIT_CYCLES,
                                                 startup_refresh_counter_reg'length);
      cmd_reg                     <= CMD_NOP;
      cmd_counter_reg             <= to_unsigned(0, cmd_counter_reg'length);
      cmd_ready_reg               <= '0';
      cmd_wr_reg                  <= '0';
      cmd_address_reg             <= (others => '1');
      cmd_data_reg                <= (others => '1');
      sdram_clk_reg               <= '1';
      sdram_ba_reg                <= (others => '0');
      sdram_addr_reg              <= (others => '1');
      sdram_data_in_reg           <= (others => '1');
      data_out_reg                <= (others => '1');
      data_out_ready_reg          <= '0';
    elsif clock'event and clock = '1' then  -- rising clock edge
      state_reg                   <= state_next;
      startup_refresh_counter_reg <= startup_refresh_counter_next;
      cmd_reg                     <= cmd_next;
      cmd_counter_reg             <= cmd_counter_next;
      cmd_ready_reg               <= cmd_ready_next;
      cmd_wr_reg                  <= cmd_wr_next;
      cmd_address_reg             <= cmd_address_next;
      cmd_data_reg                <= cmd_data_next;
      sdram_clk_reg               <= sdram_clk_next;
      sdram_ba_reg                <= sdram_ba_next;
      sdram_addr_reg              <= sdram_addr_next;
      sdram_data_in_reg           <= sdram_data_in_next;
      data_out_reg                <= data_out_next;
      data_out_ready_reg          <= data_out_ready_next;
    end if;
  end process REG;

  SDRAM_CLK_GEN : sdram_clk_next <= not sdram_clk_reg;

  -- purpose: Next-state logic
  -- type   : combinational
  -- inputs : cmd_address, cmd_address_reg, cmd_bank, cmd_bank_reg,
  --          cmd_col_reg, cmd_counter_reg, cmd_data_in, cmd_data_reg,
  --          cmd_ready_reg, cmd_reg, cmd_row, cmd_row_reg, cmd_strobe,
  --          cmd_wr, cmd_wr_reg, data_out_ready_reg, data_out_reg,
  --          sdram_ba_reg, sdram_addr_reg, sdram_clk_reg, sdram_data,
  --          sdram_data_in_reg, startup_refresh_counter_reg, state_reg
  -- outputs: cmd_address_next, cmd_bank_next, cmd_col_next,
  --          cmd_counter_next, cmd_data_next, cmd_ready_next,
  --          cmd_next, cmd_row_next, cmd_wr_next,
  --          data_out_ready_next, data_out_next,
  --          sdram_ba_next, sdram_addr_next,
  --          sdram_clk_next, sdram_data_in_next,
  --          startup_refresh_counter_next, state_next
  NSL : process (cmd_address, cmd_address_reg, cmd_bank, cmd_bank_reg,
                 cmd_col_reg, cmd_counter_reg, cmd_data_in, cmd_data_reg,
                 cmd_ready_reg, cmd_reg, cmd_row, cmd_row_reg, cmd_strobe,
                 cmd_wr, cmd_wr_reg, data_out_ready_reg, data_out_reg,
                 sdram_ba_reg, sdram_addr_reg, sdram_clk_reg, sdram_data,
                 sdram_data_in_reg, startup_refresh_counter_reg, state_reg) is
  begin  -- process NSL
    -- Avoid latches
    state_next                   <= state_reg;
    startup_refresh_counter_next <= startup_refresh_counter_reg;
    cmd_next                     <= cmd_reg;
    cmd_counter_next             <= cmd_counter_reg;
    cmd_ready_next               <= cmd_ready_reg;
    cmd_wr_next                  <= cmd_wr_reg;
    cmd_address_next             <= cmd_address_reg;
    cmd_data_next                <= cmd_data_reg;
    sdram_ba_next                <= sdram_ba_reg;
    sdram_addr_next              <= sdram_addr_reg;
    sdram_data_in_next           <= sdram_data;
    data_out_next                <= data_out_reg;
    data_out_ready_next          <= data_out_ready_reg;

    -- Check if a new read/write command has to be processed.
    if cmd_ready_reg = '1' and cmd_strobe = '1' then
      cmd_ready_next <= '0';
      cmd_wr_next <= cmd_wr;
      cmd_address_next <= cmd_address;
      if cmd_wr = '1' then
        cmd_data_next <= cmd_data_in;
      else
        cmd_data_next <= (others => '0');
      end if;
      data_out_ready_next <= '0';
    end if;

    -- Issue new commands on falling edge of SDRAM clock so that they
    -- are stable when they get sampled by the SDRAM on the rising edge.
    if sdram_clk_reg = '1' then
      -- By default, decrement the startup/refresh counter and command counter to zero.
      startup_refresh_counter_next <= startup_refresh_counter_reg - 1;
      if startup_refresh_counter_reg = 0 then
        startup_refresh_counter_next <= to_unsigned(0, startup_refresh_counter_next'length);
      end if;
      cmd_counter_next <= cmd_counter_reg - 1;
      if cmd_counter_reg = 0 then
        cmd_counter_next <= to_unsigned(0, cmd_counter_next'length);
      end if;
      -- Perform state-specific tasks
      case state_reg is
        -- Power up and initialisation
        when S_STARTUP =>
          -- Once power is applied and clock is stable, issue INHIBIT or NOP command
          -- during the (POWERUP2INIT = 100 us) startup time of the SDRAM.
          cmd_next <= CMD_NOP;
          sdram_addr_next <= (others => '1');
          if startup_refresh_counter_reg = 0 then
            -- Then, issue a PRECHARGE command.
            state_next <= S_INIT_PRECHARGE;
            -- sdram_addr(10) = '1' ensures that all banks get precharged!
            cmd_next <= CMD_PRECHARGE;
            cmd_counter_next <= to_unsigned(N_RP_WAIT_CYCLES, cmd_counter_next'length);
          end if;
        when S_INIT_PRECHARGE =>
          -- All banks must then be precharged to place the SDRAM in the all banks idle state.
          cmd_next <= CMD_NOP;
          if cmd_counter_reg = 0 then
            -- Once in the all banks idle state, INITREFRESHCYCLES (default 2)
            -- AUTO REFRESH cycles need to be performed before mode register programming
            state_next <= S_INIT_REFRESH_CYCLES;
            cmd_next <= CMD_REFRESH;
            -- Use the command address register to keep track of the
            -- initialisation refresh cycles
            cmd_address_next <= to_unsigned(INITREFRESHCYCLES - 1, cmd_address_next'length);
            cmd_counter_next <= to_unsigned(N_RFC_WAIT_CYCLES, cmd_counter_next'length);
          end if;
        when S_INIT_REFRESH_CYCLES =>
          cmd_next <= CMD_NOP;
          if cmd_counter_reg = 0 then
            if cmd_address_reg /= 0 then
              cmd_address_next <= cmd_address_reg - 1;
              cmd_next <= CMD_REFRESH;
              cmd_counter_next <= to_unsigned(N_RFC_WAIT_CYCLES, cmd_counter_next'length);
            else
              -- Now, the SDRAM is ready for mode register programming. The mode
              -- register and extended mode register should be set prior any normal
              -- operation, as they power up in an unknown state.
              state_next <= S_INIT_MODE_REG;
              cmd_next <= CMD_SET_MODE;
              cmd_counter_next <= to_unsigned(MRDCYCLES, cmd_counter_next'length);
              sdram_ba_next <= SDRAM_MODE_REG_VALUE(NBITSBANK+NBITSROW-1 downto NBITSROW);
              sdram_addr_next <= SDRAM_MODE_REG_VALUE(NBITSROW-1 downto 0);
              -- schedule next refresh
              startup_refresh_counter_next <= to_unsigned(N_REFRESH_PERIOD_CLOCK_CYCLES, startup_refresh_counter_next'length);
            end if;
          end if;
        when S_INIT_MODE_REG =>
          -- The mode register must be loaded when all banks are idle,
          -- and the controller must wait the specified time before
          -- initiating the subsequent operation.
          cmd_next <= CMD_NOP;
          if cmd_counter_reg = 0 then
            -- The Extended Mode Register must be programmed with E8
            -- through E12 set to '0'. Also, E13 (BA0) must be set to '0',
            -- and E14 (BA1) must be set to '1'. The Extended Mode
            -- Register must be loaded when all banks are idle and no
            -- bursts are in progress. The controller must wait the
            -- specified time before initiating any subsequent operation.
            state_next <= S_INIT_EXTENDED_MODE_REG;
            cmd_next <= CMD_SET_MODE;
            cmd_counter_next <= to_unsigned(MRDCYCLES, cmd_counter_next'length);
            sdram_ba_next <= SDRAM_EXTENDED_MODE_REG_VALUE(NBITSBANK+NBITSROW-1 downto NBITSROW);
            sdram_addr_next <= SDRAM_EXTENDED_MODE_REG_VALUE(NBITSROW-1 downto 0);
          end if;
        when S_INIT_EXTENDED_MODE_REG =>
          cmd_next <= CMD_NOP;
          if cmd_counter_reg = 0 then
            -- Now we are ready to process read/write commands
            state_next <= S_IDLE;
            cmd_counter_next <= to_unsigned(0, cmd_counter_next'length);
            cmd_ready_next <= '1';
          end if;
        when S_IDLE =>
          -- Wait for active commands and issue AUTO REFRESH periodically
          cmd_next <= CMD_NOP;
          if startup_refresh_counter_reg = 0
            or ((cmd_strobe = '1' or cmd_ready_reg = '0') and
                startup_refresh_counter_reg <= N_RCD_WAIT_CYCLES + CASLATENCYCYCLES
                + N_WR_WAIT_CYCLES + N_RP_WAIT_CYCLES) then
            state_next <= S_REFRESH;
            cmd_next <= CMD_REFRESH;
            cmd_counter_next <= to_unsigned(N_RFC_WAIT_CYCLES, cmd_counter_next'length);
            startup_refresh_counter_next <= to_unsigned(N_REFRESH_PERIOD_CLOCK_CYCLES, startup_refresh_counter_next'length);
          elsif cmd_strobe = '1' or cmd_ready_reg = '0' then
            state_next <= S_ROW_ACTIVE;
            cmd_next <= CMD_ACTIVATE;
            cmd_counter_next <= to_unsigned(N_RCD_WAIT_CYCLES, cmd_counter_next'length);
            sdram_ba_next <= std_logic_vector(cmd_bank_reg);
            sdram_addr_next <= std_logic_vector(cmd_row_reg);
            if cmd_strobe = '1' then
              sdram_ba_next <= std_logic_vector(cmd_bank);
              sdram_addr_next <= std_logic_vector(cmd_row);
            end if;
          end if;
        when S_ROW_ACTIVE =>
          cmd_next <= CMD_NOP;
          if cmd_counter_reg = 0 then
            if (startup_refresh_counter_reg <= CASLATENCYCYCLES + N_WR_WAIT_CYCLES + N_RP_WAIT_CYCLES) or
               (cmd_ready_reg = '1' and cmd_strobe = '1' and
                (cmd_bank /= cmd_bank_reg or cmd_row /= cmd_row_reg)) then
              state_next <= S_PRECHARGE;
              cmd_next <= CMD_PRECHARGE;
              cmd_counter_next <= to_unsigned(N_RP_WAIT_CYCLES, cmd_counter_next'length);
              -- Ensure with sdram_addr(10) = '1' the precharging of all banks
              sdram_addr_next <= (others => '1');
            elsif cmd_strobe = '1' or cmd_ready_reg = '0' then
              sdram_addr_next <= std_logic_vector(resize(cmd_col_reg, sdram_addr'length));
              if cmd_strobe = '1' then
                sdram_addr_next <= std_logic_vector(resize(cmd_col, sdram_addr'length));
              end if;
              if (cmd_ready_reg = '0' and cmd_wr_reg = '1') or
                (cmd_ready_reg = '1' and cmd_strobe = '1' and cmd_wr = '1') then
                state_next <= S_WRITE;
                cmd_next <= CMD_WRITE;
                cmd_counter_next <= to_unsigned(N_WR_WAIT_CYCLES, cmd_counter_next'length);
              else
                state_next <= S_READ;
                cmd_next <= CMD_READ;
                cmd_counter_next <= to_unsigned(CASLATENCYCYCLES, cmd_counter_next'length);
              end if;
            end if;
          end if;
        when S_READ =>
          cmd_next <= CMD_NOP;
          if cmd_counter_reg = 0 then
            state_next <= S_ROW_ACTIVE;
            data_out_next <= sdram_data_in_reg;
            data_out_ready_next <= '1';
            cmd_ready_next <= '1';
          end if;
        when S_WRITE =>
          cmd_next <= CMD_NOP;
          if cmd_counter_reg = 0 then
            state_next <= S_ROW_ACTIVE;
            cmd_ready_next <= '1';
          end if;
        when S_PRECHARGE =>
          cmd_next <= CMD_NOP;
          if cmd_counter_reg = 0 then
            state_next <= S_IDLE;
          end if;
        when S_REFRESH =>
          cmd_next <= CMD_NOP;
          if cmd_counter_reg = 0 then
            state_next <= S_IDLE;
          end if;
        when others =>
          cmd_next <= CMD_INHIBIT;
          if DEBUG then
            report "SDRAM controller got into an unhandled state!"
              severity error;
          end if;
      end case;
    end if;
  end process NSL;

  -- Output logic
  sdram_clk <= sdram_clk_reg;
  sdram_cke <= '1';                     -- SDRAM clock always enabled

  sdram_cs_n  <= cmd_reg(3);
  sdram_ras_n <= cmd_reg(2);
  sdram_cas_n <= cmd_reg(1);
  sdram_we_n  <= cmd_reg(0);

  sdram_dqm_n <= (others => '0');       -- write/output enabled

  sdram_ba <= sdram_ba_reg;

  sdram_addr <= sdram_addr_reg;

  sdram_data <= cmd_data_reg when cmd_reg = CMD_WRITE else
                (others => 'Z');

  cmd_ready <= cmd_ready_reg;

  data_out       <= data_out_reg;
  data_out_ready <= data_out_ready_reg;

end architecture rtl;
