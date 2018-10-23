source ../sim_waves.tcl

proc reset_waves { system_name } {
    catch { delete wave * } error

    add wave -divider "X3"
    add wave /system_[set system_name]/vectorblox_orca_0/core/D/the_register_file/registers(3)

    orca_reset_waves "add wave" "add wave -divider" /system_[set system_name]/vectorblox_orca_0
}


proc add_wave_data_masters { system_name } {
    orca_add_wave_data_masters "add wave" "add wave -divider" /system_[set system_name]/vectorblox_orca_0
}

proc add_wave_instruction_masters { system_name } {
    orca_add_wave_instruction_masters "add wave" "add wave -divider" /system_[set system_name]/vectorblox_orca_0
}

proc add_wave_instruction_cache { system_name } {
    orca_add_wave_instruction_cache "add wave" "add wave -divider" /system_[set system_name]/vectorblox_orca_0
}

proc add_wave_data_cache { system_name } {
    orca_add_wave_data_cache "add wave" "add wave -divider" /system_[set system_name]/vectorblox_orca_0
}

proc add_wave_instruction_fetch { system_name } {
    orca_add_wave_instruction_fetch "add wave" "add wave -divider" /system_[set system_name]/vectorblox_orca_0
}

proc add_wave_syscall { system_name } {
    orca_add_wave_syscall "add wave" "add wave -divider" /system_[set system_name]/vectorblox_orca_0
}

proc add_wave_lsu { system_name } {
    orca_add_wave_lsu "add wave" "add wave -divider" /system_[set system_name]/vectorblox_orca_0
}

proc add_wave_execute { system_name } {
    orca_add_wave_execute "add wave" "add wave -divider" /system_[set system_name]/vectorblox_orca_0
}

proc add_wave_alu { system_name } {
    orca_add_wave_alu "add wave" "add wave -divider" /system_[set system_name]/vectorblox_orca_0
}

proc add_wave_branch { system_name } {
    orca_add_wave_branch "add wave" "add wave -divider" /system_[set system_name]/vectorblox_orca_0
}

proc add_wave_decode { system_name } {
    orca_add_wave_decode "add wave" "add wave -divider" /system_[set system_name]/vectorblox_orca_0
}

proc add_wave_all { system_name } {
    orca_add_wave_all "add wave" "add wave -divider" /system_[set system_name]/vectorblox_orca_0
}
