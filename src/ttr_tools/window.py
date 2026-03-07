"""Quartz-native window management and health monitoring.

Uses CGWindowListCopyWindowInfo for fast (~1ms) window lookup and
NSRunningApplication for activation. Includes a WindowWatchdog that
runs on a background thread to pause bots when the TTR window is
missing, resized, or unfocused.
"""

from __future__ import annotations

import logging
import threading
from typing import Any

import Quartz
from AppKit import NSApplicationActivateIgnoringOtherApps, NSWorkspace

logger = logging.getLogger(__name__)


def find_ttr_window(window_name: str = "Toontown Rewritten") -> dict[str, Any] | None:
    """Find the TTR window by owner name. Returns pid, bounds, and name, or None."""
    window_list = Quartz.CGWindowListCopyWindowInfo(
        Quartz.kCGWindowListOptionOnScreenOnly | Quartz.kCGWindowListExcludeDesktopElements,
        Quartz.kCGNullWindowID,
    )
    if window_list is None:
        return None
    for window in window_list:
        owner = window.get(Quartz.kCGWindowOwnerName, "")
        if window_name in owner:
            bounds = window.get(Quartz.kCGWindowBounds, {})
            return {
                "pid": window.get(Quartz.kCGWindowOwnerPID, 0),
                "bounds": bounds,
                "name": owner,
            }
    return None


def activate_window(pid: int) -> bool:
    """Bring a window to the front by its process ID. Returns True on success."""
    workspace = NSWorkspace.sharedWorkspace()
    for app in workspace.runningApplications():
        if app.processIdentifier() == pid:
            app.activateWithOptions_(NSApplicationActivateIgnoringOtherApps)
            return True
    return False


def get_window_position(window_name: str = "Toontown Rewritten") -> tuple[int, int] | None:
    """Return the (x, y) top-left position of the TTR window, or None."""
    info = find_ttr_window(window_name)
    if info is None:
        return None
    bounds = info["bounds"]
    return int(bounds.get("X", 0)), int(bounds.get("Y", 0))


class WindowWatchdog:
    """Background thread that monitors TTR window health.

    Bots should check ``is_healthy`` before each action and call
    ``wait_until_healthy()`` to block until the window recovers.
    """

    def __init__(self, window_name: str, expected_size: tuple[int, int]) -> None:
        self._window_name = window_name
        self._expected_size = expected_size
        self._healthy = threading.Event()
        self._healthy.set()
        self._stop = threading.Event()
        self._thread: threading.Thread | None = None
        self._window_pid: int | None = None

    def start(self) -> None:
        if self._thread is not None and self._thread.is_alive():
            return
        self._stop.clear()
        self._thread = threading.Thread(target=self._run, name="WindowWatchdog", daemon=False)
        self._thread.start()
        logger.info("Window watchdog started for '%s'", self._window_name)

    def stop(self) -> None:
        self._stop.set()
        if self._thread is not None:
            self._thread.join(timeout=3.0)
            self._thread = None
        logger.info("Window watchdog stopped")

    def _run(self) -> None:
        while not self._stop.is_set():
            info = find_ttr_window(self._window_name)
            if info is None:
                if self._healthy.is_set():
                    logger.warning("TTR window not found — pausing bots")
                self._healthy.clear()
                self._window_pid = None
            else:
                self._window_pid = info["pid"]
                bounds = info["bounds"]
                actual = (int(bounds.get("Width", 0)), int(bounds.get("Height", 0)))
                if actual != self._expected_size:
                    if self._healthy.is_set():
                        logger.warning(
                            "TTR window resized to %s, expected %s", actual, self._expected_size
                        )
                    self._healthy.clear()
                elif not self._healthy.is_set():
                    logger.info("TTR window recovered")
                    self._healthy.set()
                else:
                    self._healthy.set()
            self._stop.wait(timeout=1.0)

    @property
    def is_healthy(self) -> bool:
        return self._healthy.is_set()

    def wait_until_healthy(self, timeout: float | None = None) -> bool:
        return self._healthy.wait(timeout=timeout)

    @property
    def window_pid(self) -> int | None:
        return self._window_pid

    def ensure_focused(self) -> bool:
        """Activate the TTR window if we know its PID."""
        if self._window_pid is not None:
            return activate_window(self._window_pid)
        return False
