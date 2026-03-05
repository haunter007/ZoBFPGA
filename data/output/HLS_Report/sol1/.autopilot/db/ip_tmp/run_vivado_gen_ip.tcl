create_project prj -part xck26-sfvc784-2LV-c -force
set_property target_language verilog [current_project]
set vivado_ver [version -short]
set COE_DIR "../../syn/verilog"
source "/home/zzh/minkowski_fpga/data/output/HLS_Report/sol1/syn/verilog/predict_kernel_fmul_32ns_32ns_32_3_max_dsp_1_ip.tcl"
source "/home/zzh/minkowski_fpga/data/output/HLS_Report/sol1/syn/verilog/predict_kernel_fadd_32ns_32ns_32_4_full_dsp_1_ip.tcl"
