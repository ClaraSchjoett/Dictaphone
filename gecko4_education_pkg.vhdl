-------------------------------------------------------------------------------
-- Title      : GECKO4-Education-specific constants and type definitions
-- Project    : BTE5024
-------------------------------------------------------------------------------
-- File       : gecko4_education_pkg.vhdl
-- Author     : Torsten Maehne  <torsten.maehne@bfh.ch>
-- Company    : BFH-EIT
-- Created    : 2019-05-20
-- Last update: 2019-05-28
-- Platform   : Intel Quartus Prime 18.1
-- Standard   : VHDL'93/02, Math Packages
-------------------------------------------------------------------------------
-- Description:
--
-- This package contains some type and constants definitions specific for the
-- use with the GECKO4-Education FPGA board [1].
--
-- References:
--
-- [1] Theo Kluter, et al.: "GECKO4-Education: FPGA board based on an
--     Altera Cyclone IV FPGA", Wiki, BFH-TI, 2015-2019.
--     <https://gecko.microlab.ch/>, last visited 2019-05-27
--
-------------------------------------------------------------------------------
-- Copyright (c) 2019 BFH-EIT
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2019-05-28  1.0      mht1	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package gecko4_education_pkg is

  type std_logic_matrix is array (natural range<>, natural range<>) of std_logic;

  constant LED_MATRIX_ROWS : positive := 10;
  constant LED_MATRIX_COLS : positive := 12;

end package gecko4_education_pkg;
