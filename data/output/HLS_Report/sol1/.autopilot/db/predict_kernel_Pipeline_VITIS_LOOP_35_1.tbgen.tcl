set moduleName predict_kernel_Pipeline_VITIS_LOOP_35_1
set isTopModule 0
set isCombinational 0
set isDatapathOnly 0
set isPipelined 1
set isPipelined_legacy 1
set pipeline_type loop_auto_rewind
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
set C_modelName {predict_kernel_Pipeline_VITIS_LOOP_35_1}
set C_modelType { void 0 }
set ap_memory_interface_dict [dict create]
dict set ap_memory_interface_dict A_0 { MEM_WIDTH 32 MEM_SIZE 16 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 1 }
dict set ap_memory_interface_dict A_1 { MEM_WIDTH 32 MEM_SIZE 16 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 1 }
dict set ap_memory_interface_dict A_2 { MEM_WIDTH 32 MEM_SIZE 16 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 1 }
dict set ap_memory_interface_dict A_3 { MEM_WIDTH 32 MEM_SIZE 16 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 1 }
set C_modelArgList {
	{ p_pred_0 int 32 regular {pointer 1}  }
	{ p_pred_3 int 32 regular {pointer 1}  }
	{ p_pred_2 int 32 regular {pointer 1}  }
	{ p_pred_1 int 32 regular {pointer 1}  }
	{ bitcast_ln37 float 32 regular  }
	{ bitcast_ln37_1 float 32 regular  }
	{ bitcast_ln37_2 float 32 regular  }
	{ bitcast_ln37_3 float 32 regular  }
	{ A_0 int 32 regular {array 4 { 1 3 } 1 1 }  }
	{ bitcast_ln40 float 32 regular  }
	{ A_1 int 32 regular {array 4 { 1 3 } 1 1 }  }
	{ bitcast_ln40_1 float 32 regular  }
	{ A_2 int 32 regular {array 4 { 1 3 } 1 1 }  }
	{ bitcast_ln40_2 float 32 regular  }
	{ A_3 int 32 regular {array 4 { 1 3 } 1 1 }  }
	{ bitcast_ln40_3 float 32 regular  }
}
set hasAXIMCache 0
set l_AXIML2Cache [list]
set AXIMCacheInstDict [dict create]
set C_modelArgMapList {[ 
	{ "Name" : "p_pred_0", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_pred_3", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_pred_2", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_pred_1", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "bitcast_ln37", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "bitcast_ln37_1", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "bitcast_ln37_2", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "bitcast_ln37_3", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "A_0", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "bitcast_ln40", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "A_1", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "bitcast_ln40_1", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "A_2", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "bitcast_ln40_2", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "A_3", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "bitcast_ln40_3", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} ]}
# RTL Port declarations: 
set portNum 70
set portList { 
	{ ap_clk sc_in sc_logic 1 clock -1 } 
	{ ap_rst sc_in sc_logic 1 reset -1 active_high_sync } 
	{ ap_start sc_in sc_logic 1 start -1 } 
	{ ap_done sc_out sc_logic 1 predone -1 } 
	{ ap_idle sc_out sc_logic 1 done -1 } 
	{ ap_ready sc_out sc_logic 1 ready -1 } 
	{ p_pred_0 sc_out sc_lv 32 signal 0 } 
	{ p_pred_0_ap_vld sc_out sc_logic 1 outvld 0 } 
	{ p_pred_3 sc_out sc_lv 32 signal 1 } 
	{ p_pred_3_ap_vld sc_out sc_logic 1 outvld 1 } 
	{ p_pred_2 sc_out sc_lv 32 signal 2 } 
	{ p_pred_2_ap_vld sc_out sc_logic 1 outvld 2 } 
	{ p_pred_1 sc_out sc_lv 32 signal 3 } 
	{ p_pred_1_ap_vld sc_out sc_logic 1 outvld 3 } 
	{ bitcast_ln37 sc_in sc_lv 32 signal 4 } 
	{ bitcast_ln37_1 sc_in sc_lv 32 signal 5 } 
	{ bitcast_ln37_2 sc_in sc_lv 32 signal 6 } 
	{ bitcast_ln37_3 sc_in sc_lv 32 signal 7 } 
	{ A_0_address0 sc_out sc_lv 2 signal 8 } 
	{ A_0_ce0 sc_out sc_logic 1 signal 8 } 
	{ A_0_q0 sc_in sc_lv 32 signal 8 } 
	{ bitcast_ln40 sc_in sc_lv 32 signal 9 } 
	{ A_1_address0 sc_out sc_lv 2 signal 10 } 
	{ A_1_ce0 sc_out sc_logic 1 signal 10 } 
	{ A_1_q0 sc_in sc_lv 32 signal 10 } 
	{ bitcast_ln40_1 sc_in sc_lv 32 signal 11 } 
	{ A_2_address0 sc_out sc_lv 2 signal 12 } 
	{ A_2_ce0 sc_out sc_logic 1 signal 12 } 
	{ A_2_q0 sc_in sc_lv 32 signal 12 } 
	{ bitcast_ln40_2 sc_in sc_lv 32 signal 13 } 
	{ A_3_address0 sc_out sc_lv 2 signal 14 } 
	{ A_3_ce0 sc_out sc_logic 1 signal 14 } 
	{ A_3_q0 sc_in sc_lv 32 signal 14 } 
	{ bitcast_ln40_3 sc_in sc_lv 32 signal 15 } 
	{ grp_fu_382_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_382_p_din1 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_382_p_opcode sc_out sc_lv 2 signal -1 } 
	{ grp_fu_382_p_dout0 sc_in sc_lv 32 signal -1 } 
	{ grp_fu_382_p_ce sc_out sc_logic 1 signal -1 } 
	{ grp_fu_386_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_386_p_din1 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_386_p_opcode sc_out sc_lv 2 signal -1 } 
	{ grp_fu_386_p_dout0 sc_in sc_lv 32 signal -1 } 
	{ grp_fu_386_p_ce sc_out sc_logic 1 signal -1 } 
	{ grp_fu_390_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_390_p_din1 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_390_p_opcode sc_out sc_lv 2 signal -1 } 
	{ grp_fu_390_p_dout0 sc_in sc_lv 32 signal -1 } 
	{ grp_fu_390_p_ce sc_out sc_logic 1 signal -1 } 
	{ grp_fu_394_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_394_p_din1 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_394_p_opcode sc_out sc_lv 2 signal -1 } 
	{ grp_fu_394_p_dout0 sc_in sc_lv 32 signal -1 } 
	{ grp_fu_394_p_ce sc_out sc_logic 1 signal -1 } 
	{ grp_fu_398_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_398_p_din1 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_398_p_dout0 sc_in sc_lv 32 signal -1 } 
	{ grp_fu_398_p_ce sc_out sc_logic 1 signal -1 } 
	{ grp_fu_402_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_402_p_din1 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_402_p_dout0 sc_in sc_lv 32 signal -1 } 
	{ grp_fu_402_p_ce sc_out sc_logic 1 signal -1 } 
	{ grp_fu_406_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_406_p_din1 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_406_p_dout0 sc_in sc_lv 32 signal -1 } 
	{ grp_fu_406_p_ce sc_out sc_logic 1 signal -1 } 
	{ grp_fu_410_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_410_p_din1 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_410_p_dout0 sc_in sc_lv 32 signal -1 } 
	{ grp_fu_410_p_ce sc_out sc_logic 1 signal -1 } 
}
set NewPortList {[ 
	{ "name": "ap_clk", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "clock", "bundle":{"name": "ap_clk", "role": "default" }} , 
 	{ "name": "ap_rst", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "reset", "bundle":{"name": "ap_rst", "role": "default" }} , 
 	{ "name": "ap_start", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "start", "bundle":{"name": "ap_start", "role": "default" }} , 
 	{ "name": "ap_done", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "predone", "bundle":{"name": "ap_done", "role": "default" }} , 
 	{ "name": "ap_idle", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "done", "bundle":{"name": "ap_idle", "role": "default" }} , 
 	{ "name": "ap_ready", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "ready", "bundle":{"name": "ap_ready", "role": "default" }} , 
 	{ "name": "p_pred_0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_pred_0", "role": "default" }} , 
 	{ "name": "p_pred_0_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_pred_0", "role": "ap_vld" }} , 
 	{ "name": "p_pred_3", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_pred_3", "role": "default" }} , 
 	{ "name": "p_pred_3_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_pred_3", "role": "ap_vld" }} , 
 	{ "name": "p_pred_2", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_pred_2", "role": "default" }} , 
 	{ "name": "p_pred_2_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_pred_2", "role": "ap_vld" }} , 
 	{ "name": "p_pred_1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_pred_1", "role": "default" }} , 
 	{ "name": "p_pred_1_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_pred_1", "role": "ap_vld" }} , 
 	{ "name": "bitcast_ln37", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "bitcast_ln37", "role": "default" }} , 
 	{ "name": "bitcast_ln37_1", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "bitcast_ln37_1", "role": "default" }} , 
 	{ "name": "bitcast_ln37_2", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "bitcast_ln37_2", "role": "default" }} , 
 	{ "name": "bitcast_ln37_3", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "bitcast_ln37_3", "role": "default" }} , 
 	{ "name": "A_0_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "A_0", "role": "address0" }} , 
 	{ "name": "A_0_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "A_0", "role": "ce0" }} , 
 	{ "name": "A_0_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "A_0", "role": "q0" }} , 
 	{ "name": "bitcast_ln40", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "bitcast_ln40", "role": "default" }} , 
 	{ "name": "A_1_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "A_1", "role": "address0" }} , 
 	{ "name": "A_1_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "A_1", "role": "ce0" }} , 
 	{ "name": "A_1_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "A_1", "role": "q0" }} , 
 	{ "name": "bitcast_ln40_1", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "bitcast_ln40_1", "role": "default" }} , 
 	{ "name": "A_2_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "A_2", "role": "address0" }} , 
 	{ "name": "A_2_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "A_2", "role": "ce0" }} , 
 	{ "name": "A_2_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "A_2", "role": "q0" }} , 
 	{ "name": "bitcast_ln40_2", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "bitcast_ln40_2", "role": "default" }} , 
 	{ "name": "A_3_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "A_3", "role": "address0" }} , 
 	{ "name": "A_3_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "A_3", "role": "ce0" }} , 
 	{ "name": "A_3_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "A_3", "role": "q0" }} , 
 	{ "name": "bitcast_ln40_3", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "bitcast_ln40_3", "role": "default" }} , 
 	{ "name": "grp_fu_382_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_382_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_382_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_382_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_382_p_opcode", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "grp_fu_382_p_opcode", "role": "default" }} , 
 	{ "name": "grp_fu_382_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_382_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_382_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_382_p_ce", "role": "default" }} , 
 	{ "name": "grp_fu_386_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_386_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_386_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_386_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_386_p_opcode", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "grp_fu_386_p_opcode", "role": "default" }} , 
 	{ "name": "grp_fu_386_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_386_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_386_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_386_p_ce", "role": "default" }} , 
 	{ "name": "grp_fu_390_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_390_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_390_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_390_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_390_p_opcode", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "grp_fu_390_p_opcode", "role": "default" }} , 
 	{ "name": "grp_fu_390_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_390_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_390_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_390_p_ce", "role": "default" }} , 
 	{ "name": "grp_fu_394_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_394_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_394_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_394_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_394_p_opcode", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "grp_fu_394_p_opcode", "role": "default" }} , 
 	{ "name": "grp_fu_394_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_394_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_394_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_394_p_ce", "role": "default" }} , 
 	{ "name": "grp_fu_398_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_398_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_398_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_398_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_398_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_398_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_398_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_398_p_ce", "role": "default" }} , 
 	{ "name": "grp_fu_402_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_402_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_402_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_402_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_402_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_402_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_402_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_402_p_ce", "role": "default" }} , 
 	{ "name": "grp_fu_406_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_406_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_406_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_406_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_406_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_406_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_406_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_406_p_ce", "role": "default" }} , 
 	{ "name": "grp_fu_410_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_410_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_410_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_410_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_410_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_410_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_410_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_410_p_ce", "role": "default" }}  ]}

set ArgLastReadFirstWriteLatency {
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
		bitcast_ln40_3 {Type I LastRead 0 FirstWrite -1}}}

set hasDtUnsupportedChannel 0

set PerformanceInfo {[
	{"Name" : "Latency", "Min" : "24", "Max" : "24"}
	, {"Name" : "Interval", "Min" : "5", "Max" : "5"}
]}

set PipelineEnableSignalInfo {[
	{"Pipeline" : "0", "EnableSignal" : "ap_enable_pp0"}
]}

set Spec2ImplPortList { 
	p_pred_0 { ap_vld {  { p_pred_0 out_data 1 32 }  { p_pred_0_ap_vld out_vld 1 1 } } }
	p_pred_3 { ap_vld {  { p_pred_3 out_data 1 32 }  { p_pred_3_ap_vld out_vld 1 1 } } }
	p_pred_2 { ap_vld {  { p_pred_2 out_data 1 32 }  { p_pred_2_ap_vld out_vld 1 1 } } }
	p_pred_1 { ap_vld {  { p_pred_1 out_data 1 32 }  { p_pred_1_ap_vld out_vld 1 1 } } }
	bitcast_ln37 { ap_none {  { bitcast_ln37 in_data 0 32 } } }
	bitcast_ln37_1 { ap_none {  { bitcast_ln37_1 in_data 0 32 } } }
	bitcast_ln37_2 { ap_none {  { bitcast_ln37_2 in_data 0 32 } } }
	bitcast_ln37_3 { ap_none {  { bitcast_ln37_3 in_data 0 32 } } }
	A_0 { ap_memory {  { A_0_address0 mem_address 1 2 }  { A_0_ce0 mem_ce 1 1 }  { A_0_q0 mem_dout 0 32 } } }
	bitcast_ln40 { ap_none {  { bitcast_ln40 in_data 0 32 } } }
	A_1 { ap_memory {  { A_1_address0 mem_address 1 2 }  { A_1_ce0 mem_ce 1 1 }  { A_1_q0 mem_dout 0 32 } } }
	bitcast_ln40_1 { ap_none {  { bitcast_ln40_1 in_data 0 32 } } }
	A_2 { ap_memory {  { A_2_address0 mem_address 1 2 }  { A_2_ce0 mem_ce 1 1 }  { A_2_q0 mem_dout 0 32 } } }
	bitcast_ln40_2 { ap_none {  { bitcast_ln40_2 in_data 0 32 } } }
	A_3 { ap_memory {  { A_3_address0 mem_address 1 2 }  { A_3_ce0 mem_ce 1 1 }  { A_3_q0 mem_dout 0 32 } } }
	bitcast_ln40_3 { ap_none {  { bitcast_ln40_3 in_data 0 32 } } }
}
