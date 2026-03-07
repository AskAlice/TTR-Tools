"""Fast Teleport — type a location name to teleport instantly.

Port of Teleport.ahk. Opens the Shticker Book, clicks the Map tab,
then clicks the destination. Location matching uses regex/prefix
matching identical to the original.
"""

from __future__ import annotations

import logging
import re
import time

from ttr_tools.automation import InputController
from ttr_tools.config import CalibrationProfile
from ttr_tools.pixels import PixelReader, rgb_euclidean_distance
from ttr_tools.window import WindowWatchdog

logger = logging.getLogger(__name__)

# Maps user input patterns to calibration field names.
# Order matters — first match wins. Each entry is (compiled_regex, field_name).
LOCATION_PATTERNS: list[tuple[re.Pattern[str], str]] = [
    (re.compile(r"^aa$|acorn|acres|chip|dale", re.I), "acorn_acres"),
    (re.compile(r"^bbhq$|boss", re.I), "bossbot_hq"),
    (re.compile(r"^cbhq$|cash", re.I), "cashbot_hq"),
    (re.compile(r"^dd$|dock", re.I), "donalds_dock"),
    (re.compile(r"^ddl$|dream", re.I), "dreamland"),
    (re.compile(r"^dg$|gardens|daisy", re.I), "daisy_gardens"),
    (re.compile(r"^e$|estate|home", re.I), "estate"),
    (re.compile(r"^gs$|speedway|goofy", re.I), "goofy_speedway"),
    (re.compile(r"^lbhq$|law", re.I), "lawbot_hq"),
    (re.compile(r"^mml$|minnie|melodyland", re.I), "melodyland"),
    (re.compile(r"^p$|play", re.I), "playground"),
    (re.compile(r"^sbhq$|sell", re.I), "sellbot_hq"),
    (re.compile(r"^ttc$|central|toontown", re.I), "ttc"),
]


def resolve_location(user_input: str) -> str | None:
    """Match user input to a calibration field name, or None if no match."""
    text = user_input.strip()
    for pattern, field_name in LOCATION_PATTERNS:
        if pattern.search(text):
            return field_name
    return None


def teleport_to(
    location_field: str,
    calibration: CalibrationProfile,
    input_ctrl: InputController,
    pixel_reader: PixelReader,
    watchdog: WindowWatchdog,
) -> bool:
    """Execute a teleport to the given location. Returns True on success."""
    tc = calibration.teleport.coords
    tcol = calibration.teleport.colors

    if not watchdog.is_healthy:
        logger.warning("TTR window not healthy, cannot teleport")
        return False

    watchdog.ensure_focused()
    time.sleep(0.1)

    # Check if book is already open
    bx, by = tc.book_open_check
    color = pixel_reader.get_pixel_color(bx, by)
    book_color = tuple(tcol.book_open_color)
    if rgb_euclidean_distance(color, book_color) > 5:
        # Book not open — click the book button
        input_ctrl.click(*tc.book_button)
        time.sleep(0.2)

    # Click the Map tab
    input_ctrl.click(*tc.map_tab)
    time.sleep(0.15)

    # Click the destination
    dest_coord = getattr(tc, location_field, None)
    if dest_coord is None:
        logger.error("Unknown teleport location field: %s", location_field)
        return False

    input_ctrl.click(*dest_coord)
    logger.info("Teleported to %s at (%d, %d)", location_field, dest_coord[0], dest_coord[1])
    return True
