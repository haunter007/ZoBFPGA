# ==============================================================
# Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
# Tool Version Limit: 2025.11
# Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
# Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
# 
# ==============================================================
proc sc_sim_check {ret err logfile} {
	if {$::AESL_AUTOSIM::gDebug == 1} {
		puts stdout "[debug_prompt arg check_sim.tcl] start...";
	}
    set errfile "err.log"
    if {[file exists $errfile] && [file size $errfile] != 0} {
        set fl [open $errfile r]
        while {[gets $fl line] >= 0} {
            if {[string first "AESL_mErrNo = " $line] == 0} {
                set mismatch_num [string range $line [string length "AESL_mErrNo = "] end]
                if {$mismatch_num != 0} {
                    ::AP::printMsg ERR COSIM 403 COSIM_403_986 ${mismatch_num}
                    break
                }
            }
        }
    }
    if {$ret || $err != ""} {
        if { [lindex $::errorCode 0] eq "CHILDSTATUS"} {
            set status [lindex $::errorCode 2]
            if {$status != ""} {
                ::AP::printMsg ERR COSIM 404 COSIM_404_987 $status
            } else {
                ::AP::printMsg ERR COSIM 405 COSIM_405_988
            }
        } else {
            ::AP::printMsg ERR COSIM 405 COSIM_405_989
        }
    }
	if {$::AESL_AUTOSIM::gDebug == 1} {
		puts stdout "[debug_prompt arg check_sim.tcl] finish...";
	}
}

proc rtl_sim_check {} {
	if {$::AESL_AUTOSIM::gDebug == 1} {
		puts stdout "[debug_prompt arg check_sim.tcl] start...";
	}
    set errfile "err.log"
    if {[file exists $errfile] && [file size $errfile] != 0} {
        set fl [open $errfile r]
        set unmatch_num 0
        while {[gets $fl line] >= 0} {
            if {[string first "unmatched" $line] != -1} {
                set unmatch_num [expr $unmatch_num + 1]
            }
        }
        if {$unmatch_num != 0} {
            ::AP::printMsg ERR COSIM 406 COSIM_406_991 ${unmatch_num}
        }
    }
    if {[file exists ".aesl_error"]} {
        set errfl [open ".aesl_error" r]
        gets $errfl line
        if {$line != 0} {
            ::AP::printMsg ERR COSIM 407 COSIM_407_992 $line
        }
    }
    if {[file exists ".exit.err"]} {
        ::AP::printMsg ERR COSIM 405 COSIM_405_993
    }
	if {$::AESL_AUTOSIM::gDebug == 1} {
		puts stdout "[debug_prompt arg check_sim.tcl] finish...";
	}
}

proc check_tvin_file {} {
	if {$::AESL_AUTOSIM::gDebug == 1} {
		puts stdout "[debug_prompt arg check_sim.tcl] start...";
	}
    set rtlfilelist {
         "c.predict_kernel.autotvin_p_x_0.dat"
         "c.predict_kernel.autotvin_p_x_1.dat"
         "c.predict_kernel.autotvin_p_x_2.dat"
         "c.predict_kernel.autotvin_p_x_3.dat"
         "c.predict_kernel.autotvin_H_x_0.dat"
         "c.predict_kernel.autotvin_H_x_1.dat"
         "c.predict_kernel.autotvin_H_x_2.dat"
         "c.predict_kernel.autotvin_H_x_3.dat"
         "c.predict_kernel.autotvin_m_x.dat"
         "c.predict_kernel.autotvin_A_0.dat"
         "c.predict_kernel.autotvin_A_1.dat"
         "c.predict_kernel.autotvin_A_2.dat"
         "c.predict_kernel.autotvin_A_3.dat"
         "c.predict_kernel.autotvin_p_w_0.dat"
         "c.predict_kernel.autotvin_p_w_1.dat"
         "c.predict_kernel.autotvin_p_w_2.dat"
         "c.predict_kernel.autotvin_p_w_3.dat"
         "c.predict_kernel.autotvin_H_w_0.dat"
         "c.predict_kernel.autotvin_H_w_1.dat"
         "c.predict_kernel.autotvin_H_w_2.dat"
         "c.predict_kernel.autotvin_H_w_3.dat"
         "c.predict_kernel.autotvin_m_w.dat"
         "c.predict_kernel.autotvin_H_pred_0.dat"
         "c.predict_kernel.autotvin_H_pred_1.dat"
         "c.predict_kernel.autotvin_H_pred_2.dat"
         "c.predict_kernel.autotvin_H_pred_3.dat"
    }
    foreach rtlfile $rtlfilelist {
        if {[file isfile $rtlfile]} {
        } else {
            ::AP::printMsg ERR COSIM 320 COSIM_320_994
            return 1
        }
    }
	if {$::AESL_AUTOSIM::gDebug == 1} {
		puts stdout "[debug_prompt arg check_sim.tcl] finish...";
	}
    return 0
}

proc check_tvout_file {} {
	if {$::AESL_AUTOSIM::gDebug == 1} {
		puts stdout "[debug_prompt arg check_sim.tcl] start...";
	}
    set rtlfilelist {
         "rtl.predict_kernel.autotvout_p_pred_0.dat"
         "rtl.predict_kernel.autotvout_p_pred_1.dat"
         "rtl.predict_kernel.autotvout_p_pred_2.dat"
         "rtl.predict_kernel.autotvout_p_pred_3.dat"
         "rtl.predict_kernel.autotvout_H_pred_0.dat"
         "rtl.predict_kernel.autotvout_H_pred_1.dat"
         "rtl.predict_kernel.autotvout_H_pred_2.dat"
         "rtl.predict_kernel.autotvout_H_pred_3.dat"
         "rtl.predict_kernel.autotvout_m_pred.dat"
    }
    foreach rtlfile $rtlfilelist {
        if {[file isfile $rtlfile]} {
        } else {
            ::AP::printMsg ERR COSIM 303 COSIM_303_996
            return 1
        }
    }
	if {$::AESL_AUTOSIM::gDebug == 1} {
		puts stdout "[debug_prompt arg check_sim.tcl] finish...";
	}
    return 0
}
