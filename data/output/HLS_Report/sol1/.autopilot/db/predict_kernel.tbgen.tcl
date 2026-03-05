set moduleName predict_kernel
set isTopModule 1
set isCombinational 0
set isDatapathOnly 0
set isPipelined 0
set isPipelined_legacy 0
set pipeline_type none
set FunctionProtocol ap_ctrl_hs
set restart_counter_num 0
set isOneStateSeq 0
set ProfileFlag 0
set StallSigGenFlag 0
set isEnableWaveformDebug 1
set hasInterrupt 0
set DLRegFirstOffset 0
set DLRegItemOffset 0
set svuvm_can_support 1
set cdfgNum 6
set C_modelName {predict_kernel}
set C_modelType { void 0 }
set ap_memory_interface_dict [dict create]
dict set ap_memory_interface_dict H_x_0 { MEM_WIDTH 32 MEM_SIZE 128 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 1 }
dict set ap_memory_interface_dict H_x_1 { MEM_WIDTH 32 MEM_SIZE 128 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 1 }
dict set ap_memory_interface_dict H_x_2 { MEM_WIDTH 32 MEM_SIZE 128 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 1 }
dict set ap_memory_interface_dict H_x_3 { MEM_WIDTH 32 MEM_SIZE 128 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 1 }
dict set ap_memory_interface_dict A_0 { MEM_WIDTH 32 MEM_SIZE 16 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 1 }
dict set ap_memory_interface_dict A_1 { MEM_WIDTH 32 MEM_SIZE 16 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 1 }
dict set ap_memory_interface_dict A_2 { MEM_WIDTH 32 MEM_SIZE 16 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 1 }
dict set ap_memory_interface_dict A_3 { MEM_WIDTH 32 MEM_SIZE 16 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 1 }
dict set ap_memory_interface_dict H_w_0 { MEM_WIDTH 32 MEM_SIZE 128 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 1 }
dict set ap_memory_interface_dict H_w_1 { MEM_WIDTH 32 MEM_SIZE 128 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 1 }
dict set ap_memory_interface_dict H_w_2 { MEM_WIDTH 32 MEM_SIZE 128 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 1 }
dict set ap_memory_interface_dict H_w_3 { MEM_WIDTH 32 MEM_SIZE 128 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 1 }
dict set ap_memory_interface_dict H_pred_0 { MEM_WIDTH 32 MEM_SIZE 128 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 1 }
dict set ap_memory_interface_dict H_pred_1 { MEM_WIDTH 32 MEM_SIZE 128 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 1 }
dict set ap_memory_interface_dict H_pred_2 { MEM_WIDTH 32 MEM_SIZE 128 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 1 }
dict set ap_memory_interface_dict H_pred_3 { MEM_WIDTH 32 MEM_SIZE 128 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 1 }
set C_modelArgList {
	{ p_x_0 int 32 regular {pointer 0}  }
	{ p_x_1 int 32 regular {pointer 0}  }
	{ p_x_2 int 32 regular {pointer 0}  }
	{ p_x_3 int 32 regular {pointer 0}  }
	{ H_x_0 int 32 regular {array 32 { 1 3 } 1 1 }  }
	{ H_x_1 int 32 regular {array 32 { 1 3 } 1 1 }  }
	{ H_x_2 int 32 regular {array 32 { 1 3 } 1 1 }  }
	{ H_x_3 int 32 regular {array 32 { 1 3 } 1 1 }  }
	{ m_x int 32 regular  }
	{ A_0 int 32 regular {array 4 { 1 3 } 1 1 }  }
	{ A_1 int 32 regular {array 4 { 1 3 } 1 1 }  }
	{ A_2 int 32 regular {array 4 { 1 3 } 1 1 }  }
	{ A_3 int 32 regular {array 4 { 1 3 } 1 1 }  }
	{ p_w_0 int 32 regular {pointer 0}  }
	{ p_w_1 int 32 regular {pointer 0}  }
	{ p_w_2 int 32 regular {pointer 0}  }
	{ p_w_3 int 32 regular {pointer 0}  }
	{ H_w_0 int 32 regular {array 32 { 1 3 } 1 1 }  }
	{ H_w_1 int 32 regular {array 32 { 1 3 } 1 1 }  }
	{ H_w_2 int 32 regular {array 32 { 1 3 } 1 1 }  }
	{ H_w_3 int 32 regular {array 32 { 1 3 } 1 1 }  }
	{ m_w int 32 regular  }
	{ p_pred_0 int 32 regular {pointer 1}  }
	{ p_pred_1 int 32 regular {pointer 1}  }
	{ p_pred_2 int 32 regular {pointer 1}  }
	{ p_pred_3 int 32 regular {pointer 1}  }
	{ H_pred_0 int 32 regular {array 32 { 0 3 } 0 1 }  }
	{ H_pred_1 int 32 regular {array 32 { 0 3 } 0 1 }  }
	{ H_pred_2 int 32 regular {array 32 { 0 3 } 0 1 }  }
	{ H_pred_3 int 32 regular {array 32 { 0 3 } 0 1 }  }
	{ m_pred int 32 regular {pointer 1}  }
}
set hasAXIMCache 0
set l_AXIML2Cache [list]
set AXIMCacheInstDict [dict create]
set C_modelArgMapList {[ 
	{ "Name" : "p_x_0", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "p_x_1", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "p_x_2", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "p_x_3", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "H_x_0", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "H_x_1", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "H_x_2", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "H_x_3", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "m_x", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "A_0", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "A_1", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "A_2", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "A_3", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "p_w_0", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "p_w_1", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "p_w_2", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "p_w_3", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "H_w_0", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "H_w_1", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "H_w_2", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "H_w_3", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "m_w", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "p_pred_0", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_pred_1", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_pred_2", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_pred_3", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "H_pred_0", "interface" : "memory", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "H_pred_1", "interface" : "memory", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "H_pred_2", "interface" : "memory", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "H_pred_3", "interface" : "memory", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "m_pred", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} ]}
# RTL Port declarations: 
set portNum 78
set portList { 
	{ ap_clk sc_in sc_logic 1 clock -1 } 
	{ ap_rst sc_in sc_logic 1 reset -1 active_high_sync } 
	{ ap_start sc_in sc_logic 1 start -1 } 
	{ ap_done sc_out sc_logic 1 predone -1 } 
	{ ap_idle sc_out sc_logic 1 done -1 } 
	{ ap_ready sc_out sc_logic 1 ready -1 } 
	{ p_x_0 sc_in sc_lv 32 signal 0 } 
	{ p_x_1 sc_in sc_lv 32 signal 1 } 
	{ p_x_2 sc_in sc_lv 32 signal 2 } 
	{ p_x_3 sc_in sc_lv 32 signal 3 } 
	{ H_x_0_address0 sc_out sc_lv 5 signal 4 } 
	{ H_x_0_ce0 sc_out sc_logic 1 signal 4 } 
	{ H_x_0_q0 sc_in sc_lv 32 signal 4 } 
	{ H_x_1_address0 sc_out sc_lv 5 signal 5 } 
	{ H_x_1_ce0 sc_out sc_logic 1 signal 5 } 
	{ H_x_1_q0 sc_in sc_lv 32 signal 5 } 
	{ H_x_2_address0 sc_out sc_lv 5 signal 6 } 
	{ H_x_2_ce0 sc_out sc_logic 1 signal 6 } 
	{ H_x_2_q0 sc_in sc_lv 32 signal 6 } 
	{ H_x_3_address0 sc_out sc_lv 5 signal 7 } 
	{ H_x_3_ce0 sc_out sc_logic 1 signal 7 } 
	{ H_x_3_q0 sc_in sc_lv 32 signal 7 } 
	{ m_x sc_in sc_lv 32 signal 8 } 
	{ A_0_address0 sc_out sc_lv 2 signal 9 } 
	{ A_0_ce0 sc_out sc_logic 1 signal 9 } 
	{ A_0_q0 sc_in sc_lv 32 signal 9 } 
	{ A_1_address0 sc_out sc_lv 2 signal 10 } 
	{ A_1_ce0 sc_out sc_logic 1 signal 10 } 
	{ A_1_q0 sc_in sc_lv 32 signal 10 } 
	{ A_2_address0 sc_out sc_lv 2 signal 11 } 
	{ A_2_ce0 sc_out sc_logic 1 signal 11 } 
	{ A_2_q0 sc_in sc_lv 32 signal 11 } 
	{ A_3_address0 sc_out sc_lv 2 signal 12 } 
	{ A_3_ce0 sc_out sc_logic 1 signal 12 } 
	{ A_3_q0 sc_in sc_lv 32 signal 12 } 
	{ p_w_0 sc_in sc_lv 32 signal 13 } 
	{ p_w_1 sc_in sc_lv 32 signal 14 } 
	{ p_w_2 sc_in sc_lv 32 signal 15 } 
	{ p_w_3 sc_in sc_lv 32 signal 16 } 
	{ H_w_0_address0 sc_out sc_lv 5 signal 17 } 
	{ H_w_0_ce0 sc_out sc_logic 1 signal 17 } 
	{ H_w_0_q0 sc_in sc_lv 32 signal 17 } 
	{ H_w_1_address0 sc_out sc_lv 5 signal 18 } 
	{ H_w_1_ce0 sc_out sc_logic 1 signal 18 } 
	{ H_w_1_q0 sc_in sc_lv 32 signal 18 } 
	{ H_w_2_address0 sc_out sc_lv 5 signal 19 } 
	{ H_w_2_ce0 sc_out sc_logic 1 signal 19 } 
	{ H_w_2_q0 sc_in sc_lv 32 signal 19 } 
	{ H_w_3_address0 sc_out sc_lv 5 signal 20 } 
	{ H_w_3_ce0 sc_out sc_logic 1 signal 20 } 
	{ H_w_3_q0 sc_in sc_lv 32 signal 20 } 
	{ m_w sc_in sc_lv 32 signal 21 } 
	{ p_pred_0 sc_out sc_lv 32 signal 22 } 
	{ p_pred_0_ap_vld sc_out sc_logic 1 outvld 22 } 
	{ p_pred_1 sc_out sc_lv 32 signal 23 } 
	{ p_pred_1_ap_vld sc_out sc_logic 1 outvld 23 } 
	{ p_pred_2 sc_out sc_lv 32 signal 24 } 
	{ p_pred_2_ap_vld sc_out sc_logic 1 outvld 24 } 
	{ p_pred_3 sc_out sc_lv 32 signal 25 } 
	{ p_pred_3_ap_vld sc_out sc_logic 1 outvld 25 } 
	{ H_pred_0_address0 sc_out sc_lv 5 signal 26 } 
	{ H_pred_0_ce0 sc_out sc_logic 1 signal 26 } 
	{ H_pred_0_we0 sc_out sc_logic 1 signal 26 } 
	{ H_pred_0_d0 sc_out sc_lv 32 signal 26 } 
	{ H_pred_1_address0 sc_out sc_lv 5 signal 27 } 
	{ H_pred_1_ce0 sc_out sc_logic 1 signal 27 } 
	{ H_pred_1_we0 sc_out sc_logic 1 signal 27 } 
	{ H_pred_1_d0 sc_out sc_lv 32 signal 27 } 
	{ H_pred_2_address0 sc_out sc_lv 5 signal 28 } 
	{ H_pred_2_ce0 sc_out sc_logic 1 signal 28 } 
	{ H_pred_2_we0 sc_out sc_logic 1 signal 28 } 
	{ H_pred_2_d0 sc_out sc_lv 32 signal 28 } 
	{ H_pred_3_address0 sc_out sc_lv 5 signal 29 } 
	{ H_pred_3_ce0 sc_out sc_logic 1 signal 29 } 
	{ H_pred_3_we0 sc_out sc_logic 1 signal 29 } 
	{ H_pred_3_d0 sc_out sc_lv 32 signal 29 } 
	{ m_pred sc_out sc_lv 32 signal 30 } 
	{ m_pred_ap_vld sc_out sc_logic 1 outvld 30 } 
}
set NewPortList {[ 
	{ "name": "ap_clk", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "clock", "bundle":{"name": "ap_clk", "role": "default" }} , 
 	{ "name": "ap_rst", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "reset", "bundle":{"name": "ap_rst", "role": "default" }} , 
 	{ "name": "ap_start", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "start", "bundle":{"name": "ap_start", "role": "default" }} , 
 	{ "name": "ap_done", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "predone", "bundle":{"name": "ap_done", "role": "default" }} , 
 	{ "name": "ap_idle", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "done", "bundle":{"name": "ap_idle", "role": "default" }} , 
 	{ "name": "ap_ready", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "ready", "bundle":{"name": "ap_ready", "role": "default" }} , 
 	{ "name": "p_x_0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_x_0", "role": "default" }} , 
 	{ "name": "p_x_1", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_x_1", "role": "default" }} , 
 	{ "name": "p_x_2", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_x_2", "role": "default" }} , 
 	{ "name": "p_x_3", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_x_3", "role": "default" }} , 
 	{ "name": "H_x_0_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":5, "type": "signal", "bundle":{"name": "H_x_0", "role": "address0" }} , 
 	{ "name": "H_x_0_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "H_x_0", "role": "ce0" }} , 
 	{ "name": "H_x_0_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "H_x_0", "role": "q0" }} , 
 	{ "name": "H_x_1_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":5, "type": "signal", "bundle":{"name": "H_x_1", "role": "address0" }} , 
 	{ "name": "H_x_1_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "H_x_1", "role": "ce0" }} , 
 	{ "name": "H_x_1_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "H_x_1", "role": "q0" }} , 
 	{ "name": "H_x_2_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":5, "type": "signal", "bundle":{"name": "H_x_2", "role": "address0" }} , 
 	{ "name": "H_x_2_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "H_x_2", "role": "ce0" }} , 
 	{ "name": "H_x_2_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "H_x_2", "role": "q0" }} , 
 	{ "name": "H_x_3_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":5, "type": "signal", "bundle":{"name": "H_x_3", "role": "address0" }} , 
 	{ "name": "H_x_3_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "H_x_3", "role": "ce0" }} , 
 	{ "name": "H_x_3_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "H_x_3", "role": "q0" }} , 
 	{ "name": "m_x", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "m_x", "role": "default" }} , 
 	{ "name": "A_0_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "A_0", "role": "address0" }} , 
 	{ "name": "A_0_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "A_0", "role": "ce0" }} , 
 	{ "name": "A_0_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "A_0", "role": "q0" }} , 
 	{ "name": "A_1_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "A_1", "role": "address0" }} , 
 	{ "name": "A_1_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "A_1", "role": "ce0" }} , 
 	{ "name": "A_1_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "A_1", "role": "q0" }} , 
 	{ "name": "A_2_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "A_2", "role": "address0" }} , 
 	{ "name": "A_2_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "A_2", "role": "ce0" }} , 
 	{ "name": "A_2_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "A_2", "role": "q0" }} , 
 	{ "name": "A_3_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "A_3", "role": "address0" }} , 
 	{ "name": "A_3_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "A_3", "role": "ce0" }} , 
 	{ "name": "A_3_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "A_3", "role": "q0" }} , 
 	{ "name": "p_w_0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_w_0", "role": "default" }} , 
 	{ "name": "p_w_1", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_w_1", "role": "default" }} , 
 	{ "name": "p_w_2", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_w_2", "role": "default" }} , 
 	{ "name": "p_w_3", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_w_3", "role": "default" }} , 
 	{ "name": "H_w_0_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":5, "type": "signal", "bundle":{"name": "H_w_0", "role": "address0" }} , 
 	{ "name": "H_w_0_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "H_w_0", "role": "ce0" }} , 
 	{ "name": "H_w_0_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "H_w_0", "role": "q0" }} , 
 	{ "name": "H_w_1_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":5, "type": "signal", "bundle":{"name": "H_w_1", "role": "address0" }} , 
 	{ "name": "H_w_1_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "H_w_1", "role": "ce0" }} , 
 	{ "name": "H_w_1_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "H_w_1", "role": "q0" }} , 
 	{ "name": "H_w_2_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":5, "type": "signal", "bundle":{"name": "H_w_2", "role": "address0" }} , 
 	{ "name": "H_w_2_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "H_w_2", "role": "ce0" }} , 
 	{ "name": "H_w_2_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "H_w_2", "role": "q0" }} , 
 	{ "name": "H_w_3_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":5, "type": "signal", "bundle":{"name": "H_w_3", "role": "address0" }} , 
 	{ "name": "H_w_3_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "H_w_3", "role": "ce0" }} , 
 	{ "name": "H_w_3_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "H_w_3", "role": "q0" }} , 
 	{ "name": "m_w", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "m_w", "role": "default" }} , 
 	{ "name": "p_pred_0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_pred_0", "role": "default" }} , 
 	{ "name": "p_pred_0_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_pred_0", "role": "ap_vld" }} , 
 	{ "name": "p_pred_1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_pred_1", "role": "default" }} , 
 	{ "name": "p_pred_1_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_pred_1", "role": "ap_vld" }} , 
 	{ "name": "p_pred_2", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_pred_2", "role": "default" }} , 
 	{ "name": "p_pred_2_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_pred_2", "role": "ap_vld" }} , 
 	{ "name": "p_pred_3", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_pred_3", "role": "default" }} , 
 	{ "name": "p_pred_3_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_pred_3", "role": "ap_vld" }} , 
 	{ "name": "H_pred_0_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":5, "type": "signal", "bundle":{"name": "H_pred_0", "role": "address0" }} , 
 	{ "name": "H_pred_0_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "H_pred_0", "role": "ce0" }} , 
 	{ "name": "H_pred_0_we0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "H_pred_0", "role": "we0" }} , 
 	{ "name": "H_pred_0_d0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "H_pred_0", "role": "d0" }} , 
 	{ "name": "H_pred_1_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":5, "type": "signal", "bundle":{"name": "H_pred_1", "role": "address0" }} , 
 	{ "name": "H_pred_1_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "H_pred_1", "role": "ce0" }} , 
 	{ "name": "H_pred_1_we0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "H_pred_1", "role": "we0" }} , 
 	{ "name": "H_pred_1_d0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "H_pred_1", "role": "d0" }} , 
 	{ "name": "H_pred_2_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":5, "type": "signal", "bundle":{"name": "H_pred_2", "role": "address0" }} , 
 	{ "name": "H_pred_2_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "H_pred_2", "role": "ce0" }} , 
 	{ "name": "H_pred_2_we0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "H_pred_2", "role": "we0" }} , 
 	{ "name": "H_pred_2_d0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "H_pred_2", "role": "d0" }} , 
 	{ "name": "H_pred_3_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":5, "type": "signal", "bundle":{"name": "H_pred_3", "role": "address0" }} , 
 	{ "name": "H_pred_3_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "H_pred_3", "role": "ce0" }} , 
 	{ "name": "H_pred_3_we0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "H_pred_3", "role": "we0" }} , 
 	{ "name": "H_pred_3_d0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "H_pred_3", "role": "d0" }} , 
 	{ "name": "m_pred", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "m_pred", "role": "default" }} , 
 	{ "name": "m_pred_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "m_pred", "role": "ap_vld" }}  ]}

set ArgLastReadFirstWriteLatency {
	predict_kernel {
		p_x_0 {Type I LastRead 0 FirstWrite -1}
		p_x_1 {Type I LastRead 0 FirstWrite -1}
		p_x_2 {Type I LastRead 0 FirstWrite -1}
		p_x_3 {Type I LastRead 0 FirstWrite -1}
		H_x_0 {Type I LastRead 0 FirstWrite -1}
		H_x_1 {Type I LastRead 4 FirstWrite -1}
		H_x_2 {Type I LastRead 8 FirstWrite -1}
		H_x_3 {Type I LastRead 12 FirstWrite -1}
		m_x {Type I LastRead 2 FirstWrite -1}
		A_0 {Type I LastRead 0 FirstWrite -1}
		A_1 {Type I LastRead 4 FirstWrite -1}
		A_2 {Type I LastRead 8 FirstWrite -1}
		A_3 {Type I LastRead 12 FirstWrite -1}
		p_w_0 {Type I LastRead 0 FirstWrite -1}
		p_w_1 {Type I LastRead 0 FirstWrite -1}
		p_w_2 {Type I LastRead 0 FirstWrite -1}
		p_w_3 {Type I LastRead 0 FirstWrite -1}
		H_w_0 {Type I LastRead 0 FirstWrite -1}
		H_w_1 {Type I LastRead 0 FirstWrite -1}
		H_w_2 {Type I LastRead 0 FirstWrite -1}
		H_w_3 {Type I LastRead 0 FirstWrite -1}
		m_w {Type I LastRead 4 FirstWrite -1}
		p_pred_0 {Type O LastRead -1 FirstWrite 19}
		p_pred_1 {Type O LastRead -1 FirstWrite 19}
		p_pred_2 {Type O LastRead -1 FirstWrite 19}
		p_pred_3 {Type O LastRead -1 FirstWrite 19}
		H_pred_0 {Type O LastRead -1 FirstWrite 1}
		H_pred_1 {Type O LastRead -1 FirstWrite 1}
		H_pred_2 {Type O LastRead -1 FirstWrite 1}
		H_pred_3 {Type O LastRead -1 FirstWrite 1}
		m_pred {Type O LastRead -1 FirstWrite 4}}
	predict_kernel_Pipeline_VITIS_LOOP_35_1 {
		p_pred_0 {Type O LastRead -1 FirstWrite 19}
		p_pred_3 {Type O LastRead -1 FirstWrite 19}
		p_pred_2 {Type O LastRead -1 FirstWrite 19}
		p_pred_1 {Type O LastRead -1 FirstWrite 19}
		bitcast_ln37 {Type I LastRead 0 FirstWrite -1}
		bitcast_ln37_1 {Type I LastRead 0 FirstWrite -1}
		bitcast_ln37_2 {Type I LastRead 0 FirstWrite -1}
		bitcast_ln37_3 {Type I LastRead 0 FirstWrite -1}
		A_0 {Type I LastRead 0 FirstWrite -1}
		bitcast_ln40 {Type I LastRead 0 FirstWrite -1}
		A_1 {Type I LastRead 4 FirstWrite -1}
		bitcast_ln40_1 {Type I LastRead 0 FirstWrite -1}
		A_2 {Type I LastRead 8 FirstWrite -1}
		bitcast_ln40_2 {Type I LastRead 0 FirstWrite -1}
		A_3 {Type I LastRead 12 FirstWrite -1}
		bitcast_ln40_3 {Type I LastRead 0 FirstWrite -1}}
	predict_kernel_Pipeline_VITIS_LOOP_45_3_VITIS_LOOP_48_4 {
		tmp_3 {Type I LastRead 0 FirstWrite -1}
		H_x_0 {Type I LastRead 0 FirstWrite -1}
		H_x_1 {Type I LastRead 4 FirstWrite -1}
		H_x_2 {Type I LastRead 8 FirstWrite -1}
		H_x_3 {Type I LastRead 12 FirstWrite -1}
		H_pred_3 {Type O LastRead -1 FirstWrite 19}
		H_pred_0 {Type O LastRead -1 FirstWrite 19}
		H_pred_1 {Type O LastRead -1 FirstWrite 19}
		H_pred_2 {Type O LastRead -1 FirstWrite 19}
		A_0 {Type I LastRead 0 FirstWrite -1}
		A_1 {Type I LastRead 4 FirstWrite -1}
		A_2 {Type I LastRead 8 FirstWrite -1}
		A_3 {Type I LastRead 12 FirstWrite -1}}
	predict_kernel_Pipeline_VITIS_LOOP_59_6_VITIS_LOOP_61_7 {
		tmp_5 {Type I LastRead 0 FirstWrite -1}
		empty {Type I LastRead 0 FirstWrite -1}
		H_w_0 {Type I LastRead 0 FirstWrite -1}
		H_w_1 {Type I LastRead 0 FirstWrite -1}
		H_w_2 {Type I LastRead 0 FirstWrite -1}
		H_w_3 {Type I LastRead 0 FirstWrite -1}
		H_pred_3 {Type O LastRead -1 FirstWrite 1}
		H_pred_0 {Type O LastRead -1 FirstWrite 1}
		H_pred_1 {Type O LastRead -1 FirstWrite 1}
		H_pred_2 {Type O LastRead -1 FirstWrite 1}}}

set hasDtUnsupportedChannel 0

set PerformanceInfo {[
	{"Name" : "Latency", "Min" : "33", "Max" : "307"}
	, {"Name" : "Interval", "Min" : "34", "Max" : "308"}
]}

set PipelineEnableSignalInfo {[
]}

set Spec2ImplPortList { 
	p_x_0 { ap_none {  { p_x_0 in_data 0 32 } } }
	p_x_1 { ap_none {  { p_x_1 in_data 0 32 } } }
	p_x_2 { ap_none {  { p_x_2 in_data 0 32 } } }
	p_x_3 { ap_none {  { p_x_3 in_data 0 32 } } }
	H_x_0 { ap_memory {  { H_x_0_address0 mem_address 1 5 }  { H_x_0_ce0 mem_ce 1 1 }  { H_x_0_q0 mem_dout 0 32 } } }
	H_x_1 { ap_memory {  { H_x_1_address0 mem_address 1 5 }  { H_x_1_ce0 mem_ce 1 1 }  { H_x_1_q0 mem_dout 0 32 } } }
	H_x_2 { ap_memory {  { H_x_2_address0 mem_address 1 5 }  { H_x_2_ce0 mem_ce 1 1 }  { H_x_2_q0 mem_dout 0 32 } } }
	H_x_3 { ap_memory {  { H_x_3_address0 mem_address 1 5 }  { H_x_3_ce0 mem_ce 1 1 }  { H_x_3_q0 mem_dout 0 32 } } }
	m_x { ap_none {  { m_x in_data 0 32 } } }
	A_0 { ap_memory {  { A_0_address0 mem_address 1 2 }  { A_0_ce0 mem_ce 1 1 }  { A_0_q0 mem_dout 0 32 } } }
	A_1 { ap_memory {  { A_1_address0 mem_address 1 2 }  { A_1_ce0 mem_ce 1 1 }  { A_1_q0 mem_dout 0 32 } } }
	A_2 { ap_memory {  { A_2_address0 mem_address 1 2 }  { A_2_ce0 mem_ce 1 1 }  { A_2_q0 mem_dout 0 32 } } }
	A_3 { ap_memory {  { A_3_address0 mem_address 1 2 }  { A_3_ce0 mem_ce 1 1 }  { A_3_q0 mem_dout 0 32 } } }
	p_w_0 { ap_none {  { p_w_0 in_data 0 32 } } }
	p_w_1 { ap_none {  { p_w_1 in_data 0 32 } } }
	p_w_2 { ap_none {  { p_w_2 in_data 0 32 } } }
	p_w_3 { ap_none {  { p_w_3 in_data 0 32 } } }
	H_w_0 { ap_memory {  { H_w_0_address0 mem_address 1 5 }  { H_w_0_ce0 mem_ce 1 1 }  { H_w_0_q0 mem_dout 0 32 } } }
	H_w_1 { ap_memory {  { H_w_1_address0 mem_address 1 5 }  { H_w_1_ce0 mem_ce 1 1 }  { H_w_1_q0 mem_dout 0 32 } } }
	H_w_2 { ap_memory {  { H_w_2_address0 mem_address 1 5 }  { H_w_2_ce0 mem_ce 1 1 }  { H_w_2_q0 mem_dout 0 32 } } }
	H_w_3 { ap_memory {  { H_w_3_address0 mem_address 1 5 }  { H_w_3_ce0 mem_ce 1 1 }  { H_w_3_q0 mem_dout 0 32 } } }
	m_w { ap_none {  { m_w in_data 0 32 } } }
	p_pred_0 { ap_vld {  { p_pred_0 out_data 1 32 }  { p_pred_0_ap_vld out_vld 1 1 } } }
	p_pred_1 { ap_vld {  { p_pred_1 out_data 1 32 }  { p_pred_1_ap_vld out_vld 1 1 } } }
	p_pred_2 { ap_vld {  { p_pred_2 out_data 1 32 }  { p_pred_2_ap_vld out_vld 1 1 } } }
	p_pred_3 { ap_vld {  { p_pred_3 out_data 1 32 }  { p_pred_3_ap_vld out_vld 1 1 } } }
	H_pred_0 { ap_memory {  { H_pred_0_address0 mem_address 1 5 }  { H_pred_0_ce0 mem_ce 1 1 }  { H_pred_0_we0 mem_we 1 1 }  { H_pred_0_d0 mem_din 1 32 } } }
	H_pred_1 { ap_memory {  { H_pred_1_address0 mem_address 1 5 }  { H_pred_1_ce0 mem_ce 1 1 }  { H_pred_1_we0 mem_we 1 1 }  { H_pred_1_d0 mem_din 1 32 } } }
	H_pred_2 { ap_memory {  { H_pred_2_address0 mem_address 1 5 }  { H_pred_2_ce0 mem_ce 1 1 }  { H_pred_2_we0 mem_we 1 1 }  { H_pred_2_d0 mem_din 1 32 } } }
	H_pred_3 { ap_memory {  { H_pred_3_address0 mem_address 1 5 }  { H_pred_3_ce0 mem_ce 1 1 }  { H_pred_3_we0 mem_we 1 1 }  { H_pred_3_d0 mem_din 1 32 } } }
	m_pred { ap_vld {  { m_pred out_data 1 32 }  { m_pred_ap_vld out_vld 1 1 } } }
}

set maxi_interface_dict [dict create]

# RTL port scheduling information:
set fifoSchedulingInfoList { 
}

# RTL bus port read request latency information:
set busReadReqLatencyList { 
}

# RTL bus port write response latency information:
set busWriteResLatencyList { 
}

# RTL array port load latency information:
set memoryLoadLatencyList { 
}
