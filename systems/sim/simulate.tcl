source sim_waves_system.tcl
cd system_[set system_name]/simulation/mentor
do msim_setup.tcl
exec ln -sf ../../../test.hex test.hex
ld

add log -r *

reset_waves $system_name

proc rerun { t } {
				restart -f;
				run $t
		  }
radix -hexadecimal
config wave -signalnamewidth 1
