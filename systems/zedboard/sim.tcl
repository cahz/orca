add_wave {{/design_1_wrapper/design_1_i/Orca_0/U0/core/X/clk}} {{/design_1_wrapper/design_1_i/Orca_0/U0/core/X/reset}} {{/design_1_wrapper/design_1_i/Orca_0/U0/core/X/valid_input}} {{/design_1_wrapper/design_1_i/Orca_0/U0/core/X/pc_current}} {{/design_1_wrapper/design_1_i/Orca_0/U0/core/X/instruction}} 

#add_wave {{/design_1_wrapper/design_1_i/Orca_0/U0/axi_enabled/instruction_cache/dram_ARADDR}} {{/design_1_wrapper/design_1_i/Orca_0/U0/axi_enabled/instruction_cache/dram_ARVALID}} {{/design_1_wrapper/design_1_i/Orca_0/U0/axi_enabled/instruction_cache/dram_ARREADY}} {{/design_1_wrapper/design_1_i/Orca_0/U0/axi_enabled/instruction_cache/dram_RDATA}} {{/design_1_wrapper/design_1_i/Orca_0/U0/axi_enabled/instruction_cache/dram_RVALID}} {{/design_1_wrapper/design_1_i/Orca_0/U0/axi_enabled/instruction_cache/dram_RREADY}} {{/design_1_wrapper/design_1_i/Orca_0/U0/axi_enabled/instruction_cache/state}}

add_wave {{/design_1_wrapper/design_1_i/Orca_0/U0/core/X/syscall/external_interrupts}} 
add_wave {{/design_1_wrapper/design_1_i/Orca_0/U0/core/X/syscall/interrupt_pending}} 
add_wave {{/design_1_wrapper/design_1_i/Orca_0/U0/core/X/syscall/interrupt_processor}} 
add_wave {{/design_1_wrapper/design_1_i/Orca_0/U0/core/X/syscall/mstatus}} 
add_wave {{/design_1_wrapper/design_1_i/Orca_0/U0/core/X/syscall/mie}} 
add_wave {{/design_1_wrapper/design_1_i/Orca_0/U0/core/X/syscall/meimask}} 
add_wave {{/design_1_wrapper/design_1_i/Orca_0/U0/core/X/syscall/meipend}} 
add_wave {{/design_1_wrapper/design_1_i/Orca_0/U0/core/X/syscall/pipeline_empty}} 
add_wave {{/design_1_wrapper/design_1_i/Orca_0/U0/core/X/syscall/csr_write_val}} 
add_wave {{/design_1_wrapper/design_1_i/Orca_0/U0/core/X/syscall/instruction}} 
add_wave {{/design_1_wrapper/design_1_i/fit_timer_0/U0/Interrupt}} 
add_wave {{/design_1_wrapper/design_1_i/edge_extender_0/U0/interrupt_in}} {{/design_1_wrapper/design_1_i/edge_extender_0/U0/interrupt_out}} 
add_wave {{/design_1_wrapper/design_1_i/edge_extender_0/U0/register_bank}} 
add_wave {{/design_1_wrapper/design_1_i/edge_extender_0/U0/reset}} 

restart
log_wave -r *
run 1 ps

set coe_file [open "software/test.coe" r]
set coe_data [read $coe_file]
close $coe_file

set i 0
set data [split $coe_data "\n"]
foreach line $data {
  set words [regexp -all -inline {\S+} $line]
  #puts $words
  foreach word $words {
    set byte0 ""
    append byte0 [string index $word 6]
    append byte0 [string index $word 7]
    #puts $byte0
    set_value "/design_1_wrapper/design_1_i/idram_0/U0/ram/\\idram_gen(0)\\/bram/ram[$i]" -radix hex $byte0 
    set byte1 ""
    append byte1 [string index $word 4]
    append byte1 [string index $word 5]
    #puts $byte1
    set_value "/design_1_wrapper/design_1_i/idram_0/U0/ram/\\idram_gen(1)\\/bram/ram[$i]" -radix hex $byte1
    set byte2 ""
    append byte2 [string index $word 2]
    append byte2 [string index $word 3]
    #puts $byte2
    set_value "/design_1_wrapper/design_1_i/idram_0/U0/ram/\\idram_gen(2)\\/bram/ram[$i]" -radix hex $byte2 
    set byte3 "" 
    append byte3 [string index $word 0]
    append byte3 [string index $word 1]
    #puts $byte3
    set_value "/design_1_wrapper/design_1_i/idram_0/U0/ram/\\idram_gen(3)\\/bram/ram[$i]" -radix hex $byte3 
    set i [expr {$i + 1}]
  }
}
