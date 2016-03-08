
Below any reference to GIT_TOP refers to the top level of the git repository

## Building

On windows since symbolic links are not supported, it is necessary to copy the file `GIT_TOP/riscv_hw.tcl` to `GIT_TOP/veek_project/riscv_hw.tcl`.

With Quartus 15.0 open the file `vblox1.qpf`. There should be a warning athat warns about a file called vblox1.qip not being found.

From the menubar open Tools->Qsys, and with qsys open the file `GIT_TOP/veek_project/vblox1.qsys`. When Qsys is done opening this file, click on the riscv component,
you should be able to see the various configuration options. Now frrom the menubar,click Generate->Geneate HDL .
Once the HDL generation has completed, close Qsys, and reopen `vblox.qpf` in quartus. The warning about vblox1.qip should no longer be there.

### Software

These instructions let you run the riscv-tests from https://github.com/riscv/riscv-tests . In the veek_project system, if you want to run
other programs, you will have to study the scripts in this process to figure them out.

Edit `GIT_ROOT/tools/generate_hex_files.sh` so that `TEST_DIR` points to the directory where the compiled riscv-tests have been generated.
Then, from the directory `GIT_TOP/veek_project` run that script `../tools/generate_hex_files.sh`. This will create a directory
`GIT_TOP/veek_project/test/` which contains among other things a bunch of files call *.qex. these are hex files that are correctly
formatted to be read by the initialization routines of the block rams that qsys generates. Unfortunately the block rams do not
read arbitary intel hex files, they have to be of a set width.

Once you have this, copy whichever one of the *.gex files to `GIT_TOP/veek_project/test.hex` then when you synthesize the block rams
will be initialized properly. The name of this file is configured by a configuration field of the "On-Chip Memory" in the Qsys tool.

### Makefiles

If you have created the test.hex in `GIT_TOP/veek_project` you should be able to simply run `make` in `GIT_TOP/veek_project` and everything
should build correctly and vblox.sof will be a bitstream able to download on a veek developement board.
