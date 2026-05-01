"""
Parametric zonotopic estimator for a linear time-varying system.

- Dimensions and noise levels are configured at the top.
- Core linear-algebra kernels are isolated in fpga_* functions so that
  they can later be replaced by FPGA implementations.
- 尺寸和噪声水平在代码前部分配置。
- 核心线性代数内核被封装在 fpga_* 函数中，以便  后续可由 FPGA 实现方案替换。

Requires:
    numpy
    matplotlib
"""

import os
import numpy as np
import matplotlib.pyplot as plt
import profile
from pathlib import Path
import time


# =============================================================================
# CONFIGURATION (EDIT HERE)
# =============================================================================

# State dimension 状态维度
N_STATE = 24          # n  (6 coupled oscillator blocks × 4)

# Input dimension 输入维度
N_INPUT = 1          # n_u 

# Number of scalar measurements 测量维度
N_MEAS = 12    # n_y (2 measurements per 4x4 oscillator block)

# Number of simulation steps 仿真步数
NUM_STEPS = int(os.getenv("ZONO_NUM_STEPS", "100"))

# Sampling time 采样时间
DT = 0.1            

# Process noise radius (per state coordinate, box-shaped zonotope) 过程噪声半径
PROC_NOISE_RADIUS = 0.05  # 0.05

# Measurement noise radius (per measurement, box-shaped zonotope) 测量噪声半径
MEAS_NOISE_RADIUS = 0.1  # 0.1

# Initial state box radius (per coordinate)
INIT_RADIUS = 0.2  # 0.2

# Zonotope reduction budget (max # of generators kept before row-sum aggregation) 
REDUCTION_BUDGET = 32

# Random seed for reproducibility 随机种子用于可重复性？
RANDOM_SEED = 42

# Output partition for Python-vs-HLS comparison results
OUTPUT_PARTITION = "comparison/python_hls"
HLS_REF_MODE = "csim"              # csim/cosim/ (prefer current step_axi csim)
HLS_REF_METHOD = "LAMBDA_SEGMENT"  # LAMBDA_P_RADIUS/LAMBDA_SEGMENT/LAMBDA_VOLUME/NONE
ESTIMATION_METHOD = "segment"      # 'None', 'segment', 'p_radius', 'volume'


# =============================================================================
# FPGA CANDIDATE KERNELS
# =============================================================================
# These functions are *exactly* what you’d swap out for FPGA calls in the future.
# The rest of the code should not need to change: they are pure, stateless
# functions that map numpy arrays → numpy arrays.
# =============================================================================

def fpga_predict_kernel(p_x, H_x, A, B, u, p_w, H_w):
    """
    FPGA CANDIDATE KERNEL: prediction step 候选内核

    Implements:

        X_k      = p_x ⊕ H_x B_m
        W_k      = p_w ⊕ H_w B_{m_w}
        X_{k+1}^- = A X_k ⊕ B u ⊕ W_k

    so that:

        p_pred = A p_x + B u + p_w    
        H_pred = [A H_x, H_w]

    Parameters
    ----------
    p_x : (n,) array
        State zonotope center p_x.
    H_x : (n, m_x) array
        State generators H_x.
    A : (n, n) array
        State transition matrix.
    B : (n, n_u) array
        Input matrix.
    u : (n_u,) array
        Input vector.
    p_w : (n,) array
        Process noise center.
    H_w : (n, m_w) array
        Process noise generators.

    Returns
    -------
    p_pred : (n,) array
    H_pred : (n, m_x + m_w) array
    """
    # In an FPGA implementation, this would be:
    #  - one matrix-vector multiply for A @ p_x
    #  - one matrix-vector multiply for B @ u
    #  - one matrix-matrix multiply for A @ H_x
    #  - plus some vector additions and concatenation

    A = np.asarray(A, dtype=float)
    # 强制转换//与 np.array()的区别：np.array()几乎总是创建一个新的数组副本，
    # 而 np.asarray()在输入已经是满足条件的数组时会尽量避免复制 。因此，当你希望尽可能避免不必要的内存复制时，np.asarray()是更好的选择。
    B = np.asarray(B, dtype=float)
    u = np.asarray(u, dtype=float).reshape(-1) # 展平为一维数组一行n列

    p_pred = A @ p_x + B @ u + p_w
    H_pred = np.concatenate([A @ H_x, H_w], axis=1) # 将新矩阵与另一个矩阵 H_w在水平方向（即 axis=1按列拼接（横向拼接 要求行相同））上拼接起来
    return p_pred, H_pred


def fpga_strip_update_kernel(p, H, c, y, phi, lam):
    """
    FPGA CANDIDATE KERNEL: strip-based correction for ONE scalar measurement.

    Given current zonotope Z = p ⊕ H B_m and strip

        S = { x : |c^T x - y| <= phi },

    implements:

        residual = c^T p
        r       = y - residual

        p_hat   = p + λ r
        t       = c^T H       (1×m)
        H_hat   = H - λ t     (rank-1 update)
        H_hat   = [H_hat, phi λ]  (append new generator)

    Parameters
    ----------
    p : (n,) array
        Current center.
    H : (n, m) array
        Current generators.
    c : (n,) array
        Measurement direction.
    y : float
        Measurement scalar (shifted by measurement noise center).
    phi : float
        Half-width of the strip.
    lam : (n,) array
        Free vector λ.

    Returns
    -------
    p_hat : (n,) array
    H_hat : (n, m+1) array
    """
    # In an FPGA implementation, this kernel would consist of:
    #  - dot product: residual = c^T p
    #  - axpy (vector FMA): p_hat = p + λ r
    #  - matrix-vector multiply: t = c^T H
    #  - outer product / rank-1 update: H_hat = H - λ t
    #  - append phi λ as new generator

    c = np.asarray(c, dtype=float).reshape(-1, 1)   # (n,1)
    lam = np.asarray(lam, dtype=float).reshape(-1, 1)  # (n,1)

    # scalar residual = c^T p
    #GABRIELE
    #residual = float(c.T @ p.reshape(-1, 1))
    residual = (c.T @ p.reshape(-1, 1)).item()
    r = y - residual

    # p_hat = p + λ r
    p_hat = p + (lam.flatten() * r)

    # t = c^T H : (1,m)
    t = c.T @ H   # (1,m)

    # H_hat = H - λ t
    H_hat = H - lam @ t   # (n,m)

    # Append phi λ as an extra generator
    H_hat = np.concatenate([H_hat, phi * lam], axis=1)  # (n,m+1)横向拼接

    return p_hat, H_hat


def fpga_row_sum_kernel(H_drop):
    """
    FPGA CANDIDATE KERNEL (OPTIONAL): row-sum of absolute values.

    Needed for zonotope reduction:

        row_sum_i = sum_j |(H_drop)_{i,j}|

    Parameters
    ----------
    H_drop : (n, m_drop) array

    Returns
    -------
    row_sum : (n,) array
    """
    # On FPGA: absolute value + row-wise accumulation; extremely simple.
    # Here: NumPy implementation.
    return np.sum(np.abs(H_drop), axis=1)


# =============================================================================
# ZONOTOPE CLASS
# =============================================================================

class Zonotope:
    """
    Zonotope Z = p ⊕ H B_m

    p ∈ R^n, H ∈ R^{n×m}, B_m = [-1,1]^m.
    """

    def __init__(self, p, H):
        self.p = np.asarray(p, dtype=float).reshape(-1) # 铺平 # Flatten
        H = np.asarray(H, dtype=float)
        if H.ndim == 1: # 检查数组 H的维度数
            H = H.reshape(self.p.size, 1) # 如果是一维 变成n行1列
        self.H = H

    def copy(self):
        """创建Zonotope的深拷贝"""
        return Zonotope(self.p.copy(), self.H.copy())

    @property
    def n(self):
        return self.p.size    # 返回中心点 p的维度，也就是奇诺多面体所处的空间维度。

    @property
    def m(self):
        return self.H.shape[1]  # 返回生成器矩阵 H的列数，也就是生成器向量的个数。

    # -------------------------------------------------------------------------
    # PREDICTION step (delegates to FPGA candidate kernel)
    # -------------------------------------------------------------------------
    def predict(self, A, B, u, W):
        """
        Wrapper around fpga_predict_kernel so that in the future this method
        can call the FPGA instead of NumPy.
        围绕 fpga_predict_kernel 创建封装层，以便未来该方法
        能够调用 FPGA 而不是 NumPy。
        """
        p_pred, H_pred = fpga_predict_kernel(
            p_x=self.p,
            H_x=self.H,
            A=A,
            B=B,
            u=u,
            p_w=W.p,
            H_w=W.H
        )
        return Zonotope(p_pred, H_pred)

    # -------------------------------------------------------------------------
    # INTERSECTION with one scalar measurement strip
    # -------------------------------------------------------------------------
    def intersect_with_strip(self, c, y, phi,method, lam=None):
        """
        Wrapper around fpga_strip_update_kernel.

        If lam is None, we choose lam = c (simple and effective in practice).
        method: 'None','segment', 'p_radius', 'volume'
        """
        c = np.asarray(c, dtype=float).reshape(-1)
        if method =='None':
            lam = c.copy()

        elif method == 'segment':
            # 您现有的方法（默认） # Your existing method (default)
            lam = self._optimal_lambda_segment(c, phi)
            
        elif method == 'p_radius':
            lam = self._optimal_lambda_p_radius(c, phi)
            
        elif method == 'volume':
            lam = self._optimal_lambda_volume(c, phi)
            
        else:
            raise ValueError(f"unknown method: {method}. Can choose: 'None', 'segment', 'p_radius', 'volume'")
        
        p_hat, H_hat = fpga_strip_update_kernel(
            p=self.p,
            H=self.H,
            c=c,
            y=y,
            phi=phi,
            lam=lam
        )
        return Zonotope(p_hat, H_hat)

    def _optimal_lambda_segment(self, c, phi):
        """最小Segment方法"""
        HHT = self.H @ self.H.T
        numerator = HHT @ c
        denominator = c.T @ HHT @ c + phi ** 2
        return numerator / denominator
    
    # def _optimal_lambda_p_radius(self, c, phi):
    #     c = c.reshape(-1, 1)
    #     HHT = self.H @ self.H.T
    #     eps = 1e-6
    #     P = np.linalg.inv(HHT + eps * np.eye(self.n))

    #     num = float(c.T @ P @ HHT @ c)
    #     den = float(c.T @ HHT @ P @ HHT @ c + phi**2 * c.T @ P @ c)

    #     alpha = num / den
    #     return (alpha * c).flatten()

    def _optimal_lambda_p_radius(self, c, phi):
        c = c.reshape(-1, 1)
        HHT = self.H @ self.H.T

        eps = 1e-6
        P = np.linalg.inv(HHT + eps * np.eye(self.n))

        numerator = P @ HHT @ c
        denominator = (
            c.T @ HHT @ P @ HHT @ c
            + phi**2 * c.T @ P @ c
        )

        return (numerator / denominator).flatten()

    
    # def _optimal_lambda_p_radius(self, c, phi, P=None):
    #     """最小P-半径方法"""
    #     c = np.asarray(c, dtype=float).reshape(-1, 1)  # 确保c为列向量
    #     HHT = self.H @ self.H.T
        
    #     # 关键：使用简单的P矩阵
    #     if P is None:
    #         # 选项1：单位矩阵（最稳定） # Option 1: identity matrix (most stable)
    #         P = np.eye(self.n)
            
    #         # 或者选项2：缩放的单位矩阵 # Or option 2: scaled identity matrix
    #         # trace_val = np.trace(HHT)
    #         # if trace_val > 1e-10:
    #         #     P = np.eye(self.n) / trace_val
    #         # else:
    #         #     P = np.eye(self.n)
        
    #     # 数值稳定性：检查分母 # Numerical stability: check denominator
    #     try:
    #         numerator = P @ HHT @ c
    #         term1 = float(c.T @ HHT @ P @ HHT @ c)
    #         term2 = float(phi**2 * c.T @ P @ c)
    #         denominator = term1 + term2
            
    #         if abs(denominator) < 1e-12:
    #             # 分母太小，退回到Segment方法
    #             return self._optimal_lambda_segment(c.flatten(), phi)
            
    #         lam = numerator / denominator
    #         return lam.flatten()
            
    #     except Exception as e:
    #         print(f"P-radius计算错误: {e}")
    #         # 紧急备用：使用Segment方法
    #         return self._optimal_lambda_segment(c.flatten(), phi)
    
    def _optimal_lambda_volume(self, c, phi):
        """
        Closed-form volume lambda, aligned with C++ and HLS implementations.

        Derivation: minimise the scalar alpha that scales c such that
            alpha = ||c^T H||^2 / (||c||^2 * (||c^T H||^2 + phi^2))
            lambda = alpha * c

        This matches compute_lambda_volume() in zonotope_operations.cpp and
        the HLS kernel exactly, enabling fair cross-platform comparison.
        """
        c = np.asarray(c, dtype=float).reshape(-1)
        t = self.H.T @ c          # (m,)  t_j = c^T h_j
        t_sq = float(np.dot(t, t))
        c_sq = float(np.dot(c, c))
        denom = c_sq * (t_sq + phi ** 2)
        alpha = (t_sq / denom) if denom > 1e-12 else 0.0
        return alpha * c

    # -------------------------------------------------------------------------
    # REDUCTION (uses fpga_row_sum_kernel for the row-sum part)
    # -------------------------------------------------------------------------
    def reduce(self, max_gens):
        """
        Order reduction aligned with C++ and HLS implementations.

        Strategy: keep the (max_gens - n) generators with largest L2 norm,
        aggregate the rest into a diagonal box via row-sum of absolute values.
        Final generator count = (max_gens - n) + n = max_gens.

        This matches zonotope_reduce() in zonotope_operations.cpp exactly.
        """
        m = self.m
        if m <= max_gens:
            return self

        n = self.n  # state dimension (= N_STATE = 4)
        # keep_count: slots for "real" generators; n slots reserved for diag box
        keep_count = max(0, max_gens - n)

        col_norms = np.linalg.norm(self.H, axis=0)
        idx_sorted = np.argsort(-col_norms)  # descending

        keep_idx = idx_sorted[:keep_count]
        drop_idx = idx_sorted[keep_count:]

        H_keep = self.H[:, keep_idx]
        H_drop = self.H[:, drop_idx]

        # Row-sum of abs(H_drop) via FPGA candidate kernel
        row_sum = fpga_row_sum_kernel(H_drop)

        # Diagonal box appended as n extra generators
        rs_matrix = np.diag(row_sum)

        H_red = np.concatenate([H_keep, rs_matrix], axis=1)  # shape (n, max_gens)

        return Zonotope(self.p, H_red)

    # -------------------------------------------------------------------------
    # Sampling (for simulation / visualization)
    # -------------------------------------------------------------------------
    def sample(self, n_samples=1):    # nsample默认值=1
        """
        Draw random points x = p + H ξ, with ξ ∈ [-1,1]^m uniform.
        """
        m = self.m
        xi = 2 * np.random.rand(m, n_samples) - 1.0   
        # ξ 生成一个形状为 (m, n_samples)的数组，
        # 其中的每个元素都是在 [0, 1)-1区间内均匀分布的随机数。 # Each element is a random value uniformly distributed in [0, 1)-1.
        samples = self.p.reshape(-1, 1) + self.H @ xi 
        if n_samples == 1:
            return samples.flatten() # 一列变成一行 一维数组 # Turn one column into one row (1D array)
        return samples
    
    def vertices(self):
        """计算2D zonotope的顶点（用于可视化）"""
        if self.p.shape[0] != 2:
            raise ValueError("Only 2D zonotopes supported for visualization")

        m = self.m   # 生成器数量 列 # Number of generators (columns)
        if m > 12:  # 性能限制 # Performance limit
            # 使用近似方法计算顶点 # Compute vertices with an approximate method
            angles = np.linspace(0, 2 * np.pi, 36)  # 0°到360°，36个等分角度 # 0° to 360°, divided into 36 equal angles
            vertices = []
            for angle in angles:
                d = np.array([np.cos(angle), np.sin(angle)])   # 长度为1的方向向量 # Unit direction vector
                support = self.p.flatten() + self.H @ np.sign(self.H.T @ d)    # flatten()将多维数组转换为一维数组
                # sign
                # 物理意义：判断每个箭头在该方向上是"推动"还是"拉回" # Physical meaning: decide whether each vector pushes or pulls back in this direction
                # 数学原理：如果箭头方向与搜索方向夹角<90°，则取+1（推动）；否则取-1（拉回）--sign([1, 0.5]) = [1, 1]  # 都是正数，取+1
                vertices.append(support)
            return np.array(vertices)
        else:                 # 精确计算所有顶点组合 # Compute all vertex combinations exactly
            vertices = []
            for i in range(2 ** m):
                coeffs = np.array([2 * int(b) - 1 for b in format(i, f'0{m}b')])
                # format(i, f'0{m}b')  # 将数字i转为m位二进制字符串
                # [2 * int(b) - 1 for b in binary_string] 将101，按位转换为1，-1，1.   2*0-1=-1，2*1-1=1
                point = self.p.flatten() + self.H @ coeffs    # point = 中心点 + 生成器矩阵 × ±1系数向量
                vertices.append(point)
            return np.array(vertices)

    def plot(self, ax, color='blue', alpha=0.3, label=None, linewidth=1,dims=(0, 1)):
        """绘制2D zonotope"""
        if self.n < 2:
            raise ValueError("需要至少2维状态才能可视化")
        if len(dims) != 2:
            raise ValueError("dims参数必须是包含两个维度索引的元组")
        # 提取前两个维度的数据 # Extract data from the first two dimensions
        dim1, dim2 = dims

        try:
            # 提取前两个维度的子Zonotope
            p_2d = self.p[[dim1, dim2]]  # 前两个维度的中心点 # Centers of the first two dimensions
            H_2d = self.H[[dim1, dim2], :]  # 前两个维度的生成器 # Generators of the first two dimensions
            # 创建2D投影的Zonotope
            zono_2d = Zonotope(p_2d, H_2d)
            verts = zono_2d.vertices()
            from scipy.spatial import ConvexHull  # 计算顶点 # Compute vertices
            hull = ConvexHull(verts)
            from matplotlib.patches import Polygon  # 绘制多边形 # Draw polygon
            poly = Polygon(verts[hull.vertices], facecolor=color, alpha=alpha,
                           label=label, edgecolor=color, linewidth=linewidth)
            ax.add_patch(poly)
            ax.plot(p_2d[0], p_2d[1], 'o', color=color, markersize=4)
        except Exception as e:
            print(f"警告：绘制Zonotope时出错: {e}")
        # 备用方案：只绘制中心点 # Fallback: draw only the center point
            ax.plot(self.p[dim1], self.p[dim2], 'o', color=color, 
                markersize=6, label=label, alpha=alpha)


# =============================================================================
# SYSTEM MATRICES (TIME-VARYING, PARAMETRIC)
# =============================================================================

def system_matrices(k, dt=DT):        # DT=0.1-Sampling time 采样时间
    """
    Defines time-varying (A_k, B_k, C_k) for an n-dimensional system.

    Example design:
    - A_k: small rotation in the (0,1) plane + identity on remaining states.
    - B_k: zeros (no real control in this toy example).
    - C_k: select the first N_MEAS state components.

    This keeps everything nicely structured and works for any N_STATE >= 2.
    """
    theta = 0.05 * k * dt  # small angle

    cth = np.cos(theta)
    sth = np.sin(theta)

    # Start from identity 创建标准的由1构成的对角矩阵
    A_k = np.eye(N_STATE)

    # Embed 2D rotation in the top-left 2×2 block
    # 左上角 2x2 块嵌入了一个旋转矩阵
    #GABRIELE i changed dynamics
    #if N_STATE >= 2:
    #    A_k[0:2, 0:2] = np.array([[cth, -1.5*sth],
    #                              [1.5*sth,  cth]])
    #    eps = 0.1
    #    delta = 0.05
    #    A_k[0,2] = eps
    #    A_k[1,3] = eps
    #    A_k[2,0] = -delta
    #    A_k[3,1] = -delta

    omega = 0.5  # Frequency of oscillation
    zeta = 0.05  # Damping ratio (to keep it from oscillating forever)
    
    # A_k: Uses a rotation-like structure to simulate oscillation
    c = np.cos(omega * dt) * np.exp(-zeta * dt)
    s = np.sin(omega * dt) * np.exp(-zeta * dt)

    # Each 4x4 block is an oscillator; they are coupled at the corners
    A_block = np.array([
        [ c, -s, 0.1, 0.0],
        [ s,  c, 0.0, 0.1],
        [-0.1, 0.0, c, -s],
        [ 0.0,-0.1, s,  c]
    ])
    A_k = np.zeros((N_STATE, N_STATE))
    for i in range(N_STATE // 4):
        start = i * 4
        A_k[start:start+4, start:start+4] = A_block

    # No actual control input, but keep the dimension
    B_k = np.zeros((N_STATE, N_INPUT))

    # C_k: for each 4x4 oscillator block, measure its first two states.
    C_k = np.zeros((N_MEAS, N_STATE))
    for block in range(N_STATE // 4):
        meas_base = block * 2
        state_base = block * 4
        if meas_base + 1 < N_MEAS:
            C_k[meas_base + 0, state_base + 0] = 1.0
            C_k[meas_base + 1, state_base + 1] = 1.0

    return A_k, B_k, C_k


# 定位仓库根目录。 # Locate the repository root.
def _repo_root():
    return Path(__file__).resolve().parents[2]


def _prepare_output_dirs(method_label=None):
    output_root = _repo_root() / "data" / "output"
    base_dir = output_root / OUTPUT_PARTITION
    # 每个方法独立子目录，与 HLS/C++ 输出结构一致
    # Each method gets its own subdirectory, consistent with HLS/C++ output structure
    if method_label:
        python_dir = output_root / "python" / method_label
    else:
        python_dir = output_root / "python"
    compare_dir = base_dir
    python_dir.mkdir(parents=True, exist_ok=True)
    compare_dir.mkdir(parents=True, exist_ok=True)
    return base_dir, python_dir, compare_dir

# CSV 存取。
def _save_csv(path, arr):
    arr = np.asarray(arr, dtype=float)
    if arr.ndim == 1:
        arr = arr.reshape(1, -1)
    np.savetxt(path, arr, delimiter=",")


def _load_csv_2d(path):
    if not path.exists():
        return np.zeros((0, 0), dtype=float)
    try:
        arr = np.loadtxt(path, delimiter=",")
    except Exception:
        return np.zeros((0, 0), dtype=float)
    arr = np.asarray(arr, dtype=float)
    if arr.ndim == 1:
        return arr.reshape(1, -1)
    return arr

# 按 p/H 格式导出Zonotope （每个 zonotope 存为一个 CSV 文件，第一行是中心点 p，后续行是生成器 H的列）。
def _save_zonotope_csv(path, zonotope):
    with path.open("w", encoding="utf-8") as f:
        f.write("p," + ",".join(f"{float(v):.17g}" for v in zonotope.p) + "\n")
        for j in range(zonotope.m):
            h_col = zonotope.H[:, j]
            f.write("H," + ",".join(f"{float(v):.17g}" for v in h_col) + "\n")


def _load_zonotope_csv(path):
    p = None
    generators = []
    if not path.exists():
        return np.zeros((0,), dtype=float), np.zeros((0, 0), dtype=float)

    with path.open("r", encoding="utf-8") as f:
        for raw in f:
            line = raw.strip()
            if not line:
                continue
            parts = line.split(",")
            if len(parts) <= 1:
                continue
            label = parts[0]
            data = np.asarray([float(x) for x in parts[1:]], dtype=float)
            if label == "p":
                p = data
            elif label == "H":
                generators.append(data)

    if p is None:
        return np.zeros((0,), dtype=float), np.zeros((0, 0), dtype=float)

    if generators:
        H = np.asarray(generators, dtype=float).T
    else:
        H = np.zeros((p.size, 0), dtype=float)
    return p, H


def _max_distance_point_to_true(p, H, x_true, exact_m_limit=14):
    p = np.asarray(p, dtype=float).reshape(-1)
    x_true = np.asarray(x_true, dtype=float).reshape(-1)
    H = np.asarray(H, dtype=float)
    if H.ndim == 1:
        H = H.reshape(p.size, 1)

    if p.size == 0 or x_true.size == 0:
        return 0.0, np.zeros((0,), dtype=float)

    n = min(p.size, x_true.size)
    p_eval = p[:n]
    x_eval = x_true[:n]
    H_eval = H[:n, :] if H.size > 0 else np.zeros((n, 0), dtype=float)

    m = H_eval.shape[1]
    if m == 0:
        return float(np.linalg.norm(p_eval - x_eval)), p_eval.copy()

    if m <= exact_m_limit:
        num_vertices = 1 << m
        bit_grid = ((np.arange(num_vertices)[:, None] >> np.arange(m)) & 1).astype(float)
        signs = 2.0 * bit_grid - 1.0
        pts = p_eval.reshape(1, -1) + signs @ H_eval.T
        d2 = np.sum((pts - x_eval.reshape(1, -1)) ** 2, axis=1)
        idx = int(np.argmax(d2))
        return float(np.sqrt(d2[idx])), pts[idx]

    rng = np.random.default_rng(0)
    signs = rng.choice([-1.0, 1.0], size=(4096, m))
    pts = p_eval.reshape(1, -1) + signs @ H_eval.T
    d2 = np.sum((pts - x_eval.reshape(1, -1)) ** 2, axis=1)
    idx = int(np.argmax(d2))
    return float(np.sqrt(d2[idx])), pts[idx]


def _max_error_from_zonotopes(zonotopes, true_arr):
    n_steps = min(len(zonotopes), true_arr.shape[0])
    max_err = np.zeros((n_steps,), dtype=float)
    far_points = np.zeros((n_steps, true_arr.shape[1]), dtype=float)

    for k in range(n_steps):
        dmax, x_far = _max_distance_point_to_true(zonotopes[k].p, zonotopes[k].H, true_arr[k])
        max_err[k] = dmax
        n = min(far_points.shape[1], x_far.size)
        far_points[k, :n] = x_far[:n]

    return max_err, far_points

# 导出 Python 结果以供 HLS 比较和分析。
def _export_python_outputs(python_dir, x_true_arr, center_est_arr, y_arr, zonotopes, step_time_us):
    _save_csv(python_dir / "x_true.csv", x_true_arr)
    _save_csv(python_dir / "center.csv", center_est_arr)
    _save_csv(python_dir / "meas.csv", y_arr)

    err = center_est_arr - x_true_arr
    err_l2 = np.linalg.norm(err, axis=1, keepdims=True)
    err_dump = np.hstack([err, err_l2])
    _save_csv(python_dir / "error.csv", err_dump)

    step_us = np.asarray(step_time_us, dtype=float)
    # 文件名与 HLS/C++ 保持一致，方便对比脚本统一读取
    # Filename consistent with HLS/C++ for the comparison script
    _save_csv(python_dir / "kernel_time_step_us.csv", step_us.reshape(-1, 1))
    summary = np.array([[step_us.sum(), step_us.mean() if step_us.size > 0 else 0.0, step_us.size]], dtype=float)
    _save_csv(python_dir / "kernel_time_summary_us.csv", summary)

    for k, zono in enumerate(zonotopes):
        _save_zonotope_csv(python_dir / f"zonotope_{k:03d}.csv", zono)

# 查找 HLS 参考结果目录（如果存在）以进行比较。
def _find_hls_ref_dir():
    fpga_root = _repo_root() / "data" / "output" / "hls"

    candidates = [
        fpga_root / HLS_REF_MODE / HLS_REF_METHOD,
        fpga_root / "cosim" / HLS_REF_METHOD,
    ]
    for path in candidates:
        if path.exists():
            return path

    for mode in ("csim", "cosim"):
        mode_dir = fpga_root / mode
        if not mode_dir.exists():
            continue
        method_dirs = sorted([p for p in mode_dir.iterdir() if p.is_dir()])
        if method_dirs:
            return method_dirs[0]
    return None

# 画对比图（轨迹、中心误差、最大距离误差、speedup）并写 summary。
def _plot_hls_vs_python(compare_dir, x_true_arr, center_est_arr, zonotopes, step_time_us):
    hls_dir = _find_hls_ref_dir()
    if hls_dir is None:
        print("[INFO] No HLS result directory found under data/output/hls, skip comparison plots.")
        return

    hls_center = _load_csv_2d(hls_dir / "center.csv")
    hls_true = _load_csv_2d(hls_dir / "x_true.csv")
    hls_err = _load_csv_2d(hls_dir / "error.csv")
    hls_time = _load_csv_2d(hls_dir / "kernel_time_step_us.csv")

    py_true = np.asarray(x_true_arr, dtype=float)
    py_center = np.asarray(center_est_arr, dtype=float)
    py_error_l2 = np.linalg.norm(py_center - py_true, axis=1)
    py_step_us = np.asarray(step_time_us, dtype=float)

    n_state_common = min(py_center.shape[1], hls_center.shape[1]) if hls_center.size > 0 else py_center.shape[1]
    n_step_common = min(py_center.shape[0], hls_center.shape[0]) if hls_center.size > 0 else py_center.shape[0]
    k_common = np.arange(n_step_common)

    if n_step_common > 0:
        fig, axes = plt.subplots(1, 2 if n_state_common >= 2 else 1, figsize=(10, 3.5))
        if n_state_common >= 2:
            ax0, ax1 = axes
        else:
            ax0 = axes
            ax1 = None

        ax0.plot(k_common, py_true[:n_step_common, 0], "k-", linewidth=1.5, label="True (Python)")
        ax0.plot(k_common, py_center[:n_step_common, 0], "b--o", markersize=3, label="Python center")
        if hls_center.size > 0:
            ax0.plot(k_common, hls_center[:n_step_common, 0], "r-.s", markersize=3, label="HLS center")
        ax0.set_xlabel("Step k")
        ax0.set_ylabel("x[0]")
        ax0.grid(True, linestyle=":")
        ax0.legend(loc="best")

        if ax1 is not None:
            ax1.plot(k_common, py_true[:n_step_common, 1], "k-", linewidth=1.5, label="True (Python)")
            ax1.plot(k_common, py_center[:n_step_common, 1], "b--o", markersize=3, label="Python center")
            if hls_center.size > 0 and hls_center.shape[1] >= 2:
                ax1.plot(k_common, hls_center[:n_step_common, 1], "r-.s", markersize=3, label="HLS center")
            ax1.set_xlabel("Step k")
            ax1.set_ylabel("x[1]")
            ax1.grid(True, linestyle=":")
            ax1.legend(loc="best")

        fig.suptitle("HLS vs Python estimation centers")
        fig.tight_layout()
        fig.savefig(compare_dir / "trajectory_hls_vs_python.png", dpi=160)
        plt.close(fig)

    if hls_err.size > 0:
        if hls_err.shape[1] >= 5:
            hls_error_l2 = hls_err[:, 4]
        else:
            hls_error_l2 = np.linalg.norm(hls_err, axis=1)
    else:
        hls_error_l2 = np.zeros((0,), dtype=float)

    py_max_err_l2, py_far_points = _max_error_from_zonotopes(zonotopes, py_true)

    hls_max_err_l2 = np.zeros((0,), dtype=float)
    hls_far_points = np.zeros((0, py_true.shape[1]), dtype=float)
    hls_zono_files = sorted(hls_dir.glob("zonotope_*.csv"))
    if hls_zono_files:
        hls_true_eval = hls_true if hls_true.size > 0 else py_true
        n_hls = min(len(hls_zono_files), hls_true_eval.shape[0])
        hls_max_list = []
        hls_far_list = []
        for k in range(n_hls):
            p_hls, H_hls = _load_zonotope_csv(hls_zono_files[k])
            dmax, x_far = _max_distance_point_to_true(p_hls, H_hls, hls_true_eval[k])
            hls_max_list.append(dmax)

            x_far_row = np.zeros((py_true.shape[1],), dtype=float)
            n_dim = min(x_far_row.size, x_far.size)
            x_far_row[:n_dim] = x_far[:n_dim]
            hls_far_list.append(x_far_row)

        hls_max_err_l2 = np.asarray(hls_max_list, dtype=float)
        hls_far_points = np.asarray(hls_far_list, dtype=float)

    n_err = min(py_error_l2.size, hls_error_l2.size)
    if n_err > 0:
        fig, ax = plt.subplots(figsize=(8, 3.5))
        kk = np.arange(n_err)
        ax.plot(kk, py_error_l2[:n_err], "b-", linewidth=1.5, label="Python L2 error")
        ax.plot(kk, hls_error_l2[:n_err], "r-", linewidth=1.5, label="HLS L2 error")
        ax.set_xlabel("Step k")
        ax.set_ylabel("L2(center - true)")
        ax.set_title("Error comparison: HLS vs Python")
        ax.grid(True, linestyle=":")
        ax.legend(loc="best")
        fig.tight_layout()
        fig.savefig(compare_dir / "error_hls_vs_python.png", dpi=160)
        plt.close(fig)

    n_err_max = max(py_error_l2.size, py_max_err_l2.size, hls_error_l2.size, hls_max_err_l2.size)
    if n_err_max > 0:
        fig, ax = plt.subplots(figsize=(8.6, 4.0))
        if py_error_l2.size > 0:
            ax.plot(np.arange(py_error_l2.size), py_error_l2, color="tab:blue", linestyle="-", linewidth=1.6, label="Python center error")
        if py_max_err_l2.size > 0:
            ax.plot(np.arange(py_max_err_l2.size), py_max_err_l2, color="tab:blue", linestyle="--", linewidth=1.6, label="Python max-point error")
        if hls_error_l2.size > 0:
            ax.plot(np.arange(hls_error_l2.size), hls_error_l2, color="tab:red", linestyle="-", linewidth=1.6, label="HLS center error")
        if hls_max_err_l2.size > 0:
            ax.plot(np.arange(hls_max_err_l2.size), hls_max_err_l2, color="tab:red", linestyle="--", linewidth=1.6, label="HLS max-point error")

        ax.set_xlabel("Step k")
        ax.set_ylabel("L2 error")
        ax.set_title("Center vs max-point error (HLS and Python)")
        ax.grid(True, linestyle=":")
        ax.legend(loc="best")
        fig.tight_layout()
        fig.savefig(compare_dir / "error_center_vs_max_hls_python.png", dpi=160)
        plt.close(fig)

        table = np.full((n_err_max, 5), np.nan, dtype=float)
        table[:, 0] = np.arange(n_err_max)
        table[:py_error_l2.size, 1] = py_error_l2
        table[:py_max_err_l2.size, 2] = py_max_err_l2
        table[:hls_error_l2.size, 3] = hls_error_l2
        table[:hls_max_err_l2.size, 4] = hls_max_err_l2
        _save_csv(compare_dir / "error_center_and_max.csv", table)

        if py_far_points.shape[0] > 0:
            _save_csv(compare_dir / "python_farthest_points.csv", py_far_points)
        if hls_far_points.shape[0] > 0:
            _save_csv(compare_dir / "hls_farthest_points.csv", hls_far_points)

    if hls_time.size > 0 and hls_time.shape[1] >= 3 and py_step_us.size > 0:
        hls_step_us = np.sum(hls_time[:, :3], axis=1)
        n_speed = min(py_step_us.size, hls_step_us.size)
        start_idx = 1 if n_speed > 1 else 0
        step_ids = np.arange(start_idx, n_speed)
        py_step_eval = py_step_us[start_idx:n_speed]
        safe_hls = hls_step_us[start_idx:n_speed]
        speedup_x = np.divide(
            py_step_eval,
            safe_hls,
            out=np.zeros_like(py_step_eval),
            where=safe_hls > 0.0
        )

        speedup_table = np.column_stack([
            step_ids,
            py_step_eval,
            safe_hls,
            speedup_x
        ])
        _save_csv(compare_dir / "speedup_step_x.csv", speedup_table)

        fig, ax = plt.subplots(figsize=(8, 3.5))
        kk = step_ids
        ax.plot(kk, speedup_x, "g-o", markersize=3, linewidth=1.3, label="Speedup = Python / HLS")
        ax.axhline(np.mean(speedup_x), color="k", linestyle="--", linewidth=1.2, label=f"Avg = {np.mean(speedup_x):.2f}x")
        ax.set_xlabel("Step k")
        ax.set_ylabel("Speedup (x)")
        ax.set_title("Per-step speedup factor (k>=1)")
        ax.grid(True, linestyle=":")
        ax.legend(loc="best")
        fig.tight_layout()
        fig.savefig(compare_dir / "speedup_factor_x.png", dpi=160)
        plt.close(fig)

        with (compare_dir / "compare_summary.txt").open("w", encoding="utf-8") as f:
            f.write(f"HLS reference directory: {hls_dir}\n")
            f.write(f"Python avg step time (us): {np.mean(py_step_eval):.6f}\n")
            f.write(f"HLS avg kernel step time (us): {np.mean(safe_hls):.6f}\n")
            f.write(f"Average speedup (x): {np.mean(speedup_x):.6f}\n")


# =============================================================================
# MAIN SIMULATION + ESTIMATION
# =============================================================================

def run_example(method=None, method_label=None):
    """
    method: 传入方法字符串，如 'None','segment','p_radius','volume'
            传 None 时使用全局 ESTIMATION_METHOD
            method string, e.g. 'None','segment','p_radius','volume'.
            If None, uses global ESTIMATION_METHOD.
    method_label: 输出目录名，如 'LAMBDA_NONE'
                  output directory name, e.g. 'LAMBDA_NONE'
    """
    if method is None:
        method = ESTIMATION_METHOD
    if method_label is None:
        method_label = "LAMBDA_" + method.upper()

    # NumPy的伪随机数生成器，相同的初始种子（第一个），会生成相同的随机序列
    # Reset seed per method for fair comparison (same noise sequence)
    np.random.seed(RANDOM_SEED)

    # -----------------------------
    # Process noise zonotope W
    # -----------------------------
    p_w = np.zeros(N_STATE)
    # Box along each state coordinate with radius PROC_NOISE_RADIUS
    H_w = np.diag([PROC_NOISE_RADIUS] * N_STATE)
    W = Zonotope(p_w, H_w)

    # -----------------------------
    # Measurement noise zonotope V (dimension N_MEAS)
    # -----------------------------
    p_v = np.zeros(N_MEAS)
    # Box along each measurement with radius MEAS_NOISE_RADIUS
    H_v = np.diag([MEAS_NOISE_RADIUS] * N_MEAS)
    V = Zonotope(p_v, H_v)

    # Strip half-widths φ_i = l1 norm of i-th row of H_v  L1范数
    phi_vec = np.sum(np.abs(H_v), axis=1)  # shape (N_MEAS,)

    # -----------------------------
    # Initial true state and initial zonotope X_0
    # -----------------------------
    x_true = np.zeros(N_STATE) #长度为nstate的一维数组
    # Put initial true state slightly away from the origin.
    if N_STATE >= 2:
        x_true[:2] = np.array([1.0, 0.0])
    # 如果状态维度至少为 2，那么将状态向量的前两个元素（即索引 0 和 1）分别设置为 1.0和 0.0。 # If state dimension is at least 2, set the first two state elements (indices 0 and 1) to 1.0 and 0.0.
    # x_true[:2]是 Python 的切片语法，表示从开始到索引 2（不包括 2）的所有元素。
    else:
        x_true[0] = 1.0

    # Initial zonotope X_0 = box of radius INIT_RADIUS around x_true
    p_x0 = x_true.copy()
    H_x0 = np.diag([INIT_RADIUS] * N_STATE)
    X = Zonotope(p_x0, H_x0)

    # Logs
    x_true_list = [x_true.copy()]
    y_list = []
    center_est_list = [X.p.copy()]
    zonotopes = [X.copy()]
    step_time_us = []
    # 在循环中添加监测 # Add monitoring in the loop
    size_history = []

    for k in range(NUM_STEPS):
        A_k, B_k, C_k = system_matrices(k, dt=DT)

        # === TRUE SYSTEM === 真实系统仿真（计时外，与 FPGA board 基准对齐）
        # True system update: outside timing window, aligned with board standard
        w_k = W.sample(n_samples=1)
        u_k = np.zeros(N_INPUT)
        x_true = A_k @ x_true + B_k @ u_k + w_k
        x_true_list.append(x_true.copy())

        # Measurement: y_k = C_k x_k + v_k（计时外）// outside timing window
        v_k = V.sample(n_samples=1)   # (N_MEAS,)
        y_k = C_k @ x_true + v_k      # (N_MEAS,)
        y_list.append(y_k.copy())

        # === 计时开始：只包裹纯 estimator（predict → strip × N_MEAS → reduce）===
        # Start timing: only wrap pure estimator, matching FPGA board AP_START→AP_DONE
        step_start = time.perf_counter()

        # === ESTIMATOR: Prediction ===
        X_pred = X.predict(A_k, B_k, u_k, W)

        # === ESTIMATOR: Correction with N_MEAS strips ===
        X_upd = X_pred
        for i in range(N_MEAS):  # 测量更新 # Measurement update
            c_i = C_k[i, :]                  # (n,)从一个二维数组（或矩阵）C_k中，提取出第 i行的所有元素，并赋值给一个一维向量 c_i
            y_tilde_i = y_k[i] - p_v[i]      # shift by center of meas noise
            phi_i = phi_vec[i]
            X_upd = X_upd.intersect_with_strip(c=c_i, y=y_tilde_i, phi=phi_i, method=method)
        ''' method: 'None','segment', 'p_radius', 'volume'''

        # === Reduction ===
        X = X_upd.reduce(max_gens=REDUCTION_BUDGET)

        # === 计时结束 // End timing ===
        step_time_us.append((time.perf_counter() - step_start) * 1e6)

        center_est_list.append(X.p.copy())
        zonotopes.append(X.copy())

        # 记录Zonotope大小
        zonotope_size = np.sum(np.linalg.norm(X.H, axis=0))
        size_history.append(zonotope_size)
        print(f"Steps {k}: Zonotope size = {zonotope_size:.4f}")

        print(f"\n--- Time step k = {k+1} ---")
        print(f"True state       x_true = {x_true}")
        print(f"Measurement        y_k  = {y_k}")
        print(f"Estimator center  p^x_k = {X.p}")
        print(f"# generators m_k          = {X.m}")

    x_true_arr = np.vstack(x_true_list)         # (NUM_STEPS+1, N_STATE)
    center_est_arr = np.vstack(center_est_list) # (NUM_STEPS+1, N_STATE)
    y_arr = np.vstack(y_list)                   # (NUM_STEPS, N_MEAS)

    print("\nSimulation completed.")
    print("Final true state      :", x_true_arr[-1])
    print("Final estimate center :", center_est_arr[-1])

    base_dir, python_dir, compare_dir = _prepare_output_dirs(method_label)
    _export_python_outputs(
        python_dir=python_dir,
        x_true_arr=x_true_arr,
        center_est_arr=center_est_arr,
        y_arr=y_arr,
        zonotopes=zonotopes,
        step_time_us=step_time_us,
    )
    _plot_hls_vs_python(
        compare_dir=compare_dir,
        x_true_arr=x_true_arr,
        center_est_arr=center_est_arr,
        zonotopes=zonotopes,
        step_time_us=step_time_us,
    )
    print(f"Python outputs exported to: {python_dir}")
    print(f"Python-vs-HLS comparison outputs: {compare_dir}")

    # -------------------------------------------------------------------------
    # COMPREHENSIVE PLOTS (4D Tracking, Phase Analysis, and Error Metrics)
    # -------------------------------------------------------------------------
    import shutil
    plots_dir = python_dir / "plots"  # 每个方法的 plots 在各自子目录下 // plots per method in its own subdir
    if plots_dir.exists():
        shutil.rmtree(plots_dir)
    plots_dir.mkdir(parents=True)

    k_grid = np.arange(NUM_STEPS + 1)

    # Calculate Error Metrics
    # 1. Euclidean distance between center and true state
    py_error_l2 = np.linalg.norm(center_est_arr - x_true_arr, axis=1)
    # 2. Maximum distance from true state to any point inside the zonotope
    py_max_err_l2, _ = _max_error_from_zonotopes(zonotopes, x_true_arr)

    # --- Figure 1: Time-Series for all states ---
    rows = (N_STATE + 1) // 2
    cols = 2
    fig1, axes1 = plt.subplots(rows, cols, figsize=(12, 3 * rows))
    axes1 = axes1.flatten()
    for i in range(N_STATE):
        ax = axes1[i]
        ax.plot(k_grid, x_true_arr[:, i], 'ro-', label=f'x_{i} true', markersize=3, alpha=0.5)
        ax.plot(k_grid, center_est_arr[:, i], 'bs--', label=f'x_{i} est', markersize=3)
        ax.set_xlabel('Step k')
        ax.set_ylabel(f'Value x_{i}')
        ax.set_title(f'State x_{i} Tracking')
        ax.grid(True, linestyle=':', alpha=0.5)
        ax.legend(fontsize='small')
    # Clear any unused subplots
    for j in range(i + 1, len(axes1)):
        fig1.delaxes(axes1[j])
    fig1.suptitle(f"Time-Series State Estimation ({N_STATE}D)", fontsize=14)
    fig1.tight_layout()
    fig1.savefig(plots_dir / "state_timeseries.png", dpi=160)
    plt.close(fig1)

    # --- Figure 2: Phase Plots with Initial Point Marker ---
    fig2, (ax_a, ax_b) = plt.subplots(1, 2, figsize=(14, 6))
    projection_pairs = [(0, 2), (1, 3)]
    plot_axes = [ax_a, ax_b]
    colors = plt.cm.viridis(np.linspace(0, 1, len(zonotopes)))

    for idx, (dim_x, dim_y) in enumerate(projection_pairs):
        ax = plot_axes[idx]
        for i, Z in enumerate(zonotopes):
            Z.plot(ax, color=colors[i], alpha=0.15, dims=(dim_x, dim_y))
        ax.plot(x_true_arr[:, dim_x], x_true_arr[:, dim_y], 'r-', label='True Path', alpha=0.6)
        ax.plot(center_est_arr[:, dim_x], center_est_arr[:, dim_y], 'b--', label='Est. Center')
        ax.plot(x_true_arr[0, dim_x], x_true_arr[0, dim_y], 'g*', markersize=12, label='START (k=0)', zorder=5)
        ax.set_xlabel(f'State x_{dim_x}')
        ax.set_ylabel(f'State x_{dim_y}')
        ax.set_title(f'Phase: x_{dim_x} vs x_{dim_y}')
        ax.legend(loc='best', fontsize='small')
        ax.grid(True, linestyle=':', alpha=0.4)
    fig2.tight_layout()
    fig2.savefig(plots_dir / "phase_plots.png", dpi=160)
    plt.close(fig2)

    # --- Figure 3: Error Norm Analysis ---
    fig3, ax3 = plt.subplots(figsize=(10, 5))
    ax3.plot(k_grid, py_error_l2, 'b-o', label='Euclidean Error (Center to True)', markersize=4)
    ax3.plot(k_grid, py_max_err_l2, 'r--s', label='Max Distance (True to Zonotope Bound)', markersize=4)
    ax3.fill_between(k_grid, py_error_l2, py_max_err_l2, color='gray', alpha=0.1, label='Uncertainty Range')
    ax3.set_xlabel('Step k')
    ax3.set_ylabel('Norm Error ($L_2$)')
    ax3.set_title('Estimation Error and Bound Performance')
    ax3.grid(True, linestyle=':', alpha=0.6)
    ax3.legend()
    fig3.tight_layout()
    fig3.savefig(plots_dir / "error_norm.png", dpi=160)
    plt.close(fig3)

    print(f"Python plots saved to: {plots_dir}")

    return x_true_arr, center_est_arr, y_arr


import cProfile
import pstats
import io
import numpy as np


def simple_profile_kernels():
    """
    简单直接地分析三个FPGA内核函数的性能
    """
    print("开始专项测试 fpga_predict_kernel, fpga_strip_update_kernel, fpga_row_sum_kernel ...")
    # 1. 创建性能分析器 # 1. Create the profiler
    pr = cProfile.Profile()

    # 2. 启动分析 # 2. Start profiling
    pr.enable()

    # 3. 模拟核心计算循环，这是分析的重点 # 3. Simulate the core compute loop; this is the profiling focus
    # 设置测试参数 # Set test parameters
    n_state = N_STATE
    n_input = N_INPUT
    n_meas = N_MEAS
    num_test_steps = 100  # 测试循环次数，可调整 # Number of test iterations (adjustable)

    # 生成模拟数据 # Generate mock data
    np.random.seed(RANDOM_SEED)
    p_x = np.random.rand(n_state)
    H_x = np.random.rand(n_state, 10)  # 假设有10个生成器 # Assume there are 10 generators
    A = np.random.rand(n_state, n_state)
    B = np.random.rand(n_state, n_input)
    u = np.random.rand(n_input)
    p_w = np.random.rand(n_state)
    H_w = np.random.rand(n_state, n_state)

    p = np.random.rand(n_state)
    H = np.random.rand(n_state, 15)
    c = np.random.rand(n_state)
    y = 0.5
    phi = 0.1
    lam = c.copy()

    H_drop = np.random.rand(n_state, 20)

    # 模拟实际调用过程 # Simulate the actual call flow
    for _ in range(num_test_steps):
        # 模拟调用 predict_kernel
        p_pred, H_pred = fpga_predict_kernel(p_x, H_x, A, B, u, p_w, H_w)

        # 模拟调用 strip_update_kernel (对于每个测量值)
        for i in range(n_meas):
            p_upd, H_upd = fpga_strip_update_kernel(p, H, c, y + i * 0.1, phi, lam)

        # 模拟调用 row_sum_kernel
        row_sum = fpga_row_sum_kernel(H_drop)

        # 轻微更新数据以模拟真实情况 # Slightly update data to mimic real conditions
        p_x = p_pred.copy()
        H = H_upd.copy()

    # 4. 停止分析 # 4. Stop profiling
    pr.disable()
    print("测试循环完成，生成分析报告...\n")

    # 5. 生成简洁的分析报告 # 5. Generate a concise profiling report
    s = io.StringIO()
    ps = pstats.Stats(pr, stream=s)

    # 创建一个简洁明了的报告 # Create a clear and concise report
    print("=" * 65)
    print("FPGA 内核函数性能报告 (按累计时间排序)")
    print("=" * 65)

    # 只显示我们关心的三个内核函数及其直接相关调用 # Show only the three kernel functions of interest and directly related calls
    ps.strip_dirs().sort_stats(pstats.SortKey.CUMULATIVE)

    # 打印统计信息，重点关注这三个函数 # Print statistics focused on these three functions
    print("\n📊 主要内核函数性能概览:")
    ps.print_stats(r'fpga_(predict|strip_update|row_sum)_kernel')

    print("\n🔍 最耗时的5个函数 (全局):")
    ps.print_stats(5)

    # 计算并显示三个内核的总时间占比 # Compute and display the total time share of the three kernels
    total_time = ps.total_tt
    kernel_times = {}

    stats_dict = ps.stats
    for func, (cc, nc, tt, ct, callers) in stats_dict.items():
        func_name = func[2]  # 获取函数名 # Get function name
        if 'fpga_predict_kernel' in func_name:
            kernel_times['predict'] = ct
        elif 'fpga_strip_update_kernel' in func_name:
            kernel_times['strip_update'] = ct
        elif 'fpga_row_sum_kernel' in func_name:
            kernel_times['row_sum'] = ct

    if kernel_times and total_time > 0:
        print("\n📈 内核函数时间占比分析:")
        total_kernel_time = sum(kernel_times.values())
        print(f"三个内核函数总耗时: {total_kernel_time:.4f}s / 测试总耗时: {total_time:.4f}s")
        print(f"内核函数占比: {total_kernel_time / total_time * 100:.1f}%")

        for name, time_val in kernel_times.items():
            percentage = (time_val / total_time) * 100
            print(f"  {name:15}: {time_val:.4f}s ({percentage:.1f}%)")


# 在您的主函数中这样调用： # Call it like this in your main function:
if __name__ == "__main__":
    # 运行专项性能测试 # Run the dedicated performance test
    simple_profile_kernels()

    print(f"\n{'='*60}")
    print("Running method: LAMBDA_SEGMENT")
    print(f"{'='*60}")
    run_example(method="segment", method_label="LAMBDA_SEGMENT")

    

# if __name__ == "__main__":
#     x_true_arr, center_est_arr, y_arr = run_example()

