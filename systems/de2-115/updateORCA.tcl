package require qsys

proc updateORCA { parameter value } {
    foreach instance [get_instances] {
	if {[get_instance_property $instance CLASS_NAME] == "vectorblox_orca"} {
	    set_instance_parameter_value $instance $parameter $value
	}
    }
}
