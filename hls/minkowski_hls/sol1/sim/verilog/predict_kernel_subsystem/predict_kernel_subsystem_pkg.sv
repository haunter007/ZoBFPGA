//==============================================================
//Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
//Tool Version Limit: 2025.11
//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//
//==============================================================
`timescale 1ns/1ps 

`ifndef PREDICT_KERNEL_SUBSYSTEM_PKG__SV          
    `define PREDICT_KERNEL_SUBSYSTEM_PKG__SV      
                                                     
    package predict_kernel_subsystem_pkg;               
                                                     
        import uvm_pkg::*;                           
        import file_agent_pkg::*;                    
        import svr_pkg::*;
                                                     
        `include "uvm_macros.svh"                  
                                                     
        `include "predict_kernel_config.sv"           
        `include "predict_kernel_reference_model.sv"  
        `include "predict_kernel_scoreboard.sv"       
        `include "predict_kernel_subsystem_monitor.sv"
        `include "predict_kernel_virtual_sequencer.sv"
        `include "predict_kernel_pkg_sequence_lib.sv" 
        `include "predict_kernel_env.sv"              
                                                     
    endpackage                                       
                                                     
`endif                                               
