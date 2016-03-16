cd system/testbench/mentor
exec ln -sf ../../../test.hex .
do msim_setup.tcl
ld

proc re_run { t } {
	 restart -f ;
	 run $t
}

add log -r *

add wave -noupdate /system_tb/system_inst/riscv_0/clk
add wave -noupdate /system_tb/system_inst/riscv_0/reset
add wave -noupdate /system_tb/system_inst/riscv_0/coe_to_host
add wave -noupdate -divider Decode
add wave -noupdate /system_tb/system_inst/riscv_0/D/register_file_1/registers(28)
add wave -noupdate -divider Execute
add wave -noupdate /system_tb/system_inst/riscv_0/X/valid_instr
add wave -noupdate /system_tb/system_inst/riscv_0/X/pc_current
add wave -noupdate /system_tb/system_inst/riscv_0/X/instruction

set DefaultRadix hex
