// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
// Tool Version Limit: 2025.11
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
`timescale 1ns/1ps


`define AUTOTB_DUT      predict_kernel
`define AUTOTB_DUT_INST AESL_inst_predict_kernel
`define AUTOTB_TOP      apatb_predict_kernel_top
`define AUTOTB_LAT_RESULT_FILE "predict_kernel.result.lat.rb"
`define AUTOTB_PER_RESULT_TRANS_FILE "predict_kernel.performance.result.transaction.xml"
`define AUTOTB_TOP_INST AESL_inst_apatb_predict_kernel_top
`define AUTOTB_MAX_ALLOW_LATENCY  15000000
`define AUTOTB_CLOCK_PERIOD_DIV2 5.00

`define AESL_DEPTH_p_x_0 1
`define AESL_DEPTH_p_x_1 1
`define AESL_DEPTH_p_x_2 1
`define AESL_DEPTH_p_x_3 1
`define AESL_MEM_H_x_0 AESL_automem_H_x_0
`define AESL_MEM_INST_H_x_0 mem_inst_H_x_0
`define AESL_MEM_H_x_1 AESL_automem_H_x_1
`define AESL_MEM_INST_H_x_1 mem_inst_H_x_1
`define AESL_MEM_H_x_2 AESL_automem_H_x_2
`define AESL_MEM_INST_H_x_2 mem_inst_H_x_2
`define AESL_MEM_H_x_3 AESL_automem_H_x_3
`define AESL_MEM_INST_H_x_3 mem_inst_H_x_3
`define AESL_DEPTH_m_x 1
`define AESL_MEM_A_0 AESL_automem_A_0
`define AESL_MEM_INST_A_0 mem_inst_A_0
`define AESL_MEM_A_1 AESL_automem_A_1
`define AESL_MEM_INST_A_1 mem_inst_A_1
`define AESL_MEM_A_2 AESL_automem_A_2
`define AESL_MEM_INST_A_2 mem_inst_A_2
`define AESL_MEM_A_3 AESL_automem_A_3
`define AESL_MEM_INST_A_3 mem_inst_A_3
`define AESL_DEPTH_p_w_0 1
`define AESL_DEPTH_p_w_1 1
`define AESL_DEPTH_p_w_2 1
`define AESL_DEPTH_p_w_3 1
`define AESL_MEM_H_w_0 AESL_automem_H_w_0
`define AESL_MEM_INST_H_w_0 mem_inst_H_w_0
`define AESL_MEM_H_w_1 AESL_automem_H_w_1
`define AESL_MEM_INST_H_w_1 mem_inst_H_w_1
`define AESL_MEM_H_w_2 AESL_automem_H_w_2
`define AESL_MEM_INST_H_w_2 mem_inst_H_w_2
`define AESL_MEM_H_w_3 AESL_automem_H_w_3
`define AESL_MEM_INST_H_w_3 mem_inst_H_w_3
`define AESL_DEPTH_m_w 1
`define AESL_DEPTH_p_pred_0 1
`define AESL_DEPTH_p_pred_1 1
`define AESL_DEPTH_p_pred_2 1
`define AESL_DEPTH_p_pred_3 1
`define AESL_MEM_H_pred_0 AESL_automem_H_pred_0
`define AESL_MEM_INST_H_pred_0 mem_inst_H_pred_0
`define AESL_MEM_H_pred_1 AESL_automem_H_pred_1
`define AESL_MEM_INST_H_pred_1 mem_inst_H_pred_1
`define AESL_MEM_H_pred_2 AESL_automem_H_pred_2
`define AESL_MEM_INST_H_pred_2 mem_inst_H_pred_2
`define AESL_MEM_H_pred_3 AESL_automem_H_pred_3
`define AESL_MEM_INST_H_pred_3 mem_inst_H_pred_3
`define AESL_DEPTH_m_pred 1
`define AUTOTB_TVIN_p_x_0  "../tv/cdatafile/c.predict_kernel.autotvin_p_x_0.dat"
`define AUTOTB_TVIN_p_x_1  "../tv/cdatafile/c.predict_kernel.autotvin_p_x_1.dat"
`define AUTOTB_TVIN_p_x_2  "../tv/cdatafile/c.predict_kernel.autotvin_p_x_2.dat"
`define AUTOTB_TVIN_p_x_3  "../tv/cdatafile/c.predict_kernel.autotvin_p_x_3.dat"
`define AUTOTB_TVIN_H_x_0  "../tv/cdatafile/c.predict_kernel.autotvin_H_x_0.dat"
`define AUTOTB_TVIN_H_x_1  "../tv/cdatafile/c.predict_kernel.autotvin_H_x_1.dat"
`define AUTOTB_TVIN_H_x_2  "../tv/cdatafile/c.predict_kernel.autotvin_H_x_2.dat"
`define AUTOTB_TVIN_H_x_3  "../tv/cdatafile/c.predict_kernel.autotvin_H_x_3.dat"
`define AUTOTB_TVIN_m_x  "../tv/cdatafile/c.predict_kernel.autotvin_m_x.dat"
`define AUTOTB_TVIN_A_0  "../tv/cdatafile/c.predict_kernel.autotvin_A_0.dat"
`define AUTOTB_TVIN_A_1  "../tv/cdatafile/c.predict_kernel.autotvin_A_1.dat"
`define AUTOTB_TVIN_A_2  "../tv/cdatafile/c.predict_kernel.autotvin_A_2.dat"
`define AUTOTB_TVIN_A_3  "../tv/cdatafile/c.predict_kernel.autotvin_A_3.dat"
`define AUTOTB_TVIN_p_w_0  "../tv/cdatafile/c.predict_kernel.autotvin_p_w_0.dat"
`define AUTOTB_TVIN_p_w_1  "../tv/cdatafile/c.predict_kernel.autotvin_p_w_1.dat"
`define AUTOTB_TVIN_p_w_2  "../tv/cdatafile/c.predict_kernel.autotvin_p_w_2.dat"
`define AUTOTB_TVIN_p_w_3  "../tv/cdatafile/c.predict_kernel.autotvin_p_w_3.dat"
`define AUTOTB_TVIN_H_w_0  "../tv/cdatafile/c.predict_kernel.autotvin_H_w_0.dat"
`define AUTOTB_TVIN_H_w_1  "../tv/cdatafile/c.predict_kernel.autotvin_H_w_1.dat"
`define AUTOTB_TVIN_H_w_2  "../tv/cdatafile/c.predict_kernel.autotvin_H_w_2.dat"
`define AUTOTB_TVIN_H_w_3  "../tv/cdatafile/c.predict_kernel.autotvin_H_w_3.dat"
`define AUTOTB_TVIN_m_w  "../tv/cdatafile/c.predict_kernel.autotvin_m_w.dat"
`define AUTOTB_TVIN_H_pred_0  "../tv/cdatafile/c.predict_kernel.autotvin_H_pred_0.dat"
`define AUTOTB_TVIN_H_pred_1  "../tv/cdatafile/c.predict_kernel.autotvin_H_pred_1.dat"
`define AUTOTB_TVIN_H_pred_2  "../tv/cdatafile/c.predict_kernel.autotvin_H_pred_2.dat"
`define AUTOTB_TVIN_H_pred_3  "../tv/cdatafile/c.predict_kernel.autotvin_H_pred_3.dat"
`define AUTOTB_TVIN_p_x_0_out_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvin_p_x_0.dat"
`define AUTOTB_TVIN_p_x_1_out_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvin_p_x_1.dat"
`define AUTOTB_TVIN_p_x_2_out_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvin_p_x_2.dat"
`define AUTOTB_TVIN_p_x_3_out_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvin_p_x_3.dat"
`define AUTOTB_TVIN_H_x_0_out_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvin_H_x_0.dat"
`define AUTOTB_TVIN_H_x_1_out_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvin_H_x_1.dat"
`define AUTOTB_TVIN_H_x_2_out_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvin_H_x_2.dat"
`define AUTOTB_TVIN_H_x_3_out_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvin_H_x_3.dat"
`define AUTOTB_TVIN_m_x_out_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvin_m_x.dat"
`define AUTOTB_TVIN_A_0_out_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvin_A_0.dat"
`define AUTOTB_TVIN_A_1_out_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvin_A_1.dat"
`define AUTOTB_TVIN_A_2_out_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvin_A_2.dat"
`define AUTOTB_TVIN_A_3_out_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvin_A_3.dat"
`define AUTOTB_TVIN_p_w_0_out_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvin_p_w_0.dat"
`define AUTOTB_TVIN_p_w_1_out_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvin_p_w_1.dat"
`define AUTOTB_TVIN_p_w_2_out_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvin_p_w_2.dat"
`define AUTOTB_TVIN_p_w_3_out_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvin_p_w_3.dat"
`define AUTOTB_TVIN_H_w_0_out_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvin_H_w_0.dat"
`define AUTOTB_TVIN_H_w_1_out_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvin_H_w_1.dat"
`define AUTOTB_TVIN_H_w_2_out_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvin_H_w_2.dat"
`define AUTOTB_TVIN_H_w_3_out_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvin_H_w_3.dat"
`define AUTOTB_TVIN_m_w_out_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvin_m_w.dat"
`define AUTOTB_TVIN_H_pred_0_out_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvin_H_pred_0.dat"
`define AUTOTB_TVIN_H_pred_1_out_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvin_H_pred_1.dat"
`define AUTOTB_TVIN_H_pred_2_out_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvin_H_pred_2.dat"
`define AUTOTB_TVIN_H_pred_3_out_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvin_H_pred_3.dat"
`define AUTOTB_TVOUT_p_pred_0  "../tv/cdatafile/c.predict_kernel.autotvout_p_pred_0.dat"
`define AUTOTB_TVOUT_p_pred_1  "../tv/cdatafile/c.predict_kernel.autotvout_p_pred_1.dat"
`define AUTOTB_TVOUT_p_pred_2  "../tv/cdatafile/c.predict_kernel.autotvout_p_pred_2.dat"
`define AUTOTB_TVOUT_p_pred_3  "../tv/cdatafile/c.predict_kernel.autotvout_p_pred_3.dat"
`define AUTOTB_TVOUT_H_pred_0  "../tv/cdatafile/c.predict_kernel.autotvout_H_pred_0.dat"
`define AUTOTB_TVOUT_H_pred_1  "../tv/cdatafile/c.predict_kernel.autotvout_H_pred_1.dat"
`define AUTOTB_TVOUT_H_pred_2  "../tv/cdatafile/c.predict_kernel.autotvout_H_pred_2.dat"
`define AUTOTB_TVOUT_H_pred_3  "../tv/cdatafile/c.predict_kernel.autotvout_H_pred_3.dat"
`define AUTOTB_TVOUT_m_pred  "../tv/cdatafile/c.predict_kernel.autotvout_m_pred.dat"
`define AUTOTB_TVOUT_p_pred_0_out_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvout_p_pred_0.dat"
`define AUTOTB_TVOUT_p_pred_1_out_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvout_p_pred_1.dat"
`define AUTOTB_TVOUT_p_pred_2_out_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvout_p_pred_2.dat"
`define AUTOTB_TVOUT_p_pred_3_out_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvout_p_pred_3.dat"
`define AUTOTB_TVOUT_H_pred_0_out_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvout_H_pred_0.dat"
`define AUTOTB_TVOUT_H_pred_1_out_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvout_H_pred_1.dat"
`define AUTOTB_TVOUT_H_pred_2_out_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvout_H_pred_2.dat"
`define AUTOTB_TVOUT_H_pred_3_out_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvout_H_pred_3.dat"
`define AUTOTB_TVOUT_m_pred_out_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvout_m_pred.dat"
module `AUTOTB_TOP;

parameter AUTOTB_TRANSACTION_NUM = 60;
parameter PROGRESS_TIMEOUT = 10000000;
parameter LATENCY_ESTIMATION = 307;
parameter LENGTH_A_0 = 4;
parameter LENGTH_A_1 = 4;
parameter LENGTH_A_2 = 4;
parameter LENGTH_A_3 = 4;
parameter LENGTH_H_pred_0 = 32;
parameter LENGTH_H_pred_1 = 32;
parameter LENGTH_H_pred_2 = 32;
parameter LENGTH_H_pred_3 = 32;
parameter LENGTH_H_w_0 = 32;
parameter LENGTH_H_w_1 = 32;
parameter LENGTH_H_w_2 = 32;
parameter LENGTH_H_w_3 = 32;
parameter LENGTH_H_x_0 = 32;
parameter LENGTH_H_x_1 = 32;
parameter LENGTH_H_x_2 = 32;
parameter LENGTH_H_x_3 = 32;
parameter LENGTH_m_pred = 1;
parameter LENGTH_m_w = 1;
parameter LENGTH_m_x = 1;
parameter LENGTH_p_pred_0 = 1;
parameter LENGTH_p_pred_1 = 1;
parameter LENGTH_p_pred_2 = 1;
parameter LENGTH_p_pred_3 = 1;
parameter LENGTH_p_w_0 = 1;
parameter LENGTH_p_w_1 = 1;
parameter LENGTH_p_w_2 = 1;
parameter LENGTH_p_w_3 = 1;
parameter LENGTH_p_x_0 = 1;
parameter LENGTH_p_x_1 = 1;
parameter LENGTH_p_x_2 = 1;
parameter LENGTH_p_x_3 = 1;

reg AESL_clock;
reg rst;
reg dut_rst;
reg start;
reg ce;
reg tb_continue;
wire AESL_start;
wire AESL_reset;
wire AESL_ce;
wire AESL_ready;
wire AESL_idle;
wire AESL_continue;
wire AESL_done;
reg AESL_done_delay = 0;
reg AESL_done_delay2 = 0;
reg AESL_ready_delay = 0;
wire ready;
wire ready_wire;
wire ap_start;
wire ap_done;
wire ap_idle;
wire ap_ready;
wire [31 : 0] p_x_0;
wire [31 : 0] p_x_1;
wire [31 : 0] p_x_2;
wire [31 : 0] p_x_3;
wire [4 : 0] H_x_0_address0;
wire  H_x_0_ce0;
wire [31 : 0] H_x_0_q0;
wire [4 : 0] H_x_1_address0;
wire  H_x_1_ce0;
wire [31 : 0] H_x_1_q0;
wire [4 : 0] H_x_2_address0;
wire  H_x_2_ce0;
wire [31 : 0] H_x_2_q0;
wire [4 : 0] H_x_3_address0;
wire  H_x_3_ce0;
wire [31 : 0] H_x_3_q0;
wire [31 : 0] m_x;
wire [1 : 0] A_0_address0;
wire  A_0_ce0;
wire [31 : 0] A_0_q0;
wire [1 : 0] A_1_address0;
wire  A_1_ce0;
wire [31 : 0] A_1_q0;
wire [1 : 0] A_2_address0;
wire  A_2_ce0;
wire [31 : 0] A_2_q0;
wire [1 : 0] A_3_address0;
wire  A_3_ce0;
wire [31 : 0] A_3_q0;
wire [31 : 0] p_w_0;
wire [31 : 0] p_w_1;
wire [31 : 0] p_w_2;
wire [31 : 0] p_w_3;
wire [4 : 0] H_w_0_address0;
wire  H_w_0_ce0;
wire [31 : 0] H_w_0_q0;
wire [4 : 0] H_w_1_address0;
wire  H_w_1_ce0;
wire [31 : 0] H_w_1_q0;
wire [4 : 0] H_w_2_address0;
wire  H_w_2_ce0;
wire [31 : 0] H_w_2_q0;
wire [4 : 0] H_w_3_address0;
wire  H_w_3_ce0;
wire [31 : 0] H_w_3_q0;
wire [31 : 0] m_w;
wire [31 : 0] p_pred_0;
wire  p_pred_0_ap_vld;
wire [31 : 0] p_pred_1;
wire  p_pred_1_ap_vld;
wire [31 : 0] p_pred_2;
wire  p_pred_2_ap_vld;
wire [31 : 0] p_pred_3;
wire  p_pred_3_ap_vld;
wire [4 : 0] H_pred_0_address0;
wire  H_pred_0_ce0;
wire  H_pred_0_we0;
wire [31 : 0] H_pred_0_d0;
wire [4 : 0] H_pred_1_address0;
wire  H_pred_1_ce0;
wire  H_pred_1_we0;
wire [31 : 0] H_pred_1_d0;
wire [4 : 0] H_pred_2_address0;
wire  H_pred_2_ce0;
wire  H_pred_2_we0;
wire [31 : 0] H_pred_2_d0;
wire [4 : 0] H_pred_3_address0;
wire  H_pred_3_ce0;
wire  H_pred_3_we0;
wire [31 : 0] H_pred_3_d0;
wire [31 : 0] m_pred;
wire  m_pred_ap_vld;
integer done_cnt = 0;
integer AESL_ready_cnt = 0;
integer ready_cnt = 0;
reg ready_initial;
reg ready_initial_n;
reg ready_last_n;
reg ready_delay_last_n;
reg done_delay_last_n;
reg interface_done = 0;


wire all_finish;
wire ap_clk;
wire ap_rst;
wire ap_rst_n;

`AUTOTB_DUT `AUTOTB_DUT_INST(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .ap_start(ap_start),
    .ap_done(ap_done),
    .ap_idle(ap_idle),
    .ap_ready(ap_ready),
    .p_x_0(p_x_0),
    .p_x_1(p_x_1),
    .p_x_2(p_x_2),
    .p_x_3(p_x_3),
    .H_x_0_address0(H_x_0_address0),
    .H_x_0_ce0(H_x_0_ce0),
    .H_x_0_q0(H_x_0_q0),
    .H_x_1_address0(H_x_1_address0),
    .H_x_1_ce0(H_x_1_ce0),
    .H_x_1_q0(H_x_1_q0),
    .H_x_2_address0(H_x_2_address0),
    .H_x_2_ce0(H_x_2_ce0),
    .H_x_2_q0(H_x_2_q0),
    .H_x_3_address0(H_x_3_address0),
    .H_x_3_ce0(H_x_3_ce0),
    .H_x_3_q0(H_x_3_q0),
    .m_x(m_x),
    .A_0_address0(A_0_address0),
    .A_0_ce0(A_0_ce0),
    .A_0_q0(A_0_q0),
    .A_1_address0(A_1_address0),
    .A_1_ce0(A_1_ce0),
    .A_1_q0(A_1_q0),
    .A_2_address0(A_2_address0),
    .A_2_ce0(A_2_ce0),
    .A_2_q0(A_2_q0),
    .A_3_address0(A_3_address0),
    .A_3_ce0(A_3_ce0),
    .A_3_q0(A_3_q0),
    .p_w_0(p_w_0),
    .p_w_1(p_w_1),
    .p_w_2(p_w_2),
    .p_w_3(p_w_3),
    .H_w_0_address0(H_w_0_address0),
    .H_w_0_ce0(H_w_0_ce0),
    .H_w_0_q0(H_w_0_q0),
    .H_w_1_address0(H_w_1_address0),
    .H_w_1_ce0(H_w_1_ce0),
    .H_w_1_q0(H_w_1_q0),
    .H_w_2_address0(H_w_2_address0),
    .H_w_2_ce0(H_w_2_ce0),
    .H_w_2_q0(H_w_2_q0),
    .H_w_3_address0(H_w_3_address0),
    .H_w_3_ce0(H_w_3_ce0),
    .H_w_3_q0(H_w_3_q0),
    .m_w(m_w),
    .p_pred_0(p_pred_0),
    .p_pred_0_ap_vld(p_pred_0_ap_vld),
    .p_pred_1(p_pred_1),
    .p_pred_1_ap_vld(p_pred_1_ap_vld),
    .p_pred_2(p_pred_2),
    .p_pred_2_ap_vld(p_pred_2_ap_vld),
    .p_pred_3(p_pred_3),
    .p_pred_3_ap_vld(p_pred_3_ap_vld),
    .H_pred_0_address0(H_pred_0_address0),
    .H_pred_0_ce0(H_pred_0_ce0),
    .H_pred_0_we0(H_pred_0_we0),
    .H_pred_0_d0(H_pred_0_d0),
    .H_pred_1_address0(H_pred_1_address0),
    .H_pred_1_ce0(H_pred_1_ce0),
    .H_pred_1_we0(H_pred_1_we0),
    .H_pred_1_d0(H_pred_1_d0),
    .H_pred_2_address0(H_pred_2_address0),
    .H_pred_2_ce0(H_pred_2_ce0),
    .H_pred_2_we0(H_pred_2_we0),
    .H_pred_2_d0(H_pred_2_d0),
    .H_pred_3_address0(H_pred_3_address0),
    .H_pred_3_ce0(H_pred_3_ce0),
    .H_pred_3_we0(H_pred_3_we0),
    .H_pred_3_d0(H_pred_3_d0),
    .m_pred(m_pred),
    .m_pred_ap_vld(m_pred_ap_vld));
assign ap_clk = AESL_clock;
assign ap_rst = AESL_reset;
assign ap_rst_n = ~AESL_reset;
assign AESL_reset = dut_rst;
assign AESL_start = svtb_top.misc_if.tb2dut_ap_start;
assign AESL_ready = svtb_top.misc_if.dut2tb_ap_ready;
assign AESL_done  = svtb_top.misc_if.dut2tb_ap_done;
assign all_finish = svtb_top.misc_if.finished;
initial begin : initial_process
    integer proc_rand;
    rst = 1;
    # 100;
    repeat(0+3) @ (posedge AESL_clock);
    # 0.1;
    rst = 0;
end
initial begin : initial_process_for_dut_rst
    integer proc_rand;
    dut_rst = 1;
    # 100;
    repeat(3) @ (posedge AESL_clock);
    # 0.1;
    dut_rst = 0;
end
initial begin
    AESL_clock = 0;
    forever #`AUTOTB_CLOCK_PERIOD_DIV2 AESL_clock = ~AESL_clock;
end

    sv_module_top svtb_top();
//------------------------arrayH_x_0 Instantiation--------------

// The input and output of arrayH_x_0
wire    arrayH_x_0_ce0, arrayH_x_0_ce1;
wire [4 - 1 : 0]    arrayH_x_0_we0, arrayH_x_0_we1;
wire    [4 : 0]    arrayH_x_0_address0, arrayH_x_0_address1;
wire    [31 : 0]    arrayH_x_0_din0, arrayH_x_0_din1;
wire    [31 : 0]    arrayH_x_0_dout0, arrayH_x_0_dout1;
wire    arrayH_x_0_ready;
wire    arrayH_x_0_done;

`AESL_MEM_H_x_0 `AESL_MEM_INST_H_x_0(
    .clk        (AESL_clock),
    .rst        (AESL_reset),
    .ce0        (arrayH_x_0_ce0),
    .we0        (arrayH_x_0_we0),
    .address0   (arrayH_x_0_address0),
    .din0       (arrayH_x_0_din0),
    .dout0      (arrayH_x_0_dout0),
    .ce1        (arrayH_x_0_ce1),
    .we1        (arrayH_x_0_we1),
    .address1   (arrayH_x_0_address1),
    .din1       (arrayH_x_0_din1),
    .dout1      (arrayH_x_0_dout1),
    .ready      (arrayH_x_0_ready),
    .done    (arrayH_x_0_done)
);

// Assignment between dut and arrayH_x_0
assign arrayH_x_0_address0 = H_x_0_address0;
assign arrayH_x_0_ce0 = H_x_0_ce0;
assign H_x_0_q0 = arrayH_x_0_dout0;
assign arrayH_x_0_we0 = 0;
assign arrayH_x_0_din0 = 0;
assign arrayH_x_0_we1 = 0;
assign arrayH_x_0_din1 = 0;
assign arrayH_x_0_ready=    ready;
assign arrayH_x_0_done = 0;

event H_x_0_reshape_ap_done_evt;
event H_x_0_reshape_ap_ready_evt;
initial begin
     `AESL_MEM_INST_H_x_0.initialed       = svtb_top.misc_if.initialed_evt  ;
     `AESL_MEM_INST_H_x_0.finished        = svtb_top.misc_if.finished_evt   ;
     `AESL_MEM_INST_H_x_0.dut2tb_ap_ready = svtb_top.misc_if.dut2tb_ap_ready_evt;
     `AESL_MEM_INST_H_x_0.dut2tb_ap_done = svtb_top.misc_if.dut2tb_ap_ready_evt;
end
//------------------------arrayH_x_1 Instantiation--------------

// The input and output of arrayH_x_1
wire    arrayH_x_1_ce0, arrayH_x_1_ce1;
wire [4 - 1 : 0]    arrayH_x_1_we0, arrayH_x_1_we1;
wire    [4 : 0]    arrayH_x_1_address0, arrayH_x_1_address1;
wire    [31 : 0]    arrayH_x_1_din0, arrayH_x_1_din1;
wire    [31 : 0]    arrayH_x_1_dout0, arrayH_x_1_dout1;
wire    arrayH_x_1_ready;
wire    arrayH_x_1_done;

`AESL_MEM_H_x_1 `AESL_MEM_INST_H_x_1(
    .clk        (AESL_clock),
    .rst        (AESL_reset),
    .ce0        (arrayH_x_1_ce0),
    .we0        (arrayH_x_1_we0),
    .address0   (arrayH_x_1_address0),
    .din0       (arrayH_x_1_din0),
    .dout0      (arrayH_x_1_dout0),
    .ce1        (arrayH_x_1_ce1),
    .we1        (arrayH_x_1_we1),
    .address1   (arrayH_x_1_address1),
    .din1       (arrayH_x_1_din1),
    .dout1      (arrayH_x_1_dout1),
    .ready      (arrayH_x_1_ready),
    .done    (arrayH_x_1_done)
);

// Assignment between dut and arrayH_x_1
assign arrayH_x_1_address0 = H_x_1_address0;
assign arrayH_x_1_ce0 = H_x_1_ce0;
assign H_x_1_q0 = arrayH_x_1_dout0;
assign arrayH_x_1_we0 = 0;
assign arrayH_x_1_din0 = 0;
assign arrayH_x_1_we1 = 0;
assign arrayH_x_1_din1 = 0;
assign arrayH_x_1_ready=    ready;
assign arrayH_x_1_done = 0;

event H_x_1_reshape_ap_done_evt;
event H_x_1_reshape_ap_ready_evt;
initial begin
     `AESL_MEM_INST_H_x_1.initialed       = svtb_top.misc_if.initialed_evt  ;
     `AESL_MEM_INST_H_x_1.finished        = svtb_top.misc_if.finished_evt   ;
     `AESL_MEM_INST_H_x_1.dut2tb_ap_ready = svtb_top.misc_if.dut2tb_ap_ready_evt;
     `AESL_MEM_INST_H_x_1.dut2tb_ap_done = svtb_top.misc_if.dut2tb_ap_ready_evt;
end
//------------------------arrayH_x_2 Instantiation--------------

// The input and output of arrayH_x_2
wire    arrayH_x_2_ce0, arrayH_x_2_ce1;
wire [4 - 1 : 0]    arrayH_x_2_we0, arrayH_x_2_we1;
wire    [4 : 0]    arrayH_x_2_address0, arrayH_x_2_address1;
wire    [31 : 0]    arrayH_x_2_din0, arrayH_x_2_din1;
wire    [31 : 0]    arrayH_x_2_dout0, arrayH_x_2_dout1;
wire    arrayH_x_2_ready;
wire    arrayH_x_2_done;

`AESL_MEM_H_x_2 `AESL_MEM_INST_H_x_2(
    .clk        (AESL_clock),
    .rst        (AESL_reset),
    .ce0        (arrayH_x_2_ce0),
    .we0        (arrayH_x_2_we0),
    .address0   (arrayH_x_2_address0),
    .din0       (arrayH_x_2_din0),
    .dout0      (arrayH_x_2_dout0),
    .ce1        (arrayH_x_2_ce1),
    .we1        (arrayH_x_2_we1),
    .address1   (arrayH_x_2_address1),
    .din1       (arrayH_x_2_din1),
    .dout1      (arrayH_x_2_dout1),
    .ready      (arrayH_x_2_ready),
    .done    (arrayH_x_2_done)
);

// Assignment between dut and arrayH_x_2
assign arrayH_x_2_address0 = H_x_2_address0;
assign arrayH_x_2_ce0 = H_x_2_ce0;
assign H_x_2_q0 = arrayH_x_2_dout0;
assign arrayH_x_2_we0 = 0;
assign arrayH_x_2_din0 = 0;
assign arrayH_x_2_we1 = 0;
assign arrayH_x_2_din1 = 0;
assign arrayH_x_2_ready=    ready;
assign arrayH_x_2_done = 0;

event H_x_2_reshape_ap_done_evt;
event H_x_2_reshape_ap_ready_evt;
initial begin
     `AESL_MEM_INST_H_x_2.initialed       = svtb_top.misc_if.initialed_evt  ;
     `AESL_MEM_INST_H_x_2.finished        = svtb_top.misc_if.finished_evt   ;
     `AESL_MEM_INST_H_x_2.dut2tb_ap_ready = svtb_top.misc_if.dut2tb_ap_ready_evt;
     `AESL_MEM_INST_H_x_2.dut2tb_ap_done = svtb_top.misc_if.dut2tb_ap_ready_evt;
end
//------------------------arrayH_x_3 Instantiation--------------

// The input and output of arrayH_x_3
wire    arrayH_x_3_ce0, arrayH_x_3_ce1;
wire [4 - 1 : 0]    arrayH_x_3_we0, arrayH_x_3_we1;
wire    [4 : 0]    arrayH_x_3_address0, arrayH_x_3_address1;
wire    [31 : 0]    arrayH_x_3_din0, arrayH_x_3_din1;
wire    [31 : 0]    arrayH_x_3_dout0, arrayH_x_3_dout1;
wire    arrayH_x_3_ready;
wire    arrayH_x_3_done;

`AESL_MEM_H_x_3 `AESL_MEM_INST_H_x_3(
    .clk        (AESL_clock),
    .rst        (AESL_reset),
    .ce0        (arrayH_x_3_ce0),
    .we0        (arrayH_x_3_we0),
    .address0   (arrayH_x_3_address0),
    .din0       (arrayH_x_3_din0),
    .dout0      (arrayH_x_3_dout0),
    .ce1        (arrayH_x_3_ce1),
    .we1        (arrayH_x_3_we1),
    .address1   (arrayH_x_3_address1),
    .din1       (arrayH_x_3_din1),
    .dout1      (arrayH_x_3_dout1),
    .ready      (arrayH_x_3_ready),
    .done    (arrayH_x_3_done)
);

// Assignment between dut and arrayH_x_3
assign arrayH_x_3_address0 = H_x_3_address0;
assign arrayH_x_3_ce0 = H_x_3_ce0;
assign H_x_3_q0 = arrayH_x_3_dout0;
assign arrayH_x_3_we0 = 0;
assign arrayH_x_3_din0 = 0;
assign arrayH_x_3_we1 = 0;
assign arrayH_x_3_din1 = 0;
assign arrayH_x_3_ready=    ready;
assign arrayH_x_3_done = 0;

event H_x_3_reshape_ap_done_evt;
event H_x_3_reshape_ap_ready_evt;
initial begin
     `AESL_MEM_INST_H_x_3.initialed       = svtb_top.misc_if.initialed_evt  ;
     `AESL_MEM_INST_H_x_3.finished        = svtb_top.misc_if.finished_evt   ;
     `AESL_MEM_INST_H_x_3.dut2tb_ap_ready = svtb_top.misc_if.dut2tb_ap_ready_evt;
     `AESL_MEM_INST_H_x_3.dut2tb_ap_done = svtb_top.misc_if.dut2tb_ap_ready_evt;
end
//------------------------arrayA_0 Instantiation--------------

// The input and output of arrayA_0
wire    arrayA_0_ce0, arrayA_0_ce1;
wire [4 - 1 : 0]    arrayA_0_we0, arrayA_0_we1;
wire    [1 : 0]    arrayA_0_address0, arrayA_0_address1;
wire    [31 : 0]    arrayA_0_din0, arrayA_0_din1;
wire    [31 : 0]    arrayA_0_dout0, arrayA_0_dout1;
wire    arrayA_0_ready;
wire    arrayA_0_done;

`AESL_MEM_A_0 `AESL_MEM_INST_A_0(
    .clk        (AESL_clock),
    .rst        (AESL_reset),
    .ce0        (arrayA_0_ce0),
    .we0        (arrayA_0_we0),
    .address0   (arrayA_0_address0),
    .din0       (arrayA_0_din0),
    .dout0      (arrayA_0_dout0),
    .ce1        (arrayA_0_ce1),
    .we1        (arrayA_0_we1),
    .address1   (arrayA_0_address1),
    .din1       (arrayA_0_din1),
    .dout1      (arrayA_0_dout1),
    .ready      (arrayA_0_ready),
    .done    (arrayA_0_done)
);

// Assignment between dut and arrayA_0
assign arrayA_0_address0 = A_0_address0;
assign arrayA_0_ce0 = A_0_ce0;
assign A_0_q0 = arrayA_0_dout0;
assign arrayA_0_we0 = 0;
assign arrayA_0_din0 = 0;
assign arrayA_0_we1 = 0;
assign arrayA_0_din1 = 0;
assign arrayA_0_ready=    ready;
assign arrayA_0_done = 0;

event A_0_reshape_ap_done_evt;
event A_0_reshape_ap_ready_evt;
initial begin
     `AESL_MEM_INST_A_0.initialed       = svtb_top.misc_if.initialed_evt  ;
     `AESL_MEM_INST_A_0.finished        = svtb_top.misc_if.finished_evt   ;
     `AESL_MEM_INST_A_0.dut2tb_ap_ready = svtb_top.misc_if.dut2tb_ap_ready_evt;
     `AESL_MEM_INST_A_0.dut2tb_ap_done = svtb_top.misc_if.dut2tb_ap_ready_evt;
end
//------------------------arrayA_1 Instantiation--------------

// The input and output of arrayA_1
wire    arrayA_1_ce0, arrayA_1_ce1;
wire [4 - 1 : 0]    arrayA_1_we0, arrayA_1_we1;
wire    [1 : 0]    arrayA_1_address0, arrayA_1_address1;
wire    [31 : 0]    arrayA_1_din0, arrayA_1_din1;
wire    [31 : 0]    arrayA_1_dout0, arrayA_1_dout1;
wire    arrayA_1_ready;
wire    arrayA_1_done;

`AESL_MEM_A_1 `AESL_MEM_INST_A_1(
    .clk        (AESL_clock),
    .rst        (AESL_reset),
    .ce0        (arrayA_1_ce0),
    .we0        (arrayA_1_we0),
    .address0   (arrayA_1_address0),
    .din0       (arrayA_1_din0),
    .dout0      (arrayA_1_dout0),
    .ce1        (arrayA_1_ce1),
    .we1        (arrayA_1_we1),
    .address1   (arrayA_1_address1),
    .din1       (arrayA_1_din1),
    .dout1      (arrayA_1_dout1),
    .ready      (arrayA_1_ready),
    .done    (arrayA_1_done)
);

// Assignment between dut and arrayA_1
assign arrayA_1_address0 = A_1_address0;
assign arrayA_1_ce0 = A_1_ce0;
assign A_1_q0 = arrayA_1_dout0;
assign arrayA_1_we0 = 0;
assign arrayA_1_din0 = 0;
assign arrayA_1_we1 = 0;
assign arrayA_1_din1 = 0;
assign arrayA_1_ready=    ready;
assign arrayA_1_done = 0;

event A_1_reshape_ap_done_evt;
event A_1_reshape_ap_ready_evt;
initial begin
     `AESL_MEM_INST_A_1.initialed       = svtb_top.misc_if.initialed_evt  ;
     `AESL_MEM_INST_A_1.finished        = svtb_top.misc_if.finished_evt   ;
     `AESL_MEM_INST_A_1.dut2tb_ap_ready = svtb_top.misc_if.dut2tb_ap_ready_evt;
     `AESL_MEM_INST_A_1.dut2tb_ap_done = svtb_top.misc_if.dut2tb_ap_ready_evt;
end
//------------------------arrayA_2 Instantiation--------------

// The input and output of arrayA_2
wire    arrayA_2_ce0, arrayA_2_ce1;
wire [4 - 1 : 0]    arrayA_2_we0, arrayA_2_we1;
wire    [1 : 0]    arrayA_2_address0, arrayA_2_address1;
wire    [31 : 0]    arrayA_2_din0, arrayA_2_din1;
wire    [31 : 0]    arrayA_2_dout0, arrayA_2_dout1;
wire    arrayA_2_ready;
wire    arrayA_2_done;

`AESL_MEM_A_2 `AESL_MEM_INST_A_2(
    .clk        (AESL_clock),
    .rst        (AESL_reset),
    .ce0        (arrayA_2_ce0),
    .we0        (arrayA_2_we0),
    .address0   (arrayA_2_address0),
    .din0       (arrayA_2_din0),
    .dout0      (arrayA_2_dout0),
    .ce1        (arrayA_2_ce1),
    .we1        (arrayA_2_we1),
    .address1   (arrayA_2_address1),
    .din1       (arrayA_2_din1),
    .dout1      (arrayA_2_dout1),
    .ready      (arrayA_2_ready),
    .done    (arrayA_2_done)
);

// Assignment between dut and arrayA_2
assign arrayA_2_address0 = A_2_address0;
assign arrayA_2_ce0 = A_2_ce0;
assign A_2_q0 = arrayA_2_dout0;
assign arrayA_2_we0 = 0;
assign arrayA_2_din0 = 0;
assign arrayA_2_we1 = 0;
assign arrayA_2_din1 = 0;
assign arrayA_2_ready=    ready;
assign arrayA_2_done = 0;

event A_2_reshape_ap_done_evt;
event A_2_reshape_ap_ready_evt;
initial begin
     `AESL_MEM_INST_A_2.initialed       = svtb_top.misc_if.initialed_evt  ;
     `AESL_MEM_INST_A_2.finished        = svtb_top.misc_if.finished_evt   ;
     `AESL_MEM_INST_A_2.dut2tb_ap_ready = svtb_top.misc_if.dut2tb_ap_ready_evt;
     `AESL_MEM_INST_A_2.dut2tb_ap_done = svtb_top.misc_if.dut2tb_ap_ready_evt;
end
//------------------------arrayA_3 Instantiation--------------

// The input and output of arrayA_3
wire    arrayA_3_ce0, arrayA_3_ce1;
wire [4 - 1 : 0]    arrayA_3_we0, arrayA_3_we1;
wire    [1 : 0]    arrayA_3_address0, arrayA_3_address1;
wire    [31 : 0]    arrayA_3_din0, arrayA_3_din1;
wire    [31 : 0]    arrayA_3_dout0, arrayA_3_dout1;
wire    arrayA_3_ready;
wire    arrayA_3_done;

`AESL_MEM_A_3 `AESL_MEM_INST_A_3(
    .clk        (AESL_clock),
    .rst        (AESL_reset),
    .ce0        (arrayA_3_ce0),
    .we0        (arrayA_3_we0),
    .address0   (arrayA_3_address0),
    .din0       (arrayA_3_din0),
    .dout0      (arrayA_3_dout0),
    .ce1        (arrayA_3_ce1),
    .we1        (arrayA_3_we1),
    .address1   (arrayA_3_address1),
    .din1       (arrayA_3_din1),
    .dout1      (arrayA_3_dout1),
    .ready      (arrayA_3_ready),
    .done    (arrayA_3_done)
);

// Assignment between dut and arrayA_3
assign arrayA_3_address0 = A_3_address0;
assign arrayA_3_ce0 = A_3_ce0;
assign A_3_q0 = arrayA_3_dout0;
assign arrayA_3_we0 = 0;
assign arrayA_3_din0 = 0;
assign arrayA_3_we1 = 0;
assign arrayA_3_din1 = 0;
assign arrayA_3_ready=    ready;
assign arrayA_3_done = 0;

event A_3_reshape_ap_done_evt;
event A_3_reshape_ap_ready_evt;
initial begin
     `AESL_MEM_INST_A_3.initialed       = svtb_top.misc_if.initialed_evt  ;
     `AESL_MEM_INST_A_3.finished        = svtb_top.misc_if.finished_evt   ;
     `AESL_MEM_INST_A_3.dut2tb_ap_ready = svtb_top.misc_if.dut2tb_ap_ready_evt;
     `AESL_MEM_INST_A_3.dut2tb_ap_done = svtb_top.misc_if.dut2tb_ap_ready_evt;
end
//------------------------arrayH_w_0 Instantiation--------------

// The input and output of arrayH_w_0
wire    arrayH_w_0_ce0, arrayH_w_0_ce1;
wire [4 - 1 : 0]    arrayH_w_0_we0, arrayH_w_0_we1;
wire    [4 : 0]    arrayH_w_0_address0, arrayH_w_0_address1;
wire    [31 : 0]    arrayH_w_0_din0, arrayH_w_0_din1;
wire    [31 : 0]    arrayH_w_0_dout0, arrayH_w_0_dout1;
wire    arrayH_w_0_ready;
wire    arrayH_w_0_done;

`AESL_MEM_H_w_0 `AESL_MEM_INST_H_w_0(
    .clk        (AESL_clock),
    .rst        (AESL_reset),
    .ce0        (arrayH_w_0_ce0),
    .we0        (arrayH_w_0_we0),
    .address0   (arrayH_w_0_address0),
    .din0       (arrayH_w_0_din0),
    .dout0      (arrayH_w_0_dout0),
    .ce1        (arrayH_w_0_ce1),
    .we1        (arrayH_w_0_we1),
    .address1   (arrayH_w_0_address1),
    .din1       (arrayH_w_0_din1),
    .dout1      (arrayH_w_0_dout1),
    .ready      (arrayH_w_0_ready),
    .done    (arrayH_w_0_done)
);

// Assignment between dut and arrayH_w_0
assign arrayH_w_0_address0 = H_w_0_address0;
assign arrayH_w_0_ce0 = H_w_0_ce0;
assign H_w_0_q0 = arrayH_w_0_dout0;
assign arrayH_w_0_we0 = 0;
assign arrayH_w_0_din0 = 0;
assign arrayH_w_0_we1 = 0;
assign arrayH_w_0_din1 = 0;
assign arrayH_w_0_ready=    ready;
assign arrayH_w_0_done = 0;

event H_w_0_reshape_ap_done_evt;
event H_w_0_reshape_ap_ready_evt;
initial begin
     `AESL_MEM_INST_H_w_0.initialed       = svtb_top.misc_if.initialed_evt  ;
     `AESL_MEM_INST_H_w_0.finished        = svtb_top.misc_if.finished_evt   ;
     `AESL_MEM_INST_H_w_0.dut2tb_ap_ready = svtb_top.misc_if.dut2tb_ap_ready_evt;
     `AESL_MEM_INST_H_w_0.dut2tb_ap_done = svtb_top.misc_if.dut2tb_ap_ready_evt;
end
//------------------------arrayH_w_1 Instantiation--------------

// The input and output of arrayH_w_1
wire    arrayH_w_1_ce0, arrayH_w_1_ce1;
wire [4 - 1 : 0]    arrayH_w_1_we0, arrayH_w_1_we1;
wire    [4 : 0]    arrayH_w_1_address0, arrayH_w_1_address1;
wire    [31 : 0]    arrayH_w_1_din0, arrayH_w_1_din1;
wire    [31 : 0]    arrayH_w_1_dout0, arrayH_w_1_dout1;
wire    arrayH_w_1_ready;
wire    arrayH_w_1_done;

`AESL_MEM_H_w_1 `AESL_MEM_INST_H_w_1(
    .clk        (AESL_clock),
    .rst        (AESL_reset),
    .ce0        (arrayH_w_1_ce0),
    .we0        (arrayH_w_1_we0),
    .address0   (arrayH_w_1_address0),
    .din0       (arrayH_w_1_din0),
    .dout0      (arrayH_w_1_dout0),
    .ce1        (arrayH_w_1_ce1),
    .we1        (arrayH_w_1_we1),
    .address1   (arrayH_w_1_address1),
    .din1       (arrayH_w_1_din1),
    .dout1      (arrayH_w_1_dout1),
    .ready      (arrayH_w_1_ready),
    .done    (arrayH_w_1_done)
);

// Assignment between dut and arrayH_w_1
assign arrayH_w_1_address0 = H_w_1_address0;
assign arrayH_w_1_ce0 = H_w_1_ce0;
assign H_w_1_q0 = arrayH_w_1_dout0;
assign arrayH_w_1_we0 = 0;
assign arrayH_w_1_din0 = 0;
assign arrayH_w_1_we1 = 0;
assign arrayH_w_1_din1 = 0;
assign arrayH_w_1_ready=    ready;
assign arrayH_w_1_done = 0;

event H_w_1_reshape_ap_done_evt;
event H_w_1_reshape_ap_ready_evt;
initial begin
     `AESL_MEM_INST_H_w_1.initialed       = svtb_top.misc_if.initialed_evt  ;
     `AESL_MEM_INST_H_w_1.finished        = svtb_top.misc_if.finished_evt   ;
     `AESL_MEM_INST_H_w_1.dut2tb_ap_ready = svtb_top.misc_if.dut2tb_ap_ready_evt;
     `AESL_MEM_INST_H_w_1.dut2tb_ap_done = svtb_top.misc_if.dut2tb_ap_ready_evt;
end
//------------------------arrayH_w_2 Instantiation--------------

// The input and output of arrayH_w_2
wire    arrayH_w_2_ce0, arrayH_w_2_ce1;
wire [4 - 1 : 0]    arrayH_w_2_we0, arrayH_w_2_we1;
wire    [4 : 0]    arrayH_w_2_address0, arrayH_w_2_address1;
wire    [31 : 0]    arrayH_w_2_din0, arrayH_w_2_din1;
wire    [31 : 0]    arrayH_w_2_dout0, arrayH_w_2_dout1;
wire    arrayH_w_2_ready;
wire    arrayH_w_2_done;

`AESL_MEM_H_w_2 `AESL_MEM_INST_H_w_2(
    .clk        (AESL_clock),
    .rst        (AESL_reset),
    .ce0        (arrayH_w_2_ce0),
    .we0        (arrayH_w_2_we0),
    .address0   (arrayH_w_2_address0),
    .din0       (arrayH_w_2_din0),
    .dout0      (arrayH_w_2_dout0),
    .ce1        (arrayH_w_2_ce1),
    .we1        (arrayH_w_2_we1),
    .address1   (arrayH_w_2_address1),
    .din1       (arrayH_w_2_din1),
    .dout1      (arrayH_w_2_dout1),
    .ready      (arrayH_w_2_ready),
    .done    (arrayH_w_2_done)
);

// Assignment between dut and arrayH_w_2
assign arrayH_w_2_address0 = H_w_2_address0;
assign arrayH_w_2_ce0 = H_w_2_ce0;
assign H_w_2_q0 = arrayH_w_2_dout0;
assign arrayH_w_2_we0 = 0;
assign arrayH_w_2_din0 = 0;
assign arrayH_w_2_we1 = 0;
assign arrayH_w_2_din1 = 0;
assign arrayH_w_2_ready=    ready;
assign arrayH_w_2_done = 0;

event H_w_2_reshape_ap_done_evt;
event H_w_2_reshape_ap_ready_evt;
initial begin
     `AESL_MEM_INST_H_w_2.initialed       = svtb_top.misc_if.initialed_evt  ;
     `AESL_MEM_INST_H_w_2.finished        = svtb_top.misc_if.finished_evt   ;
     `AESL_MEM_INST_H_w_2.dut2tb_ap_ready = svtb_top.misc_if.dut2tb_ap_ready_evt;
     `AESL_MEM_INST_H_w_2.dut2tb_ap_done = svtb_top.misc_if.dut2tb_ap_ready_evt;
end
//------------------------arrayH_w_3 Instantiation--------------

// The input and output of arrayH_w_3
wire    arrayH_w_3_ce0, arrayH_w_3_ce1;
wire [4 - 1 : 0]    arrayH_w_3_we0, arrayH_w_3_we1;
wire    [4 : 0]    arrayH_w_3_address0, arrayH_w_3_address1;
wire    [31 : 0]    arrayH_w_3_din0, arrayH_w_3_din1;
wire    [31 : 0]    arrayH_w_3_dout0, arrayH_w_3_dout1;
wire    arrayH_w_3_ready;
wire    arrayH_w_3_done;

`AESL_MEM_H_w_3 `AESL_MEM_INST_H_w_3(
    .clk        (AESL_clock),
    .rst        (AESL_reset),
    .ce0        (arrayH_w_3_ce0),
    .we0        (arrayH_w_3_we0),
    .address0   (arrayH_w_3_address0),
    .din0       (arrayH_w_3_din0),
    .dout0      (arrayH_w_3_dout0),
    .ce1        (arrayH_w_3_ce1),
    .we1        (arrayH_w_3_we1),
    .address1   (arrayH_w_3_address1),
    .din1       (arrayH_w_3_din1),
    .dout1      (arrayH_w_3_dout1),
    .ready      (arrayH_w_3_ready),
    .done    (arrayH_w_3_done)
);

// Assignment between dut and arrayH_w_3
assign arrayH_w_3_address0 = H_w_3_address0;
assign arrayH_w_3_ce0 = H_w_3_ce0;
assign H_w_3_q0 = arrayH_w_3_dout0;
assign arrayH_w_3_we0 = 0;
assign arrayH_w_3_din0 = 0;
assign arrayH_w_3_we1 = 0;
assign arrayH_w_3_din1 = 0;
assign arrayH_w_3_ready=    ready;
assign arrayH_w_3_done = 0;

event H_w_3_reshape_ap_done_evt;
event H_w_3_reshape_ap_ready_evt;
initial begin
     `AESL_MEM_INST_H_w_3.initialed       = svtb_top.misc_if.initialed_evt  ;
     `AESL_MEM_INST_H_w_3.finished        = svtb_top.misc_if.finished_evt   ;
     `AESL_MEM_INST_H_w_3.dut2tb_ap_ready = svtb_top.misc_if.dut2tb_ap_ready_evt;
     `AESL_MEM_INST_H_w_3.dut2tb_ap_done = svtb_top.misc_if.dut2tb_ap_ready_evt;
end
//------------------------arrayH_pred_0 Instantiation--------------

// The input and output of arrayH_pred_0
wire    arrayH_pred_0_ce0, arrayH_pred_0_ce1;
wire [4 - 1 : 0]    arrayH_pred_0_we0, arrayH_pred_0_we1;
wire    [4 : 0]    arrayH_pred_0_address0, arrayH_pred_0_address1;
wire    [31 : 0]    arrayH_pred_0_din0, arrayH_pred_0_din1;
wire    [31 : 0]    arrayH_pred_0_dout0, arrayH_pred_0_dout1;
wire    arrayH_pred_0_ready;
wire    arrayH_pred_0_done;

`AESL_MEM_H_pred_0 `AESL_MEM_INST_H_pred_0(
    .clk        (AESL_clock),
    .rst        (AESL_reset),
    .ce0        (arrayH_pred_0_ce0),
    .we0        (arrayH_pred_0_we0),
    .address0   (arrayH_pred_0_address0),
    .din0       (arrayH_pred_0_din0),
    .dout0      (arrayH_pred_0_dout0),
    .ce1        (arrayH_pred_0_ce1),
    .we1        (arrayH_pred_0_we1),
    .address1   (arrayH_pred_0_address1),
    .din1       (arrayH_pred_0_din1),
    .dout1      (arrayH_pred_0_dout1),
    .ready      (arrayH_pred_0_ready),
    .done    (arrayH_pred_0_done)
);

// Assignment between dut and arrayH_pred_0
assign arrayH_pred_0_address0 = H_pred_0_address0;
assign arrayH_pred_0_ce0 = H_pred_0_ce0;
assign arrayH_pred_0_we0[0] = H_pred_0_we0;
assign arrayH_pred_0_we0[1] = H_pred_0_we0;
assign arrayH_pred_0_we0[2] = H_pred_0_we0;
assign arrayH_pred_0_we0[3] = H_pred_0_we0;
assign arrayH_pred_0_din0 = H_pred_0_d0;
assign arrayH_pred_0_we1 = 0;
assign arrayH_pred_0_din1 = 0;
assign arrayH_pred_0_ready= ready_initial | arrayH_pred_0_done;
assign arrayH_pred_0_done =    AESL_done_delay;

event H_pred_0_reshape_ap_done_evt;
event H_pred_0_reshape_ap_ready_evt;
initial begin
     `AESL_MEM_INST_H_pred_0.initialed       = svtb_top.misc_if.initialed_evt  ;
     `AESL_MEM_INST_H_pred_0.finished        = svtb_top.misc_if.finished_evt   ;
     `AESL_MEM_INST_H_pred_0.dut2tb_ap_done  = svtb_top.misc_if.dut2tb_ap_done_evt;
     `AESL_MEM_INST_H_pred_0.dut2tb_ap_ready = H_pred_0_reshape_ap_ready_evt;
end
initial begin
    forever begin
        @svtb_top.misc_if.dut2tb_ap_done_evt;
        #0;
        -> H_pred_0_reshape_ap_ready_evt;
    end
end
//------------------------arrayH_pred_1 Instantiation--------------

// The input and output of arrayH_pred_1
wire    arrayH_pred_1_ce0, arrayH_pred_1_ce1;
wire [4 - 1 : 0]    arrayH_pred_1_we0, arrayH_pred_1_we1;
wire    [4 : 0]    arrayH_pred_1_address0, arrayH_pred_1_address1;
wire    [31 : 0]    arrayH_pred_1_din0, arrayH_pred_1_din1;
wire    [31 : 0]    arrayH_pred_1_dout0, arrayH_pred_1_dout1;
wire    arrayH_pred_1_ready;
wire    arrayH_pred_1_done;

`AESL_MEM_H_pred_1 `AESL_MEM_INST_H_pred_1(
    .clk        (AESL_clock),
    .rst        (AESL_reset),
    .ce0        (arrayH_pred_1_ce0),
    .we0        (arrayH_pred_1_we0),
    .address0   (arrayH_pred_1_address0),
    .din0       (arrayH_pred_1_din0),
    .dout0      (arrayH_pred_1_dout0),
    .ce1        (arrayH_pred_1_ce1),
    .we1        (arrayH_pred_1_we1),
    .address1   (arrayH_pred_1_address1),
    .din1       (arrayH_pred_1_din1),
    .dout1      (arrayH_pred_1_dout1),
    .ready      (arrayH_pred_1_ready),
    .done    (arrayH_pred_1_done)
);

// Assignment between dut and arrayH_pred_1
assign arrayH_pred_1_address0 = H_pred_1_address0;
assign arrayH_pred_1_ce0 = H_pred_1_ce0;
assign arrayH_pred_1_we0[0] = H_pred_1_we0;
assign arrayH_pred_1_we0[1] = H_pred_1_we0;
assign arrayH_pred_1_we0[2] = H_pred_1_we0;
assign arrayH_pred_1_we0[3] = H_pred_1_we0;
assign arrayH_pred_1_din0 = H_pred_1_d0;
assign arrayH_pred_1_we1 = 0;
assign arrayH_pred_1_din1 = 0;
assign arrayH_pred_1_ready= ready_initial | arrayH_pred_1_done;
assign arrayH_pred_1_done =    AESL_done_delay;

event H_pred_1_reshape_ap_done_evt;
event H_pred_1_reshape_ap_ready_evt;
initial begin
     `AESL_MEM_INST_H_pred_1.initialed       = svtb_top.misc_if.initialed_evt  ;
     `AESL_MEM_INST_H_pred_1.finished        = svtb_top.misc_if.finished_evt   ;
     `AESL_MEM_INST_H_pred_1.dut2tb_ap_done  = svtb_top.misc_if.dut2tb_ap_done_evt;
     `AESL_MEM_INST_H_pred_1.dut2tb_ap_ready = H_pred_1_reshape_ap_ready_evt;
end
initial begin
    forever begin
        @svtb_top.misc_if.dut2tb_ap_done_evt;
        #0;
        -> H_pred_1_reshape_ap_ready_evt;
    end
end
//------------------------arrayH_pred_2 Instantiation--------------

// The input and output of arrayH_pred_2
wire    arrayH_pred_2_ce0, arrayH_pred_2_ce1;
wire [4 - 1 : 0]    arrayH_pred_2_we0, arrayH_pred_2_we1;
wire    [4 : 0]    arrayH_pred_2_address0, arrayH_pred_2_address1;
wire    [31 : 0]    arrayH_pred_2_din0, arrayH_pred_2_din1;
wire    [31 : 0]    arrayH_pred_2_dout0, arrayH_pred_2_dout1;
wire    arrayH_pred_2_ready;
wire    arrayH_pred_2_done;

`AESL_MEM_H_pred_2 `AESL_MEM_INST_H_pred_2(
    .clk        (AESL_clock),
    .rst        (AESL_reset),
    .ce0        (arrayH_pred_2_ce0),
    .we0        (arrayH_pred_2_we0),
    .address0   (arrayH_pred_2_address0),
    .din0       (arrayH_pred_2_din0),
    .dout0      (arrayH_pred_2_dout0),
    .ce1        (arrayH_pred_2_ce1),
    .we1        (arrayH_pred_2_we1),
    .address1   (arrayH_pred_2_address1),
    .din1       (arrayH_pred_2_din1),
    .dout1      (arrayH_pred_2_dout1),
    .ready      (arrayH_pred_2_ready),
    .done    (arrayH_pred_2_done)
);

// Assignment between dut and arrayH_pred_2
assign arrayH_pred_2_address0 = H_pred_2_address0;
assign arrayH_pred_2_ce0 = H_pred_2_ce0;
assign arrayH_pred_2_we0[0] = H_pred_2_we0;
assign arrayH_pred_2_we0[1] = H_pred_2_we0;
assign arrayH_pred_2_we0[2] = H_pred_2_we0;
assign arrayH_pred_2_we0[3] = H_pred_2_we0;
assign arrayH_pred_2_din0 = H_pred_2_d0;
assign arrayH_pred_2_we1 = 0;
assign arrayH_pred_2_din1 = 0;
assign arrayH_pred_2_ready= ready_initial | arrayH_pred_2_done;
assign arrayH_pred_2_done =    AESL_done_delay;

event H_pred_2_reshape_ap_done_evt;
event H_pred_2_reshape_ap_ready_evt;
initial begin
     `AESL_MEM_INST_H_pred_2.initialed       = svtb_top.misc_if.initialed_evt  ;
     `AESL_MEM_INST_H_pred_2.finished        = svtb_top.misc_if.finished_evt   ;
     `AESL_MEM_INST_H_pred_2.dut2tb_ap_done  = svtb_top.misc_if.dut2tb_ap_done_evt;
     `AESL_MEM_INST_H_pred_2.dut2tb_ap_ready = H_pred_2_reshape_ap_ready_evt;
end
initial begin
    forever begin
        @svtb_top.misc_if.dut2tb_ap_done_evt;
        #0;
        -> H_pred_2_reshape_ap_ready_evt;
    end
end
//------------------------arrayH_pred_3 Instantiation--------------

// The input and output of arrayH_pred_3
wire    arrayH_pred_3_ce0, arrayH_pred_3_ce1;
wire [4 - 1 : 0]    arrayH_pred_3_we0, arrayH_pred_3_we1;
wire    [4 : 0]    arrayH_pred_3_address0, arrayH_pred_3_address1;
wire    [31 : 0]    arrayH_pred_3_din0, arrayH_pred_3_din1;
wire    [31 : 0]    arrayH_pred_3_dout0, arrayH_pred_3_dout1;
wire    arrayH_pred_3_ready;
wire    arrayH_pred_3_done;

`AESL_MEM_H_pred_3 `AESL_MEM_INST_H_pred_3(
    .clk        (AESL_clock),
    .rst        (AESL_reset),
    .ce0        (arrayH_pred_3_ce0),
    .we0        (arrayH_pred_3_we0),
    .address0   (arrayH_pred_3_address0),
    .din0       (arrayH_pred_3_din0),
    .dout0      (arrayH_pred_3_dout0),
    .ce1        (arrayH_pred_3_ce1),
    .we1        (arrayH_pred_3_we1),
    .address1   (arrayH_pred_3_address1),
    .din1       (arrayH_pred_3_din1),
    .dout1      (arrayH_pred_3_dout1),
    .ready      (arrayH_pred_3_ready),
    .done    (arrayH_pred_3_done)
);

// Assignment between dut and arrayH_pred_3
assign arrayH_pred_3_address0 = H_pred_3_address0;
assign arrayH_pred_3_ce0 = H_pred_3_ce0;
assign arrayH_pred_3_we0[0] = H_pred_3_we0;
assign arrayH_pred_3_we0[1] = H_pred_3_we0;
assign arrayH_pred_3_we0[2] = H_pred_3_we0;
assign arrayH_pred_3_we0[3] = H_pred_3_we0;
assign arrayH_pred_3_din0 = H_pred_3_d0;
assign arrayH_pred_3_we1 = 0;
assign arrayH_pred_3_din1 = 0;
assign arrayH_pred_3_ready= ready_initial | arrayH_pred_3_done;
assign arrayH_pred_3_done =    AESL_done_delay;

event H_pred_3_reshape_ap_done_evt;
event H_pred_3_reshape_ap_ready_evt;
initial begin
     `AESL_MEM_INST_H_pred_3.initialed       = svtb_top.misc_if.initialed_evt  ;
     `AESL_MEM_INST_H_pred_3.finished        = svtb_top.misc_if.finished_evt   ;
     `AESL_MEM_INST_H_pred_3.dut2tb_ap_done  = svtb_top.misc_if.dut2tb_ap_done_evt;
     `AESL_MEM_INST_H_pred_3.dut2tb_ap_ready = H_pred_3_reshape_ap_ready_evt;
end
initial begin
    forever begin
        @svtb_top.misc_if.dut2tb_ap_done_evt;
        #0;
        -> H_pred_3_reshape_ap_ready_evt;
    end
end

////////////////////////////////////////////
// progress and performance
////////////////////////////////////////////

task wait_start();
    while (~AESL_start) begin
        @ (posedge AESL_clock);
    end
endtask

reg [31:0] clk_cnt = 0;
reg AESL_ready_p1;
reg AESL_start_p1;

always @ (posedge AESL_clock) begin
    if (AESL_reset == 1) begin
        clk_cnt <= 32'h0;
        AESL_ready_p1 <= 1'b0;
        AESL_start_p1 <= 1'b0;
    end
    else begin
        clk_cnt <= clk_cnt + 1;
        AESL_ready_p1 <= AESL_ready;
        AESL_start_p1 <= AESL_start;
    end
end

reg [31:0] start_timestamp [0:AUTOTB_TRANSACTION_NUM - 1];
reg [31:0] start_cnt;
reg [31:0] ready_timestamp [0:AUTOTB_TRANSACTION_NUM - 1];
reg [31:0] ap_ready_cnt;
reg [31:0] finish_timestamp [0:AUTOTB_TRANSACTION_NUM - 1];
reg [31:0] finish_cnt;
reg [31:0] lat_total;
event report_progress;

always @(posedge AESL_clock)
begin
    if (finish_cnt == AUTOTB_TRANSACTION_NUM - 1 && AESL_done == 1'b1)
        lat_total = clk_cnt - start_timestamp[0];
end

initial begin
    start_cnt = 0;
    finish_cnt = 0;
    ap_ready_cnt = 0;
    wait (AESL_reset == 0);
    wait_start();
    start_timestamp[start_cnt] = clk_cnt;
    start_cnt = start_cnt + 1;
    if (AESL_done) begin
        finish_timestamp[finish_cnt] = clk_cnt;
        finish_cnt = finish_cnt + 1;
    end
    -> report_progress;
    forever begin
        @ (posedge AESL_clock);
        if (start_cnt < AUTOTB_TRANSACTION_NUM) begin
            if ((AESL_start && AESL_ready_p1)||(AESL_start && ~AESL_start_p1)) begin
                start_timestamp[start_cnt] = clk_cnt;
                start_cnt = start_cnt + 1;
            end
        end
        if (ap_ready_cnt < AUTOTB_TRANSACTION_NUM) begin
            if (AESL_start_p1 && AESL_ready_p1) begin
                ready_timestamp[ap_ready_cnt] = clk_cnt;
                ap_ready_cnt = ap_ready_cnt + 1;
            end
        end
        if (finish_cnt < AUTOTB_TRANSACTION_NUM) begin
            if (AESL_done) begin
                finish_timestamp[finish_cnt] = clk_cnt;
                finish_cnt = finish_cnt + 1;
            end
        end
        -> report_progress;
    end
end

reg [31:0] progress_timeout;

initial begin : simulation_progress
    real intra_progress;
    wait (AESL_reset == 0);
    progress_timeout = PROGRESS_TIMEOUT;
    $display("////////////////////////////////////////////////////////////////////////////////////");
    $display("// Inter-Transaction Progress: Completed Transaction / Total Transaction");
    $display("// Intra-Transaction Progress: Measured Latency / Latency Estimation * 100%%");
    $display("//");
    $display("// RTL Simulation : \"Inter-Transaction Progress\" [\"Intra-Transaction Progress\"] @ \"Simulation Time\"");
    $display("////////////////////////////////////////////////////////////////////////////////////");
    print_progress();
    while (finish_cnt < AUTOTB_TRANSACTION_NUM) begin
        @ (report_progress);
        if (finish_cnt < AUTOTB_TRANSACTION_NUM) begin
            if (AESL_done) begin
                print_progress();
                progress_timeout = PROGRESS_TIMEOUT;
            end else begin
                if (progress_timeout == 0) begin
                    print_progress();
                    progress_timeout = PROGRESS_TIMEOUT;
                end else begin
                    progress_timeout = progress_timeout - 1;
                end
            end
        end
    end
    print_progress();
    $display("////////////////////////////////////////////////////////////////////////////////////");
    calculate_performance();
end

task get_intra_progress(output real intra_progress);
    begin
        if (start_cnt > finish_cnt) begin
            intra_progress = clk_cnt - start_timestamp[finish_cnt];
        end else if(finish_cnt > 0) begin
            intra_progress = LATENCY_ESTIMATION;
        end else begin
            intra_progress = 0;
        end
        intra_progress = intra_progress / LATENCY_ESTIMATION;
    end
endtask

task print_progress();
    real intra_progress;
    begin
        if (LATENCY_ESTIMATION > 0) begin
            get_intra_progress(intra_progress);
            $display("// RTL Simulation : %0d / %0d [%2.2f%%] @ \"%0t\"", finish_cnt, AUTOTB_TRANSACTION_NUM, intra_progress * 100, $time);
        end else begin
            $display("// RTL Simulation : %0d / %0d [n/a] @ \"%0t\"", finish_cnt, AUTOTB_TRANSACTION_NUM, $time);
        end
    end
endtask

task calculate_performance();
    integer i;
    integer fp;
    reg [31:0] latency [0:AUTOTB_TRANSACTION_NUM - 1];
    reg [31:0] latency_min;
    reg [31:0] latency_max;
    reg [31:0] latency_total;
    reg [31:0] latency_average;
    reg [31:0] interval [0:AUTOTB_TRANSACTION_NUM - 2];
    reg [31:0] interval_min;
    reg [31:0] interval_max;
    reg [31:0] interval_total;
    reg [31:0] interval_average;
    reg [31:0] total_execute_time;
    begin
        latency_min = -1;
        latency_max = 0;
        latency_total = 0;
        interval_min = -1;
        interval_max = 0;
        interval_total = 0;
        total_execute_time = lat_total;

        for (i = 0; i < AUTOTB_TRANSACTION_NUM; i = i + 1) begin
            // calculate latency
            latency[i] = finish_timestamp[i] - start_timestamp[i];
            if (latency[i] > latency_max) latency_max = latency[i];
            if (latency[i] < latency_min) latency_min = latency[i];
            latency_total = latency_total + latency[i];
            // calculate interval
            if (AUTOTB_TRANSACTION_NUM == 1) begin
                interval[i] = 0;
                interval_max = 0;
                interval_min = 0;
                interval_total = 0;
            end else if (i < AUTOTB_TRANSACTION_NUM - 1) begin
                interval[i] = start_timestamp[i + 1] - start_timestamp[i];
                if (interval[i] > interval_max) interval_max = interval[i];
                if (interval[i] < interval_min) interval_min = interval[i];
                interval_total = interval_total + interval[i];
            end
        end

        latency_average = latency_total / AUTOTB_TRANSACTION_NUM;
        if (AUTOTB_TRANSACTION_NUM == 1) begin
            interval_average = 0;
        end else begin
            interval_average = interval_total / (AUTOTB_TRANSACTION_NUM - 1);
        end

        fp = $fopen(`AUTOTB_LAT_RESULT_FILE, "w");

        $fdisplay(fp, "$MAX_LATENCY = \"%0d\"", latency_max);
        $fdisplay(fp, "$MIN_LATENCY = \"%0d\"", latency_min);
        $fdisplay(fp, "$AVER_LATENCY = \"%0d\"", latency_average);
        $fdisplay(fp, "$MAX_THROUGHPUT = \"%0d\"", interval_max);
        $fdisplay(fp, "$MIN_THROUGHPUT = \"%0d\"", interval_min);
        $fdisplay(fp, "$AVER_THROUGHPUT = \"%0d\"", interval_average);
        $fdisplay(fp, "$TOTAL_EXECUTE_TIME = \"%0d\"", total_execute_time);

        $fclose(fp);

        fp = $fopen(`AUTOTB_PER_RESULT_TRANS_FILE, "w");

        $fdisplay(fp, "%20s%16s%16s", "", "latency", "interval");
        if (AUTOTB_TRANSACTION_NUM == 1) begin
            i = 0;
            $fdisplay(fp, "transaction%8d:%16d%16d", i, latency[i], interval[i]);
        end else begin
            for (i = 0; i < AUTOTB_TRANSACTION_NUM; i = i + 1) begin
                if (i < AUTOTB_TRANSACTION_NUM - 1) begin
                    $fdisplay(fp, "transaction%8d:%16d%16d", i, latency[i], interval[i]);
                end else begin
                    $fdisplay(fp, "transaction%8d:%16d               x", i, latency[i]);
                end
            end
        end

        $fclose(fp);
    end
endtask


////////////////////////////////////////////
// Dependence Check
////////////////////////////////////////////

`ifndef POST_SYN

`endif
///////////////////////////////////////////////////////
// dataflow status monitor
///////////////////////////////////////////////////////
dataflow_monitor U_dataflow_monitor(
    .clock(AESL_clock),
    .reset(rst),
    .finish(all_finish));

`include "fifo_para.vh"
endmodule
