//==============================================================
//Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
//Tool Version Limit: 2025.11
//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//
//==============================================================

`ifndef SV_MODULE_TOP_SV
`define SV_MODULE_TOP_SV


`timescale 1ns/1ps


`include "uvm_macros.svh"
import uvm_pkg::*;
import file_agent_pkg::*;
import svr_pkg::*;
import predict_kernel_subsystem_pkg::*;
`include "predict_kernel_subsys_test_sequence_lib.sv"
`include "predict_kernel_test_lib.sv"


module sv_module_top;


    misc_interface              misc_if ( .clock(apatb_predict_kernel_top.AESL_clock), .reset(apatb_predict_kernel_top.AESL_reset) );
    assign apatb_predict_kernel_top.ap_start = misc_if.tb2dut_ap_start;
    assign misc_if.dut2tb_ap_done = apatb_predict_kernel_top.ap_done;
    assign misc_if.dut2tb_ap_ready = apatb_predict_kernel_top.ap_ready;
    initial begin
        uvm_config_db #(virtual misc_interface)::set(null, "uvm_test_top.top_env.*", "misc_if", misc_if);
    end


    svr_if #(32)  svr_p_x_0_if    (.clk  (apatb_predict_kernel_top.AESL_clock), .rst(apatb_predict_kernel_top.AESL_reset));
    assign apatb_predict_kernel_top.p_x_0 = svr_p_x_0_if.data[31:0];
    assign svr_p_x_0_if.ready = svr_p_x_0_if.valid & misc_if.tb2dut_ap_start;
    initial begin
        uvm_config_db #( virtual svr_if#(32) )::set(null, "uvm_test_top.top_env.env_master_svr_p_x_0.*", "vif", svr_p_x_0_if);
    end


    svr_if #(32)  svr_p_x_1_if    (.clk  (apatb_predict_kernel_top.AESL_clock), .rst(apatb_predict_kernel_top.AESL_reset));
    assign apatb_predict_kernel_top.p_x_1 = svr_p_x_1_if.data[31:0];
    assign svr_p_x_1_if.ready = svr_p_x_1_if.valid & misc_if.tb2dut_ap_start;
    initial begin
        uvm_config_db #( virtual svr_if#(32) )::set(null, "uvm_test_top.top_env.env_master_svr_p_x_1.*", "vif", svr_p_x_1_if);
    end


    svr_if #(32)  svr_p_x_2_if    (.clk  (apatb_predict_kernel_top.AESL_clock), .rst(apatb_predict_kernel_top.AESL_reset));
    assign apatb_predict_kernel_top.p_x_2 = svr_p_x_2_if.data[31:0];
    assign svr_p_x_2_if.ready = svr_p_x_2_if.valid & misc_if.tb2dut_ap_start;
    initial begin
        uvm_config_db #( virtual svr_if#(32) )::set(null, "uvm_test_top.top_env.env_master_svr_p_x_2.*", "vif", svr_p_x_2_if);
    end


    svr_if #(32)  svr_p_x_3_if    (.clk  (apatb_predict_kernel_top.AESL_clock), .rst(apatb_predict_kernel_top.AESL_reset));
    assign apatb_predict_kernel_top.p_x_3 = svr_p_x_3_if.data[31:0];
    assign svr_p_x_3_if.ready = svr_p_x_3_if.valid & misc_if.tb2dut_ap_start;
    initial begin
        uvm_config_db #( virtual svr_if#(32) )::set(null, "uvm_test_top.top_env.env_master_svr_p_x_3.*", "vif", svr_p_x_3_if);
    end


    svr_if #(32)  svr_m_x_if    (.clk  (apatb_predict_kernel_top.AESL_clock), .rst(apatb_predict_kernel_top.AESL_reset));
    assign apatb_predict_kernel_top.m_x = svr_m_x_if.data[31:0];
    assign svr_m_x_if.ready = svr_m_x_if.valid & misc_if.tb2dut_ap_start;
    initial begin
        uvm_config_db #( virtual svr_if#(32) )::set(null, "uvm_test_top.top_env.env_master_svr_m_x.*", "vif", svr_m_x_if);
    end


    svr_if #(32)  svr_p_w_0_if    (.clk  (apatb_predict_kernel_top.AESL_clock), .rst(apatb_predict_kernel_top.AESL_reset));
    assign apatb_predict_kernel_top.p_w_0 = svr_p_w_0_if.data[31:0];
    assign svr_p_w_0_if.ready = svr_p_w_0_if.valid & misc_if.tb2dut_ap_start;
    initial begin
        uvm_config_db #( virtual svr_if#(32) )::set(null, "uvm_test_top.top_env.env_master_svr_p_w_0.*", "vif", svr_p_w_0_if);
    end


    svr_if #(32)  svr_p_w_1_if    (.clk  (apatb_predict_kernel_top.AESL_clock), .rst(apatb_predict_kernel_top.AESL_reset));
    assign apatb_predict_kernel_top.p_w_1 = svr_p_w_1_if.data[31:0];
    assign svr_p_w_1_if.ready = svr_p_w_1_if.valid & misc_if.tb2dut_ap_start;
    initial begin
        uvm_config_db #( virtual svr_if#(32) )::set(null, "uvm_test_top.top_env.env_master_svr_p_w_1.*", "vif", svr_p_w_1_if);
    end


    svr_if #(32)  svr_p_w_2_if    (.clk  (apatb_predict_kernel_top.AESL_clock), .rst(apatb_predict_kernel_top.AESL_reset));
    assign apatb_predict_kernel_top.p_w_2 = svr_p_w_2_if.data[31:0];
    assign svr_p_w_2_if.ready = svr_p_w_2_if.valid & misc_if.tb2dut_ap_start;
    initial begin
        uvm_config_db #( virtual svr_if#(32) )::set(null, "uvm_test_top.top_env.env_master_svr_p_w_2.*", "vif", svr_p_w_2_if);
    end


    svr_if #(32)  svr_p_w_3_if    (.clk  (apatb_predict_kernel_top.AESL_clock), .rst(apatb_predict_kernel_top.AESL_reset));
    assign apatb_predict_kernel_top.p_w_3 = svr_p_w_3_if.data[31:0];
    assign svr_p_w_3_if.ready = svr_p_w_3_if.valid & misc_if.tb2dut_ap_start;
    initial begin
        uvm_config_db #( virtual svr_if#(32) )::set(null, "uvm_test_top.top_env.env_master_svr_p_w_3.*", "vif", svr_p_w_3_if);
    end


    svr_if #(32)  svr_m_w_if    (.clk  (apatb_predict_kernel_top.AESL_clock), .rst(apatb_predict_kernel_top.AESL_reset));
    assign apatb_predict_kernel_top.m_w = svr_m_w_if.data[31:0];
    assign svr_m_w_if.ready = svr_m_w_if.valid & misc_if.tb2dut_ap_start;
    initial begin
        uvm_config_db #( virtual svr_if#(32) )::set(null, "uvm_test_top.top_env.env_master_svr_m_w.*", "vif", svr_m_w_if);
    end


    svr_if #(32)  svr_p_pred_0_if    (.clk  (apatb_predict_kernel_top.AESL_clock), .rst(apatb_predict_kernel_top.AESL_reset));
    assign svr_p_pred_0_if.valid = apatb_predict_kernel_top.p_pred_0_ap_vld;
    assign svr_p_pred_0_if.data[31:0] = apatb_predict_kernel_top.p_pred_0;
    initial begin
        uvm_config_db #( virtual svr_if#(32) )::set(null, "uvm_test_top.top_env.env_slave_svr_p_pred_0.*", "vif", svr_p_pred_0_if);
    end


    svr_if #(32)  svr_p_pred_1_if    (.clk  (apatb_predict_kernel_top.AESL_clock), .rst(apatb_predict_kernel_top.AESL_reset));
    assign svr_p_pred_1_if.valid = apatb_predict_kernel_top.p_pred_1_ap_vld;
    assign svr_p_pred_1_if.data[31:0] = apatb_predict_kernel_top.p_pred_1;
    initial begin
        uvm_config_db #( virtual svr_if#(32) )::set(null, "uvm_test_top.top_env.env_slave_svr_p_pred_1.*", "vif", svr_p_pred_1_if);
    end


    svr_if #(32)  svr_p_pred_2_if    (.clk  (apatb_predict_kernel_top.AESL_clock), .rst(apatb_predict_kernel_top.AESL_reset));
    assign svr_p_pred_2_if.valid = apatb_predict_kernel_top.p_pred_2_ap_vld;
    assign svr_p_pred_2_if.data[31:0] = apatb_predict_kernel_top.p_pred_2;
    initial begin
        uvm_config_db #( virtual svr_if#(32) )::set(null, "uvm_test_top.top_env.env_slave_svr_p_pred_2.*", "vif", svr_p_pred_2_if);
    end


    svr_if #(32)  svr_p_pred_3_if    (.clk  (apatb_predict_kernel_top.AESL_clock), .rst(apatb_predict_kernel_top.AESL_reset));
    assign svr_p_pred_3_if.valid = apatb_predict_kernel_top.p_pred_3_ap_vld;
    assign svr_p_pred_3_if.data[31:0] = apatb_predict_kernel_top.p_pred_3;
    initial begin
        uvm_config_db #( virtual svr_if#(32) )::set(null, "uvm_test_top.top_env.env_slave_svr_p_pred_3.*", "vif", svr_p_pred_3_if);
    end


    svr_if #(32)  svr_m_pred_if    (.clk  (apatb_predict_kernel_top.AESL_clock), .rst(apatb_predict_kernel_top.AESL_reset));
    assign svr_m_pred_if.valid = apatb_predict_kernel_top.m_pred_ap_vld;
    assign svr_m_pred_if.data[31:0] = apatb_predict_kernel_top.m_pred;
    initial begin
        uvm_config_db #( virtual svr_if#(32) )::set(null, "uvm_test_top.top_env.env_slave_svr_m_pred.*", "vif", svr_m_pred_if);
    end


    initial begin
        run_test();
    end
endmodule
`endif
