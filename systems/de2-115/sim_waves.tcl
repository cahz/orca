source ../sim_waves.tcl

proc reset_waves { } {
    catch { delete wave * } error

    add wave -divider "Top level"
    add wave /clk_clk
    add wave /reset_reset_n
    add wave /hex*_export
    add wave /led*_export

    orca_reset_waves "add wave" "add wave -divider" /orca_system/the_vectorblox_orca
}
    

proc add_wave_data_masters { } {
    orca_add_wave_data_masters "add wave" "add wave -divider" /orca_system/the_vectorblox_orca
}

proc add_wave_instruction_masters { } {
    orca_add_wave_instruction_masters "add wave" "add wave -divider" /orca_system/the_vectorblox_orca
}

proc add_wave_instruction_cache { } {
    orca_add_wave_instruction_cache "add wave" "add wave -divider" /orca_system/the_vectorblox_orca
}

proc add_wave_data_cache { } {
    orca_add_wave_data_cache "add wave" "add wave -divider" /orca_system/the_vectorblox_orca
}

proc add_wave_instruction_fetch { } {
    orca_add_wave_instruction_fetch "add wave" "add wave -divider" /orca_system/the_vectorblox_orca
}

proc add_wave_syscall { } {
    orca_add_wave_syscall "add wave" "add wave -divider" /orca_system/the_vectorblox_orca
}

proc add_wave_lsu { } {
    orca_add_wave_lsu "add wave" "add wave -divider" /orca_system/the_vectorblox_orca
}

proc add_wave_execute { } {
    orca_add_wave_execute "add wave" "add wave -divider" /orca_system/the_vectorblox_orca
}

proc add_wave_alu { } {
    orca_add_wave_alu "add wave" "add wave -divider" /orca_system/the_vectorblox_orca
}

proc add_wave_branch { } {
    orca_add_wave_branch "add wave" "add wave -divider" /orca_system/the_vectorblox_orca
}

proc add_wave_decode { } {
    orca_add_wave_decode "add wave" "add wave -divider" /orca_system/the_vectorblox_orca
}

proc add_wave_all { } {
    orca_add_wave_all "add wave" "add wave -divider" /orca_system/the_vectorblox_orca
}
