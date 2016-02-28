create_project NaCl_CryptoBox ./vivado -part xc7z010clg400-1

set_property target_language VHDL [current_project]

add_files -norecurse ./hdl/OutputDMA.vhd 
add_files -norecurse ./hdl/Poly1305.vhd 
add_files -norecurse ./hdl/hSalsa20.vhd 
add_files -norecurse ./hdl/Controller.vhd 
add_files -norecurse ./hdl/DMA_Controller.vhd
add_files -norecurse ./hdl/Poly1305_RS.vhd 
add_files -norecurse ./hdl/InputReg.vhd 
add_files -norecurse ./hdl/Poly1305_Chunk.vhd 
add_files -norecurse ./hdl/NaCl.vhd
add_files -norecurse ./hdl/NonceMUX.vhd

set_property top NaCl [current_fileset]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

ipx::package_project -root_dir ./ip_repo

set_property vendor furkanturan [ipx::current_core]
set_property taxonomy /UserIP [ipx::current_core]
set_property display_name NaCl [ipx::current_core]
set_property description {NaCl CryptoBox} [ipx::current_core]
set_property display_name {NaCl CryptoBox} [ipx::current_core]
set_property core_revision 2 [ipx::current_core]

ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]

set_property ip_repo_paths  ./ip_repo [current_project]
update_ip_catalog
