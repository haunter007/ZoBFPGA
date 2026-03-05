set ModuleHierarchy {[{
"Name" : "predict_kernel", "RefName" : "predict_kernel","ID" : "0","Type" : "sequential",
"SubInsts" : [
	{"Name" : "grp_predict_kernel_Pipeline_VITIS_LOOP_35_1_fu_163", "RefName" : "predict_kernel_Pipeline_VITIS_LOOP_35_1","ID" : "1","Type" : "sequential",
		"SubLoops" : [
		{"Name" : "VITIS_LOOP_35_1","RefName" : "VITIS_LOOP_35_1","ID" : "2","Type" : "pipeline"},]},
	{"Name" : "grp_predict_kernel_Pipeline_VITIS_LOOP_45_3_VITIS_LOOP_48_4_fu_191", "RefName" : "predict_kernel_Pipeline_VITIS_LOOP_45_3_VITIS_LOOP_48_4","ID" : "3","Type" : "sequential",
		"SubLoops" : [
		{"Name" : "VITIS_LOOP_45_3_VITIS_LOOP_48_4","RefName" : "VITIS_LOOP_45_3_VITIS_LOOP_48_4","ID" : "4","Type" : "pipeline"},]},
	{"Name" : "grp_predict_kernel_Pipeline_VITIS_LOOP_59_6_VITIS_LOOP_61_7_fu_220", "RefName" : "predict_kernel_Pipeline_VITIS_LOOP_59_6_VITIS_LOOP_61_7","ID" : "5","Type" : "sequential",
		"SubLoops" : [
		{"Name" : "VITIS_LOOP_59_6_VITIS_LOOP_61_7","RefName" : "VITIS_LOOP_59_6_VITIS_LOOP_61_7","ID" : "6","Type" : "pipeline"},]},]
}]}