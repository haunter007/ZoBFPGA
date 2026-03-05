//==============================================================
//Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
//Tool Version Limit: 2025.11
//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//
//==============================================================
`ifndef PREDICT_KERNEL_SUBSYS_TEST_SEQUENCE_LIB__SV                                              
    `define PREDICT_KERNEL_SUBSYS_TEST_SEQUENCE_LIB__SV                                          
                                                                                                    
    `define AUTOTB_TVIN_p_x_0_p_x_0  "../tv/cdatafile/c.predict_kernel.autotvin_p_x_0.dat" 
    `define AUTOTB_TVIN_p_x_1_p_x_1  "../tv/cdatafile/c.predict_kernel.autotvin_p_x_1.dat" 
    `define AUTOTB_TVIN_p_x_2_p_x_2  "../tv/cdatafile/c.predict_kernel.autotvin_p_x_2.dat" 
    `define AUTOTB_TVIN_p_x_3_p_x_3  "../tv/cdatafile/c.predict_kernel.autotvin_p_x_3.dat" 
    `define AUTOTB_TVIN_m_x_m_x  "../tv/cdatafile/c.predict_kernel.autotvin_m_x.dat" 
    `define AUTOTB_TVIN_p_w_0_p_w_0  "../tv/cdatafile/c.predict_kernel.autotvin_p_w_0.dat" 
    `define AUTOTB_TVIN_p_w_1_p_w_1  "../tv/cdatafile/c.predict_kernel.autotvin_p_w_1.dat" 
    `define AUTOTB_TVIN_p_w_2_p_w_2  "../tv/cdatafile/c.predict_kernel.autotvin_p_w_2.dat" 
    `define AUTOTB_TVIN_p_w_3_p_w_3  "../tv/cdatafile/c.predict_kernel.autotvin_p_w_3.dat" 
    `define AUTOTB_TVIN_m_w_m_w  "../tv/cdatafile/c.predict_kernel.autotvin_m_w.dat" 
                                                                                                    
    `include "uvm_macros.svh"                                                                     
                                                                                                    
    class predict_kernel_subsys_test_sequence_lib extends uvm_sequence;                                
                                                                                                    
        function new (string name = "predict_kernel_subsys_test_sequence_lib");                      
            super.new(name);                                                                        
            `uvm_info(this.get_full_name(), "new is called", UVM_LOW)                             
        endfunction                                                                                 
                                                                                                    
        `uvm_object_utils(predict_kernel_subsys_test_sequence_lib)                                     
        `uvm_declare_p_sequencer(predict_kernel_virtual_sequencer)                                     
                                                                                                    
        virtual task body();                                                                        
            uvm_phase starting_phase;                                                               
            virtual interface misc_interface misc_if;                                               
            predict_kernel_reference_model refm;                                                       
                                                                                                    
            string file_queue_p_x_0 [$];                                                         
            integer bitwidth_queue_p_x_0 [$];                                                    
                                                                                                               
            svr_pkg::svr_master_sequence#(32) svr_port_p_x_0_seq;            
            svr_pkg::svr_random_sequence#(32) svr_port_random_port_p_x_0_seq;

            string file_queue_p_x_1 [$];                                                         
            integer bitwidth_queue_p_x_1 [$];                                                    
                                                                                                               
            svr_pkg::svr_master_sequence#(32) svr_port_p_x_1_seq;            
            svr_pkg::svr_random_sequence#(32) svr_port_random_port_p_x_1_seq;

            string file_queue_p_x_2 [$];                                                         
            integer bitwidth_queue_p_x_2 [$];                                                    
                                                                                                               
            svr_pkg::svr_master_sequence#(32) svr_port_p_x_2_seq;            
            svr_pkg::svr_random_sequence#(32) svr_port_random_port_p_x_2_seq;

            string file_queue_p_x_3 [$];                                                         
            integer bitwidth_queue_p_x_3 [$];                                                    
                                                                                                               
            svr_pkg::svr_master_sequence#(32) svr_port_p_x_3_seq;            
            svr_pkg::svr_random_sequence#(32) svr_port_random_port_p_x_3_seq;

            string file_queue_m_x [$];                                                         
            integer bitwidth_queue_m_x [$];                                                    
                                                                                                               
            svr_pkg::svr_master_sequence#(32) svr_port_m_x_seq;            
            svr_pkg::svr_random_sequence#(32) svr_port_random_port_m_x_seq;

            string file_queue_p_w_0 [$];                                                         
            integer bitwidth_queue_p_w_0 [$];                                                    
                                                                                                               
            svr_pkg::svr_master_sequence#(32) svr_port_p_w_0_seq;            
            svr_pkg::svr_random_sequence#(32) svr_port_random_port_p_w_0_seq;

            string file_queue_p_w_1 [$];                                                         
            integer bitwidth_queue_p_w_1 [$];                                                    
                                                                                                               
            svr_pkg::svr_master_sequence#(32) svr_port_p_w_1_seq;            
            svr_pkg::svr_random_sequence#(32) svr_port_random_port_p_w_1_seq;

            string file_queue_p_w_2 [$];                                                         
            integer bitwidth_queue_p_w_2 [$];                                                    
                                                                                                               
            svr_pkg::svr_master_sequence#(32) svr_port_p_w_2_seq;            
            svr_pkg::svr_random_sequence#(32) svr_port_random_port_p_w_2_seq;

            string file_queue_p_w_3 [$];                                                         
            integer bitwidth_queue_p_w_3 [$];                                                    
                                                                                                               
            svr_pkg::svr_master_sequence#(32) svr_port_p_w_3_seq;            
            svr_pkg::svr_random_sequence#(32) svr_port_random_port_p_w_3_seq;

            string file_queue_m_w [$];                                                         
            integer bitwidth_queue_m_w [$];                                                    
                                                                                                               
            svr_pkg::svr_master_sequence#(32) svr_port_m_w_seq;            
            svr_pkg::svr_random_sequence#(32) svr_port_random_port_m_w_seq;

            svr_pkg::svr_slave_sequence #(32) svr_port_p_pred_0_seq;            

            svr_pkg::svr_slave_sequence #(32) svr_port_p_pred_1_seq;            

            svr_pkg::svr_slave_sequence #(32) svr_port_p_pred_2_seq;            

            svr_pkg::svr_slave_sequence #(32) svr_port_p_pred_3_seq;            

            svr_pkg::svr_slave_sequence #(32) svr_port_m_pred_seq;            


            if (!uvm_config_db#(predict_kernel_reference_model)::get(p_sequencer,"", "refm", refm))
                `uvm_fatal(this.get_full_name(), "No reference model")
            `uvm_info(this.get_full_name(), "get reference model by uvm_config_db", UVM_LOW)

            `uvm_info(this.get_full_name(), "body is called", UVM_LOW)
            starting_phase = this.get_starting_phase();
            if (starting_phase != null) begin
                `uvm_info(this.get_full_name(), "starting_phase not null", UVM_LOW)
                starting_phase.raise_objection(this);
            end
            else
                `uvm_info(this.get_full_name(), "starting_phase null" , UVM_LOW)

            misc_if = refm.misc_if;


            //phase_done.set_drain_time(this, 0ns);
            wait(refm.misc_if.reset === 0);
            ->refm.misc_if.initialed_evt;

            fork
                begin
                    fork
                        begin
                            string keystr_delay;
                            file_queue_p_x_0.push_back(`AUTOTB_TVIN_p_x_0_p_x_0);
                            bitwidth_queue_p_x_0.push_back(32);

                            `uvm_create_on(svr_port_p_x_0_seq, p_sequencer.svr_port_p_x_0_sqr);
                            svr_port_p_x_0_seq.misc_if = refm.misc_if;
                            svr_port_p_x_0_seq.ap_done  = refm.ap_done_for_nexttrans ;
                            svr_port_p_x_0_seq.ap_ready = refm.ap_ready_for_nexttrans;
                            svr_port_p_x_0_seq.finish   = refm.finish;
                            svr_port_p_x_0_seq.file_rd.config_file(file_queue_p_x_0, bitwidth_queue_p_x_0);
                            if( refm.predict_kernel_cfg.port_p_x_0_cfg.prt_type == AP_VLD ) wait(refm.misc_if.tb2dut_ap_start === 1'b1);
                            svr_port_p_x_0_seq.isusr_delay = svr_pkg::NO_DELAY;
                            `uvm_send(svr_port_p_x_0_seq);     
                        end                                               
                        begin
                            string keystr_delay;
                            file_queue_p_x_1.push_back(`AUTOTB_TVIN_p_x_1_p_x_1);
                            bitwidth_queue_p_x_1.push_back(32);

                            `uvm_create_on(svr_port_p_x_1_seq, p_sequencer.svr_port_p_x_1_sqr);
                            svr_port_p_x_1_seq.misc_if = refm.misc_if;
                            svr_port_p_x_1_seq.ap_done  = refm.ap_done_for_nexttrans ;
                            svr_port_p_x_1_seq.ap_ready = refm.ap_ready_for_nexttrans;
                            svr_port_p_x_1_seq.finish   = refm.finish;
                            svr_port_p_x_1_seq.file_rd.config_file(file_queue_p_x_1, bitwidth_queue_p_x_1);
                            if( refm.predict_kernel_cfg.port_p_x_1_cfg.prt_type == AP_VLD ) wait(refm.misc_if.tb2dut_ap_start === 1'b1);
                            svr_port_p_x_1_seq.isusr_delay = svr_pkg::NO_DELAY;
                            `uvm_send(svr_port_p_x_1_seq);     
                        end                                               
                        begin
                            string keystr_delay;
                            file_queue_p_x_2.push_back(`AUTOTB_TVIN_p_x_2_p_x_2);
                            bitwidth_queue_p_x_2.push_back(32);

                            `uvm_create_on(svr_port_p_x_2_seq, p_sequencer.svr_port_p_x_2_sqr);
                            svr_port_p_x_2_seq.misc_if = refm.misc_if;
                            svr_port_p_x_2_seq.ap_done  = refm.ap_done_for_nexttrans ;
                            svr_port_p_x_2_seq.ap_ready = refm.ap_ready_for_nexttrans;
                            svr_port_p_x_2_seq.finish   = refm.finish;
                            svr_port_p_x_2_seq.file_rd.config_file(file_queue_p_x_2, bitwidth_queue_p_x_2);
                            if( refm.predict_kernel_cfg.port_p_x_2_cfg.prt_type == AP_VLD ) wait(refm.misc_if.tb2dut_ap_start === 1'b1);
                            svr_port_p_x_2_seq.isusr_delay = svr_pkg::NO_DELAY;
                            `uvm_send(svr_port_p_x_2_seq);     
                        end                                               
                        begin
                            string keystr_delay;
                            file_queue_p_x_3.push_back(`AUTOTB_TVIN_p_x_3_p_x_3);
                            bitwidth_queue_p_x_3.push_back(32);

                            `uvm_create_on(svr_port_p_x_3_seq, p_sequencer.svr_port_p_x_3_sqr);
                            svr_port_p_x_3_seq.misc_if = refm.misc_if;
                            svr_port_p_x_3_seq.ap_done  = refm.ap_done_for_nexttrans ;
                            svr_port_p_x_3_seq.ap_ready = refm.ap_ready_for_nexttrans;
                            svr_port_p_x_3_seq.finish   = refm.finish;
                            svr_port_p_x_3_seq.file_rd.config_file(file_queue_p_x_3, bitwidth_queue_p_x_3);
                            if( refm.predict_kernel_cfg.port_p_x_3_cfg.prt_type == AP_VLD ) wait(refm.misc_if.tb2dut_ap_start === 1'b1);
                            svr_port_p_x_3_seq.isusr_delay = svr_pkg::NO_DELAY;
                            `uvm_send(svr_port_p_x_3_seq);     
                        end                                               
                        begin
                            string keystr_delay;
                            file_queue_m_x.push_back(`AUTOTB_TVIN_m_x_m_x);
                            bitwidth_queue_m_x.push_back(32);

                            `uvm_create_on(svr_port_m_x_seq, p_sequencer.svr_port_m_x_sqr);
                            svr_port_m_x_seq.misc_if = refm.misc_if;
                            svr_port_m_x_seq.ap_done  = refm.ap_done_for_nexttrans ;
                            svr_port_m_x_seq.ap_ready = refm.ap_ready_for_nexttrans;
                            svr_port_m_x_seq.finish   = refm.finish;
                            svr_port_m_x_seq.file_rd.config_file(file_queue_m_x, bitwidth_queue_m_x);
                            if( refm.predict_kernel_cfg.port_m_x_cfg.prt_type == AP_VLD ) wait(refm.misc_if.tb2dut_ap_start === 1'b1);
                            svr_port_m_x_seq.isusr_delay = svr_pkg::NO_DELAY;
                            `uvm_send(svr_port_m_x_seq);     
                        end                                               
                        begin
                            string keystr_delay;
                            file_queue_p_w_0.push_back(`AUTOTB_TVIN_p_w_0_p_w_0);
                            bitwidth_queue_p_w_0.push_back(32);

                            `uvm_create_on(svr_port_p_w_0_seq, p_sequencer.svr_port_p_w_0_sqr);
                            svr_port_p_w_0_seq.misc_if = refm.misc_if;
                            svr_port_p_w_0_seq.ap_done  = refm.ap_done_for_nexttrans ;
                            svr_port_p_w_0_seq.ap_ready = refm.ap_ready_for_nexttrans;
                            svr_port_p_w_0_seq.finish   = refm.finish;
                            svr_port_p_w_0_seq.file_rd.config_file(file_queue_p_w_0, bitwidth_queue_p_w_0);
                            if( refm.predict_kernel_cfg.port_p_w_0_cfg.prt_type == AP_VLD ) wait(refm.misc_if.tb2dut_ap_start === 1'b1);
                            svr_port_p_w_0_seq.isusr_delay = svr_pkg::NO_DELAY;
                            `uvm_send(svr_port_p_w_0_seq);     
                        end                                               
                        begin
                            string keystr_delay;
                            file_queue_p_w_1.push_back(`AUTOTB_TVIN_p_w_1_p_w_1);
                            bitwidth_queue_p_w_1.push_back(32);

                            `uvm_create_on(svr_port_p_w_1_seq, p_sequencer.svr_port_p_w_1_sqr);
                            svr_port_p_w_1_seq.misc_if = refm.misc_if;
                            svr_port_p_w_1_seq.ap_done  = refm.ap_done_for_nexttrans ;
                            svr_port_p_w_1_seq.ap_ready = refm.ap_ready_for_nexttrans;
                            svr_port_p_w_1_seq.finish   = refm.finish;
                            svr_port_p_w_1_seq.file_rd.config_file(file_queue_p_w_1, bitwidth_queue_p_w_1);
                            if( refm.predict_kernel_cfg.port_p_w_1_cfg.prt_type == AP_VLD ) wait(refm.misc_if.tb2dut_ap_start === 1'b1);
                            svr_port_p_w_1_seq.isusr_delay = svr_pkg::NO_DELAY;
                            `uvm_send(svr_port_p_w_1_seq);     
                        end                                               
                        begin
                            string keystr_delay;
                            file_queue_p_w_2.push_back(`AUTOTB_TVIN_p_w_2_p_w_2);
                            bitwidth_queue_p_w_2.push_back(32);

                            `uvm_create_on(svr_port_p_w_2_seq, p_sequencer.svr_port_p_w_2_sqr);
                            svr_port_p_w_2_seq.misc_if = refm.misc_if;
                            svr_port_p_w_2_seq.ap_done  = refm.ap_done_for_nexttrans ;
                            svr_port_p_w_2_seq.ap_ready = refm.ap_ready_for_nexttrans;
                            svr_port_p_w_2_seq.finish   = refm.finish;
                            svr_port_p_w_2_seq.file_rd.config_file(file_queue_p_w_2, bitwidth_queue_p_w_2);
                            if( refm.predict_kernel_cfg.port_p_w_2_cfg.prt_type == AP_VLD ) wait(refm.misc_if.tb2dut_ap_start === 1'b1);
                            svr_port_p_w_2_seq.isusr_delay = svr_pkg::NO_DELAY;
                            `uvm_send(svr_port_p_w_2_seq);     
                        end                                               
                        begin
                            string keystr_delay;
                            file_queue_p_w_3.push_back(`AUTOTB_TVIN_p_w_3_p_w_3);
                            bitwidth_queue_p_w_3.push_back(32);

                            `uvm_create_on(svr_port_p_w_3_seq, p_sequencer.svr_port_p_w_3_sqr);
                            svr_port_p_w_3_seq.misc_if = refm.misc_if;
                            svr_port_p_w_3_seq.ap_done  = refm.ap_done_for_nexttrans ;
                            svr_port_p_w_3_seq.ap_ready = refm.ap_ready_for_nexttrans;
                            svr_port_p_w_3_seq.finish   = refm.finish;
                            svr_port_p_w_3_seq.file_rd.config_file(file_queue_p_w_3, bitwidth_queue_p_w_3);
                            if( refm.predict_kernel_cfg.port_p_w_3_cfg.prt_type == AP_VLD ) wait(refm.misc_if.tb2dut_ap_start === 1'b1);
                            svr_port_p_w_3_seq.isusr_delay = svr_pkg::NO_DELAY;
                            `uvm_send(svr_port_p_w_3_seq);     
                        end                                               
                        begin
                            string keystr_delay;
                            file_queue_m_w.push_back(`AUTOTB_TVIN_m_w_m_w);
                            bitwidth_queue_m_w.push_back(32);

                            `uvm_create_on(svr_port_m_w_seq, p_sequencer.svr_port_m_w_sqr);
                            svr_port_m_w_seq.misc_if = refm.misc_if;
                            svr_port_m_w_seq.ap_done  = refm.ap_done_for_nexttrans ;
                            svr_port_m_w_seq.ap_ready = refm.ap_ready_for_nexttrans;
                            svr_port_m_w_seq.finish   = refm.finish;
                            svr_port_m_w_seq.file_rd.config_file(file_queue_m_w, bitwidth_queue_m_w);
                            if( refm.predict_kernel_cfg.port_m_w_cfg.prt_type == AP_VLD ) wait(refm.misc_if.tb2dut_ap_start === 1'b1);
                            svr_port_m_w_seq.isusr_delay = svr_pkg::NO_DELAY;
                            `uvm_send(svr_port_m_w_seq);     
                        end                                               
                        begin
                            string keystr_delay;
                            `uvm_create_on(svr_port_p_pred_0_seq, p_sequencer.svr_port_p_pred_0_sqr);
                            svr_port_p_pred_0_seq.misc_if = refm.misc_if;
                            svr_port_p_pred_0_seq.ap_done  = refm.ap_done_for_nexttrans ;
                            svr_port_p_pred_0_seq.ap_ready = refm.ap_ready_for_nexttrans;
                            svr_port_p_pred_0_seq.finish   = refm.finish;
                            svr_port_p_pred_0_seq.isusr_delay = svr_pkg::NO_DELAY;
                            `uvm_send(svr_port_p_pred_0_seq);     
                        end                                               
                        begin
                            string keystr_delay;
                            `uvm_create_on(svr_port_p_pred_1_seq, p_sequencer.svr_port_p_pred_1_sqr);
                            svr_port_p_pred_1_seq.misc_if = refm.misc_if;
                            svr_port_p_pred_1_seq.ap_done  = refm.ap_done_for_nexttrans ;
                            svr_port_p_pred_1_seq.ap_ready = refm.ap_ready_for_nexttrans;
                            svr_port_p_pred_1_seq.finish   = refm.finish;
                            svr_port_p_pred_1_seq.isusr_delay = svr_pkg::NO_DELAY;
                            `uvm_send(svr_port_p_pred_1_seq);     
                        end                                               
                        begin
                            string keystr_delay;
                            `uvm_create_on(svr_port_p_pred_2_seq, p_sequencer.svr_port_p_pred_2_sqr);
                            svr_port_p_pred_2_seq.misc_if = refm.misc_if;
                            svr_port_p_pred_2_seq.ap_done  = refm.ap_done_for_nexttrans ;
                            svr_port_p_pred_2_seq.ap_ready = refm.ap_ready_for_nexttrans;
                            svr_port_p_pred_2_seq.finish   = refm.finish;
                            svr_port_p_pred_2_seq.isusr_delay = svr_pkg::NO_DELAY;
                            `uvm_send(svr_port_p_pred_2_seq);     
                        end                                               
                        begin
                            string keystr_delay;
                            `uvm_create_on(svr_port_p_pred_3_seq, p_sequencer.svr_port_p_pred_3_sqr);
                            svr_port_p_pred_3_seq.misc_if = refm.misc_if;
                            svr_port_p_pred_3_seq.ap_done  = refm.ap_done_for_nexttrans ;
                            svr_port_p_pred_3_seq.ap_ready = refm.ap_ready_for_nexttrans;
                            svr_port_p_pred_3_seq.finish   = refm.finish;
                            svr_port_p_pred_3_seq.isusr_delay = svr_pkg::NO_DELAY;
                            `uvm_send(svr_port_p_pred_3_seq);     
                        end                                               
                        begin
                            string keystr_delay;
                            `uvm_create_on(svr_port_m_pred_seq, p_sequencer.svr_port_m_pred_sqr);
                            svr_port_m_pred_seq.misc_if = refm.misc_if;
                            svr_port_m_pred_seq.ap_done  = refm.ap_done_for_nexttrans ;
                            svr_port_m_pred_seq.ap_ready = refm.ap_ready_for_nexttrans;
                            svr_port_m_pred_seq.finish   = refm.finish;
                            svr_port_m_pred_seq.isusr_delay = svr_pkg::NO_DELAY;
                            `uvm_send(svr_port_m_pred_seq);     
                        end                                               
                        begin
                            wait(svr_port_p_x_0_seq&&svr_port_p_x_1_seq&&svr_port_p_x_2_seq&&svr_port_p_x_3_seq&&svr_port_m_x_seq&&svr_port_p_w_0_seq&&svr_port_p_w_1_seq&&svr_port_p_w_2_seq&&svr_port_p_w_3_seq&&svr_port_m_w_seq);
                            forever begin
                                wait(svr_port_p_x_0_seq.one_sect_read&&svr_port_p_x_1_seq.one_sect_read&&svr_port_p_x_2_seq.one_sect_read&&svr_port_p_x_3_seq.one_sect_read&&svr_port_m_x_seq.one_sect_read&&svr_port_p_w_0_seq.one_sect_read&&svr_port_p_w_1_seq.one_sect_read&&svr_port_p_w_2_seq.one_sect_read&&svr_port_p_w_3_seq.one_sect_read&&svr_port_m_w_seq.one_sect_read);
                                svr_port_p_x_0_seq.one_sect_read = 0;
                                svr_port_p_x_1_seq.one_sect_read = 0;
                                svr_port_p_x_2_seq.one_sect_read = 0;
                                svr_port_p_x_3_seq.one_sect_read = 0;
                                svr_port_m_x_seq.one_sect_read = 0;
                                svr_port_p_w_0_seq.one_sect_read = 0;
                                svr_port_p_w_1_seq.one_sect_read = 0;
                                svr_port_p_w_2_seq.one_sect_read = 0;
                                svr_port_p_w_3_seq.one_sect_read = 0;
                                svr_port_m_w_seq.one_sect_read = 0;
                                -> refm.allsvr_input_done;
                            end
                        end
                        begin
                            int delay;
                            repeat(3) @(posedge refm.misc_if.clock);
                            for(int j=0; j<60; j++) begin
                                #0; refm.misc_if.tb2dut_ap_start = 1;
                                fork
                                    begin
                                        @(refm.dut2tb_ap_done);
                                    end
                                    begin
                                        @(refm.dut2tb_ap_ready);
                                        #0; refm.misc_if.tb2dut_ap_start = 0;
                                    end
                                join
                                void'(std::randomize(delay) with { delay == 0; });
                                repeat(delay) @(posedge refm.misc_if.clock);
                            end
                        end
                        begin
                            int delay;
                            for(int j=0; j<60; j=j+refm.ap_done_cnt) begin
                                @refm.dut2tb_ap_done;
                                #0; refm.misc_if.tb2dut_ap_continue = 0;
                            end
                        end
                    join
                end

                begin
                    for(int j=0; j<60; j=j+refm.ap_done_cnt) @refm.ap_done_for_nexttrans;
                    `uvm_info(this.get_full_name(), "autotb finished", UVM_LOW)
                    -> refm.finish;
                    refm.misc_if.finished = 1;
                    @(posedge refm.misc_if.clock);
                    refm.misc_if.finished = 0;
                    @(posedge refm.misc_if.clock);
                    -> refm.misc_if.finished_evt;
                end
            join_any
            repeat(5) @(posedge refm.misc_if.clock); //5 cycles delay for finish stuff. 5 is haphazard value

            p_sequencer.svr_port_p_x_0_sqr.stop_sequences();
            p_sequencer.svr_port_p_x_1_sqr.stop_sequences();
            p_sequencer.svr_port_p_x_2_sqr.stop_sequences();
            p_sequencer.svr_port_p_x_3_sqr.stop_sequences();
            p_sequencer.svr_port_m_x_sqr.stop_sequences();
            p_sequencer.svr_port_p_w_0_sqr.stop_sequences();
            p_sequencer.svr_port_p_w_1_sqr.stop_sequences();
            p_sequencer.svr_port_p_w_2_sqr.stop_sequences();
            p_sequencer.svr_port_p_w_3_sqr.stop_sequences();
            p_sequencer.svr_port_m_w_sqr.stop_sequences();
            p_sequencer.svr_port_p_pred_0_sqr.stop_sequences();
            p_sequencer.svr_port_p_pred_1_sqr.stop_sequences();
            p_sequencer.svr_port_p_pred_2_sqr.stop_sequences();
            p_sequencer.svr_port_p_pred_3_sqr.stop_sequences();
            p_sequencer.svr_port_m_pred_sqr.stop_sequences();
            disable fork;
                                                                                                    
            starting_phase.drop_objection(this);                                                    
                                                                                                    
        endtask                                                                                     
    endclass                                                                                        
                                                                                                    
`endif                                                                                              
