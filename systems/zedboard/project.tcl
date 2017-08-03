
#creates .xpr
proc init_project { proj_dir proj_name} {
	 create_project $proj_name $proj_dir -part xc7z020clg484-1
	 set_property BOARD_PART em.avnet.com:zed:part0:1.3 [current_project]
	 set_property ip_repo_paths ../../rtl/ [current_fileset]
	 update_ip_catalog
	 close_project
}

#creates .bd and .vhd
proc create_bd {proj_dir proj_name bd_file} {
	 open_project $proj_dir/$proj_name.xpr
	 source $bd_file
	 make_wrapper -files [get_files $proj_dir/$proj_name.srcs/[current_fileset]/bd/[current_bd_design]/[current_bd_design].bd] -top
	 add_files -norecurse $proj_dir/$proj_name.srcs/[current_fileset]/bd/[current_bd_design]/hdl/[current_bd_design]_wrapper.v
	 update_compile_order -fileset [current_fileset]
	 validate_bd_design -force
	 close_project
}

#creates .hwdef
proc generate_bd_design {proj_dir proj_name } {
	 open_project $proj_dir/$proj_name.xpr
	 set bd_design [glob $proj_dir/$proj_name.srcs/[current_fileset]/bd/*/*.bd]
	 open_bd_design $bd_design
	 generate_target all [get_files  $bd_design ]
	 export_ip_user_files -of_objects [get_files $bd_design] -no_script -force -quiet
	 close_project
}

#creates synth_1/runme.log
proc project_synth {proj_dir proj_name } {
	 open_project $proj_dir/$proj_name.xpr
	 reset_run synth_1
	 launch_runs synth_1
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
#init_project prj_dir prj_name
#create_bd prj_dir prj_name design_1.tcl
#generate_bd_design prj_dir prj_name
#project_synth prj_dir prj_name
#project_impl prj_dir prj_name
