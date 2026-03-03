set SynModuleInfo {
  {SRCNAME predict_kernel_Pipeline_VITIS_LOOP_35_1 MODELNAME predict_kernel_Pipeline_VITIS_LOOP_35_1 RTLNAME predict_kernel_predict_kernel_Pipeline_VITIS_LOOP_35_1
    SUBMODULES {
      {MODELNAME predict_kernel_sparsemux_9_2_32_1_1 RTLNAME predict_kernel_sparsemux_9_2_32_1_1 BINDTYPE op TYPE sparsemux IMPL compactencoding_dontcare}
      {MODELNAME predict_kernel_flow_control_loop_pipe_sequential_init RTLNAME predict_kernel_flow_control_loop_pipe_sequential_init BINDTYPE interface TYPE internal_upc_flow_control INSTNAME predict_kernel_flow_control_loop_pipe_sequential_init_U}
    }
  }
  {SRCNAME predict_kernel_Pipeline_VITIS_LOOP_45_3_VITIS_LOOP_48_4 MODELNAME predict_kernel_Pipeline_VITIS_LOOP_45_3_VITIS_LOOP_48_4 RTLNAME predict_kernel_predict_kernel_Pipeline_VITIS_LOOP_45_3_VITIS_LOOP_48_4}
  {SRCNAME predict_kernel_Pipeline_VITIS_LOOP_59_6_VITIS_LOOP_61_7 MODELNAME predict_kernel_Pipeline_VITIS_LOOP_59_6_VITIS_LOOP_61_7 RTLNAME predict_kernel_predict_kernel_Pipeline_VITIS_LOOP_59_6_VITIS_LOOP_61_7}
  {SRCNAME predict_kernel MODELNAME predict_kernel RTLNAME predict_kernel IS_TOP 1
    SUBMODULES {
      {MODELNAME predict_kernel_fadd_32ns_32ns_32_4_full_dsp_1 RTLNAME predict_kernel_fadd_32ns_32ns_32_4_full_dsp_1 BINDTYPE op TYPE fadd IMPL fulldsp LATENCY 3 ALLOW_PRAGMA 1}
      {MODELNAME predict_kernel_fmul_32ns_32ns_32_3_max_dsp_1 RTLNAME predict_kernel_fmul_32ns_32ns_32_3_max_dsp_1 BINDTYPE op TYPE fmul IMPL maxdsp LATENCY 2 ALLOW_PRAGMA 1}
    }
  }
}
