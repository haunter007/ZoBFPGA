//==============================================================
//Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
//Tool Version Limit: 2025.11
//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//
//==============================================================
`ifndef PREDICT_KERNEL_VIRTUAL_SEQUENCER__SV                        
    `define PREDICT_KERNEL_VIRTUAL_SEQUENCER__SV                    
                                                                       
    class predict_kernel_virtual_sequencer extends uvm_sequencer;         
        svr_master_sequencer#(32) svr_port_p_x_0_sqr;
        svr_master_sequencer#(32) svr_port_p_x_1_sqr;
        svr_master_sequencer#(32) svr_port_p_x_2_sqr;
        svr_master_sequencer#(32) svr_port_p_x_3_sqr;
        svr_master_sequencer#(32) svr_port_m_x_sqr;
        svr_master_sequencer#(32) svr_port_p_w_0_sqr;
        svr_master_sequencer#(32) svr_port_p_w_1_sqr;
        svr_master_sequencer#(32) svr_port_p_w_2_sqr;
        svr_master_sequencer#(32) svr_port_p_w_3_sqr;
        svr_master_sequencer#(32) svr_port_m_w_sqr;
        svr_slave_sequencer#(32) svr_port_p_pred_0_sqr;
        svr_slave_sequencer#(32) svr_port_p_pred_1_sqr;
        svr_slave_sequencer#(32) svr_port_p_pred_2_sqr;
        svr_slave_sequencer#(32) svr_port_p_pred_3_sqr;
        svr_slave_sequencer#(32) svr_port_m_pred_sqr;
 
        function new (string name, uvm_component parent);              
            super.new(name, parent);                                   
            //`uvm_info(this.get_full_name(), "new is called", UVM_LOW)
        endfunction                                                    
                                                                       
        `uvm_component_utils_begin(predict_kernel_virtual_sequencer)      
        `uvm_component_utils_end                                       
                                                                       
    endclass

`endif
