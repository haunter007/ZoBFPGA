; ModuleID = '/home/zzh/minkowski_fpga/hls/minkowski_hls/sol1/.autopilot/db/a.g.ld.5.gdce.bc'
source_filename = "llvm-link"
target datalayout = "e-m:e-i64:64-i128:128-i256:256-i512:512-i1024:1024-i2048:2048-i4096:4096-n8:16:32:64-S128-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
target triple = "fpga64-xilinx-none"

; Function Attrs: inaccessiblememonly nounwind willreturn
declare void @llvm.sideeffect() #0

; Function Attrs: inaccessiblemem_or_argmemonly noinline willreturn
define void @apatb_predict_kernel_ir(float* noalias nocapture nonnull readonly "fpga.decayed.dim.hint"="4" "partition" %p_x, [32 x float]* noalias nocapture nonnull readonly "fpga.decayed.dim.hint"="4" "partition" %H_x, i32 %m_x, [4 x float]* noalias nocapture nonnull readonly "fpga.decayed.dim.hint"="4" "partition" %A, float* noalias nocapture nonnull readonly "fpga.decayed.dim.hint"="4" "partition" %p_w, [32 x float]* noalias nocapture nonnull readonly "fpga.decayed.dim.hint"="4" "partition" %H_w, i32 %m_w, float* noalias nocapture nonnull "fpga.decayed.dim.hint"="4" "partition" %p_pred, [32 x float]* noalias nocapture nonnull "fpga.decayed.dim.hint"="4" "partition" %H_pred, i32* noalias nocapture nonnull %m_pred) local_unnamed_addr #1 {
entry:
  %0 = bitcast float* %p_x to [4 x float]*
  %p_x_copy_0 = alloca float, align 512
  %p_x_copy_1 = alloca float, align 512
  %p_x_copy_2 = alloca float, align 512
  %p_x_copy_3 = alloca float, align 512
  %1 = bitcast [32 x float]* %H_x to [4 x [32 x float]]*
  %H_x_copy_0 = alloca [32 x float], align 512
  %H_x_copy_1 = alloca [32 x float], align 512
  %H_x_copy_2 = alloca [32 x float], align 512
  %H_x_copy_3 = alloca [32 x float], align 512
  %2 = bitcast [4 x float]* %A to [4 x [4 x float]]*
  %A_copy_0 = alloca [4 x float], align 512
  %A_copy_1 = alloca [4 x float], align 512
  %A_copy_2 = alloca [4 x float], align 512
  %A_copy_3 = alloca [4 x float], align 512
  %_0 = getelementptr [4 x float], [4 x float]* %A_copy_0, i64 0, i64 0
  %_1 = getelementptr [4 x float], [4 x float]* %A_copy_1, i64 0, i64 0
  %_2 = getelementptr [4 x float], [4 x float]* %A_copy_2, i64 0, i64 0
  %_3 = getelementptr [4 x float], [4 x float]* %A_copy_3, i64 0, i64 0
  %3 = bitcast float* %p_w to [4 x float]*
  %p_w_copy_0 = alloca float, align 512
  %p_w_copy_1 = alloca float, align 512
  %p_w_copy_2 = alloca float, align 512
  %p_w_copy_3 = alloca float, align 512
  %4 = bitcast [32 x float]* %H_w to [4 x [32 x float]]*
  %H_w_copy_0 = alloca [32 x float], align 512
  %H_w_copy_1 = alloca [32 x float], align 512
  %H_w_copy_2 = alloca [32 x float], align 512
  %H_w_copy_3 = alloca [32 x float], align 512
  %5 = bitcast float* %p_pred to [4 x float]*
  %p_pred_copy_0 = alloca float, align 512
  %p_pred_copy_1 = alloca float, align 512
  %p_pred_copy_2 = alloca float, align 512
  %p_pred_copy_3 = alloca float, align 512
  %6 = bitcast [32 x float]* %H_pred to [4 x [32 x float]]*
  %H_pred_copy_0 = alloca [32 x float], align 512
  %H_pred_copy_1 = alloca [32 x float], align 512
  %H_pred_copy_2 = alloca [32 x float], align 512
  %H_pred_copy_3 = alloca [32 x float], align 512
  %m_pred_copy = alloca i32, align 512
  call void @copy_in([4 x float]* nonnull %0, float* nonnull align 512 %p_x_copy_0, float* nonnull align 512 %p_x_copy_1, float* nonnull align 512 %p_x_copy_2, float* nonnull align 512 %p_x_copy_3, [4 x [32 x float]]* nonnull %1, [32 x float]* nonnull align 512 %H_x_copy_0, [32 x float]* nonnull align 512 %H_x_copy_1, [32 x float]* nonnull align 512 %H_x_copy_2, [32 x float]* nonnull align 512 %H_x_copy_3, [4 x [4 x float]]* nonnull %2, [4 x float]* nonnull align 512 %A_copy_0, [4 x float]* nonnull align 512 %A_copy_1, [4 x float]* nonnull align 512 %A_copy_2, [4 x float]* nonnull align 512 %A_copy_3, [4 x float]* nonnull %3, float* nonnull align 512 %p_w_copy_0, float* nonnull align 512 %p_w_copy_1, float* nonnull align 512 %p_w_copy_2, float* nonnull align 512 %p_w_copy_3, [4 x [32 x float]]* nonnull %4, [32 x float]* nonnull align 512 %H_w_copy_0, [32 x float]* nonnull align 512 %H_w_copy_1, [32 x float]* nonnull align 512 %H_w_copy_2, [32 x float]* nonnull align 512 %H_w_copy_3, [4 x float]* nonnull %5, float* nonnull align 512 %p_pred_copy_0, float* nonnull align 512 %p_pred_copy_1, float* nonnull align 512 %p_pred_copy_2, float* nonnull align 512 %p_pred_copy_3, [4 x [32 x float]]* nonnull %6, [32 x float]* nonnull align 512 %H_pred_copy_0, [32 x float]* nonnull align 512 %H_pred_copy_1, [32 x float]* nonnull align 512 %H_pred_copy_2, [32 x float]* nonnull align 512 %H_pred_copy_3, i32* nonnull %m_pred, i32* nonnull align 512 %m_pred_copy)
  call void @llvm.sideeffect() #7 [ "xlx_array_partition"([32 x float]* %H_x_copy_0, i32 998, i32 1, i32 0, i1 false) ], !dbg !66
  call void @llvm.sideeffect() #7 [ "xlx_array_partition"([32 x float]* %H_x_copy_1, i32 998, i32 1, i32 0, i1 false) ], !dbg !66
  call void @llvm.sideeffect() #7 [ "xlx_array_partition"([32 x float]* %H_x_copy_2, i32 998, i32 1, i32 0, i1 false) ], !dbg !66
  call void @llvm.sideeffect() #7 [ "xlx_array_partition"([32 x float]* %H_x_copy_3, i32 998, i32 1, i32 0, i1 false) ], !dbg !66
  call void @llvm.sideeffect() #7 [ "xlx_array_partition"(float* %_0, i32 998, i32 1, i32 0, i1 false) ], !dbg !545
  call void @llvm.sideeffect() #7 [ "xlx_array_partition"(float* %_1, i32 998, i32 1, i32 0, i1 false) ], !dbg !545
  call void @llvm.sideeffect() #7 [ "xlx_array_partition"(float* %_2, i32 998, i32 1, i32 0, i1 false) ], !dbg !545
  call void @llvm.sideeffect() #7 [ "xlx_array_partition"(float* %_3, i32 998, i32 1, i32 0, i1 false) ], !dbg !545
  call void @llvm.sideeffect() #7 [ "xlx_array_partition"([32 x float]* %H_w_copy_0, i32 998, i32 1, i32 0, i1 false) ], !dbg !546
  call void @llvm.sideeffect() #7 [ "xlx_array_partition"([32 x float]* %H_w_copy_1, i32 998, i32 1, i32 0, i1 false) ], !dbg !546
  call void @llvm.sideeffect() #7 [ "xlx_array_partition"([32 x float]* %H_w_copy_2, i32 998, i32 1, i32 0, i1 false) ], !dbg !546
  call void @llvm.sideeffect() #7 [ "xlx_array_partition"([32 x float]* %H_w_copy_3, i32 998, i32 1, i32 0, i1 false) ], !dbg !546
  call void @llvm.sideeffect() #7 [ "xlx_array_partition"([32 x float]* %H_pred_copy_0, i32 998, i32 1, i32 0, i1 false) ], !dbg !547
  call void @llvm.sideeffect() #7 [ "xlx_array_partition"([32 x float]* %H_pred_copy_1, i32 998, i32 1, i32 0, i1 false) ], !dbg !547
  call void @llvm.sideeffect() #7 [ "xlx_array_partition"([32 x float]* %H_pred_copy_2, i32 998, i32 1, i32 0, i1 false) ], !dbg !547
  call void @llvm.sideeffect() #7 [ "xlx_array_partition"([32 x float]* %H_pred_copy_3, i32 998, i32 1, i32 0, i1 false) ], !dbg !547
  call void @apatb_predict_kernel_hw(float* %p_x_copy_0, float* %p_x_copy_1, float* %p_x_copy_2, float* %p_x_copy_3, [32 x float]* %H_x_copy_0, [32 x float]* %H_x_copy_1, [32 x float]* %H_x_copy_2, [32 x float]* %H_x_copy_3, i32 %m_x, [4 x float]* %A_copy_0, [4 x float]* %A_copy_1, [4 x float]* %A_copy_2, [4 x float]* %A_copy_3, float* %p_w_copy_0, float* %p_w_copy_1, float* %p_w_copy_2, float* %p_w_copy_3, [32 x float]* %H_w_copy_0, [32 x float]* %H_w_copy_1, [32 x float]* %H_w_copy_2, [32 x float]* %H_w_copy_3, i32 %m_w, float* %p_pred_copy_0, float* %p_pred_copy_1, float* %p_pred_copy_2, float* %p_pred_copy_3, [32 x float]* %H_pred_copy_0, [32 x float]* %H_pred_copy_1, [32 x float]* %H_pred_copy_2, [32 x float]* %H_pred_copy_3, i32* %m_pred_copy)
  call void @copy_back([4 x float]* %0, float* %p_x_copy_0, float* %p_x_copy_1, float* %p_x_copy_2, float* %p_x_copy_3, [4 x [32 x float]]* %1, [32 x float]* %H_x_copy_0, [32 x float]* %H_x_copy_1, [32 x float]* %H_x_copy_2, [32 x float]* %H_x_copy_3, [4 x [4 x float]]* %2, [4 x float]* %A_copy_0, [4 x float]* %A_copy_1, [4 x float]* %A_copy_2, [4 x float]* %A_copy_3, [4 x float]* %3, float* %p_w_copy_0, float* %p_w_copy_1, float* %p_w_copy_2, float* %p_w_copy_3, [4 x [32 x float]]* %4, [32 x float]* %H_w_copy_0, [32 x float]* %H_w_copy_1, [32 x float]* %H_w_copy_2, [32 x float]* %H_w_copy_3, [4 x float]* %5, float* %p_pred_copy_0, float* %p_pred_copy_1, float* %p_pred_copy_2, float* %p_pred_copy_3, [4 x [32 x float]]* %6, [32 x float]* %H_pred_copy_0, [32 x float]* %H_pred_copy_1, [32 x float]* %H_pred_copy_2, [32 x float]* %H_pred_copy_3, i32* %m_pred, i32* %m_pred_copy)
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define void @arraycpy_hls.p0a4f32([4 x float]* "orig.arg.no"="0" %dst, [4 x float]* readonly "orig.arg.no"="1" %src, i64 "orig.arg.no"="2" %num) local_unnamed_addr #2 {
entry:
  %0 = icmp eq [4 x float]* %src, null
  %1 = icmp eq [4 x float]* %dst, null
  %2 = or i1 %1, %0
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  %for.loop.cond1 = icmp sgt i64 %num, 0
  br i1 %for.loop.cond1, label %for.loop.lr.ph, label %copy.split

for.loop.lr.ph:                                   ; preds = %copy
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %for.loop.lr.ph
  %for.loop.idx2 = phi i64 [ 0, %for.loop.lr.ph ], [ %for.loop.idx.next, %for.loop ]
  %dst.addr = getelementptr [4 x float], [4 x float]* %dst, i64 0, i64 %for.loop.idx2
  %src.addr = getelementptr [4 x float], [4 x float]* %src, i64 0, i64 %for.loop.idx2
  %3 = load float, float* %src.addr, align 4
  store float %3, float* %dst.addr, align 4
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx2, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, %num
  br i1 %exitcond, label %for.loop, label %copy.split

copy.split:                                       ; preds = %for.loop, %copy
  br label %ret

ret:                                              ; preds = %copy.split, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define void @arraycpy_hls.p0a4a32f32([4 x [32 x float]]* "orig.arg.no"="0" %dst, [4 x [32 x float]]* readonly "orig.arg.no"="1" %src, i64 "orig.arg.no"="2" %num) local_unnamed_addr #2 {
entry:
  %0 = icmp eq [4 x [32 x float]]* %src, null
  %1 = icmp eq [4 x [32 x float]]* %dst, null
  %2 = or i1 %1, %0
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  %for.loop.cond1 = icmp sgt i64 %num, 0
  br i1 %for.loop.cond1, label %for.loop.lr.ph, label %copy.split

for.loop.lr.ph:                                   ; preds = %copy
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %for.loop.lr.ph
  %for.loop.idx2 = phi i64 [ 0, %for.loop.lr.ph ], [ %for.loop.idx.next, %for.loop ]
  %dst.addr = getelementptr [4 x [32 x float]], [4 x [32 x float]]* %dst, i64 0, i64 %for.loop.idx2
  %src.addr = getelementptr [4 x [32 x float]], [4 x [32 x float]]* %src, i64 0, i64 %for.loop.idx2
  call void @arraycpy_hls.p0a32f32([32 x float]* %dst.addr, [32 x float]* %src.addr, i64 32)
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx2, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, %num
  br i1 %exitcond, label %for.loop, label %copy.split

copy.split:                                       ; preds = %for.loop, %copy
  br label %ret

ret:                                              ; preds = %copy.split, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define void @arraycpy_hls.p0a32f32([32 x float]* %dst, [32 x float]* readonly %src, i64 %num) local_unnamed_addr #2 {
entry:
  %0 = icmp eq [32 x float]* %src, null
  %1 = icmp eq [32 x float]* %dst, null
  %2 = or i1 %1, %0
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  %for.loop.cond1 = icmp sgt i64 %num, 0
  br i1 %for.loop.cond1, label %for.loop.lr.ph, label %copy.split

for.loop.lr.ph:                                   ; preds = %copy
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %for.loop.lr.ph
  %for.loop.idx2 = phi i64 [ 0, %for.loop.lr.ph ], [ %for.loop.idx.next, %for.loop ]
  %dst.addr = getelementptr [32 x float], [32 x float]* %dst, i64 0, i64 %for.loop.idx2
  %src.addr = getelementptr [32 x float], [32 x float]* %src, i64 0, i64 %for.loop.idx2
  %3 = load float, float* %src.addr, align 4
  store float %3, float* %dst.addr, align 4
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx2, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, %num
  br i1 %exitcond, label %for.loop, label %copy.split

copy.split:                                       ; preds = %for.loop, %copy
  br label %ret

ret:                                              ; preds = %copy.split, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define void @arraycpy_hls.p0a4a4f32([4 x [4 x float]]* "orig.arg.no"="0" %dst, [4 x [4 x float]]* readonly "orig.arg.no"="1" %src, i64 "orig.arg.no"="2" %num) local_unnamed_addr #2 {
entry:
  %0 = icmp eq [4 x [4 x float]]* %src, null
  %1 = icmp eq [4 x [4 x float]]* %dst, null
  %2 = or i1 %1, %0
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  %for.loop.cond1 = icmp sgt i64 %num, 0
  br i1 %for.loop.cond1, label %for.loop.lr.ph, label %copy.split

for.loop.lr.ph:                                   ; preds = %copy
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %for.loop.lr.ph
  %for.loop.idx2 = phi i64 [ 0, %for.loop.lr.ph ], [ %for.loop.idx.next, %for.loop ]
  %dst.addr = getelementptr [4 x [4 x float]], [4 x [4 x float]]* %dst, i64 0, i64 %for.loop.idx2
  %src.addr = getelementptr [4 x [4 x float]], [4 x [4 x float]]* %src, i64 0, i64 %for.loop.idx2
  call void @arraycpy_hls.p0a4f32([4 x float]* %dst.addr, [4 x float]* %src.addr, i64 4)
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx2, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, %num
  br i1 %exitcond, label %for.loop, label %copy.split

copy.split:                                       ; preds = %for.loop, %copy
  br label %ret

ret:                                              ; preds = %copy.split, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @onebyonecpy_hls.p0i32(i32* noalias align 512 %dst, i32* noalias readonly %src) unnamed_addr #3 {
entry:
  %0 = icmp eq i32* %dst, null
  %1 = icmp eq i32* %src, null
  %2 = or i1 %0, %1
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  %3 = load i32, i32* %src, align 4
  store i32 %3, i32* %dst, align 512
  br label %ret

ret:                                              ; preds = %copy, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define void @arraycpy_hls.p0a4f32.4.5(float* "orig.arg.no"="0" "unpacked"="0.0" %dst_0, float* "orig.arg.no"="0" "unpacked"="0.1" %dst_1, float* "orig.arg.no"="0" "unpacked"="0.2" %dst_2, float* "orig.arg.no"="0" "unpacked"="0.3" %dst_3, [4 x float]* readonly "orig.arg.no"="1" %src, i64 "orig.arg.no"="2" %num) #2 {
entry:
  %0 = icmp eq [4 x float]* %src, null
  %1 = icmp eq float* %dst_0, null
  %2 = or i1 %1, %0
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  %for.loop.cond1 = icmp sgt i64 %num, 0
  br i1 %for.loop.cond1, label %for.loop.lr.ph, label %copy.split

for.loop.lr.ph:                                   ; preds = %copy
  br label %for.loop

for.loop:                                         ; preds = %dst.addr.exit, %for.loop.lr.ph
  %for.loop.idx2 = phi i64 [ 0, %for.loop.lr.ph ], [ %for.loop.idx.next, %dst.addr.exit ]
  %src.addr = getelementptr [4 x float], [4 x float]* %src, i64 0, i64 %for.loop.idx2
  %3 = load float, float* %src.addr, align 4
  switch i64 %for.loop.idx2, label %dst.addr.exit [
    i64 0, label %dst.addr.case.0
    i64 1, label %dst.addr.case.1
    i64 2, label %dst.addr.case.2
    i64 3, label %dst.addr.case.3
  ]

dst.addr.case.0:                                  ; preds = %for.loop
  store float %3, float* %dst_0, align 4
  br label %dst.addr.exit

dst.addr.case.1:                                  ; preds = %for.loop
  store float %3, float* %dst_1, align 4
  br label %dst.addr.exit

dst.addr.case.2:                                  ; preds = %for.loop
  store float %3, float* %dst_2, align 4
  br label %dst.addr.exit

dst.addr.case.3:                                  ; preds = %for.loop
  store float %3, float* %dst_3, align 4
  br label %dst.addr.exit

dst.addr.exit:                                    ; preds = %dst.addr.case.3, %dst.addr.case.2, %dst.addr.case.1, %dst.addr.case.0, %for.loop
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx2, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, %num
  br i1 %exitcond, label %for.loop, label %copy.split

copy.split:                                       ; preds = %dst.addr.exit, %copy
  br label %ret

ret:                                              ; preds = %copy.split, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal void @onebyonecpy_hls.p0a4f32.3.6(float* noalias align 512 "orig.arg.no"="0" "unpacked"="0.0" %dst_0, float* noalias align 512 "orig.arg.no"="0" "unpacked"="0.1" %dst_1, float* noalias align 512 "orig.arg.no"="0" "unpacked"="0.2" %dst_2, float* noalias align 512 "orig.arg.no"="0" "unpacked"="0.3" %dst_3, [4 x float]* noalias readonly "orig.arg.no"="1" %src) #3 {
entry:
  %0 = icmp eq float* %dst_0, null
  %1 = icmp eq [4 x float]* %src, null
  %2 = or i1 %0, %1
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  call void @arraycpy_hls.p0a4f32.4.5(float* nonnull %dst_0, float* %dst_1, float* %dst_2, float* %dst_3, [4 x float]* nonnull %src, i64 4)
  br label %ret

ret:                                              ; preds = %copy, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define void @arraycpy_hls.p0a4a32f32.8.9([32 x float]* "orig.arg.no"="0" "unpacked"="0.0" %dst_0, [32 x float]* "orig.arg.no"="0" "unpacked"="0.1" %dst_1, [32 x float]* "orig.arg.no"="0" "unpacked"="0.2" %dst_2, [32 x float]* "orig.arg.no"="0" "unpacked"="0.3" %dst_3, [4 x [32 x float]]* readonly "orig.arg.no"="1" %src, i64 "orig.arg.no"="2" %num) #2 {
entry:
  %0 = icmp eq [4 x [32 x float]]* %src, null
  %1 = icmp eq [32 x float]* %dst_0, null
  %2 = or i1 %1, %0
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  %for.loop.cond1 = icmp sgt i64 %num, 0
  br i1 %for.loop.cond1, label %for.loop.lr.ph, label %copy.split

for.loop.lr.ph:                                   ; preds = %copy
  br label %for.loop

for.loop:                                         ; preds = %dst.addr.exit, %for.loop.lr.ph
  %for.loop.idx2 = phi i64 [ 0, %for.loop.lr.ph ], [ %for.loop.idx.next, %dst.addr.exit ]
  %src.addr = getelementptr [4 x [32 x float]], [4 x [32 x float]]* %src, i64 0, i64 %for.loop.idx2
  switch i64 %for.loop.idx2, label %dst.addr.default [
    i64 0, label %dst.addr.case.0
    i64 1, label %dst.addr.case.1
    i64 2, label %dst.addr.case.2
    i64 3, label %dst.addr.case.3
  ]

dst.addr.default:                                 ; preds = %for.loop
  call void @arraycpy_hls.p0a32f32([32 x float]* %dst_0, [32 x float]* %src.addr, i64 32)
  br label %dst.addr.exit

dst.addr.case.0:                                  ; preds = %for.loop
  call void @arraycpy_hls.p0a32f32([32 x float]* %dst_0, [32 x float]* %src.addr, i64 32)
  br label %dst.addr.exit

dst.addr.case.1:                                  ; preds = %for.loop
  call void @arraycpy_hls.p0a32f32([32 x float]* %dst_1, [32 x float]* %src.addr, i64 32)
  br label %dst.addr.exit

dst.addr.case.2:                                  ; preds = %for.loop
  call void @arraycpy_hls.p0a32f32([32 x float]* %dst_2, [32 x float]* %src.addr, i64 32)
  br label %dst.addr.exit

dst.addr.case.3:                                  ; preds = %for.loop
  call void @arraycpy_hls.p0a32f32([32 x float]* %dst_3, [32 x float]* %src.addr, i64 32)
  br label %dst.addr.exit

dst.addr.exit:                                    ; preds = %dst.addr.case.3, %dst.addr.case.2, %dst.addr.case.1, %dst.addr.case.0, %dst.addr.default
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx2, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, %num
  br i1 %exitcond, label %for.loop, label %copy.split

copy.split:                                       ; preds = %dst.addr.exit, %copy
  br label %ret

ret:                                              ; preds = %copy.split, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal void @onebyonecpy_hls.p0a4a32f32.7.10([32 x float]* noalias align 512 "orig.arg.no"="0" "unpacked"="0.0" %dst_0, [32 x float]* noalias align 512 "orig.arg.no"="0" "unpacked"="0.1" %dst_1, [32 x float]* noalias align 512 "orig.arg.no"="0" "unpacked"="0.2" %dst_2, [32 x float]* noalias align 512 "orig.arg.no"="0" "unpacked"="0.3" %dst_3, [4 x [32 x float]]* noalias readonly "orig.arg.no"="1" %src) #3 {
entry:
  %0 = icmp eq [32 x float]* %dst_0, null
  %1 = icmp eq [4 x [32 x float]]* %src, null
  %2 = or i1 %0, %1
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  call void @arraycpy_hls.p0a4a32f32.8.9([32 x float]* nonnull %dst_0, [32 x float]* %dst_1, [32 x float]* %dst_2, [32 x float]* %dst_3, [4 x [32 x float]]* nonnull %src, i64 4)
  br label %ret

ret:                                              ; preds = %copy, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define void @arraycpy_hls.p0a4a4f32.12.13([4 x float]* "orig.arg.no"="0" "unpacked"="0.0" %dst_0, [4 x float]* "orig.arg.no"="0" "unpacked"="0.1" %dst_1, [4 x float]* "orig.arg.no"="0" "unpacked"="0.2" %dst_2, [4 x float]* "orig.arg.no"="0" "unpacked"="0.3" %dst_3, [4 x [4 x float]]* readonly "orig.arg.no"="1" %src, i64 "orig.arg.no"="2" %num) #2 {
entry:
  %0 = icmp eq [4 x [4 x float]]* %src, null
  %1 = icmp eq [4 x float]* %dst_0, null
  %2 = or i1 %1, %0
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  %for.loop.cond1 = icmp sgt i64 %num, 0
  br i1 %for.loop.cond1, label %for.loop.lr.ph, label %copy.split

for.loop.lr.ph:                                   ; preds = %copy
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %for.loop.lr.ph
  %for.loop.idx2 = phi i64 [ 0, %for.loop.lr.ph ], [ %for.loop.idx.next, %for.loop ]
  %dst.addr_0 = getelementptr [4 x float], [4 x float]* %dst_0, i64 0, i64 %for.loop.idx2
  %dst.addr_1 = getelementptr [4 x float], [4 x float]* %dst_1, i64 0, i64 %for.loop.idx2
  %dst.addr_2 = getelementptr [4 x float], [4 x float]* %dst_2, i64 0, i64 %for.loop.idx2
  %dst.addr_3 = getelementptr [4 x float], [4 x float]* %dst_3, i64 0, i64 %for.loop.idx2
  %src.addr = getelementptr [4 x [4 x float]], [4 x [4 x float]]* %src, i64 0, i64 %for.loop.idx2
  call void @arraycpy_hls.p0a4f32.4.5(float* %dst.addr_0, float* %dst.addr_1, float* %dst.addr_2, float* %dst.addr_3, [4 x float]* %src.addr, i64 4)
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx2, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, %num
  br i1 %exitcond, label %for.loop, label %copy.split

copy.split:                                       ; preds = %for.loop, %copy
  br label %ret

ret:                                              ; preds = %copy.split, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal void @onebyonecpy_hls.p0a4a4f32.11.14([4 x float]* noalias align 512 "orig.arg.no"="0" "unpacked"="0.0" %dst_0, [4 x float]* noalias align 512 "orig.arg.no"="0" "unpacked"="0.1" %dst_1, [4 x float]* noalias align 512 "orig.arg.no"="0" "unpacked"="0.2" %dst_2, [4 x float]* noalias align 512 "orig.arg.no"="0" "unpacked"="0.3" %dst_3, [4 x [4 x float]]* noalias readonly "orig.arg.no"="1" %src) #3 {
entry:
  %0 = icmp eq [4 x float]* %dst_0, null
  %1 = icmp eq [4 x [4 x float]]* %src, null
  %2 = or i1 %0, %1
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  call void @arraycpy_hls.p0a4a4f32.12.13([4 x float]* nonnull %dst_0, [4 x float]* %dst_1, [4 x float]* %dst_2, [4 x float]* %dst_3, [4 x [4 x float]]* nonnull %src, i64 4)
  br label %ret

ret:                                              ; preds = %copy, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal void @copy_in([4 x float]* noalias readonly "orig.arg.no"="0", float* noalias align 512 "orig.arg.no"="1" "unpacked"="1.0" %_0, float* noalias align 512 "orig.arg.no"="1" "unpacked"="1.1" %_1, float* noalias align 512 "orig.arg.no"="1" "unpacked"="1.2" %_2, float* noalias align 512 "orig.arg.no"="1" "unpacked"="1.3" %_3, [4 x [32 x float]]* noalias readonly "orig.arg.no"="2", [32 x float]* noalias align 512 "orig.arg.no"="3" "unpacked"="3.0" %_01, [32 x float]* noalias align 512 "orig.arg.no"="3" "unpacked"="3.1" %_12, [32 x float]* noalias align 512 "orig.arg.no"="3" "unpacked"="3.2" %_23, [32 x float]* noalias align 512 "orig.arg.no"="3" "unpacked"="3.3" %_34, [4 x [4 x float]]* noalias readonly "orig.arg.no"="4", [4 x float]* noalias align 512 "orig.arg.no"="5" "unpacked"="5.0" %_05, [4 x float]* noalias align 512 "orig.arg.no"="5" "unpacked"="5.1" %_16, [4 x float]* noalias align 512 "orig.arg.no"="5" "unpacked"="5.2" %_27, [4 x float]* noalias align 512 "orig.arg.no"="5" "unpacked"="5.3" %_38, [4 x float]* noalias readonly "orig.arg.no"="6", float* noalias align 512 "orig.arg.no"="7" "unpacked"="7.0" %_09, float* noalias align 512 "orig.arg.no"="7" "unpacked"="7.1" %_110, float* noalias align 512 "orig.arg.no"="7" "unpacked"="7.2" %_211, float* noalias align 512 "orig.arg.no"="7" "unpacked"="7.3" %_312, [4 x [32 x float]]* noalias readonly "orig.arg.no"="8", [32 x float]* noalias align 512 "orig.arg.no"="9" "unpacked"="9.0" %_013, [32 x float]* noalias align 512 "orig.arg.no"="9" "unpacked"="9.1" %_114, [32 x float]* noalias align 512 "orig.arg.no"="9" "unpacked"="9.2" %_215, [32 x float]* noalias align 512 "orig.arg.no"="9" "unpacked"="9.3" %_316, [4 x float]* noalias readonly "orig.arg.no"="10", float* noalias align 512 "orig.arg.no"="11" "unpacked"="11.0" %_017, float* noalias align 512 "orig.arg.no"="11" "unpacked"="11.1" %_118, float* noalias align 512 "orig.arg.no"="11" "unpacked"="11.2" %_219, float* noalias align 512 "orig.arg.no"="11" "unpacked"="11.3" %_320, [4 x [32 x float]]* noalias readonly "orig.arg.no"="12", [32 x float]* noalias align 512 "orig.arg.no"="13" "unpacked"="13.0" %_021, [32 x float]* noalias align 512 "orig.arg.no"="13" "unpacked"="13.1" %_122, [32 x float]* noalias align 512 "orig.arg.no"="13" "unpacked"="13.2" %_223, [32 x float]* noalias align 512 "orig.arg.no"="13" "unpacked"="13.3" %_324, i32* noalias readonly "orig.arg.no"="14", i32* noalias align 512 "orig.arg.no"="15") #4 {
entry:
  call void @onebyonecpy_hls.p0a4f32.3.6(float* align 512 %_0, float* align 512 %_1, float* align 512 %_2, float* align 512 %_3, [4 x float]* %0)
  call void @onebyonecpy_hls.p0a4a32f32.7.10([32 x float]* align 512 %_01, [32 x float]* align 512 %_12, [32 x float]* align 512 %_23, [32 x float]* align 512 %_34, [4 x [32 x float]]* %1)
  call void @onebyonecpy_hls.p0a4a4f32.11.14([4 x float]* align 512 %_05, [4 x float]* align 512 %_16, [4 x float]* align 512 %_27, [4 x float]* align 512 %_38, [4 x [4 x float]]* %2)
  call void @onebyonecpy_hls.p0a4f32.3.6(float* align 512 %_09, float* align 512 %_110, float* align 512 %_211, float* align 512 %_312, [4 x float]* %3)
  call void @onebyonecpy_hls.p0a4a32f32.7.10([32 x float]* align 512 %_013, [32 x float]* align 512 %_114, [32 x float]* align 512 %_215, [32 x float]* align 512 %_316, [4 x [32 x float]]* %4)
  call void @onebyonecpy_hls.p0a4f32.3.6(float* align 512 %_017, float* align 512 %_118, float* align 512 %_219, float* align 512 %_320, [4 x float]* %5)
  call void @onebyonecpy_hls.p0a4a32f32.7.10([32 x float]* align 512 %_021, [32 x float]* align 512 %_122, [32 x float]* align 512 %_223, [32 x float]* align 512 %_324, [4 x [32 x float]]* %6)
  call fastcc void @onebyonecpy_hls.p0i32(i32* align 512 %8, i32* %7)
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define void @arraycpy_hls.p0a4f32.20.21([4 x float]* "orig.arg.no"="0" %dst, float* readonly "orig.arg.no"="1" "unpacked"="1.0" %src_0, float* readonly "orig.arg.no"="1" "unpacked"="1.1" %src_1, float* readonly "orig.arg.no"="1" "unpacked"="1.2" %src_2, float* readonly "orig.arg.no"="1" "unpacked"="1.3" %src_3, i64 "orig.arg.no"="2" %num) #2 {
entry:
  %0 = icmp eq float* %src_0, null
  %1 = icmp eq [4 x float]* %dst, null
  %2 = or i1 %1, %0
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  %for.loop.cond1 = icmp sgt i64 %num, 0
  br i1 %for.loop.cond1, label %for.loop.lr.ph, label %copy.split

for.loop.lr.ph:                                   ; preds = %copy
  br label %for.loop

for.loop:                                         ; preds = %src.addr.exit, %for.loop.lr.ph
  %for.loop.idx2 = phi i64 [ 0, %for.loop.lr.ph ], [ %for.loop.idx.next, %src.addr.exit ]
  %dst.addr = getelementptr [4 x float], [4 x float]* %dst, i64 0, i64 %for.loop.idx2
  switch i64 %for.loop.idx2, label %src.addr.exit [
    i64 0, label %src.addr.case.0
    i64 1, label %src.addr.case.1
    i64 2, label %src.addr.case.2
    i64 3, label %src.addr.case.3
  ]

src.addr.case.0:                                  ; preds = %for.loop
  %_0 = load float, float* %src_0, align 4
  br label %src.addr.exit

src.addr.case.1:                                  ; preds = %for.loop
  %_1 = load float, float* %src_1, align 4
  br label %src.addr.exit

src.addr.case.2:                                  ; preds = %for.loop
  %_2 = load float, float* %src_2, align 4
  br label %src.addr.exit

src.addr.case.3:                                  ; preds = %for.loop
  %_3 = load float, float* %src_3, align 4
  br label %src.addr.exit

src.addr.exit:                                    ; preds = %src.addr.case.3, %src.addr.case.2, %src.addr.case.1, %src.addr.case.0, %for.loop
  %3 = phi float [ %_0, %src.addr.case.0 ], [ %_1, %src.addr.case.1 ], [ %_2, %src.addr.case.2 ], [ %_3, %src.addr.case.3 ], [ undef, %for.loop ]
  store float %3, float* %dst.addr, align 4
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx2, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, %num
  br i1 %exitcond, label %for.loop, label %copy.split

copy.split:                                       ; preds = %src.addr.exit, %copy
  br label %ret

ret:                                              ; preds = %copy.split, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal void @onebyonecpy_hls.p0a4f32.19.22([4 x float]* noalias "orig.arg.no"="0" %dst, float* noalias readonly align 512 "orig.arg.no"="1" "unpacked"="1.0" %src_0, float* noalias readonly align 512 "orig.arg.no"="1" "unpacked"="1.1" %src_1, float* noalias readonly align 512 "orig.arg.no"="1" "unpacked"="1.2" %src_2, float* noalias readonly align 512 "orig.arg.no"="1" "unpacked"="1.3" %src_3) #3 {
entry:
  %0 = icmp eq [4 x float]* %dst, null
  %1 = icmp eq float* %src_0, null
  %2 = or i1 %0, %1
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  call void @arraycpy_hls.p0a4f32.20.21([4 x float]* nonnull %dst, float* nonnull %src_0, float* %src_1, float* %src_2, float* %src_3, i64 4)
  br label %ret

ret:                                              ; preds = %copy, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define void @arraycpy_hls.p0a4a32f32.24.25([4 x [32 x float]]* "orig.arg.no"="0" %dst, [32 x float]* readonly "orig.arg.no"="1" "unpacked"="1.0" %src_0, [32 x float]* readonly "orig.arg.no"="1" "unpacked"="1.1" %src_1, [32 x float]* readonly "orig.arg.no"="1" "unpacked"="1.2" %src_2, [32 x float]* readonly "orig.arg.no"="1" "unpacked"="1.3" %src_3, i64 "orig.arg.no"="2" %num) #2 {
entry:
  %0 = icmp eq [32 x float]* %src_0, null
  %1 = icmp eq [4 x [32 x float]]* %dst, null
  %2 = or i1 %1, %0
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  %for.loop.cond1 = icmp sgt i64 %num, 0
  br i1 %for.loop.cond1, label %for.loop.lr.ph, label %copy.split

for.loop.lr.ph:                                   ; preds = %copy
  br label %for.loop

for.loop:                                         ; preds = %src.addr.exit, %for.loop.lr.ph
  %for.loop.idx2 = phi i64 [ 0, %for.loop.lr.ph ], [ %for.loop.idx.next, %src.addr.exit ]
  %dst.addr = getelementptr [4 x [32 x float]], [4 x [32 x float]]* %dst, i64 0, i64 %for.loop.idx2
  switch i64 %for.loop.idx2, label %src.addr.default [
    i64 0, label %src.addr.case.0
    i64 1, label %src.addr.case.1
    i64 2, label %src.addr.case.2
    i64 3, label %src.addr.case.3
  ]

src.addr.default:                                 ; preds = %for.loop
  call void @arraycpy_hls.p0a32f32([32 x float]* %dst.addr, [32 x float]* %src_0, i64 32)
  br label %src.addr.exit

src.addr.case.0:                                  ; preds = %for.loop
  call void @arraycpy_hls.p0a32f32([32 x float]* %dst.addr, [32 x float]* %src_0, i64 32)
  br label %src.addr.exit

src.addr.case.1:                                  ; preds = %for.loop
  call void @arraycpy_hls.p0a32f32([32 x float]* %dst.addr, [32 x float]* %src_1, i64 32)
  br label %src.addr.exit

src.addr.case.2:                                  ; preds = %for.loop
  call void @arraycpy_hls.p0a32f32([32 x float]* %dst.addr, [32 x float]* %src_2, i64 32)
  br label %src.addr.exit

src.addr.case.3:                                  ; preds = %for.loop
  call void @arraycpy_hls.p0a32f32([32 x float]* %dst.addr, [32 x float]* %src_3, i64 32)
  br label %src.addr.exit

src.addr.exit:                                    ; preds = %src.addr.case.3, %src.addr.case.2, %src.addr.case.1, %src.addr.case.0, %src.addr.default
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx2, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, %num
  br i1 %exitcond, label %for.loop, label %copy.split

copy.split:                                       ; preds = %src.addr.exit, %copy
  br label %ret

ret:                                              ; preds = %copy.split, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal void @onebyonecpy_hls.p0a4a32f32.23.26([4 x [32 x float]]* noalias "orig.arg.no"="0" %dst, [32 x float]* noalias readonly align 512 "orig.arg.no"="1" "unpacked"="1.0" %src_0, [32 x float]* noalias readonly align 512 "orig.arg.no"="1" "unpacked"="1.1" %src_1, [32 x float]* noalias readonly align 512 "orig.arg.no"="1" "unpacked"="1.2" %src_2, [32 x float]* noalias readonly align 512 "orig.arg.no"="1" "unpacked"="1.3" %src_3) #3 {
entry:
  %0 = icmp eq [4 x [32 x float]]* %dst, null
  %1 = icmp eq [32 x float]* %src_0, null
  %2 = or i1 %0, %1
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  call void @arraycpy_hls.p0a4a32f32.24.25([4 x [32 x float]]* nonnull %dst, [32 x float]* nonnull %src_0, [32 x float]* %src_1, [32 x float]* %src_2, [32 x float]* %src_3, i64 4)
  br label %ret

ret:                                              ; preds = %copy, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define void @arraycpy_hls.p0a4a4f32.28.29([4 x [4 x float]]* "orig.arg.no"="0" %dst, [4 x float]* readonly "orig.arg.no"="1" "unpacked"="1.0" %src_0, [4 x float]* readonly "orig.arg.no"="1" "unpacked"="1.1" %src_1, [4 x float]* readonly "orig.arg.no"="1" "unpacked"="1.2" %src_2, [4 x float]* readonly "orig.arg.no"="1" "unpacked"="1.3" %src_3, i64 "orig.arg.no"="2" %num) #2 {
entry:
  %0 = icmp eq [4 x float]* %src_0, null
  %1 = icmp eq [4 x [4 x float]]* %dst, null
  %2 = or i1 %1, %0
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  %for.loop.cond1 = icmp sgt i64 %num, 0
  br i1 %for.loop.cond1, label %for.loop.lr.ph, label %copy.split

for.loop.lr.ph:                                   ; preds = %copy
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %for.loop.lr.ph
  %for.loop.idx2 = phi i64 [ 0, %for.loop.lr.ph ], [ %for.loop.idx.next, %for.loop ]
  %dst.addr = getelementptr [4 x [4 x float]], [4 x [4 x float]]* %dst, i64 0, i64 %for.loop.idx2
  %src.addr_0 = getelementptr [4 x float], [4 x float]* %src_0, i64 0, i64 %for.loop.idx2
  %src.addr_1 = getelementptr [4 x float], [4 x float]* %src_1, i64 0, i64 %for.loop.idx2
  %src.addr_2 = getelementptr [4 x float], [4 x float]* %src_2, i64 0, i64 %for.loop.idx2
  %src.addr_3 = getelementptr [4 x float], [4 x float]* %src_3, i64 0, i64 %for.loop.idx2
  call void @arraycpy_hls.p0a4f32.20.21([4 x float]* %dst.addr, float* %src.addr_0, float* %src.addr_1, float* %src.addr_2, float* %src.addr_3, i64 4)
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx2, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, %num
  br i1 %exitcond, label %for.loop, label %copy.split

copy.split:                                       ; preds = %for.loop, %copy
  br label %ret

ret:                                              ; preds = %copy.split, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal void @onebyonecpy_hls.p0a4a4f32.27.30([4 x [4 x float]]* noalias "orig.arg.no"="0" %dst, [4 x float]* noalias readonly align 512 "orig.arg.no"="1" "unpacked"="1.0" %src_0, [4 x float]* noalias readonly align 512 "orig.arg.no"="1" "unpacked"="1.1" %src_1, [4 x float]* noalias readonly align 512 "orig.arg.no"="1" "unpacked"="1.2" %src_2, [4 x float]* noalias readonly align 512 "orig.arg.no"="1" "unpacked"="1.3" %src_3) #3 {
entry:
  %0 = icmp eq [4 x [4 x float]]* %dst, null
  %1 = icmp eq [4 x float]* %src_0, null
  %2 = or i1 %0, %1
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  call void @arraycpy_hls.p0a4a4f32.28.29([4 x [4 x float]]* nonnull %dst, [4 x float]* nonnull %src_0, [4 x float]* %src_1, [4 x float]* %src_2, [4 x float]* %src_3, i64 4)
  br label %ret

ret:                                              ; preds = %copy, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal void @copy_out([4 x float]* noalias "orig.arg.no"="0", float* noalias readonly align 512 "orig.arg.no"="1" "unpacked"="1.0" %_0, float* noalias readonly align 512 "orig.arg.no"="1" "unpacked"="1.1" %_1, float* noalias readonly align 512 "orig.arg.no"="1" "unpacked"="1.2" %_2, float* noalias readonly align 512 "orig.arg.no"="1" "unpacked"="1.3" %_3, [4 x [32 x float]]* noalias "orig.arg.no"="2", [32 x float]* noalias readonly align 512 "orig.arg.no"="3" "unpacked"="3.0" %_01, [32 x float]* noalias readonly align 512 "orig.arg.no"="3" "unpacked"="3.1" %_12, [32 x float]* noalias readonly align 512 "orig.arg.no"="3" "unpacked"="3.2" %_23, [32 x float]* noalias readonly align 512 "orig.arg.no"="3" "unpacked"="3.3" %_34, [4 x [4 x float]]* noalias "orig.arg.no"="4", [4 x float]* noalias readonly align 512 "orig.arg.no"="5" "unpacked"="5.0" %_05, [4 x float]* noalias readonly align 512 "orig.arg.no"="5" "unpacked"="5.1" %_16, [4 x float]* noalias readonly align 512 "orig.arg.no"="5" "unpacked"="5.2" %_27, [4 x float]* noalias readonly align 512 "orig.arg.no"="5" "unpacked"="5.3" %_38, [4 x float]* noalias "orig.arg.no"="6", float* noalias readonly align 512 "orig.arg.no"="7" "unpacked"="7.0" %_09, float* noalias readonly align 512 "orig.arg.no"="7" "unpacked"="7.1" %_110, float* noalias readonly align 512 "orig.arg.no"="7" "unpacked"="7.2" %_211, float* noalias readonly align 512 "orig.arg.no"="7" "unpacked"="7.3" %_312, [4 x [32 x float]]* noalias "orig.arg.no"="8", [32 x float]* noalias readonly align 512 "orig.arg.no"="9" "unpacked"="9.0" %_013, [32 x float]* noalias readonly align 512 "orig.arg.no"="9" "unpacked"="9.1" %_114, [32 x float]* noalias readonly align 512 "orig.arg.no"="9" "unpacked"="9.2" %_215, [32 x float]* noalias readonly align 512 "orig.arg.no"="9" "unpacked"="9.3" %_316, [4 x float]* noalias "orig.arg.no"="10", float* noalias readonly align 512 "orig.arg.no"="11" "unpacked"="11.0" %_017, float* noalias readonly align 512 "orig.arg.no"="11" "unpacked"="11.1" %_118, float* noalias readonly align 512 "orig.arg.no"="11" "unpacked"="11.2" %_219, float* noalias readonly align 512 "orig.arg.no"="11" "unpacked"="11.3" %_320, [4 x [32 x float]]* noalias "orig.arg.no"="12", [32 x float]* noalias readonly align 512 "orig.arg.no"="13" "unpacked"="13.0" %_021, [32 x float]* noalias readonly align 512 "orig.arg.no"="13" "unpacked"="13.1" %_122, [32 x float]* noalias readonly align 512 "orig.arg.no"="13" "unpacked"="13.2" %_223, [32 x float]* noalias readonly align 512 "orig.arg.no"="13" "unpacked"="13.3" %_324, i32* noalias "orig.arg.no"="14", i32* noalias readonly align 512 "orig.arg.no"="15") #5 {
entry:
  call void @onebyonecpy_hls.p0a4f32.19.22([4 x float]* %0, float* align 512 %_0, float* align 512 %_1, float* align 512 %_2, float* align 512 %_3)
  call void @onebyonecpy_hls.p0a4a32f32.23.26([4 x [32 x float]]* %1, [32 x float]* align 512 %_01, [32 x float]* align 512 %_12, [32 x float]* align 512 %_23, [32 x float]* align 512 %_34)
  call void @onebyonecpy_hls.p0a4a4f32.27.30([4 x [4 x float]]* %2, [4 x float]* align 512 %_05, [4 x float]* align 512 %_16, [4 x float]* align 512 %_27, [4 x float]* align 512 %_38)
  call void @onebyonecpy_hls.p0a4f32.19.22([4 x float]* %3, float* align 512 %_09, float* align 512 %_110, float* align 512 %_211, float* align 512 %_312)
  call void @onebyonecpy_hls.p0a4a32f32.23.26([4 x [32 x float]]* %4, [32 x float]* align 512 %_013, [32 x float]* align 512 %_114, [32 x float]* align 512 %_215, [32 x float]* align 512 %_316)
  call void @onebyonecpy_hls.p0a4f32.19.22([4 x float]* %5, float* align 512 %_017, float* align 512 %_118, float* align 512 %_219, float* align 512 %_320)
  call void @onebyonecpy_hls.p0a4a32f32.23.26([4 x [32 x float]]* %6, [32 x float]* align 512 %_021, [32 x float]* align 512 %_122, [32 x float]* align 512 %_223, [32 x float]* align 512 %_324)
  call fastcc void @onebyonecpy_hls.p0i32(i32* %7, i32* align 512 %8)
  ret void
}

declare i8* @malloc(i64)

declare void @free(i8*)

declare void @apatb_predict_kernel_hw(float*, float*, float*, float*, [32 x float]*, [32 x float]*, [32 x float]*, [32 x float]*, i32, [4 x float]*, [4 x float]*, [4 x float]*, [4 x float]*, float*, float*, float*, float*, [32 x float]*, [32 x float]*, [32 x float]*, [32 x float]*, i32, float*, float*, float*, float*, [32 x float]*, [32 x float]*, [32 x float]*, [32 x float]*, i32*)

; Function Attrs: argmemonly noinline norecurse willreturn
define internal void @copy_back([4 x float]* noalias "orig.arg.no"="0", float* noalias readonly align 512 "orig.arg.no"="1" "unpacked"="1.0" %_0, float* noalias readonly align 512 "orig.arg.no"="1" "unpacked"="1.1" %_1, float* noalias readonly align 512 "orig.arg.no"="1" "unpacked"="1.2" %_2, float* noalias readonly align 512 "orig.arg.no"="1" "unpacked"="1.3" %_3, [4 x [32 x float]]* noalias "orig.arg.no"="2", [32 x float]* noalias readonly align 512 "orig.arg.no"="3" "unpacked"="3.0" %_01, [32 x float]* noalias readonly align 512 "orig.arg.no"="3" "unpacked"="3.1" %_12, [32 x float]* noalias readonly align 512 "orig.arg.no"="3" "unpacked"="3.2" %_23, [32 x float]* noalias readonly align 512 "orig.arg.no"="3" "unpacked"="3.3" %_34, [4 x [4 x float]]* noalias "orig.arg.no"="4", [4 x float]* noalias readonly align 512 "orig.arg.no"="5" "unpacked"="5.0" %_05, [4 x float]* noalias readonly align 512 "orig.arg.no"="5" "unpacked"="5.1" %_16, [4 x float]* noalias readonly align 512 "orig.arg.no"="5" "unpacked"="5.2" %_27, [4 x float]* noalias readonly align 512 "orig.arg.no"="5" "unpacked"="5.3" %_38, [4 x float]* noalias "orig.arg.no"="6", float* noalias readonly align 512 "orig.arg.no"="7" "unpacked"="7.0" %_09, float* noalias readonly align 512 "orig.arg.no"="7" "unpacked"="7.1" %_110, float* noalias readonly align 512 "orig.arg.no"="7" "unpacked"="7.2" %_211, float* noalias readonly align 512 "orig.arg.no"="7" "unpacked"="7.3" %_312, [4 x [32 x float]]* noalias "orig.arg.no"="8", [32 x float]* noalias readonly align 512 "orig.arg.no"="9" "unpacked"="9.0" %_013, [32 x float]* noalias readonly align 512 "orig.arg.no"="9" "unpacked"="9.1" %_114, [32 x float]* noalias readonly align 512 "orig.arg.no"="9" "unpacked"="9.2" %_215, [32 x float]* noalias readonly align 512 "orig.arg.no"="9" "unpacked"="9.3" %_316, [4 x float]* noalias "orig.arg.no"="10", float* noalias readonly align 512 "orig.arg.no"="11" "unpacked"="11.0" %_017, float* noalias readonly align 512 "orig.arg.no"="11" "unpacked"="11.1" %_118, float* noalias readonly align 512 "orig.arg.no"="11" "unpacked"="11.2" %_219, float* noalias readonly align 512 "orig.arg.no"="11" "unpacked"="11.3" %_320, [4 x [32 x float]]* noalias "orig.arg.no"="12", [32 x float]* noalias readonly align 512 "orig.arg.no"="13" "unpacked"="13.0" %_021, [32 x float]* noalias readonly align 512 "orig.arg.no"="13" "unpacked"="13.1" %_122, [32 x float]* noalias readonly align 512 "orig.arg.no"="13" "unpacked"="13.2" %_223, [32 x float]* noalias readonly align 512 "orig.arg.no"="13" "unpacked"="13.3" %_324, i32* noalias "orig.arg.no"="14", i32* noalias readonly align 512 "orig.arg.no"="15") #5 {
entry:
  call void @onebyonecpy_hls.p0a4f32.19.22([4 x float]* %5, float* align 512 %_017, float* align 512 %_118, float* align 512 %_219, float* align 512 %_320)
  call void @onebyonecpy_hls.p0a4a32f32.23.26([4 x [32 x float]]* %6, [32 x float]* align 512 %_021, [32 x float]* align 512 %_122, [32 x float]* align 512 %_223, [32 x float]* align 512 %_324)
  call fastcc void @onebyonecpy_hls.p0i32(i32* %7, i32* align 512 %8)
  ret void
}

declare void @predict_kernel_hw_stub(float* noalias nocapture nonnull readonly, [32 x float]* noalias nocapture nonnull readonly, i32, [4 x float]* noalias nocapture nonnull readonly, float* noalias nocapture nonnull readonly, [32 x float]* noalias nocapture nonnull readonly, i32, float* noalias nocapture nonnull, [32 x float]* noalias nocapture nonnull, i32* noalias nocapture nonnull)

define void @predict_kernel_hw_stub_wrapper(float*, float*, float*, float*, [32 x float]*, [32 x float]*, [32 x float]*, [32 x float]*, i32, [4 x float]*, [4 x float]*, [4 x float]*, [4 x float]*, float*, float*, float*, float*, [32 x float]*, [32 x float]*, [32 x float]*, [32 x float]*, i32, float*, float*, float*, float*, [32 x float]*, [32 x float]*, [32 x float]*, [32 x float]*, i32*) #6 {
entry:
  %31 = call i8* @malloc(i64 16)
  %32 = bitcast i8* %31 to [4 x float]*
  %33 = call i8* @malloc(i64 512)
  %34 = bitcast i8* %33 to [4 x [32 x float]]*
  %35 = call i8* @malloc(i64 64)
  %36 = bitcast i8* %35 to [4 x [4 x float]]*
  %37 = call i8* @malloc(i64 16)
  %38 = bitcast i8* %37 to [4 x float]*
  %39 = call i8* @malloc(i64 512)
  %40 = bitcast i8* %39 to [4 x [32 x float]]*
  %41 = call i8* @malloc(i64 16)
  %42 = bitcast i8* %41 to [4 x float]*
  %43 = call i8* @malloc(i64 512)
  %44 = bitcast i8* %43 to [4 x [32 x float]]*
  call void @copy_out([4 x float]* %32, float* %0, float* %1, float* %2, float* %3, [4 x [32 x float]]* %34, [32 x float]* %4, [32 x float]* %5, [32 x float]* %6, [32 x float]* %7, [4 x [4 x float]]* %36, [4 x float]* %9, [4 x float]* %10, [4 x float]* %11, [4 x float]* %12, [4 x float]* %38, float* %13, float* %14, float* %15, float* %16, [4 x [32 x float]]* %40, [32 x float]* %17, [32 x float]* %18, [32 x float]* %19, [32 x float]* %20, [4 x float]* %42, float* %22, float* %23, float* %24, float* %25, [4 x [32 x float]]* %44, [32 x float]* %26, [32 x float]* %27, [32 x float]* %28, [32 x float]* %29, i32* null, i32* %30)
  %45 = bitcast [4 x float]* %32 to float*
  %46 = bitcast [4 x [32 x float]]* %34 to [32 x float]*
  %47 = bitcast [4 x [4 x float]]* %36 to [4 x float]*
  %48 = bitcast [4 x float]* %38 to float*
  %49 = bitcast [4 x [32 x float]]* %40 to [32 x float]*
  %50 = bitcast [4 x float]* %42 to float*
  %51 = bitcast [4 x [32 x float]]* %44 to [32 x float]*
  call void @predict_kernel_hw_stub(float* %45, [32 x float]* %46, i32 %8, [4 x float]* %47, float* %48, [32 x float]* %49, i32 %21, float* %50, [32 x float]* %51, i32* %30)
  call void @copy_in([4 x float]* %32, float* %0, float* %1, float* %2, float* %3, [4 x [32 x float]]* %34, [32 x float]* %4, [32 x float]* %5, [32 x float]* %6, [32 x float]* %7, [4 x [4 x float]]* %36, [4 x float]* %9, [4 x float]* %10, [4 x float]* %11, [4 x float]* %12, [4 x float]* %38, float* %13, float* %14, float* %15, float* %16, [4 x [32 x float]]* %40, [32 x float]* %17, [32 x float]* %18, [32 x float]* %19, [32 x float]* %20, [4 x float]* %42, float* %22, float* %23, float* %24, float* %25, [4 x [32 x float]]* %44, [32 x float]* %26, [32 x float]* %27, [32 x float]* %28, [32 x float]* %29, i32* null, i32* %30)
  call void @free(i8* %31)
  call void @free(i8* %33)
  call void @free(i8* %35)
  call void @free(i8* %37)
  call void @free(i8* %39)
  call void @free(i8* %41)
  call void @free(i8* %43)
  ret void
}

attributes #0 = { inaccessiblememonly nounwind willreturn }
attributes #1 = { inaccessiblemem_or_argmemonly noinline willreturn "fpga.wrapper.func"="wrapper" }
attributes #2 = { argmemonly noinline norecurse willreturn "fpga.wrapper.func"="arraycpy_hls" }
attributes #3 = { argmemonly noinline norecurse willreturn "fpga.wrapper.func"="onebyonecpy_hls" }
attributes #4 = { argmemonly noinline norecurse willreturn "fpga.wrapper.func"="copyin" }
attributes #5 = { argmemonly noinline norecurse willreturn "fpga.wrapper.func"="copyout" }
attributes #6 = { "fpga.wrapper.func"="stub" }
attributes #7 = { inaccessiblememonly nounwind willreturn "xlx.source"="infer-from-pragma" }

!llvm.dbg.cu = !{}
!llvm.ident = !{!0, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1}
!llvm.module.flags = !{!2, !3, !4}
!blackbox_cfg = !{!5}
!datalayout.transforms.on.top = !{!6, !16, !24, !34, !42, !50, !58}

!0 = !{!"AMD/Xilinx clang version 16.0.6"}
!1 = !{!"clang version 7.0.0 "}
!2 = !{i32 2, !"Dwarf Version", i32 4}
!3 = !{i32 2, !"Debug Info Version", i32 3}
!4 = !{i32 1, !"wchar_size", i32 4}
!5 = !{}
!6 = !{!7, !9, !11}
!7 = !{!8}
!8 = !{!"0", [4 x float]* null}
!9 = !{!10}
!10 = !{!"array_partition", !"type=Complete", !"dim=1"}
!11 = !{!12, !13, !14, !15}
!12 = !{!"0.0", float* null}
!13 = !{!"0.1", float* null}
!14 = !{!"0.2", float* null}
!15 = !{!"0.3", float* null}
!16 = !{!17, !9, !19}
!17 = !{!18}
!18 = !{!"1", [4 x [32 x float]]* null}
!19 = !{!20, !21, !22, !23}
!20 = !{!"1.0", [32 x float]* null}
!21 = !{!"1.1", [32 x float]* null}
!22 = !{!"1.2", [32 x float]* null}
!23 = !{!"1.3", [32 x float]* null}
!24 = !{!25, !27, !29}
!25 = !{!26}
!26 = !{!"3", [4 x [4 x float]]* null}
!27 = !{!28}
!28 = !{!"array_partition", !"type=Complete", !"dim=2"}
!29 = !{!30, !31, !32, !33}
!30 = !{!"3.0", [4 x float]* null}
!31 = !{!"3.1", [4 x float]* null}
!32 = !{!"3.2", [4 x float]* null}
!33 = !{!"3.3", [4 x float]* null}
!34 = !{!35, !9, !37}
!35 = !{!36}
!36 = !{!"4", [4 x float]* null}
!37 = !{!38, !39, !40, !41}
!38 = !{!"4.0", float* null}
!39 = !{!"4.1", float* null}
!40 = !{!"4.2", float* null}
!41 = !{!"4.3", float* null}
!42 = !{!43, !9, !45}
!43 = !{!44}
!44 = !{!"5", [4 x [32 x float]]* null}
!45 = !{!46, !47, !48, !49}
!46 = !{!"5.0", [32 x float]* null}
!47 = !{!"5.1", [32 x float]* null}
!48 = !{!"5.2", [32 x float]* null}
!49 = !{!"5.3", [32 x float]* null}
!50 = !{!51, !9, !53}
!51 = !{!52}
!52 = !{!"7", [4 x float]* null}
!53 = !{!54, !55, !56, !57}
!54 = !{!"7.0", float* null}
!55 = !{!"7.1", float* null}
!56 = !{!"7.2", float* null}
!57 = !{!"7.3", float* null}
!58 = !{!59, !9, !61}
!59 = !{!60}
!60 = !{!"8", [4 x [32 x float]]* null}
!61 = !{!62, !63, !64, !65}
!62 = !{!"8.0", [32 x float]* null}
!63 = !{!"8.1", [32 x float]* null}
!64 = !{!"8.2", [32 x float]* null}
!65 = !{!"8.3", [32 x float]* null}
!66 = !DILocation(line: 29, column: 1, scope: !67)
!67 = distinct !DISubprogram(name: "predict_kernel", scope: !68, file: !68, line: 8, type: !69, isLocal: false, isDefinition: true, scopeLine: 17, flags: DIFlagPrototyped, isOptimized: false, unit: !89, variables: !5)
!68 = !DIFile(filename: "src/fpga_kernels.cpp", directory: "/home/zzh/minkowski_fpga/hls")
!69 = !DISubroutineType(types: !70)
!70 = !{null, !71, !76, !80, !81, !71, !76, !80, !85, !86, !88}
!71 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !72, size: 64)
!72 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !73)
!73 = !DIDerivedType(tag: DW_TAG_typedef, name: "data_t", file: !74, line: 17, baseType: !75)
!74 = !DIFile(filename: "include/zonotope.hpp", directory: "/home/zzh/minkowski_fpga/hls")
!75 = !DIBasicType(name: "float", size: 32, encoding: DW_ATE_float)
!76 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !77, size: 64)
!77 = !DICompositeType(tag: DW_TAG_array_type, baseType: !72, size: 1024, elements: !78)
!78 = !{!79}
!79 = !DISubrange(count: 32)
!80 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!81 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !82, size: 64)
!82 = !DICompositeType(tag: DW_TAG_array_type, baseType: !72, size: 128, elements: !83)
!83 = !{!84}
!84 = !DISubrange(count: 4)
!85 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !73, size: 64)
!86 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !87, size: 64)
!87 = !DICompositeType(tag: DW_TAG_array_type, baseType: !73, size: 1024, elements: !78)
!88 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !80, size: 64)
!89 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus_14, file: !90, producer: "AMD/Xilinx clang version 16.0.6", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, imports: !91, splitDebugInlining: false, gnuPubnames: true)
!90 = !DIFile(filename: "/home/zzh/minkowski_fpga/hls/minkowski_hls/sol1/.autopilot/db/fpga_kernels.pp.0.cpp", directory: "/home/zzh/minkowski_fpga/hls", checksumkind: CSK_MD5, checksum: "f562b94d994a4beabbb74257a354fb7d")
!91 = !{!92, !99, !106, !108, !110, !114, !116, !118, !120, !122, !124, !126, !128, !132, !136, !138, !140, !145, !147, !149, !151, !153, !155, !157, !160, !162, !164, !168, !173, !175, !177, !179, !181, !183, !185, !187, !189, !191, !193, !197, !201, !203, !205, !207, !209, !211, !213, !215, !217, !219, !221, !223, !225, !227, !229, !231, !235, !239, !243, !245, !247, !249, !251, !253, !255, !257, !259, !261, !265, !269, !273, !275, !277, !279, !284, !288, !292, !294, !296, !298, !300, !302, !304, !306, !308, !310, !312, !314, !316, !321, !325, !329, !331, !333, !335, !342, !346, !350, !352, !354, !356, !358, !360, !362, !366, !370, !372, !374, !376, !378, !382, !386, !390, !392, !394, !396, !398, !400, !402, !406, !410, !414, !416, !420, !424, !426, !428, !430, !432, !434, !436, !440, !446, !451, !457, !461, !463, !465, !467, !469, !471, !473, !475, !477, !479, !481, !483, !485, !487, !489, !491, !493, !495, !497, !499, !501, !503, !505, !507, !509, !511, !513, !517, !521, !523, !525, !527, !529, !531, !533, !535, !537, !539, !541, !543}
!92 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !94, file: !98, line: 52)
!93 = !DINamespace(name: "std", scope: null)
!94 = !DISubprogram(name: "abs", scope: !95, file: !95, line: 980, type: !96, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!95 = !DIFile(filename: "/usr/include/stdlib.h", directory: "")
!96 = !DISubroutineType(types: !97)
!97 = !{!80, !80}
!98 = !DIFile(filename: "/opt/Xilinx/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/bits/std_abs.h", directory: "")
!99 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !100, file: !105, line: 83)
!100 = !DISubprogram(name: "acos", scope: !101, file: !101, line: 53, type: !102, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!101 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/mathcalls.h", directory: "")
!102 = !DISubroutineType(types: !103)
!103 = !{!104, !104}
!104 = !DIBasicType(name: "double", size: 64, encoding: DW_ATE_float)
!105 = !DIFile(filename: "/opt/Xilinx/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/cmath", directory: "")
!106 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !107, file: !105, line: 102)
!107 = !DISubprogram(name: "asin", scope: !101, file: !101, line: 55, type: !102, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!108 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !109, file: !105, line: 121)
!109 = !DISubprogram(name: "atan", scope: !101, file: !101, line: 57, type: !102, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!110 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !111, file: !105, line: 140)
!111 = !DISubprogram(name: "atan2", scope: !101, file: !101, line: 59, type: !112, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!112 = !DISubroutineType(types: !113)
!113 = !{!104, !104, !104}
!114 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !115, file: !105, line: 161)
!115 = !DISubprogram(name: "ceil", scope: !101, file: !101, line: 159, type: !102, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!116 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !117, file: !105, line: 180)
!117 = !DISubprogram(name: "cos", scope: !101, file: !101, line: 62, type: !102, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!118 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !119, file: !105, line: 199)
!119 = !DISubprogram(name: "cosh", scope: !101, file: !101, line: 71, type: !102, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!120 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !121, file: !105, line: 218)
!121 = !DISubprogram(name: "exp", scope: !101, file: !101, line: 95, type: !102, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!122 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !123, file: !105, line: 237)
!123 = !DISubprogram(name: "fabs", scope: !101, file: !101, line: 162, type: !102, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!124 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !125, file: !105, line: 256)
!125 = !DISubprogram(name: "floor", scope: !101, file: !101, line: 165, type: !102, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!126 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !127, file: !105, line: 275)
!127 = !DISubprogram(name: "fmod", scope: !101, file: !101, line: 168, type: !112, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!128 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !129, file: !105, line: 296)
!129 = !DISubprogram(name: "frexp", scope: !101, file: !101, line: 98, type: !130, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!130 = !DISubroutineType(types: !131)
!131 = !{!104, !104, !88}
!132 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !133, file: !105, line: 315)
!133 = !DISubprogram(name: "ldexp", scope: !101, file: !101, line: 101, type: !134, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!134 = !DISubroutineType(types: !135)
!135 = !{!104, !104, !80}
!136 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !137, file: !105, line: 334)
!137 = !DISubprogram(name: "log", scope: !101, file: !101, line: 104, type: !102, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!138 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !139, file: !105, line: 353)
!139 = !DISubprogram(name: "log10", scope: !101, file: !101, line: 107, type: !102, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!140 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !141, file: !105, line: 372)
!141 = !DISubprogram(name: "modf", scope: !101, file: !101, line: 110, type: !142, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!142 = !DISubroutineType(types: !143)
!143 = !{!104, !104, !144}
!144 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !104, size: 64)
!145 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !146, file: !105, line: 384)
!146 = !DISubprogram(name: "pow", scope: !101, file: !101, line: 140, type: !112, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!147 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !148, file: !105, line: 421)
!148 = !DISubprogram(name: "sin", scope: !101, file: !101, line: 64, type: !102, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!149 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !150, file: !105, line: 440)
!150 = !DISubprogram(name: "sinh", scope: !101, file: !101, line: 73, type: !102, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!151 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !152, file: !105, line: 459)
!152 = !DISubprogram(name: "sqrt", scope: !101, file: !101, line: 143, type: !102, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!153 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !154, file: !105, line: 478)
!154 = !DISubprogram(name: "tan", scope: !101, file: !101, line: 66, type: !102, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!155 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !156, file: !105, line: 497)
!156 = !DISubprogram(name: "tanh", scope: !101, file: !101, line: 75, type: !102, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!157 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !158, file: !105, line: 1065)
!158 = !DIDerivedType(tag: DW_TAG_typedef, name: "double_t", file: !159, line: 164, baseType: !104)
!159 = !DIFile(filename: "/usr/include/math.h", directory: "")
!160 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !161, file: !105, line: 1066)
!161 = !DIDerivedType(tag: DW_TAG_typedef, name: "float_t", file: !159, line: 163, baseType: !75)
!162 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !163, file: !105, line: 1069)
!163 = !DISubprogram(name: "acosh", scope: !101, file: !101, line: 85, type: !102, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!164 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !165, file: !105, line: 1070)
!165 = !DISubprogram(name: "acoshf", scope: !101, file: !101, line: 85, type: !166, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!166 = !DISubroutineType(types: !167)
!167 = !{!75, !75}
!168 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !169, file: !105, line: 1071)
!169 = !DISubprogram(name: "acoshl", scope: !101, file: !101, line: 85, type: !170, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!170 = !DISubroutineType(types: !171)
!171 = !{!172, !172}
!172 = !DIBasicType(name: "long double", size: 64, encoding: DW_ATE_float)
!173 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !174, file: !105, line: 1073)
!174 = !DISubprogram(name: "asinh", scope: !101, file: !101, line: 87, type: !102, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!175 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !176, file: !105, line: 1074)
!176 = !DISubprogram(name: "asinhf", scope: !101, file: !101, line: 87, type: !166, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!177 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !178, file: !105, line: 1075)
!178 = !DISubprogram(name: "asinhl", scope: !101, file: !101, line: 87, type: !170, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!179 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !180, file: !105, line: 1077)
!180 = !DISubprogram(name: "atanh", scope: !101, file: !101, line: 89, type: !102, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!181 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !182, file: !105, line: 1078)
!182 = !DISubprogram(name: "atanhf", scope: !101, file: !101, line: 89, type: !166, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!183 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !184, file: !105, line: 1079)
!184 = !DISubprogram(name: "atanhl", scope: !101, file: !101, line: 89, type: !170, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!185 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !186, file: !105, line: 1081)
!186 = !DISubprogram(name: "cbrt", scope: !101, file: !101, line: 152, type: !102, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!187 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !188, file: !105, line: 1082)
!188 = !DISubprogram(name: "cbrtf", scope: !101, file: !101, line: 152, type: !166, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!189 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !190, file: !105, line: 1083)
!190 = !DISubprogram(name: "cbrtl", scope: !101, file: !101, line: 152, type: !170, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!191 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !192, file: !105, line: 1085)
!192 = !DISubprogram(name: "copysign", scope: !101, file: !101, line: 198, type: !112, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!193 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !194, file: !105, line: 1086)
!194 = !DISubprogram(name: "copysignf", scope: !101, file: !101, line: 198, type: !195, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!195 = !DISubroutineType(types: !196)
!196 = !{!75, !75, !75}
!197 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !198, file: !105, line: 1087)
!198 = !DISubprogram(name: "copysignl", scope: !101, file: !101, line: 198, type: !199, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!199 = !DISubroutineType(types: !200)
!200 = !{!172, !172, !172}
!201 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !202, file: !105, line: 1089)
!202 = !DISubprogram(name: "erf", scope: !101, file: !101, line: 231, type: !102, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!203 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !204, file: !105, line: 1090)
!204 = !DISubprogram(name: "erff", scope: !101, file: !101, line: 231, type: !166, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!205 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !206, file: !105, line: 1091)
!206 = !DISubprogram(name: "erfl", scope: !101, file: !101, line: 231, type: !170, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!207 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !208, file: !105, line: 1093)
!208 = !DISubprogram(name: "erfc", scope: !101, file: !101, line: 232, type: !102, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!209 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !210, file: !105, line: 1094)
!210 = !DISubprogram(name: "erfcf", scope: !101, file: !101, line: 232, type: !166, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!211 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !212, file: !105, line: 1095)
!212 = !DISubprogram(name: "erfcl", scope: !101, file: !101, line: 232, type: !170, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!213 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !214, file: !105, line: 1097)
!214 = !DISubprogram(name: "exp2", scope: !101, file: !101, line: 130, type: !102, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!215 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !216, file: !105, line: 1098)
!216 = !DISubprogram(name: "exp2f", scope: !101, file: !101, line: 130, type: !166, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!217 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !218, file: !105, line: 1099)
!218 = !DISubprogram(name: "exp2l", scope: !101, file: !101, line: 130, type: !170, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!219 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !220, file: !105, line: 1101)
!220 = !DISubprogram(name: "expm1", scope: !101, file: !101, line: 119, type: !102, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!221 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !222, file: !105, line: 1102)
!222 = !DISubprogram(name: "expm1f", scope: !101, file: !101, line: 119, type: !166, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!223 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !224, file: !105, line: 1103)
!224 = !DISubprogram(name: "expm1l", scope: !101, file: !101, line: 119, type: !170, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!225 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !226, file: !105, line: 1105)
!226 = !DISubprogram(name: "fdim", scope: !101, file: !101, line: 329, type: !112, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!227 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !228, file: !105, line: 1106)
!228 = !DISubprogram(name: "fdimf", scope: !101, file: !101, line: 329, type: !195, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!229 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !230, file: !105, line: 1107)
!230 = !DISubprogram(name: "fdiml", scope: !101, file: !101, line: 329, type: !199, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!231 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !232, file: !105, line: 1109)
!232 = !DISubprogram(name: "fma", scope: !101, file: !101, line: 340, type: !233, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!233 = !DISubroutineType(types: !234)
!234 = !{!104, !104, !104, !104}
!235 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !236, file: !105, line: 1110)
!236 = !DISubprogram(name: "fmaf", scope: !101, file: !101, line: 340, type: !237, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!237 = !DISubroutineType(types: !238)
!238 = !{!75, !75, !75, !75}
!239 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !240, file: !105, line: 1111)
!240 = !DISubprogram(name: "fmal", scope: !101, file: !101, line: 340, type: !241, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!241 = !DISubroutineType(types: !242)
!242 = !{!172, !172, !172, !172}
!243 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !244, file: !105, line: 1113)
!244 = !DISubprogram(name: "fmax", scope: !101, file: !101, line: 333, type: !112, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!245 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !246, file: !105, line: 1114)
!246 = !DISubprogram(name: "fmaxf", scope: !101, file: !101, line: 333, type: !195, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!247 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !248, file: !105, line: 1115)
!248 = !DISubprogram(name: "fmaxl", scope: !101, file: !101, line: 333, type: !199, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!249 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !250, file: !105, line: 1117)
!250 = !DISubprogram(name: "fmin", scope: !101, file: !101, line: 336, type: !112, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!251 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !252, file: !105, line: 1118)
!252 = !DISubprogram(name: "fminf", scope: !101, file: !101, line: 336, type: !195, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!253 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !254, file: !105, line: 1119)
!254 = !DISubprogram(name: "fminl", scope: !101, file: !101, line: 336, type: !199, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!255 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !256, file: !105, line: 1121)
!256 = !DISubprogram(name: "hypot", scope: !101, file: !101, line: 147, type: !112, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!257 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !258, file: !105, line: 1122)
!258 = !DISubprogram(name: "hypotf", scope: !101, file: !101, line: 147, type: !195, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!259 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !260, file: !105, line: 1123)
!260 = !DISubprogram(name: "hypotl", scope: !101, file: !101, line: 147, type: !199, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!261 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !262, file: !105, line: 1125)
!262 = !DISubprogram(name: "ilogb", scope: !101, file: !101, line: 283, type: !263, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!263 = !DISubroutineType(types: !264)
!264 = !{!80, !104}
!265 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !266, file: !105, line: 1126)
!266 = !DISubprogram(name: "ilogbf", scope: !101, file: !101, line: 283, type: !267, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!267 = !DISubroutineType(types: !268)
!268 = !{!80, !75}
!269 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !270, file: !105, line: 1127)
!270 = !DISubprogram(name: "ilogbl", scope: !101, file: !101, line: 283, type: !271, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!271 = !DISubroutineType(types: !272)
!272 = !{!80, !172}
!273 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !274, file: !105, line: 1129)
!274 = !DISubprogram(name: "lgamma", scope: !101, file: !101, line: 233, type: !102, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!275 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !276, file: !105, line: 1130)
!276 = !DISubprogram(name: "lgammaf", scope: !101, file: !101, line: 233, type: !166, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!277 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !278, file: !105, line: 1131)
!278 = !DISubprogram(name: "lgammal", scope: !101, file: !101, line: 233, type: !170, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!279 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !280, file: !105, line: 1134)
!280 = !DISubprogram(name: "llrint", scope: !101, file: !101, line: 319, type: !281, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!281 = !DISubroutineType(types: !282)
!282 = !{!283, !104}
!283 = !DIBasicType(name: "long long", size: 64, encoding: DW_ATE_signed)
!284 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !285, file: !105, line: 1135)
!285 = !DISubprogram(name: "llrintf", scope: !101, file: !101, line: 319, type: !286, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!286 = !DISubroutineType(types: !287)
!287 = !{!283, !75}
!288 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !289, file: !105, line: 1136)
!289 = !DISubprogram(name: "llrintl", scope: !101, file: !101, line: 319, type: !290, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!290 = !DISubroutineType(types: !291)
!291 = !{!283, !172}
!292 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !293, file: !105, line: 1138)
!293 = !DISubprogram(name: "llround", scope: !101, file: !101, line: 325, type: !281, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!294 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !295, file: !105, line: 1139)
!295 = !DISubprogram(name: "llroundf", scope: !101, file: !101, line: 325, type: !286, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!296 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !297, file: !105, line: 1140)
!297 = !DISubprogram(name: "llroundl", scope: !101, file: !101, line: 325, type: !290, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!298 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !299, file: !105, line: 1143)
!299 = !DISubprogram(name: "log1p", scope: !101, file: !101, line: 122, type: !102, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!300 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !301, file: !105, line: 1144)
!301 = !DISubprogram(name: "log1pf", scope: !101, file: !101, line: 122, type: !166, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!302 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !303, file: !105, line: 1145)
!303 = !DISubprogram(name: "log1pl", scope: !101, file: !101, line: 122, type: !170, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!304 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !305, file: !105, line: 1147)
!305 = !DISubprogram(name: "log2", scope: !101, file: !101, line: 133, type: !102, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!306 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !307, file: !105, line: 1148)
!307 = !DISubprogram(name: "log2f", scope: !101, file: !101, line: 133, type: !166, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!308 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !309, file: !105, line: 1149)
!309 = !DISubprogram(name: "log2l", scope: !101, file: !101, line: 133, type: !170, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!310 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !311, file: !105, line: 1151)
!311 = !DISubprogram(name: "logb", scope: !101, file: !101, line: 125, type: !102, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!312 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !313, file: !105, line: 1152)
!313 = !DISubprogram(name: "logbf", scope: !101, file: !101, line: 125, type: !166, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!314 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !315, file: !105, line: 1153)
!315 = !DISubprogram(name: "logbl", scope: !101, file: !101, line: 125, type: !170, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!316 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !317, file: !105, line: 1155)
!317 = !DISubprogram(name: "lrint", scope: !101, file: !101, line: 317, type: !318, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!318 = !DISubroutineType(types: !319)
!319 = !{!320, !104}
!320 = !DIBasicType(name: "long", size: 64, encoding: DW_ATE_signed)
!321 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !322, file: !105, line: 1156)
!322 = !DISubprogram(name: "lrintf", scope: !101, file: !101, line: 317, type: !323, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!323 = !DISubroutineType(types: !324)
!324 = !{!320, !75}
!325 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !326, file: !105, line: 1157)
!326 = !DISubprogram(name: "lrintl", scope: !101, file: !101, line: 317, type: !327, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!327 = !DISubroutineType(types: !328)
!328 = !{!320, !172}
!329 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !330, file: !105, line: 1159)
!330 = !DISubprogram(name: "lround", scope: !101, file: !101, line: 323, type: !318, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!331 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !332, file: !105, line: 1160)
!332 = !DISubprogram(name: "lroundf", scope: !101, file: !101, line: 323, type: !323, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!333 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !334, file: !105, line: 1161)
!334 = !DISubprogram(name: "lroundl", scope: !101, file: !101, line: 323, type: !327, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!335 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !336, file: !105, line: 1163)
!336 = !DISubprogram(name: "nan", scope: !101, file: !101, line: 203, type: !337, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!337 = !DISubroutineType(types: !338)
!338 = !{!104, !339}
!339 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !340, size: 64)
!340 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !341)
!341 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!342 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !343, file: !105, line: 1164)
!343 = !DISubprogram(name: "nanf", scope: !101, file: !101, line: 203, type: !344, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!344 = !DISubroutineType(types: !345)
!345 = !{!75, !339}
!346 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !347, file: !105, line: 1165)
!347 = !DISubprogram(name: "nanl", scope: !101, file: !101, line: 203, type: !348, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!348 = !DISubroutineType(types: !349)
!349 = !{!172, !339}
!350 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !351, file: !105, line: 1167)
!351 = !DISubprogram(name: "nearbyint", scope: !101, file: !101, line: 297, type: !102, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!352 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !353, file: !105, line: 1168)
!353 = !DISubprogram(name: "nearbyintf", scope: !101, file: !101, line: 297, type: !166, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!354 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !355, file: !105, line: 1169)
!355 = !DISubprogram(name: "nearbyintl", scope: !101, file: !101, line: 297, type: !170, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!356 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !357, file: !105, line: 1171)
!357 = !DISubprogram(name: "nextafter", scope: !101, file: !101, line: 262, type: !112, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!358 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !359, file: !105, line: 1172)
!359 = !DISubprogram(name: "nextafterf", scope: !101, file: !101, line: 262, type: !195, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!360 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !361, file: !105, line: 1173)
!361 = !DISubprogram(name: "nextafterl", scope: !101, file: !101, line: 262, type: !199, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!362 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !363, file: !105, line: 1175)
!363 = !DISubprogram(name: "nexttoward", scope: !101, file: !101, line: 264, type: !364, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!364 = !DISubroutineType(types: !365)
!365 = !{!104, !104, !172}
!366 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !367, file: !105, line: 1176)
!367 = !DISubprogram(name: "nexttowardf", scope: !101, file: !101, line: 264, type: !368, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!368 = !DISubroutineType(types: !369)
!369 = !{!75, !75, !172}
!370 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !371, file: !105, line: 1177)
!371 = !DISubprogram(name: "nexttowardl", scope: !101, file: !101, line: 264, type: !199, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!372 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !373, file: !105, line: 1179)
!373 = !DISubprogram(name: "remainder", scope: !101, file: !101, line: 275, type: !112, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!374 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !375, file: !105, line: 1180)
!375 = !DISubprogram(name: "remainderf", scope: !101, file: !101, line: 275, type: !195, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!376 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !377, file: !105, line: 1181)
!377 = !DISubprogram(name: "remainderl", scope: !101, file: !101, line: 275, type: !199, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!378 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !379, file: !105, line: 1183)
!379 = !DISubprogram(name: "remquo", scope: !101, file: !101, line: 310, type: !380, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!380 = !DISubroutineType(types: !381)
!381 = !{!104, !104, !104, !88}
!382 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !383, file: !105, line: 1184)
!383 = !DISubprogram(name: "remquof", scope: !101, file: !101, line: 310, type: !384, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!384 = !DISubroutineType(types: !385)
!385 = !{!75, !75, !75, !88}
!386 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !387, file: !105, line: 1185)
!387 = !DISubprogram(name: "remquol", scope: !101, file: !101, line: 310, type: !388, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!388 = !DISubroutineType(types: !389)
!389 = !{!172, !172, !172, !88}
!390 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !391, file: !105, line: 1187)
!391 = !DISubprogram(name: "rint", scope: !101, file: !101, line: 259, type: !102, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!392 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !393, file: !105, line: 1188)
!393 = !DISubprogram(name: "rintf", scope: !101, file: !101, line: 259, type: !166, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!394 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !395, file: !105, line: 1189)
!395 = !DISubprogram(name: "rintl", scope: !101, file: !101, line: 259, type: !170, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!396 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !397, file: !105, line: 1191)
!397 = !DISubprogram(name: "round", scope: !101, file: !101, line: 301, type: !102, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!398 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !399, file: !105, line: 1192)
!399 = !DISubprogram(name: "roundf", scope: !101, file: !101, line: 301, type: !166, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!400 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !401, file: !105, line: 1193)
!401 = !DISubprogram(name: "roundl", scope: !101, file: !101, line: 301, type: !170, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!402 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !403, file: !105, line: 1195)
!403 = !DISubprogram(name: "scalbln", scope: !101, file: !101, line: 293, type: !404, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!404 = !DISubroutineType(types: !405)
!405 = !{!104, !104, !320}
!406 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !407, file: !105, line: 1196)
!407 = !DISubprogram(name: "scalblnf", scope: !101, file: !101, line: 293, type: !408, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!408 = !DISubroutineType(types: !409)
!409 = !{!75, !75, !320}
!410 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !411, file: !105, line: 1197)
!411 = !DISubprogram(name: "scalblnl", scope: !101, file: !101, line: 293, type: !412, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!412 = !DISubroutineType(types: !413)
!413 = !{!172, !172, !320}
!414 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !415, file: !105, line: 1199)
!415 = !DISubprogram(name: "scalbn", scope: !101, file: !101, line: 279, type: !134, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!416 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !417, file: !105, line: 1200)
!417 = !DISubprogram(name: "scalbnf", scope: !101, file: !101, line: 279, type: !418, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!418 = !DISubroutineType(types: !419)
!419 = !{!75, !75, !80}
!420 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !421, file: !105, line: 1201)
!421 = !DISubprogram(name: "scalbnl", scope: !101, file: !101, line: 279, type: !422, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!422 = !DISubroutineType(types: !423)
!423 = !{!172, !172, !80}
!424 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !425, file: !105, line: 1203)
!425 = !DISubprogram(name: "tgamma", scope: !101, file: !101, line: 238, type: !102, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!426 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !427, file: !105, line: 1204)
!427 = !DISubprogram(name: "tgammaf", scope: !101, file: !101, line: 238, type: !166, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!428 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !429, file: !105, line: 1205)
!429 = !DISubprogram(name: "tgammal", scope: !101, file: !101, line: 238, type: !170, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!430 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !431, file: !105, line: 1207)
!431 = !DISubprogram(name: "trunc", scope: !101, file: !101, line: 305, type: !102, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!432 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !433, file: !105, line: 1208)
!433 = !DISubprogram(name: "truncf", scope: !101, file: !101, line: 305, type: !166, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!434 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !93, entity: !435, file: !105, line: 1209)
!435 = !DISubprogram(name: "truncl", scope: !101, file: !101, line: 305, type: !170, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!436 = !DIImportedEntity(tag: DW_TAG_imported_module, scope: !437, entity: !438, file: !439, line: 58)
!437 = !DINamespace(name: "__gnu_debug", scope: null)
!438 = !DINamespace(name: "__debug", scope: !93)
!439 = !DIFile(filename: "/opt/Xilinx/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/debug/debug.h", directory: "")
!440 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !441, file: !445, line: 38)
!441 = !DISubprogram(name: "abs", linkageName: "_ZSt3absg", scope: !93, file: !98, line: 102, type: !442, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!442 = !DISubroutineType(types: !443)
!443 = !{!444, !444}
!444 = !DIBasicType(name: "__float128", size: 128, encoding: DW_ATE_float)
!445 = !DIFile(filename: "/opt/Xilinx/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/math.h", directory: "")
!446 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !447, file: !445, line: 54)
!447 = !DISubprogram(name: "modf", linkageName: "_ZSt4modfePe", scope: !93, file: !105, line: 380, type: !448, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!448 = !DISubroutineType(types: !449)
!449 = !{!172, !172, !450}
!450 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !172, size: 64)
!451 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !452, file: !445, line: 115)
!452 = !DISubprogram(name: "assoc_laguerref", linkageName: "_ZSt15assoc_laguerrefjjf", scope: !93, file: !453, line: 206, type: !454, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!453 = !DIFile(filename: "/opt/Xilinx/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/bits/specfun.h", directory: "")
!454 = !DISubroutineType(types: !455)
!455 = !{!75, !456, !456, !75}
!456 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!457 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !458, file: !445, line: 116)
!458 = !DISubprogram(name: "assoc_laguerrel", linkageName: "_ZSt15assoc_laguerreljje", scope: !93, file: !453, line: 216, type: !459, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!459 = !DISubroutineType(types: !460)
!460 = !{!172, !456, !456, !172}
!461 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !462, file: !445, line: 118)
!462 = !DISubprogram(name: "assoc_legendref", linkageName: "_ZSt15assoc_legendrefjjf", scope: !93, file: !453, line: 267, type: !454, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!463 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !464, file: !445, line: 119)
!464 = !DISubprogram(name: "assoc_legendrel", linkageName: "_ZSt15assoc_legendreljje", scope: !93, file: !453, line: 276, type: !459, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!465 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !466, file: !445, line: 121)
!466 = !DISubprogram(name: "betaf", linkageName: "_ZSt5betafff", scope: !93, file: !453, line: 312, type: !195, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!467 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !468, file: !445, line: 122)
!468 = !DISubprogram(name: "betal", linkageName: "_ZSt5betalee", scope: !93, file: !453, line: 322, type: !199, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!469 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !470, file: !445, line: 124)
!470 = !DISubprogram(name: "comp_ellint_1f", linkageName: "_ZSt14comp_ellint_1ff", scope: !93, file: !453, line: 358, type: !166, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!471 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !472, file: !445, line: 125)
!472 = !DISubprogram(name: "comp_ellint_1l", linkageName: "_ZSt14comp_ellint_1le", scope: !93, file: !453, line: 368, type: !170, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!473 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !474, file: !445, line: 127)
!474 = !DISubprogram(name: "comp_ellint_2f", linkageName: "_ZSt14comp_ellint_2ff", scope: !93, file: !453, line: 406, type: !166, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!475 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !476, file: !445, line: 128)
!476 = !DISubprogram(name: "comp_ellint_2l", linkageName: "_ZSt14comp_ellint_2le", scope: !93, file: !453, line: 416, type: !170, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!477 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !478, file: !445, line: 130)
!478 = !DISubprogram(name: "comp_ellint_3f", linkageName: "_ZSt14comp_ellint_3fff", scope: !93, file: !453, line: 453, type: !195, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!479 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !480, file: !445, line: 131)
!480 = !DISubprogram(name: "comp_ellint_3l", linkageName: "_ZSt14comp_ellint_3lee", scope: !93, file: !453, line: 463, type: !199, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!481 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !482, file: !445, line: 133)
!482 = !DISubprogram(name: "cyl_bessel_if", linkageName: "_ZSt13cyl_bessel_ifff", scope: !93, file: !453, line: 504, type: !195, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!483 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !484, file: !445, line: 134)
!484 = !DISubprogram(name: "cyl_bessel_il", linkageName: "_ZSt13cyl_bessel_ilee", scope: !93, file: !453, line: 514, type: !199, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!485 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !486, file: !445, line: 136)
!486 = !DISubprogram(name: "cyl_bessel_jf", linkageName: "_ZSt13cyl_bessel_jfff", scope: !93, file: !453, line: 550, type: !195, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!487 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !488, file: !445, line: 137)
!488 = !DISubprogram(name: "cyl_bessel_jl", linkageName: "_ZSt13cyl_bessel_jlee", scope: !93, file: !453, line: 560, type: !199, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!489 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !490, file: !445, line: 139)
!490 = !DISubprogram(name: "cyl_bessel_kf", linkageName: "_ZSt13cyl_bessel_kfff", scope: !93, file: !453, line: 596, type: !195, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!491 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !492, file: !445, line: 140)
!492 = !DISubprogram(name: "cyl_bessel_kl", linkageName: "_ZSt13cyl_bessel_klee", scope: !93, file: !453, line: 606, type: !199, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!493 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !494, file: !445, line: 142)
!494 = !DISubprogram(name: "cyl_neumannf", linkageName: "_ZSt12cyl_neumannfff", scope: !93, file: !453, line: 648, type: !195, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!495 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !496, file: !445, line: 143)
!496 = !DISubprogram(name: "cyl_neumannl", linkageName: "_ZSt12cyl_neumannlee", scope: !93, file: !453, line: 658, type: !199, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!497 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !498, file: !445, line: 145)
!498 = !DISubprogram(name: "ellint_1f", linkageName: "_ZSt9ellint_1fff", scope: !93, file: !453, line: 696, type: !195, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!499 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !500, file: !445, line: 146)
!500 = !DISubprogram(name: "ellint_1l", linkageName: "_ZSt9ellint_1lee", scope: !93, file: !453, line: 706, type: !199, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!501 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !502, file: !445, line: 148)
!502 = !DISubprogram(name: "ellint_2f", linkageName: "_ZSt9ellint_2fff", scope: !93, file: !453, line: 744, type: !195, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!503 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !504, file: !445, line: 149)
!504 = !DISubprogram(name: "ellint_2l", linkageName: "_ZSt9ellint_2lee", scope: !93, file: !453, line: 754, type: !199, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!505 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !506, file: !445, line: 151)
!506 = !DISubprogram(name: "ellint_3f", linkageName: "_ZSt9ellint_3ffff", scope: !93, file: !453, line: 792, type: !237, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!507 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !508, file: !445, line: 152)
!508 = !DISubprogram(name: "ellint_3l", linkageName: "_ZSt9ellint_3leee", scope: !93, file: !453, line: 802, type: !241, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!509 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !510, file: !445, line: 154)
!510 = !DISubprogram(name: "expintf", linkageName: "_ZSt7expintff", scope: !93, file: !453, line: 844, type: !166, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!511 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !512, file: !445, line: 155)
!512 = !DISubprogram(name: "expintl", linkageName: "_ZSt7expintle", scope: !93, file: !453, line: 854, type: !170, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!513 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !514, file: !445, line: 157)
!514 = !DISubprogram(name: "hermitef", linkageName: "_ZSt8hermitefjf", scope: !93, file: !453, line: 885, type: !515, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!515 = !DISubroutineType(types: !516)
!516 = !{!75, !456, !75}
!517 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !518, file: !445, line: 158)
!518 = !DISubprogram(name: "hermitel", linkageName: "_ZSt8hermitelje", scope: !93, file: !453, line: 895, type: !519, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!519 = !DISubroutineType(types: !520)
!520 = !{!172, !456, !172}
!521 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !522, file: !445, line: 160)
!522 = !DISubprogram(name: "laguerref", linkageName: "_ZSt9laguerrefjf", scope: !93, file: !453, line: 933, type: !515, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!523 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !524, file: !445, line: 161)
!524 = !DISubprogram(name: "laguerrel", linkageName: "_ZSt9laguerrelje", scope: !93, file: !453, line: 943, type: !519, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!525 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !526, file: !445, line: 163)
!526 = !DISubprogram(name: "legendref", linkageName: "_ZSt9legendrefjf", scope: !93, file: !453, line: 977, type: !515, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!527 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !528, file: !445, line: 164)
!528 = !DISubprogram(name: "legendrel", linkageName: "_ZSt9legendrelje", scope: !93, file: !453, line: 987, type: !519, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!529 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !530, file: !445, line: 166)
!530 = !DISubprogram(name: "riemann_zetaf", linkageName: "_ZSt13riemann_zetaff", scope: !93, file: !453, line: 1022, type: !166, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!531 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !532, file: !445, line: 167)
!532 = !DISubprogram(name: "riemann_zetal", linkageName: "_ZSt13riemann_zetale", scope: !93, file: !453, line: 1032, type: !170, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!533 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !534, file: !445, line: 169)
!534 = !DISubprogram(name: "sph_besself", linkageName: "_ZSt11sph_besselfjf", scope: !93, file: !453, line: 1073, type: !515, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!535 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !536, file: !445, line: 170)
!536 = !DISubprogram(name: "sph_bessell", linkageName: "_ZSt11sph_bessellje", scope: !93, file: !453, line: 1083, type: !519, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!537 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !538, file: !445, line: 172)
!538 = !DISubprogram(name: "sph_legendref", linkageName: "_ZSt13sph_legendrefjjf", scope: !93, file: !453, line: 1117, type: !454, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!539 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !540, file: !445, line: 173)
!540 = !DISubprogram(name: "sph_legendrel", linkageName: "_ZSt13sph_legendreljje", scope: !93, file: !453, line: 1128, type: !459, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!541 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !542, file: !445, line: 175)
!542 = !DISubprogram(name: "sph_neumannf", linkageName: "_ZSt12sph_neumannfjf", scope: !93, file: !453, line: 1164, type: !515, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!543 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !89, entity: !544, file: !445, line: 176)
!544 = !DISubprogram(name: "sph_neumannl", linkageName: "_ZSt12sph_neumannlje", scope: !93, file: !453, line: 1174, type: !519, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!545 = !DILocation(line: 24, column: 1, scope: !67)
!546 = !DILocation(line: 30, column: 1, scope: !67)
!547 = !DILocation(line: 31, column: 1, scope: !67)
