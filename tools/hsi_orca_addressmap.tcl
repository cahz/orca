
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
proc generate_lscript { hwh_file orca_name} {

	 set hw [open_hw_design $hwh_file]
	 set orca [get_cells $orca_name]
	 if { [string length $orca] == 0  } {
		  puts "No cell named $orca_name"
		  return ""
	 }
	 set reset_vector [get_property CONFIG.RESET_VECTOR $orca]
	 set mem_ranges [lsort -unique [get_mem_ranges -of_objects $orca ]]
	 foreach mr $mem_ranges {
		  set mem_name $mr
		  set lo_addr [get_property BASE_VALUE $mr]
		  set hi_addr [get_property HIGH_VALUE $mr]
		  if { $reset_vector >= $lo_addr && $reset_vector < $hi_addr } {
				break;
		  }
	 }
	 set input_lscript "[file dirname [file normalize [info script]]]/lscript.template"
	 set tmpl [open $input_lscript]
	 set output "/*AUTOMATICALLY GENERATED FILE*/"
	 while {[gets $tmpl line] != -1} {
		  #transform $line somehow
		  if { [string match "*MEM_REGION*" $line] } {
				foreach mr $mem_ranges {
					 set mr_lo_addr [get_property BASE_VALUE $mr]
					 set mr_hi_addr [get_property HIGH_VALUE $mr]
					 set memline $line
					 regsub "MEM_REGION" $memline $mr memline
					 regsub "MEM_ORIGIN" $memline $mr_lo_addr memline
					 regsub "MEM_LENGTH" $memline [format "0x%x" [expr $mr_hi_addr - $mr_lo_addr +1]] memline
					 set output "$output\n$memline"
				}
				continue
		  }
		  regsub "MEM_NAME" $line $mem_name line
		  regsub "RESET_VECTOR" $line $reset_vector line
		  regsub "END_OF_MEMORY" $line [format "0x%x" [expr $hi_addr & (~3) ]] line
		  set output "$output\n$line"
	 }
	 close_hw_design $hw
	 return $output

}
proc generate_bsp { hwh_file orca_name} {
	 set hw [open_hw_design $hwh_file]
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
	 close_hw_design $hw
	 return $bsp
}


proc usage {} {
	 puts "ERROR: usage:  [-h header_file.h ] [ -l lscript_file.ld] orca_name hardware_file.hwh"
	 exit -1

}
if { $::argc < 3 } {
	 usage
} else {

	 set hwh_file [lindex $argv end ]
	 set orca_name [lindex $argv end-1 ]
	 set header_file ""
	 set lscript_file ""
	 puts "$hwh_file $orca_name"
	 for {set arg 0} {$arg < [llength $argv]-2 } {incr arg} {
		  set argstring [lindex $argv $arg]
		  if { [string equal [string range $argstring  0 1] "-h"] } {
				if { [string length $argstring ] == 2 } {
					 set header_file [lindex $argv [expr $arg + 1]]
					 incr arg
				} else {
					 set header_file [string range $argstring 2 end]
				}
				continue
		  }
		  if { [string equal [string range $argstring  0 1] "-l"] } {
				if { [string length $argstring ] == 2 } {
					 set lscript_file [lindex $argv [expr $arg + 1]]
					 incr arg
				} else {
					 set lscript_file [string range $argstring 2 end]
				}
		  }

	 }
	 if { [string length $header_file] } {
		  set bsp_h [open $header_file "w" ]
		  puts $bsp_h [generate_bsp $hwh_file $orca_name]
	 }

	  if { [string length $lscript_file] } {
		  set lscript [open $lscript_file "w" ]
		  puts $lscript [generate_lscript $hwh_file $orca_name]
	 }
}
