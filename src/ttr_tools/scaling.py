"""Retina display detection and coordinate conversion.

All calibration data and bot logic use logical coordinates (the coordinate space
that pynput and the OS window manager operate in). Physical coordinates are only
used at the boundary when sampling pixels from mss screenshots, which capture at
full Retina resolution.
"""

from __future__ import annotations

import logging

import Quartz

logger = logging.getLogger(__name__)


def get_display_scale_factor() -> float:
    """Detect the Retina scaling factor for the main display.

    Returns 1.0 on non-Retina displays and 2.0 on standard Retina displays.
    """
    main_display = Quartz.CGMainDisplayID()
    mode = Quartz.CGDisplayCopyDisplayMode(main_display)
    if mode is None:
        logger.warning("Could not query display mode, assuming scale factor 1.0")
        return 1.0
    pixel_width = Quartz.CGDisplayModeGetPixelWidth(mode)
    logical_width = Quartz.CGDisplayModeGetWidth(mode)
    if logical_width == 0:
        return 1.0
    return pixel_width / logical_width


class CoordinateScaler:
    """Converts between logical (OS/pynput) and physical (screenshot pixel) coordinates."""

    def __init__(self) -> None:
        self.scale_factor = get_display_scale_factor()
        logger.info("Display scale factor: %.1f", self.scale_factor)

    @property
    def is_retina(self) -> bool:
        return self.scale_factor > 1.0

    def logical_to_physical(self, x: int, y: int) -> tuple[int, int]:
        """Convert logical coords to physical coords for screenshot pixel sampling."""
        return int(x * self.scale_factor), int(y * self.scale_factor)

    def physical_to_logical(self, x: int, y: int) -> tuple[int, int]:
        """Convert physical coords from a screenshot back to logical coords."""
        return int(x / self.scale_factor), int(y / self.scale_factor)

    def scale_dimension(self, w: int, h: int) -> tuple[int, int]:
        """Scale a width/height pair from logical to physical."""
        return int(w * self.scale_factor), int(h * self.scale_factor)
