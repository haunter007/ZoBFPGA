if { [llength $argv] < 2 } {
  puts "ERROR: usage: vivado -mode batch -source package_hls_ip.tcl -tclargs <hls_proj_dir> <top_name> ?part?"
  exit 1
}

set hls_proj [file normalize [lindex $argv 0]]
set top_name [lindex $argv 1]
set part_name "xck26-sfvc784-2LV-c"
if { [llength $argv] >= 3 } {
  set part_name [lindex $argv 2]
}

set impl_dir [file join $hls_proj "sol1" "impl" "verilog"]
if { ![file isdirectory $impl_dir] } {
  puts "ERROR: impl verilog dir not found: $impl_dir"
  exit 2
}

set out_root [file join $hls_proj "sol1" "ip_repo" $top_name]
set tmp_proj [file join $hls_proj "sol1" ".package_ip_vivado"]

file delete -force $out_root
file delete -force $tmp_proj
file mkdir $out_root
file mkdir $tmp_proj

create_project -force package_ip $tmp_proj -part $part_name
set_property target_language Verilog [current_project]

set rtl_files [glob -nocomplain -directory $impl_dir *.v]
set dat_files [glob -nocomplain -directory $impl_dir *.dat]
if { [llength $rtl_files] == 0 } {
  puts "ERROR: no Verilog files found in $impl_dir"
  exit 3
}

add_files -norecurse {*}$rtl_files
if { [llength $dat_files] > 0 } {
  add_files -norecurse {*}$dat_files
}
set_property top $top_name [current_fileset]
update_compile_order -fileset sources_1

ipx::package_project -root_dir $out_root -vendor user.org -library hls -taxonomy /UserIP -import_files -set_current true
set core [ipx::current_core]
set_property name $top_name $core
set_property display_name $top_name $core
set_property description "Packaged from Vitis HLS impl/verilog output" $core
set_property vendor_display_name "user.org" $core
set_property version 1.0 $core

set axi_if_list {s_axi_control m_axi_state_port m_axi_param_port m_axi_meas_y_port m_axi_meas_phi_port}
foreach bus_name $axi_if_list {
  catch {ipx::infer_bus_interface $bus_name xilinx.com:interface:aximm_rtl:1.0 $core}
}
catch {ipx::infer_bus_interface ap_clk xilinx.com:signal:clock_rtl:1.0 $core}
catch {ipx::infer_bus_interface ap_rst_n xilinx.com:signal:reset_rtl:1.0 $core}

foreach bus_name $axi_if_list {
  catch {ipx::associate_bus_interfaces -busif $bus_name -clock ap_clk $core}
}
catch {set_property value 95000000 [ipx::get_bus_parameters FREQ_HZ -of_objects [ipx::get_bus_interfaces ap_clk -of_objects $core]]}
catch {set_property value ap_rst_n [ipx::get_bus_parameters ASSOCIATED_RESET -of_objects [ipx::get_bus_interfaces ap_clk -of_objects $core]]}

ipx::create_xgui_files $core
ipx::update_checksums $core
ipx::save_core $core

close_project

puts "INFO: packaged IP repo at $out_root"
puts "INFO: component.xml at [file join $out_root component.xml]"
exit 0
