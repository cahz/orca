# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "RAM_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "INSTR_PORT_TYPE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DATA_PORT_TYPE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WRITE_FIRST_MODE" -parent ${Page_0}

  set SIZE [ipgui::add_param $IPINST -name "SIZE" -parent ${Page_0}]
  set_property tooltip {Number of bytes stored in IDRAM.} ${SIZE}

}

proc update_PARAM_VALUE.ADDR_WIDTH { PARAM_VALUE.ADDR_WIDTH } {
	# Procedure called to update ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ADDR_WIDTH { PARAM_VALUE.ADDR_WIDTH } {
	# Procedure called to validate ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.RAM_WIDTH { PARAM_VALUE.RAM_WIDTH } {
	# Procedure called to update RAM_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RAM_WIDTH { PARAM_VALUE.RAM_WIDTH } {
	# Procedure called to validate RAM_WIDTH
	return true
}

proc update_PARAM_VALUE.INSTR_PORT_TYPE { PARAM_VALUE.INSTR_PORT_TYPE } {
	# Procedure called to update INSTR_PORT_TYPE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INSTR_PORT_TYPE { PARAM_VALUE.INSTR_PORT_TYPE } {
	# Procedure called to validate INSTR_PORT_TYPE
	return true
}

proc update_PARAM_VALUE.DATA_PORT_TYPE { PARAM_VALUE.DATA_PORT_TYPE } {
	# Procedure called to update DATA_PORT_TYPE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_PORT_TYPE { PARAM_VALUE.DATA_PORT_TYPE } {
	# Procedure called to validate DATA_PORT_TYPE
	return true
}

proc update_PARAM_VALUE.WRITE_FIRST_MODE { PARAM_VALUE.WRITE_FIRST_MODE } {
	# Procedure called to update WRITE_FIRST_MODE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WRITE_FIRST_MODE { PARAM_VALUE.WRITE_FIRST_MODE } {
	# Procedure called to validate WRITE_FIRST_MODE
	return true
}

proc update_PARAM_VALUE.SIZE { PARAM_VALUE.SIZE } {
	# Procedure called to update SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SIZE { PARAM_VALUE.SIZE } {
	# Procedure called to validate SIZE
	return true
}


proc update_MODELPARAM_VALUE.RAM_WIDTH { MODELPARAM_VALUE.RAM_WIDTH PARAM_VALUE.RAM_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RAM_WIDTH}] ${MODELPARAM_VALUE.RAM_WIDTH}
}

proc update_MODELPARAM_VALUE.INSTR_PORT_TYPE { MODELPARAM_VALUE.INSTR_PORT_TYPE PARAM_VALUE.INSTR_PORT_TYPE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INSTR_PORT_TYPE}] ${MODELPARAM_VALUE.INSTR_PORT_TYPE}
}

proc update_MODELPARAM_VALUE.DATA_PORT_TYPE { MODELPARAM_VALUE.DATA_PORT_TYPE PARAM_VALUE.DATA_PORT_TYPE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_PORT_TYPE}] ${MODELPARAM_VALUE.DATA_PORT_TYPE}
}

proc update_MODELPARAM_VALUE.WRITE_FIRST_MODE { MODELPARAM_VALUE.WRITE_FIRST_MODE PARAM_VALUE.WRITE_FIRST_MODE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WRITE_FIRST_MODE}] ${MODELPARAM_VALUE.WRITE_FIRST_MODE}
}

proc update_MODELPARAM_VALUE.SIZE { MODELPARAM_VALUE.SIZE PARAM_VALUE.SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SIZE}] ${MODELPARAM_VALUE.SIZE}
}

proc update_MODELPARAM_VALUE.ADDR_WIDTH { MODELPARAM_VALUE.ADDR_WIDTH PARAM_VALUE.ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ADDR_WIDTH}] ${MODELPARAM_VALUE.ADDR_WIDTH}
}

