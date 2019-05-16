These instructions assume that you are using Linux and GNU make, all other
platforms are untested.  This system targets a DE2-115 development board, and
can be run on the Tpad or Veek development boards which use a DE2-115 as their
base.

## Building

The build process can be done completely from the command line by the included
Makefile (just run `make`).  Alternatively, running `make gui-quartus` will
create the project and open Quartus so you can use the GUI tools from there.

If you wish to modify the QSYS system (e.g. to change the ORCA parameters or add
another peripheral) you can run `make gui-qsys` to create the QSYS system and
open the QSYS GUI.  After saving changes you've made run either `make` to build
the system on the command line or `make gui-quartus` to generate the QSYS system
and then open Quartus.


## Programming

The Makefile includes pgm and run targets.  `make pgm` will download the
bitstream to the board.  `make run` will load the program built from the
software/ directory into instruction memory and reset the processor.

Outputs cannot be seen on HEX when using make run. You can use the 
`make terminal-run` command to see program outputs. In this way,
outputs can be seen via terminal.


## Changing Only ORCA Parameters

If you wish to make a system with only changes to ORCA parameters you can do so
by passing the parameters to the Makefile.  If an optional `config.mk` file
exists it will be included in the Makefile and is a good place to put these
parameters.  For instance, to set `PIPELINE_STAGES` to 4, add the line
`PIPELINE_STAGES=4` to `config.mk`.


## Software

The `software/` directory is built using make.  Running make in the software
directory builds the .coe file needed for simulation and initializing the BRAMs
on power-up.  The de2-115 Makefile automatically builds the .coe file when
initializing the project or simulation.

To run and debug new programs use the `make run` command which will download the
program over JTAG.  This runs a script which holds the processor in reset,
downloads the new program, then releases the reset to allow the program to run.

See README.md in the software directory for instructions on building software.


## Simulation

To simulate, start by running `make sim`.  This builds a QSYS testbench and
launches Modelsim.  A set of `add_wave_*` commands are provided to add all the
signals in certain ORCA units (e.g. `add_wave_instruction_fetch`).  The command
`add_wave_all` will add all ORCA signals to the waveform.


## Block RAM Initialization

Block RAMs are initialized by the file in software/test.hex for running at
startup.  Currently to update the BRAMs the entire build script needs to be
rerun; as such the dependency between software/test.hex and the bitstream is not
included in the Makefile.  The design flow that works best currently is to debug
programs using `make run` to load them at run-time and only after the program is
ready for deployment re-make the bitstream from scratch (`make clean && make`)
to initialize the BRAMs.

It should be possible to update the BRAM contents after bitstream generation; we
are working towards a robust BRAM initialization script in a future release.


