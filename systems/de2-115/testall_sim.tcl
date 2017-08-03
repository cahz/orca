cd  system/testbench/mentor/
do msim_setup.tcl
ld
add wave /system_tb/system_inst/vectorblox_orca_0/D/register_file_1/t3

set files [lsort [glob ../../../test/*.qex]]

foreach f $files {
	 file copy -force $f test.hex
	 restart -f
	 onbreak {resume}
	 when {/system_tb/system_inst/vectorblox_orca_0/X/instruction == x"00000073" && /system_tb/system_inst/vectorblox_orca_0/X/valid_input == "1" } {stop}
	 when {/system_tb/system_inst/vectorblox_orca_0/X/syscall/legal_instruction == "0" && /system_tb/system_inst/vectorblox_orca_0/X/syscall/valid == "1"  } {stop}
	 run 30 us
	 set v [examine -decimal /system_tb/system_inst/vectorblox_orca_0/D/register_file_1/t3 ]
	 puts "$f = $v"
}

exit -f;
