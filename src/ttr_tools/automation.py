"""Low-latency mouse and keyboard automation via pynput.

Uses pynput Controllers which post Quartz events directly, giving <5ms
per action compared to pyautogui's ~500ms on macOS.
"""

from __future__ import annotations

import logging
import time

from pynput.keyboard import Controller as KeyboardController
from pynput.keyboard import Key
from pynput.mouse import Button
from pynput.mouse import Controller as MouseController

logger = logging.getLogger(__name__)


class InputController:
    """Wraps pynput mouse and keyboard controllers for game automation."""

    def __init__(self) -> None:
        self._mouse = MouseController()
        self._keyboard = KeyboardController()

    def click(self, x: int, y: int) -> None:
        """Move to (x, y) in logical coordinates and left-click."""
        self._mouse.position = (x, y)
        time.sleep(0.01)
        self._mouse.click(Button.left)

    def right_click(self, x: int, y: int) -> None:
        """Move to (x, y) in logical coordinates and right-click."""
        self._mouse.position = (x, y)
        time.sleep(0.01)
        self._mouse.click(Button.right)

    def key_tap(self, key: Key | str) -> None:
        """Quick press and release of a key."""
        self._keyboard.press(key)
        time.sleep(0.02)
        self._keyboard.release(key)

    def key_hold(self, key: Key | str, duration: float) -> None:
        """Press and hold a key for ``duration`` seconds. Used for toon movement."""
        self._keyboard.press(key)
        time.sleep(duration)
        self._keyboard.release(key)

    def key_down(self, key: Key | str) -> None:
        self._keyboard.press(key)

    def key_up(self, key: Key | str) -> None:
        self._keyboard.release(key)

    @property
    def mouse_position(self) -> tuple[int, int]:
        pos = self._mouse.position
        return int(pos[0]), int(pos[1])
