#
# Orca "Orca" v1.0
#  2015.11.09.13:16:38
#
#

#
# request TCL package from ACDS 15.0
#
package require -exact qsys 15.0


#
# module orca
#
set_module_property DESCRIPTION "Orca, a RISC-V implementation by Vectorblox"
set_module_property NAME "vectorblox_orca"
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property GROUP "Vectorblox/Processors"
set_module_property DISPLAY_NAME "Orca (RISC-V)"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false
set_module_property ELABORATION_CALLBACK elaboration_callback
add_documentation_link "Documentation" https://github.com/VectorBlox/risc-v
#
# file sets
#
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL Orca
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file vblox_orca/utils.vhd VHDL PATH utils.vhd
add_fileset_file vblox_orca/constants_pkg.vhd VHDL PATH constants_pkg.vhd
add_fileset_file vblox_orca/components.vhd VHDL PATH components.vhd
add_fileset_file vblox_orca/alu.vhd VHDL PATH alu.vhd
add_fileset_file vblox_orca/branch_unit.vhd VHDL PATH branch_unit.vhd
add_fileset_file vblox_orca/decode.vhd VHDL PATH decode.vhd
add_fileset_file vblox_orca/execute.vhd VHDL PATH execute.vhd
add_fileset_file vblox_orca/instruction_fetch.vhd VHDL PATH instruction_fetch.vhd
add_fileset_file vblox_orca/load_store_unit.vhd VHDL PATH load_store_unit.vhd
add_fileset_file vblox_orca/register_file.vhd VHDL PATH register_file.vhd
add_fileset_file vblox_orca/orca.vhd VHDL PATH orca.vhd TOP_LEVEL_FILE
add_fileset_file vblox_orca/orca_core.vhd VHDL PATH orca_core.vhd TOP_LEVEL_FILE
add_fileset_file vblox_orca/sys_call.vhd VHDL PATH sys_call.vhd
add_fileset_file vblox_orca/4port_mem.vhd VHDL PATH 4port_mem.vhd
add_fileset_file vblox_orca/lve_top.vhd VHDL PATH lve_top.vhd

add_fileset SIM_VHDL SIM_VHDL "" ""
set_fileset_property SIM_VHDL TOP_LEVEL Orca
set_fileset_property SIM_VHDL ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property SIM_VHDL ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file vblox_orca/utils.vhd VHDL PATH utils.vhd
add_fileset_file vblox_orca/constants_pkg.vhd VHDL PATH constants_pkg.vhd
add_fileset_file vblox_orca/components.vhd VHDL PATH components.vhd
add_fileset_file vblox_orca/alu.vhd VHDL PATH alu.vhd
add_fileset_file vblox_orca/branch_unit.vhd VHDL PATH branch_unit.vhd
add_fileset_file vblox_orca/decode.vhd VHDL PATH decode.vhd
add_fileset_file vblox_orca/execute.vhd VHDL PATH execute.vhd
add_fileset_file vblox_orca/instruction_fetch.vhd VHDL PATH instruction_fetch.vhd
add_fileset_file vblox_orca/load_store_unit.vhd VHDL PATH load_store_unit.vhd
add_fileset_file vblox_orca/register_file.vhd VHDL PATH register_file.vhd
add_fileset_file vblox_orca/orca.vhd VHDL PATH orca.vhd
add_fileset_file vblox_orca/orca_core.vhd VHDL PATH orca_core.vhd
add_fileset_file vblox_orca/sys_call.vhd VHDL PATH sys_call.vhd
add_fileset_file vblox_orca/4port_mem.vhd VHDL PATH 4port_mem.vhd
add_fileset_file vblox_orca/lve_top.vhd VHDL PATH lve_top.vhd


#
# parameters
#
add_parameter REGISTER_SIZE INTEGER 32
set_parameter_property REGISTER_SIZE DEFAULT_VALUE 32
set_parameter_property REGISTER_SIZE DISPLAY_NAME REGISTER_SIZE
set_parameter_property REGISTER_SIZE TYPE INTEGER
set_parameter_property REGISTER_SIZE UNITS None
set_parameter_property REGISTER_SIZE ALLOWED_RANGES {32}
set_parameter_property REGISTER_SIZE HDL_PARAMETER true
set_parameter_property REGISTER_SIZE visible false



add_parameter          BUS_TYPE string Avalon
set_parameter_property BUS_TYPE HDL_PARAMETER false
set_parameter_property BUS_TYPE DISPLAY_NAME "Bus Type"
set_parameter_property BUS_TYPE ALLOWED_RANGES {Axi,Avalon}

add_parameter             AVALON_ENABLE natural 1
set_parameter_property    AVALON_ENABLE ALLOWED_RANGES 0:1
set_parameter_property    AVALON_ENABLE HDL_PARAMETER true
set_parameter_property    AVALON_ENABLE visible false
set_parameter_property    AVALON_ENABLE derived true

add_parameter             AXI_ENABLE natural 1
set_parameter_property    AXI_ENABLE ALLOWED_RANGES 0:1
set_parameter_property    AXI_ENABLE HDL_PARAMETER true
set_parameter_property    AXI_ENABLE visible false
set_parameter_property    AXI_ENABLE derived true

add_parameter LVE_ENABLE natural 0
set_parameter_property LVE_ENABLE DEFAULT_VALUE 0
set_parameter_property LVE_ENABLE DISPLAY_NAME "Vector Extensions"
set_parameter_property LVE_ENABLE DESCRIPTION "Enable Vector Extensions"
set_parameter_property LVE_ENABLE TYPE NATURAL
set_parameter_property LVE_ENABLE UNITS None
set_parameter_property LVE_ENABLE ALLOWED_RANGES 0:1
set_parameter_property LVE_ENABLE HDL_PARAMETER true
set_display_item_property LVE_ENABLE DISPLAY_HINT boolean

add_parameter  SCRATCHPAD_SIZE integer 1024
set_parameter_property SCRATCHPAD_SIZE DISPLAY_NAME "        Scratchpad size"
set_parameter_property SCRATCHPAD_SIZE DESCRIPTION "Enable Vector Extensions"
set_parameter_property SCRATCHPAD_SIZE UNITS Bytes
set_parameter_property SCRATCHPAD_SIZE HDL_PARAMETER true
set_parameter_property SCRATCHPAD_SIZE visible false



add_parameter RESET_VECTOR NATURAL 512
set_parameter_property RESET_VECTOR DISPLAY_NAME "Reset Vector"
set_parameter_property RESET_VECTOR TYPE integer
set_parameter_property RESET_VECTOR UNITS None
set_parameter_property RESET_VECTOR HDL_PARAMETER true
set_display_item_property RESET_VECTOR DISPLAY_HINT hexadecimal

add_parameter MULTIPLY_ENABLE natural 0
set_parameter_property MULTIPLY_ENABLE DEFAULT_VALUE 0
set_parameter_property MULTIPLY_ENABLE DISPLAY_NAME "Hardware Multiply"
set_parameter_property MULTIPLY_ENABLE DESCRIPTION "Enable Multiplier, uses around 100 LUT4s, Shift instruction use the multiplier, 2 cycle operation"
set_parameter_property MULTIPLY_ENABLE TYPE NATURAL
set_parameter_property MULTIPLY_ENABLE UNITS None
set_parameter_property MULTIPLY_ENABLE ALLOWED_RANGES 0:1
set_parameter_property MULTIPLY_ENABLE HDL_PARAMETER true
set_display_item_property MULTIPLY_ENABLE DISPLAY_HINT boolean

add_parameter DIVIDE_ENABLE natural 0
set_parameter_property DIVIDE_ENABLE DEFAULT_VALUE 0
set_parameter_property DIVIDE_ENABLE DISPLAY_NAME "Hardware Divide"
set_parameter_property DIVIDE_ENABLE DESCRIPTION "Enable Divider, uses around 400 LUT4s, 35 cycle operation"
set_parameter_property DIVIDE_ENABLE TYPE NATURAL
set_parameter_property DIVIDE_ENABLE UNITS None
set_parameter_property DIVIDE_ENABLE ALLOWED_RANGES 0:1
set_parameter_property DIVIDE_ENABLE HDL_PARAMETER true
set_display_item_property DIVIDE_ENABLE DISPLAY_HINT boolean

add_parameter SHIFTER_MAX_CYCLES natural 32
set_parameter_property SHIFTER_MAX_CYCLES DISPLAY_NAME "Shifter Max Cycles"
set_parameter_property SHIFTER_MAX_CYCLES TYPE NATURAL
set_parameter_property SHIFTER_MAX_CYCLES UNITS Cycles
set_parameter_property SHIFTER_MAX_CYCLES ALLOWED_RANGES {1 8 32}
set_parameter_property SHIFTER_MAX_CYCLES HDL_PARAMETER true


add_parameter ENABLE_EXCEPTIONS natural 1
set_parameter_property ENABLE_EXCEPTIONS DISPLAY_NAME "Enable Excecptions"
set_parameter_property ENABLE_EXCEPTIONS DESCRIPTION "Enable handling of illegal instructions, external interrupts, and timer interrupts (Recommended)"
set_parameter_property ENABLE_EXCEPTIONS TYPE NATURAL
set_parameter_property ENABLE_EXCEPTIONS UNITS None
set_parameter_property ENABLE_EXCEPTIONS ALLOWED_RANGES 0:1
set_parameter_property ENABLE_EXCEPTIONS HDL_PARAMETER true
set_display_item_property ENABLE_EXCEPTIONS DISPLAY_HINT boolean

add_parameter          EXT_INTERRUPTS integer 1
set_parameter_property EXT_INTERRUPTS HDL_PARAMETER false
set_parameter_property EXT_INTERRUPTS DISPLAY_NAME "       External Interruptes"
set_parameter_property EXT_INTERRUPTS DESCRIPTION "The number of connected external interrupts (minimum 2, maximum 32)."
set_parameter_property EXT_INTERRUPTS ALLOWED_RANGES {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,32}

add_parameter          NUM_EXT_INTERRUPTS integer 1
set_parameter_property NUM_EXT_INTERRUPTS HDL_PARAMETER true
set_parameter_property NUM_EXT_INTERRUPTS ALLOWED_RANGES 1:32
set_parameter_property NUM_EXT_INTERRUPTS visible false
set_parameter_property NUM_EXT_INTERRUPTS derived true

add_parameter          ENABLE_EXT_INTERRUPTS natural 1
set_parameter_property ENABLE_EXT_INTERRUPTS HDL_PARAMETER true
set_parameter_property ENABLE_EXT_INTERRUPTS ALLOWED_RANGES 0:1
set_parameter_property ENABLE_EXT_INTERRUPTS visible false
set_parameter_property ENABLE_EXT_INTERRUPTS derived true


add_parameter COUNTER_LENGTH natural 64
set_parameter_property COUNTER_LENGTH DISPLAY_NAME "Counters Register Size"
set_parameter_property COUNTER_LENGTH DESCRIPTION "\
rdcycle and rdinstret size. If this is set to zero those \
instructions throw unimplemented exception"
set_parameter_property COUNTER_LENGTH TYPE NATURAL
set_parameter_property COUNTER_LENGTH UNITS None
set_parameter_property COUNTER_LENGTH ALLOWED_RANGES {0 32 64}
set_parameter_property COUNTER_LENGTH HDL_PARAMETER true
set_display_item_property COUNTER_LENGTH DISPLAY_HINT boolean

add_parameter          BRANCH_PREDICTORS natural 0
set_parameter_property BRANCH_PREDICTORS DEFAULT_VALUE 1
set_parameter_property BRANCH_PREDICTORS TYPE NATURAL
set_parameter_property BRANCH_PREDICTORS UNITS None
set_parameter_property BRANCH_PREDICTORS HDL_PARAMETER true
set_parameter_property BRANCH_PREDICTORS visible false
set_parameter_property BRANCH_PREDICTORS derived true

add_parameter          BRANCH_PREDICTION boolean false
set_parameter_property BRANCH_PREDICTION HDL_PARAMETER false
set_parameter_property BRANCH_PREDICTION DISPLAY_NAME "Branch Prediction"

add_parameter          BTB_SIZE natural
set_parameter_property BTB_SIZE HDL_PARAMETER false
set_parameter_property BTB_SIZE DISPLAY_NAME "        Branch Target Buffer Size"
set_parameter_property BTB_SIZE DISPLAY_UNITS entries
set_parameter_property BTB_SIZE visible false

add_parameter          PIPELINE_STAGES natural 4
set_parameter_property PIPELINE_STAGES HDL_PARAMETER true
set_parameter_property PIPELINE_STAGES DISPLAY_NAME "Pipeline Stages"
set_parameter_property PIPELINE_STAGES DESCRIPTION "Choose the number of pipeline stages, 3 stages is smaller\
but 4 stages has a higher fmax"
set_parameter_property PIPELINE_STAGES ALLOWED_RANGES {4,5}



#
# display items
#

#
# connection point clock
#
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock clk clk Input 1

add_interface scratchpad_clk clock end
set_interface_property scratchpad_clk clockRate 0
#set_interface_property scratchpad_clk ENABLED true
set_interface_property scratchpad_clk EXPORT_OF ""
set_interface_property scratchpad_clk PORT_NAME_MAP ""
set_interface_property scratchpad_clk CMSIS_SVD_VARIABLES ""
set_interface_property scratchpad_clk SVD_ADDRESS_GROUP ""

add_interface_port scratchpad_clk scratchpad_clk clk Input 1



#
# connection point reset
#
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset reset reset Input 1


#
# connection point data
#
add_interface data avalon start
set_interface_property data addressUnits SYMBOLS
set_interface_property data associatedClock clock
set_interface_property data associatedReset reset
set_interface_property data bitsPerSymbol 8
set_interface_property data burstOnBurstBoundariesOnly false
set_interface_property data burstcountUnits WORDS
set_interface_property data doStreamReads false
set_interface_property data doStreamWrites false
set_interface_property data holdTime 0
set_interface_property data linewrapBursts false
set_interface_property data maximumPendingReadTransactions 0
set_interface_property data maximumPendingWriteTransactions 0
set_interface_property data readLatency 0
set_interface_property data readWaitTime 1
set_interface_property data setupTime 0
set_interface_property data timingUnits Cycles
set_interface_property data writeWaitTime 0
set_interface_property data ENABLED true
set_interface_property data EXPORT_OF ""
set_interface_property data PORT_NAME_MAP ""
set_interface_property data CMSIS_SVD_VARIABLES ""
set_interface_property data SVD_ADDRESS_GROUP ""

add_interface_port data avm_data_address address Output register_size
add_interface_port data avm_data_byteenable byteenable Output register_size/8
add_interface_port data avm_data_read read Output 1
add_interface_port data avm_data_readdata readdata Input register_size
add_interface_port data avm_data_write write Output 1
add_interface_port data avm_data_writedata writedata Output register_size
add_interface_port data avm_data_waitrequest waitrequest Input 1
add_interface_port data avm_data_readdatavalid readdatavalid Input 1


#
# Data Axi Port
#
add_interface axi_data_master axi start
set_interface_property axi_data_master associatedClock clock
set_interface_property axi_data_master associatedReset reset
set_interface_property axi_data_master readIssuingCapability 1
set_interface_property axi_data_master writeIssuingCapability 1
set_interface_property axi_data_master combinedIssuingCapability 1
set_interface_property axi_data_master ENABLED true
set_interface_property axi_data_master EXPORT_OF ""
set_interface_property axi_data_master PORT_NAME_MAP ""
set_interface_property axi_data_master CMSIS_SVD_VARIABLES ""
set_interface_property axi_data_master SVD_ADDRESS_GROUP ""

add_interface_port axi_data_master data_ARADDR araddr Output register_size
add_interface_port axi_data_master data_ARBURST arburst Output 2
add_interface_port axi_data_master data_ARCACHE arcache Output 4
add_interface_port axi_data_master data_ARID arid Output 4
add_interface_port axi_data_master data_ARLEN arlen Output 4
add_interface_port axi_data_master data_ARLOCK arlock Output 2
add_interface_port axi_data_master data_ARPROT arprot Output 3
add_interface_port axi_data_master data_ARREADY arready Input 1
add_interface_port axi_data_master data_ARSIZE arsize Output 3
add_interface_port axi_data_master data_ARVALID arvalid Output 1
add_interface_port axi_data_master data_AWADDR awaddr Output register_size
add_interface_port axi_data_master data_AWBURST awburst Output 2
add_interface_port axi_data_master data_AWCACHE awcache Output 4
add_interface_port axi_data_master data_AWID awid Output 4
add_interface_port axi_data_master data_AWLEN awlen Output 4
add_interface_port axi_data_master data_AWLOCK awlock Output 2
add_interface_port axi_data_master data_AWPROT awprot Output 3
add_interface_port axi_data_master data_AWREADY awready Input 1
add_interface_port axi_data_master data_AWSIZE awsize Output 3
add_interface_port axi_data_master data_AWVALID awvalid Output 1
add_interface_port axi_data_master data_BID bid Input 4
add_interface_port axi_data_master data_BREADY bready Output 1
add_interface_port axi_data_master data_BRESP bresp Input 2
add_interface_port axi_data_master data_BVALID bvalid Input 1
add_interface_port axi_data_master data_RDATA rdata Input register_size
add_interface_port axi_data_master data_RID rid Input 4
add_interface_port axi_data_master data_RLAST rlast Input 1
add_interface_port axi_data_master data_RREADY rready Output 1
add_interface_port axi_data_master data_RRESP rresp Input 2
add_interface_port axi_data_master data_RVALID rvalid Input 1
add_interface_port axi_data_master data_WDATA wdata Output register_size
add_interface_port axi_data_master data_WID wid Output 4
add_interface_port axi_data_master data_WLAST wlast Output 1
add_interface_port axi_data_master data_WREADY wready Input 1
add_interface_port axi_data_master data_WSTRB wstrb Output register_size/8
add_interface_port axi_data_master data_WVALID wvalid Output 1


#
# Data Axi Port
#
add_interface axi_instr_master axi start
set_interface_property axi_instr_master associatedClock clock
set_interface_property axi_instr_master associatedReset reset
set_interface_property axi_instr_master readIssuingCapability 1
set_interface_property axi_instr_master writeIssuingCapability 1
set_interface_property axi_instr_master combinedIssuingCapability 1
set_interface_property axi_instr_master ENABLED true
set_interface_property axi_instr_master EXPORT_OF ""
set_interface_property axi_instr_master PORT_NAME_MAP ""
set_interface_property axi_instr_master CMSIS_SVD_VARIABLES ""
set_interface_property axi_instr_master SVD_ADDRESS_GROUP ""

add_interface_port axi_instr_master instr_ARADDR araddr Output register_size
add_interface_port axi_instr_master instr_ARBURST arburst Output 2
add_interface_port axi_instr_master instr_ARCACHE arcache Output 4
add_interface_port axi_instr_master instr_ARID arid Output 4
add_interface_port axi_instr_master instr_ARLEN arlen Output 4
add_interface_port axi_instr_master instr_ARLOCK arlock Output 2
add_interface_port axi_instr_master instr_ARPROT arprot Output 3
add_interface_port axi_instr_master instr_ARREADY arready Input 1
add_interface_port axi_instr_master instr_ARSIZE arsize Output 3
add_interface_port axi_instr_master instr_ARVALID arvalid Output 1
add_interface_port axi_instr_master instr_AWADDR awaddr Output register_size
add_interface_port axi_instr_master instr_AWBURST awburst Output 2
add_interface_port axi_instr_master instr_AWCACHE awcache Output 4
add_interface_port axi_instr_master instr_AWID awid Output 4
add_interface_port axi_instr_master instr_AWLEN awlen Output 4
add_interface_port axi_instr_master instr_AWLOCK awlock Output 2
add_interface_port axi_instr_master instr_AWPROT awprot Output 3
add_interface_port axi_instr_master instr_AWREADY awready Input 1
add_interface_port axi_instr_master instr_AWSIZE awsize Output 3
add_interface_port axi_instr_master instr_AWVALID awvalid Output 1
add_interface_port axi_instr_master instr_BID bid Input 4
add_interface_port axi_instr_master instr_BREADY bready Output 1
add_interface_port axi_instr_master instr_BRESP bresp Input 2
add_interface_port axi_instr_master instr_BVALID bvalid Input 1
add_interface_port axi_instr_master instr_RDATA rdata Input register_size
add_interface_port axi_instr_master instr_RID rid Input 4
add_interface_port axi_instr_master instr_RLAST rlast Input 1
add_interface_port axi_instr_master instr_RREADY rready Output 1
add_interface_port axi_instr_master instr_RRESP rresp Input 2
add_interface_port axi_instr_master instr_RVALID rvalid Input 1
add_interface_port axi_instr_master instr_WDATA wdata Output register_size
add_interface_port axi_instr_master instr_WID wid Output 4
add_interface_port axi_instr_master instr_WLAST wlast Output 1
add_interface_port axi_instr_master instr_WREADY wready Input 1
add_interface_port axi_instr_master instr_WSTRB wstrb Output register_size/8
add_interface_port axi_instr_master instr_WVALID wvalid Output 1

#
# connection point instruction
#
add_interface instruction avalon start
set_interface_property instruction addressUnits SYMBOLS
set_interface_property instruction associatedClock clock
set_interface_property instruction associatedReset reset
set_interface_property instruction bitsPerSymbol 8
set_interface_property instruction burstOnBurstBoundariesOnly false
set_interface_property instruction burstcountUnits WORDS
set_interface_property instruction doStreamReads false
set_interface_property instruction doStreamWrites false
set_interface_property instruction holdTime 0
set_interface_property instruction linewrapBursts false
set_interface_property instruction maximumPendingReadTransactions 0
set_interface_property instruction maximumPendingWriteTransactions 0
set_interface_property instruction readLatency 0
set_interface_property instruction readWaitTime 1
set_interface_property instruction setupTime 0
set_interface_property instruction timingUnits Cycles
set_interface_property instruction writeWaitTime 0
set_interface_property instruction ENABLED true
set_interface_property instruction EXPORT_OF ""
set_interface_property instruction PORT_NAME_MAP ""
set_interface_property instruction CMSIS_SVD_VARIABLES ""
set_interface_property instruction SVD_ADDRESS_GROUP ""

add_interface_port instruction avm_instruction_address address Output register_size
add_interface_port instruction avm_instruction_read read Output 1
add_interface_port instruction avm_instruction_readdata readdata Input register_size
add_interface_port instruction avm_instruction_waitrequest waitrequest Input 1
add_interface_port instruction avm_instruction_readdatavalid readdatavalid Input 1

#
# connection point global_interrupts
#

add_interface global_interrupts conduit end
set_interface_property global_interrupts associatedClock ""
set_interface_property global_interrupts associatedReset ""
set_interface_property global_interrupts ENABLED true
set_interface_property global_interrupts EXPORT_OF ""
set_interface_property global_interrupts PORT_NAME_MAP ""
set_interface_property global_interrupts CMSIS_SVD_VARIABLES ""
set_interface_property global_interrupts SVD_ADDRESS_GROUP ""

add_interface_port global_interrupts global_interrupts export Input NUM_EXT_INTERRUPTS

#
# connection point wishbone bus (disabled)
#
add_interface unused_wishbone_bus conduit end
set_interface_property unused_wishbone_bus associatedClock ""
set_interface_property unused_wishbone_bus associatedReset ""
set_interface_property unused_wishbone_bus ENABLED false
set_interface_property unused_wishbone_bus EXPORT_OF ""
set_interface_property unused_wishbone_bus PORT_NAME_MAP ""
set_interface_property unused_wishbone_bus CMSIS_SVD_VARIABLES ""
set_interface_property unused_wishbone_bus SVD_ADDRESS_GROUP ""

add_interface_port unused_wishbone_bus       data_ADR_O     export0     output REGISTER_SIZE
add_interface_port unused_wishbone_bus       data_DAT_I     export1      input  REGISTER_SIZE
add_interface_port unused_wishbone_bus       data_DAT_O     export2     output REGISTER_SIZE
add_interface_port unused_wishbone_bus       data_WE_O      export3     output 1
add_interface_port unused_wishbone_bus       data_SEL_O     export4    output REGISTER_SIZE/8
add_interface_port unused_wishbone_bus       data_STB_O     export5     output 1
add_interface_port unused_wishbone_bus       data_ACK_I     export6      input 1
add_interface_port unused_wishbone_bus       data_CYC_O     export7     output 1
add_interface_port unused_wishbone_bus       data_CTI_O     export8     output 3
add_interface_port unused_wishbone_bus       data_STALL_I   export9      input 1
add_interface_port unused_wishbone_bus       instr_ADR_O    export10     output REGISTER_SIZE
add_interface_port unused_wishbone_bus       instr_DAT_I    export11      input REGISTER_SIZE
add_interface_port unused_wishbone_bus       instr_STB_O    export12     output 1
add_interface_port unused_wishbone_bus       instr_ACK_I    export13      input 1
add_interface_port unused_wishbone_bus       instr_CYC_O    export14     output 1
add_interface_port unused_wishbone_bus       instr_CTI_O    export15     output 3
add_interface_port unused_wishbone_bus       instr_STALL_I  export16      input 1



proc log_out {out_str} {
        set chan [open ~/orca_hw_log.txt a]
        set timestamp [clock format [clock seconds]]
        puts $chan "$timestamp $out_str"
        close $chan
}

proc elaboration_callback {} {
	 if { [get_parameter_value MULTIPLY_ENABLE] } {
		  set_display_item_property SHIFTER_MAX_CYCLES ENABLED false
	 } else {
		  set_display_item_property SHIFTER_MAX_CYCLES ENABLED true
	 }

	 if { [get_parameter_value LVE_ENABLE] } {

		  set_interface_property scratchpad_clk ENABLED true
		  set_parameter_property SCRATCHPAD_SIZE visible true
	 } else {
		  set_interface_property scratchpad_clk ENABLED false
		  set_parameter_property SCRATCHPAD_SIZE visible false
	 }

	 set table_size 0
	 if { [get_parameter_value BRANCH_PREDICTION] } {
		  set_parameter_property BTB_SIZE visible true
		  set table_size [get_parameter_value BTB_SIZE ]
	 } else {
	  set_parameter_property BTB_SIZE visible false
	 }

	 if { [get_parameter_value ENABLE_EXCEPTIONS] } {
		  set_parameter_property EXT_INTERRUPTS visible true
		  if { [ get_parameter_value EXT_INTERRUPTS ] > 0 } {
				set_interface_property global_interrupts enabled true
				set_parameter_value ENABLE_EXT_INTERRUPTS 1
				set_parameter_value NUM_EXT_INTERRUPTS [ get_parameter_value EXT_INTERRUPTS ]

	     } else {
				set_interface_property global_interrupts enabled false
				set_parameter_value ENABLE_EXT_INTERRUPTS 0
				set_parameter_value NUM_EXT_INTERRUPTS 1
		  }
	 } else {
		  set_parameter_property EXT_INTERRUPTS visible false
		  set_interface_property global_interrupts enabled false
		  set_parameter_value ENABLE_EXT_INTERRUPTS 0
		  set_parameter_value NUM_EXT_INTERRUPTS 1
	 }
	 set count 0
	 for {set i 0} {$i<32} {incr i} {
		  if { $table_size & [expr 1<< $i ] } {
				set count [expr $count + 1]
		  }
	 }
	 if { $count > 1 } {
		  send_message Error "BTB_SIZE is not a power of two"
	 }
	 set_parameter_value BRANCH_PREDICTORS $table_size

	 if {  [get_parameter_value BUS_TYPE ] == "Axi" } {
		  set axi_bus true
		  set avalon_bus false
	 } else {
		  set axi_bus false
		  set avalon_bus true
	 }


	 set_parameter_value AXI_ENABLE   $axi_bus
	 set_parameter_value AVALON_ENABLE  $avalon_bus

	 set_interface_property axi_instr_master ENABLED $axi_bus
	 set_interface_property axi_data_master ENABLED $axi_bus

	 set_interface_property data ENABLED $avalon_bus
	 set_interface_property instruction ENABLED $avalon_bus

}
