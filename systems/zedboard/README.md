These instructions assume that you are using Linux and GNU make, all other
platforms are untested.  This project targets the Zynq-7000 XC7Z020-CLG484-1
SoC, found on the Zedboard development kit.


## Building

The build process can be done completely from the command line by the included
Makefile (just run `make`).  Alternatively, running `make gui` will create the
project and open Vivado so you can use the GUI tools from there.

Changes to the Vivado block design (BD) have to be exported to a TCL file to be
saved.  This happens automatically if you run `make` from the command line.  If
built from the GUI changes to the BD can be saved to the repository by running
`make archiveBD`.


## Programming

The Makefile includes pgm and run targets.  `make pgm` will download the
bitstream to the board.  `make run` will load the program built from the
software/ directory into instruction memory and reset the processor.


## Changing Only ORCA Parameters

If you wish to make a system with only changes to ORCA parameters you can do so
by passing the parameters to the Makefile.  If an optional `config.mk` file
exists it will be included in the Makefile and is a good place to put these
parameters.  For instance, to set `PIPELINE_STAGES` to 4, add the line
`PIPELINE_STAGES=4` to `config.mk`.


## Software

The `software/` directory is built using make.  Running make in the software
directory builds the .coe file needed for simulation and initializing the BRAMs
on power-up.  The zedboard Makefile automatically builds the .coe file when
initializing the project or simulation.

To run and debug new programs use the `make run` command which will download the
program over JTAG.  This runs a script which holds the processor in reset,
downloads the new program, then releases the reset to allow the program to run.


## Simulation

To simulate, start by running `make sim`.  This builds the file
software/test.coe which initializes the block RAMs, and generates and opens the
design in Vivado sourcing the simulate.tcl script.  Once in Vivado open the TCL
console and use the following commands provided by simulate.tcl:

* `reset_sim` - Reset the simulation and reload all IP to get source file changes.
* `start_sim` - Launch a simulation, forcing signals that need to be forced,
  etc.
* `add_wave_all` - Add waves for all parts of the processor; there are separate
  add\_wave\_* (`add_wave_instruction_fetch`, etc.) commands for individual parts.

A common set of commands would be `reset_sim; start_sim; add_wave_all; run 100us`


## Block RAM Initialization

Block RAMs are initialized by the file in software/test.coe for running at
startup.  Currently to update the BRAMs the entire build script needs to be
rerun; as such the dependency between software/test.coe and out.bit is not
included in the Makefile.  The design flow that works best currently is to debug
programs using `make run` to load them at run-time and only after the program is
ready for deployment re-make the bitstream from scratch (`make clean && make`)
to initialize the BRAMs.

It is possible to initialize the BRAMs of a full bitstream in a matter of
seconds; however, there doesn't seem to be a standard way to do so when not
using a Xilinx supported processor.  We are working towards a robust BRAM
initialization script in a future release.


## Hardware Triggering

To begin triggering an ILA core right at startup (rather than on user input),

1) In the hardware manager tcl shell, enter the command
* `run_hw_ila -force -file ila_trig.tas [get_hw_ilas hw_ila_1]`

2) In the implemented design tcl shell, enter the commands
* `apply_hw_ila_trigger ila_trig.tas`
* `write_bitstream -force trig_at_startup.bit`

3) Program the device using trig\_at\_startup.bit, as well as the debug nets in
the orca/zedboard/project/project.runs/impl1/ subdirectory.


## JTAG Frequency

It is sometimes possible that the JTAG frequency is too fast for the debug JTAG
cores in the design.  This can cause JTAG data (for example, ila data) to become
corrupted.  A possible fix for this issue is to reduce the JTAG frequency.  To
do this, in the side panel under Program and Debug, select Open Target -> Open
New Target..., then select the local server option from the drop down menu.
Click next, and now a drop down menu should appear that shows the acceptable
JTAG frequencies.  The default should be 15 MHz.  Select a lower frequency (5
MHz should be fine).  Click next, then finish.
