# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  set Component_Name  [  ipgui::add_param $IPINST -name "Component_Name" -display_name {Component Name}]
  set_property tooltip {Component Name} ${Component_Name}
  #Adding Page
  set Page_0  [  ipgui::add_page $IPINST -name "Page 0" -display_name {Page 0}]
  set_property tooltip {Page 0} ${Page_0}
  set SLAVE_BASE_ADDR  [  ipgui::add_param $IPINST -name "SLAVE_BASE_ADDR" -parent ${Page_0} -display_name {SLAVE_BASE_ADDR}]
  set_property tooltip {SLAVE_BASE_ADDR} ${SLAVE_BASE_ADDR}


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

