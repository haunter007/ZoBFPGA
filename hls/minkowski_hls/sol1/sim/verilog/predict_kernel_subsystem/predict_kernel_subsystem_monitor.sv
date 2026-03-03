//==============================================================
//Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
//Tool Version Limit: 2025.11
//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//
//==============================================================

`ifndef PREDICT_KERNEL_SUBSYSTEM_MONITOR_SV
`define PREDICT_KERNEL_SUBSYSTEM_MONITOR_SV

`uvm_analysis_imp_decl(_svr_master_p_x_0)
`uvm_analysis_imp_decl(_svr_master_p_x_1)
`uvm_analysis_imp_decl(_svr_master_p_x_2)
`uvm_analysis_imp_decl(_svr_master_p_x_3)
`uvm_analysis_imp_decl(_svr_master_m_x)
`uvm_analysis_imp_decl(_svr_master_p_w_0)
`uvm_analysis_imp_decl(_svr_master_p_w_1)
`uvm_analysis_imp_decl(_svr_master_p_w_2)
`uvm_analysis_imp_decl(_svr_master_p_w_3)
`uvm_analysis_imp_decl(_svr_master_m_w)
`uvm_analysis_imp_decl(_svr_slave_p_pred_0)
`uvm_analysis_imp_decl(_svr_slave_p_pred_1)
`uvm_analysis_imp_decl(_svr_slave_p_pred_2)
`uvm_analysis_imp_decl(_svr_slave_p_pred_3)
`uvm_analysis_imp_decl(_svr_slave_m_pred)

class predict_kernel_subsystem_monitor extends uvm_component;

    predict_kernel_reference_model refm;
    predict_kernel_scoreboard scbd;

    `uvm_component_utils_begin(predict_kernel_subsystem_monitor)
    `uvm_component_utils_end

    uvm_analysis_imp_svr_master_p_x_0#(svr_pkg::svr_transfer#(32), predict_kernel_subsystem_monitor) svr_master_p_x_0_imp;
    uvm_analysis_imp_svr_master_p_x_1#(svr_pkg::svr_transfer#(32), predict_kernel_subsystem_monitor) svr_master_p_x_1_imp;
    uvm_analysis_imp_svr_master_p_x_2#(svr_pkg::svr_transfer#(32), predict_kernel_subsystem_monitor) svr_master_p_x_2_imp;
    uvm_analysis_imp_svr_master_p_x_3#(svr_pkg::svr_transfer#(32), predict_kernel_subsystem_monitor) svr_master_p_x_3_imp;
    uvm_analysis_imp_svr_master_m_x#(svr_pkg::svr_transfer#(32), predict_kernel_subsystem_monitor) svr_master_m_x_imp;
    uvm_analysis_imp_svr_master_p_w_0#(svr_pkg::svr_transfer#(32), predict_kernel_subsystem_monitor) svr_master_p_w_0_imp;
    uvm_analysis_imp_svr_master_p_w_1#(svr_pkg::svr_transfer#(32), predict_kernel_subsystem_monitor) svr_master_p_w_1_imp;
    uvm_analysis_imp_svr_master_p_w_2#(svr_pkg::svr_transfer#(32), predict_kernel_subsystem_monitor) svr_master_p_w_2_imp;
    uvm_analysis_imp_svr_master_p_w_3#(svr_pkg::svr_transfer#(32), predict_kernel_subsystem_monitor) svr_master_p_w_3_imp;
    uvm_analysis_imp_svr_master_m_w#(svr_pkg::svr_transfer#(32), predict_kernel_subsystem_monitor) svr_master_m_w_imp;
    uvm_analysis_imp_svr_slave_p_pred_0#(svr_pkg::svr_transfer#(32), predict_kernel_subsystem_monitor) svr_slave_p_pred_0_imp;
    uvm_analysis_imp_svr_slave_p_pred_1#(svr_pkg::svr_transfer#(32), predict_kernel_subsystem_monitor) svr_slave_p_pred_1_imp;
    uvm_analysis_imp_svr_slave_p_pred_2#(svr_pkg::svr_transfer#(32), predict_kernel_subsystem_monitor) svr_slave_p_pred_2_imp;
    uvm_analysis_imp_svr_slave_p_pred_3#(svr_pkg::svr_transfer#(32), predict_kernel_subsystem_monitor) svr_slave_p_pred_3_imp;
    uvm_analysis_imp_svr_slave_m_pred#(svr_pkg::svr_transfer#(32), predict_kernel_subsystem_monitor) svr_slave_m_pred_imp;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(predict_kernel_reference_model)::get(this, "", "refm", refm))
            `uvm_fatal(this.get_full_name(), "No refm from high level")
        `uvm_info(this.get_full_name(), "get reference model by uvm_config_db", UVM_MEDIUM)
        scbd = predict_kernel_scoreboard::type_id::create("scbd", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    function new (string name = "", uvm_component parent = null);
        super.new(name, parent);
        svr_master_p_x_0_imp = new("svr_master_p_x_0_imp", this);
        svr_master_p_x_1_imp = new("svr_master_p_x_1_imp", this);
        svr_master_p_x_2_imp = new("svr_master_p_x_2_imp", this);
        svr_master_p_x_3_imp = new("svr_master_p_x_3_imp", this);
        svr_master_m_x_imp = new("svr_master_m_x_imp", this);
        svr_master_p_w_0_imp = new("svr_master_p_w_0_imp", this);
        svr_master_p_w_1_imp = new("svr_master_p_w_1_imp", this);
        svr_master_p_w_2_imp = new("svr_master_p_w_2_imp", this);
        svr_master_p_w_3_imp = new("svr_master_p_w_3_imp", this);
        svr_master_m_w_imp = new("svr_master_m_w_imp", this);
        svr_slave_p_pred_0_imp = new("svr_slave_p_pred_0_imp", this);
        svr_slave_p_pred_1_imp = new("svr_slave_p_pred_1_imp", this);
        svr_slave_p_pred_2_imp = new("svr_slave_p_pred_2_imp", this);
        svr_slave_p_pred_3_imp = new("svr_slave_p_pred_3_imp", this);
        svr_slave_m_pred_imp = new("svr_slave_m_pred_imp", this);
    endfunction

    virtual function void write_svr_master_p_x_0(svr_transfer#(32) tr);
        refm.write_svr_master_p_x_0(tr);
        scbd.write_svr_master_p_x_0(tr);
    endfunction

    virtual function void write_svr_master_p_x_1(svr_transfer#(32) tr);
        refm.write_svr_master_p_x_1(tr);
        scbd.write_svr_master_p_x_1(tr);
    endfunction

    virtual function void write_svr_master_p_x_2(svr_transfer#(32) tr);
        refm.write_svr_master_p_x_2(tr);
        scbd.write_svr_master_p_x_2(tr);
    endfunction

    virtual function void write_svr_master_p_x_3(svr_transfer#(32) tr);
        refm.write_svr_master_p_x_3(tr);
        scbd.write_svr_master_p_x_3(tr);
    endfunction

    virtual function void write_svr_master_m_x(svr_transfer#(32) tr);
        refm.write_svr_master_m_x(tr);
        scbd.write_svr_master_m_x(tr);
    endfunction

    virtual function void write_svr_master_p_w_0(svr_transfer#(32) tr);
        refm.write_svr_master_p_w_0(tr);
        scbd.write_svr_master_p_w_0(tr);
    endfunction

    virtual function void write_svr_master_p_w_1(svr_transfer#(32) tr);
        refm.write_svr_master_p_w_1(tr);
        scbd.write_svr_master_p_w_1(tr);
    endfunction

    virtual function void write_svr_master_p_w_2(svr_transfer#(32) tr);
        refm.write_svr_master_p_w_2(tr);
        scbd.write_svr_master_p_w_2(tr);
    endfunction

    virtual function void write_svr_master_p_w_3(svr_transfer#(32) tr);
        refm.write_svr_master_p_w_3(tr);
        scbd.write_svr_master_p_w_3(tr);
    endfunction

    virtual function void write_svr_master_m_w(svr_transfer#(32) tr);
        refm.write_svr_master_m_w(tr);
        scbd.write_svr_master_m_w(tr);
    endfunction

    virtual function void write_svr_slave_p_pred_0(svr_transfer#(32) tr);
        refm.write_svr_slave_p_pred_0(tr);
        scbd.write_svr_slave_p_pred_0(tr);
    endfunction

    virtual function void write_svr_slave_p_pred_1(svr_transfer#(32) tr);
        refm.write_svr_slave_p_pred_1(tr);
        scbd.write_svr_slave_p_pred_1(tr);
    endfunction

    virtual function void write_svr_slave_p_pred_2(svr_transfer#(32) tr);
        refm.write_svr_slave_p_pred_2(tr);
        scbd.write_svr_slave_p_pred_2(tr);
    endfunction

    virtual function void write_svr_slave_p_pred_3(svr_transfer#(32) tr);
        refm.write_svr_slave_p_pred_3(tr);
        scbd.write_svr_slave_p_pred_3(tr);
    endfunction

    virtual function void write_svr_slave_m_pred(svr_transfer#(32) tr);
        refm.write_svr_slave_m_pred(tr);
        scbd.write_svr_slave_m_pred(tr);
    endfunction
endclass
`endif
