proc propagate {cell_name args} {
         #to support versions >=2014.3
         #make these functions the same
         post_propagate $cell_name $args

         #for each custom instruction port we set the number of lanes from
         #the MXP
         set custom_intf [get_bd_intf_pins $cell_name/M_VCI*]

         for {set vci 0} {$vci < [llength $custom_intf ]} {incr vci} {
                  set intf [get_bd_intf_pins $cell_name/M_VCI[set vci] ]
                  set net [get_bd_intf_nets  -of_objects $intf ]
                  set intf [ get_bd_intf_pins -of_objects $net -filter {MODE==Slave} ]
                  set custom_cell [get_bd_cells -of_objects  $intf ]
                  set custom_lanes [get_property "CONFIG.VCI_[set vci]_LANES" [get_bd_cells $cell_name]]

                  set_property CONFIG.VCI_LANES.VALUE_SRC "DEFAULT" $custom_cell
                  set_property CONFIG.VCI_LANES $custom_lanes $custom_cell
         }
}

proc post_propagate {cellpath undefined_params} {
    set ip [get_bd_cells $cellpath]
    set busif [get_bd_intf_pins $cellpath/S_AXI_INSTR]

    if {$busif != ""} {
        set id_wid [get_property CONFIG.ID_WIDTH $busif]
        set_property CONFIG.ID_WIDTH $id_wid $ip
    }
}
