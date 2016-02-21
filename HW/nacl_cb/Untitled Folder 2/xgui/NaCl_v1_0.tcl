# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
	set Component_Name [ipgui::add_param $IPINST -name Component_Name]
	set Page0 [ipgui::add_page $IPINST -name "Page 0" -layout vertical]
	set SLAVE_BASE_ADDR [ipgui::add_param $IPINST -parent $Page0 -name SLAVE_BASE_ADDR]
}

proc update_PARAM_VALUE.SLAVE_BASE_ADDR { PARAM_VALUE.SLAVE_BASE_ADDR } {
	# Procedure called to update SLAVE_BASE_ADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SLAVE_BASE_ADDR { PARAM_VALUE.SLAVE_BASE_ADDR } {
	# Procedure called to validate SLAVE_BASE_ADDR
	return true
}


proc update_MODELPARAM_VALUE.SLAVE_BASE_ADDR { MODELPARAM_VALUE.SLAVE_BASE_ADDR PARAM_VALUE.SLAVE_BASE_ADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SLAVE_BASE_ADDR}] ${MODELPARAM_VALUE.SLAVE_BASE_ADDR}
}

