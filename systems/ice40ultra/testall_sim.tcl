do simulate.tcl

set files [lsort [glob ./test/*.mem]]
add wave /top_tb/dut/rv/core/D/register_file_1/t3

set max_length  0
foreach f $files {
	 set len [string length $f ]
	 if { $len > $max_length } {
		  set max_length $len
	 }
}

foreach f $files {
	 file copy -force $f test.mem
	 exec touch test.mem
	 exec make MEM_FILE=test.mem imem.mem dmem.mem
	 restart -f
	 onbreak {resume}
	 when {/top_tb/dut/rv/core/X/instruction == x"00000073" && /top_tb/dut/rv/core/X/valid_input == "1" } {stop}
	 run 2000 us
	 set v [examine -radix decimal /top_tb/dut/rv/core/D/register_file_1/t3 ]
     set passfail  ""
	 if { $v != 1 } {
		  set passfail "FAIL"
	 }
     puts [format "%-${max_length}s = %-6d %s" $f $v $passfail ]

}

exit -f;
