source ../sim_waves.tcl

proc reset_waves { } {
    catch { close_wave_config -force } error

    add_wave_divider "Top level"
    add_wave /orca_system_wrapper/orca_system_i/processing_system7_0_FCLK_CLK0 /orca_system_wrapper/orca_system_i/processing_system7_0_FCLK_RESET0_N /orca_system_wrapper/orca_system_i/clk_wiz_clk_out1 /orca_system_wrapper/orca_system_i/clock_clk_2x_out /orca_system_wrapper/orca_system_i/clock_peripheral_reset /orca_system_wrapper/orca_system_i/rst_clk_wiz_100M_interconnect_aresetn /orca_system_wrapper/orca_system_i/rst_clk_wiz_100M_peripheral_aresetn /orca_system_wrapper/orca_system_i/leds_8bits_tri_o

    orca_reset_waves add_wave add_wave_divider /orca_system_wrapper/orca_system_i/orca/U0
}
    

proc add_wave_data_masters { } {
    orca_add_wave_data_masters add_wave add_wave_divider /orca_system_wrapper/orca_system_i/orca/U0
}

proc add_wave_instruction_masters { } {
    orca_add_wave_instruction_masters add_wave add_wave_divider /orca_system_wrapper/orca_system_i/orca/U0
}

proc add_wave_instruction_cache { } {
    orca_add_wave_instruction_cache add_wave add_wave_divider /orca_system_wrapper/orca_system_i/orca/U0
}

proc add_wave_data_cache { } {
    orca_add_wave_data_cache add_wave add_wave_divider /orca_system_wrapper/orca_system_i/orca/U0
}

proc add_wave_instruction_fetch { } {
    orca_add_wave_instruction_fetch add_wave add_wave_divider /orca_system_wrapper/orca_system_i/orca/U0
}

proc add_wave_syscall { } {
    orca_add_wave_syscall add_wave add_wave_divider /orca_system_wrapper/orca_system_i/orca/U0
}

proc add_wave_lsu { } {
    orca_add_wave_lsu add_wave add_wave_divider /orca_system_wrapper/orca_system_i/orca/U0
}

proc add_wave_execute { } {
    orca_add_wave_execute add_wave add_wave_divider /orca_system_wrapper/orca_system_i/orca/U0
}

proc add_wave_alu { } {
    orca_add_wave_alu add_wave add_wave_divider /orca_system_wrapper/orca_system_i/orca/U0
}

proc add_wave_branch { } {
    orca_add_wave_branch add_wave add_wave_divider /orca_system_wrapper/orca_system_i/orca/U0
}

proc add_wave_decode { } {
    orca_add_wave_decode add_wave add_wave_divider /orca_system_wrapper/orca_system_i/orca/U0
}

proc add_wave_all { } {
    orca_add_wave_all add_wave add_wave_divider /orca_system_wrapper/orca_system_i/orca/U0
}
