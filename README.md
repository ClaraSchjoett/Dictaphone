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
* `vhdl_ls.toml`: Configuration file for [`rust_hdl`][rusthdl]
* `build/`: Folder created automatically when design is simulated and
  synthesised with the help of [FuseSoC][fusesoc]
* `hdl/`: Folder with all the HDL files of the design
  * `sdram_controller.vhdl`: Simple generic Single Data Rate (SDR)
    SDRAM controller
  * `sdram_controller_tb.vhdl`: Test bench for `sdram_controller`
  * `is42vm16160k_pkg.vhdl`: Constants package describing the ISSI
    IS42VM16160K SDRAM
  * `gecko4_education_pkg.vhdl`: Package with
    GECKO4-Education-specific type and constants definitions
  * `sdram_controller_top.vhdl`: Top-level design for testing the
    `sdram_controller` on the [GECKO4-Education][gecko4edu]
  * `sdram_controller_top_tb.vhdl`: Test bench for the top-level
    design `sdram_controller_top`
* `ghdl/`: Folder with `Makefile` to simulate the design using
  [GHDL][ghdl] and display the results using [GTKWave][gtkwave]
   * `Makefile`: `make all` compiles the whole design with
     `ghdl`. `make run` simulates all test benches with `ghdl`. The
     resulting `.ghw` files can be displayed using the GTKWave.
   * `sdram_commands.gtkf`: GTKWave configuration file for decoding
     the SDRAM commands
   * `sdram_controller_tb.gtkw`: GTKWave configuration file for test
     bench `sdram_controller_tb`
* `modelsim/`: Folder with `Makefile` to simulate the design using
  [Mentor Graphics ModelSim][modelsim]
  * `Makefile`: `make all` compiles the whole design with
    `vcom`. `make run` simulates all test benches with `vsim`. The
    resulting `.wlf` files can be displayed using the `vsim`. The
    `Makefile` uses by default the script
    [`intelFPGA`](https://www.microlab.ti.bfh.ch/wiki/huce:microlab:tools:linux-client:intel_quartus_prime_lite)
    to initialise the shell environment for using ModelSim.
  * `sdram_controller_tb_sim.do`: Tcl script for simulating the test
    bench `sdram_controller_tb`
  * `sdram_controller_tb_tb_wave.do`: Tcl script to format the display
    of the most important signals of test bench `sdram_controller_tb`
  * `sdram_controller_top_tb_sim.do`: Tcl script for simulating the
    test bench `sdram_controller_top_tb`
  * `sdram_controller_top_tb_tb_wave.do`: Tcl script to format the
    display of the most important signals of test bench
    `sdram_controller_top_tb`
* `quartus/`: Folder with the files for synthesizing the design using
  Intel Quartus Prime
  * `sdram_controller_top.tcl`: Tcl script for pin-mapping all ports
    of the top-level design entity `sdram_controller_top`
  * `sdram_controller_top.sdc`: Synopsys Design Constraints (SDC) file
    needed for static timing analysis

[^1]: ISSI: ["IS42/45SM/RM/VM16160K 4M x 16Bits x 4Banks Mobile
    Synchronous
    DRAM"](http://www.issi.com/WW/pdf/42-45SM-RM-VM16160K.pdf), data
    sheet, Rev. B1, Integrated Silicon Solution, Inc., March 2015, URL
    last visited 2019-05-27.

[^2]: Intel: ["SDRAM Controller Core with Avalon
    interface"](https://www.intel.com/content/www/us/en/programmable/documentation/sfo1400787952932.html#iga1401314928585)
    in the "Embedded Peripherals IP User Guide". UG-01085, 2019-04-01,
    URL last visited 2019-05-27.

[^3]: Mike Field: ["SDRAM Memory
    Controller"](http://hamsterworks.co.nz/mediawiki/index.php/SDRAM_Memory_Controller),
    2013-10-15, URL last visited 2019-05-27.

[^4]: Mike Field: ["Simple SDRAM
    Controller"](http://hamsterworks.co.nz/mediawiki/index.php/Simple_SDRAM_Controller),
    2014-09-13, URL last visited 2019-05-27.


[fusesoc]: https://github.com/olofk/fusesoc "FuseSoC: A package manager and a set of build tools for FPGA/ASIC development"

[gecko4edu]: https://gecko-wiki.ti.bfh.ch/geck4education:start "GECKO4-Education: FPGA board based on an Altera Cyclone IV FPGA used at BFH in the first two years of Bachelor studies"

[ghdl]: https://github.com/ghdl/ghdl "Free VHDL simulator implemented in Ada"

[gtkwave]: http://gtkwave.sourceforge.net/ "GTKWave: A fully featured GTK+-based wave viewer"

[modelsim]: http://fpgasoftware.intel.com/18.1/?edition=lite "ModelSim-Intel FPGA Starter Edition provided as part of Intel Quartus Prime Lite Edition, version 18.1, released September 2018"

[quartusprimelite]: http://fpgasoftware.intel.com/18.1/?edition=lite "Intel Quartus Prime Lite Edition, version 18.1, released September 2018"

[rusthdl]: https://github.com/kraigher/rust_hdl "`rust_hdl`: A collection of HDL-related tools written in Rust providing a VHDL parser and VHDL Language Server"
