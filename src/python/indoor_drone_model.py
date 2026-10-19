"""Simulated indoor quadrotor localization near stabilized hover.

This is a small-angle, closed-loop linear model, not a flight-validated plant.
State order: position xyz [m], velocity xyz [m/s], roll/pitch/yaw [rad],
body-angle rates [rad/s]. Inputs are commanded vertical and angular
accelerations [m/s^2, rad/s^2]. Position and attitude are measured.
"""

import numpy as np
from scipy.linalg import expm


STATE_NAMES = ("px", "py", "pz", "vx", "vy", "vz",
               "roll", "pitch", "yaw", "roll_rate", "pitch_rate", "yaw_rate")
MEASUREMENT_NAMES = ("px", "py", "pz", "roll", "pitch", "yaw")
INPUT_NAMES = ("vertical_acceleration", "roll_acceleration",
               "pitch_acceleration", "yaw_acceleration")
DT = 0.1
GRAVITY = 9.81
VELOCITY_DAMPING = (0.30, 0.30, 0.40)  # 1/s
ATTITUDE_STIFFNESS = (3.0, 3.0, 2.0)  # 1/s^2; stabilized hover feedback
RATE_DAMPING = (1.8, 1.8, 1.5)  # 1/s
PROCESS_RADIUS = np.array([0.005] * 3 + [0.020] * 3 +
                          [0.002] * 3 + [0.010] * 3)
MEASUREMENT_RADIUS = np.array([0.10] * 3 + [0.020] * 3)
INITIAL_RADIUS = np.array([0.25] * 3 + [0.20] * 3 +
                          [0.05] * 3 + [0.10] * 3)
INITIAL_STATE = np.array([1.0, -0.5, 1.5, 0.15, 0.05, 0.0,
                          0.02, -0.03, 0.01, 0.0, 0.0, 0.0])


def matrices(dt=DT):
    """Exactly discretize x_dot = F x + G u around stabilized hover.

    Horizontal acceleration is g*pitch and -g*roll at small angles. The
    attitude restoring terms represent a stabilizing inner-loop controller.
    """
    F = np.zeros((12, 12))
    G = np.zeros((12, 4))
    F[0:3, 3:6] = np.eye(3)
    F[3, 7] = GRAVITY
    F[4, 6] = -GRAVITY
    F[3:6, 3:6] = -np.diag(VELOCITY_DAMPING)
    F[6:9, 9:12] = np.eye(3)
    F[9:12, 6:9] = -np.diag(ATTITUDE_STIFFNESS)
    F[9:12, 9:12] = -np.diag(RATE_DAMPING)
    G[5, 0] = 1.0
    G[9:12, 1:4] = np.eye(3)

    augmented = np.zeros((16, 16))
    augmented[:12, :12] = F
    augmented[:12, 12:] = G
    discrete = expm(augmented * dt)
    A, B = discrete[:12, :12], discrete[:12, 12:]
    C = np.zeros((6, 12))
    C[:3, :3] = np.eye(3)
    C[3:, 6:9] = np.eye(3)
    return A, B, C


def commanded_input(step, dt=DT):
    """Known, gentle deterministic excitation shared across methods/seeds."""
    t = step * dt
    return np.array([0.04 * np.sin(0.4 * t),
                     0.06 * np.sin(0.55 * t),
                     0.06 * np.cos(0.45 * t),
                     0.03 * np.sin(0.30 * t)])
