//==============================================================
//Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
//Tool Version Limit: 2025.11
//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//
//==============================================================
`ifndef PREDICT_KERNEL_CONFIG__SV                        
    `define PREDICT_KERNEL_CONFIG__SV                    
                                                            
    class predict_kernel_config extends uvm_object;            
                                                            
        int check_ena;                                      
        int cover_ena;                                      
        svr_pkg::svr_config port_p_x_0_cfg;
        svr_pkg::svr_config port_p_x_1_cfg;
        svr_pkg::svr_config port_p_x_2_cfg;
        svr_pkg::svr_config port_p_x_3_cfg;
        svr_pkg::svr_config port_m_x_cfg;
        svr_pkg::svr_config port_p_w_0_cfg;
        svr_pkg::svr_config port_p_w_1_cfg;
        svr_pkg::svr_config port_p_w_2_cfg;
        svr_pkg::svr_config port_p_w_3_cfg;
        svr_pkg::svr_config port_m_w_cfg;
        svr_pkg::svr_config port_p_pred_0_cfg;
        svr_pkg::svr_config port_p_pred_1_cfg;
        svr_pkg::svr_config port_p_pred_2_cfg;
        svr_pkg::svr_config port_p_pred_3_cfg;
        svr_pkg::svr_config port_m_pred_cfg;

        `uvm_object_utils_begin(predict_kernel_config)         
        `uvm_field_object(port_p_x_0_cfg, UVM_DEFAULT)
        `uvm_field_object(port_p_x_1_cfg, UVM_DEFAULT)
        `uvm_field_object(port_p_x_2_cfg, UVM_DEFAULT)
        `uvm_field_object(port_p_x_3_cfg, UVM_DEFAULT)
        `uvm_field_object(port_m_x_cfg, UVM_DEFAULT)
        `uvm_field_object(port_p_w_0_cfg, UVM_DEFAULT)
        `uvm_field_object(port_p_w_1_cfg, UVM_DEFAULT)
        `uvm_field_object(port_p_w_2_cfg, UVM_DEFAULT)
        `uvm_field_object(port_p_w_3_cfg, UVM_DEFAULT)
        `uvm_field_object(port_m_w_cfg, UVM_DEFAULT)
        `uvm_field_object(port_p_pred_0_cfg, UVM_DEFAULT)
        `uvm_field_object(port_p_pred_1_cfg, UVM_DEFAULT)
        `uvm_field_object(port_p_pred_2_cfg, UVM_DEFAULT)
        `uvm_field_object(port_p_pred_3_cfg, UVM_DEFAULT)
        `uvm_field_object(port_m_pred_cfg, UVM_DEFAULT)
        `uvm_field_int   (check_ena , UVM_DEFAULT)          
        `uvm_field_int   (cover_ena , UVM_DEFAULT)          
        `uvm_object_utils_end                               

        function new (string name = "predict_kernel_config");
            super.new(name);                                
            port_p_x_0_cfg = svr_pkg::svr_config::type_id::create("port_p_x_0_cfg");
            port_p_x_1_cfg = svr_pkg::svr_config::type_id::create("port_p_x_1_cfg");
            port_p_x_2_cfg = svr_pkg::svr_config::type_id::create("port_p_x_2_cfg");
            port_p_x_3_cfg = svr_pkg::svr_config::type_id::create("port_p_x_3_cfg");
            port_m_x_cfg = svr_pkg::svr_config::type_id::create("port_m_x_cfg");
            port_p_w_0_cfg = svr_pkg::svr_config::type_id::create("port_p_w_0_cfg");
            port_p_w_1_cfg = svr_pkg::svr_config::type_id::create("port_p_w_1_cfg");
            port_p_w_2_cfg = svr_pkg::svr_config::type_id::create("port_p_w_2_cfg");
            port_p_w_3_cfg = svr_pkg::svr_config::type_id::create("port_p_w_3_cfg");
            port_m_w_cfg = svr_pkg::svr_config::type_id::create("port_m_w_cfg");
            port_p_pred_0_cfg = svr_pkg::svr_config::type_id::create("port_p_pred_0_cfg");
            port_p_pred_1_cfg = svr_pkg::svr_config::type_id::create("port_p_pred_1_cfg");
            port_p_pred_2_cfg = svr_pkg::svr_config::type_id::create("port_p_pred_2_cfg");
            port_p_pred_3_cfg = svr_pkg::svr_config::type_id::create("port_p_pred_3_cfg");
            port_m_pred_cfg = svr_pkg::svr_config::type_id::create("port_m_pred_cfg");
        endfunction                                         
                                                            
    endclass                                                
                                                            
`endif                                                      
