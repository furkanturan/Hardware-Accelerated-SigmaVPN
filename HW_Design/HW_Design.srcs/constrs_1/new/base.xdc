#set_property PACKAGE_PIN R18 [get_ports {btns_4bits_tri_i[0]}]
#set_property PACKAGE_PIN P16 [get_ports {btns_4bits_tri_i[1]}]
#set_property PACKAGE_PIN V16 [get_ports {btns_4bits_tri_i[2]}]
#set_property PACKAGE_PIN Y16 [get_ports {btns_4bits_tri_i[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {btns_4bits_tri_i[*]}]

#set_property PACKAGE_PIN M14 [get_ports {dmactrl_awvalid}]
#set_property IOSTANDARD LVCMOS33 [get_ports {dmactrl_awvalid}]
#set_property PACKAGE_PIN M15 [get_ports {S01_AXI_awready}]
#set_property IOSTANDARD LVCMOS33 [get_ports {S01_AXI_awready}]
#set_property PACKAGE_PIN G14 [get_ports {dmactrl_bready}]
#set_property IOSTANDARD LVCMOS33 [get_ports {dmactrl_bready}]
#set_property PACKAGE_PIN D18 [get_ports {S01_AXI_bvalid}]
#set_property IOSTANDARD LVCMOS33 [get_ports {S01_AXI_bvalid}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]

#set_property PACKAGE_PIN G15 [get_ports {sws_4bits_tri_i[0]}]
#set_property PACKAGE_PIN P15 [get_ports {sws_4bits_tri_i[1]}]
#set_property PACKAGE_PIN W13 [get_ports {sws_4bits_tri_i[2]}]
#set_property PACKAGE_PIN T16 [get_ports {sws_4bits_tri_i[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {sws_4bits_tri_i[*]}]

set_property PACKAGE_PIN N18 [get_ports iic_0_scl_io]
set_property IOSTANDARD LVCMOS33 [get_ports iic_0_scl_io]
set_property PACKAGE_PIN N17 [get_ports iic_0_sda_io]
set_property IOSTANDARD LVCMOS33 [get_ports iic_0_sda_io]

#False path constraints for crossing clock domains in the Audio and Display cores.
#Synchronization between the clock domains is handled properly in logic.
#TODO: The following constraints should be changed to identify the proper pins
#      of the cores by their hierarchical pin names. Currently the global clock names are
#      used. Ultimately, it would be nice to have the cores automatically generate them.
#adi_i2s constaints:
set_false_path -from [get_clocks clk_fpga_0] -to [get_clocks clk_fpga_2]
set_false_path -from [get_clocks clk_fpga_2] -to [get_clocks clk_fpga_0]
