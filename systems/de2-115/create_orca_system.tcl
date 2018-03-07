

# module properties



# default module properties








proc compose { } {
    # Instances and instance parameters
    # (disabled instances are intentionally culled)
    add_instance hex_0 altera_avalon_pio 15.1
    set_instance_parameter_value hex_0 {bitClearingEdgeCapReg} {0}
    set_instance_parameter_value hex_0 {bitModifyingOutReg} {0}
    set_instance_parameter_value hex_0 {captureEdge} {0}
    set_instance_parameter_value hex_0 {direction} {Output}
    set_instance_parameter_value hex_0 {edgeType} {RISING}
    set_instance_parameter_value hex_0 {generateIRQ} {0}
    set_instance_parameter_value hex_0 {irqType} {LEVEL}
    set_instance_parameter_value hex_0 {resetValue} {0.0}
    set_instance_parameter_value hex_0 {simDoTestBenchWiring} {0}
    set_instance_parameter_value hex_0 {simDrivenValue} {0.0}
    set_instance_parameter_value hex_0 {width} {32}

    add_instance hex_1 altera_avalon_pio 15.1
    set_instance_parameter_value hex_1 {bitClearingEdgeCapReg} {0}
    set_instance_parameter_value hex_1 {bitModifyingOutReg} {0}
    set_instance_parameter_value hex_1 {captureEdge} {0}
    set_instance_parameter_value hex_1 {direction} {Output}
    set_instance_parameter_value hex_1 {edgeType} {RISING}
    set_instance_parameter_value hex_1 {generateIRQ} {0}
    set_instance_parameter_value hex_1 {irqType} {LEVEL}
    set_instance_parameter_value hex_1 {resetValue} {0.0}
    set_instance_parameter_value hex_1 {simDoTestBenchWiring} {0}
    set_instance_parameter_value hex_1 {simDrivenValue} {0.0}
    set_instance_parameter_value hex_1 {width} {32}

    add_instance hex_2 altera_avalon_pio 15.1
    set_instance_parameter_value hex_2 {bitClearingEdgeCapReg} {0}
    set_instance_parameter_value hex_2 {bitModifyingOutReg} {0}
    set_instance_parameter_value hex_2 {captureEdge} {0}
    set_instance_parameter_value hex_2 {direction} {Output}
    set_instance_parameter_value hex_2 {edgeType} {RISING}
    set_instance_parameter_value hex_2 {generateIRQ} {0}
    set_instance_parameter_value hex_2 {irqType} {LEVEL}
    set_instance_parameter_value hex_2 {resetValue} {0.0}
    set_instance_parameter_value hex_2 {simDoTestBenchWiring} {0}
    set_instance_parameter_value hex_2 {simDrivenValue} {0.0}
    set_instance_parameter_value hex_2 {width} {32}

    add_instance hex_3 altera_avalon_pio 15.1
    set_instance_parameter_value hex_3 {bitClearingEdgeCapReg} {0}
    set_instance_parameter_value hex_3 {bitModifyingOutReg} {0}
    set_instance_parameter_value hex_3 {captureEdge} {0}
    set_instance_parameter_value hex_3 {direction} {Output}
    set_instance_parameter_value hex_3 {edgeType} {RISING}
    set_instance_parameter_value hex_3 {generateIRQ} {0}
    set_instance_parameter_value hex_3 {irqType} {LEVEL}
    set_instance_parameter_value hex_3 {resetValue} {0.0}
    set_instance_parameter_value hex_3 {simDoTestBenchWiring} {0}
    set_instance_parameter_value hex_3 {simDrivenValue} {0.0}
    set_instance_parameter_value hex_3 {width} {32}

    add_instance ledg altera_avalon_pio 15.1
    set_instance_parameter_value ledg {bitClearingEdgeCapReg} {0}
    set_instance_parameter_value ledg {bitModifyingOutReg} {0}
    set_instance_parameter_value ledg {captureEdge} {0}
    set_instance_parameter_value ledg {direction} {Output}
    set_instance_parameter_value ledg {edgeType} {RISING}
    set_instance_parameter_value ledg {generateIRQ} {0}
    set_instance_parameter_value ledg {irqType} {LEVEL}
    set_instance_parameter_value ledg {resetValue} {0.0}
    set_instance_parameter_value ledg {simDoTestBenchWiring} {0}
    set_instance_parameter_value ledg {simDrivenValue} {0.0}
    set_instance_parameter_value ledg {width} {32}

    add_instance ledr altera_avalon_pio 15.1
    set_instance_parameter_value ledr {bitClearingEdgeCapReg} {0}
    set_instance_parameter_value ledr {bitModifyingOutReg} {0}
    set_instance_parameter_value ledr {captureEdge} {0}
    set_instance_parameter_value ledr {direction} {Output}
    set_instance_parameter_value ledr {edgeType} {RISING}
    set_instance_parameter_value ledr {generateIRQ} {0}
    set_instance_parameter_value ledr {irqType} {LEVEL}
    set_instance_parameter_value ledr {resetValue} {0.0}
    set_instance_parameter_value ledr {simDoTestBenchWiring} {0}
    set_instance_parameter_value ledr {simDrivenValue} {0.0}
    set_instance_parameter_value ledr {width} {32}

    add_instance the_altpll altpll 15.1
    set_instance_parameter_value the_altpll {HIDDEN_CUSTOM_ELABORATION} {altpll_avalon_elaboration}
    set_instance_parameter_value the_altpll {HIDDEN_CUSTOM_POST_EDIT} {altpll_avalon_post_edit}
    set_instance_parameter_value the_altpll {INTENDED_DEVICE_FAMILY} {Cyclone IV E}
    set_instance_parameter_value the_altpll {WIDTH_CLOCK} {5}
    set_instance_parameter_value the_altpll {WIDTH_PHASECOUNTERSELECT} {}
    set_instance_parameter_value the_altpll {PRIMARY_CLOCK} {}
    set_instance_parameter_value the_altpll {INCLK0_INPUT_FREQUENCY} {20000}
    set_instance_parameter_value the_altpll {INCLK1_INPUT_FREQUENCY} {}
    set_instance_parameter_value the_altpll {OPERATION_MODE} {NORMAL}
    set_instance_parameter_value the_altpll {PLL_TYPE} {AUTO}
    set_instance_parameter_value the_altpll {QUALIFY_CONF_DONE} {}
    set_instance_parameter_value the_altpll {COMPENSATE_CLOCK} {CLK0}
    set_instance_parameter_value the_altpll {SCAN_CHAIN} {}
    set_instance_parameter_value the_altpll {GATE_LOCK_SIGNAL} {}
    set_instance_parameter_value the_altpll {GATE_LOCK_COUNTER} {}
    set_instance_parameter_value the_altpll {LOCK_HIGH} {}
    set_instance_parameter_value the_altpll {LOCK_LOW} {}
    set_instance_parameter_value the_altpll {VALID_LOCK_MULTIPLIER} {}
    set_instance_parameter_value the_altpll {INVALID_LOCK_MULTIPLIER} {}
    set_instance_parameter_value the_altpll {SWITCH_OVER_ON_LOSSCLK} {}
    set_instance_parameter_value the_altpll {SWITCH_OVER_ON_GATED_LOCK} {}
    set_instance_parameter_value the_altpll {ENABLE_SWITCH_OVER_COUNTER} {}
    set_instance_parameter_value the_altpll {SKIP_VCO} {}
    set_instance_parameter_value the_altpll {SWITCH_OVER_COUNTER} {}
    set_instance_parameter_value the_altpll {SWITCH_OVER_TYPE} {}
    set_instance_parameter_value the_altpll {FEEDBACK_SOURCE} {}
    set_instance_parameter_value the_altpll {BANDWIDTH} {}
    set_instance_parameter_value the_altpll {BANDWIDTH_TYPE} {AUTO}
    set_instance_parameter_value the_altpll {SPREAD_FREQUENCY} {}
    set_instance_parameter_value the_altpll {DOWN_SPREAD} {}
    set_instance_parameter_value the_altpll {SELF_RESET_ON_GATED_LOSS_LOCK} {}
    set_instance_parameter_value the_altpll {SELF_RESET_ON_LOSS_LOCK} {}
    set_instance_parameter_value the_altpll {CLK0_MULTIPLY_BY} {2}
    set_instance_parameter_value the_altpll {CLK1_MULTIPLY_BY} {}
    set_instance_parameter_value the_altpll {CLK2_MULTIPLY_BY} {}
    set_instance_parameter_value the_altpll {CLK3_MULTIPLY_BY} {}
    set_instance_parameter_value the_altpll {CLK4_MULTIPLY_BY} {}
    set_instance_parameter_value the_altpll {CLK5_MULTIPLY_BY} {}
    set_instance_parameter_value the_altpll {CLK6_MULTIPLY_BY} {}
    set_instance_parameter_value the_altpll {CLK7_MULTIPLY_BY} {}
    set_instance_parameter_value the_altpll {CLK8_MULTIPLY_BY} {}
    set_instance_parameter_value the_altpll {CLK9_MULTIPLY_BY} {}
    set_instance_parameter_value the_altpll {EXTCLK0_MULTIPLY_BY} {}
    set_instance_parameter_value the_altpll {EXTCLK1_MULTIPLY_BY} {}
    set_instance_parameter_value the_altpll {EXTCLK2_MULTIPLY_BY} {}
    set_instance_parameter_value the_altpll {EXTCLK3_MULTIPLY_BY} {}
    set_instance_parameter_value the_altpll {CLK0_DIVIDE_BY} {1}
    set_instance_parameter_value the_altpll {CLK1_DIVIDE_BY} {}
    set_instance_parameter_value the_altpll {CLK2_DIVIDE_BY} {}
    set_instance_parameter_value the_altpll {CLK3_DIVIDE_BY} {}
    set_instance_parameter_value the_altpll {CLK4_DIVIDE_BY} {}
    set_instance_parameter_value the_altpll {CLK5_DIVIDE_BY} {}
    set_instance_parameter_value the_altpll {CLK6_DIVIDE_BY} {}
    set_instance_parameter_value the_altpll {CLK7_DIVIDE_BY} {}
    set_instance_parameter_value the_altpll {CLK8_DIVIDE_BY} {}
    set_instance_parameter_value the_altpll {CLK9_DIVIDE_BY} {}
    set_instance_parameter_value the_altpll {EXTCLK0_DIVIDE_BY} {}
    set_instance_parameter_value the_altpll {EXTCLK1_DIVIDE_BY} {}
    set_instance_parameter_value the_altpll {EXTCLK2_DIVIDE_BY} {}
    set_instance_parameter_value the_altpll {EXTCLK3_DIVIDE_BY} {}
    set_instance_parameter_value the_altpll {CLK0_PHASE_SHIFT} {0}
    set_instance_parameter_value the_altpll {CLK1_PHASE_SHIFT} {}
    set_instance_parameter_value the_altpll {CLK2_PHASE_SHIFT} {}
    set_instance_parameter_value the_altpll {CLK3_PHASE_SHIFT} {}
    set_instance_parameter_value the_altpll {CLK4_PHASE_SHIFT} {}
    set_instance_parameter_value the_altpll {CLK5_PHASE_SHIFT} {}
    set_instance_parameter_value the_altpll {CLK6_PHASE_SHIFT} {}
    set_instance_parameter_value the_altpll {CLK7_PHASE_SHIFT} {}
    set_instance_parameter_value the_altpll {CLK8_PHASE_SHIFT} {}
    set_instance_parameter_value the_altpll {CLK9_PHASE_SHIFT} {}
    set_instance_parameter_value the_altpll {EXTCLK0_PHASE_SHIFT} {}
    set_instance_parameter_value the_altpll {EXTCLK1_PHASE_SHIFT} {}
    set_instance_parameter_value the_altpll {EXTCLK2_PHASE_SHIFT} {}
    set_instance_parameter_value the_altpll {EXTCLK3_PHASE_SHIFT} {}
    set_instance_parameter_value the_altpll {CLK0_DUTY_CYCLE} {50}
    set_instance_parameter_value the_altpll {CLK1_DUTY_CYCLE} {}
    set_instance_parameter_value the_altpll {CLK2_DUTY_CYCLE} {}
    set_instance_parameter_value the_altpll {CLK3_DUTY_CYCLE} {}
    set_instance_parameter_value the_altpll {CLK4_DUTY_CYCLE} {}
    set_instance_parameter_value the_altpll {CLK5_DUTY_CYCLE} {}
    set_instance_parameter_value the_altpll {CLK6_DUTY_CYCLE} {}
    set_instance_parameter_value the_altpll {CLK7_DUTY_CYCLE} {}
    set_instance_parameter_value the_altpll {CLK8_DUTY_CYCLE} {}
    set_instance_parameter_value the_altpll {CLK9_DUTY_CYCLE} {}
    set_instance_parameter_value the_altpll {EXTCLK0_DUTY_CYCLE} {}
    set_instance_parameter_value the_altpll {EXTCLK1_DUTY_CYCLE} {}
    set_instance_parameter_value the_altpll {EXTCLK2_DUTY_CYCLE} {}
    set_instance_parameter_value the_altpll {EXTCLK3_DUTY_CYCLE} {}
    set_instance_parameter_value the_altpll {PORT_clkena0} {PORT_UNUSED}
    set_instance_parameter_value the_altpll {PORT_clkena1} {PORT_UNUSED}
    set_instance_parameter_value the_altpll {PORT_clkena2} {PORT_UNUSED}
    set_instance_parameter_value the_altpll {PORT_clkena3} {PORT_UNUSED}
    set_instance_parameter_value the_altpll {PORT_clkena4} {PORT_UNUSED}
    set_instance_parameter_value the_altpll {PORT_clkena5} {PORT_UNUSED}
    set_instance_parameter_value the_altpll {PORT_extclkena0} {}
    set_instance_parameter_value the_altpll {PORT_extclkena1} {}
    set_instance_parameter_value the_altpll {PORT_extclkena2} {}
    set_instance_parameter_value the_altpll {PORT_extclkena3} {}
    set_instance_parameter_value the_altpll {PORT_extclk0} {PORT_UNUSED}
    set_instance_parameter_value the_altpll {PORT_extclk1} {PORT_UNUSED}
    set_instance_parameter_value the_altpll {PORT_extclk2} {PORT_UNUSED}
    set_instance_parameter_value the_altpll {PORT_extclk3} {PORT_UNUSED}
    set_instance_parameter_value the_altpll {PORT_CLKBAD0} {PORT_UNUSED}
    set_instance_parameter_value the_altpll {PORT_CLKBAD1} {PORT_UNUSED}
    set_instance_parameter_value the_altpll {PORT_clk0} {PORT_USED}
    set_instance_parameter_value the_altpll {PORT_clk1} {PORT_UNUSED}
    set_instance_parameter_value the_altpll {PORT_clk2} {PORT_UNUSED}
    set_instance_parameter_value the_altpll {PORT_clk3} {PORT_UNUSED}
    set_instance_parameter_value the_altpll {PORT_clk4} {PORT_UNUSED}
    set_instance_parameter_value the_altpll {PORT_clk5} {PORT_UNUSED}
    set_instance_parameter_value the_altpll {PORT_clk6} {}
    set_instance_parameter_value the_altpll {PORT_clk7} {}
    set_instance_parameter_value the_altpll {PORT_clk8} {}
    set_instance_parameter_value the_altpll {PORT_clk9} {}
    set_instance_parameter_value the_altpll {PORT_SCANDATA} {PORT_UNUSED}
    set_instance_parameter_value the_altpll {PORT_SCANDATAOUT} {PORT_UNUSED}
    set_instance_parameter_value the_altpll {PORT_SCANDONE} {PORT_UNUSED}
    set_instance_parameter_value the_altpll {PORT_SCLKOUT1} {}
    set_instance_parameter_value the_altpll {PORT_SCLKOUT0} {}
    set_instance_parameter_value the_altpll {PORT_ACTIVECLOCK} {PORT_UNUSED}
    set_instance_parameter_value the_altpll {PORT_CLKLOSS} {PORT_UNUSED}
    set_instance_parameter_value the_altpll {PORT_INCLK1} {PORT_UNUSED}
    set_instance_parameter_value the_altpll {PORT_INCLK0} {PORT_USED}
    set_instance_parameter_value the_altpll {PORT_FBIN} {PORT_UNUSED}
    set_instance_parameter_value the_altpll {PORT_PLLENA} {PORT_UNUSED}
    set_instance_parameter_value the_altpll {PORT_CLKSWITCH} {PORT_UNUSED}
    set_instance_parameter_value the_altpll {PORT_ARESET} {PORT_USED}
    set_instance_parameter_value the_altpll {PORT_PFDENA} {PORT_UNUSED}
    set_instance_parameter_value the_altpll {PORT_SCANCLK} {PORT_UNUSED}
    set_instance_parameter_value the_altpll {PORT_SCANACLR} {PORT_UNUSED}
    set_instance_parameter_value the_altpll {PORT_SCANREAD} {PORT_UNUSED}
    set_instance_parameter_value the_altpll {PORT_SCANWRITE} {PORT_UNUSED}
    set_instance_parameter_value the_altpll {PORT_ENABLE0} {}
    set_instance_parameter_value the_altpll {PORT_ENABLE1} {}
    set_instance_parameter_value the_altpll {PORT_LOCKED} {PORT_USED}
    set_instance_parameter_value the_altpll {PORT_CONFIGUPDATE} {PORT_UNUSED}
    set_instance_parameter_value the_altpll {PORT_FBOUT} {}
    set_instance_parameter_value the_altpll {PORT_PHASEDONE} {PORT_UNUSED}
    set_instance_parameter_value the_altpll {PORT_PHASESTEP} {PORT_UNUSED}
    set_instance_parameter_value the_altpll {PORT_PHASEUPDOWN} {PORT_UNUSED}
    set_instance_parameter_value the_altpll {PORT_SCANCLKENA} {PORT_UNUSED}
    set_instance_parameter_value the_altpll {PORT_PHASECOUNTERSELECT} {PORT_UNUSED}
    set_instance_parameter_value the_altpll {PORT_VCOOVERRANGE} {}
    set_instance_parameter_value the_altpll {PORT_VCOUNDERRANGE} {}
    set_instance_parameter_value the_altpll {DPA_MULTIPLY_BY} {}
    set_instance_parameter_value the_altpll {DPA_DIVIDE_BY} {}
    set_instance_parameter_value the_altpll {DPA_DIVIDER} {}
    set_instance_parameter_value the_altpll {VCO_MULTIPLY_BY} {}
    set_instance_parameter_value the_altpll {VCO_DIVIDE_BY} {}
    set_instance_parameter_value the_altpll {SCLKOUT0_PHASE_SHIFT} {}
    set_instance_parameter_value the_altpll {SCLKOUT1_PHASE_SHIFT} {}
    set_instance_parameter_value the_altpll {VCO_FREQUENCY_CONTROL} {}
    set_instance_parameter_value the_altpll {VCO_PHASE_SHIFT_STEP} {}
    set_instance_parameter_value the_altpll {USING_FBMIMICBIDIR_PORT} {}
    set_instance_parameter_value the_altpll {SCAN_CHAIN_MIF_FILE} {}
    set_instance_parameter_value the_altpll {AVALON_USE_SEPARATE_SYSCLK} {NO}
    set_instance_parameter_value the_altpll {HIDDEN_CONSTANTS} {CT#PORT_clk5 PORT_UNUSED CT#PORT_clk4 PORT_UNUSED CT#PORT_clk3 PORT_UNUSED CT#PORT_clk2 PORT_UNUSED CT#PORT_clk1 PORT_UNUSED CT#PORT_clk0 PORT_USED CT#CLK0_MULTIPLY_BY 2 CT#PORT_SCANWRITE PORT_UNUSED CT#PORT_SCANACLR PORT_UNUSED CT#PORT_PFDENA PORT_UNUSED CT#PORT_PLLENA PORT_UNUSED CT#PORT_SCANDATA PORT_UNUSED CT#PORT_SCANCLKENA PORT_UNUSED CT#WIDTH_CLOCK 5 CT#PORT_SCANDATAOUT PORT_UNUSED CT#LPM_TYPE altpll CT#PLL_TYPE AUTO CT#CLK0_PHASE_SHIFT 0 CT#PORT_PHASEDONE PORT_UNUSED CT#OPERATION_MODE NORMAL CT#PORT_CONFIGUPDATE PORT_UNUSED CT#COMPENSATE_CLOCK CLK0 CT#PORT_CLKSWITCH PORT_UNUSED CT#INCLK0_INPUT_FREQUENCY 20000 CT#PORT_SCANDONE PORT_UNUSED CT#PORT_CLKLOSS PORT_UNUSED CT#PORT_INCLK1 PORT_UNUSED CT#AVALON_USE_SEPARATE_SYSCLK NO CT#PORT_INCLK0 PORT_USED CT#PORT_clkena5 PORT_UNUSED CT#PORT_clkena4 PORT_UNUSED CT#PORT_clkena3 PORT_UNUSED CT#PORT_clkena2 PORT_UNUSED CT#PORT_clkena1 PORT_UNUSED CT#PORT_clkena0 PORT_UNUSED CT#PORT_ARESET PORT_USED CT#BANDWIDTH_TYPE AUTO CT#INTENDED_DEVICE_FAMILY {Cyclone IV E} CT#PORT_SCANREAD PORT_UNUSED CT#PORT_PHASESTEP PORT_UNUSED CT#PORT_SCANCLK PORT_UNUSED CT#PORT_CLKBAD1 PORT_UNUSED CT#PORT_CLKBAD0 PORT_UNUSED CT#PORT_FBIN PORT_UNUSED CT#PORT_PHASEUPDOWN PORT_UNUSED CT#PORT_extclk3 PORT_UNUSED CT#PORT_extclk2 PORT_UNUSED CT#PORT_extclk1 PORT_UNUSED CT#PORT_PHASECOUNTERSELECT PORT_UNUSED CT#PORT_extclk0 PORT_UNUSED CT#PORT_ACTIVECLOCK PORT_UNUSED CT#CLK0_DUTY_CYCLE 50 CT#CLK0_DIVIDE_BY 1 CT#PORT_LOCKED PORT_USED}
    set_instance_parameter_value the_altpll {HIDDEN_PRIVATES} {PT#GLOCKED_FEATURE_ENABLED 0 PT#SPREAD_FEATURE_ENABLED 0 PT#BANDWIDTH_FREQ_UNIT MHz PT#CUR_DEDICATED_CLK c0 PT#INCLK0_FREQ_EDIT 50.000 PT#BANDWIDTH_PRESET Low PT#PLL_LVDS_PLL_CHECK 0 PT#BANDWIDTH_USE_PRESET 0 PT#AVALON_USE_SEPARATE_SYSCLK NO PT#PLL_ENHPLL_CHECK 0 PT#OUTPUT_FREQ_UNIT0 MHz PT#PHASE_RECONFIG_FEATURE_ENABLED 1 PT#CREATE_CLKBAD_CHECK 0 PT#CLKSWITCH_CHECK 0 PT#INCLK1_FREQ_EDIT 100.000 PT#NORMAL_MODE_RADIO 1 PT#SRC_SYNCH_COMP_RADIO 0 PT#PLL_ARESET_CHECK 1 PT#LONG_SCAN_RADIO 1 PT#SCAN_FEATURE_ENABLED 1 PT#PHASE_RECONFIG_INPUTS_CHECK 0 PT#USE_CLK0 1 PT#PRIMARY_CLK_COMBO inclk0 PT#BANDWIDTH 1.000 PT#GLOCKED_COUNTER_EDIT_CHANGED 1 PT#PLL_FASTPLL_CHECK 0 PT#SPREAD_FREQ_UNIT KHz PT#PLL_AUTOPLL_CHECK 1 PT#LVDS_PHASE_SHIFT_UNIT0 deg PT#SWITCHOVER_FEATURE_ENABLED 0 PT#MIG_DEVICE_SPEED_GRADE Any PT#OUTPUT_FREQ_MODE0 0 PT#BANDWIDTH_FEATURE_ENABLED 1 PT#INCLK0_FREQ_UNIT_COMBO MHz PT#ZERO_DELAY_RADIO 0 PT#OUTPUT_FREQ0 100.00000000 PT#SHORT_SCAN_RADIO 0 PT#LVDS_MODE_DATA_RATE_DIRTY 0 PT#CUR_FBIN_CLK c0 PT#PLL_ADVANCED_PARAM_CHECK 0 PT#CLKBAD_SWITCHOVER_CHECK 0 PT#PHASE_SHIFT_STEP_ENABLED_CHECK 0 PT#DEVICE_SPEED_GRADE Any PT#PLL_FBMIMIC_CHECK 0 PT#LVDS_MODE_DATA_RATE {Not Available} PT#LOCKED_OUTPUT_CHECK 1 PT#SPREAD_PERCENT 0.500 PT#PHASE_SHIFT0 0.00000000 PT#DIV_FACTOR0 1 PT#CNX_NO_COMPENSATE_RADIO 0 PT#USE_CLKENA0 0 PT#CREATE_INCLK1_CHECK 0 PT#GLOCK_COUNTER_EDIT 1048575 PT#INCLK1_FREQ_UNIT_COMBO MHz PT#EFF_OUTPUT_FREQ_VALUE0 100.000000 PT#SPREAD_FREQ 50.000 PT#USE_MIL_SPEED_GRADE 0 PT#EXPLICIT_SWITCHOVER_COUNTER 0 PT#STICKY_CLK0 1 PT#EXT_FEEDBACK_RADIO 0 PT#MIRROR_CLK0 0 PT#SWITCHOVER_COUNT_EDIT 1 PT#SELF_RESET_LOCK_LOSS 0 PT#PLL_PFDENA_CHECK 0 PT#INT_FEEDBACK__MODE_RADIO 1 PT#INCLK1_FREQ_EDIT_CHANGED 1 PT#CLKLOSS_CHECK 0 PT#SYNTH_WRAPPER_GEN_POSTFIX 0 PT#PHASE_SHIFT_UNIT0 deg PT#BANDWIDTH_USE_AUTO 1 PT#HAS_MANUAL_SWITCHOVER 1 PT#MULT_FACTOR0 2 PT#SPREAD_USE 0 PT#GLOCKED_MODE_CHECK 0 PT#SACN_INPUTS_CHECK 0 PT#DUTY_CYCLE0 50.00000000 PT#INTENDED_DEVICE_FAMILY {Cyclone IV E} PT#PLL_TARGET_HARCOPY_CHECK 0 PT#INCLK1_FREQ_UNIT_CHANGED 1 PT#RECONFIG_FILE ALTPLL1510782053533517.mif PT#ACTIVECLK_CHECK 0}
    set_instance_parameter_value the_altpll {HIDDEN_USED_PORTS} {UP#locked used UP#c0 used UP#areset used UP#inclk0 used}
    set_instance_parameter_value the_altpll {HIDDEN_IS_NUMERIC} {IN#WIDTH_CLOCK 1 IN#CLK0_DUTY_CYCLE 1 IN#PLL_TARGET_HARCOPY_CHECK 1 IN#SWITCHOVER_COUNT_EDIT 1 IN#INCLK0_INPUT_FREQUENCY 1 IN#PLL_LVDS_PLL_CHECK 1 IN#PLL_AUTOPLL_CHECK 1 IN#PLL_FASTPLL_CHECK 1 IN#PLL_ENHPLL_CHECK 1 IN#DIV_FACTOR0 1 IN#LVDS_MODE_DATA_RATE_DIRTY 1 IN#GLOCK_COUNTER_EDIT 1 IN#CLK0_DIVIDE_BY 1 IN#MULT_FACTOR0 1 IN#CLK0_MULTIPLY_BY 1 IN#USE_MIL_SPEED_GRADE 1}
    set_instance_parameter_value the_altpll {HIDDEN_MF_PORTS} {MF#areset 1 MF#clk 1 MF#locked 1 MF#inclk 1}
    set_instance_parameter_value the_altpll {HIDDEN_IF_PORTS} {IF#locked {output 0} IF#reset {input 0} IF#clk {input 0} IF#readdata {output 32} IF#write {input 0} IF#phasedone {output 0} IF#address {input 2} IF#c0 {output 0} IF#writedata {input 32} IF#read {input 0} IF#areset {input 0}}
    set_instance_parameter_value the_altpll {HIDDEN_IS_FIRST_EDIT} {0}

    add_instance the_clk clock_source 15.1
    set_instance_parameter_value the_clk {clockFrequency} {50000000.0}
    set_instance_parameter_value the_clk {clockFrequencyKnown} {1}
    set_instance_parameter_value the_clk {resetSynchronousEdges} {NONE}

    add_instance the_jtag_uart altera_avalon_jtag_uart 15.1
    set_instance_parameter_value the_jtag_uart {allowMultipleConnections} {0}
    set_instance_parameter_value the_jtag_uart {hubInstanceID} {0}
    set_instance_parameter_value the_jtag_uart {readBufferDepth} {64}
    set_instance_parameter_value the_jtag_uart {readIRQThreshold} {8}
    set_instance_parameter_value the_jtag_uart {simInputCharacterStream} {}
    set_instance_parameter_value the_jtag_uart {simInteractiveOptions} {NO_INTERACTIVE_WINDOWS}
    set_instance_parameter_value the_jtag_uart {useRegistersForReadBuffer} {0}
    set_instance_parameter_value the_jtag_uart {useRegistersForWriteBuffer} {0}
    set_instance_parameter_value the_jtag_uart {useRelativePathForSimFile} {0}
    set_instance_parameter_value the_jtag_uart {writeBufferDepth} {64}
    set_instance_parameter_value the_jtag_uart {writeIRQThreshold} {8}

    add_instance the_master altera_jtag_avalon_master 15.1
    set_instance_parameter_value the_master {USE_PLI} {0}
    set_instance_parameter_value the_master {PLI_PORT} {50000}
    set_instance_parameter_value the_master {FAST_VER} {0}
    set_instance_parameter_value the_master {FIFO_DEPTHS} {2}

    add_instance the_memory_mapped_reset memory_mapped_reset 1.0
    set_instance_parameter_value the_memory_mapped_reset {ADDR_WIDTH} {2}
    set_instance_parameter_value the_memory_mapped_reset {REGISTER_SIZE} {32}

    add_instance the_mm_clock_crossing_bridge altera_avalon_mm_clock_crossing_bridge 15.1
    set_instance_parameter_value the_mm_clock_crossing_bridge {DATA_WIDTH} {32}
    set_instance_parameter_value the_mm_clock_crossing_bridge {SYMBOL_WIDTH} {8}
    set_instance_parameter_value the_mm_clock_crossing_bridge {ADDRESS_WIDTH} {10}
    set_instance_parameter_value the_mm_clock_crossing_bridge {USE_AUTO_ADDRESS_WIDTH} {1}
    set_instance_parameter_value the_mm_clock_crossing_bridge {ADDRESS_UNITS} {SYMBOLS}
    set_instance_parameter_value the_mm_clock_crossing_bridge {MAX_BURST_SIZE} {1}
    set_instance_parameter_value the_mm_clock_crossing_bridge {COMMAND_FIFO_DEPTH} {4}
    set_instance_parameter_value the_mm_clock_crossing_bridge {RESPONSE_FIFO_DEPTH} {4}
    set_instance_parameter_value the_mm_clock_crossing_bridge {MASTER_SYNC_DEPTH} {2}
    set_instance_parameter_value the_mm_clock_crossing_bridge {SLAVE_SYNC_DEPTH} {2}

    add_instance the_onchip_memory2 altera_avalon_onchip_memory2 15.1
    set_instance_parameter_value the_onchip_memory2 {allowInSystemMemoryContentEditor} {0}
    set_instance_parameter_value the_onchip_memory2 {blockType} {AUTO}
    set_instance_parameter_value the_onchip_memory2 {dataWidth} {32}
    set_instance_parameter_value the_onchip_memory2 {dualPort} {1}
    set_instance_parameter_value the_onchip_memory2 {initMemContent} {1}
    set_instance_parameter_value the_onchip_memory2 {initializationFileName} {software/test.hex}
    set_instance_parameter_value the_onchip_memory2 {instanceID} {NONE}
    set_instance_parameter_value the_onchip_memory2 {memorySize} {65536.0}
    set_instance_parameter_value the_onchip_memory2 {readDuringWriteMode} {DONT_CARE}
    set_instance_parameter_value the_onchip_memory2 {simAllowMRAMContentsFile} {0}
    set_instance_parameter_value the_onchip_memory2 {simMemInitOnlyFilename} {0}
    set_instance_parameter_value the_onchip_memory2 {singleClockOperation} {0}
    set_instance_parameter_value the_onchip_memory2 {slave1Latency} {1}
    set_instance_parameter_value the_onchip_memory2 {slave2Latency} {1}
    set_instance_parameter_value the_onchip_memory2 {useNonDefaultInitFile} {1}
    set_instance_parameter_value the_onchip_memory2 {copyInitFile} {0}
    set_instance_parameter_value the_onchip_memory2 {useShallowMemBlocks} {0}
    set_instance_parameter_value the_onchip_memory2 {writable} {1}
    set_instance_parameter_value the_onchip_memory2 {ecc_enabled} {0}
    set_instance_parameter_value the_onchip_memory2 {resetrequest_enabled} {1}

    add_instance the_timer altera_avalon_timer 15.1
    set_instance_parameter_value the_timer {alwaysRun} {0}
    set_instance_parameter_value the_timer {counterSize} {32}
    set_instance_parameter_value the_timer {fixedPeriod} {0}
    set_instance_parameter_value the_timer {period} {1}
    set_instance_parameter_value the_timer {periodUnits} {MSEC}
    set_instance_parameter_value the_timer {resetOutput} {0}
    set_instance_parameter_value the_timer {snapshot} {1}
    set_instance_parameter_value the_timer {timeoutPulseOutput} {0}
    set_instance_parameter_value the_timer {watchdogPulse} {2}

    add_instance the_vectorblox_orca vectorblox_orca 1.0
    set_instance_parameter_value the_vectorblox_orca {REGISTER_SIZE} {32}
    set_instance_parameter_value the_vectorblox_orca {RESET_VECTOR} {0}
    set_instance_parameter_value the_vectorblox_orca {ENABLE_EXCEPTIONS} {1}
    set_instance_parameter_value the_vectorblox_orca {INTERRUPT_VECTOR} {512}
    set_instance_parameter_value the_vectorblox_orca {ENABLE_EXT_INTERRUPTS} {1}
    set_instance_parameter_value the_vectorblox_orca {NUM_EXT_INTERRUPTS} {2}
    set_instance_parameter_value the_vectorblox_orca {MAX_IFETCHES_IN_FLIGHT} {4}
    set_instance_parameter_value the_vectorblox_orca {BTB_ENTRIES} {16}
    set_instance_parameter_value the_vectorblox_orca {MULTIPLY_ENABLE} {1}
    set_instance_parameter_value the_vectorblox_orca {SHIFTER_MAX_CYCLES} {1}
    set_instance_parameter_value the_vectorblox_orca {DIVIDE_ENABLE} {1}
    set_instance_parameter_value the_vectorblox_orca {COUNTER_LENGTH} {64}
    set_instance_parameter_value the_vectorblox_orca {PIPELINE_STAGES} {5}
    set_instance_parameter_value the_vectorblox_orca {VCP_ENABLE} {0}
    set_instance_parameter_value the_vectorblox_orca {POWER_OPTIMIZED} {0}
    set_instance_parameter_value the_vectorblox_orca {FAMILY} {ALTERA}
    set_instance_parameter_value the_vectorblox_orca {INSTRUCTION_REQUEST_REGISTER} {0}
    set_instance_parameter_value the_vectorblox_orca {INSTRUCTION_RETURN_REGISTER} {0}
    set_instance_parameter_value the_vectorblox_orca {DATA_REQUEST_REGISTER} {0}
    set_instance_parameter_value the_vectorblox_orca {DATA_RETURN_REGISTER} {0}
    set_instance_parameter_value the_vectorblox_orca {LOG2_BURSTLENGTH} {4}
    set_instance_parameter_value the_vectorblox_orca {AXI_ID_WIDTH} {2}
    set_instance_parameter_value the_vectorblox_orca {ICACHE_SIZE} {0}
    set_instance_parameter_value the_vectorblox_orca {ICACHE_LINE_SIZE} {32}
    set_instance_parameter_value the_vectorblox_orca {ICACHE_EXTERNAL_WIDTH} {32}
    set_instance_parameter_value the_vectorblox_orca {IC_REQUEST_REGISTER} {1}
    set_instance_parameter_value the_vectorblox_orca {IC_RETURN_REGISTER} {0}
    set_instance_parameter_value the_vectorblox_orca {DCACHE_SIZE} {0}
    set_instance_parameter_value the_vectorblox_orca {DCACHE_WRITEBACK} {0}
    set_instance_parameter_value the_vectorblox_orca {DCACHE_LINE_SIZE} {32}
    set_instance_parameter_value the_vectorblox_orca {DCACHE_EXTERNAL_WIDTH} {32}
    set_instance_parameter_value the_vectorblox_orca {DC_REQUEST_REGISTER} {1}
    set_instance_parameter_value the_vectorblox_orca {DC_RETURN_REGISTER} {0}
    set_instance_parameter_value the_vectorblox_orca {UC_MEMORY_REGIONS} {0}
    set_instance_parameter_value the_vectorblox_orca {UMR0_ADDR_BASE} {0}
    set_instance_parameter_value the_vectorblox_orca {UMR0_ADDR_LAST} {0}
    set_instance_parameter_value the_vectorblox_orca {IUC_REQUEST_REGISTER} {1}
    set_instance_parameter_value the_vectorblox_orca {IUC_RETURN_REGISTER} {0}
    set_instance_parameter_value the_vectorblox_orca {DUC_REQUEST_REGISTER} {2}
    set_instance_parameter_value the_vectorblox_orca {DUC_RETURN_REGISTER} {1}
    set_instance_parameter_value the_vectorblox_orca {AUX_MEMORY_REGIONS} {1}
    set_instance_parameter_value the_vectorblox_orca {AMR0_ADDR_BASE} {0}
    set_instance_parameter_value the_vectorblox_orca {AMR0_ADDR_LAST} {0}
    set_instance_parameter_value the_vectorblox_orca {IAUX_REQUEST_REGISTER} {1}
    set_instance_parameter_value the_vectorblox_orca {IAUX_RETURN_REGISTER} {0}
    set_instance_parameter_value the_vectorblox_orca {DAUX_REQUEST_REGISTER} {2}
    set_instance_parameter_value the_vectorblox_orca {DAUX_RETURN_REGISTER} {1}

    # connections and connection parameters
    add_connection the_vectorblox_orca.data the_mm_clock_crossing_bridge.s0 avalon
    set_connection_parameter_value the_vectorblox_orca.data/the_mm_clock_crossing_bridge.s0 arbitrationPriority {1}
    set_connection_parameter_value the_vectorblox_orca.data/the_mm_clock_crossing_bridge.s0 baseAddress {0x01000000}
    set_connection_parameter_value the_vectorblox_orca.data/the_mm_clock_crossing_bridge.s0 defaultConnection {0}

    add_connection the_vectorblox_orca.data the_onchip_memory2.s2 avalon
    set_connection_parameter_value the_vectorblox_orca.data/the_onchip_memory2.s2 arbitrationPriority {1}
    set_connection_parameter_value the_vectorblox_orca.data/the_onchip_memory2.s2 baseAddress {0x0000}
    set_connection_parameter_value the_vectorblox_orca.data/the_onchip_memory2.s2 defaultConnection {0}

    add_connection the_vectorblox_orca.instruction the_onchip_memory2.s1 avalon
    set_connection_parameter_value the_vectorblox_orca.instruction/the_onchip_memory2.s1 arbitrationPriority {1}
    set_connection_parameter_value the_vectorblox_orca.instruction/the_onchip_memory2.s1 baseAddress {0x0000}
    set_connection_parameter_value the_vectorblox_orca.instruction/the_onchip_memory2.s1 defaultConnection {0}

    add_connection the_mm_clock_crossing_bridge.m0 the_jtag_uart.avalon_jtag_slave avalon
    set_connection_parameter_value the_mm_clock_crossing_bridge.m0/the_jtag_uart.avalon_jtag_slave arbitrationPriority {1}
    set_connection_parameter_value the_mm_clock_crossing_bridge.m0/the_jtag_uart.avalon_jtag_slave baseAddress {0x0070}
    set_connection_parameter_value the_mm_clock_crossing_bridge.m0/the_jtag_uart.avalon_jtag_slave defaultConnection {0}

    add_connection the_mm_clock_crossing_bridge.m0 the_altpll.pll_slave avalon
    set_connection_parameter_value the_mm_clock_crossing_bridge.m0/the_altpll.pll_slave arbitrationPriority {1}
    set_connection_parameter_value the_mm_clock_crossing_bridge.m0/the_altpll.pll_slave baseAddress {0x0000}
    set_connection_parameter_value the_mm_clock_crossing_bridge.m0/the_altpll.pll_slave defaultConnection {0}

    add_connection the_mm_clock_crossing_bridge.m0 ledr.s1 avalon
    set_connection_parameter_value the_mm_clock_crossing_bridge.m0/ledr.s1 arbitrationPriority {1}
    set_connection_parameter_value the_mm_clock_crossing_bridge.m0/ledr.s1 baseAddress {0x0010}
    set_connection_parameter_value the_mm_clock_crossing_bridge.m0/ledr.s1 defaultConnection {0}

    add_connection the_mm_clock_crossing_bridge.m0 ledg.s1 avalon
    set_connection_parameter_value the_mm_clock_crossing_bridge.m0/ledg.s1 arbitrationPriority {1}
    set_connection_parameter_value the_mm_clock_crossing_bridge.m0/ledg.s1 baseAddress {0x0020}
    set_connection_parameter_value the_mm_clock_crossing_bridge.m0/ledg.s1 defaultConnection {0}

    add_connection the_mm_clock_crossing_bridge.m0 hex_3.s1 avalon
    set_connection_parameter_value the_mm_clock_crossing_bridge.m0/hex_3.s1 arbitrationPriority {1}
    set_connection_parameter_value the_mm_clock_crossing_bridge.m0/hex_3.s1 baseAddress {0x0060}
    set_connection_parameter_value the_mm_clock_crossing_bridge.m0/hex_3.s1 defaultConnection {0}

    add_connection the_mm_clock_crossing_bridge.m0 hex_2.s1 avalon
    set_connection_parameter_value the_mm_clock_crossing_bridge.m0/hex_2.s1 arbitrationPriority {1}
    set_connection_parameter_value the_mm_clock_crossing_bridge.m0/hex_2.s1 baseAddress {0x0050}
    set_connection_parameter_value the_mm_clock_crossing_bridge.m0/hex_2.s1 defaultConnection {0}

    add_connection the_mm_clock_crossing_bridge.m0 hex_1.s1 avalon
    set_connection_parameter_value the_mm_clock_crossing_bridge.m0/hex_1.s1 arbitrationPriority {1}
    set_connection_parameter_value the_mm_clock_crossing_bridge.m0/hex_1.s1 baseAddress {0x0040}
    set_connection_parameter_value the_mm_clock_crossing_bridge.m0/hex_1.s1 defaultConnection {0}

    add_connection the_mm_clock_crossing_bridge.m0 hex_0.s1 avalon
    set_connection_parameter_value the_mm_clock_crossing_bridge.m0/hex_0.s1 arbitrationPriority {1}
    set_connection_parameter_value the_mm_clock_crossing_bridge.m0/hex_0.s1 baseAddress {0x0030}
    set_connection_parameter_value the_mm_clock_crossing_bridge.m0/hex_0.s1 defaultConnection {0}

    add_connection the_mm_clock_crossing_bridge.m0 the_timer.s1 avalon
    set_connection_parameter_value the_mm_clock_crossing_bridge.m0/the_timer.s1 arbitrationPriority {1}
    set_connection_parameter_value the_mm_clock_crossing_bridge.m0/the_timer.s1 baseAddress {0x0080}
    set_connection_parameter_value the_mm_clock_crossing_bridge.m0/the_timer.s1 defaultConnection {0}

    add_connection the_master.master the_memory_mapped_reset.avalon_slave avalon
    set_connection_parameter_value the_master.master/the_memory_mapped_reset.avalon_slave arbitrationPriority {1}
    set_connection_parameter_value the_master.master/the_memory_mapped_reset.avalon_slave baseAddress {0x10000000}
    set_connection_parameter_value the_master.master/the_memory_mapped_reset.avalon_slave defaultConnection {0}

    add_connection the_master.master the_onchip_memory2.s2 avalon
    set_connection_parameter_value the_master.master/the_onchip_memory2.s2 arbitrationPriority {1}
    set_connection_parameter_value the_master.master/the_onchip_memory2.s2 baseAddress {0x0000}
    set_connection_parameter_value the_master.master/the_onchip_memory2.s2 defaultConnection {0}

    add_connection the_altpll.c0 the_onchip_memory2.clk1 clock

    add_connection the_altpll.c0 the_onchip_memory2.clk2 clock

    add_connection the_altpll.c0 the_vectorblox_orca.clock clock

    add_connection the_altpll.c0 the_mm_clock_crossing_bridge.s0_clk clock

    add_connection the_clk.clk ledg.clk clock

    add_connection the_clk.clk ledr.clk clock

    add_connection the_clk.clk hex_0.clk clock

    add_connection the_clk.clk hex_1.clk clock

    add_connection the_clk.clk the_jtag_uart.clk clock

    add_connection the_clk.clk hex_2.clk clock

    add_connection the_clk.clk hex_3.clk clock

    add_connection the_clk.clk the_master.clk clock

    add_connection the_clk.clk the_timer.clk clock

    add_connection the_clk.clk the_memory_mapped_reset.clock clock

    add_connection the_clk.clk the_altpll.inclk_interface clock

    add_connection the_clk.clk the_mm_clock_crossing_bridge.m0_clk clock

    add_connection the_vectorblox_orca.global_interrupts the_jtag_uart.irq interrupt
    set_connection_parameter_value the_vectorblox_orca.global_interrupts/the_jtag_uart.irq irqNumber {1}

    add_connection the_vectorblox_orca.global_interrupts the_timer.irq interrupt
    set_connection_parameter_value the_vectorblox_orca.global_interrupts/the_timer.irq irqNumber {0}

    add_connection the_clk.clk_reset the_master.clk_reset reset

    add_connection the_clk.clk_reset the_altpll.inclk_interface_reset reset

    add_connection the_clk.clk_reset the_mm_clock_crossing_bridge.m0_reset reset

    add_connection the_clk.clk_reset the_memory_mapped_reset.reset reset

    add_connection the_clk.clk_reset the_vectorblox_orca.reset reset

    add_connection the_clk.clk_reset ledr.reset reset

    add_connection the_clk.clk_reset ledg.reset reset

    add_connection the_clk.clk_reset hex_3.reset reset

    add_connection the_clk.clk_reset hex_2.reset reset

    add_connection the_clk.clk_reset hex_1.reset reset

    add_connection the_clk.clk_reset hex_0.reset reset

    add_connection the_clk.clk_reset the_jtag_uart.reset reset

    add_connection the_clk.clk_reset the_timer.reset reset

    add_connection the_clk.clk_reset the_onchip_memory2.reset1 reset

    add_connection the_clk.clk_reset the_onchip_memory2.reset2 reset

    add_connection the_clk.clk_reset the_mm_clock_crossing_bridge.s0_reset reset

    add_connection the_memory_mapped_reset.reset_source the_vectorblox_orca.reset reset

    add_connection the_memory_mapped_reset.reset_source ledr.reset reset

    add_connection the_memory_mapped_reset.reset_source ledg.reset reset

    add_connection the_memory_mapped_reset.reset_source hex_3.reset reset

    add_connection the_memory_mapped_reset.reset_source hex_2.reset reset

    add_connection the_memory_mapped_reset.reset_source hex_1.reset reset

    add_connection the_memory_mapped_reset.reset_source hex_0.reset reset

    add_connection the_memory_mapped_reset.reset_source the_jtag_uart.reset reset

    add_connection the_memory_mapped_reset.reset_source the_timer.reset reset

    # exported interfaces
    add_interface clk clock sink
    set_interface_property clk EXPORT_OF the_clk.clk_in
    add_interface hex0 conduit end
    set_interface_property hex0 EXPORT_OF hex_0.external_connection
    add_interface hex1 conduit end
    set_interface_property hex1 EXPORT_OF hex_1.external_connection
    add_interface hex2 conduit end
    set_interface_property hex2 EXPORT_OF hex_2.external_connection
    add_interface hex3 conduit end
    set_interface_property hex3 EXPORT_OF hex_3.external_connection
    add_interface ledg conduit end
    set_interface_property ledg EXPORT_OF ledg.external_connection
    add_interface ledr conduit end
    set_interface_property ledr EXPORT_OF ledr.external_connection
    add_interface reset reset sink
    set_interface_property reset EXPORT_OF the_clk.clk_in_reset
    add_interface the_altpll_areset conduit end
    set_interface_property the_altpll_areset EXPORT_OF the_altpll.areset_conduit
    add_interface the_altpll_locked conduit end
    set_interface_property the_altpll_locked EXPORT_OF the_altpll.locked_conduit
    add_interface the_altpll_phasedone conduit end
    set_interface_property the_altpll_phasedone EXPORT_OF the_altpll.phasedone_conduit

    # interconnect requirements
    set_interconnect_requirement {$system} {qsys_mm.clockCrossingAdapter} {HANDSHAKE}
    set_interconnect_requirement {$system} {qsys_mm.maxAdditionalLatency} {1}
    set_interconnect_requirement {$system} {qsys_mm.enableEccProtection} {FALSE}
    set_interconnect_requirement {$system} {qsys_mm.insertDefaultSlave} {FALSE}
}
