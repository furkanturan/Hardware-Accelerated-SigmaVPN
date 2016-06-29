create_project NaCl_CryptoBox_Double ./vivado_double -part xc7z010clg400-1

set_property target_language VHDL [current_project]

add_files -norecurse ./hdl_double/OutputDMA.vhd 
add_files -norecurse ./hdl_double/Poly1305.vhd 
add_files -norecurse ./hdl_double/hSalsa20.vhd 
add_files -norecurse ./hdl_double/Controller.vhd 
add_files -norecurse ./hdl_double/DMA_Controller.vhd
add_files -norecurse ./hdl_double/Poly1305_RS.vhd 
add_files -norecurse ./hdl_double/InputReg.vhd 
add_files -norecurse ./hdl_double/Poly1305_Chunk.vhd 
add_files -norecurse ./hdl_double/NaCl.vhd
add_files -norecurse ./hdl_double/NonceMUX.vhd

set_property top NaCl_double [current_fileset]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

ipx::package_project -root_dir ./ip_repo/nacl_double

set_property vendor furkanturan [ipx::current_core]
set_property taxonomy /UserIP [ipx::current_core]
set_property name NaCl_Double [ipx::current_core]
set_property version 1.0 [ipx::current_core]
set_property description {NaCl CryptoBox Double} [ipx::current_core]
set_property display_name {NaCl CryptoBox Double} [ipx::current_core]
set_property core_revision 2 [ipx::current_core]

ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]

set_property ip_repo_paths  ./ip_repo/nacl_double [current_project]
update_ip_catalog


