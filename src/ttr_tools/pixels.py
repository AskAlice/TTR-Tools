"""High-performance pixel reading using mss (CoreGraphics).

mss is ~30x faster than Pillow's ImageGrab on macOS (~2ms per single-pixel
read vs ~1300ms). Supports region grabs for batch pixel checks — the gardening
bot grabs the whole game window once (~15ms) and samples many pixels from the
cached screenshot.
"""

from __future__ import annotations

import logging
import math
from typing import TYPE_CHECKING

import mss
import mss.darwin

from ttr_tools.scaling import CoordinateScaler

if TYPE_CHECKING:
    pass

logger = logging.getLogger(__name__)

# Force mss to capture at full Retina resolution so pixel sampling is accurate.
mss.darwin.IMAGE_OPTIONS = 0


def rgb_euclidean_distance(c1: tuple[int, int, int], c2: tuple[int, int, int] | list[int]) -> float:
    """Euclidean distance between two RGB colors. Threshold < 20 matches original AHK logic."""
    return math.sqrt(sum((a - b) ** 2 for a, b in zip(c1, c2, strict=False)))


class PixelReader:
    """Thread-local screenshot reader. Each thread should create its own instance
    because mss instances are not thread-safe.
    """

    def __init__(self, scaler: CoordinateScaler) -> None:
        self._sct = mss.mss()
        self._scaler = scaler

    def get_pixel_color(self, x: int, y: int) -> tuple[int, int, int]:
        """Read a single pixel at logical (x, y). Returns RGB tuple. ~2ms."""
        px, py = self._scaler.logical_to_physical(x, y)
        region = {"left": px, "top": py, "width": 1, "height": 1}
        img = self._sct.grab(region)
        r, g, b = img.pixel(0, 0)[2], img.pixel(0, 0)[1], img.pixel(0, 0)[0]
        return (r, g, b)

    def get_region(self, x: int, y: int, w: int, h: int) -> mss.screenshot.ScreenShot:
        """Grab a region at logical coordinates. ~15ms for 800x640."""
        px, py = self._scaler.logical_to_physical(x, y)
        pw, ph = self._scaler.scale_dimension(w, h)
        return self._sct.grab({"left": px, "top": py, "width": pw, "height": ph})

    def pixel_from_region(
        self, region: mss.screenshot.ScreenShot, logical_x: int, logical_y: int
    ) -> tuple[int, int, int]:
        """Sample a pixel from an already-captured region screenshot.

        ``logical_x`` and ``logical_y`` are in the same coordinate space as the
        region's origin. The region must have been captured starting at (0, 0)
        of the game window for absolute coordinates to work, or you must pass
        coordinates relative to the region's origin.
        """
        px, py = self._scaler.logical_to_physical(logical_x, logical_y)
        bgra = region.pixel(px, py)
        return (bgra[2], bgra[1], bgra[0])

    def close(self) -> None:
        self._sct.close()
