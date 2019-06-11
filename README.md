# Dictaphone

[Clara Schjoett] (mailto:claraagerskov.schjoett@students.bfh.ch)   
[Peter Wuethrich] (mailto:peterwuethrich@students.bfh.ch)
[Berner Fachhochschule (BFH) - Elektrotechnik und Informationstechnologie (EIT)](https://ti.bfh.ch/elektro)  
Jlcoweg 1  
CH-3400 Burgdorf  
Switzerland


## Introduction

This project directory contains the VHDL implementation of a 
dictaphone for an FPGA.
Each VHDL file contains a header comment explaining the purpose and overall
function of it.


## Files

The files constituting this design are organised as follows:

* `README.md`: This file
  
* `Pin_assignment/`: Folder with tcl files for project
  * `clocks.tcl`: Onboard oscillator pin assignment
  * `led_array.tcl`: LED matrix pin assignments
  * `pmod.tcl`: Pmod modules pin assignments
  * `sdram_controller.tcl`: Pin assigments for onboard SDRAM
  * `seven_segment.tcl`: Pin assigments for seven segment displays
  * `switches.tcl`: Pin assigments for onboard buttons
  
  
* `hdl/`: Folder with all the HDL files of the design (sorted alphabetically)
  * `clk_divider_1khz.vhd`: Provided by Torsten Maehne, instantiated in peak_level_ctrl
  * `debouncer.vhd`: Debouncer for push buttons
  * `DEC2SSD.vhd`: Conversion of 2 inputs to display on 4 seven segment displays
  * `DICT_WRAP.vhd`: Top entity in design
  * `fifo.vhd`: FIFO ring buffer, 1024 registers depth
  * `fifo_tb.vhd`: test bench for FIFO, funtionality according to instruction requirements
  * `FSM_MENU.vhd`: Menu navigation for dictaphone
  * `gecko4_education_pkg.vhdl`: Package with GECKO4-Education-specific type and constants definitions
  * `is42vm16160k_pkg.vhdl`: Constants package describing the ISSI IS42VM16160K SDRAM
  * `LEDmatrix.vhd`: Conversion of counter and sound level bars to display on LED matrix
  * `Mult32x18.vhd`: Provided by Torsten Maehne, instantiated in PeakLevelMeter
  * `PAR2SER_I2S.vhd`: Parallel to serial converter, data for audio jack
  * `peak_level_ctrl.vhd`: Provided by Torsten Maehne, instantiated in DICT_WRAP
  * `PeakLevelMeter.vhd`: Provided by Torsten Maehne, instantiated in peak_level_ctrl
  * `sdram_controller.vhdl`: Simple generic Single Data Rate (SDR) SDRAM controller
  * `SER2PAR_SPI.vhd`: Serial to parallel converter, data from microphone


* `txt/`: Folder with text files used in project
  * `Arbeitsjournal.txt`: Work journal
  * `data_in.txt`: list of 16 bit vectors, used by fifo_tb.vhd
  * `data_out.txt`: (empty file), used by fifo_tb.vhd