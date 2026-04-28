"""PYNQ timing helpers for zonotope board validation.

This module is intentionally independent from the HLS kernel source.  It helps
separate the host-side MMIO polling cost from the measured kernel wall time.
Copy this file next to the board-side main.py, then import the helper functions.
"""

import time


CTRL_ADDR = 0x00
AP_START_MASK = 0x01
AP_DONE_MASK = 0x02


def estimate_mmio_read_seconds(zono_ip, samples=20000):
    """Return average seconds per idle CTRL register read."""
    if samples <= 0:
        raise ValueError("samples must be positive")

    mmio = zono_ip.mmio
    for _ in range(64):
        mmio.read(CTRL_ADDR)

    t0 = time.perf_counter()
    for _ in range(samples):
        mmio.read(CTRL_ADDR)
    return (time.perf_counter() - t0) / samples


def start_kernel_and_wait_profile(zono_ip, mmio_read_seconds=None, poll_sleep_seconds=0.0):
    """Start the HLS IP and wait for ap_done, returning timing diagnostics.

    The returned elapsed_seconds is the same board-level wall-clock quantity as
    the original start_kernel_and_wait().  estimated_poll_seconds is the total
    time spent issuing blocking MMIO reads while the PL kernel is also running;
    it should not be subtracted from elapsed_seconds.  Use poll_sleep_seconds to
    reduce AXI-Lite traffic when checking whether busy polling perturbs a run.
    """
    if poll_sleep_seconds < 0:
        raise ValueError("poll_sleep_seconds must be non-negative")

    mmio = zono_ip.mmio
    poll_reads = 0

    t0 = time.perf_counter()
    mmio.write(CTRL_ADDR, AP_START_MASK)
    while (mmio.read(CTRL_ADDR) & AP_DONE_MASK) == 0:
        poll_reads += 1
        if poll_sleep_seconds:
            time.sleep(poll_sleep_seconds)
    elapsed_seconds = time.perf_counter() - t0

    estimated_poll_seconds = None
    if mmio_read_seconds is not None:
        estimated_poll_seconds = poll_reads * mmio_read_seconds

    return {
        "elapsed_seconds": elapsed_seconds,
        "poll_reads": poll_reads,
        "mmio_read_seconds": mmio_read_seconds,
        "estimated_poll_seconds": estimated_poll_seconds,
        "poll_sleep_seconds": poll_sleep_seconds,
    }


def print_timing_profile(prefix, profile, fclk0_mhz=100.0, effective_steps=200):
    """Print one compact timing-profile line."""
    elapsed_ms = profile["elapsed_seconds"] * 1000.0
    cycles_per_step = elapsed_ms / effective_steps * fclk0_mhz * 1000.0
    print(f"  {prefix} elapsed: {elapsed_ms:.4f} ms")
    print(f"  {prefix} cycles/step: {cycles_per_step:.2f} @ {fclk0_mhz:.3f} MHz")
    print(f"  {prefix} poll reads: {profile['poll_reads']}")

    est_poll = profile.get("estimated_poll_seconds")
    if est_poll is not None:
        est_poll_ms = est_poll * 1000.0
        pct = est_poll / profile["elapsed_seconds"] * 100.0 if profile["elapsed_seconds"] else 0.0
        print(f"  {prefix} est busy-wait MMIO time: {est_poll_ms:.4f} ms ({pct:.2f}% overlapped)")

    poll_sleep = profile.get("poll_sleep_seconds", 0.0)
    if poll_sleep:
        print(f"  {prefix} poll sleep: {poll_sleep * 1e6:.1f} us/read max detection lag")
