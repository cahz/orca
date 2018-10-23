source ../sim_waves.tcl

proc reset_waves { } {
    set orca_system_name [lindex [get_bd_designs] [lsearch [get_bd_designs] *orca_system*]]
    catch { close_wave_config -force } error

    add_wave_divider "Top level"
    add_wave /[set orca_system_name]_wrapper/[set orca_system_name]_i/processing_system7_0_FCLK_CLK0 /[set orca_system_name]_wrapper/[set orca_system_name]_i/processing_system7_0_FCLK_RESET0_N /[set orca_system_name]_wrapper/[set orca_system_name]_i/clk_wiz_clk_out1 /[set orca_system_name]_wrapper/[set orca_system_name]_i/clock_clk_2x_out /[set orca_system_name]_wrapper/[set orca_system_name]_i/clock_peripheral_reset /[set orca_system_name]_wrapper/[set orca_system_name]_i/rst_clk_wiz_100M_interconnect_aresetn /[set orca_system_name]_wrapper/[set orca_system_name]_i/rst_clk_wiz_100M_peripheral_aresetn /[set orca_system_name]_wrapper/[set orca_system_name]_i/leds_8bits_tri_o

    orca_reset_waves add_wave add_wave_divider /[set orca_system_name]_wrapper/[set orca_system_name]_i/orca/U0
}
    

proc add_wave_data_masters { } {
    set orca_system_name [lindex [get_bd_designs] [lsearch [get_bd_designs] *orca_system*]]
    orca_add_wave_data_masters add_wave add_wave_divider /[set orca_system_name]_wrapper/[set orca_system_name]_i/orca/U0
}

proc add_wave_instruction_masters { } {
    set orca_system_name [lindex [get_bd_designs] [lsearch [get_bd_designs] *orca_system*]]
    orca_add_wave_instruction_masters add_wave add_wave_divider /[set orca_system_name]_wrapper/[set orca_system_name]_i/orca/U0
}

proc add_wave_instruction_cache { } {
    set orca_system_name [lindex [get_bd_designs] [lsearch [get_bd_designs] *orca_system*]]
    orca_add_wave_instruction_cache add_wave add_wave_divider /[set orca_system_name]_wrapper/[set orca_system_name]_i/orca/U0
}

proc add_wave_data_cache { } {
    set orca_system_name [lindex [get_bd_designs] [lsearch [get_bd_designs] *orca_system*]]
    orca_add_wave_data_cache add_wave add_wave_divider /[set orca_system_name]_wrapper/[set orca_system_name]_i/orca/U0
}

proc add_wave_instruction_fetch { } {
    set orca_system_name [lindex [get_bd_designs] [lsearch [get_bd_designs] *orca_system*]]
    orca_add_wave_instruction_fetch add_wave add_wave_divider /[set orca_system_name]_wrapper/[set orca_system_name]_i/orca/U0
}

proc add_wave_syscall { } {
    set orca_system_name [lindex [get_bd_designs] [lsearch [get_bd_designs] *orca_system*]]
    orca_add_wave_syscall add_wave add_wave_divider /[set orca_system_name]_wrapper/[set orca_system_name]_i/orca/U0
}

proc add_wave_lsu { } {
    set orca_system_name [lindex [get_bd_designs] [lsearch [get_bd_designs] *orca_system*]]
    orca_add_wave_lsu add_wave add_wave_divider /[set orca_system_name]_wrapper/[set orca_system_name]_i/orca/U0
}

proc add_wave_execute { } {
    set orca_system_name [lindex [get_bd_designs] [lsearch [get_bd_designs] *orca_system*]]
    orca_add_wave_execute add_wave add_wave_divider /[set orca_system_name]_wrapper/[set orca_system_name]_i/orca/U0
}

proc add_wave_alu { } {
    set orca_system_name [lindex [get_bd_designs] [lsearch [get_bd_designs] *orca_system*]]
    orca_add_wave_alu add_wave add_wave_divider /[set orca_system_name]_wrapper/[set orca_system_name]_i/orca/U0
}

proc add_wave_branch { } {
    set orca_system_name [lindex [get_bd_designs] [lsearch [get_bd_designs] *orca_system*]]
    orca_add_wave_branch add_wave add_wave_divider /[set orca_system_name]_wrapper/[set orca_system_name]_i/orca/U0
}

proc add_wave_decode { } {
    set orca_system_name [lindex [get_bd_designs] [lsearch [get_bd_designs] *orca_system*]]
    orca_add_wave_decode add_wave add_wave_divider /[set orca_system_name]_wrapper/[set orca_system_name]_i/orca/U0
}

proc add_wave_all { } {
    set orca_system_name [lindex [get_bd_designs] [lsearch [get_bd_designs] *orca_system*]]
    orca_add_wave_all add_wave add_wave_divider /[set orca_system_name]_wrapper/[set orca_system_name]_i/orca/U0
}
