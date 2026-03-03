
set TopModule "predict_kernel"
set ClockPeriod 10
set ClockList ap_clk
set AxiliteClockList {}
set HasVivadoClockPeriod 0
set CombLogicFlag 0
set PipelineFlag 0
set DataflowTaskPipelineFlag 1
set TrivialPipelineFlag 0
set noPortSwitchingFlag 0
set FloatingPointFlag 1
set FftOrFirFlag 0
set NbRWValue 0
set intNbAccess 0
set NewDSPMapping 1
set HasDSPModule 0
set ResetLevelFlag 1
set ResetStyle control
set ResetSyncFlag 1
set ResetRegisterFlag 0
set ResetVariableFlag 0
set ResetRegisterNum 0
set FsmEncStyle onehot
set MaxFanout 0
set RtlPrefix {}
set RtlSubPrefix predict_kernel_
set ExtraCCFlags {}
set ExtraCLdFlags {}
set SynCheckOptions {}
set PresynOptions {}
set PreprocOptions {}
set RtlWriterOptions {}
set CbcGenFlag 0
set CasGenFlag 0
set CasMonitorFlag 0
set AutoSimOptions {}
set ExportMCPathFlag 0
set SCTraceFileName mytrace
set SCTraceFileFormat vcd
set SCTraceOption all
set TargetInfo xck26:-sfvc784:-2LV-c
set SourceFiles {sc {} c ../../src/fpga_kernels.cpp}
set SourceFlags {sc {} c -I/home/zzh/minkowski_fpga/hls/include}
set DirectiveFile {}
set TBFiles {verilog {/home/zzh/minkowski_fpga/hls/src/dump.cpp /home/zzh/minkowski_fpga/hls/src/zonotope_operations.cpp /home/zzh/minkowski_fpga/hls/src/testbench.cpp} bc {/home/zzh/minkowski_fpga/hls/src/dump.cpp /home/zzh/minkowski_fpga/hls/src/zonotope_operations.cpp /home/zzh/minkowski_fpga/hls/src/testbench.cpp} vhdl {/home/zzh/minkowski_fpga/hls/src/dump.cpp /home/zzh/minkowski_fpga/hls/src/zonotope_operations.cpp /home/zzh/minkowski_fpga/hls/src/testbench.cpp} sc {/home/zzh/minkowski_fpga/hls/src/dump.cpp /home/zzh/minkowski_fpga/hls/src/zonotope_operations.cpp /home/zzh/minkowski_fpga/hls/src/testbench.cpp} cas {/home/zzh/minkowski_fpga/hls/src/dump.cpp /home/zzh/minkowski_fpga/hls/src/zonotope_operations.cpp /home/zzh/minkowski_fpga/hls/src/testbench.cpp} c {}}
set SpecLanguage C
set TVInFiles {bc {} c {} sc {} cas {} vhdl {} verilog {}}
set TVOutFiles {bc {} c {} sc {} cas {} vhdl {} verilog {}}
set TBTops {verilog {} bc {} vhdl {} sc {} cas {} c {}}
set TBInstNames {verilog {} bc {} vhdl {} sc {} cas {} c {}}
set XDCFiles {}
set ExtraGlobalOptions {"area_timing" 1 "clock_gate" 1 "impl_flow" map "power_gate" 0}
set TBTVFileNotFound {}
set AppFile ../hls.app
set ApsFile sol1.aps
set AvePath ../../.
set DefaultPlatform DefaultPlatform
set multiClockList {}
set SCPortClockMap {}
set intNbAccess 0
set PlatformFiles {{DefaultPlatform {xilinx/zynquplus/zynquplus}}}
set HPFPO 0
