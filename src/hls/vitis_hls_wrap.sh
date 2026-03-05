#!/usr/bin/env bash

# 提高脚本健壮性 # Improve script robustness
set -Eeuo pipefail
trap 'echo "[WRAP] ERROR on line $LINENO"; exit 1' ERR

echo "=== vitis_hls_wrap.sh ENTER ==="
echo "[WRAP] ARGS=$*"

# -----------------------------
# 路径定义 (根据 find 结果精准定位)
# -----------------------------
XILINX_ROOT=/opt/Xilinx/2025.2
XILINX_VITIS=$XILINX_ROOT/Vitis
VITIS_HLS_BIN=$XILINX_VITIS/bin/unwrapped/lnx64.o/vitis_hls

# -----------------------------
# 环境清理与配置 # Environment cleanup and setup
# -----------------------------
set +u
export PYTHONPATH=""
export PYTHONHOME=""
export MATLABPATH=""
export XILINX_ROOT="$XILINX_ROOT"

# 载入 Xilinx 官方设置
if [ -f "$XILINX_VITIS/settings64.sh" ]; then
    source "$XILINX_VITIS/settings64.sh"
else
    echo "ERROR: Cannot find settings64.sh at $XILINX_VITIS"
    exit 1
fi

# 关键：根据 find 结果手动设置 Tcl 库路径
# 解决 "version conflict for package Tcl"
if [ -d "$XILINX_ROOT/tps/tcl/tcl8.6" ]; then
    export TCL_LIBRARY="$XILINX_ROOT/tps/tcl/tcl8.6"
    echo "[WRAP] Using internal Tcl library: $TCL_LIBRARY"
elif [ -d "$XILINX_ROOT/lnx64/tools/vcxx/third-party/python-linux/user/3.10.10/lib/tcl8.6" ]; then
    export TCL_LIBRARY="$XILINX_ROOT/lnx64/tools/vcxx/third-party/python-linux/user/3.10.10/lib/tcl8.6"
fi

# 关键：vitis_hls 需要这些环境变量才能找到其 Tcl/工具链脚本
export RDI_ROOT="$XILINX_VITIS"
export RDI_APPROOT="$XILINX_VITIS"
export HDI_APPROOT="$XILINX_VITIS"
export RDI_PLATFORM="lnx64"
export RDI_DATADIR="$XILINX_VITIS/data"
export RDI_BINDIR="$XILINX_VITIS/bin"

# 关键：直接调用 unwrapped 二进制文件时，需要显式补齐动态库搜索路径
export LD_LIBRARY_PATH="$XILINX_VITIS/lib/lnx64.o:${LD_LIBRARY_PATH:-}"

set -u

# 确保脚本在自身所在目录执行 # Ensure the script runs in its own directory
cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

# -----------------------------
# 执行逻辑 # Execution logic
# -----------------------------
if [[ "${1:-}" == "-f" && -n "${2:-}" ]]; then
    USER_TCL="$(readlink -f "$2")"
    shift 2
    echo "[WRAP] exec: $VITIS_HLS_BIN $USER_TCL $*"
    exec "$VITIS_HLS_BIN" "$USER_TCL" "$@"
else
    echo "[WRAP] exec: $VITIS_HLS_BIN $*"
    exec "$VITIS_HLS_BIN" "$@"
fi
# #!/usr/bin/env bash
# set -Eeuo pipefail
# trap 'echo "[WRAP] ERROR on line $LINENO"; exit 1' ERR

# echo "=== vitis_hls_wrap.sh ENTER ==="
# echo "[WRAP] ARGS=$*"

# # -----------------------------
# # Paths
# # -----------------------------
# XILINX_ROOT=/opt/Xilinx/2025.2
# XILINX_VITIS=$XILINX_ROOT/Vitis
# VITIS_HLS_EXE=$XILINX_VITIS/bin/unwrapped/lnx64.o/vitis_hls
# HLS_DRIVER_TCL=$XILINX_VITIS/scripts/vitis_hls/hls.tcl
# VITIS_HLS_BIN=/opt/Xilinx/2025.2/Vitis/bin/vitis_hls

# # -----------------------------
# # Xilinx environment
# # -----------------------------
# set +u
# export PYTHONPATH="${PYTHONPATH:-}"
# export PYTHONHOME="${PYTHONHOME:-}"
# export MATLABPATH="${MATLABPATH:-}"
# export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}"
# source "$XILINX_VITIS/settings64.sh"

# export XILINX_ROOT="$XILINX_ROOT"
# export XILINX_VITIS="$XILINX_VITIS"
# export RDI_DATADIR="$XILINX_VITIS/data"

# export LD_LIBRARY_PATH="$XILINX_VITIS/lib/lnx64.o:${LD_LIBRARY_PATH:-}"
# export PATH="$XILINX_VITIS/bin/unwrapped/lnx64.o:$XILINX_VITIS/bin:${PATH:-}"

# # # Tcl runtime
# # if [[ -f "$HOME/tcl8613_install/lib/tcl8.6/init.tcl" ]]; then
# #   export TCL_LIBRARY="$HOME/tcl8613_install/lib/tcl8.6"
# # elif [[ -f "/usr/share/tcltk/tcl8.6/init.tcl" ]]; then
# #   export TCL_LIBRARY="/usr/share/tcltk/tcl8.6"
# # elif [[ -f "/usr/lib/tcl8.6/init.tcl" ]]; then
# #   export TCL_LIBRARY="/usr/lib/tcl8.6"
# # else
# #   echo "[WRAP] ERROR: cannot find init.tcl. Install tcl8.6 (sudo apt install tcl8.6)."
# #   exit 2
# # fi
# # if [[ -d "/usr/share/tcltk/tk8.6" ]]; then
# #   export TK_LIBRARY="/usr/share/tcltk/tk8.6"
# # fi
# set -u

# # -----------------------------
# # Optional log file (not journal)
# # -----------------------------
# LOG_DIR="$HOME/.vitis_hls_journal"
# mkdir -p "$LOG_DIR"
# LOG_FILE="$LOG_DIR/vitis_hls.log"
# : > "$LOG_FILE"

# # Keep relative paths stable
# cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

# # -----------------------------
# # Dispatch (CRITICAL: -nojournal)
# # -----------------------------
# # ---- init file to avoid "source {} -notrace" ----
# INIT_TCL="$HOME/.vitis_hls_runtime/init.tcl"

# COMMON_OPTS=(-init "$INIT_TCL" -log "$HOME/.vitis_hls_journal/vitis_hls.log")

# if [[ "${1:-}" == "-f" && -n "${2:-}" ]]; then
#   USER_TCL="$(readlink -f "$2")"
#   shift 2
#   # 直接传递参数，不要再嵌套 -f $HLS_DRIVER_TCL
#   exec "$VITIS_HLS_EXE" "${COMMON_OPTS[@]}" -f "$USER_TCL" "$@"
# else
#   # 交互模式或直接运行 # Interactive mode or direct execution
#   echo "[WRAP] exec: $VITIS_HLS_EXE ${COMMON_OPTS[*]} $*"
#   exec "$VITIS_HLS_EXE" "${COMMON_OPTS[@]}" "$@"
# fi

#!/usr/bin/env bash












# #!/usr/bin/env bash
# echo "=== run_hls.tcl ENTER ==="
# # set -euo pipefail
# set -e
# set +u   # <<< 强制关闭 nounset，避免 MATLABPATH/PYTHONPATH 未定义导致 settings 脚本炸

# export PYTHONPATH="${PYTHONPATH:-}"
# export PYTHONHOME="${PYTHONHOME:-}"
# export MATLABPATH="${MATLABPATH:-}"
# export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}"
# export PATH="${PATH:-}"

# # # 安装根目录（按你实际版本） # Installation root directory (set to your actual version)
# export XILINX_ROOT=/opt/Xilinx/2025.2

# # ✅ 关键：强制设置 RDI_DATADIR（你机器上就是这个路径）
# export RDI_DATADIR=$XILINX_ROOT/data

# # 1) 基础环境（一定要source，否则RDI_DATADIR等不全）  Vitis
# source /opt/Xilinx/2025.2/Vitis/settings64.sh

# # 2) 强制使用系统 Tcl/Tk 的脚本库（提供 init.tcl）
# export TK_LIBRARY=/usr/share/tcltk/tk8.6
# # 关键：给 vitis_hls 一个“它能用的” Tcl library（你已经有 tcl8.6.13 源码目录） 
# export TCL_LIBRARY=$HOME/tcl8613_install/lib/tcl8.6
# # export TCL_LIBRARY=/usr/share/tcltk/tcl8.6

# # 3) 确保动态库能找到（你之前缺 so 的问题）
# export LD_LIBRARY_PATH=/opt/Xilinx/2025.2/Vitis/lib/lnx64.o:${LD_LIBRARY_PATH:-}

# # 4) 确保能找到 vitis_hls 可执行文件
# export PATH=/opt/Xilinx/2025.2/Vitis/bin/unwrapped/lnx64.o:/opt/Xilinx/2025.2/Vitis/bin:$PATH

# # # 5) 关键：从 Vitis 根目录启动，避免找不到 scripts/builtin.tcl
# # cd /opt/Xilinx/2025.2/Vitis

# # # 6) 运行：把你传进来的参数原样转发给 vitis_hls
# # exec /opt/Xilinx/2025.2/Vitis/bin/unwrapped/lnx64.o/vitis_hls "$@"
# # echo "[WRAP] TCL_SCRIPT=$TCL_SCRIPT"

# echo "[WRAP] ARGS=$*"

# VITIS_HLS_BIN=/opt/Xilinx/2025.2/Vitis/bin/unwrapped/lnx64.o/vitis_hls

# VITIS_LAUNCHER=(/opt/Xilinx/2025.2/Vitis/bin/vitis -exec vitis_hls)

# JOU_DIR="$HOME/.vitis_hls_journal"
# mkdir -p "$JOU_DIR"
# JOU_FILE="$JOU_DIR/vitis_hls.jou"

# if [[ "${1:-}" == "-f" && -n "${2:-}" ]]; then
#   TCL_SCRIPT="$(readlink -f "$2")"
#   shift 2
#   echo "[WRAP] exec: ${VITIS_LAUNCHER[*]} -journal $JOU_FILE -f $TCL_SCRIPT -tclargs $*"
#   exec "${VITIS_LAUNCHER[@]}" -journal "$JOU_FILE" -f "$TCL_SCRIPT" -tclargs "$@"
# else
#   echo "[WRAP] exec: ${VITIS_LAUNCHER[*]} -journal $JOU_FILE $*"
#   exec "${VITIS_LAUNCHER[@]}" -journal "$JOU_FILE" "$@"
# fi
