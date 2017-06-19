
proc com {} {
	 set fileset [list \
							../rtl/utils.vhd  \
							../rtl/constants_pkg.vhd \
							../rtl/components.vhd 	  \
							../rtl/alu.vhd 				  \
							../rtl/branch_unit.vhd	  \
							../rtl/decode.vhd 			  \
							../rtl/execute.vhd			  \
							../rtl/instruction_fetch.vhd\
							../rtl/load_store_unit.vhd \
							../rtl/register_file.vhd   \
							../rtl/orca.vhd 			  \
							../rtl/sys_call.vhd 		  \
							../rtl/lve_top.vhd 		  \
							../rtl/4port_mem.vhd 		  \
							../rtl/orca_core.vhd \
							hdl/top_util_pkg.vhd \
							hdl/top_component_pkg.vhd\
							hdl/wb_ram.vhd 		  \
							hdl/wb_arbiter.vhd \
							hdl/wb_splitter.vhd \
							hdl/wb_pio.vhd \
							hdl/bram.vhd \
							hdl/my_led_sim.v\
							hdl/uart_rd1042/uart_core.vhd\
							hdl/uart_rd1042/modem.vhd      \
							hdl/uart_rd1042/rxcver.vhd		 \
							hdl/uart_rd1042/txcver_fifo.vhd\
							hdl/uart_rd1042/rxcver_fifo.vhd\
							hdl/uart_rd1042/intface.vhd	 \
							hdl/uart_rd1042/txmitt.vhd     \
							hdl/pmod_mic/pmod_mic_wb.vhd \
							hdl/pmod_mic/pmod_mic_ref_comp.vhd \
							top.vhd				  \
							hdl/top_tb.vhd]



	 vlib work

	 foreach f $fileset {
		  if { [file extension $f ] == ".v" } {
				vlog -work work -stats=none $f
		  } else {
				vcom -work work -2002 -explicit $f
		  }
	 }
}

com

vsim work.top_tb
add log -r *

add wave -noupdate /top_tb/dut/rv/core/clk
add wave -noupdate /top_tb/dut/rv/core/reset
add wave -noupdate -divider Decode
add wave -noupdate /top_tb/dut/rv/core/D/register_file_1/t3
add wave -noupdate -divider Execute
add wave -noupdate /top_tb/dut/rv/core/X/valid_instr
add wave -noupdate /top_tb/dut/rv/core/X/pc_current
add wave -noupdate /top_tb/dut/rv/core/X/instruction

proc rerun { t } {
				restart -f;
				run $t
		  }
radix -hexadecimal
config wave -signalnamewidth 2
