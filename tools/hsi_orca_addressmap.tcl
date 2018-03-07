
proc get_connected_mxp { orca } {
	 set vcp_net  [get_nets -of_objects $orca [set orca]_vcp_instruction  ]
	 set cells [ get_cells -of_objects $vcp_net]
	 foreach cell $cells {
		  #return the cell that was not the original
		  if { $cell != $orca } {
				return $cell
		  }
	 }
}

proc generate_bsp { hwh_file orca_name} {
	 open_hw_design $hwh_file
	 set orca [get_cells $orca_name]
	 if { [string length $orca] == 0  } {
		  puts "No cell named $orca_name"
		  return ""
	 }

	 set mem_ranges [get_mem_ranges -of_objects $orca ]
	 set def_guard [string toupper "${orca_name}_BSP_H__"]
	 set bsp "#ifndef $def_guard\n"
	 set bsp "$bsp#define $def_guard\n"
	 set masters [get_property MASTER_INTERFACE [lindex $mem_ranges 0]]

	 foreach mr $mem_ranges {
		  set master [get_property MASTER_INTERFACE $mr]
		  if { [lsearch -exact $masters $master] < 0 } {
				lappend masters $master
		  }
	 }
	 set clk_freq [get_property CLK_FREQ [get_pins -of_objects $orca clk]]
	 set bsp "$bsp\n#define ${orca_name}_CLK_FREQ ${clk_freq}"
	 foreach master $masters {
		  set mem_ranges [get_mem_ranges -of_objects $orca -filter "MASTER_INTERFACE==$master"]
		  foreach mr $mem_ranges {
				set base [get_property BASE_VALUE $mr]
				set high [get_property HIGH_VALUE $mr]
				set define [string toupper "${orca_name}_${master}_${mr}_base_addr" ]
				set bsp "$bsp\n#define $define ${base}"
				set define [string toupper "${orca_name}_${master}_${mr}_high_addr"]
				set bsp "$bsp\n#define $define ${high}"
		  }
	 }
	 set configs [list_property $orca CONFIG.*]
	 foreach conf $configs {
		  set trimmed_conf [string range $conf [string length "Config." ] 999]
		  set define [string toupper "${orca_name}_${trimmed_conf}"]
		  set val [get_property $conf $orca]
		  set bsp "$bsp\n#define $define $val"
	 }

	 set mxp [get_connected_mxp $orca]
	 if { [string length $mxp] > 0  } {
		  set configs [list_property $mxp CONFIG.*]
		  foreach conf $configs {
				set trimmed_conf [string range $conf [string length "Config." ] 999]
				set define [string toupper "${orca_name}_MXP_${trimmed_conf}"]
				set val [get_property $conf $mxp]
				set bsp "$bsp\n#define $define $val"

		  }
	 }

	 set bsp "$bsp\n#endif //$def_guard"
	 return $bsp
}


if { $::argc != 3 } {
	 puts "ERROR: usage: bsp_gen.tcl hardware_file.hwh orca_name header_file.h"
	 exit -1
} else {
	 set hwh_file [lindex $argv 0 ]
	 set orca_name [lindex $argv 1 ]
	 set bsp_h [open [lindex $argv 2 ] "w" ]
	 puts $bsp_h [generate_bsp $hwh_file $orca_name]

}
