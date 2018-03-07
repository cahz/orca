
#creates .xpr
proc init_project { proj_dir proj_name} {
    create_project $proj_name $proj_dir -part xc7z020clg484-1 -force
    set_property BOARD_PART em.avnet.com:zed:part0:1.3 [current_project]
    set_property ip_repo_paths "../../ip/ ip/" [current_fileset]
    update_ip_catalog
    #Make a temporary .xdc for ILA/debugging
    file mkdir $proj_dir/$proj_name.srcs/constrs_1
    file mkdir $proj_dir/$proj_name.srcs/constrs_1/new
    close [ open $proj_dir/$proj_name.srcs/constrs_1/new/debug.xdc w ]
    add_files -fileset constrs_1 $proj_dir/$proj_name.srcs/constrs_1/new/debug.xdc
    set_property target_constrs_file $proj_dir/$proj_name.srcs/constrs_1/new/debug.xdc [current_fileset -constrset]
    close_project
}

#creates .bd and .vhd
proc create_bd {proj_dir proj_name bd_file bd_changes} {
    open_project $proj_dir/$proj_name.xpr
    source $bd_file
    make_wrapper -files [get_files $proj_dir/$proj_name.srcs/[current_fileset]/bd/[current_bd_design]/[current_bd_design].bd] -top
    add_files -norecurse $proj_dir/$proj_name.srcs/[current_fileset]/bd/[current_bd_design]/hdl/[current_bd_design]_wrapper.v
    update_compile_order -fileset [current_fileset]
    set bd_design [glob $proj_dir/$proj_name.srcs/[current_fileset]/bd/*/*.bd]
    open_bd_design $bd_design
    foreach {property value} $bd_changes {
	puts "Changing ORCA parameter: set_property -dict [list CONFIG.$property $value] [get_bd_cells orca]"
        set_property -dict [list CONFIG.$property $value] [get_bd_cells orca]
    }
    set_msg_config -id {BD 41-237} -new_severity {WARNING}
    validate_bd_design -force
    save_bd_design
    close_project
}

#creates .hwdef
proc generate_bd_design {proj_dir proj_name {bd_tcl_name ""} } {
    open_project $proj_dir/$proj_name.xpr
    set bd_design [glob $proj_dir/$proj_name.srcs/[current_fileset]/bd/*/*.bd]
    open_bd_design $bd_design
    catch { reset_target all [get_files $bd_design] }
    generate_target all [get_files  $bd_design ]
	 if { [string length $bd_tcl_name] > 0 } {
		  write_bd_tcl $bd_tcl_name
	 }
    close_project
}

#creates synth_1/runme.log
proc project_synth {proj_dir proj_name } {
    open_project $proj_dir/$proj_name.xpr
    reset_run synth_1
    launch_runs synth_1 -jobs 4
    wait_on_run synth_1
    close_project
}
#creates synth_1/runme.log
proc project_impl {proj_dir proj_name } {
    open_project $proj_dir/$proj_name.xpr
    reset_run impl_1
    launch_runs impl_1 -to_step write_bitstream
    wait_on_run impl_1
    close_project
}

proc export_bitstream {proj_dir proj_name } {
    open_project $proj_dir/$proj_name.xpr
    file  copy -force [glob $proj_dir/$proj_name.runs/[current_run]/*.bit] $proj_name.bit
    close_project
}

if {$argc > 0} {
    regsub -all {\\\{} $argv "{" argv
    regsub -all {\\\}} $argv "}" argv
    puts "Executing [set argv]"
    eval [set argv]
}
