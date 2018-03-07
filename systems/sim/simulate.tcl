source sim_waves_system.tcl
cd system/simulation/mentor
do msim_setup.tcl
exec ln -sf ../../../test.hex test.hex
ld

add log -r *

reset_waves

proc rerun { t } {
				restart -f;
				run $t
		  }
radix -hexadecimal
config wave -signalnamewidth 1
