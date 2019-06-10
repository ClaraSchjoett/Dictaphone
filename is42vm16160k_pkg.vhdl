-------------------------------------------------------------------------------
-- Title      : Constants package describing the IS42VM16160K SDRAM
-- Project    : BTE5024
-------------------------------------------------------------------------------
-- File       : is42vm16160k_pkg.vhdl
-- Author     : Torsten Maehne  <torsten.maehne@bfh.ch>
-- Company    : BFH-EIT
-- Created    : 2019-05-20
-- Last update: 2019-05-28
-- Platform   : Intel Quartus Prime 18.1
-- Standard   : VHDL'93/02, Math Packages
-------------------------------------------------------------------------------
-- Description:
--
-- The properties of the ISSI IS42VM16160K SDRAM summarised in this package are
-- taken from its data sheet [1].
--
-- References:
--
-- [1] ISSI: "IS42/45SM/RM/VM16160K 4M x 16Bits x 4Banks Mobile
--     Synchronous DRAM", data sheet, Rev. B1, Integrated Silicon
--     Solution, Inc., March 2015.
--     <http://www.issi.com/WW/pdf/42-45SM-RM-VM16160K.pdf>,
--     last visited 2019-05-27.
--
-------------------------------------------------------------------------------
-- Copyright (c) 2019 BFH-EIT
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2019-05-20  1.0      mht1	Created
-------------------------------------------------------------------------------

package is42vm16160k_pkg is

  constant NBITSDATA         : positive     := 16;
  constant NBITSBANK         : positive     := 2;
  constant NBITSROW          : positive     := 13;
  constant NBITSCOL          : positive     := 9;
  constant FREQCLOCK         : real         := 50.0e6;
  -- The CAS latency of the IS42VM16160K is programmable to either 2 or 3
  constant CASLATENCYCYCLES  : positive     := 2;
  constant INITREFRESHCYCLES : positive     := 2;
  constant REFRESHPERIOD     : delay_length := 7.8125 us;
  constant POWERUP2INIT      : delay_length := 100.0 us;
  constant TRFC              : delay_length := 80.0 ns;
  constant TRP               : delay_length := 22.5 ns;
  constant TRCD              : delay_length := 22.5 ns;
  constant TAC               : delay_length := 8.0 ns;
  constant TWR               : delay_length := 22.5 ns;
  constant MRDCYCLES         : positive     := 3;

end package is42vm16160k_pkg;
