
These instructions assume that you are using a linux machine, all other platforms are untested and will probably fail.

## Building

With Quartus 15.0 open the file `system.qpf`. There should be a warning about a file called system.qip not being found.

From the menubar open Tools->Qsys, and with qsys open the file `GIT_TOP/de2-115/system.qsys`. When Qsys is done opening this file, click on the riscv component,
you should be able to see the various configuration options. Now from the menubar, click Generate->Geneate HDL .
Once the HDL generation has completed, close Qsys, and reopen `system.qpf` in quartus. The warning about system.qip should no longer be there.

Now Run Processing->Start Compilation from the menubar, this should build

### Software

Build the software at `GIT_TOP/de2-115/software/` then with the script `GIT_TOP/tools/elf2hex.sh` convert the elf file to a hex file that quartus can
understand. Copy that hex file to this directory and call it test.hex.

### Makefiles

If you have created the test.hex in this directory as described in the above section, you should be able to simply run `make` in this directory and everything
should build correctly and system.sof will be a bitstream able to download on a de2-115 developement board.
