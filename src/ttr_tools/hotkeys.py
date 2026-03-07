"""Global hotkey listener using pynput.

Runs a pynput keyboard Listener on a dedicated thread. Hotkey combos use
Cmd+Shift instead of AHK's Alt+Shift because Option/Alt has special
meaning on macOS.

Hotkeys:
    Cmd+Shift+G  — Start/Stop Auto-Garden
    F5           — Fast Teleport
    Numpad 1-5   — Quick plant flowers 1-5
    Numpad .     — Watering can trainer
    Cmd+Shift+Q  — Quit application
"""

from __future__ import annotations

import logging
import threading
from collections.abc import Callable
from typing import Any

from pynput.keyboard import Key, KeyCode, Listener

logger = logging.getLogger(__name__)


class HotkeyManager:
    """Manages global hotkey registration and dispatching."""

    def __init__(self) -> None:
        self._listener: Listener | None = None
        self._callbacks: dict[str, Callable[[], Any]] = {}
        self._pressed: set[Key | KeyCode] = set()
        self._lock = threading.Lock()

    def register(self, name: str, callback: Callable[[], Any]) -> None:
        """Register a named callback. Names match the internal hotkey map."""
        with self._lock:
            self._callbacks[name] = callback
            logger.debug("Registered hotkey callback: %s", name)

    def start(self) -> None:
        if self._listener is not None:
            return
        self._listener = Listener(on_press=self._on_press, on_release=self._on_release)
        self._listener.name = "HotkeyListener"
        self._listener.start()
        logger.info("Hotkey listener started")

    def stop(self) -> None:
        if self._listener is not None:
            self._listener.stop()
            self._listener = None
            self._pressed.clear()
            logger.info("Hotkey listener stopped")

    def _fire(self, name: str) -> None:
        with self._lock:
            cb = self._callbacks.get(name)
        if cb is not None:
            logger.debug("Hotkey fired: %s", name)
            threading.Thread(target=cb, name=f"hotkey-{name}", daemon=True).start()

    def _on_press(self, key: Key | KeyCode | None) -> None:
        if key is None:
            return
        self._pressed.add(key)

        has_cmd = (
            Key.cmd in self._pressed or Key.cmd_l in self._pressed or Key.cmd_r in self._pressed
        )
        has_shift = (
            Key.shift in self._pressed
            or Key.shift_l in self._pressed
            or Key.shift_r in self._pressed
        )

        if has_cmd and has_shift:
            if key == KeyCode.from_char("g") or key == KeyCode.from_char("G"):
                self._fire("toggle_garden")
                return
            if key == KeyCode.from_char("q") or key == KeyCode.from_char("Q"):
                self._fire("quit")
                return

        if key == Key.f5:
            self._fire("teleport")
            return

        # Numpad keys for quick plant
        _numpad_map = {
            KeyCode.from_vk(83): "quick_plant_1",  # Numpad 1
            KeyCode.from_vk(84): "quick_plant_2",  # Numpad 2
            KeyCode.from_vk(85): "quick_plant_3",  # Numpad 3
            KeyCode.from_vk(86): "quick_plant_4",  # Numpad 4
            KeyCode.from_vk(87): "quick_plant_5",  # Numpad 5
            KeyCode.from_vk(65): "train_watering_can",  # Numpad .
        }
        action = _numpad_map.get(key)
        if action:
            self._fire(action)

    def _on_release(self, key: Key | KeyCode | None) -> None:
        if key is None:
            return
        self._pressed.discard(key)
