//==============================================================
//Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
//Tool Version Limit: 2025.11
//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//
//==============================================================
`ifndef PREDICT_KERNEL_SCOREBOARD__SV                                                       
    `define PREDICT_KERNEL_SCOREBOARD__SV                                                   
                                                                                               
    `define AUTOTB_TVOUT_p_pred_0_p_pred_0_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvout_p_pred_0.dat"
    `define AUTOTB_TVOUT_p_pred_1_p_pred_1_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvout_p_pred_1.dat"
    `define AUTOTB_TVOUT_p_pred_2_p_pred_2_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvout_p_pred_2.dat"
    `define AUTOTB_TVOUT_p_pred_3_p_pred_3_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvout_p_pred_3.dat"
    `define AUTOTB_TVOUT_m_pred_m_pred_wrapc  "../tv/rtldatafile/rtl.predict_kernel.autotvout_m_pred.dat"
                                                                                               
    class predict_kernel_scoreboard extends uvm_component;                                        
                                                                                               
        predict_kernel_reference_model refm;                                                      
                                                                                               
        typedef integer TRANS_SIZE_QUEUE_TYPE [$];                                      
        TRANS_SIZE_QUEUE_TYPE TVOUT_transaction_size_queue;                                
        int write_file_done_p_pred_0_p_pred_0;                                                          
        int write_file_done_p_pred_1_p_pred_1;                                                          
        int write_file_done_p_pred_2_p_pred_2;                                                          
        int write_file_done_p_pred_3_p_pred_3;                                                          
        int write_file_done_m_pred_m_pred;                                                          
        int write_section_done_p_pred_0_p_pred_0 = 0;                                                   
        int write_section_done_p_pred_1_p_pred_1 = 0;                                                   
        int write_section_done_p_pred_2_p_pred_2 = 0;                                                   
        int write_section_done_p_pred_3_p_pred_3 = 0;                                                   
        int write_section_done_m_pred_m_pred = 0;                                                   
                                                                                           
        file_agent_pkg::file_write_agent#(32) file_wr_port_p_pred_0_p_pred_0;
    svr_transfer#(32) p_pred_0_apvld_rxtr;
        file_agent_pkg::file_write_agent#(32) file_wr_port_p_pred_1_p_pred_1;
    svr_transfer#(32) p_pred_1_apvld_rxtr;
        file_agent_pkg::file_write_agent#(32) file_wr_port_p_pred_2_p_pred_2;
    svr_transfer#(32) p_pred_2_apvld_rxtr;
        file_agent_pkg::file_write_agent#(32) file_wr_port_p_pred_3_p_pred_3;
    svr_transfer#(32) p_pred_3_apvld_rxtr;
        file_agent_pkg::file_write_agent#(32) file_wr_port_m_pred_m_pred;
    svr_transfer#(32) m_pred_apvld_rxtr;
                                                                                               
        `uvm_component_utils_begin(predict_kernel_scoreboard)                                     
        `uvm_field_object(refm  , UVM_DEFAULT)                                                 
        `uvm_field_queue_int(TVOUT_transaction_size_queue, UVM_DEFAULT)                    
        `uvm_field_object(file_wr_port_p_pred_0_p_pred_0, UVM_DEFAULT)
        `uvm_field_int(write_file_done_p_pred_0_p_pred_0, UVM_DEFAULT)
        `uvm_field_int(write_section_done_p_pred_0_p_pred_0, UVM_DEFAULT)
        `uvm_field_object(file_wr_port_p_pred_1_p_pred_1, UVM_DEFAULT)
        `uvm_field_int(write_file_done_p_pred_1_p_pred_1, UVM_DEFAULT)
        `uvm_field_int(write_section_done_p_pred_1_p_pred_1, UVM_DEFAULT)
        `uvm_field_object(file_wr_port_p_pred_2_p_pred_2, UVM_DEFAULT)
        `uvm_field_int(write_file_done_p_pred_2_p_pred_2, UVM_DEFAULT)
        `uvm_field_int(write_section_done_p_pred_2_p_pred_2, UVM_DEFAULT)
        `uvm_field_object(file_wr_port_p_pred_3_p_pred_3, UVM_DEFAULT)
        `uvm_field_int(write_file_done_p_pred_3_p_pred_3, UVM_DEFAULT)
        `uvm_field_int(write_section_done_p_pred_3_p_pred_3, UVM_DEFAULT)
        `uvm_field_object(file_wr_port_m_pred_m_pred, UVM_DEFAULT)
        `uvm_field_int(write_file_done_m_pred_m_pred, UVM_DEFAULT)
        `uvm_field_int(write_section_done_m_pred_m_pred, UVM_DEFAULT)
        `uvm_component_utils_end                                                               
                                                                                               
        virtual function void build_phase(uvm_phase phase);                                    
            if (!uvm_config_db #(predict_kernel_reference_model)::get(this, "", "refm", refm))
                `uvm_fatal(this.get_full_name(), "No refm from high level")                  
            `uvm_info(this.get_full_name(), "get reference model by uvm_config_db", UVM_MEDIUM) 
                                                                                               
            file_wr_port_p_pred_0_p_pred_0 = file_agent_pkg::file_write_agent#(32)::type_id::create("file_wr_port_p_pred_0_p_pred_0", this);
            file_wr_port_p_pred_1_p_pred_1 = file_agent_pkg::file_write_agent#(32)::type_id::create("file_wr_port_p_pred_1_p_pred_1", this);
            file_wr_port_p_pred_2_p_pred_2 = file_agent_pkg::file_write_agent#(32)::type_id::create("file_wr_port_p_pred_2_p_pred_2", this);
            file_wr_port_p_pred_3_p_pred_3 = file_agent_pkg::file_write_agent#(32)::type_id::create("file_wr_port_p_pred_3_p_pred_3", this);
            file_wr_port_m_pred_m_pred = file_agent_pkg::file_write_agent#(32)::type_id::create("file_wr_port_m_pred_m_pred", this);
        endfunction                                                                            
                                                                                               
        function new (string name = "", uvm_component parent = null);                        
            super.new(name, parent);                                                           
            write_file_done_p_pred_0_p_pred_0 = 0;                                                          
            write_file_done_p_pred_1_p_pred_1 = 0;                                                          
            write_file_done_p_pred_2_p_pred_2 = 0;                                                          
            write_file_done_p_pred_3_p_pred_3 = 0;                                                          
            write_file_done_m_pred_m_pred = 0;                                                          
        endfunction                                                                            
                                                                                               
        virtual task run_phase(uvm_phase phase);                                               
            create_TVOUT_transaction_size_queue_by_depth(1);
            file_wr_port_p_pred_0_p_pred_0.config_file(   
                    `AUTOTB_TVOUT_p_pred_0_p_pred_0_wrapc,
                    TVOUT_transaction_size_queue                            
                );                                                          
                                                                            
            create_TVOUT_transaction_size_queue_by_depth(1);
            file_wr_port_p_pred_1_p_pred_1.config_file(   
                    `AUTOTB_TVOUT_p_pred_1_p_pred_1_wrapc,
                    TVOUT_transaction_size_queue                            
                );                                                          
                                                                            
            create_TVOUT_transaction_size_queue_by_depth(1);
            file_wr_port_p_pred_2_p_pred_2.config_file(   
                    `AUTOTB_TVOUT_p_pred_2_p_pred_2_wrapc,
                    TVOUT_transaction_size_queue                            
                );                                                          
                                                                            
            create_TVOUT_transaction_size_queue_by_depth(1);
            file_wr_port_p_pred_3_p_pred_3.config_file(   
                    `AUTOTB_TVOUT_p_pred_3_p_pred_3_wrapc,
                    TVOUT_transaction_size_queue                            
                );                                                          
                                                                            
            create_TVOUT_transaction_size_queue_by_depth(1);
            file_wr_port_m_pred_m_pred.config_file(   
                    `AUTOTB_TVOUT_m_pred_m_pred_wrapc,
                    TVOUT_transaction_size_queue                            
                );                                                          
                                                                            

            fork                                                                               
                                                                                               
                forever begin
                    @refm.dut2tb_ap_done;
                    `uvm_info(this.get_full_name(), "receive dut2tb_ap_done and do axim dump", UVM_LOW)
            if (p_pred_0_apvld_rxtr) file_wr_port_p_pred_0_p_pred_0.write_TVOUT_data(p_pred_0_apvld_rxtr.data[31: 0]);
                    file_wr_port_p_pred_0_p_pred_0.receive_ap_done();
             p_pred_0_apvld_rxtr = null;
            if (p_pred_1_apvld_rxtr) file_wr_port_p_pred_1_p_pred_1.write_TVOUT_data(p_pred_1_apvld_rxtr.data[31: 0]);
                    file_wr_port_p_pred_1_p_pred_1.receive_ap_done();
             p_pred_1_apvld_rxtr = null;
            if (p_pred_2_apvld_rxtr) file_wr_port_p_pred_2_p_pred_2.write_TVOUT_data(p_pred_2_apvld_rxtr.data[31: 0]);
                    file_wr_port_p_pred_2_p_pred_2.receive_ap_done();
             p_pred_2_apvld_rxtr = null;
            if (p_pred_3_apvld_rxtr) file_wr_port_p_pred_3_p_pred_3.write_TVOUT_data(p_pred_3_apvld_rxtr.data[31: 0]);
                    file_wr_port_p_pred_3_p_pred_3.receive_ap_done();
             p_pred_3_apvld_rxtr = null;
            if (m_pred_apvld_rxtr) file_wr_port_m_pred_m_pred.write_TVOUT_data(m_pred_apvld_rxtr.data[31: 0]);
                    file_wr_port_m_pred_m_pred.receive_ap_done();
             m_pred_apvld_rxtr = null;
                end                                                                            
                begin                                                                          
                    @refm.finish;                                                              
                    `uvm_info(this.get_full_name(), "receive FINISH", UVM_LOW)               
                    file_wr_port_p_pred_0_p_pred_0.wait_write_file_done();
                    file_wr_port_p_pred_1_p_pred_1.wait_write_file_done();
                    file_wr_port_p_pred_2_p_pred_2.wait_write_file_done();
                    file_wr_port_p_pred_3_p_pred_3.wait_write_file_done();
                    file_wr_port_m_pred_m_pred.wait_write_file_done();
                end                                                                            
                begin                                                                      
                    forever begin                                                              
                        wait(write_section_done_p_pred_0_p_pred_0 && write_section_done_p_pred_1_p_pred_1 && write_section_done_p_pred_2_p_pred_2 && write_section_done_p_pred_3_p_pred_3 && write_section_done_m_pred_m_pred);                          
                        write_section_done_p_pred_0_p_pred_0 = 0;                                               
                        write_section_done_p_pred_1_p_pred_1 = 0;                                               
                        write_section_done_p_pred_2_p_pred_2 = 0;                                               
                        write_section_done_p_pred_3_p_pred_3 = 0;                                               
                        write_section_done_m_pred_m_pred = 0;                                               
                        -> refm.allsvr_output_done;                                         
                    end                                                                        
                end                                                                        
            join                                                                               
        endtask                                                                                
                                                                                               
        virtual function void create_TVOUT_transaction_size_queue_by_depth(integer depth); 
            integer i;                                                                     
            TVOUT_transaction_size_queue.delete();                                         
            for (i = 0; i < 60; i++)                                    
                TVOUT_transaction_size_queue.push_back(depth);                             
        endfunction                                                                        
                                                                                           
        virtual function void write_svr_master_p_x_0(svr_transfer#(32) tr);
            `uvm_info(this.get_full_name(), "port p_x_0 collected one pkt", UVM_DEBUG);          
        endfunction
                   
        virtual function void write_svr_master_p_x_1(svr_transfer#(32) tr);
            `uvm_info(this.get_full_name(), "port p_x_1 collected one pkt", UVM_DEBUG);          
        endfunction
                   
        virtual function void write_svr_master_p_x_2(svr_transfer#(32) tr);
            `uvm_info(this.get_full_name(), "port p_x_2 collected one pkt", UVM_DEBUG);          
        endfunction
                   
        virtual function void write_svr_master_p_x_3(svr_transfer#(32) tr);
            `uvm_info(this.get_full_name(), "port p_x_3 collected one pkt", UVM_DEBUG);          
        endfunction
                   
        virtual function void write_svr_master_m_x(svr_transfer#(32) tr);
            `uvm_info(this.get_full_name(), "port m_x collected one pkt", UVM_DEBUG);          
        endfunction
                   
        virtual function void write_svr_master_p_w_0(svr_transfer#(32) tr);
            `uvm_info(this.get_full_name(), "port p_w_0 collected one pkt", UVM_DEBUG);          
        endfunction
                   
        virtual function void write_svr_master_p_w_1(svr_transfer#(32) tr);
            `uvm_info(this.get_full_name(), "port p_w_1 collected one pkt", UVM_DEBUG);          
        endfunction
                   
        virtual function void write_svr_master_p_w_2(svr_transfer#(32) tr);
            `uvm_info(this.get_full_name(), "port p_w_2 collected one pkt", UVM_DEBUG);          
        endfunction
                   
        virtual function void write_svr_master_p_w_3(svr_transfer#(32) tr);
            `uvm_info(this.get_full_name(), "port p_w_3 collected one pkt", UVM_DEBUG);          
        endfunction
                   
        virtual function void write_svr_master_m_w(svr_transfer#(32) tr);
            `uvm_info(this.get_full_name(), "port m_w collected one pkt", UVM_DEBUG);          
        endfunction
                   
        virtual function void write_svr_slave_p_pred_0(svr_transfer#(32) tr);
            `uvm_info(this.get_full_name(), "port p_pred_0 collected one pkt", UVM_DEBUG);          
             p_pred_0_apvld_rxtr = tr;
            write_section_done_p_pred_0_p_pred_0 = 1;
        endfunction
                   
        virtual function void write_svr_slave_p_pred_1(svr_transfer#(32) tr);
            `uvm_info(this.get_full_name(), "port p_pred_1 collected one pkt", UVM_DEBUG);          
             p_pred_1_apvld_rxtr = tr;
            write_section_done_p_pred_1_p_pred_1 = 1;
        endfunction
                   
        virtual function void write_svr_slave_p_pred_2(svr_transfer#(32) tr);
            `uvm_info(this.get_full_name(), "port p_pred_2 collected one pkt", UVM_DEBUG);          
             p_pred_2_apvld_rxtr = tr;
            write_section_done_p_pred_2_p_pred_2 = 1;
        endfunction
                   
        virtual function void write_svr_slave_p_pred_3(svr_transfer#(32) tr);
            `uvm_info(this.get_full_name(), "port p_pred_3 collected one pkt", UVM_DEBUG);          
             p_pred_3_apvld_rxtr = tr;
            write_section_done_p_pred_3_p_pred_3 = 1;
        endfunction
                   
        virtual function void write_svr_slave_m_pred(svr_transfer#(32) tr);
            `uvm_info(this.get_full_name(), "port m_pred collected one pkt", UVM_DEBUG);          
             m_pred_apvld_rxtr = tr;
            write_section_done_m_pred_m_pred = 1;
        endfunction
                   
    endclass                                                                                   
                                                                                               
`endif                                                                                         
