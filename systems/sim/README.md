These instructions assume that you are using Linux and GNU make, all other
platforms are untested.  This project targets RTL simulation tests using
Modelsim (either the free Intel provided version or a full version of Modelsim
can be used).  The test systems are built using Intel QSYS and require
Quartus/QSYS to build before running in Modelsim.

## Automatic Testing

To run automatic tests run 'make testall'.  The Makefile will compile the
appropriate RISC-V ISA tests as well as the tests in orca/software/orca-tests,
run them all in Modelsim, and print out a message indicating test pass or fail.
Some tests are expected to fail: the rv32ua* tests require atomic memory
instructions that are currently not implemented in ORCA and the interrupt test
requires an interrupt generator that is not present in all systems.
Additionally the dhrystone test uses its error code to report the number of VAX
MIPS if the ORCA is running at 100MHz core clock.

## Manual testing

To examine an individual test, copy the .qex file into orca/systems/sim/test.hex
and then run 'make sim'.  This will create the test system, link test.hex into
the run directory, and then launch Modelsim.  A set of `add_wave_*` commands are
provided to add all the signals in certain ORCA units
(e.g. `add_wave_instruction_fetch`).  The command `add_wave_all` will add all
ORCA signals to the waveform.  Tests report their error codes by setting a
return value in register T3 and running an ECALL instruction in the manner that
the RISC-V ISA test suite runs.  When run on other platforms the ECALL is used
to trigger a print to a UART; on the simulation system a null UART is used so
there is no printout.
