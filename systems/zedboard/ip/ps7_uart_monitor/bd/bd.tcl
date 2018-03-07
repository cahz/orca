proc init { cell_name other_params } {
  set_property BRIDGES {M_AXI} [get_bd_intf_pins $cell_name/S_AXI]
}
