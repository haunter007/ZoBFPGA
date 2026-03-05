# Usage:
# vitis_hls run_hls.tcl <mode> <proj> <top> <part_or_platform> <clk_mhz> <kernel_src> <tb_src> [cflags...]
# Note: vitis_hls 2025.2 会把以 '-' 开头的参数当作工具选项解析，建议把编译参数放到环境变量 HLS_CFLAGS 里传入。
#
# Examples:
#   HLS_CFLAGS="-DTEST=1" vitis_hls run_hls.tcl csim ../../data/output/HLS_Report predict_kernel xck26-sfvc784-2LV-c 100 src/kernels_hls.cpp src/testbench.cpp
#   HLS_CFLAGS="-DTEST=1" vitis_hls run_hls.tcl synth ../../data/output/HLS_Report predict_kernel xilinx_kr260 300 src/kernels_hls.cpp src/testbench.cpp

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
add_files -tb $tb_src -cflags $cflags_str

# Extra TB sources (used by full-pipeline TB for dumps/plots)
set extra_tb_rel [list "zonotope_operations.cpp" "dump.cpp"]
foreach rel $extra_tb_rel {
  set f [file normalize [file join $script_dir $rel]]
  if { [file exists $f] } {
    puts "INFO: Adding extra TB source: $f"
    add_files -tb $f -cflags $cflags_str
  }
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
  cosim_design
} elseif { $mode eq "export" } {
  csynth_design
  export_design -format ip_catalog
} else {
  puts "ERROR: Unknown mode: $mode"
  exit 4
}

exit
