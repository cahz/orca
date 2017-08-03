# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "BYTE_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RAM_WIDTH" -parent ${Page_0}

  set SIZE [ipgui::add_param $IPINST -name "SIZE"]
  set_property tooltip {Number of bytes stored in IDRAM.} ${SIZE}

}

proc update_PARAM_VALUE.ADDR_WIDTH { PARAM_VALUE.ADDR_WIDTH } {
	# Procedure called to update ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ADDR_WIDTH { PARAM_VALUE.ADDR_WIDTH } {
	# Procedure called to validate ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.BYTE_SIZE { PARAM_VALUE.BYTE_SIZE } {
	# Procedure called to update BYTE_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BYTE_SIZE { PARAM_VALUE.BYTE_SIZE } {
	# Procedure called to validate BYTE_SIZE
	return true
}

proc update_PARAM_VALUE.RAM_WIDTH { PARAM_VALUE.RAM_WIDTH } {
	# Procedure called to update RAM_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RAM_WIDTH { PARAM_VALUE.RAM_WIDTH } {
	# Procedure called to validate RAM_WIDTH
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

proc update_MODELPARAM_VALUE.BYTE_SIZE { MODELPARAM_VALUE.BYTE_SIZE PARAM_VALUE.BYTE_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BYTE_SIZE}] ${MODELPARAM_VALUE.BYTE_SIZE}
}

proc update_MODELPARAM_VALUE.SIZE { MODELPARAM_VALUE.SIZE PARAM_VALUE.SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SIZE}] ${MODELPARAM_VALUE.SIZE}
}

proc update_MODELPARAM_VALUE.ADDR_WIDTH { MODELPARAM_VALUE.ADDR_WIDTH PARAM_VALUE.ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ADDR_WIDTH}] ${MODELPARAM_VALUE.ADDR_WIDTH}
}

