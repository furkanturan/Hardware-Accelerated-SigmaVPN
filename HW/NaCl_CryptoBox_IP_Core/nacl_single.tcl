create_project NaCl_CryptoBox_Single ./vivado_single -part xc7z010clg400-1

set_property target_language VHDL [current_project]

add_files -norecurse ./hdl_single/OutputDMA.vhd 
add_files -norecurse ./hdl_single/Poly1305.vhd 
add_files -norecurse ./hdl_single/hSalsa20.vhd 
add_files -norecurse ./hdl_single/Controller.vhd 
add_files -norecurse ./hdl_single/DMA_Controller.vhd
add_files -norecurse ./hdl_single/Poly1305_RS.vhd 
add_files -norecurse ./hdl_single/InputReg.vhd 
add_files -norecurse ./hdl_single/Poly1305_Chunk.vhd 
add_files -norecurse ./hdl_single/NaCl.vhd
add_files -norecurse ./hdl_single/NonceMUX.vhd

set_property top NaCl_single [current_fileset]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

ipx::package_project -root_dir ./ip_repo/nacl_single

set_property vendor furkanturan [ipx::current_core]
set_property taxonomy /UserIP [ipx::current_core]
set_property name NaCl_Single [ipx::current_core]
set_property version 1.0 [ipx::current_core]
set_property description {NaCl CryptoBox Single} [ipx::current_core]
set_property display_name {NaCl CryptoBox Single} [ipx::current_core]
set_property core_revision 1 [ipx::current_core]

ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]

set_property ip_repo_paths  ./ip_repo/nacl_single [current_project]
update_ip_catalog


