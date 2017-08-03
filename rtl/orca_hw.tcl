#
# Orca "Orca" v1.0
#  2015.11.09.13:16:38
#
#

#
# request TCL package from ACDS 15.0
#
package require -exact qsys 15.0

proc log2 { num } {
	 set retval 0
	 while { $num > 1 } {
		  set retval [expr $retval + 1 ]
		  set num [expr $num / 2 ]
	 }
	 return $retval
}
#
# module orca
#
set_module_property DESCRIPTION "Orca, a RISC-V implementation by Vectorblox"
set_module_property NAME "vectorblox_orca"
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR "VectorBlox Computing Inc."
set_module_property GROUP "VectorBlox Computing Inc./Processors"
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
add_fileset_file vblox_orca/lve_top.vhd VHDL PATH lve_top.vhd
add_fileset_file vblox_orca/axi_master.vhd VHDL PATH axi_master.vhd

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
add_fileset_file vblox_orca/lve_top.vhd VHDL PATH lve_top.vhd
add_fileset_file vblox_orca/axi_master.vhd VHDL PATH axi_master.vhd

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

add_parameter BYTE_SIZE INTEGER 8 
set_parameter_property REGISTER_SIZE DEFAULT_VALUE 8 
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

add_parameter          AVALON_ENABLE natural 1
set_parameter_property AVALON_ENABLE ALLOWED_RANGES 0:1
set_parameter_property AVALON_ENABLE HDL_PARAMETER true
set_parameter_property AVALON_ENABLE visible false
set_parameter_property AVALON_ENABLE derived true

add_parameter          AXI_ENABLE natural 0
set_parameter_property AXI_ENABLE ALLOWED_RANGES 0:1
set_parameter_property AXI_ENABLE HDL_PARAMETER true
set_parameter_property AXI_ENABLE visible false
set_parameter_property AXI_ENABLE derived true

add_parameter          WISHBONE_ENABLE natural 0
set_parameter_property WISHBONE_ENABLE ALLOWED_RANGES 0:1
set_parameter_property WISHBONE_ENABLE HDL_PARAMETER true
set_parameter_property WISHBONE_ENABLE visible false
set_parameter_property WISHBONE_ENABLE derived true

add_parameter RESET_VECTOR NATURAL 0 
set_parameter_property RESET_VECTOR DEFAULT_VALUE 0
set_parameter_property RESET_VECTOR DISPLAY_NAME "Reset Vector"
set_parameter_property RESET_VECTOR TYPE integer
set_parameter_property RESET_VECTOR UNITS None
set_parameter_property RESET_VECTOR HDL_PARAMETER true
set_display_item_property RESET_VECTOR DISPLAY_HINT hexadecimal

add_parameter INTERRUPT_VECTOR NATURAL 512
set_parameter_property INTERRUPT_VECTOR DEFAULT_VALUE 512
set_parameter_property INTERRUPT_VECTOR DISPLAY_NAME "Interrupt Vector"
set_parameter_property INTERRUPT_VECTOR TYPE integer
set_parameter_property INTERRUPT_VECTOR UNITS None
set_parameter_property INTERRUPT_VECTOR HDL_PARAMETER true
set_display_item_property INTERRUPT_VECTOR DISPLAY_HINT hexadecimal

add_parameter MULTIPLY_ENABLE natural 1
set_parameter_property MULTIPLY_ENABLE DEFAULT_VALUE 1
set_parameter_property MULTIPLY_ENABLE DISPLAY_NAME "Hardware Multiply"
set_parameter_property MULTIPLY_ENABLE DESCRIPTION "Enable Multiplier, uses around 100 LUT4s, Shift instruction use the multiplier, 2 cycle operation"
set_parameter_property MULTIPLY_ENABLE TYPE NATURAL
set_parameter_property MULTIPLY_ENABLE UNITS None
set_parameter_property MULTIPLY_ENABLE ALLOWED_RANGES 0:1
set_parameter_property MULTIPLY_ENABLE HDL_PARAMETER true
set_display_item_property MULTIPLY_ENABLE DISPLAY_HINT boolean

add_parameter DIVIDE_ENABLE natural 1
set_parameter_property DIVIDE_ENABLE DEFAULT_VALUE 1
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

add_parameter ENABLE_EXCEPTIONS natural 1
set_parameter_property ENABLE_EXCEPTIONS DISPLAY_NAME "Enable Exceptions"
set_parameter_property ENABLE_EXCEPTIONS DESCRIPTION "Enable handling of illegal instructions, external interrupts, and timer interrupts (Recommended)"
set_parameter_property ENABLE_EXCEPTIONS TYPE NATURAL
set_parameter_property ENABLE_EXCEPTIONS UNITS None
set_parameter_property ENABLE_EXCEPTIONS ALLOWED_RANGES 0:1
set_parameter_property ENABLE_EXCEPTIONS HDL_PARAMETER true
set_display_item_property ENABLE_EXCEPTIONS DISPLAY_HINT boolean

add_parameter ENABLE_EXT_INTERRUPTS natural 0
set_parameter_property ENABLE_EXT_INTERRUPTS DISPLAY_NAME "Enable Interrupts"
set_parameter_property ENABLE_EXT_INTERRUPTS DESCRIPTION "Enable handling of external interrupts" 
set_parameter_property ENABLE_EXT_INTERRUPTS TYPE NATURAL
set_parameter_property ENABLE_EXT_INTERRUPTS UNITS None
set_parameter_property ENABLE_EXT_INTERRUPTS ALLOWED_RANGES 0:1
set_parameter_property ENABLE_EXT_INTERRUPTS HDL_PARAMETER true
set_display_item_property ENABLE_EXT_INTERRUPTS DISPLAY_HINT boolean

add_parameter          EXT_INTERRUPTS integer 1
set_parameter_property EXT_INTERRUPTS HDL_PARAMETER false
set_parameter_property EXT_INTERRUPTS DISPLAY_NAME "       External Interrupts"
set_parameter_property EXT_INTERRUPTS DESCRIPTION "The number of connected external interrupts (minimum 2, maximum 32)."
set_parameter_property EXT_INTERRUPTS ALLOWED_RANGES {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,32}

add_parameter          NUM_EXT_INTERRUPTS integer 1
set_parameter_property NUM_EXT_INTERRUPTS HDL_PARAMETER true
set_parameter_property NUM_EXT_INTERRUPTS ALLOWED_RANGES 1:32
set_parameter_property NUM_EXT_INTERRUPTS visible false
set_parameter_property NUM_EXT_INTERRUPTS derived true

add_parameter          BRANCH_PREDICTORS natural 0
set_parameter_property BRANCH_PREDICTORS DEFAULT_VALUE 0
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

add_parameter          PIPELINE_STAGES natural 5
set_parameter_property PIPELINE_STAGES HDL_PARAMETER true
set_parameter_property PIPELINE_STAGES DISPLAY_NAME "Pipeline Stages"
set_parameter_property PIPELINE_STAGES DESCRIPTION "Choose the number of pipeline stages, 4 stages is smaller\
but 5 stages has a higher fmax"
set_parameter_property PIPELINE_STAGES ALLOWED_RANGES {4,5}

add_parameter LVE_ENABLE natural 0
set_parameter_property LVE_ENABLE DEFAULT_VALUE 0
set_parameter_property LVE_ENABLE DISPLAY_NAME "Vector Extensions"
set_parameter_property LVE_ENABLE DESCRIPTION "Enable Vector Extensions"
set_parameter_property LVE_ENABLE TYPE NATURAL
set_parameter_property LVE_ENABLE UNITS None
set_parameter_property LVE_ENABLE ALLOWED_RANGES 0:1
set_parameter_property LVE_ENABLE HDL_PARAMETER true
set_display_item_property LVE_ENABLE DISPLAY_HINT boolean

add_parameter SCRATCHPAD_SIZE integer 64
set_parameter_property SCRATCHPAD_SIZE DISPLAY_NAME "        Scratchpad size"
set_parameter_property SCRATCHPAD_SIZE DESCRIPTION "        Scratchpad size"
set_parameter_property SCRATCHPAD_SIZE UNITS kilobytes
set_parameter_property SCRATCHPAD_SIZE HDL_PARAMETER false
set_parameter_property SCRATCHPAD_SIZE visible true 

add_parameter SCRATCHPAD_ADDR_BITS integer 10
set_parameter_property SCRATCHPAD_ADDR_BITS HDL_PARAMETER true
set_parameter_property SCRATCHPAD_ADDR_BITS visible false 
set_parameter_property SCRATCHPAD_ADDR_BITS derived true

add_parameter TCRAM_SIZE integer 64
set_parameter_property TCRAM_SIZE HDL_PARAMETER true
set_parameter_property TCRAM_SIZE visible false 

add_parameter CACHE_SIZE integer 64
set_parameter_property CACHE_SIZE HDL_PARAMETER true
set_parameter_property CACHE_SIZE visible false 

add_parameter LINE_SIZE integer 16
set_parameter_property LINE_SIZE HDL_PARAMETER true
set_parameter_property LINE_SIZE visible false 

add_parameter DRAM_WIDTH integer 32
set_parameter_property DRAM_WIDTH HDL_PARAMETER true
set_parameter_property DRAM_WIDTH visible false 

add_parameter BURST_EN integer 0 
set_parameter_property BURST_EN HDL_PARAMETER true
set_parameter_property BURST_EN visible false 

add_parameter POWER_OPTIMIZED natural
set_parameter_property POWER_OPTIMIZED DEFAULT_VALUE 0
set_parameter_property POWER_OPTIMIZED DISPLAY_NAME "Optimize for Power"
set_parameter_property POWER_OPTIMIZED DESCRIPTION "Improve power usage at the expense of area"
set_parameter_property POWER_OPTIMIZED HDL_PARAMETER true
set_parameter_property POWER_OPTIMIZED ALLOWED_RANGES 0:1
set_display_item_property POWER_OPTIMIZED DISPLAY_HINT boolean

add_parameter CACHE_ENABLE integer 0 
set_parameter_property CACHE_ENABLE HDL_PARAMETER true
set_parameter_property CACHE_ENABLE visible false 

add_parameter FAMILY string ALTERA 
set_parameter_property FAMILY HDL_PARAMETER true
set_parameter_property FAMILY visible false 

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
# ITCRAM Axi Port
#
add_interface axi_itcram_master axi start
set_interface_property axi_itcram_master associatedClock clock
set_interface_property axi_itcram_master associatedReset reset
set_interface_property axi_itcram_master readIssuingCapability 2
set_interface_property axi_itcram_master writeIssuingCapability 1
set_interface_property axi_itcram_master combinedIssuingCapability 1
set_interface_property axi_itcram_master ENABLED true
set_interface_property axi_itcram_master EXPORT_OF ""
set_interface_property axi_itcram_master PORT_NAME_MAP ""
set_interface_property axi_itcram_master CMSIS_SVD_VARIABLES ""
set_interface_property axi_itcram_master SVD_ADDRESS_GROUP ""

add_interface_port axi_itcram_master itcram_ARADDR araddr Output register_size
add_interface_port axi_itcram_master itcram_ARBURST arburst Output 2
add_interface_port axi_itcram_master itcram_ARCACHE arcache Output 4
add_interface_port axi_itcram_master itcram_ARID arid Output 4
add_interface_port axi_itcram_master itcram_ARLEN arlen Output 4
add_interface_port axi_itcram_master itcram_ARLOCK arlock Output 2
add_interface_port axi_itcram_master itcram_ARPROT arprot Output 3
add_interface_port axi_itcram_master itcram_ARREADY arready Input 1
add_interface_port axi_itcram_master itcram_ARSIZE arsize Output 3
add_interface_port axi_itcram_master itcram_ARVALID arvalid Output 1
add_interface_port axi_itcram_master itcram_AWADDR awaddr Output register_size
add_interface_port axi_itcram_master itcram_AWBURST awburst Output 2
add_interface_port axi_itcram_master itcram_AWCACHE awcache Output 4
add_interface_port axi_itcram_master itcram_AWID awid Output 4
add_interface_port axi_itcram_master itcram_AWLEN awlen Output 4
add_interface_port axi_itcram_master itcram_AWLOCK awlock Output 2
add_interface_port axi_itcram_master itcram_AWPROT awprot Output 3
add_interface_port axi_itcram_master itcram_AWREADY awready Input 1
add_interface_port axi_itcram_master itcram_AWSIZE awsize Output 3
add_interface_port axi_itcram_master itcram_AWVALID awvalid Output 1
add_interface_port axi_itcram_master itcram_BID bid Input 4
add_interface_port axi_itcram_master itcram_BREADY bready Output 1
add_interface_port axi_itcram_master itcram_BRESP bresp Input 2
add_interface_port axi_itcram_master itcram_BVALID bvalid Input 1
add_interface_port axi_itcram_master itcram_RDATA rdata Input register_size
add_interface_port axi_itcram_master itcram_RID rid Input 4
add_interface_port axi_itcram_master itcram_RLAST rlast Input 1
add_interface_port axi_itcram_master itcram_RREADY rready Output 1
add_interface_port axi_itcram_master itcram_RRESP rresp Input 2
add_interface_port axi_itcram_master itcram_RVALID rvalid Input 1
add_interface_port axi_itcram_master itcram_WDATA wdata Output register_size
add_interface_port axi_itcram_master itcram_WID wid Output 4
add_interface_port axi_itcram_master itcram_WLAST wlast Output 1
add_interface_port axi_itcram_master itcram_WREADY wready Input 1
add_interface_port axi_itcram_master itcram_WSTRB wstrb Output register_size/8
add_interface_port axi_itcram_master itcram_WVALID wvalid Output 1

#
# IRAM Axi Port
#
add_interface axi_iram_master axi start
set_interface_property axi_iram_master associatedClock clock
set_interface_property axi_iram_master associatedReset reset
set_interface_property axi_iram_master readIssuingCapability 2
set_interface_property axi_iram_master writeIssuingCapability 1
set_interface_property axi_iram_master combinedIssuingCapability 1
set_interface_property axi_iram_master ENABLED true
set_interface_property axi_iram_master EXPORT_OF ""
set_interface_property axi_iram_master PORT_NAME_MAP ""
set_interface_property axi_iram_master CMSIS_SVD_VARIABLES ""
set_interface_property axi_iram_master SVD_ADDRESS_GROUP ""

add_interface_port axi_iram_master iram_ARADDR araddr Output register_size
add_interface_port axi_iram_master iram_ARBURST arburst Output 2
add_interface_port axi_iram_master iram_ARCACHE arcache Output 4
add_interface_port axi_iram_master iram_ARID arid Output 4
add_interface_port axi_iram_master iram_ARLEN arlen Output 4
add_interface_port axi_iram_master iram_ARLOCK arlock Output 2
add_interface_port axi_iram_master iram_ARPROT arprot Output 3
add_interface_port axi_iram_master iram_ARREADY arready Input 1
add_interface_port axi_iram_master iram_ARSIZE arsize Output 3
add_interface_port axi_iram_master iram_ARVALID arvalid Output 1
add_interface_port axi_iram_master iram_AWADDR awaddr Output register_size
add_interface_port axi_iram_master iram_AWBURST awburst Output 2
add_interface_port axi_iram_master iram_AWCACHE awcache Output 4
add_interface_port axi_iram_master iram_AWID awid Output 4
add_interface_port axi_iram_master iram_AWLEN awlen Output 4
add_interface_port axi_iram_master iram_AWLOCK awlock Output 2
add_interface_port axi_iram_master iram_AWPROT awprot Output 3
add_interface_port axi_iram_master iram_AWREADY awready Input 1
add_interface_port axi_iram_master iram_AWSIZE awsize Output 3
add_interface_port axi_iram_master iram_AWVALID awvalid Output 1
add_interface_port axi_iram_master iram_BID bid Input 4
add_interface_port axi_iram_master iram_BREADY bready Output 1
add_interface_port axi_iram_master iram_BRESP bresp Input 2
add_interface_port axi_iram_master iram_BVALID bvalid Input 1
add_interface_port axi_iram_master iram_RDATA rdata Input register_size
add_interface_port axi_iram_master iram_RID rid Input 4
add_interface_port axi_iram_master iram_RLAST rlast Input 1
add_interface_port axi_iram_master iram_RREADY rready Output 1
add_interface_port axi_iram_master iram_RRESP rresp Input 2
add_interface_port axi_iram_master iram_RVALID rvalid Input 1
add_interface_port axi_iram_master iram_WDATA wdata Output register_size
add_interface_port axi_iram_master iram_WID wid Output 4
add_interface_port axi_iram_master iram_WLAST wlast Output 1
add_interface_port axi_iram_master iram_WREADY wready Input 1
add_interface_port axi_iram_master iram_WSTRB wstrb Output register_size/8
add_interface_port axi_iram_master iram_WVALID wvalid Output 1

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
# connection point scratch
#
add_interface scratch avalon slave

set_interface_property scratch addressUnits SYMBOLS
set_interface_property scratch associatedClock clock
set_interface_property scratch associatedReset reset
set_interface_property scratch bitsPerSymbol 8
set_interface_property scratch burstOnBurstBoundariesOnly false
set_interface_property scratch burstcountUnits WORDS
set_interface_property scratch holdTime 0
set_interface_property scratch linewrapBursts false
set_interface_property scratch maximumPendingReadTransactions 1
set_interface_property scratch maximumPendingWriteTransactions 0
set_interface_property scratch readLatency 0
set_interface_property scratch readWaitTime 1
set_interface_property scratch setupTime 0
set_interface_property scratch timingUnits Cycles
set_interface_property scratch writeWaitTime 0
set_interface_property scratch ENABLED true
set_interface_property scratch EXPORT_OF ""
set_interface_property scratch PORT_NAME_MAP ""
set_interface_property scratch CMSIS_SVD_VARIABLES ""
set_interface_property scratch SVD_ADDRESS_GROUP ""

add_interface_port scratch avm_scratch_address address Input scratchpad_addr_bits
add_interface_port scratch avm_scratch_byteenable byteenable Input register_size/8
add_interface_port scratch avm_scratch_read read Input 1
add_interface_port scratch avm_scratch_readdata readdata Output register_size
add_interface_port scratch avm_scratch_write write Input 1
add_interface_port scratch avm_scratch_writedata writedata Input register_size
add_interface_port scratch avm_scratch_waitrequest waitrequest Output 1
add_interface_port scratch avm_scratch_readdatavalid readdatavalid Output 1

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

add_interface_port unused_wishbone_bus       sp_ADR_I     export20     input scratchpad_addr_bits
add_interface_port unused_wishbone_bus       sp_DAT_O     export21      output  REGISTER_SIZE
add_interface_port unused_wishbone_bus       sp_DAT_I     export22     input REGISTER_SIZE
add_interface_port unused_wishbone_bus       sp_WE_I      export23     input 1
add_interface_port unused_wishbone_bus       sp_SEL_I     export24     input REGISTER_SIZE/8
add_interface_port unused_wishbone_bus       sp_STB_I     export25     input 1
add_interface_port unused_wishbone_bus       sp_ACK_O     export26     output 1
add_interface_port unused_wishbone_bus       sp_CYC_I     export27     input 1
add_interface_port unused_wishbone_bus       sp_CTI_I     export28     input 3
add_interface_port unused_wishbone_bus       sp_STALL_O   export29      output 1

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
			set_interface_property scratch ENABLED true
			set_parameter_property SCRATCHPAD_SIZE visible true
	} else {
		set_interface_property scratchpad_clk ENABLED false
			set_interface_property scratch ENABLED false
			set_parameter_property SCRATCHPAD_SIZE visible false
	}
	set sp_size [expr 1024*[get_parameter_value SCRATCHPAD_SIZE ] ]
		set log_size [log2 $sp_size]
		set_parameter_value SCRATCHPAD_ADDR_BITS $log_size
		if { [expr 2**$log_size != $sp_size ] } {
			send_message Error "Scratchpad size is not a power of two"
		}
	set table_size 0
		if { [get_parameter_value BRANCH_PREDICTION] } {
			set_parameter_property BTB_SIZE visible true
				set table_size [get_parameter_value BTB_SIZE ]
		} else {
			set_parameter_property BTB_SIZE visible false
		}

	if { [get_parameter_value ENABLE_EXCEPTIONS] } {
		set_parameter_property ENABLE_EXT_INTERRUPTS visible true
			if { [get_parameter_value  ENABLE_EXT_INTERRUPTS] > 0 } {
				set_parameter_property EXT_INTERRUPTS visible true
				set_interface_property global_interrupts enabled true
				set_parameter_value NUM_EXT_INTERRUPTS [ get_parameter_value EXT_INTERRUPTS ]
			} else {
				set_parameter_property EXT_INTERRUPTS visible false 
				set_interface_property global_interrupts enabled false
				set_parameter_value NUM_EXT_INTERRUPTS 1
			}
	} else {
		set_parameter_property ENABLE_EXT_INTERRUPTS visible false 
		set_interface_property global_interrupts enabled false
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

	if {[get_parameter_value BUS_TYPE] == "Axi"} {
		set axi_bus true
		set avalon_bus false
	} else {
		set axi_bus false
		set avalon_bus true
	}

	# Wishbone bus not yet supported.
	set wishbone_bus false

	# Cache not supported on this family.
	set cache_bus false

	set_parameter_value AXI_ENABLE   $axi_bus
	set_parameter_value AVALON_ENABLE  $avalon_bus
	set_parameter_value WISHBONE_ENABLE $wishbone_bus

	set_interface_property axi_itcram_master ENABLED $axi_bus
	set_interface_property axi_data_master ENABLED $axi_bus
	set_interface_property axi_iram_master ENABLED $cache_bus

	set_interface_property data ENABLED $avalon_bus
	set_interface_property instruction ENABLED $avalon_bus

}

