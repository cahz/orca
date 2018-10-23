#Should be run from the system_$system_name/simulation/mentor dir after msim_setup is loaded

do msim_setup.tcl
ld

proc run_tests { system_name tests } {
    set files {}
    foreach test $tests {lappend files "../../../software/$test.qex"}

    set max_length  0
    foreach f $files {
        set len [string length $f ]
        if { $len > $max_length } {
            set max_length $len
        }
    }

    add wave /system_[set system_name]/vectorblox_orca_0/core/D/the_register_file/registers(3)
    foreach f $files {
        file copy -force $f test.hex
        restart -f
        onbreak { resume }

        when "system_[set system_name]/vectorblox_orca_0/core/X/to_execute_instruction(31:0) == x\"00000073\" && system_[set system_name]/vectorblox_orca_0/core/X/to_execute_valid == \"1\" " {
				#wait until the first cycle after the ecall to stop the simulation
				when   "[set entity]/vectorblox_orca_0/core/X/to_execute_valid = \"0\" " {
					 when   "[set entity]/vectorblox_orca_0/core/X/to_execute_valid = \"1\" " {stop}
				}
		  }

		  if {[string match "*vbx_64*" $f ] || [string match "*interrupt*" $f ] } {
				run 1ps
				#these two tests rely on vcp_enable being 2, if vcp_enable is not 2,
				#force misa(23) to 0 which will make the tests be skipped
				set vcp_enable [examine -radix hex system_[set system_name]/vectorblox_orca_0/VCP_ENABLE]
				if { $vcp_enable != 2 }  {
					 force -freeze system_[set system_name]/vectorblox_orca_0/core/X/syscall/misa(23) 0 0
				}
		  }
        if { [string match "*dhrystone*" $f ] } {
            #Dhrystone does multiple runs to at least 100us
            run 700 us
        } elseif { [string match "rv32*.elf*" $f ] } {
            run 30 us
        } else {
            #some of the unit tests may have to run for a much longer time
            run 200 us
        }
		  nowhen *
        set instruction [examine -radix hex system_[set system_name]/vectorblox_orca_0/core/X/to_execute_instruction(31:0)]
        set valid       [examine system_[set system_name]/vectorblox_orca_0/core/X/to_execute_valid]

		  set returnValue [examine -radix decimal /system_[set system_name]/vectorblox_orca_0/core/D/the_register_file/registers(3)]
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

    exit -f;
}
