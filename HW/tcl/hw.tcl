
# Created project named "arch"
start_gui
create_project arch /home/ft/Thesis/Hardware-Accelerated-SigmaVPN/HW/vivado/arch -part xc7z010clg400-1

# Created Block Design named "blockdesign"
create_bd_design "blockdesign"

# Add and configure processing system
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0
endgroup
startgroup
set_property -dict [list CONFIG.PCW_UIPARAM_DDR_FREQ_MHZ {525.0} CONFIG.PCW_CRYSTAL_PERIPHERAL_FREQMHZ {50} CONFIG.PCW_APU_PERIPHERAL_FREQMHZ {650.0} CONFIG.PCW_USE_S_AXI_HP0 {1} CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 1.8V} CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} CONFIG.PCW_QSPI_QSPI_IO {MIO 1 .. 6} CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1} CONFIG.PCW_QSPI_GRP_FBCLK_ENABLE {1} CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27} CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1} CONFIG.PCW_ENET0_GRP_MDIO_IO {MIO 52 .. 53} CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} CONFIG.PCW_SD0_SD0_IO {MIO 40 .. 45} CONFIG.PCW_SD0_GRP_CD_ENABLE {1} CONFIG.PCW_SD0_GRP_CD_IO {MIO 47} CONFIG.PCW_SD0_GRP_WP_ENABLE {1} CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} CONFIG.PCW_UART1_UART1_IO {MIO 48 .. 49} CONFIG.PCW_USB0_PERIPHERAL_ENABLE {1} CONFIG.PCW_USB0_USB0_IO {MIO 28 .. 39} CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {1} CONFIG.PCW_I2C0_I2C0_IO {EMIO} CONFIG.PCW_I2C1_PERIPHERAL_ENABLE {0} CONFIG.PCW_I2C1_I2C1_IO {EMIO} CONFIG.PCW_MIO_1_PULLUP {disabled} CONFIG.PCW_MIO_1_SLEW {fast} CONFIG.PCW_MIO_2_SLEW {fast} CONFIG.PCW_MIO_3_SLEW {fast} CONFIG.PCW_MIO_4_SLEW {fast} CONFIG.PCW_MIO_5_SLEW {fast} CONFIG.PCW_MIO_6_SLEW {fast} CONFIG.PCW_MIO_8_SLEW {fast} CONFIG.PCW_MIO_16_PULLUP {disabled} CONFIG.PCW_MIO_17_PULLUP {disabled} CONFIG.PCW_MIO_18_PULLUP {disabled} CONFIG.PCW_MIO_18_IOTYPE {HSTL 1.8V} CONFIG.PCW_MIO_18_SLEW {fast} CONFIG.PCW_MIO_19_PULLUP {disabled} CONFIG.PCW_MIO_19_IOTYPE {HSTL 1.8V} CONFIG.PCW_MIO_19_SLEW {fast} CONFIG.PCW_MIO_20_PULLUP {disabled} CONFIG.PCW_MIO_20_IOTYPE {HSTL 1.8V} CONFIG.PCW_MIO_20_SLEW {fast} CONFIG.PCW_MIO_21_PULLUP {disabled} CONFIG.PCW_MIO_21_IOTYPE {HSTL 1.8V} CONFIG.PCW_MIO_21_SLEW {fast} CONFIG.PCW_MIO_22_PULLUP {disabled} CONFIG.PCW_MIO_22_IOTYPE {HSTL 1.8V} CONFIG.PCW_MIO_22_SLEW {fast} CONFIG.PCW_MIO_23_PULLUP {disabled} CONFIG.PCW_MIO_23_IOTYPE {HSTL 1.8V} CONFIG.PCW_MIO_23_SLEW {fast} CONFIG.PCW_MIO_24_PULLUP {disabled} CONFIG.PCW_MIO_24_IOTYPE {HSTL 1.8V} CONFIG.PCW_MIO_24_SLEW {fast} CONFIG.PCW_MIO_25_PULLUP {disabled} CONFIG.PCW_MIO_25_IOTYPE {HSTL 1.8V} CONFIG.PCW_MIO_25_SLEW {fast} CONFIG.PCW_MIO_26_PULLUP {disabled} CONFIG.PCW_MIO_26_IOTYPE {HSTL 1.8V} CONFIG.PCW_MIO_26_SLEW {fast} CONFIG.PCW_MIO_27_PULLUP {disabled} CONFIG.PCW_MIO_27_IOTYPE {HSTL 1.8V} CONFIG.PCW_MIO_27_SLEW {fast} CONFIG.PCW_MIO_28_PULLUP {disabled} CONFIG.PCW_MIO_28_SLEW {fast} CONFIG.PCW_MIO_29_PULLUP {disabled} CONFIG.PCW_MIO_29_SLEW {fast} CONFIG.PCW_MIO_30_PULLUP {disabled} CONFIG.PCW_MIO_30_SLEW {fast} CONFIG.PCW_MIO_31_PULLUP {disabled} CONFIG.PCW_MIO_31_SLEW {fast} CONFIG.PCW_MIO_32_PULLUP {disabled} CONFIG.PCW_MIO_32_SLEW {fast} CONFIG.PCW_MIO_33_PULLUP {disabled} CONFIG.PCW_MIO_33_SLEW {fast} CONFIG.PCW_MIO_34_PULLUP {disabled} CONFIG.PCW_MIO_34_SLEW {fast} CONFIG.PCW_MIO_35_PULLUP {disabled} CONFIG.PCW_MIO_35_SLEW {fast} CONFIG.PCW_MIO_36_PULLUP {disabled} CONFIG.PCW_MIO_36_SLEW {fast} CONFIG.PCW_MIO_37_PULLUP {disabled} CONFIG.PCW_MIO_37_SLEW {fast} CONFIG.PCW_MIO_38_PULLUP {disabled} CONFIG.PCW_MIO_38_SLEW {fast} CONFIG.PCW_MIO_39_PULLUP {disabled} CONFIG.PCW_MIO_39_SLEW {fast} CONFIG.PCW_MIO_40_PULLUP {disabled} CONFIG.PCW_MIO_40_SLEW {fast} CONFIG.PCW_MIO_41_PULLUP {disabled} CONFIG.PCW_MIO_41_SLEW {fast} CONFIG.PCW_MIO_42_PULLUP {disabled} CONFIG.PCW_MIO_42_SLEW {fast} CONFIG.PCW_MIO_43_PULLUP {disabled} CONFIG.PCW_MIO_43_SLEW {fast} CONFIG.PCW_MIO_44_PULLUP {disabled} CONFIG.PCW_MIO_44_SLEW {fast} CONFIG.PCW_MIO_45_PULLUP {disabled} CONFIG.PCW_MIO_45_SLEW {fast} CONFIG.PCW_MIO_48_PULLUP {disabled} CONFIG.PCW_MIO_49_PULLUP {disabled}] [get_bd_cells processing_system7_0]
endgroup
startgroup
set_property -dict [list CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_0 {-0.073} CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_1 {-0.034} CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_2 {-0.03} CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_3 {-0.082} CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY0 {0.176} CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY1 {0.159} CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY2 {0.162} CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY3 {0.183} CONFIG.PCW_CRYSTAL_PERIPHERAL_FREQMHZ {50.00} CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100.0} CONFIG.PCW_USE_FABRIC_INTERRUPT {1} CONFIG.PCW_IRQ_F2P_INTR {1} CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41K128M16 JT-125}] [get_bd_cells processing_system7_0]
endgroup

# Add CryptoCP IP to the project
set_property  ip_repo_paths  /home/ft/Thesis/Hardware-Accelerated-SigmaVPN/CryptoCP [current_project]
update_ip_catalog

### Create the block Diagram

# Add CryptoCP
startgroup
create_bd_cell -type ip -vlnv fturan:user:CryptoCP:1.0 CryptoCP_0
endgroup

# Add Processor System Reset
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0
endgroup
startgroup

# Add AXI Interconnect between CrytoCP and DMA
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0
endgroup
startgroup
set_property -dict [list CONFIG.NUM_SI {2} CONFIG.NUM_MI {1}] [get_bd_cells axi_interconnect_0]
endgroup

# Add AXI Interconnect between DMA and Processing System
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_1
endgroup
startgroup
set_property -dict [list CONFIG.NUM_SI {2} CONFIG.NUM_MI {1}] [get_bd_cells axi_interconnect_1]
endgroup

# Add DMA
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_0
endgroup
startgroup
set_property -dict [list CONFIG.c_include_sg {0} CONFIG.c_include_mm2s_dre {1} CONFIG.c_mm2s_burst_size {256} CONFIG.c_include_s2mm_dre {1} CONFIG.c_s2mm_burst_size {256} CONFIG.c_sg_include_stscntrl_strm {0}] [get_bd_cells axi_dma_0]
endgroup

# Add Ground for SDIO_0 input of the Processing System
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0
endgroup
set_property -dict [list CONFIG.CONST_VAL {0}] [get_bd_cells xlconstant_0]


### Start Wiring

# Connect RESET's 
connect_bd_net [get_bd_pins proc_sys_reset_0/interconnect_aresetn] [get_bd_pins axi_interconnect_0/ARESETN]
connect_bd_net -net [get_bd_nets proc_sys_reset_0_interconnect_aresetn] [get_bd_pins axi_interconnect_1/ARESETN] [get_bd_pins proc_sys_reset_0/interconnect_aresetn]
connect_bd_net [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins axi_interconnect_0/S00_ARESETN]
connect_bd_net -net [get_bd_nets proc_sys_reset_0_peripheral_aresetn] [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
connect_bd_net -net [get_bd_nets proc_sys_reset_0_peripheral_aresetn] [get_bd_pins axi_interconnect_0/S01_ARESETN] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
connect_bd_net -net [get_bd_nets proc_sys_reset_0_peripheral_aresetn] [get_bd_pins axi_interconnect_1/S00_ARESETN] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
connect_bd_net -net [get_bd_nets proc_sys_reset_0_peripheral_aresetn] [get_bd_pins axi_interconnect_1/M00_ARESETN] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
connect_bd_net -net [get_bd_nets proc_sys_reset_0_peripheral_aresetn] [get_bd_pins axi_interconnect_1/S01_ARESETN] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
connect_bd_net -net [get_bd_nets proc_sys_reset_0_peripheral_aresetn] [get_bd_pins axi_dma_0/axi_resetn] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
connect_bd_net -net [get_bd_nets proc_sys_reset_0_peripheral_aresetn] [get_bd_pins CryptoCP_0/ramtocp_aresetn] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
connect_bd_net -net [get_bd_nets proc_sys_reset_0_peripheral_aresetn] [get_bd_pins CryptoCP_0/process_aresetn] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
connect_bd_net -net [get_bd_nets proc_sys_reset_0_peripheral_aresetn] [get_bd_pins CryptoCP_0/cptoram_aresetn] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
connect_bd_net -net [get_bd_nets proc_sys_reset_0_peripheral_aresetn] [get_bd_pins CryptoCP_0/dmactrl_aresetn] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
connect_bd_net [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins proc_sys_reset_0/ext_reset_in]

# Connect CLOCK's
connect_bd_net [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins proc_sys_reset_0/slowest_sync_clk]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins CryptoCP_0/ramtocp_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins CryptoCP_0/process_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins CryptoCP_0/cptoram_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins CryptoCP_0/dmactrl_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins axi_interconnect_0/S01_ACLK] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins axi_interconnect_1/ACLK] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins axi_interconnect_1/S00_ACLK] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins axi_interconnect_1/M00_ACLK] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins axi_interconnect_1/S01_ACLK] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins axi_dma_0/s_axi_lite_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins axi_dma_0/m_axi_mm2s_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins axi_dma_0/m_axi_s2mm_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins processing_system7_0/S_AXI_HP0_ACLK] [get_bd_pins processing_system7_0/FCLK_CLK0]


# Connect DATA Busses
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_interconnect_1/M00_AXI] [get_bd_intf_pins processing_system7_0/S_AXI_HP0]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_interconnect_1/S01_AXI] [get_bd_intf_pins axi_dma_0/M_AXI_S2MM]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_interconnect_1/S00_AXI] [get_bd_intf_pins axi_dma_0/M_AXI_MM2S]
connect_bd_intf_net [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S] [get_bd_intf_pins CryptoCP_0/RAMtoCP]
connect_bd_intf_net [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM] [get_bd_intf_pins CryptoCP_0/CPtoRAM]
connect_bd_intf_net [get_bd_intf_pins CryptoCP_0/DMActrl] -boundary_type upper [get_bd_intf_pins axi_interconnect_0/S01_AXI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_interconnect_0/S00_AXI] [get_bd_intf_pins processing_system7_0/M_AXI_GP0]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_interconnect_0/M00_AXI] [get_bd_intf_pins axi_dma_0/S_AXI_LITE]

# Connect GND
connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins processing_system7_0/SDIO0_WP]

# Apply Block automation
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]

# Assign Addresses
assign_bd_address [get_bd_addr_segs {axi_dma_0/S_AXI_LITE/Reg }]
assign_bd_address [get_bd_addr_segs {processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM }]

# Create HDL Wrapper
make_wrapper -files [get_files /home/ft/Thesis/Hardware-Accelerated-SigmaVPN/HW/vivado/arch/arch.srcs/sources_1/bd/blockdesign/blockdesign.bd] -top
add_files -norecurse /home/ft/Thesis/Hardware-Accelerated-SigmaVPN/HW/vivado/arch/arch.srcs/sources_1/bd/blockdesign/hdl/blockdesign_wrapper.v
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# Design is done
save_bd_design