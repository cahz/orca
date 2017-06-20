open_project [lindex $argv 0][lindex $argv 1].xpr
exec updatemem -force --meminfo [lindex $argv 2] \
  --data [lindex $argv 3] \
  --bit [lindex $argv 4] \
  --proc dummy \
  --out [lindex $argv 5]
close_project
