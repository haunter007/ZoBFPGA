# Usage:
# vitis_hls run_hls.tcl <mode> <proj> <top> <part_or_platform> <clk_mhz> <kernel_src> <tb_src> [cflags...]
# Note: vitis_hls 2025.2 会把以 '-' 开头的参数当作工具选项解析，建议把编译参数放到环境变量 HLS_CFLAGS 里传入。
#
# Examples (single-step kernel, original):
#   vitis_hls run_hls.tcl synth  ../../data/output/hls/HLS_Report  zonotope_step_kernel_axi  xck26-sfvc784-2LV-c 95  fpga_kernels.cpp testbench.cpp
#
# Examples (batch kernel — recommended for speedup over C++):
#   HLS_TB_MODE=batch vitis_hls run_hls.tcl synth  ../../data/output/hls/HLS_Report_batch  zonotope_batch_kernel_axi  xck26-sfvc784-2LV-c 95  fpga_kernels.cpp testbench.cpp
#   HLS_TB_MODE=batch vitis_hls run_hls.tcl csim   ../../data/output/hls/HLS_Report_batch  zonotope_batch_kernel_axi  xck26-sfvc784-2LV-c 95  fpga_kernels.cpp testbench.cpp

# -----------------------------
# Parse argv robustly
# -----------------------------
if { [llength $argv] < 7 } {
  puts "ERROR: insufficient args."
  puts "Expected: <mode> <proj> <top> <part_or_platform> <clk_mhz> <kernel_src> <tb_src> [cflags...]"
  puts "Got argv: $argv"
  exit 1
}

set mode            [lindex $argv 0]
set proj            [lindex $argv 1]
set top             [lindex $argv 2]
set part_or_platform [lindex $argv 3]
set clk_mhz         [lindex $argv 4]
set kernel_src_in   [lindex $argv 5]
set tb_src_in       [lindex $argv 6]
set cflags          [lrange $argv 7 end]

# Directory of this script (independent of current working dir)
set script_dir [file dirname [file normalize [info script]]]

# Normalize source paths: if relative, interpret relative to script_dir
if { [file pathtype $kernel_src_in] eq "relative" } {
  set kernel_src [file normalize [file join $script_dir $kernel_src_in]]
} else {
  set kernel_src [file normalize $kernel_src_in]
}

if { [file pathtype $tb_src_in] eq "relative" } {
  set tb_src [file normalize [file join $script_dir $tb_src_in]]
} else {
  set tb_src [file normalize $tb_src_in]
}

# Basic sanity checks
if { ![file exists $kernel_src] } {
  puts "ERROR: kernel_src not found: $kernel_src"
  exit 2
}
if { ![file exists $tb_src] } {
  puts "ERROR: tb_src not found: $tb_src"
  exit 3
}

puts "INFO: mode=$mode"
puts "INFO: proj=$proj top=$top"
puts "INFO: part_or_platform=$part_or_platform"
puts "INFO: clk_mhz=$clk_mhz"
puts "INFO: kernel_src=$kernel_src"
puts "INFO: tb_src=$tb_src"
puts "INFO: cflags=$cflags"

proc patch_generated_xsim_script {sim_verilog_dir top} {
  set script_path [file normalize [file join $sim_verilog_dir "xsim.dir" $top "xsim_script.tcl"]]
  if {![file exists $script_path]} {
    puts "WARN: xsim script not found: $script_path"
    return 0
  }

  set fh [open $script_path r]
  set content [read $fh]
  close $fh

  set patched [string map [list \
    [format {xsim {%s}} $top] [format {xsim %s} $top] \
    [format {-tclbatch {%s.tcl}} $top] [format {-tclbatch %s.tcl} $top] \
  ] $content]

  if {$patched ne $content} {
    set fh [open $script_path w]
    puts -nonewline $fh $patched
    close $fh
    puts "INFO: patched malformed xsim script: $script_path"
    return 1
  }

  puts "INFO: xsim script did not need patching: $script_path"
  return 0
}

proc run_manual_cosim_fallback {proj top} {
  set sim_verilog_dir [file normalize [file join $proj "sol1" "sim" "verilog"]]
  set run_xsim_path [file normalize [file join $sim_verilog_dir "run_xsim.sh"]]
  if {![file exists $run_xsim_path]} {
    error "manual cosim fallback cannot find run_xsim.sh at $run_xsim_path"
  }

  set fh [open $run_xsim_path r]
  set raw_lines [split [read $fh] "\n"]
  close $fh

  set xelab_cmd ""
  set xsim_cmd ""
  foreach line $raw_lines {
    set line [string trim $line]
    if {$line eq ""} {
      continue
    }
    if {$xelab_cmd eq ""} {
      set xelab_cmd $line
    } elseif {$xsim_cmd eq ""} {
      set xsim_cmd $line
      break
    }
  }

  if {$xelab_cmd eq "" || $xsim_cmd eq ""} {
    error "manual cosim fallback could not parse xelab/xsim commands from $run_xsim_path"
  }

  set prev_dir [pwd]
  cd $sim_verilog_dir
  puts "INFO: manual cosim fallback running xelab"
  set ret [catch {exec sh -lc $xelab_cmd >&@ stdout} err]
  if {$ret} {
    cd $prev_dir
    error "manual cosim fallback xelab failed: $err"
  }

  patch_generated_xsim_script $sim_verilog_dir $top

  puts "INFO: manual cosim fallback running xsim"
  set ret [catch {exec sh -lc $xsim_cmd >&@ stdout} err]
  if {$ret} {
    cd $prev_dir
    error "manual cosim fallback xsim failed: $err"
  }

  set tvout_path [file normalize [file join $sim_verilog_dir ".." "tv" "rtldatafile" "rtl.${top}.autotvout_state_port.dat"]]
  if {![file exists $tvout_path]} {
    cd $prev_dir
    error "manual cosim fallback did not produce RTL tvout: $tvout_path"
  }

  set wrapc_pc_dir [file normalize [file join $sim_verilog_dir ".." "wrapc_pc"]]
  set pc_exe [file join $wrapc_pc_dir "cosim.pc.exe"]
  if {[file exists $pc_exe]} {
    cd $wrapc_pc_dir
    puts "INFO: manual cosim fallback running post-check"
    set ret [catch {exec sh -lc "./cosim.pc.exe | tee temp3.log" >&@ stdout} err]
    cd $sim_verilog_dir
    if {$ret} {
      cd $prev_dir
      error "manual cosim fallback post-check failed: $err"
    }
  } else {
    puts "WARN: manual cosim fallback could not find cosim.pc.exe at $pc_exe"
  }

  cd $prev_dir
}

proc patch_file_string_map {path replacements} {
  if {![file exists $path]} {
    puts "WARN: patch target not found: $path"
    return 0
  }

  set fh [open $path r]
  set content [read $fh]
  close $fh

  set patched [string map $replacements $content]
  if {$patched eq $content} {
    puts "INFO: no patch needed for $path"
    return 0
  }

  set fh [open $path w]
  puts -nonewline $fh $patched
  close $fh
  puts "INFO: patched $path"
  return 1
}

proc patch_file_regsub {path patterns_replacements} {
  if {![file exists $path]} {
    puts "WARN: patch target not found: $path"
    return 0
  }

  set fh [open $path r]
  set content [read $fh]
  close $fh

  set patched $content
  foreach {pattern replacement} $patterns_replacements {
    regsub -all -- $pattern $patched $replacement patched
  }

  if {$patched eq $content} {
    puts "INFO: no patch needed for $path"
    return 0
  }

  set fh [open $path w]
  puts -nonewline $fh $patched
  close $fh
  puts "INFO: patched $path"
  return 1
}

proc patch_exported_axi_user_widths {proj top axi_user_width} {
  set export_root [file normalize [file join $proj "sol1"]]
  set top_rtl [file join $export_root "impl" "ip" "hdl" "verilog" "${top}.v"]
  set impl_component [file join $export_root "impl" "ip" "component.xml"]
  set impl_xgui_tcl [file join $export_root "impl" "ip" "xgui" "${top}_v1_0.tcl"]
  set repo_root [file join $export_root "ip_repo" $top]

  set rtl_replacements [list \
    "parameter    C_M_AXI_MEAS_PHI_PORT_AWUSER_WIDTH = 1;" "parameter    C_M_AXI_MEAS_PHI_PORT_AWUSER_WIDTH = $axi_user_width;" \
    "parameter    C_M_AXI_MEAS_PHI_PORT_ARUSER_WIDTH = 1;" "parameter    C_M_AXI_MEAS_PHI_PORT_ARUSER_WIDTH = $axi_user_width;" \
    "parameter    C_M_AXI_MEAS_PHI_PORT_WUSER_WIDTH = 1;" "parameter    C_M_AXI_MEAS_PHI_PORT_WUSER_WIDTH = $axi_user_width;" \
    "parameter    C_M_AXI_MEAS_PHI_PORT_RUSER_WIDTH = 1;" "parameter    C_M_AXI_MEAS_PHI_PORT_RUSER_WIDTH = $axi_user_width;" \
    "parameter    C_M_AXI_MEAS_PHI_PORT_BUSER_WIDTH = 1;" "parameter    C_M_AXI_MEAS_PHI_PORT_BUSER_WIDTH = $axi_user_width;" \
    "parameter    C_M_AXI_MEAS_Y_PORT_AWUSER_WIDTH = 1;" "parameter    C_M_AXI_MEAS_Y_PORT_AWUSER_WIDTH = $axi_user_width;" \
    "parameter    C_M_AXI_MEAS_Y_PORT_ARUSER_WIDTH = 1;" "parameter    C_M_AXI_MEAS_Y_PORT_ARUSER_WIDTH = $axi_user_width;" \
    "parameter    C_M_AXI_MEAS_Y_PORT_WUSER_WIDTH = 1;" "parameter    C_M_AXI_MEAS_Y_PORT_WUSER_WIDTH = $axi_user_width;" \
    "parameter    C_M_AXI_MEAS_Y_PORT_RUSER_WIDTH = 1;" "parameter    C_M_AXI_MEAS_Y_PORT_RUSER_WIDTH = $axi_user_width;" \
    "parameter    C_M_AXI_MEAS_Y_PORT_BUSER_WIDTH = 1;" "parameter    C_M_AXI_MEAS_Y_PORT_BUSER_WIDTH = $axi_user_width;" \
    "parameter    C_M_AXI_PARAM_PORT_AWUSER_WIDTH = 1;" "parameter    C_M_AXI_PARAM_PORT_AWUSER_WIDTH = $axi_user_width;" \
    "parameter    C_M_AXI_PARAM_PORT_ARUSER_WIDTH = 1;" "parameter    C_M_AXI_PARAM_PORT_ARUSER_WIDTH = $axi_user_width;" \
    "parameter    C_M_AXI_PARAM_PORT_WUSER_WIDTH = 1;" "parameter    C_M_AXI_PARAM_PORT_WUSER_WIDTH = $axi_user_width;" \
    "parameter    C_M_AXI_PARAM_PORT_RUSER_WIDTH = 1;" "parameter    C_M_AXI_PARAM_PORT_RUSER_WIDTH = $axi_user_width;" \
    "parameter    C_M_AXI_PARAM_PORT_BUSER_WIDTH = 1;" "parameter    C_M_AXI_PARAM_PORT_BUSER_WIDTH = $axi_user_width;" \
    "parameter    C_M_AXI_STATE_PORT_AWUSER_WIDTH = 1;" "parameter    C_M_AXI_STATE_PORT_AWUSER_WIDTH = $axi_user_width;" \
    "parameter    C_M_AXI_STATE_PORT_ARUSER_WIDTH = 1;" "parameter    C_M_AXI_STATE_PORT_ARUSER_WIDTH = $axi_user_width;" \
    "parameter    C_M_AXI_STATE_PORT_WUSER_WIDTH = 1;" "parameter    C_M_AXI_STATE_PORT_WUSER_WIDTH = $axi_user_width;" \
    "parameter    C_M_AXI_STATE_PORT_RUSER_WIDTH = 1;" "parameter    C_M_AXI_STATE_PORT_RUSER_WIDTH = $axi_user_width;" \
    "parameter    C_M_AXI_STATE_PORT_BUSER_WIDTH = 1;" "parameter    C_M_AXI_STATE_PORT_BUSER_WIDTH = $axi_user_width;" \
  ]

  set changed 0
  set user_width_params {
    C_M_AXI_MEAS_PHI_PORT_AWUSER_WIDTH
    C_M_AXI_MEAS_PHI_PORT_ARUSER_WIDTH
    C_M_AXI_MEAS_PHI_PORT_WUSER_WIDTH
    C_M_AXI_MEAS_PHI_PORT_RUSER_WIDTH
    C_M_AXI_MEAS_PHI_PORT_BUSER_WIDTH
    C_M_AXI_MEAS_Y_PORT_AWUSER_WIDTH
    C_M_AXI_MEAS_Y_PORT_ARUSER_WIDTH
    C_M_AXI_MEAS_Y_PORT_WUSER_WIDTH
    C_M_AXI_MEAS_Y_PORT_RUSER_WIDTH
    C_M_AXI_MEAS_Y_PORT_BUSER_WIDTH
    C_M_AXI_PARAM_PORT_AWUSER_WIDTH
    C_M_AXI_PARAM_PORT_ARUSER_WIDTH
    C_M_AXI_PARAM_PORT_WUSER_WIDTH
    C_M_AXI_PARAM_PORT_RUSER_WIDTH
    C_M_AXI_PARAM_PORT_BUSER_WIDTH
    C_M_AXI_STATE_PORT_AWUSER_WIDTH
    C_M_AXI_STATE_PORT_ARUSER_WIDTH
    C_M_AXI_STATE_PORT_WUSER_WIDTH
    C_M_AXI_STATE_PORT_RUSER_WIDTH
    C_M_AXI_STATE_PORT_BUSER_WIDTH
  }

  set xml_patterns {}
  foreach param $user_width_params {
    lappend xml_patterns \
      [format {<spirit:value([^>]*)id="MODELPARAM_VALUE\.%s"([^>]*)>1</spirit:value>} $param] [format {<spirit:value\1id="MODELPARAM_VALUE.%s"\2>%s</spirit:value>} $param $axi_user_width] \
      [format {<spirit:value([^>]*)id="PARAM_VALUE\.%s"([^>]*)>1</spirit:value>} $param] [format {<spirit:value\1id="PARAM_VALUE.%s"\2>%s</spirit:value>} $param $axi_user_width] \
      [format {(spirit:id="PARAM_VALUE\.%s"[^>]*spirit:minimum=")1(")} $param] [format {\1%s\2} $axi_user_width]
  }

  incr changed [patch_file_string_map $top_rtl $rtl_replacements]
  incr changed [patch_file_regsub $impl_component $xml_patterns]
  incr changed [patch_file_regsub $impl_xgui_tcl [list \
    "set_property value \\[get_property value \\$\\{PARAM_VALUE\\.([A-Z0-9_]+USER_WIDTH)\\}\\] \\$\\{MODELPARAM_VALUE\\.\\1\\}" "set_property value [get_property value \${PARAM_VALUE.\\1}] \${MODELPARAM_VALUE.\\1}" \
  ]]

  file delete -force $repo_root
  file mkdir [file dirname $repo_root]
  file copy -force [file join $export_root "impl" "ip"] $repo_root
  incr changed [patch_file_regsub [file join $repo_root "component.xml"] $xml_patterns]
  incr changed [patch_file_string_map [file join $repo_root "hdl" "verilog" "${top}.v"] $rtl_replacements]
  puts "INFO: AXI USER width post-export patch count=$changed"
}

# -----------------------------
# Project setup
# -----------------------------
open_project -reset $proj
set_top $top

# Add sources
# - Always include this repo's include/ by default
# - Additional flags can be provided via env(HLS_CFLAGS)
# - $cflags (argv tail) is kept for backward compatibility but should avoid leading '-' tokens
set include_dir [file normalize [file join $script_dir "../../include"]]
set cflags_list [list "-I$include_dir"]
if { [info exists ::env(HLS_CFLAGS)] && $::env(HLS_CFLAGS) ne "" } {
  lappend cflags_list $::env(HLS_CFLAGS)
}
if { [llength $cflags] > 0 } {
  lappend cflags_list {*}$cflags
}
set cflags_str [string trim [join $cflags_list " "]]
add_files $kernel_src -cflags $cflags_str
add_files [file normalize [file join $script_dir "zonotope_operations.cpp"]] -cflags $cflags_str
add_files -tb $tb_src -cflags $cflags_str

# Extra TB sources (used by full-pipeline TB for dumps/plots)
set extra_tb_rel [list "dump.cpp"]
foreach rel $extra_tb_rel {
  set f [file normalize [file join $script_dir $rel]]
  if { [file exists $f] } {
    puts "INFO: Adding extra TB source: $f"
    add_files -tb $f -cflags $cflags_str
  }
}

# Some older/generated solutions can leave behind malformed .aps metadata.
# Recreate the solution directory explicitly so batch reruns are deterministic.
set sol_dir [file normalize [file join $proj "sol1"]]
if { [file exists $sol_dir] } {
  file delete -force $sol_dir
}
open_solution -reset "sol1"

# -----------------------------
# KR260: prefer platform if provided; otherwise use part
# -----------------------------
# Heuristic:
# - if arg contains "/" or ends with ".xpfm" or looks like a platform name (kr260),
#   treat it as platform; else treat it as part.
set is_platform 0
if { [string match "*/*" $part_or_platform] } { set is_platform 1 }
if { [string match "*.xpfm" $part_or_platform] } { set is_platform 1 }
if { [string match "*kr260*" [string tolower $part_or_platform]] } { set is_platform 1 }

if { $is_platform } {
  puts "INFO: Using platform: $part_or_platform"
  # Vitis HLS supports platform-based flows; platform can be name or path to .xpfm depending on install
  set_platform $part_or_platform
} else {
  puts "INFO: Using part: $part_or_platform"
  set_part $part_or_platform
}

# If you *also* need board_part (optional, only if you have a board file in Vivado installation):
# Example: set_property board_part xilinx.com:kr260_som:part0:1.1 [current_project]
# Keep commented unless you are sure it exists.
# set_property board_part <BOARD_PART_STRING> [current_project]

# Clock period in ns (1000/ MHz)，这个1000只是MHz和ns之间的代换系数
create_clock -period [expr {1000.0 / double($clk_mhz)}] -name default

# Recommended configs
config_interface -m_axi_addr64=1
config_compile -pipeline_loops=1

# -----------------------------
# Run flow
# -----------------------------
if { $mode eq "csim" } {
  csim_design
} elseif { $mode eq "synth" || $mode eq "csynth" } {
  csynth_design
} elseif { $mode eq "cosim" } {
  # Co-sim needs synthesized RTL; run synth first since this script resets the solution.
  csynth_design
  set cosim_ret [catch {cosim_design} cosim_err]
  if {$cosim_ret} {
    puts "WARN: cosim_design failed, attempting manual xsim fallback"
    puts "WARN: original cosim error: $cosim_err"
    run_manual_cosim_fallback $proj $top
  }
} elseif { $mode eq "export" } {
  csynth_design
  if { [info exists ::env(HLS_IP_VERSION)] && $::env(HLS_IP_VERSION) ne "" } {
    puts "INFO: Using explicit IP version: $::env(HLS_IP_VERSION)"
    config_export -vendor xilinx.com -library hls -ipname $top -version $::env(HLS_IP_VERSION) -rtl verilog
  }
  export_design -format ip_catalog
  set axi_user_width 4
  if { [info exists ::env(HLS_AXI_USER_WIDTH)] && $::env(HLS_AXI_USER_WIDTH) ne "" } {
    set axi_user_width $::env(HLS_AXI_USER_WIDTH)
  }
  puts "INFO: Post-processing exported AXI USER widths to $axi_user_width"
  patch_exported_axi_user_widths $proj $top $axi_user_width
} else {
  puts "ERROR: Unknown mode: $mode"
  exit 4
}

exit
