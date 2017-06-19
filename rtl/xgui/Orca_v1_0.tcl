
# Loading additional proc with user specified bodies to compute parameter values.
source [file join [file dirname [file dirname [info script]]] gui/Orca_v1_0.gtcl]

# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "RESET_VECTOR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "PIPELINE_STAGES" -parent ${Page_0} -widget comboBox
  #Adding Group
  set ALU [ipgui::add_group $IPINST -name "ALU" -parent ${Page_0}]
  ipgui::add_param $IPINST -name "MULTIPLY_ENABLE" -parent ${ALU} -widget checkBox
  ipgui::add_param $IPINST -name "DIVIDE_ENABLE" -parent ${ALU} -widget checkBox
  ipgui::add_param $IPINST -name "SHIFTER_MAX_CYCLES" -parent ${ALU} -widget comboBox
  #Adding Group
  set LVE [ipgui::add_group $IPINST -name "LVE" -parent ${Page_0}]
  set_property tooltip {Lightweight Vector Extensions} ${LVE}
  ipgui::add_param $IPINST -name "LVE_ENABLE" -parent ${LVE} -widget checkBox
  #Adding Group
  set Control_and_Status [ipgui::add_group $IPINST -name "Control and Status" -parent ${Page_0}]
  ipgui::add_param $IPINST -name "COUNTER_LENGTH" -parent ${Control_and_Status} -widget comboBox
  ipgui::add_param $IPINST -name "ENABLE_EXCEPTIONS" -parent ${Control_and_Status} -widget checkBox
  ipgui::add_param $IPINST -name "ENABLE_EXT_INTERRUPTS" -parent ${Control_and_Status} -widget checkBox
  ipgui::add_param $IPINST -name "NUM_EXT_INTERRUPTS" -parent ${Control_and_Status}
  #Adding Group
  set Bus_Interfaces [ipgui::add_group $IPINST -name "Bus Interfaces" -parent ${Page_0}]
  ipgui::add_param $IPINST -name "AVALON_ENABLE" -parent ${Bus_Interfaces} -widget checkBox
  ipgui::add_param $IPINST -name "WISHBONE_ENABLE" -parent ${Bus_Interfaces} -widget checkBox
  ipgui::add_param $IPINST -name "AXI_ENABLE" -parent ${Bus_Interfaces} -widget checkBox



}

proc update_PARAM_VALUE.ENABLE_EXT_INTERRUPTS { PARAM_VALUE.ENABLE_EXT_INTERRUPTS PARAM_VALUE.ENABLE_EXCEPTIONS } {
	# Procedure called to update ENABLE_EXT_INTERRUPTS when any of the dependent parameters in the arguments change
	
	set ENABLE_EXT_INTERRUPTS ${PARAM_VALUE.ENABLE_EXT_INTERRUPTS}
	set ENABLE_EXCEPTIONS ${PARAM_VALUE.ENABLE_EXCEPTIONS}
	set values(ENABLE_EXCEPTIONS) [get_property value $ENABLE_EXCEPTIONS]
	if { [gen_USERPARAMETER_ENABLE_EXT_INTERRUPTS_ENABLEMENT $values(ENABLE_EXCEPTIONS)] } {
		set_property enabled true $ENABLE_EXT_INTERRUPTS
	} else {
		set_property enabled false $ENABLE_EXT_INTERRUPTS
	}
}

proc validate_PARAM_VALUE.ENABLE_EXT_INTERRUPTS { PARAM_VALUE.ENABLE_EXT_INTERRUPTS } {
	# Procedure called to validate ENABLE_EXT_INTERRUPTS
	return true
}

proc update_PARAM_VALUE.NUM_EXT_INTERRUPTS { PARAM_VALUE.NUM_EXT_INTERRUPTS PARAM_VALUE.ENABLE_EXCEPTIONS PARAM_VALUE.ENABLE_EXT_INTERRUPTS } {
	# Procedure called to update NUM_EXT_INTERRUPTS when any of the dependent parameters in the arguments change
	
	set NUM_EXT_INTERRUPTS ${PARAM_VALUE.NUM_EXT_INTERRUPTS}
	set ENABLE_EXCEPTIONS ${PARAM_VALUE.ENABLE_EXCEPTIONS}
	set ENABLE_EXT_INTERRUPTS ${PARAM_VALUE.ENABLE_EXT_INTERRUPTS}
	set values(ENABLE_EXCEPTIONS) [get_property value $ENABLE_EXCEPTIONS]
	set values(ENABLE_EXT_INTERRUPTS) [get_property value $ENABLE_EXT_INTERRUPTS]
	if { [gen_USERPARAMETER_NUM_EXT_INTERRUPTS_ENABLEMENT $values(ENABLE_EXCEPTIONS) $values(ENABLE_EXT_INTERRUPTS)] } {
		set_property enabled true $NUM_EXT_INTERRUPTS
	} else {
		set_property enabled false $NUM_EXT_INTERRUPTS
	}
}

proc validate_PARAM_VALUE.NUM_EXT_INTERRUPTS { PARAM_VALUE.NUM_EXT_INTERRUPTS } {
	# Procedure called to validate NUM_EXT_INTERRUPTS
	return true
}

proc update_PARAM_VALUE.SHIFTER_MAX_CYCLES { PARAM_VALUE.SHIFTER_MAX_CYCLES PARAM_VALUE.MULTIPLY_ENABLE } {
	# Procedure called to update SHIFTER_MAX_CYCLES when any of the dependent parameters in the arguments change
	
	set SHIFTER_MAX_CYCLES ${PARAM_VALUE.SHIFTER_MAX_CYCLES}
	set MULTIPLY_ENABLE ${PARAM_VALUE.MULTIPLY_ENABLE}
	set values(MULTIPLY_ENABLE) [get_property value $MULTIPLY_ENABLE]
	if { [gen_USERPARAMETER_SHIFTER_MAX_CYCLES_ENABLEMENT $values(MULTIPLY_ENABLE)] } {
		set_property enabled true $SHIFTER_MAX_CYCLES
	} else {
		set_property enabled false $SHIFTER_MAX_CYCLES
	}
}

proc validate_PARAM_VALUE.SHIFTER_MAX_CYCLES { PARAM_VALUE.SHIFTER_MAX_CYCLES } {
	# Procedure called to validate SHIFTER_MAX_CYCLES
	return true
}

proc update_PARAM_VALUE.AVALON_ENABLE { PARAM_VALUE.AVALON_ENABLE } {
	# Procedure called to update AVALON_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AVALON_ENABLE { PARAM_VALUE.AVALON_ENABLE } {
	# Procedure called to validate AVALON_ENABLE
	return true
}

proc update_PARAM_VALUE.AXI_ENABLE { PARAM_VALUE.AXI_ENABLE } {
	# Procedure called to update AXI_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_ENABLE { PARAM_VALUE.AXI_ENABLE } {
	# Procedure called to validate AXI_ENABLE
	return true
}

proc update_PARAM_VALUE.BRANCH_PREDICTORS { PARAM_VALUE.BRANCH_PREDICTORS } {
	# Procedure called to update BRANCH_PREDICTORS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BRANCH_PREDICTORS { PARAM_VALUE.BRANCH_PREDICTORS } {
	# Procedure called to validate BRANCH_PREDICTORS
	return true
}

proc update_PARAM_VALUE.COUNTER_LENGTH { PARAM_VALUE.COUNTER_LENGTH } {
	# Procedure called to update COUNTER_LENGTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.COUNTER_LENGTH { PARAM_VALUE.COUNTER_LENGTH } {
	# Procedure called to validate COUNTER_LENGTH
	return true
}

proc update_PARAM_VALUE.DIVIDE_ENABLE { PARAM_VALUE.DIVIDE_ENABLE } {
	# Procedure called to update DIVIDE_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DIVIDE_ENABLE { PARAM_VALUE.DIVIDE_ENABLE } {
	# Procedure called to validate DIVIDE_ENABLE
	return true
}

proc update_PARAM_VALUE.ENABLE_EXCEPTIONS { PARAM_VALUE.ENABLE_EXCEPTIONS } {
	# Procedure called to update ENABLE_EXCEPTIONS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ENABLE_EXCEPTIONS { PARAM_VALUE.ENABLE_EXCEPTIONS } {
	# Procedure called to validate ENABLE_EXCEPTIONS
	return true
}

proc update_PARAM_VALUE.FAMILY { PARAM_VALUE.FAMILY } {
	# Procedure called to update FAMILY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FAMILY { PARAM_VALUE.FAMILY } {
	# Procedure called to validate FAMILY
	return true
}

proc update_PARAM_VALUE.LVE_ENABLE { PARAM_VALUE.LVE_ENABLE } {
	# Procedure called to update LVE_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.LVE_ENABLE { PARAM_VALUE.LVE_ENABLE } {
	# Procedure called to validate LVE_ENABLE
	return true
}

proc update_PARAM_VALUE.MULTIPLY_ENABLE { PARAM_VALUE.MULTIPLY_ENABLE } {
	# Procedure called to update MULTIPLY_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MULTIPLY_ENABLE { PARAM_VALUE.MULTIPLY_ENABLE } {
	# Procedure called to validate MULTIPLY_ENABLE
	return true
}

proc update_PARAM_VALUE.PIPELINE_STAGES { PARAM_VALUE.PIPELINE_STAGES } {
	# Procedure called to update PIPELINE_STAGES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PIPELINE_STAGES { PARAM_VALUE.PIPELINE_STAGES } {
	# Procedure called to validate PIPELINE_STAGES
	return true
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
	return true
}

proc update_PARAM_VALUE.SCRATCHPAD_ADDR_BITS { PARAM_VALUE.SCRATCHPAD_ADDR_BITS } {
	# Procedure called to update SCRATCHPAD_ADDR_BITS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SCRATCHPAD_ADDR_BITS { PARAM_VALUE.SCRATCHPAD_ADDR_BITS } {
	# Procedure called to validate SCRATCHPAD_ADDR_BITS
	return true
}

proc update_PARAM_VALUE.WISHBONE_ENABLE { PARAM_VALUE.WISHBONE_ENABLE } {
	# Procedure called to update WISHBONE_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WISHBONE_ENABLE { PARAM_VALUE.WISHBONE_ENABLE } {
	# Procedure called to validate WISHBONE_ENABLE
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

proc update_MODELPARAM_VALUE.COUNTER_LENGTH { MODELPARAM_VALUE.COUNTER_LENGTH PARAM_VALUE.COUNTER_LENGTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.COUNTER_LENGTH}] ${MODELPARAM_VALUE.COUNTER_LENGTH}
}

proc update_MODELPARAM_VALUE.ENABLE_EXCEPTIONS { MODELPARAM_VALUE.ENABLE_EXCEPTIONS PARAM_VALUE.ENABLE_EXCEPTIONS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ENABLE_EXCEPTIONS}] ${MODELPARAM_VALUE.ENABLE_EXCEPTIONS}
}

proc update_MODELPARAM_VALUE.BRANCH_PREDICTORS { MODELPARAM_VALUE.BRANCH_PREDICTORS PARAM_VALUE.BRANCH_PREDICTORS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BRANCH_PREDICTORS}] ${MODELPARAM_VALUE.BRANCH_PREDICTORS}
}

proc update_MODELPARAM_VALUE.PIPELINE_STAGES { MODELPARAM_VALUE.PIPELINE_STAGES PARAM_VALUE.PIPELINE_STAGES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PIPELINE_STAGES}] ${MODELPARAM_VALUE.PIPELINE_STAGES}
}

proc update_MODELPARAM_VALUE.LVE_ENABLE { MODELPARAM_VALUE.LVE_ENABLE PARAM_VALUE.LVE_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.LVE_ENABLE}] ${MODELPARAM_VALUE.LVE_ENABLE}
}

proc update_MODELPARAM_VALUE.ENABLE_EXT_INTERRUPTS { MODELPARAM_VALUE.ENABLE_EXT_INTERRUPTS PARAM_VALUE.ENABLE_EXT_INTERRUPTS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ENABLE_EXT_INTERRUPTS}] ${MODELPARAM_VALUE.ENABLE_EXT_INTERRUPTS}
}

proc update_MODELPARAM_VALUE.NUM_EXT_INTERRUPTS { MODELPARAM_VALUE.NUM_EXT_INTERRUPTS PARAM_VALUE.NUM_EXT_INTERRUPTS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_EXT_INTERRUPTS}] ${MODELPARAM_VALUE.NUM_EXT_INTERRUPTS}
}

proc update_MODELPARAM_VALUE.SCRATCHPAD_ADDR_BITS { MODELPARAM_VALUE.SCRATCHPAD_ADDR_BITS PARAM_VALUE.SCRATCHPAD_ADDR_BITS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SCRATCHPAD_ADDR_BITS}] ${MODELPARAM_VALUE.SCRATCHPAD_ADDR_BITS}
}

proc update_MODELPARAM_VALUE.AVALON_ENABLE { MODELPARAM_VALUE.AVALON_ENABLE PARAM_VALUE.AVALON_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AVALON_ENABLE}] ${MODELPARAM_VALUE.AVALON_ENABLE}
}

proc update_MODELPARAM_VALUE.WISHBONE_ENABLE { MODELPARAM_VALUE.WISHBONE_ENABLE PARAM_VALUE.WISHBONE_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WISHBONE_ENABLE}] ${MODELPARAM_VALUE.WISHBONE_ENABLE}
}

proc update_MODELPARAM_VALUE.AXI_ENABLE { MODELPARAM_VALUE.AXI_ENABLE PARAM_VALUE.AXI_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXI_ENABLE}] ${MODELPARAM_VALUE.AXI_ENABLE}
}

proc update_MODELPARAM_VALUE.FAMILY { MODELPARAM_VALUE.FAMILY PARAM_VALUE.FAMILY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FAMILY}] ${MODELPARAM_VALUE.FAMILY}
}

