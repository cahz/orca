#Connect
connect

#Reset the PS
target -set -filter {name =~ "APU"}
catch { stop } error
rst

#Initialize processing system
#Normally this is ps7_init.tcl
source [lindex $argv 1]
ps7_init
ps7_post_config

#Program the bitstream
target -set -filter {name =~ "xc7z*"}
fpga [lindex $argv 0]
