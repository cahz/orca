
Below any reference to GIT_TOP refers to the top level of the git repository
These instructions assume that you are using a linux machine, all other platforms are untested and will probably fail.
## Building

With Quartus 15.0 open the file `system.qpf`. There should be a warning athat warns about a file called system.qip not being found.

From the menubar open Tools->Qsys, and with qsys open the file `GIT_TOP/de2-115/system.qsys`. When Qsys is done opening this file, click on the riscv component,
you should be able to see the various configuration options. Now frrom the menubar,click Generate->Geneate HDL .
Once the HDL generation has completed, close Qsys, and reopen `system.qpf` in quartus. The warning about system.qip should no longer be there.

### Software

These instructions let you run the riscv-tests from https://github.com/riscv/riscv-tests on the de2-115 system, if you want to run
other programs, you will have to study the scripts in this process to figure them out.

Edit `GIT_ROOT/tools/generate_hex_files.sh` so that `TEST_DIR` points to the directory where the compiled riscv-tests have been generated.
Then, from the directory `GIT_TOP/de2-115` run that script `../tools/generate_hex_files.sh`. This will create a directory
`GIT_TOP/de2-115/test/` which contains among other things a bunch of files call *.qex. these are hex files that are correctly
formatted to be read by the initialization routines of the block rams that qsys generates. Unfortunately the block rams do not
read arbitary intel hex files, they have to be of a specific width.

Once you have this, copy whichever one of the *.qex files to `GIT_TOP/de2-115/test.hex` then when you synthesize the block rams
will be initialized properly. The name of this file is configured by a configuration field of the "On-Chip Memory" in the Qsys tool.

### Makefiles

If you have created the test.hex in `GIT_TOP/de2-115` you should be able to simply run `make` in `GIT_TOP/de2-115` and everything
should build correctly and system.sof will be a bitstream able to download on a de2-115 developement board.

#### Simulation

Running `make sim` should generate a testbench, and then start up modelsim. Make sure you have a `test.hex` in `GIT_TOP/de2-115`
