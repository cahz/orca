#Should be run from the system_$system_name/simulation/mentor dir after msim_setup is loaded

do msim_setup.tcl
ld

proc run_tests { system_name tests } {
    set files {}
    foreach test $tests {lappend files "../../../test/$test.qex"}

    set max_length  0
    foreach f $files {
        set len [string length $f ]
        if { $len > $max_length } {
            set max_length $len
        }
    }

    add wave /system_[set system_name]/vectorblox_orca_0/core/D/the_register_file/t3
    foreach f $files {
        file copy -force $f test.hex
        restart -f
        onbreak { resume }
        when " system_[set system_name]/vectorblox_orca_0/core/X/to_execute_instruction(31:0) == x\"00000073\" && system_[set system_name]/vectorblox_orca_0/core/X/to_execute_valid == \"1\" " { stop }

        if { [string match "*dhrystone*" $f ] } {
            #Dhrystone does multiple runs to at least 100us
            run 500 us
        } elseif { [string match "rv32*.elf*" $f ] } {
            run 30 us
        } else {
            #some of the unit tests may have to run for a much longer time
            run 60 us
        }
        set instruction [examine -radix hex system_[set system_name]/vectorblox_orca_0/core/X/to_execute_instruction(31:0)]
        set valid       [examine system_[set system_name]/vectorblox_orca_0/core/X/to_execute_valid]
        if { ($instruction != "00000073") || ($valid != "1") } {
            set validString "valid"
            if { $valid != "1" } {
                set validString "invalid"
            }
            puts [format "%-${max_length}s = Error  FAIL  Instruction $instruction %s" $f $validString ]
        } else {
            set returnValue [examine -radix decimal /system_[set system_name]/vectorblox_orca_0/core/D/the_register_file/t3]
            set passfail  ""
            if { $returnValue != 1 } {
                if { [string match "*dhrystone*" $f ] } {
                    set passfail "MIPS@100MHz"
                } else {
                    set passfail "FAIL"
                }
            }
            puts [format "%-${max_length}s = %-6d %s" $f $returnValue $passfail ]
        }
    }

    exit -f;
}
