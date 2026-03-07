"""Gardening Bot — automates flower planting, watering, replanting, and can training.

Faithful port of Garden.ahk. All pixel coordinates and colors are read from the
calibration profile — nothing is hardcoded. The bot uses a state machine:
  move -> plant -> wait for OK -> water -> move to next pot -> repeat

Threading: the bot loop runs on a worker thread. ``stop_event`` terminates it
cleanly within one iteration. The ``WindowWatchdog`` pauses the loop if the
TTR window disappears or resizes.
"""

from __future__ import annotations

import logging
import threading
import time
from enum import IntEnum

from pynput.keyboard import Key

from ttr_tools.automation import InputController
from ttr_tools.config import AppConfig, CalibrationProfile
from ttr_tools.pixels import PixelReader, rgb_euclidean_distance
from ttr_tools.scaling import CoordinateScaler
from ttr_tools.window import WindowWatchdog

logger = logging.getLogger(__name__)

# Bean recipe lookup — maps bean_count -> flower_index (1-based) -> list of bean indices.
# Directly from the JSON in Garden.ahk lines 4-65.
BEAN_RECIPES: dict[int, list[list[int]]] = {
    1: [[1], [2], [5], [6], [7]],
    2: [[1, 7], [2, 7], [5, 6], [6, 0], [7, 1]],
    3: [[6, 0, 1], [2, 0, 0], [0, 0, 0], [5, 0, 0], [7, 0, 0]],
    4: [[6, 0, 7, 2], [7, 2, 2, 5], [1, 5, 6, 6], [2, 6, 6, 0], [0, 6, 2, 6]],
    5: [[6, 0, 2, 2, 2], [7, 0, 0, 0, 0], [3, 0, 4, 3, 3], [5, 0, 1, 4, 0], [1, 5, 4, 5, 5]],
    6: [
        [7, 0, 3, 3, 3, 3],
        [3, 0, 0, 0, 3, 3],
        [6, 4, 7, 3, 4, 4],
        [0, 5, 2, 0, 2, 5],
        [2, 5, 5, 2, 4, 5],
    ],
    7: [
        [0, 7, 2, 5, 3, 7, 7],
        [7, 3, 7, 4, 7, 4, 4],
        [6, 1, 0, 2, 1, 1, 1],
        [4, 3, 4, 3, 7, 4, 4],
        [5, 1, 1, 1, 1, 6, 1],
    ],
    8: [
        [0, 4, 3, 3, 4, 4, 5, 4],
        [4, 5, 5, 4, 0, 2, 6, 6],
        [7, 4, 6, 6, 7, 4, 6, 6],
        [6, 4, 3, 7, 3, 0, 2, 3],
        [3, 6, 6, 3, 6, 2, 3, 6],
    ],
}

# Movement sequences for navigating between flower pots (from Garden.ahk movement()).
# Each entry is a list of (key, hold_duration_seconds) tuples.
MOVEMENT_SEQUENCES: dict[int, list[tuple[str, float]]] = {
    0: [("left", 0.281), ("up", 0.400), ("right", 0.430), ("up", 0.090)],
    1: [
        ("down", 0.125),
        ("left", 0.469),
        ("up", 0.469),
        ("right", 0.719),
        ("up", 0.300),
        ("right", 0.906),
        ("up", 0.090),
    ],
    2: [("left", 0.825), ("up", 0.141)],
    3: [("left", 0.825), ("up", 0.141)],
    4: [
        ("down", 0.312),
        ("left", 0.422),
        ("up", 0.765),
        ("right", 1.000),
        ("up", 0.150),
    ],
    5: [("left", 0.800), ("up", 0.155)],
    6: [
        ("down", 0.094),
        ("left", 0.672),
        ("up", 0.594),
        ("right", 0.656),
        ("up", 0.294),
        ("right", 0.830),
        ("up", 0.135),
    ],
    7: [("left", 0.825), ("up", 0.140)],
    8: [("left", 0.825), ("up", 0.140)],
    9: [
        ("down", 0.062),
        ("left", 0.688),
        ("up", 0.297),
        ("right", 0.500),
        ("up", 0.100),
    ],
}

_KEY_MAP = {
    "left": Key.left,
    "right": Key.right,
    "up": Key.up,
    "down": Key.down,
}


class PlantResult(IntEnum):
    WATER_EXISTING = 0
    SUCCESS = 1
    BEAN_COUNT_FAIL = 3
    VERIFY_FAIL = 4
    ITERATION_ERROR = 5
    REPLANT = 6
    SIDEBAR_NOT_FOUND = 9
    WINDOW_GONE = 99


class GardenBot:
    """Gardening bot with full state machine, watchdog integration, and retry logic."""

    def __init__(
        self,
        config: AppConfig,
        calibration: CalibrationProfile,
        scaler: CoordinateScaler,
        watchdog: WindowWatchdog,
        log_callback: callable | None = None,
    ) -> None:
        self._config = config
        self._cal = calibration
        self._scaler = scaler
        self._watchdog = watchdog
        self._input = InputController()
        self._pixels = PixelReader(scaler)
        self._stop_event = threading.Event()
        self._thread: threading.Thread | None = None
        self._running = False
        self._log_cb = log_callback or (lambda msg: None)

    @property
    def is_running(self) -> bool:
        return self._running

    def _log(self, msg: str) -> None:
        logger.info(msg)
        self._log_cb(msg)

    # ------------------------------------------------------------------
    # Pixel helpers
    # ------------------------------------------------------------------

    def _color_match(self, x: int, y: int, expected: list[int], threshold: float = 20.0) -> bool:
        color = self._pixels.get_pixel_color(x, y)
        return rgb_euclidean_distance(color, tuple(expected)) < threshold

    def _wait_for_color(self, x: int, y: int, expected: list[int], timeout: float = 5.0) -> bool:
        deadline = time.monotonic() + timeout
        while time.monotonic() < deadline:
            if self._stop_event.is_set():
                return False
            if not self._watchdog.is_healthy:
                self._watchdog.wait_until_healthy(timeout=30.0)
                continue
            if self._color_match(x, y, expected):
                return True
            time.sleep(0.05)
        return False

    # ------------------------------------------------------------------
    # Click helpers (use calibration coords)
    # ------------------------------------------------------------------

    def _click(self, coord: list[int]) -> None:
        if not self._watchdog.is_healthy:
            self._watchdog.wait_until_healthy(timeout=30.0)
        self._watchdog.ensure_focused()
        self._input.click(coord[0], coord[1])

    def _click_bean(self, bean_index: int) -> None:
        gc = self._cal.garden.coords
        x = gc.bean_origin[0] + bean_index * gc.bean_spacing
        y = gc.bean_origin[1]
        self._click([x, y])
        time.sleep(0.05)

    def _make_flower(self, bean_count: int, flower_index: int) -> None:
        recipe = BEAN_RECIPES.get(bean_count, [])
        if flower_index < 1 or flower_index > len(recipe):
            return
        beans = recipe[flower_index - 1]
        for bean in beans:
            self._click_bean(bean)

    # ------------------------------------------------------------------
    # Sidebar detection (port of checkForSidebar)
    # ------------------------------------------------------------------

    def _check_sidebar(self) -> int:
        """Returns: 1=pot empty, 2=pot full (has plant), 9=sidebar not found."""
        gc = self._cal.garden.coords
        gcol = self._cal.garden.colors

        if not self._color_match(*gc.sidebar_header, gcol.sidebar_color):
            return 9

        if self._color_match(*gc.water_bucket, gcol.bucket_color):
            return 2  # pot full, water bucket visible

        if self._color_match(*gc.shovel_icon, gcol.shovel_color):
            return 1  # pot empty, shovel visible

        return 1  # sidebar found but no shovel — treat as empty (matches AHK fallback)

    # ------------------------------------------------------------------
    # Bean box scanning (port of the beanCount scanning loop)
    # ------------------------------------------------------------------

    def _scan_bean_count(self) -> int:
        gc = self._cal.garden.coords
        gcol = self._cal.garden.colors
        bean_count = 0
        for box_n in range(7, -1, -1):
            bx = gc.box_origin[0] + box_n * gc.box_spacing
            by = gc.box_origin[1]
            color = self._pixels.get_pixel_color(bx, by)
            box_dist = rgb_euclidean_distance(color, tuple(gcol.box_inactive_color))
            first_dist = rgb_euclidean_distance(color, tuple(gcol.box_first_color))
            if (box_dist < 20 or (box_n == 0 and first_dist < 20)) and bean_count == 0:
                bean_count = box_n + 1
        return bean_count

    # ------------------------------------------------------------------
    # Plant function (port of plant())
    # ------------------------------------------------------------------

    def _plant(self, iteration: int) -> PlantResult:
        self._log(f"Attempting to plant flower #{iteration}")
        # Normalize iteration to 1-5 range (mirrors AHK logic)
        if iteration > 5 and iteration <= 10:
            iteration = 6 - (iteration - 5)
        if iteration > 10:
            iteration = iteration - 10
        if iteration > 5:
            return PlantResult.ITERATION_ERROR

        if not self._watchdog.is_healthy:
            return PlantResult.WINDOW_GONE

        gc = self._cal.garden.coords
        gcol = self._cal.garden.colors

        # Check if bean picker is already open
        if self._color_match(*gc.bean_picker_check, gcol.bean_picker_open_color):
            self._log("Plant window already open")
        else:
            # Check sidebar
            sidebar = self._check_sidebar()
            if sidebar == 9:
                self._log("Couldn't find flower pot sidebar")
                time.sleep(0.5)
                return PlantResult.SIDEBAR_NOT_FOUND
            if sidebar == 2:
                if not self._config.garden.replant:
                    self._log(f"Plant exists for flower #{iteration}, watering instead")
                    return PlantResult.WATER_EXISTING
                else:
                    self._log("Replanting...")
                    return PlantResult.REPLANT
            # Pot is empty — click shovel
            self._log("Pot is empty, opening planting window")
            self._click(gc.shovel_click)
            time.sleep(0.075)

        # Scan bean count
        self._log("Scanning max bean count")
        bean_count = self._scan_bean_count()
        if bean_count == 0:
            self._log("Couldn't determine bean count")
            return PlantResult.BEAN_COUNT_FAIL

        self._log(f"Making {bean_count}-bean flower #{iteration}")
        self._make_flower(bean_count, iteration)

        # Verify all beans were used
        verify_count = self._scan_bean_count()
        if verify_count == 0:
            self._log("Verified! Planting now")
            self._click(gc.plant_button)
            return PlantResult.SUCCESS
        else:
            self._log("Bean verification failed, resetting")
            for _ in range(4):
                self._click(gc.reset_button)
                time.sleep(0.05)
            return PlantResult.VERIFY_FAIL

    # ------------------------------------------------------------------
    # OK dialog check (port of plantFinishOK)
    # ------------------------------------------------------------------

    def _check_plant_ok(self) -> bool:
        gc = self._cal.garden.coords
        gcol = self._cal.garden.colors
        if self._color_match(gc.ok_button[0], gc.ok_button[1] - 35, gcol.ok_dialog_color):
            self._click(gc.ok_button)
            return True
        return False

    # ------------------------------------------------------------------
    # Movement between pots
    # ------------------------------------------------------------------

    def _move_to_pot(self, move_iter: int) -> bool:
        if move_iter not in MOVEMENT_SEQUENCES:
            return False
        if not self._watchdog.is_healthy:
            return False
        self._watchdog.ensure_focused()
        self._log(f"Moving to pot #{move_iter}")
        for key_name, duration in MOVEMENT_SEQUENCES[move_iter]:
            if self._stop_event.is_set():
                return False
            self._input.key_hold(_KEY_MAP[key_name], duration)
        self._log(f"Finished movement #{move_iter}")
        return True

    # ------------------------------------------------------------------
    # Remove plant (click shovel then confirm buttons)
    # ------------------------------------------------------------------

    def _remove_plant(self) -> None:
        gc = self._cal.garden.coords
        self._click(gc.shovel_click)
        time.sleep(0.125)
        for y_pos in gc.remove_confirm_y_positions:
            self._click([gc.remove_confirm_x, y_pos])
            time.sleep(0.03)
        time.sleep(0.1)

    # ------------------------------------------------------------------
    # Water plant
    # ------------------------------------------------------------------

    def _water_plant(self) -> bool:
        gc = self._cal.garden.coords
        gcol = self._cal.garden.colors
        if self._color_match(*gc.water_bucket, gcol.bucket_color):
            self._click(list(gc.water_bucket))
            return True
        return False

    # ------------------------------------------------------------------
    # Main auto-garden loop (port of runGarden)
    # ------------------------------------------------------------------

    def start_auto_garden(self) -> None:
        if self._running:
            return
        self._stop_event.clear()
        self._thread = threading.Thread(target=self._auto_garden_loop, name="GardenBot")
        self._thread.start()

    def start_quick_plant(self, flower_number: int) -> None:
        if self._running:
            return
        self._stop_event.clear()
        self._thread = threading.Thread(
            target=self._quick_plant_loop, args=(flower_number,), name="QuickPlant"
        )
        self._thread.start()

    def start_can_trainer(self) -> None:
        if self._running:
            return
        self._stop_event.clear()
        self._thread = threading.Thread(target=self._can_trainer_loop, name="CanTrainer")
        self._thread.start()

    def stop(self) -> None:
        self._stop_event.set()
        if self._thread is not None:
            self._thread.join(timeout=5.0)
            self._thread = None
        self._running = False

    def _auto_garden_loop(self) -> None:
        self._running = True
        self._log("Starting Auto-Gardening")
        flower = 1
        flowers_complete = 0
        ready_to_plant = False
        ready_to_move = True
        ready_to_water = False
        searching_for_ok = False
        move_iter = 0
        sidebar_check_count = 0
        water_count = 0
        replanting = False

        try:
            while not self._stop_event.is_set():
                if not self._watchdog.is_healthy:
                    self._watchdog.wait_until_healthy(timeout=30.0)
                    continue

                if not ready_to_plant:
                    if ready_to_move:
                        if self._move_to_pot(move_iter):
                            ready_to_plant = True
                            ready_to_move = False
                            move_iter += 1
                        else:
                            self._log("Gardening finished (no more pots)")
                            break
                    elif ready_to_water:
                        sidebar = self._check_sidebar()
                        if sidebar == 2:
                            sidebar_check_count = 0
                            times_to_water = self._config.garden.times_to_water
                            if water_count >= times_to_water or (
                                replanting and times_to_water == 1
                            ):
                                water_count = 0
                                if replanting:
                                    self._log("Removing plant for replant")
                                    self._remove_plant()
                                else:
                                    ready_to_water = False
                                    ready_to_move = True
                            else:
                                self._log("Watering...")
                                self._water_plant()
                                time.sleep(0.05)
                                if self._check_sidebar() != 2:
                                    water_count += 1
                                    self._log(f"Watered #{water_count}")
                        elif sidebar == 1:
                            if replanting:
                                self._log("Done removing plant, planting new")
                                replanting = False
                                ready_to_plant = True
                                ready_to_water = False
                        else:
                            sidebar_check_count += 1
                            if sidebar_check_count % 5 == 0 or sidebar_check_count < 2:
                                self._log(f"Looking for sidebar (attempt #{sidebar_check_count})")
                            if sidebar_check_count > 600:
                                self._log("Timed out looking for sidebar")
                                break
                        time.sleep(0.05)
                    else:
                        if not searching_for_ok:
                            self._log("Waiting for plant OK dialog")
                            searching_for_ok = True
                        if self._check_plant_ok():
                            self._log("Clicked OK, moving on")
                            searching_for_ok = False
                            ready_to_water = True
                        time.sleep(0.05)
                else:
                    if flowers_complete > 10:
                        break
                    result = self._plant(flower)
                    if result == PlantResult.SUCCESS:
                        flower += 1
                        flowers_complete += 1
                        ready_to_plant = False
                    elif result == PlantResult.WATER_EXISTING:
                        flower += 1
                        flowers_complete += 1
                        ready_to_plant = False
                        ready_to_water = True
                    elif result == PlantResult.VERIFY_FAIL:
                        self._click(self._cal.garden.coords.reset_button)
                        time.sleep(0.05)
                    elif result == PlantResult.ITERATION_ERROR:
                        break
                    elif result == PlantResult.REPLANT:
                        replanting = True
                        ready_to_plant = False
                        ready_to_water = True
                    elif result == PlantResult.SIDEBAR_NOT_FOUND:
                        time.sleep(0.5)
                    elif result == PlantResult.WINDOW_GONE:
                        break
        except Exception:
            logger.exception("Garden bot crashed")
        finally:
            self._running = False
            self._log("Stopped Auto-Gardening")
            self._pixels.close()

    def _quick_plant_loop(self, flower_number: int) -> None:
        self._running = True
        self._log(f"Quick-planting flower #{flower_number}")
        try:
            result = self._plant(flower_number)
            self._log(f"Quick plant result: {result.name}")
        except Exception:
            logger.exception("Quick plant crashed")
        finally:
            self._running = False
            self._pixels.close()

    def _can_trainer_loop(self) -> None:
        self._running = True
        self._log("Starting Watering Can Trainer")
        gc = self._cal.garden.coords
        gcol = self._cal.garden.colors
        times_watered = 0
        timeout_count = 0

        try:
            while not self._stop_event.is_set():
                if not self._watchdog.is_healthy:
                    self._watchdog.wait_until_healthy(timeout=30.0)
                    continue

                status = self._check_sidebar()

                if status == 1:
                    self._click(gc.shovel_click)
                    time.sleep(0.075)
                    self._log("Making a 1-bean flower")
                    self._make_flower(1, 1)
                    self._click(gc.plant_button)

                elif status == 2:
                    if times_watered < self._config.garden.times_to_water:
                        self._log("Watering...")
                        self._water_plant()
                        times_watered += 1
                    else:
                        self._click(gc.shovel_click)
                        time.sleep(0.075)
                        for y_pos in gc.remove_confirm_y_positions:
                            self._click([gc.remove_confirm_x, y_pos])
                            time.sleep(0.03)
                        time.sleep(0.1)

                elif status == 9:
                    if self._check_plant_ok():
                        self._log("Finished making plant")
                        times_watered = 0
                        timeout_count = 0

                    if self._color_match(*gc.bean_picker_check, gcol.bean_picker_open_color):
                        self._click(gc.reset_button)
                        time.sleep(0.05)
                        self._click(gc.reset_button)
                        time.sleep(0.075)
                        self._log("Making a 1-bean flower")
                        self._make_flower(1, 1)
                        self._click(gc.plant_button)

                    timeout_count += 1
                    if timeout_count % 10 == 0 or timeout_count < 2:
                        self._log(f"Looking for sidebar (attempt #{timeout_count})")
                    if timeout_count > 300:
                        self._log("Watering can trainer timed out")
                        break

                if status != 9:
                    timeout_count = 0

                time.sleep(0.05)
        except Exception:
            logger.exception("Can trainer crashed")
        finally:
            self._running = False
            self._log("Stopped Watering Can Trainer")
            self._pixels.close()
