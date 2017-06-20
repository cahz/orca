
These instructions assume that you are using a linux machine, all other platforms are untested and will probably fail.
This project targets the M2S150-FC1152 SoC, but it should work with minimal changes on other SmartFusion2 SoC's.

## Building

The build process is as follows:
1) Open sf2plus/sf2plus.prjx.
2) In the Design Hierarchy tab, generate the my_mss, my_mss_top, and Top_Fabric_Master SmartDesign files. The mss sub-sheets are
opened by double-clicking the MSS SmartDesign under the Top_Fabric_Master SmartDesign. All of them must be generated, including 
the lowest level Microcontroller Subsystem sheet. The generation process regenerates the Actel cores required for the project.
3) In the Design Flow tab, under Create Constraints->I/O Constraints, right-click the constraint/io/Top_Fabric_Master.io.pdc 
file and select "Use for compile". This I/O Constraints file specifies certain pins (i.e. UART) and can be expanded as neccessary.
4) Build the software directory, as explained in the section below.
5) Build the entire design flow, using the Update eNVM Memory Content option to update the flash memory. The board can now be
flashed with the final bitstream. 

### Software

The `GIT_TOP/sf2plus/software/` directory is built using make. Every time the software directory is rebuilt, the flash content on
the SoC needs to be updated. This is done by using the Program and Debug Design->Update eNVM Memory Content in the Libero tools.
The test.hex generated in the software directory is the file that should be chosen in the Update eNVM Memory Content tool. 
The bistream can then be regenerated using the Program and Debug Design->Program Design->Generate Bitstream. 

### Bootloader

This project is slightly different than the other projects due to Microsemi's flash based SoC's. Because the chips are flash-based,
the Libero tools are not able to initialize the block rams with the compiled software. To work around this, we have included a
hardware bootloader that copies over the initial block ram data from the eNVM flash to the block rams. The hdl for this is found
in the `fabric_master.vhd` file. Once the bootloader has completed, it transfers block ram access to the ORCA processor. The ORCA
is then brought out of reset and then executes the code. 
