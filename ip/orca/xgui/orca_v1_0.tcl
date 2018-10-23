# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
    ipgui::add_param $IPINST -parent $IPINST -name Component_Name



    set generalParametersPage [ ipgui::add_page $IPINST -name "General Parameters" ]

    #    ipgui::add_param $IPINST -name "REGISTER_SIZE" -parent $generalParametersPage
    #    set_property tooltip \
        #        [concat \
        #             "" ] \
        #        $REGISTER_SIZE

    set RESET_VECTOR [ ipgui::add_param $IPINST -name "RESET_VECTOR" -parent $generalParametersPage ]
    set_property tooltip \
        [concat \
             "Address to start fetching instructions at after reset." ] \
        $RESET_VECTOR

    set VCP_ENABLE [ ipgui::add_param $IPINST -name "VCP_ENABLE" -parent $generalParametersPage -widget comboBox]
    set_property tooltip \
        [concat \
             "Enable the Vector Coprocessor Port (VCP); this connects to VectorBlox's " \
             "proprietary Lightweight Vector Extensions (LVE) or Matrix Processor (MXP). " \
             "The 32-bit variant supports only basic instructions, while the 64-bit variant " \
             "supports all VCP instructions.  Note that no other 64-bit instructions are supported even " \
             "when this is set to 32/64-bit." ] \
        $VCP_ENABLE

    #    set FAMILY [ ipgui::add_param $IPINST -name "FAMILY" -parent $generalParametersPage ]
    #    set_property tooltip \
        #        [concat \
        #             "" ] \
        #        $FAMILY


    set exceptionsGroup [ipgui::add_group $IPINST -name "Exceptions" -parent $generalParametersPage]

    set ENABLE_EXCEPTIONS [ ipgui::add_param $IPINST -name "ENABLE_EXCEPTIONS" -parent $exceptionsGroup -widget checkBox ]
    set_property tooltip \
        [concat \
             "Enable exceptions (traps/interrupts).  " \
             "Disable if unused to save area.  " \
             "If disabled then interrupts are ignored and illegal instructions and traps (ECALL/EBREAK) " \
             "produce undefined behaviour." ] \
        $ENABLE_EXCEPTIONS

    set INTERRUPT_VECTOR [ ipgui::add_param $IPINST -name "INTERRUPT_VECTOR" -parent $exceptionsGroup ]
    set_property tooltip \
        [concat \
             "Address to jump to on exceptions (traps/interrupts)." ] \
        $INTERRUPT_VECTOR

    set ENABLE_EXT_INTERRUPTS [ ipgui::add_param $IPINST -name "ENABLE_EXT_INTERRUPTS" -parent $exceptionsGroup -widget checkBox ]
    set_property tooltip \
        [concat \
             "Enable external interrupts (exceptions must be enabled).  " \
             "Disable if unused to save area." ] \
        $ENABLE_EXT_INTERRUPTS

    set NUM_EXT_INTERRUPTS [ ipgui::add_param $IPINST -name "NUM_EXT_INTERRUPTS" -parent $exceptionsGroup ]
    set_property tooltip \
        [concat \
             "Size of the global_interrupts[] input and number of bits in the MEIMASK/MEIPEND CSRs." ] \
        $NUM_EXT_INTERRUPTS


    set performanceOptionsGroup [ipgui::add_group $IPINST -name "Performance/Area Options" -parent $generalParametersPage]

    set MAX_IFETCHES_IN_FLIGHT [ ipgui::add_param $IPINST -name "MAX_IFETCHES_IN_FLIGHT" -parent $performanceOptionsGroup -widget comboBox ]
    set_property tooltip \
        [concat \
             "Maximum number of instruction fetches in flight.  " \
             "Must be greater than or equal to the instruction fetch latency for full throughput.  " \
             "Can be left at 1 if running out of the instruction cache." ] \
        $MAX_IFETCHES_IN_FLIGHT

    set BTB_ENTRIES [ ipgui::add_param $IPINST -name "BTB_ENTRIES" -parent $performanceOptionsGroup ]
    set_property tooltip \
        [concat \
             "Number of branch target buffer (BTB) entries.  " \
             "Set to disabled to disable branch predcition." ] \
        $BTB_ENTRIES

    set MULTIPLY_ENABLE [ ipgui::add_param $IPINST -name "MULTIPLY_ENABLE" -parent $performanceOptionsGroup -widget checkBox ]
    set_property tooltip \
        [concat \
             "Enables hardware multiplier.  " \
             "When enabled shifts also use the multiplier." ] \
        $MULTIPLY_ENABLE

    set SHIFTER_MAX_CYCLES [ ipgui::add_param $IPINST -name "SHIFTER_MAX_CYCLES" -parent $performanceOptionsGroup -widget comboBox ]
    set_property tooltip \
        [concat \
             "Number of cycles for shift instructions.  " \
             "Higher numbers use less are.  " \
             "Not applicable when multiplier is enabled, as shifts are done using the multiplier when enabled." ] \
        $SHIFTER_MAX_CYCLES

    set DIVIDE_ENABLE [ ipgui::add_param $IPINST -name "DIVIDE_ENABLE" -parent $performanceOptionsGroup -widget checkBox ]
    set_property tooltip \
        [concat \
             "Enable hardware divider.  " \
             "Divide and remainder ops take one cycle per bit when enabled." ] \
        $DIVIDE_ENABLE

    set MTIME_ENABLE [ ipgui::add_param $IPINST -name "MTIME_ENABLE" -parent $performanceOptionsGroup -widget checkBox ]
    set_property tooltip \
        [concat \
             "Enable the MTIME/MTIMEH CSR.  " \
             "When enabled the external Timer_Interface port must " \
             "be connected to an external ORCA Timer component." ] \
        $MTIME_ENABLE

    set PIPELINE_STAGES [ ipgui::add_param $IPINST -name "PIPELINE_STAGES" -parent $performanceOptionsGroup -widget comboBox ]
    set_property tooltip \
        [concat \
             "Number of pipeline stages.  " \
             "Reducing this lowers area and branch misprediction penalty but potentially lowers fmax as well." ] \
        $PIPELINE_STAGES

    set POWER_OPTIMIZED [ ipgui::add_param $IPINST -name "POWER_OPTIMIZED" -parent $performanceOptionsGroup -widget checkBox ]
    set_property tooltip \
        [concat \
             "Enable optimizations for power at the cost of higher area and potentially lower fmax." ] \
        $POWER_OPTIMIZED



    set memoryAndCachePage [ ipgui::add_page $IPINST -name "Memory and Cache" ]

    set INSTRUCTION_REQUEST_REGISTER [ ipgui::add_param $IPINST -name "INSTRUCTION_REQUEST_REGISTER" -parent $memoryAndCachePage -widget comboBox ]
    set_property tooltip \
        [concat \
             "Register for ALL instruction requests (including cache hits).  " \
             "Light disconnects only the combinational path through the waitrequest/ready signal, " \
             "but adds no latency.  " \
             "Full disconnects the combinational path through all signals (address/data/etc.), " \
             "but adds one cycle of latency." ] \
        $INSTRUCTION_REQUEST_REGISTER

    set INSTRUCTION_RETURN_REGISTER [ ipgui::add_param $IPINST -name "INSTRUCTION_RETURN_REGISTER" -parent $memoryAndCachePage -widget comboBox ]
    set_property tooltip \
        [concat \
             "Return data register for ALL instruction reads (including cache hits)." ] \
        $INSTRUCTION_RETURN_REGISTER

    set DATA_REQUEST_REGISTER [ ipgui::add_param $IPINST -name "DATA_REQUEST_REGISTER" -parent $memoryAndCachePage -widget comboBox ]
    set_property tooltip \
        [concat \
             "Register for ALL data requests (including cache hits).  " \
             "Light disconnects only the combinational path through the waitrequest/ready signal, " \
             "but adds no latency.  " \
             "Full disconnects the combinational path through all signals (address/data/etc.), " \
             "but adds one cycle of latency." ] \
        $DATA_REQUEST_REGISTER

    set DATA_RETURN_REGISTER [ ipgui::add_param $IPINST -name "DATA_RETURN_REGISTER" -parent $memoryAndCachePage -widget comboBox ]
    set_property tooltip \
        [concat \
             "Return data register for ALL data reads (including cache hits)." ] \
        $DATA_RETURN_REGISTER

    #    set LOG2_BURSTLENGTH [ ipgui::add_param $IPINST -name "LOG2_BURSTLENGTH" -parent $memoryAndCachePage ]
    #    set_property tooltip \
        #        [concat \
        #             "" ] \
        #        $LOG2_BURSTLENGTH

    #    set AXI_ID_WIDTH [ ipgui::add_param $IPINST -name "AXI_ID_WIDTH" -parent $memoryAndCachePage ]
    #    set_property tooltip \
        #        [concat \
        #             "" ] \
        #        $AXI_ID_WIDTH

    #    set AVALON_AUX [ ipgui::add_param $IPINST -name "AVALON_AUX" -parent $memoryAndCachePage ]
    #    set_property tooltip \
        #        [concat \
        #             "" ] \
        #        $AVALON_AUX

    #    set LMB_AUX [ ipgui::add_param $IPINST -name "LMB_AUX" -parent $memoryAndCachePage ]
    #    set_property tooltip \
        #        [concat \
        #             "" ] \
        #        $LMB_AUX

    #    set WISHBONE_AUX [ ipgui::add_param $IPINST -name "WISHBONE_AUX" -parent $memoryAndCachePage ]
    #    set_property tooltip \
        #        [concat \
        #             "" ] \
        #        $WISHBONE_AUX

    set icGroup [ipgui::add_group $IPINST -name "Instruction Cache and IC AXI4 Master" -parent $memoryAndCachePage]

    set ICACHE_SIZE [ ipgui::add_param $IPINST -name "ICACHE_SIZE" -parent $icGroup -widget comboBox ]
    set_property tooltip \
        [concat \
             "Instruction cache size in bytes.  " \
             "When enabled the IC AXI4 master is enabled." ] \
        $ICACHE_SIZE

    set ICACHE_LINE_SIZE [ ipgui::add_param $IPINST -name "ICACHE_LINE_SIZE" -parent $icGroup -widget comboBox ]
    set_property tooltip \
        [concat \
             "Instruction line cache size in bytes.  " ] \
        $ICACHE_LINE_SIZE

    #    set ICACHE_EXTERNAL_WIDTH [ ipgui::add_param $IPINST -name "ICACHE_EXTERNAL_WIDTH" -parent $icGroup ]
    #    set_property tooltip \
        #        [concat \
        #             "Instruction cache external width in bits.  " \
        #             "Determines the data width of the IC AXI4 master." ] \
        #        $ICACHE_EXTERNAL_WIDTH

    set IC_REQUEST_REGISTER [ ipgui::add_param $IPINST -name "IC_REQUEST_REGISTER" -parent $icGroup -widget comboBox ]
    set_property tooltip \
        [concat \
             "Register for instruction cache AXI4 master requests.  " \
             "Light disconnects only the combinational path through the waitrequest/ready signal, " \
             "but adds no latency.  " \
             "Full disconnects the combinational path through all signals (address/data/etc.), " \
             "but adds one cycle of latency." ] \
        $IC_REQUEST_REGISTER

    set IC_RETURN_REGISTER [ ipgui::add_param $IPINST -name "IC_RETURN_REGISTER" -parent $icGroup -widget comboBox ]
    set_property tooltip \
        [concat \
             "Return data register for instruction cache AXI4 master reads." ] \
        $IC_RETURN_REGISTER


    set dcGroup [ipgui::add_group $IPINST -name "Data Cache and DC AXI4 Master" -parent $memoryAndCachePage]

    set DCACHE_SIZE [ ipgui::add_param $IPINST -name "DCACHE_SIZE" -parent $dcGroup -widget comboBox ]
    set_property tooltip \
        [concat \
             "Data cache size in bytes.  " \
             "When enabled the DC AXI4 master is enabled." ] \
        $DCACHE_SIZE
    
    set DCACHE_WRITEBACK [ ipgui::add_param $IPINST -name "DCACHE_WRITEBACK" -parent $dcGroup -widget comboBox ]
    set_property tooltip \
        [concat \
             "Write-through immediately puts all writes onto the DC bus and does not allocate on write misses.  " \
             "Write-back writes dirty cache lines back on eviction (conflict, IFENCE, or FLUSH/INVALIDATE) and " \
             "allocates on write misses." ] \
        $DCACHE_WRITEBACK
    
    set DCACHE_LINE_SIZE [ ipgui::add_param $IPINST -name "DCACHE_LINE_SIZE" -parent $dcGroup -widget comboBox ]
    set_property tooltip \
        [concat \
             "Data line cache size in bytes.  " ] \
        $DCACHE_LINE_SIZE

    #    set DCACHE_EXTERNAL_WIDTH [ ipgui::add_param $IPINST -name "DCACHE_EXTERNAL_WIDTH" -parent $dcGroup ]
    #    set_property tooltip \
        #        [concat \
        #             "Data cache external width in bits.  " \
        #             "Determines the data width of the DC AXI4 master." ] \
        #        $DCACHE_EXTERNAL_WIDTH

    set DC_REQUEST_REGISTER [ ipgui::add_param $IPINST -name "DC_REQUEST_REGISTER" -parent $dcGroup -widget comboBox ]
    set_property tooltip \
        [concat \
             "Register for data cache AXI4 master requests.  " \
             "Light disconnects only the combinational path through the waitrequest/ready signal, " \
             "but adds no latency.  " \
             "Full disconnects the combinational path through all signals (address/data/etc.), " \
             "but adds one cycle of latency." ] \
        $DC_REQUEST_REGISTER

    set DC_RETURN_REGISTER [ ipgui::add_param $IPINST -name "DC_RETURN_REGISTER" -parent $dcGroup -widget comboBox ]
    set_property tooltip \
        [concat \
             "Return data register for data cache AXI4 master reads." ] \
        $DC_RETURN_REGISTER


    set ucGroup [ipgui::add_group $IPINST -name "Uncached AXI4-Lite Masters" -parent $memoryAndCachePage]

    set UC_MEMORY_REGIONS [ ipgui::add_param $IPINST -name "UC_MEMORY_REGIONS" -parent $ucGroup -widget comboBox ]
    set_property tooltip \
        [concat \
             "Number of uncached AXI4-Lite regions.  " \
             "If set to one or more then the IUC and DUC masters are enabled." ] \
        $UC_MEMORY_REGIONS

    set UMR0_ADDR_BASE [ ipgui::add_param $IPINST -name "UMR0_ADDR_BASE" -parent $ucGroup ]
    set_property tooltip \
        [concat \
             "Initial base address for uncached memory region 0.  " \
             "Should be set to the base address of the default IUC/DUC address range." ] \
        $UMR0_ADDR_BASE

    set UMR0_ADDR_LAST [ ipgui::add_param $IPINST -name "UMR0_ADDR_LAST" -parent $ucGroup ]
    set_property tooltip \
        [concat \
             "Initial last address for uncached memory region 0.  " \
             "Should be set to the last address of the default IUC/DUC address range.  " \
             "Note that last address is the highest addressable address not the start of the next address range.  " \
             "e.g. if UMR0 starts at 0x00000000 and has a span of 0x80000000 URM0_ADDR_LAST is 0x7FFFFFFF." ] \
        $UMR0_ADDR_LAST

    set UMR0_READ_ONLY [ ipgui::add_param $IPINST -name "UMR0_READ_ONLY" -parent $ucGroup -widget checkBox ]
    set_property tooltip \
        [concat \
             "Makes UMR0 read-only.  " \
             "Should be set when cached/uncached regions will not change to save logic and increase fmax." ] \
        $UMR0_READ_ONLY

    set IUC_REQUEST_REGISTER [ ipgui::add_param $IPINST -name "IUC_REQUEST_REGISTER" -parent $ucGroup -widget comboBox ]
    set_property tooltip \
        [concat \
             "Register for instruction uncached AXI4-Lite master requests.  " \
             "Light disconnects only the combinational path through the waitrequest/ready signal, " \
             "but adds no latency.  " \
             "Full disconnects the combinational path through all signals (address/data/etc.), " \
             "but adds one cycle of latency." ] \
        $IUC_REQUEST_REGISTER

    set IUC_RETURN_REGISTER [ ipgui::add_param $IPINST -name "IUC_RETURN_REGISTER" -parent $ucGroup -widget comboBox ]
    set_property tooltip \
        [concat \
             "Return data register for instruction uncached AXI4-Lite master reads." ] \
        $IUC_RETURN_REGISTER

    set DUC_REQUEST_REGISTER [ ipgui::add_param $IPINST -name "DUC_REQUEST_REGISTER" -parent $ucGroup -widget comboBox ]
    set_property tooltip \
        [concat \
             "Register for data uncached AXI4-Lite master requests.  " \
             "Light disconnects only the combinational path through the waitrequest/ready signal, " \
             "but adds no latency.  " \
             "Full disconnects the combinational path through all signals (address/data/etc.), " \
             "but adds one cycle of latency." ] \
        $DUC_REQUEST_REGISTER

    set DUC_RETURN_REGISTER [ ipgui::add_param $IPINST -name "DUC_RETURN_REGISTER" -parent $ucGroup -widget comboBox ]
    set_property tooltip \
        [concat \
             "Return data register for data uncached AXI4-Lite master reads." ] \
        $DUC_RETURN_REGISTER


    set lmbGroup [ipgui::add_group $IPINST -name "LMB (Xilinx Local Memory Bus) Masters" -parent $memoryAndCachePage]

    set AUX_MEMORY_REGIONS [ ipgui::add_param $IPINST -name "AUX_MEMORY_REGIONS" -parent $lmbGroup -widget comboBox ]
    set_property tooltip \
        [concat \
             "Number of LMB regions.  " \
             "If set to one or more then the ILMB and DLMB masters are enabled." ] \
        $AUX_MEMORY_REGIONS

    set AMR0_ADDR_BASE [ ipgui::add_param $IPINST -name "AMR0_ADDR_BASE" -parent $lmbGroup ]
    set_property tooltip \
        [concat \
             "Initial base address for auxiliary memory region 0.  " \
             "Should be set to the base address of the default ILMB/DLMB address range." ] \
        $AMR0_ADDR_BASE

    set AMR0_ADDR_LAST [ ipgui::add_param $IPINST -name "AMR0_ADDR_LAST" -parent $lmbGroup ]
    set_property tooltip \
        [concat \
             "Initial last address for auxiliary memory region 0.  " \
             "Should be set to the last address of the default ILMB/DLMB address range.  " \
             "Note that last address is the highest addressable address not the start of the next address range.  " \
             "e.g. if AMR0 starts at 0x00000000 and has a span of 0x80000000 ARM0_ADDR_LAST is 0x7FFFFFFF." ] \
        $AMR0_ADDR_LAST

    set AMR0_READ_ONLY [ ipgui::add_param $IPINST -name "AMR0_READ_ONLY" -parent $lmbGroup -widget checkBox ]
    set_property tooltip \
        [concat \
             "Makes AMR0 read-only.  " \
             "Should be set when LMB region will not change to save logic and increase fmax." ] \
        $AMR0_READ_ONLY

    set IAUX_REQUEST_REGISTER [ ipgui::add_param $IPINST -name "IAUX_REQUEST_REGISTER" -parent $lmbGroup -widget comboBox ]
    set_property tooltip \
        [concat \
             "Register for instruction LMB master requests.  " \
             "Light disconnects only the combinational path through the waitrequest/ready signal, " \
             "but adds no latency.  " \
             "Full disconnects the combinational path through all signals (address/data/etc.), " \
             "but adds one cycle of latency." ] \
        $IAUX_REQUEST_REGISTER

    set IAUX_RETURN_REGISTER [ ipgui::add_param $IPINST -name "IAUX_RETURN_REGISTER" -parent $lmbGroup -widget comboBox ]
    set_property tooltip \
        [concat \
             "Return data register for instruction LMB master reads." ] \
        $IAUX_RETURN_REGISTER

    set DAUX_REQUEST_REGISTER [ ipgui::add_param $IPINST -name "DAUX_REQUEST_REGISTER" -parent $lmbGroup -widget comboBox ]
    set_property tooltip \
        [concat \
             "Register for data LMB master requests.  " \
             "Light disconnects only the combinational path through the waitrequest/ready signal, " \
             "but adds no latency.  " \
             "Full disconnects the combinational path through all signals (address/data/etc.), " \
             "but adds one cycle of latency." ] \
        $DAUX_REQUEST_REGISTER

    set DAUX_RETURN_REGISTER [ ipgui::add_param $IPINST -name "DAUX_RETURN_REGISTER" -parent $lmbGroup -widget comboBox ]
    set_property tooltip \
        [concat \
             "Return data register for data LMB master reads." ] \
        $DAUX_RETURN_REGISTER
}

proc update_PARAM_VALUE.REGISTER_SIZE { PARAM_VALUE.REGISTER_SIZE } {
    # Procedure called to update REGISTER_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.REGISTER_SIZE { PARAM_VALUE.REGISTER_SIZE } {
    # Procedure called to validate REGISTER_SIZE
    return true
}

proc update_PARAM_VALUE.RESET_VECTOR { PARAM_VALUE.RESET_VECTOR } {
    # Procedure called to update RESET_VECTOR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RESET_VECTOR { PARAM_VALUE.RESET_VECTOR } {
    # Procedure called to validate RESET_VECTOR
    if { [expr [get_property value ${PARAM_VALUE.RESET_VECTOR}] % 4] != 0 } {
        set_property errmsg "Reset vector must be aligned to 4 bytes." ${PARAM_VALUE.RESET_VECTOR}
        return false
    }
    return true
}

proc update_PARAM_VALUE.INTERRUPT_VECTOR { PARAM_VALUE.INTERRUPT_VECTOR PARAM_VALUE.ENABLE_EXCEPTIONS } {
    # Procedure called to update INTERRUPT_VECTOR when any of the dependent parameters in the arguments change
    if { [get_property value ${PARAM_VALUE.ENABLE_EXCEPTIONS} ] } {
        set_property enabled true ${PARAM_VALUE.INTERRUPT_VECTOR}
    } else {
        set_property enabled false ${PARAM_VALUE.INTERRUPT_VECTOR}
    }
}

proc validate_PARAM_VALUE.INTERRUPT_VECTOR { PARAM_VALUE.INTERRUPT_VECTOR PARAM_VALUE.ENABLE_EXCEPTIONS } {
    # Procedure called to validate INTERRUPT_VECTOR
    if { [expr [get_property value ${PARAM_VALUE.INTERRUPT_VECTOR}] % 4] != 0 } {
        set_property errmsg "Exception vector must be aligned to 4 bytes." ${PARAM_VALUE.INTERRUPT_VECTOR}
        return false
    }
    return true
}

proc update_PARAM_VALUE.MAX_IFETCHES_IN_FLIGHT { PARAM_VALUE.MAX_IFETCHES_IN_FLIGHT } {
    # Procedure called to update MAX_IFETCHES_IN_FLIGHT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MAX_IFETCHES_IN_FLIGHT { PARAM_VALUE.MAX_IFETCHES_IN_FLIGHT } {
    # Procedure called to validate MAX_IFETCHES_IN_FLIGHT
    return true
}

proc update_PARAM_VALUE.BTB_ENTRIES { PARAM_VALUE.BTB_ENTRIES } {
    # Procedure called to update BTB_ENTRIES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BTB_ENTRIES { PARAM_VALUE.BTB_ENTRIES } {
    # Procedure called to validate BTB_ENTRIES
    return true
}

proc update_PARAM_VALUE.MULTIPLY_ENABLE { PARAM_VALUE.MULTIPLY_ENABLE } {
    # Procedure called to update MULTIPLY_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MULTIPLY_ENABLE { PARAM_VALUE.MULTIPLY_ENABLE } {
    # Procedure called to validate MULTIPLY_ENABLE
    return true
}

proc update_PARAM_VALUE.DIVIDE_ENABLE { PARAM_VALUE.DIVIDE_ENABLE } {
    # Procedure called to update DIVIDE_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DIVIDE_ENABLE { PARAM_VALUE.DIVIDE_ENABLE } {
    # Procedure called to validate DIVIDE_ENABLE
    return true
}

proc update_PARAM_VALUE.SHIFTER_MAX_CYCLES { PARAM_VALUE.SHIFTER_MAX_CYCLES PARAM_VALUE.MULTIPLY_ENABLE } {
    # Procedure called to update SHIFTER_MAX_CYCLES when any of the dependent parameters in the arguments change
    if { [get_property value ${PARAM_VALUE.MULTIPLY_ENABLE} ] } {
        set_property enabled false ${PARAM_VALUE.SHIFTER_MAX_CYCLES}
    } else {
        set_property enabled true ${PARAM_VALUE.SHIFTER_MAX_CYCLES}
    }
}

proc validate_PARAM_VALUE.SHIFTER_MAX_CYCLES { PARAM_VALUE.SHIFTER_MAX_CYCLES } {
    # Procedure called to validate SHIFTER_MAX_CYCLES
    return true
}

proc update_PARAM_VALUE.MTIME_ENABLE { PARAM_VALUE.MTIME_ENABLE } {
    # Procedure called to update MTIME_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MTIME_ENABLE { PARAM_VALUE.MTIME_ENABLE } {
    # Procedure called to validate MTIME_ENABLE
    return true
}

proc update_PARAM_VALUE.ENABLE_EXCEPTIONS { PARAM_VALUE.ENABLE_EXCEPTIONS } {
    # Procedure called to update ENABLE_EXCEPTIONS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ENABLE_EXCEPTIONS { PARAM_VALUE.ENABLE_EXCEPTIONS } {
    # Procedure called to validate ENABLE_EXCEPTIONS
    return true
}

proc update_PARAM_VALUE.PIPELINE_STAGES { PARAM_VALUE.PIPELINE_STAGES } {
    # Procedure called to update PIPELINE_STAGES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PIPELINE_STAGES { PARAM_VALUE.PIPELINE_STAGES } {
    # Procedure called to validate PIPELINE_STAGES
    return true
}

proc update_PARAM_VALUE.VCP_ENABLE { PARAM_VALUE.VCP_ENABLE } {
    # Procedure called to update VCP_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.VCP_ENABLE { PARAM_VALUE.VCP_ENABLE } {
    # Procedure called to validate VCP_ENABLE
    return true
}

proc update_PARAM_VALUE.ENABLE_EXT_INTERRUPTS { PARAM_VALUE.ENABLE_EXT_INTERRUPTS PARAM_VALUE.ENABLE_EXCEPTIONS } {
    # Procedure called to update ENABLE_EXT_INTERRUPTS when any of the dependent parameters in the arguments change
    if { [get_property value ${PARAM_VALUE.ENABLE_EXCEPTIONS} ] } {
        set_property enabled true ${PARAM_VALUE.ENABLE_EXT_INTERRUPTS}
    } else {
        set_property enabled false ${PARAM_VALUE.ENABLE_EXT_INTERRUPTS}
    }
}

proc validate_PARAM_VALUE.ENABLE_EXT_INTERRUPTS { PARAM_VALUE.ENABLE_EXT_INTERRUPTS } {
    # Procedure called to validate ENABLE_EXT_INTERRUPTS
    return true
}

proc update_PARAM_VALUE.NUM_EXT_INTERRUPTS { PARAM_VALUE.NUM_EXT_INTERRUPTS PARAM_VALUE.ENABLE_EXCEPTIONS PARAM_VALUE.ENABLE_EXT_INTERRUPTS } {
    # Procedure called to update NUM_EXT_INTERRUPTS when any of the dependent parameters in the arguments change
    if { [get_property value ${PARAM_VALUE.ENABLE_EXCEPTIONS} ] && [get_property value ${PARAM_VALUE.ENABLE_EXT_INTERRUPTS} ] } {
        set_property enabled true ${PARAM_VALUE.NUM_EXT_INTERRUPTS}
    } else {
        set_property enabled false ${PARAM_VALUE.NUM_EXT_INTERRUPTS}
    }
}

proc validate_PARAM_VALUE.NUM_EXT_INTERRUPTS { PARAM_VALUE.NUM_EXT_INTERRUPTS } {
    # Procedure called to validate NUM_EXT_INTERRUPTS
    return true
}

proc update_PARAM_VALUE.POWER_OPTIMIZED { PARAM_VALUE.POWER_OPTIMIZED } {
    # Procedure called to update POWER_OPTIMIZED when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.POWER_OPTIMIZED { PARAM_VALUE.POWER_OPTIMIZED } {
    # Procedure called to validate POWER_OPTIMIZED
    return true
}

proc update_PARAM_VALUE.FAMILY { PARAM_VALUE.FAMILY } {
    # Procedure called to update FAMILY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FAMILY { PARAM_VALUE.FAMILY } {
    # Procedure called to validate FAMILY
    return true
}

proc update_PARAM_VALUE.LOG2_BURSTLENGTH { PARAM_VALUE.LOG2_BURSTLENGTH } {
    # Procedure called to update LOG2_BURSTLENGTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.LOG2_BURSTLENGTH { PARAM_VALUE.LOG2_BURSTLENGTH } {
    # Procedure called to validate LOG2_BURSTLENGTH
    return true
}

proc update_PARAM_VALUE.AXI_ID_WIDTH { PARAM_VALUE.AXI_ID_WIDTH } {
    # Procedure called to update AXI_ID_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_ID_WIDTH { PARAM_VALUE.AXI_ID_WIDTH } {
    # Procedure called to validate AXI_ID_WIDTH
    return true
}

proc update_PARAM_VALUE.AVALON_AUX { PARAM_VALUE.AVALON_AUX } {
    # Procedure called to update AVALON_AUX when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AVALON_AUX { PARAM_VALUE.AVALON_AUX } {
    # Procedure called to validate AVALON_AUX
    return true
}

proc update_PARAM_VALUE.LMB_AUX { PARAM_VALUE.LMB_AUX } {
    # Procedure called to update LMB_AUX when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.LMB_AUX { PARAM_VALUE.LMB_AUX } {
    # Procedure called to validate LMB_AUX
    return true
}

proc update_PARAM_VALUE.WISHBONE_AUX { PARAM_VALUE.WISHBONE_AUX } {
    # Procedure called to update WISHBONE_AUX when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WISHBONE_AUX { PARAM_VALUE.WISHBONE_AUX } {
    # Procedure called to validate WISHBONE_AUX
    return true
}

proc update_PARAM_VALUE.AUX_MEMORY_REGIONS { PARAM_VALUE.AUX_MEMORY_REGIONS } {
    # Procedure called to update AUX_MEMORY_REGIONS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AUX_MEMORY_REGIONS { PARAM_VALUE.AUX_MEMORY_REGIONS } {
    # Procedure called to validate AUX_MEMORY_REGIONS
    return true
}

proc update_PARAM_VALUE.AMR0_ADDR_BASE { PARAM_VALUE.AMR0_ADDR_BASE PARAM_VALUE.AUX_MEMORY_REGIONS } {
    # Procedure called to update AMR0_ADDR_BASE when any of the dependent parameters in the arguments change
    if { [get_property value ${PARAM_VALUE.AUX_MEMORY_REGIONS} ] } {
        set_property enabled true ${PARAM_VALUE.AMR0_ADDR_BASE}
    } else {
        set_property enabled false ${PARAM_VALUE.AMR0_ADDR_BASE}
    }
}

proc validate_PARAM_VALUE.AMR0_ADDR_BASE { PARAM_VALUE.AMR0_ADDR_BASE } {
    # Procedure called to validate AMR0_ADDR_BASE
    return true
}

proc update_PARAM_VALUE.AMR0_ADDR_LAST { PARAM_VALUE.AMR0_ADDR_LAST PARAM_VALUE.AUX_MEMORY_REGIONS } {
    # Procedure called to update AMR0_ADDR_LAST when any of the dependent parameters in the arguments change
    if { [get_property value ${PARAM_VALUE.AUX_MEMORY_REGIONS} ] } {
        set_property enabled true ${PARAM_VALUE.AMR0_ADDR_LAST}
    } else {
        set_property enabled false ${PARAM_VALUE.AMR0_ADDR_LAST}
    }
}

proc validate_PARAM_VALUE.AMR0_ADDR_LAST { PARAM_VALUE.AMR0_ADDR_LAST } {
    # Procedure called to validate AMR0_ADDR_LAST
    return true
}

proc update_PARAM_VALUE.AMR0_READ_ONLY { PARAM_VALUE.AMR0_READ_ONLY PARAM_VALUE.AUX_MEMORY_REGIONS } {
    # Procedure called to update AMR0_READ_ONLY when any of the dependent parameters in the arguments change
    if { [get_property value ${PARAM_VALUE.AUX_MEMORY_REGIONS} ] } {
        set_property enabled true ${PARAM_VALUE.AMR0_READ_ONLY}
    } else {
        set_property enabled false ${PARAM_VALUE.AMR0_READ_ONLY}
    }
}

proc validate_PARAM_VALUE.AMR0_READ_ONLY { PARAM_VALUE.AMR0_READ_ONLY } {
    # Procedure called to validate AMR0_READ_ONLY
    return true
}

proc update_PARAM_VALUE.UC_MEMORY_REGIONS { PARAM_VALUE.UC_MEMORY_REGIONS } {
    # Procedure called to update UC_MEMORY_REGIONS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.UC_MEMORY_REGIONS { PARAM_VALUE.UC_MEMORY_REGIONS } {
    # Procedure called to validate UC_MEMORY_REGIONS
    return true
}

proc update_PARAM_VALUE.UMR0_ADDR_BASE { PARAM_VALUE.UMR0_ADDR_BASE PARAM_VALUE.UC_MEMORY_REGIONS } {
    # Procedure called to update UMR0_ADDR_BASE when any of the dependent parameters in the arguments change
    if { [get_property value ${PARAM_VALUE.UC_MEMORY_REGIONS} ] } {
        set_property enabled true ${PARAM_VALUE.UMR0_ADDR_BASE}
    } else {
        set_property enabled false ${PARAM_VALUE.UMR0_ADDR_BASE}
    }
}

proc validate_PARAM_VALUE.UMR0_ADDR_BASE { PARAM_VALUE.UMR0_ADDR_BASE } {
    # Procedure called to validate UMR0_ADDR_BASE
    return true
}

proc update_PARAM_VALUE.UMR0_ADDR_LAST { PARAM_VALUE.UMR0_ADDR_LAST PARAM_VALUE.UC_MEMORY_REGIONS } {
    # Procedure called to update UMR0_ADDR_LAST when any of the dependent parameters in the arguments change
    if { [get_property value ${PARAM_VALUE.UC_MEMORY_REGIONS} ] } {
        set_property enabled true ${PARAM_VALUE.UMR0_ADDR_LAST}
    } else {
        set_property enabled false ${PARAM_VALUE.UMR0_ADDR_LAST}
    }
}

proc validate_PARAM_VALUE.UMR0_ADDR_LAST { PARAM_VALUE.UMR0_ADDR_LAST } {
    # Procedure called to validate UMR0_ADDR_LAST
    return true
}

proc update_PARAM_VALUE.UMR0_READ_ONLY { PARAM_VALUE.UMR0_READ_ONLY PARAM_VALUE.UC_MEMORY_REGIONS } {
    # Procedure called to update UMR0_READ_ONLY when any of the dependent parameters in the arguments change
    if { [get_property value ${PARAM_VALUE.UC_MEMORY_REGIONS} ] } {
        set_property enabled true ${PARAM_VALUE.UMR0_READ_ONLY}
    } else {
        set_property enabled false ${PARAM_VALUE.UMR0_READ_ONLY}
    }
}

proc validate_PARAM_VALUE.UMR0_READ_ONLY { PARAM_VALUE.UMR0_READ_ONLY } {
    # Procedure called to validate UMR0_READ_ONLY
    return true
}

proc update_PARAM_VALUE.ICACHE_SIZE { PARAM_VALUE.ICACHE_SIZE } {
    # Procedure called to update ICACHE_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ICACHE_SIZE { PARAM_VALUE.ICACHE_SIZE } {
    # Procedure called to validate ICACHE_SIZE
    return true
}

proc update_PARAM_VALUE.ICACHE_LINE_SIZE { PARAM_VALUE.ICACHE_LINE_SIZE PARAM_VALUE.ICACHE_SIZE } {
    # Procedure called to update ICACHE_LINE_SIZE when any of the dependent parameters in the arguments change
    if { [get_property value ${PARAM_VALUE.ICACHE_SIZE} ] } {
        set_property enabled true ${PARAM_VALUE.ICACHE_LINE_SIZE}
    } else {
        set_property enabled false ${PARAM_VALUE.ICACHE_LINE_SIZE}
    }
}

proc validate_PARAM_VALUE.ICACHE_LINE_SIZE { PARAM_VALUE.ICACHE_LINE_SIZE } {
    # Procedure called to validate ICACHE_LINE_SIZE
    return true
}

proc update_PARAM_VALUE.ICACHE_EXTERNAL_WIDTH { PARAM_VALUE.ICACHE_EXTERNAL_WIDTH PARAM_VALUE.ICACHE_SIZE } {
    # Procedure called to update ICACHE_EXTERNAL_WIDTH when any of the dependent parameters in the arguments change
    if { [get_property value ${PARAM_VALUE.ICACHE_SIZE} ] } {
        set_property enabled true ${PARAM_VALUE.ICACHE_EXTERNAL_WIDTH}
    } else {
        set_property enabled false ${PARAM_VALUE.ICACHE_EXTERNAL_WIDTH}
    }
}

proc validate_PARAM_VALUE.ICACHE_EXTERNAL_WIDTH { PARAM_VALUE.ICACHE_EXTERNAL_WIDTH } {
    # Procedure called to validate ICACHE_EXTERNAL_WIDTH
    return true
}

proc update_PARAM_VALUE.INSTRUCTION_REQUEST_REGISTER { PARAM_VALUE.INSTRUCTION_REQUEST_REGISTER } {
    # Procedure called to update INSTRUCTION_REQUEST_REGISTER when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INSTRUCTION_REQUEST_REGISTER { PARAM_VALUE.INSTRUCTION_REQUEST_REGISTER } {
    # Procedure called to validate INSTRUCTION_REQUEST_REGISTER
    return true
}

proc update_PARAM_VALUE.INSTRUCTION_RETURN_REGISTER { PARAM_VALUE.INSTRUCTION_RETURN_REGISTER } {
    # Procedure called to update INSTRUCTION_RETURN_REGISTER when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INSTRUCTION_RETURN_REGISTER { PARAM_VALUE.INSTRUCTION_RETURN_REGISTER } {
    # Procedure called to validate INSTRUCTION_RETURN_REGISTER
    return true
}

proc update_PARAM_VALUE.IUC_REQUEST_REGISTER { PARAM_VALUE.IUC_REQUEST_REGISTER PARAM_VALUE.UC_MEMORY_REGIONS } {
    # Procedure called to update IUC_REQUEST_REGISTER when any of the dependent parameters in the arguments change
    if { [get_property value ${PARAM_VALUE.UC_MEMORY_REGIONS} ] } {
        set_property enabled true ${PARAM_VALUE.IUC_REQUEST_REGISTER}
    } else {
        set_property enabled false ${PARAM_VALUE.IUC_REQUEST_REGISTER}
    }
}

proc validate_PARAM_VALUE.IUC_REQUEST_REGISTER { PARAM_VALUE.IUC_REQUEST_REGISTER } {
    # Procedure called to validate IUC_REQUEST_REGISTER
    return true
}

proc update_PARAM_VALUE.IUC_RETURN_REGISTER { PARAM_VALUE.IUC_RETURN_REGISTER PARAM_VALUE.UC_MEMORY_REGIONS } {
    # Procedure called to update IUC_RETURN_REGISTER when any of the dependent parameters in the arguments change
    if { [get_property value ${PARAM_VALUE.UC_MEMORY_REGIONS} ] } {
        set_property enabled true ${PARAM_VALUE.IUC_RETURN_REGISTER}
    } else {
        set_property enabled false ${PARAM_VALUE.IUC_RETURN_REGISTER}
    }
}

proc validate_PARAM_VALUE.IUC_RETURN_REGISTER { PARAM_VALUE.IUC_RETURN_REGISTER } {
    # Procedure called to validate IUC_RETURN_REGISTER
    return true
}

proc update_PARAM_VALUE.IAUX_REQUEST_REGISTER { PARAM_VALUE.IAUX_REQUEST_REGISTER PARAM_VALUE.AUX_MEMORY_REGIONS } {
    # Procedure called to update IAUX_REQUEST_REGISTER when any of the dependent parameters in the arguments change
    if { [get_property value ${PARAM_VALUE.AUX_MEMORY_REGIONS} ] } {
        set_property enabled true ${PARAM_VALUE.IAUX_REQUEST_REGISTER}
    } else {
        set_property enabled false ${PARAM_VALUE.IAUX_REQUEST_REGISTER}
    }
}

proc validate_PARAM_VALUE.IAUX_REQUEST_REGISTER { PARAM_VALUE.IAUX_REQUEST_REGISTER } {
    # Procedure called to validate IAUX_REQUEST_REGISTER
    return true
}

proc update_PARAM_VALUE.IAUX_RETURN_REGISTER { PARAM_VALUE.IAUX_RETURN_REGISTER PARAM_VALUE.AUX_MEMORY_REGIONS } {
    # Procedure called to update IAUX_RETURN_REGISTER when any of the dependent parameters in the arguments change
    if { [get_property value ${PARAM_VALUE.AUX_MEMORY_REGIONS} ] } {
        set_property enabled true ${PARAM_VALUE.IAUX_RETURN_REGISTER}
    } else {
        set_property enabled false ${PARAM_VALUE.IAUX_RETURN_REGISTER}
    }
}

proc validate_PARAM_VALUE.IAUX_RETURN_REGISTER { PARAM_VALUE.IAUX_RETURN_REGISTER } {
    # Procedure called to validate IAUX_RETURN_REGISTER
    return true
}

proc update_PARAM_VALUE.IC_REQUEST_REGISTER { PARAM_VALUE.IC_REQUEST_REGISTER PARAM_VALUE.ICACHE_SIZE } {
    # Procedure called to update IC_REQUEST_REGISTER when any of the dependent parameters in the arguments change
    if { [get_property value ${PARAM_VALUE.ICACHE_SIZE} ] } {
        set_property enabled true ${PARAM_VALUE.IC_REQUEST_REGISTER}
    } else {
        set_property enabled false ${PARAM_VALUE.IC_REQUEST_REGISTER}
    }
}

proc validate_PARAM_VALUE.IC_REQUEST_REGISTER { PARAM_VALUE.IC_REQUEST_REGISTER } {
    # Procedure called to validate IC_REQUEST_REGISTER
    return true
}

proc update_PARAM_VALUE.IC_RETURN_REGISTER { PARAM_VALUE.IC_RETURN_REGISTER PARAM_VALUE.ICACHE_SIZE } {
    # Procedure called to update IC_RETURN_REGISTER when any of the dependent parameters in the arguments change
    if { [get_property value ${PARAM_VALUE.ICACHE_SIZE} ] } {
        set_property enabled true ${PARAM_VALUE.IC_RETURN_REGISTER}
    } else {
        set_property enabled false ${PARAM_VALUE.IC_RETURN_REGISTER}
    }
}

proc validate_PARAM_VALUE.IC_RETURN_REGISTER { PARAM_VALUE.IC_RETURN_REGISTER } {
    # Procedure called to validate IC_RETURN_REGISTER
    return true
}

proc update_PARAM_VALUE.DCACHE_SIZE { PARAM_VALUE.DCACHE_SIZE } {
    # Procedure called to update DCACHE_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DCACHE_SIZE { PARAM_VALUE.DCACHE_SIZE } {
    # Procedure called to validate DCACHE_SIZE
    return true
}

proc update_PARAM_VALUE.DCACHE_WRITEBACK { PARAM_VALUE.DCACHE_WRITEBACK PARAM_VALUE.DCACHE_SIZE } {
    # Procedure called to update DCACHE_WRITEBACK when any of the dependent parameters in the arguments change
    if { [get_property value ${PARAM_VALUE.DCACHE_SIZE} ] } {
        set_property enabled true ${PARAM_VALUE.DCACHE_WRITEBACK}
    } else {
        set_property enabled false ${PARAM_VALUE.DCACHE_WRITEBACK}
    }
}

proc validate_PARAM_VALUE.DCACHE_WRITEBACK { PARAM_VALUE.DCACHE_WRITEBACK } {
    # Procedure called to validate DCACHE_WRITEBACK
    return true
}

proc update_PARAM_VALUE.DCACHE_LINE_SIZE { PARAM_VALUE.DCACHE_LINE_SIZE PARAM_VALUE.DCACHE_SIZE } {
    # Procedure called to update DCACHE_LINE_SIZE when any of the dependent parameters in the arguments change
    if { [get_property value ${PARAM_VALUE.DCACHE_SIZE} ] } {
        set_property enabled true ${PARAM_VALUE.DCACHE_LINE_SIZE}
    } else {
        set_property enabled false ${PARAM_VALUE.DCACHE_LINE_SIZE}
    }
}

proc validate_PARAM_VALUE.DCACHE_LINE_SIZE { PARAM_VALUE.DCACHE_LINE_SIZE } {
    # Procedure called to validate DCACHE_LINE_SIZE
    return true
}

proc update_PARAM_VALUE.DCACHE_EXTERNAL_WIDTH { PARAM_VALUE.DCACHE_EXTERNAL_WIDTH PARAM_VALUE.DCACHE_SIZE } {
    # Procedure called to update DCACHE_EXTERNAL_WIDTH when any of the dependent parameters in the arguments change
    if { [get_property value ${PARAM_VALUE.DCACHE_SIZE} ] } {
        set_property enabled true ${PARAM_VALUE.DCACHE_EXTERNAL_WIDTH}
    } else {
        set_property enabled false ${PARAM_VALUE.DCACHE_EXTERNAL_WIDTH}
    }
}

proc validate_PARAM_VALUE.DCACHE_EXTERNAL_WIDTH { PARAM_VALUE.DCACHE_EXTERNAL_WIDTH } {
    # Procedure called to validate DCACHE_EXTERNAL_WIDTH
    return true
}

proc update_PARAM_VALUE.DATA_REQUEST_REGISTER { PARAM_VALUE.DATA_REQUEST_REGISTER } {
    # Procedure called to update DATA_REQUEST_REGISTER when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_REQUEST_REGISTER { PARAM_VALUE.DATA_REQUEST_REGISTER } {
    # Procedure called to validate DATA_REQUEST_REGISTER
    return true
}

proc update_PARAM_VALUE.DATA_RETURN_REGISTER { PARAM_VALUE.DATA_RETURN_REGISTER } {
    # Procedure called to update DATA_RETURN_REGISTER when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_RETURN_REGISTER { PARAM_VALUE.DATA_RETURN_REGISTER } {
    # Procedure called to validate DATA_RETURN_REGISTER
    return true
}

proc update_PARAM_VALUE.DUC_REQUEST_REGISTER { PARAM_VALUE.DUC_REQUEST_REGISTER PARAM_VALUE.UC_MEMORY_REGIONS } {
    # Procedure called to update DUC_REQUEST_REGISTER when any of the dependent parameters in the arguments change
    if { [get_property value ${PARAM_VALUE.UC_MEMORY_REGIONS} ] } {
        set_property enabled true ${PARAM_VALUE.DUC_REQUEST_REGISTER}
    } else {
        set_property enabled false ${PARAM_VALUE.DUC_REQUEST_REGISTER}
    }
}

proc validate_PARAM_VALUE.DUC_REQUEST_REGISTER { PARAM_VALUE.DUC_REQUEST_REGISTER } {
    # Procedure called to validate DUC_REQUEST_REGISTER
    return true
}

proc update_PARAM_VALUE.DUC_RETURN_REGISTER { PARAM_VALUE.DUC_RETURN_REGISTER PARAM_VALUE.UC_MEMORY_REGIONS } {
    # Procedure called to update DUC_RETURN_REGISTER when any of the dependent parameters in the arguments change
    if { [get_property value ${PARAM_VALUE.UC_MEMORY_REGIONS} ] } {
        set_property enabled true ${PARAM_VALUE.DUC_RETURN_REGISTER}
    } else {
        set_property enabled false ${PARAM_VALUE.DUC_RETURN_REGISTER}
    }
}

proc validate_PARAM_VALUE.DUC_RETURN_REGISTER { PARAM_VALUE.DUC_RETURN_REGISTER } {
    # Procedure called to validate DUC_RETURN_REGISTER
    return true
}

proc update_PARAM_VALUE.DAUX_REQUEST_REGISTER { PARAM_VALUE.DAUX_REQUEST_REGISTER PARAM_VALUE.AUX_MEMORY_REGIONS } {
    # Procedure called to update DAUX_REQUEST_REGISTER when any of the dependent parameters in the arguments change
    if { [get_property value ${PARAM_VALUE.AUX_MEMORY_REGIONS} ] } {
        set_property enabled true ${PARAM_VALUE.DAUX_REQUEST_REGISTER}
    } else {
        set_property enabled false ${PARAM_VALUE.DAUX_REQUEST_REGISTER}
    }
}

proc validate_PARAM_VALUE.DAUX_REQUEST_REGISTER { PARAM_VALUE.DAUX_REQUEST_REGISTER } {
    # Procedure called to validate DAUX_REQUEST_REGISTER
    return true
}

proc update_PARAM_VALUE.DAUX_RETURN_REGISTER { PARAM_VALUE.DAUX_RETURN_REGISTER PARAM_VALUE.AUX_MEMORY_REGIONS } {
    # Procedure called to update DAUX_RETURN_REGISTER when any of the dependent parameters in the arguments change
    if { [get_property value ${PARAM_VALUE.AUX_MEMORY_REGIONS} ] } {
        set_property enabled true ${PARAM_VALUE.DAUX_RETURN_REGISTER}
    } else {
        set_property enabled false ${PARAM_VALUE.DAUX_RETURN_REGISTER}
    }
}

proc validate_PARAM_VALUE.DAUX_RETURN_REGISTER { PARAM_VALUE.DAUX_RETURN_REGISTER } {
    # Procedure called to validate DAUX_RETURN_REGISTER
    return true
}

proc update_PARAM_VALUE.DC_REQUEST_REGISTER { PARAM_VALUE.DC_REQUEST_REGISTER PARAM_VALUE.DCACHE_SIZE } {
    # Procedure called to update DC_REQUEST_REGISTER when any of the dependent parameters in the arguments change
    if { [get_property value ${PARAM_VALUE.DCACHE_SIZE} ] } {
        set_property enabled true ${PARAM_VALUE.DC_REQUEST_REGISTER}
    } else {
        set_property enabled false ${PARAM_VALUE.DC_REQUEST_REGISTER}
    }
}

proc validate_PARAM_VALUE.DC_REQUEST_REGISTER { PARAM_VALUE.DC_REQUEST_REGISTER } {
    # Procedure called to validate DC_REQUEST_REGISTER
    return true
}

proc update_PARAM_VALUE.DC_RETURN_REGISTER { PARAM_VALUE.DC_RETURN_REGISTER PARAM_VALUE.DCACHE_SIZE } {
    # Procedure called to update DC_RETURN_REGISTER when any of the dependent parameters in the arguments change
    if { [get_property value ${PARAM_VALUE.DCACHE_SIZE} ] } {
        set_property enabled true ${PARAM_VALUE.DC_RETURN_REGISTER}
    } else {
        set_property enabled false ${PARAM_VALUE.DC_RETURN_REGISTER}
    }
}

proc validate_PARAM_VALUE.DC_RETURN_REGISTER { PARAM_VALUE.DC_RETURN_REGISTER } {
    # Procedure called to validate DC_RETURN_REGISTER
    return true
}

proc update_MODELPARAM_VALUE.REGISTER_SIZE { MODELPARAM_VALUE.REGISTER_SIZE PARAM_VALUE.REGISTER_SIZE } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.REGISTER_SIZE}] ${MODELPARAM_VALUE.REGISTER_SIZE}
}

proc update_MODELPARAM_VALUE.RESET_VECTOR { MODELPARAM_VALUE.RESET_VECTOR PARAM_VALUE.RESET_VECTOR } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.RESET_VECTOR}] ${MODELPARAM_VALUE.RESET_VECTOR}
}

proc update_MODELPARAM_VALUE.INTERRUPT_VECTOR { MODELPARAM_VALUE.INTERRUPT_VECTOR PARAM_VALUE.INTERRUPT_VECTOR } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.INTERRUPT_VECTOR}] ${MODELPARAM_VALUE.INTERRUPT_VECTOR}
}

proc update_MODELPARAM_VALUE.MAX_IFETCHES_IN_FLIGHT { MODELPARAM_VALUE.MAX_IFETCHES_IN_FLIGHT PARAM_VALUE.MAX_IFETCHES_IN_FLIGHT } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.MAX_IFETCHES_IN_FLIGHT}] ${MODELPARAM_VALUE.MAX_IFETCHES_IN_FLIGHT}
}

proc update_MODELPARAM_VALUE.BTB_ENTRIES { MODELPARAM_VALUE.BTB_ENTRIES PARAM_VALUE.BTB_ENTRIES } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.BTB_ENTRIES}] ${MODELPARAM_VALUE.BTB_ENTRIES}
}

proc update_MODELPARAM_VALUE.MULTIPLY_ENABLE { MODELPARAM_VALUE.MULTIPLY_ENABLE PARAM_VALUE.MULTIPLY_ENABLE } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.MULTIPLY_ENABLE}] ${MODELPARAM_VALUE.MULTIPLY_ENABLE}
}

proc update_MODELPARAM_VALUE.DIVIDE_ENABLE { MODELPARAM_VALUE.DIVIDE_ENABLE PARAM_VALUE.DIVIDE_ENABLE } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.DIVIDE_ENABLE}] ${MODELPARAM_VALUE.DIVIDE_ENABLE}
}

proc update_MODELPARAM_VALUE.SHIFTER_MAX_CYCLES { MODELPARAM_VALUE.SHIFTER_MAX_CYCLES PARAM_VALUE.SHIFTER_MAX_CYCLES } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.SHIFTER_MAX_CYCLES}] ${MODELPARAM_VALUE.SHIFTER_MAX_CYCLES}
}

proc update_MODELPARAM_VALUE.ENABLE_EXCEPTIONS { MODELPARAM_VALUE.ENABLE_EXCEPTIONS PARAM_VALUE.ENABLE_EXCEPTIONS } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.ENABLE_EXCEPTIONS}] ${MODELPARAM_VALUE.ENABLE_EXCEPTIONS}
}

proc update_MODELPARAM_VALUE.PIPELINE_STAGES { MODELPARAM_VALUE.PIPELINE_STAGES PARAM_VALUE.PIPELINE_STAGES } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.PIPELINE_STAGES}] ${MODELPARAM_VALUE.PIPELINE_STAGES}
}

proc update_MODELPARAM_VALUE.VCP_ENABLE { MODELPARAM_VALUE.VCP_ENABLE PARAM_VALUE.VCP_ENABLE } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.VCP_ENABLE}] ${MODELPARAM_VALUE.VCP_ENABLE}
}

proc update_MODELPARAM_VALUE.ENABLE_EXT_INTERRUPTS { MODELPARAM_VALUE.ENABLE_EXT_INTERRUPTS PARAM_VALUE.ENABLE_EXT_INTERRUPTS } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.ENABLE_EXT_INTERRUPTS}] ${MODELPARAM_VALUE.ENABLE_EXT_INTERRUPTS}
}

proc update_MODELPARAM_VALUE.NUM_EXT_INTERRUPTS { MODELPARAM_VALUE.NUM_EXT_INTERRUPTS PARAM_VALUE.NUM_EXT_INTERRUPTS } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.NUM_EXT_INTERRUPTS}] ${MODELPARAM_VALUE.NUM_EXT_INTERRUPTS}
}

proc update_MODELPARAM_VALUE.POWER_OPTIMIZED { MODELPARAM_VALUE.POWER_OPTIMIZED PARAM_VALUE.POWER_OPTIMIZED } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.POWER_OPTIMIZED}] ${MODELPARAM_VALUE.POWER_OPTIMIZED}
}

proc update_MODELPARAM_VALUE.FAMILY { MODELPARAM_VALUE.FAMILY PARAM_VALUE.FAMILY } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.FAMILY}] ${MODELPARAM_VALUE.FAMILY}
}

proc update_MODELPARAM_VALUE.LOG2_BURSTLENGTH { MODELPARAM_VALUE.LOG2_BURSTLENGTH PARAM_VALUE.LOG2_BURSTLENGTH } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.LOG2_BURSTLENGTH}] ${MODELPARAM_VALUE.LOG2_BURSTLENGTH}
}

proc update_MODELPARAM_VALUE.AXI_ID_WIDTH { MODELPARAM_VALUE.AXI_ID_WIDTH PARAM_VALUE.AXI_ID_WIDTH } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.AXI_ID_WIDTH}] ${MODELPARAM_VALUE.AXI_ID_WIDTH}
}

proc update_MODELPARAM_VALUE.AVALON_AUX { MODELPARAM_VALUE.AVALON_AUX PARAM_VALUE.AVALON_AUX } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.AVALON_AUX}] ${MODELPARAM_VALUE.AVALON_AUX}
}

proc update_MODELPARAM_VALUE.LMB_AUX { MODELPARAM_VALUE.LMB_AUX PARAM_VALUE.LMB_AUX } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.LMB_AUX}] ${MODELPARAM_VALUE.LMB_AUX}
}

proc update_MODELPARAM_VALUE.WISHBONE_AUX { MODELPARAM_VALUE.WISHBONE_AUX PARAM_VALUE.WISHBONE_AUX } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.WISHBONE_AUX}] ${MODELPARAM_VALUE.WISHBONE_AUX}
}

proc update_MODELPARAM_VALUE.AUX_MEMORY_REGIONS { MODELPARAM_VALUE.AUX_MEMORY_REGIONS PARAM_VALUE.AUX_MEMORY_REGIONS } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.AUX_MEMORY_REGIONS}] ${MODELPARAM_VALUE.AUX_MEMORY_REGIONS}
}

proc update_MODELPARAM_VALUE.AMR0_ADDR_BASE { MODELPARAM_VALUE.AMR0_ADDR_BASE PARAM_VALUE.AMR0_ADDR_BASE } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.AMR0_ADDR_BASE}] ${MODELPARAM_VALUE.AMR0_ADDR_BASE}
}

proc update_MODELPARAM_VALUE.AMR0_ADDR_LAST { MODELPARAM_VALUE.AMR0_ADDR_LAST PARAM_VALUE.AMR0_ADDR_LAST } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) lastd on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.AMR0_ADDR_LAST}] ${MODELPARAM_VALUE.AMR0_ADDR_LAST}
}

proc update_MODELPARAM_VALUE.AMR0_READ_ONLY { MODELPARAM_VALUE.AMR0_READ_ONLY PARAM_VALUE.AMR0_READ_ONLY } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) lastd on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.AMR0_READ_ONLY}] ${MODELPARAM_VALUE.AMR0_READ_ONLY}
}

proc update_MODELPARAM_VALUE.UC_MEMORY_REGIONS { MODELPARAM_VALUE.UC_MEMORY_REGIONS PARAM_VALUE.UC_MEMORY_REGIONS } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.UC_MEMORY_REGIONS}] ${MODELPARAM_VALUE.UC_MEMORY_REGIONS}
}

proc update_MODELPARAM_VALUE.UMR0_ADDR_BASE { MODELPARAM_VALUE.UMR0_ADDR_BASE PARAM_VALUE.UMR0_ADDR_BASE } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.UMR0_ADDR_BASE}] ${MODELPARAM_VALUE.UMR0_ADDR_BASE}
}

proc update_MODELPARAM_VALUE.UMR0_ADDR_LAST { MODELPARAM_VALUE.UMR0_ADDR_LAST PARAM_VALUE.UMR0_ADDR_LAST } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) lastd on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.UMR0_ADDR_LAST}] ${MODELPARAM_VALUE.UMR0_ADDR_LAST}
}

proc update_MODELPARAM_VALUE.UMR0_READ_ONLY { MODELPARAM_VALUE.UMR0_READ_ONLY PARAM_VALUE.UMR0_READ_ONLY } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) lastd on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.UMR0_READ_ONLY}] ${MODELPARAM_VALUE.UMR0_READ_ONLY}
}

proc update_MODELPARAM_VALUE.ICACHE_SIZE { MODELPARAM_VALUE.ICACHE_SIZE PARAM_VALUE.ICACHE_SIZE } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.ICACHE_SIZE}] ${MODELPARAM_VALUE.ICACHE_SIZE}
}

proc update_MODELPARAM_VALUE.ICACHE_LINE_SIZE { MODELPARAM_VALUE.ICACHE_LINE_SIZE PARAM_VALUE.ICACHE_LINE_SIZE } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.ICACHE_LINE_SIZE}] ${MODELPARAM_VALUE.ICACHE_LINE_SIZE}
}

proc update_MODELPARAM_VALUE.ICACHE_EXTERNAL_WIDTH { MODELPARAM_VALUE.ICACHE_EXTERNAL_WIDTH PARAM_VALUE.ICACHE_EXTERNAL_WIDTH } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.ICACHE_EXTERNAL_WIDTH}] ${MODELPARAM_VALUE.ICACHE_EXTERNAL_WIDTH}
}

proc update_MODELPARAM_VALUE.INSTRUCTION_REQUEST_REGISTER { MODELPARAM_VALUE.INSTRUCTION_REQUEST_REGISTER PARAM_VALUE.INSTRUCTION_REQUEST_REGISTER } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.INSTRUCTION_REQUEST_REGISTER}] ${MODELPARAM_VALUE.INSTRUCTION_REQUEST_REGISTER}
}

proc update_MODELPARAM_VALUE.INSTRUCTION_RETURN_REGISTER { MODELPARAM_VALUE.INSTRUCTION_RETURN_REGISTER PARAM_VALUE.INSTRUCTION_RETURN_REGISTER } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.INSTRUCTION_RETURN_REGISTER}] ${MODELPARAM_VALUE.INSTRUCTION_RETURN_REGISTER}
}

proc update_MODELPARAM_VALUE.IUC_REQUEST_REGISTER { MODELPARAM_VALUE.IUC_REQUEST_REGISTER PARAM_VALUE.IUC_REQUEST_REGISTER } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.IUC_REQUEST_REGISTER}] ${MODELPARAM_VALUE.IUC_REQUEST_REGISTER}
}

proc update_MODELPARAM_VALUE.IUC_RETURN_REGISTER { MODELPARAM_VALUE.IUC_RETURN_REGISTER PARAM_VALUE.IUC_RETURN_REGISTER } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.IUC_RETURN_REGISTER}] ${MODELPARAM_VALUE.IUC_RETURN_REGISTER}
}

proc update_MODELPARAM_VALUE.IAUX_REQUEST_REGISTER { MODELPARAM_VALUE.IAUX_REQUEST_REGISTER PARAM_VALUE.IAUX_REQUEST_REGISTER } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.IAUX_REQUEST_REGISTER}] ${MODELPARAM_VALUE.IAUX_REQUEST_REGISTER}
}

proc update_MODELPARAM_VALUE.IAUX_RETURN_REGISTER { MODELPARAM_VALUE.IAUX_RETURN_REGISTER PARAM_VALUE.IAUX_RETURN_REGISTER } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.IAUX_RETURN_REGISTER}] ${MODELPARAM_VALUE.IAUX_RETURN_REGISTER}
}

proc update_MODELPARAM_VALUE.IC_REQUEST_REGISTER { MODELPARAM_VALUE.IC_REQUEST_REGISTER PARAM_VALUE.IC_REQUEST_REGISTER } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.IC_REQUEST_REGISTER}] ${MODELPARAM_VALUE.IC_REQUEST_REGISTER}
}

proc update_MODELPARAM_VALUE.IC_RETURN_REGISTER { MODELPARAM_VALUE.IC_RETURN_REGISTER PARAM_VALUE.IC_RETURN_REGISTER } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.IC_RETURN_REGISTER}] ${MODELPARAM_VALUE.IC_RETURN_REGISTER}
}

proc update_MODELPARAM_VALUE.DCACHE_SIZE { MODELPARAM_VALUE.DCACHE_SIZE PARAM_VALUE.DCACHE_SIZE } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.DCACHE_SIZE}] ${MODELPARAM_VALUE.DCACHE_SIZE}
}

proc update_MODELPARAM_VALUE.DCACHE_WRITEBACK { MODELPARAM_VALUE.DCACHE_WRITEBACK PARAM_VALUE.DCACHE_WRITEBACK } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.DCACHE_WRITEBACK}] ${MODELPARAM_VALUE.DCACHE_WRITEBACK}
}

proc update_MODELPARAM_VALUE.DCACHE_LINE_SIZE { MODELPARAM_VALUE.DCACHE_LINE_SIZE PARAM_VALUE.DCACHE_LINE_SIZE } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.DCACHE_LINE_SIZE}] ${MODELPARAM_VALUE.DCACHE_LINE_SIZE}
}

proc update_MODELPARAM_VALUE.DCACHE_EXTERNAL_WIDTH { MODELPARAM_VALUE.DCACHE_EXTERNAL_WIDTH PARAM_VALUE.DCACHE_EXTERNAL_WIDTH } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.DCACHE_EXTERNAL_WIDTH}] ${MODELPARAM_VALUE.DCACHE_EXTERNAL_WIDTH}
}

proc update_MODELPARAM_VALUE.DATA_REQUEST_REGISTER { MODELPARAM_VALUE.DATA_REQUEST_REGISTER PARAM_VALUE.DATA_REQUEST_REGISTER } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.DATA_REQUEST_REGISTER}] ${MODELPARAM_VALUE.DATA_REQUEST_REGISTER}
}

proc update_MODELPARAM_VALUE.DATA_RETURN_REGISTER { MODELPARAM_VALUE.DATA_RETURN_REGISTER PARAM_VALUE.DATA_RETURN_REGISTER } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.DATA_RETURN_REGISTER}] ${MODELPARAM_VALUE.DATA_RETURN_REGISTER}
}

proc update_MODELPARAM_VALUE.DUC_REQUEST_REGISTER { MODELPARAM_VALUE.DUC_REQUEST_REGISTER PARAM_VALUE.DUC_REQUEST_REGISTER } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.DUC_REQUEST_REGISTER}] ${MODELPARAM_VALUE.DUC_REQUEST_REGISTER}
}

proc update_MODELPARAM_VALUE.DUC_RETURN_REGISTER { MODELPARAM_VALUE.DUC_RETURN_REGISTER PARAM_VALUE.DUC_RETURN_REGISTER } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.DUC_RETURN_REGISTER}] ${MODELPARAM_VALUE.DUC_RETURN_REGISTER}
}

proc update_MODELPARAM_VALUE.DAUX_REQUEST_REGISTER { MODELPARAM_VALUE.DAUX_REQUEST_REGISTER PARAM_VALUE.DAUX_REQUEST_REGISTER } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.DAUX_REQUEST_REGISTER}] ${MODELPARAM_VALUE.DAUX_REQUEST_REGISTER}
}

proc update_MODELPARAM_VALUE.DAUX_RETURN_REGISTER { MODELPARAM_VALUE.DAUX_RETURN_REGISTER PARAM_VALUE.DAUX_RETURN_REGISTER } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.DAUX_RETURN_REGISTER}] ${MODELPARAM_VALUE.DAUX_RETURN_REGISTER}
}

proc update_MODELPARAM_VALUE.DC_REQUEST_REGISTER { MODELPARAM_VALUE.DC_REQUEST_REGISTER PARAM_VALUE.DC_REQUEST_REGISTER } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.DC_REQUEST_REGISTER}] ${MODELPARAM_VALUE.DC_REQUEST_REGISTER}
}

proc update_MODELPARAM_VALUE.DC_RETURN_REGISTER { MODELPARAM_VALUE.DC_RETURN_REGISTER PARAM_VALUE.DC_RETURN_REGISTER } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.DC_RETURN_REGISTER}] ${MODELPARAM_VALUE.DC_RETURN_REGISTER}
}
