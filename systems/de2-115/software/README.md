These instructions assume that you are using Linux and GNU make, all other
platforms are untested.

## Selecting software

The software in this directory is built using a common build script found in
orca/software/software.mk.  It can be passed parameters to set the C sources,
optimization level, etc.  An optional config.mk file in this directory can
contain all of the parameters you want for building software; alternatively
parameters can be passed through the command line.

If no parameters are passed a simple "Hello world" example is built.  Any of the
tests in orca/software/orca-tests can be run by definig the `ORCA_TEST`
variable; e.g. by setting `ORCA_TEST=simple_c` in config.mk or running
`ORCA_TEST=simple_c make` the simple C test will be made.  `ORCA_TEST` can also
be passed using in the orca/systems/de2-115 Makefile (e.g. `ORCA_TEST=simple_c
make run` in that directory to run the test over JTAG on a board that's already
been programmed) but in general it is easier to use the config.mk file in this
directory when building and programming the board.
