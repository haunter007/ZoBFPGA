
/opt/Xilinx/2025.2/Vivado/bin/xelab xil_defaultlib.apatb_predict_kernel_top xil_defaultlib.glbl -Oenable_linking_all_libraries  -prj predict_kernel.prj -L smartconnect_v1_0 -L axi_protocol_checker_v1_1_12 -L axi_protocol_checker_v1_1_13 -L axis_protocol_checker_v1_1_11 -L axis_protocol_checker_v1_1_12 -L xil_defaultlib -L unisims_ver -L xpm  -L floating_point_v7_1_21 -L floating_point_v7_0_26 --lib "ieee_proposed=./ieee_proposed"  -L uvm -relax -i ./svr -i ./svtb -i ./file_agent -i ./predict_kernel_subsystem -s predict_kernel 
/opt/Xilinx/2025.2/Vivado/bin/xsim -testplusarg "UVM_VERBOSITY=UVM_NONE" -testplusarg "UVM_TESTNAME=predict_kernel_test_lib" -testplusarg "UVM_TIMEOUT=20000000000000" --noieeewarnings predict_kernel -tclbatch predict_kernel.tcl 

