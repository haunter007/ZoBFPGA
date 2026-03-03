//==============================================================
//Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
//Tool Version Limit: 2025.11
//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//
//==============================================================
`ifndef PREDICT_KERNEL_ENV__SV                                                                                   
    `define PREDICT_KERNEL_ENV__SV                                                                               
                                                                                                                    
                                                                                                                    
    class predict_kernel_env extends uvm_env;                                                                          
                                                                                                                    
        predict_kernel_virtual_sequencer predict_kernel_virtual_sqr;                                                      
        predict_kernel_config predict_kernel_cfg;                                                                         
                                                                                                                    
        svr_pkg::svr_env#(32) env_master_svr_p_x_0;
        svr_pkg::svr_env#(32) env_master_svr_p_x_1;
        svr_pkg::svr_env#(32) env_master_svr_p_x_2;
        svr_pkg::svr_env#(32) env_master_svr_p_x_3;
        svr_pkg::svr_env#(32) env_master_svr_m_x;
        svr_pkg::svr_env#(32) env_master_svr_p_w_0;
        svr_pkg::svr_env#(32) env_master_svr_p_w_1;
        svr_pkg::svr_env#(32) env_master_svr_p_w_2;
        svr_pkg::svr_env#(32) env_master_svr_p_w_3;
        svr_pkg::svr_env#(32) env_master_svr_m_w;
        svr_pkg::svr_env#(32) env_slave_svr_p_pred_0;
        svr_pkg::svr_env#(32) env_slave_svr_p_pred_1;
        svr_pkg::svr_env#(32) env_slave_svr_p_pred_2;
        svr_pkg::svr_env#(32) env_slave_svr_p_pred_3;
        svr_pkg::svr_env#(32) env_slave_svr_m_pred;
                                                                                                                    
        predict_kernel_reference_model   refm;                                                                         
                                                                                                                    
        predict_kernel_subsystem_monitor subsys_mon;                                                                   
                                                                                                                    
        `uvm_component_utils_begin(predict_kernel_env)                                                                 
        `uvm_field_object (env_master_svr_p_x_0,  UVM_DEFAULT | UVM_REFERENCE)
        `uvm_field_object (env_master_svr_p_x_1,  UVM_DEFAULT | UVM_REFERENCE)
        `uvm_field_object (env_master_svr_p_x_2,  UVM_DEFAULT | UVM_REFERENCE)
        `uvm_field_object (env_master_svr_p_x_3,  UVM_DEFAULT | UVM_REFERENCE)
        `uvm_field_object (env_master_svr_m_x,  UVM_DEFAULT | UVM_REFERENCE)
        `uvm_field_object (env_master_svr_p_w_0,  UVM_DEFAULT | UVM_REFERENCE)
        `uvm_field_object (env_master_svr_p_w_1,  UVM_DEFAULT | UVM_REFERENCE)
        `uvm_field_object (env_master_svr_p_w_2,  UVM_DEFAULT | UVM_REFERENCE)
        `uvm_field_object (env_master_svr_p_w_3,  UVM_DEFAULT | UVM_REFERENCE)
        `uvm_field_object (env_master_svr_m_w,  UVM_DEFAULT | UVM_REFERENCE)
        `uvm_field_object (env_slave_svr_p_pred_0,  UVM_DEFAULT | UVM_REFERENCE)
        `uvm_field_object (env_slave_svr_p_pred_1,  UVM_DEFAULT | UVM_REFERENCE)
        `uvm_field_object (env_slave_svr_p_pred_2,  UVM_DEFAULT | UVM_REFERENCE)
        `uvm_field_object (env_slave_svr_p_pred_3,  UVM_DEFAULT | UVM_REFERENCE)
        `uvm_field_object (env_slave_svr_m_pred,  UVM_DEFAULT | UVM_REFERENCE)
        `uvm_field_object (refm, UVM_DEFAULT | UVM_REFERENCE)                                                       
        `uvm_field_object (predict_kernel_virtual_sqr, UVM_DEFAULT | UVM_REFERENCE)                                    
        `uvm_field_object (predict_kernel_cfg        , UVM_DEFAULT)                                                    
        `uvm_component_utils_end                                                                                    
                                                                                                                    
        function new (string name = "predict_kernel_env", uvm_component parent = null);                              
            super.new(name, parent);                                                                                
        endfunction                                                                                                 
                                                                                                                    
        extern virtual function void build_phase(uvm_phase phase);                                                  
        extern virtual function void connect_phase(uvm_phase phase);                                                
        extern virtual task          run_phase(uvm_phase phase);                                                    
                                                                                                                    
    endclass                                                                                                        
                                                                                                                    
    function void predict_kernel_env::build_phase(uvm_phase phase);                                                    
        super.build_phase(phase);                                                                                   
        predict_kernel_cfg = predict_kernel_config::type_id::create("predict_kernel_cfg", this);                           
                                                                                                                    
        predict_kernel_cfg.port_p_x_0_cfg.svr_type = svr_pkg::SVR_MASTER ;
        env_master_svr_p_x_0  = svr_env#(32)::type_id::create("env_master_svr_p_x_0", this);
        uvm_config_db#(svr_pkg::svr_config)::set(this, "env_master_svr_p_x_0*", "cfg", predict_kernel_cfg.port_p_x_0_cfg);
        predict_kernel_cfg.port_p_x_0_cfg.prt_type = svr_pkg::AP_NONE;
        predict_kernel_cfg.port_p_x_0_cfg.is_active = svr_pkg::SVR_ACTIVE;
        predict_kernel_cfg.port_p_x_0_cfg.spec_cfg = svr_pkg::NORMAL;
        predict_kernel_cfg.port_p_x_0_cfg.reset_level = svr_pkg::RESET_LEVEL_HIGH;
 
        predict_kernel_cfg.port_p_x_1_cfg.svr_type = svr_pkg::SVR_MASTER ;
        env_master_svr_p_x_1  = svr_env#(32)::type_id::create("env_master_svr_p_x_1", this);
        uvm_config_db#(svr_pkg::svr_config)::set(this, "env_master_svr_p_x_1*", "cfg", predict_kernel_cfg.port_p_x_1_cfg);
        predict_kernel_cfg.port_p_x_1_cfg.prt_type = svr_pkg::AP_NONE;
        predict_kernel_cfg.port_p_x_1_cfg.is_active = svr_pkg::SVR_ACTIVE;
        predict_kernel_cfg.port_p_x_1_cfg.spec_cfg = svr_pkg::NORMAL;
        predict_kernel_cfg.port_p_x_1_cfg.reset_level = svr_pkg::RESET_LEVEL_HIGH;
 
        predict_kernel_cfg.port_p_x_2_cfg.svr_type = svr_pkg::SVR_MASTER ;
        env_master_svr_p_x_2  = svr_env#(32)::type_id::create("env_master_svr_p_x_2", this);
        uvm_config_db#(svr_pkg::svr_config)::set(this, "env_master_svr_p_x_2*", "cfg", predict_kernel_cfg.port_p_x_2_cfg);
        predict_kernel_cfg.port_p_x_2_cfg.prt_type = svr_pkg::AP_NONE;
        predict_kernel_cfg.port_p_x_2_cfg.is_active = svr_pkg::SVR_ACTIVE;
        predict_kernel_cfg.port_p_x_2_cfg.spec_cfg = svr_pkg::NORMAL;
        predict_kernel_cfg.port_p_x_2_cfg.reset_level = svr_pkg::RESET_LEVEL_HIGH;
 
        predict_kernel_cfg.port_p_x_3_cfg.svr_type = svr_pkg::SVR_MASTER ;
        env_master_svr_p_x_3  = svr_env#(32)::type_id::create("env_master_svr_p_x_3", this);
        uvm_config_db#(svr_pkg::svr_config)::set(this, "env_master_svr_p_x_3*", "cfg", predict_kernel_cfg.port_p_x_3_cfg);
        predict_kernel_cfg.port_p_x_3_cfg.prt_type = svr_pkg::AP_NONE;
        predict_kernel_cfg.port_p_x_3_cfg.is_active = svr_pkg::SVR_ACTIVE;
        predict_kernel_cfg.port_p_x_3_cfg.spec_cfg = svr_pkg::NORMAL;
        predict_kernel_cfg.port_p_x_3_cfg.reset_level = svr_pkg::RESET_LEVEL_HIGH;
 
        predict_kernel_cfg.port_m_x_cfg.svr_type = svr_pkg::SVR_MASTER ;
        env_master_svr_m_x  = svr_env#(32)::type_id::create("env_master_svr_m_x", this);
        uvm_config_db#(svr_pkg::svr_config)::set(this, "env_master_svr_m_x*", "cfg", predict_kernel_cfg.port_m_x_cfg);
        predict_kernel_cfg.port_m_x_cfg.prt_type = svr_pkg::AP_NONE;
        predict_kernel_cfg.port_m_x_cfg.is_active = svr_pkg::SVR_ACTIVE;
        predict_kernel_cfg.port_m_x_cfg.spec_cfg = svr_pkg::NORMAL;
        predict_kernel_cfg.port_m_x_cfg.reset_level = svr_pkg::RESET_LEVEL_HIGH;
 
        predict_kernel_cfg.port_p_w_0_cfg.svr_type = svr_pkg::SVR_MASTER ;
        env_master_svr_p_w_0  = svr_env#(32)::type_id::create("env_master_svr_p_w_0", this);
        uvm_config_db#(svr_pkg::svr_config)::set(this, "env_master_svr_p_w_0*", "cfg", predict_kernel_cfg.port_p_w_0_cfg);
        predict_kernel_cfg.port_p_w_0_cfg.prt_type = svr_pkg::AP_NONE;
        predict_kernel_cfg.port_p_w_0_cfg.is_active = svr_pkg::SVR_ACTIVE;
        predict_kernel_cfg.port_p_w_0_cfg.spec_cfg = svr_pkg::NORMAL;
        predict_kernel_cfg.port_p_w_0_cfg.reset_level = svr_pkg::RESET_LEVEL_HIGH;
 
        predict_kernel_cfg.port_p_w_1_cfg.svr_type = svr_pkg::SVR_MASTER ;
        env_master_svr_p_w_1  = svr_env#(32)::type_id::create("env_master_svr_p_w_1", this);
        uvm_config_db#(svr_pkg::svr_config)::set(this, "env_master_svr_p_w_1*", "cfg", predict_kernel_cfg.port_p_w_1_cfg);
        predict_kernel_cfg.port_p_w_1_cfg.prt_type = svr_pkg::AP_NONE;
        predict_kernel_cfg.port_p_w_1_cfg.is_active = svr_pkg::SVR_ACTIVE;
        predict_kernel_cfg.port_p_w_1_cfg.spec_cfg = svr_pkg::NORMAL;
        predict_kernel_cfg.port_p_w_1_cfg.reset_level = svr_pkg::RESET_LEVEL_HIGH;
 
        predict_kernel_cfg.port_p_w_2_cfg.svr_type = svr_pkg::SVR_MASTER ;
        env_master_svr_p_w_2  = svr_env#(32)::type_id::create("env_master_svr_p_w_2", this);
        uvm_config_db#(svr_pkg::svr_config)::set(this, "env_master_svr_p_w_2*", "cfg", predict_kernel_cfg.port_p_w_2_cfg);
        predict_kernel_cfg.port_p_w_2_cfg.prt_type = svr_pkg::AP_NONE;
        predict_kernel_cfg.port_p_w_2_cfg.is_active = svr_pkg::SVR_ACTIVE;
        predict_kernel_cfg.port_p_w_2_cfg.spec_cfg = svr_pkg::NORMAL;
        predict_kernel_cfg.port_p_w_2_cfg.reset_level = svr_pkg::RESET_LEVEL_HIGH;
 
        predict_kernel_cfg.port_p_w_3_cfg.svr_type = svr_pkg::SVR_MASTER ;
        env_master_svr_p_w_3  = svr_env#(32)::type_id::create("env_master_svr_p_w_3", this);
        uvm_config_db#(svr_pkg::svr_config)::set(this, "env_master_svr_p_w_3*", "cfg", predict_kernel_cfg.port_p_w_3_cfg);
        predict_kernel_cfg.port_p_w_3_cfg.prt_type = svr_pkg::AP_NONE;
        predict_kernel_cfg.port_p_w_3_cfg.is_active = svr_pkg::SVR_ACTIVE;
        predict_kernel_cfg.port_p_w_3_cfg.spec_cfg = svr_pkg::NORMAL;
        predict_kernel_cfg.port_p_w_3_cfg.reset_level = svr_pkg::RESET_LEVEL_HIGH;
 
        predict_kernel_cfg.port_m_w_cfg.svr_type = svr_pkg::SVR_MASTER ;
        env_master_svr_m_w  = svr_env#(32)::type_id::create("env_master_svr_m_w", this);
        uvm_config_db#(svr_pkg::svr_config)::set(this, "env_master_svr_m_w*", "cfg", predict_kernel_cfg.port_m_w_cfg);
        predict_kernel_cfg.port_m_w_cfg.prt_type = svr_pkg::AP_NONE;
        predict_kernel_cfg.port_m_w_cfg.is_active = svr_pkg::SVR_ACTIVE;
        predict_kernel_cfg.port_m_w_cfg.spec_cfg = svr_pkg::NORMAL;
        predict_kernel_cfg.port_m_w_cfg.reset_level = svr_pkg::RESET_LEVEL_HIGH;
 
        predict_kernel_cfg.port_p_pred_0_cfg.svr_type = svr_pkg::SVR_SLAVE ;
        env_slave_svr_p_pred_0  = svr_env#(32)::type_id::create("env_slave_svr_p_pred_0", this);
        uvm_config_db#(svr_pkg::svr_config)::set(this, "env_slave_svr_p_pred_0*", "cfg", predict_kernel_cfg.port_p_pred_0_cfg);
        predict_kernel_cfg.port_p_pred_0_cfg.prt_type = svr_pkg::AP_VLD;
        predict_kernel_cfg.port_p_pred_0_cfg.is_active = svr_pkg::SVR_ACTIVE;
        predict_kernel_cfg.port_p_pred_0_cfg.spec_cfg = svr_pkg::NORMAL;
        predict_kernel_cfg.port_p_pred_0_cfg.reset_level = svr_pkg::RESET_LEVEL_HIGH;
 
        predict_kernel_cfg.port_p_pred_1_cfg.svr_type = svr_pkg::SVR_SLAVE ;
        env_slave_svr_p_pred_1  = svr_env#(32)::type_id::create("env_slave_svr_p_pred_1", this);
        uvm_config_db#(svr_pkg::svr_config)::set(this, "env_slave_svr_p_pred_1*", "cfg", predict_kernel_cfg.port_p_pred_1_cfg);
        predict_kernel_cfg.port_p_pred_1_cfg.prt_type = svr_pkg::AP_VLD;
        predict_kernel_cfg.port_p_pred_1_cfg.is_active = svr_pkg::SVR_ACTIVE;
        predict_kernel_cfg.port_p_pred_1_cfg.spec_cfg = svr_pkg::NORMAL;
        predict_kernel_cfg.port_p_pred_1_cfg.reset_level = svr_pkg::RESET_LEVEL_HIGH;
 
        predict_kernel_cfg.port_p_pred_2_cfg.svr_type = svr_pkg::SVR_SLAVE ;
        env_slave_svr_p_pred_2  = svr_env#(32)::type_id::create("env_slave_svr_p_pred_2", this);
        uvm_config_db#(svr_pkg::svr_config)::set(this, "env_slave_svr_p_pred_2*", "cfg", predict_kernel_cfg.port_p_pred_2_cfg);
        predict_kernel_cfg.port_p_pred_2_cfg.prt_type = svr_pkg::AP_VLD;
        predict_kernel_cfg.port_p_pred_2_cfg.is_active = svr_pkg::SVR_ACTIVE;
        predict_kernel_cfg.port_p_pred_2_cfg.spec_cfg = svr_pkg::NORMAL;
        predict_kernel_cfg.port_p_pred_2_cfg.reset_level = svr_pkg::RESET_LEVEL_HIGH;
 
        predict_kernel_cfg.port_p_pred_3_cfg.svr_type = svr_pkg::SVR_SLAVE ;
        env_slave_svr_p_pred_3  = svr_env#(32)::type_id::create("env_slave_svr_p_pred_3", this);
        uvm_config_db#(svr_pkg::svr_config)::set(this, "env_slave_svr_p_pred_3*", "cfg", predict_kernel_cfg.port_p_pred_3_cfg);
        predict_kernel_cfg.port_p_pred_3_cfg.prt_type = svr_pkg::AP_VLD;
        predict_kernel_cfg.port_p_pred_3_cfg.is_active = svr_pkg::SVR_ACTIVE;
        predict_kernel_cfg.port_p_pred_3_cfg.spec_cfg = svr_pkg::NORMAL;
        predict_kernel_cfg.port_p_pred_3_cfg.reset_level = svr_pkg::RESET_LEVEL_HIGH;
 
        predict_kernel_cfg.port_m_pred_cfg.svr_type = svr_pkg::SVR_SLAVE ;
        env_slave_svr_m_pred  = svr_env#(32)::type_id::create("env_slave_svr_m_pred", this);
        uvm_config_db#(svr_pkg::svr_config)::set(this, "env_slave_svr_m_pred*", "cfg", predict_kernel_cfg.port_m_pred_cfg);
        predict_kernel_cfg.port_m_pred_cfg.prt_type = svr_pkg::AP_VLD;
        predict_kernel_cfg.port_m_pred_cfg.is_active = svr_pkg::SVR_ACTIVE;
        predict_kernel_cfg.port_m_pred_cfg.spec_cfg = svr_pkg::NORMAL;
        predict_kernel_cfg.port_m_pred_cfg.reset_level = svr_pkg::RESET_LEVEL_HIGH;
 



        refm = predict_kernel_reference_model::type_id::create("refm", this);


        uvm_config_db#(predict_kernel_reference_model)::set(this, "*", "refm", refm);


        `uvm_info(this.get_full_name(), "set reference model by uvm_config_db", UVM_LOW)


        subsys_mon = predict_kernel_subsystem_monitor::type_id::create("subsys_mon", this);


        predict_kernel_virtual_sqr = predict_kernel_virtual_sequencer::type_id::create("predict_kernel_virtual_sqr", this);
        `uvm_info(this.get_full_name(), "build_phase done", UVM_LOW)
    endfunction


    function void predict_kernel_env::connect_phase(uvm_phase phase);
        super.connect_phase(phase);


        predict_kernel_virtual_sqr.svr_port_p_x_0_sqr = env_master_svr_p_x_0.m_agt.sqr;
        env_master_svr_p_x_0.m_agt.mon.item_collect_port.connect(subsys_mon.svr_master_p_x_0_imp);
 
        predict_kernel_virtual_sqr.svr_port_p_x_1_sqr = env_master_svr_p_x_1.m_agt.sqr;
        env_master_svr_p_x_1.m_agt.mon.item_collect_port.connect(subsys_mon.svr_master_p_x_1_imp);
 
        predict_kernel_virtual_sqr.svr_port_p_x_2_sqr = env_master_svr_p_x_2.m_agt.sqr;
        env_master_svr_p_x_2.m_agt.mon.item_collect_port.connect(subsys_mon.svr_master_p_x_2_imp);
 
        predict_kernel_virtual_sqr.svr_port_p_x_3_sqr = env_master_svr_p_x_3.m_agt.sqr;
        env_master_svr_p_x_3.m_agt.mon.item_collect_port.connect(subsys_mon.svr_master_p_x_3_imp);
 
        predict_kernel_virtual_sqr.svr_port_m_x_sqr = env_master_svr_m_x.m_agt.sqr;
        env_master_svr_m_x.m_agt.mon.item_collect_port.connect(subsys_mon.svr_master_m_x_imp);
 
        predict_kernel_virtual_sqr.svr_port_p_w_0_sqr = env_master_svr_p_w_0.m_agt.sqr;
        env_master_svr_p_w_0.m_agt.mon.item_collect_port.connect(subsys_mon.svr_master_p_w_0_imp);
 
        predict_kernel_virtual_sqr.svr_port_p_w_1_sqr = env_master_svr_p_w_1.m_agt.sqr;
        env_master_svr_p_w_1.m_agt.mon.item_collect_port.connect(subsys_mon.svr_master_p_w_1_imp);
 
        predict_kernel_virtual_sqr.svr_port_p_w_2_sqr = env_master_svr_p_w_2.m_agt.sqr;
        env_master_svr_p_w_2.m_agt.mon.item_collect_port.connect(subsys_mon.svr_master_p_w_2_imp);
 
        predict_kernel_virtual_sqr.svr_port_p_w_3_sqr = env_master_svr_p_w_3.m_agt.sqr;
        env_master_svr_p_w_3.m_agt.mon.item_collect_port.connect(subsys_mon.svr_master_p_w_3_imp);
 
        predict_kernel_virtual_sqr.svr_port_m_w_sqr = env_master_svr_m_w.m_agt.sqr;
        env_master_svr_m_w.m_agt.mon.item_collect_port.connect(subsys_mon.svr_master_m_w_imp);
 
        predict_kernel_virtual_sqr.svr_port_p_pred_0_sqr = env_slave_svr_p_pred_0.s_agt.sqr;
        env_slave_svr_p_pred_0.s_agt.mon.item_collect_port.connect(subsys_mon.svr_slave_p_pred_0_imp);
 
        predict_kernel_virtual_sqr.svr_port_p_pred_1_sqr = env_slave_svr_p_pred_1.s_agt.sqr;
        env_slave_svr_p_pred_1.s_agt.mon.item_collect_port.connect(subsys_mon.svr_slave_p_pred_1_imp);
 
        predict_kernel_virtual_sqr.svr_port_p_pred_2_sqr = env_slave_svr_p_pred_2.s_agt.sqr;
        env_slave_svr_p_pred_2.s_agt.mon.item_collect_port.connect(subsys_mon.svr_slave_p_pred_2_imp);
 
        predict_kernel_virtual_sqr.svr_port_p_pred_3_sqr = env_slave_svr_p_pred_3.s_agt.sqr;
        env_slave_svr_p_pred_3.s_agt.mon.item_collect_port.connect(subsys_mon.svr_slave_p_pred_3_imp);
 
        predict_kernel_virtual_sqr.svr_port_m_pred_sqr = env_slave_svr_m_pred.s_agt.sqr;
        env_slave_svr_m_pred.s_agt.mon.item_collect_port.connect(subsys_mon.svr_slave_m_pred_imp);
 
        refm.predict_kernel_cfg = predict_kernel_cfg;
        `uvm_info(this.get_full_name(), "connect phase done", UVM_LOW)
    endfunction


    task predict_kernel_env::run_phase(uvm_phase phase);
        `uvm_info(this.get_full_name(), "predict_kernel_env is running", UVM_LOW)
    endtask


`endif
