cd system/testbench/mentor
exec ln -sf ../../../test.hex .
do msim_setup.tcl
ld

proc re_run { t } {

	 restart -f ;
	 run $t
}

add log -r *

add wave -noupdate /system_tb/system_inst/vectorblox_orca_0/clk
add wave -noupdate /system_tb/system_inst/vectorblox_orca_0/reset

add wave -noupdate -divider Execute
add wave -noupdate /system_tb/system_inst/vectorblox_orca_0/core/X/valid_instr
add wave -noupdate /system_tb/system_inst/vectorblox_orca_0/core/X/pc_current
add wave -noupdate /system_tb/system_inst/vectorblox_orca_0/core/X/instruction

set DefaultRadix hex
