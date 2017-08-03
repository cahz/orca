set inc_interrupt      /system_tb/system_inst/vectorblox_orca_0/X/syscall/mip_meip_i
set ext_interrupt      /system_tb/system_inst/vectorblox_orca_0/interrupt_controller/mip_meip_o
set instruction        /system_tb/system_inst/vectorblox_orca_0/X/instruction
set valid_instr        /system_tb/system_inst/vectorblox_orca_0/X/valid_instr
set clk                /system_tb/system_inst/vectorblox_orca_0/clk
set reset              /system_tb/system_inst/vectorblox_orca_0/reset
set pc                 /system_tb/system_inst/vectorblox_orca_0/X/pc_current
set mepc               /system_tb/system_inst/vectorblox_orca_0/X/syscall/mepc
set mip_meip           /system_tb/system_inst/vectorblox_orca_0/X/syscall/mip_meip
set br_bad_predict     /system_tb/system_inst/vectorblox_orca_0/X/syscall/br_bad_predict
set br_bad_predict_reg /system_tb/system_inst/vectorblox_orca_0/X/syscall/br_bad_predict_reg
set br_new_pc_reg      /system_tb/system_inst/vectorblox_orca_0/X/syscall/br_new_pc_reg


proc clock_cycle {} {
  global step
  global clk

  run $step
  force -freeze $clk 1 
  run $step
  force -freeze $clk 0 
}

proc interruptSim {} {
  global step

  global ext_interrupt
  global reset
  global clk
  global instruction
  global valid_instr

# Reset for 50 ns.
  force -freeze $ext_interrupt 0 
  force -freeze $reset         1 
  force -freeze $clk           0 

  for {set i 0} {$i < 80} {incr i} {
    clock_cycle
  }

  force -freeze $reset 0 

# Interrupt with 0 cycle delay after a branch instruction.
  while {[examine -expr {$instruction != 32'h0000006f}] || [examine -expr {$valid_instr != 1}]} {
    clock_cycle 
  }
  echo "Done loop 0."
  force -freeze $ext_interrupt 1
  examine $ext_interrupt
# Upon reading mcause register, clear the interrupt.
  while {[examine -expr {$instruction != 32'h34202573}] || [examine -expr {$valid_instr != 1}]} {
    clock_cycle
  }
  echo "Clearing interrupt 0."
  force -freeze $ext_interrupt 0

# Interrupt with a 1 cycle delay after a branch instruction.
  while {[examine -expr {$instruction != 32'h0000006f}] || [examine -expr {$valid_instr != 1}]} {
    clock_cycle 
  }
# Delay 1 clock cycle.
  echo "Done loop 1."
  clock_cycle
  force -freeze $ext_interrupt 1
# Upon reading mcause register, clear the interrupt.
  while {[examine -expr {$instruction != 32'h34202573}] || [examine -expr {$valid_instr != 1}]} {
    clock_cycle
  }
  echo "Clearing interrupt 1."
  force -freeze $ext_interrupt 0

# Interrupt with a 2 cycle delay after a branch instruction.
  while {[examine -expr {$instruction != 32'h0000006f}] || [examine -expr {$valid_instr != 1}]} {
    clock_cycle 
  }
# Delay 2 clock cycles.
  echo "Done loop 2."
  clock_cycle
  clock_cycle
  force -freeze $ext_interrupt 1
# Upon reading mcause register, clear the interrupt.
  while {[examine -expr {$instruction != 32'h34202573}] || [examine -expr {$valid_instr != 1}]} {
    clock_cycle
  }
  echo "Clearing interrupt 2."
  force -freeze $ext_interrupt 0

# Interrupt with a 3 cycle delay after a branch instruction.
  while {[examine -expr {$instruction != 32'h0000006f}] || [examine -expr {$valid_instr != 1}]} {
    clock_cycle 
  }
# Delay 3 clock cycles.
  echo "Done loop 3."
  clock_cycle
  clock_cycle
  clock_cycle
  force -freeze $ext_interrupt 1
# Upon reading mcause register, clear the interrupt.
  while {[examine -expr {$instruction != 32'h34202573}] || [examine -expr {$valid_instr != 1}]} {
    clock_cycle
  }
  echo "Clearing interrupt 3."
  force -freeze $ext_interrupt 0

# Wait for interrupt handler to be done.
  while {[examine -expr {$instruction != 32'h0000006f}] || [examine -expr {$valid_instr != 1}]} {
    clock_cycle 
  }

  puts "Interrupt Branch Test Passed."

}


cd system/testbench/mentor/
do msim_setup.tcl
ld

add wave -position insertpoint $reset
add wave -position insertpoint $clk
add wave -position insertpoint $ext_interrupt
add wave -position insertpoint $inc_interrupt
add wave -position insertpoint $pc
add wave -position insertpoint $instruction
add wave -position insertpoint $valid_instr

file copy -force ../../../test/interrupt_branch_test.qex test.hex
restart -f
log -r *

set step 1

interruptSim
