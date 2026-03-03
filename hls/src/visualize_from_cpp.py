import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon
from scipy.spatial import ConvexHull
import glob
import os

# 这里需要手动指定 N_STATE，确保与 C++ 中的宏定义一致
N_STATE = 4 
OUTPUT_DIR = "../hls/data/output"

class Zonotope:
    """Python 端的 Zonotope 绘图类"""
    def __init__(self, p, H):
        self.p = np.array(p)
        self.H = np.array(H)
        self.n = self.p.size
        self.m = self.H.shape[1] if self.H.ndim > 1 else 0

    def get_vertices_2d(self, dims=(0, 1)):
        """计算投影到 2D 平面上的顶点"""
        p_2d = self.p[list(dims)].reshape(-1, 1)
        H_2d = self.H[list(dims), :]
        
        # 支撑函数法：对于高维/多生成器 Zonotope 效率最高且最稳定
        angles = np.linspace(0, 2*np.pi, 100)
        directions = np.array([np.cos(angles), np.sin(angles)])
        # 通过 sign(H.T @ d) 快速找到极点
        vertices = p_2d + H_2d @ np.sign(H_2d.T @ directions)
        return vertices.T

    def plot(self, ax, color="tab:blue", alpha=0.25):
        if self.m == 0:
            return

        verts = self.get_vertices_2d()

        # 去重（非常重要，避免数值抖动）
        verts = np.unique(verts, axis=0)

        # ---- 情况 1：只有一个点 ----
        if verts.shape[0] == 1:
            ax.plot(verts[0, 0], verts[0, 1],
                    "o", color=color, markersize=3)
            return

        # ---- 情况 2：只有两个点（线段 zonotope）----
        if verts.shape[0] == 2:
            ax.plot(verts[:, 0], verts[:, 1],
                    color=color, linewidth=2, alpha=0.8)
            return

        # ---- 情况 3：正常 2D zonotope ----
        try:
            hull = ConvexHull(verts)
            poly = Polygon(
                verts[hull.vertices],
                facecolor=color,
                alpha=alpha,
                edgecolor=color,
                linewidth=0.5
            )
            ax.add_patch(poly)
        except Exception:
            # 极端退化兜底（画线）
            ax.plot(verts[:, 0], verts[:, 1],
                    color=color, linewidth=1)


def load_zonotope_csv(fname):
    """
    解析 dump.cpp 生成的格式:
    p,p0,p1,p2,p3
    H,h00,h10,h20,h30
    H,h01,h11,h21,h31...
    """
    p = None
    generators = []
    
    with open(fname, 'r') as f:
        for line in f:
            parts = line.strip().split(',')
            label = parts[0]
            data = [float(x) for x in parts[1:]]
            
            if label == 'p':
                p = np.array(data)
            elif label == 'H':
                generators.append(data)
    
    # 转换为矩阵 (N_STATE, m)
    H = np.array(generators).T if generators else np.zeros((N_STATE, 0))
    return Zonotope(p, H)

def main():
    # 1. 加载中心轨迹
    center_path = f"{OUTPUT_DIR}/center.csv"
    if not os.path.exists(center_path):
        print(f"Error: {center_path} not found. 请先运行 C++ 程序。")
        return
    
    # loadtxt 默认处理只有数字的 CSV
    centers = np.loadtxt(center_path, delimiter=",")
    true_states = np.loadtxt(f"{OUTPUT_DIR}/x_true.csv", delimiter=",")
# ############################################################################################

    # 2. 加载各个步数的 Zonotope 文件
    # 使用 %03d 匹配 C++ 的 std::snprintf(..., "zonotope_%03d.csv", ...)
    files = sorted(glob.glob(f"{OUTPUT_DIR}/zonotope_*.csv"))
    zonos = [load_zonotope_csv(f) for f in files]

    # 3. 绘图
    fig, ax = plt.subplots(figsize=(7, 7))
    
    # 绘制不确定性集合
    for Z in zonos:
        Z.plot(ax, color="tab:blue", alpha=0.15)

    # 绘制估计轨迹
    ax.plot(centers[:, 0], centers[:, 1], "r-o", label="Estimated Center (C++)", markersize=4, linewidth=1)
    ax.plot(true_states[:,0], true_states[:,1],
            "k-", linewidth=2, label="True State") ###########################
    
    ax.set_aspect("equal")
    ax.set_xlabel("State x[0]")
    ax.set_ylabel("State x[1]")
    ax.set_title("Zonotopic Estimation Pipeline: C++ -> Python")
    ax.legend()
    ax.grid(True, linestyle=':', alpha=0.6)
    
    plt.tight_layout()
    plt.show() # block=False
    # input("Press Enter to close...")

if __name__ == "__main__":
    main()