"""TOML configuration and calibration profile management.

Manages two files in ~/Library/Application Support/TTR-Tools/:
  - config.toml   — app settings (window name, garden options)
  - calibration.toml — pixel coordinates and colors (from calibration or defaults)

Falls back to bundled defaults if user files are missing or corrupted.
"""

from __future__ import annotations

import logging
import tomllib
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

logger = logging.getLogger(__name__)

APP_DIR = Path("~/Library/Application Support/TTR-Tools").expanduser()
CONFIG_PATH = APP_DIR / "config.toml"
CALIBRATION_PATH = APP_DIR / "calibration.toml"

_PACKAGE_DIR = Path(__file__).parent
DEFAULT_CONFIG_PATH = _PACKAGE_DIR / "default_config.toml"
DEFAULT_CALIBRATION_PATH = _PACKAGE_DIR / "default_calibration.toml"


# ---------------------------------------------------------------------------
# App config
# ---------------------------------------------------------------------------


@dataclass
class GardenSettings:
    times_to_water: int = 2
    replant: bool = True


@dataclass
class AppConfig:
    version: str = "2.0.0"
    window_name: str = "Toontown Rewritten"
    garden: GardenSettings = field(default_factory=GardenSettings)


def load_app_config() -> AppConfig:
    """Load app config from user dir, falling back to bundled defaults."""
    raw = _load_toml(CONFIG_PATH, DEFAULT_CONFIG_PATH)
    tools = raw.get("ttr-tools", {})
    garden_raw = raw.get("garden", {})
    return AppConfig(
        version=tools.get("version", "2.0.0"),
        window_name=tools.get("window_name", "Toontown Rewritten"),
        garden=GardenSettings(
            times_to_water=garden_raw.get("times_to_water", 2),
            replant=garden_raw.get("replant", True),
        ),
    )


def save_app_config(config: AppConfig) -> None:
    """Write app config to user dir."""
    APP_DIR.mkdir(parents=True, exist_ok=True)
    lines = [
        "[ttr-tools]",
        f'version = "{config.version}"',
        f'window_name = "{config.window_name}"',
        "",
        "[garden]",
        f"times_to_water = {config.garden.times_to_water}",
        f"replant = {'true' if config.garden.replant else 'false'}",
        "",
    ]
    CONFIG_PATH.write_text("\n".join(lines))
    logger.info("Saved app config to %s", CONFIG_PATH)


# ---------------------------------------------------------------------------
# Calibration profile
# ---------------------------------------------------------------------------


@dataclass
class CalibrationMeta:
    created: str = ""
    window_width: int = 816
    window_height: int = 639
    scale_factor: float = 1.0


@dataclass
class GardenCoords:
    sidebar_header: list[int] = field(default_factory=lambda: [70, 145])
    shovel_icon: list[int] = field(default_factory=lambda: [50, 159])
    shovel_click: list[int] = field(default_factory=lambda: [45, 170])
    water_bucket: list[int] = field(default_factory=lambda: [40, 214])
    bean_picker_check: list[int] = field(default_factory=lambda: [400, 250])
    bean_origin: list[int] = field(default_factory=lambda: [285, 300])
    bean_spacing: int = 30
    box_origin: list[int] = field(default_factory=lambda: [300, 375])
    box_spacing: int = 30
    plant_button: list[int] = field(default_factory=lambda: [495, 435])
    reset_button: list[int] = field(default_factory=lambda: [405, 435])
    ok_button: list[int] = field(default_factory=lambda: [405, 405])
    remove_confirm_x: int = 369
    remove_confirm_y_positions: list[int] = field(default_factory=lambda: [414, 424, 435, 445])


@dataclass
class GardenColors:
    sidebar_color: list[int] = field(default_factory=lambda: [255, 255, 143])
    bucket_color: list[int] = field(default_factory=lambda: [86, 201, 208])
    shovel_color: list[int] = field(default_factory=lambda: [73, 82, 81])
    bean_picker_open_color: list[int] = field(default_factory=lambda: [255, 255, 191])
    box_inactive_color: list[int] = field(default_factory=lambda: [127, 127, 127])
    box_first_color: list[int] = field(default_factory=lambda: [255, 255, 255])
    ok_dialog_color: list[int] = field(default_factory=lambda: [255, 255, 191])


@dataclass
class GardenCalibration:
    coords: GardenCoords = field(default_factory=GardenCoords)
    colors: GardenColors = field(default_factory=GardenColors)


@dataclass
class TeleportCoords:
    book_button: list[int] = field(default_factory=lambda: [780, 595])
    map_tab: list[int] = field(default_factory=lambda: [685, 180])
    book_open_check: list[int] = field(default_factory=lambda: [40, 315])
    acorn_acres: list[int] = field(default_factory=lambda: [465, 420])
    bossbot_hq: list[int] = field(default_factory=lambda: [610, 415])
    cashbot_hq: list[int] = field(default_factory=lambda: [212, 131])
    donalds_dock: list[int] = field(default_factory=lambda: [585, 300])
    dreamland: list[int] = field(default_factory=lambda: [383, 152])
    daisy_gardens: list[int] = field(default_factory=lambda: [325, 395])
    estate: list[int] = field(default_factory=lambda: [450, 495])
    goofy_speedway: list[int] = field(default_factory=lambda: [256, 280])
    lawbot_hq: list[int] = field(default_factory=lambda: [620, 128])
    melodyland: list[int] = field(default_factory=lambda: [445, 240])
    playground: list[int] = field(default_factory=lambda: [575, 485])
    sellbot_hq: list[int] = field(default_factory=lambda: [210, 420])
    ttc: list[int] = field(default_factory=lambda: [415, 305])


@dataclass
class TeleportColors:
    book_open_color: list[int] = field(default_factory=lambda: [13, 38, 102])


@dataclass
class TeleportCalibration:
    coords: TeleportCoords = field(default_factory=TeleportCoords)
    colors: TeleportColors = field(default_factory=TeleportColors)


@dataclass
class CalibrationProfile:
    meta: CalibrationMeta = field(default_factory=CalibrationMeta)
    garden: GardenCalibration = field(default_factory=GardenCalibration)
    teleport: TeleportCalibration = field(default_factory=TeleportCalibration)


def load_calibration() -> CalibrationProfile:
    """Load calibration from user dir, falling back to bundled defaults."""
    raw = _load_toml(CALIBRATION_PATH, DEFAULT_CALIBRATION_PATH)
    return _parse_calibration(raw)


def save_calibration(profile: CalibrationProfile) -> None:
    """Write calibration profile to user dir."""
    APP_DIR.mkdir(parents=True, exist_ok=True)
    lines = _serialize_calibration(profile)
    CALIBRATION_PATH.write_text("\n".join(lines))
    logger.info("Saved calibration to %s", CALIBRATION_PATH)


def is_using_defaults() -> bool:
    """True if no user calibration exists (using bundled defaults)."""
    return not CALIBRATION_PATH.exists()


# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------


def _load_toml(user_path: Path, default_path: Path) -> dict[str, Any]:
    """Try user path first, fall back to bundled default."""
    if user_path.exists():
        try:
            return tomllib.loads(user_path.read_text())
        except Exception:
            logger.exception("Corrupted config at %s, falling back to defaults", user_path)
    return tomllib.loads(default_path.read_text())


def _parse_calibration(raw: dict[str, Any]) -> CalibrationProfile:
    meta_raw = raw.get("meta", {})
    meta = CalibrationMeta(
        created=meta_raw.get("created", ""),
        window_width=meta_raw.get("window_width", 816),
        window_height=meta_raw.get("window_height", 639),
        scale_factor=meta_raw.get("scale_factor", 1.0),
    )

    gc_raw = raw.get("garden", {}).get("coords", {})
    garden_coords = GardenCoords(**{k: v for k, v in gc_raw.items() if hasattr(GardenCoords, k)})

    gcol_raw = raw.get("garden", {}).get("colors", {})
    garden_colors = GardenColors(**{k: v for k, v in gcol_raw.items() if hasattr(GardenColors, k)})

    tc_raw = raw.get("teleport", {}).get("coords", {})
    teleport_coords = TeleportCoords(
        **{k: v for k, v in tc_raw.items() if hasattr(TeleportCoords, k)}
    )

    tcol_raw = raw.get("teleport", {}).get("colors", {})
    teleport_colors = TeleportColors(
        **{k: v for k, v in tcol_raw.items() if hasattr(TeleportColors, k)}
    )

    return CalibrationProfile(
        meta=meta,
        garden=GardenCalibration(coords=garden_coords, colors=garden_colors),
        teleport=TeleportCalibration(coords=teleport_coords, colors=teleport_colors),
    )


def _format_list(values: list[int]) -> str:
    return "[" + ", ".join(str(v) for v in values) + "]"


def _serialize_calibration(profile: CalibrationProfile) -> list[str]:
    m = profile.meta
    gc = profile.garden.coords
    gcol = profile.garden.colors
    tc = profile.teleport.coords
    tcol = profile.teleport.colors

    return [
        "[meta]",
        f'created = "{m.created}"',
        f"window_width = {m.window_width}",
        f"window_height = {m.window_height}",
        f"scale_factor = {m.scale_factor}",
        "",
        "[garden.coords]",
        f"sidebar_header = {_format_list(gc.sidebar_header)}",
        f"shovel_icon = {_format_list(gc.shovel_icon)}",
        f"shovel_click = {_format_list(gc.shovel_click)}",
        f"water_bucket = {_format_list(gc.water_bucket)}",
        f"bean_picker_check = {_format_list(gc.bean_picker_check)}",
        f"bean_origin = {_format_list(gc.bean_origin)}",
        f"bean_spacing = {gc.bean_spacing}",
        f"box_origin = {_format_list(gc.box_origin)}",
        f"box_spacing = {gc.box_spacing}",
        f"plant_button = {_format_list(gc.plant_button)}",
        f"reset_button = {_format_list(gc.reset_button)}",
        f"ok_button = {_format_list(gc.ok_button)}",
        f"remove_confirm_x = {gc.remove_confirm_x}",
        f"remove_confirm_y_positions = {_format_list(gc.remove_confirm_y_positions)}",
        "",
        "[garden.colors]",
        f"sidebar_color = {_format_list(gcol.sidebar_color)}",
        f"bucket_color = {_format_list(gcol.bucket_color)}",
        f"shovel_color = {_format_list(gcol.shovel_color)}",
        f"bean_picker_open_color = {_format_list(gcol.bean_picker_open_color)}",
        f"box_inactive_color = {_format_list(gcol.box_inactive_color)}",
        f"box_first_color = {_format_list(gcol.box_first_color)}",
        f"ok_dialog_color = {_format_list(gcol.ok_dialog_color)}",
        "",
        "[teleport.coords]",
        f"book_button = {_format_list(tc.book_button)}",
        f"map_tab = {_format_list(tc.map_tab)}",
        f"book_open_check = {_format_list(tc.book_open_check)}",
        f"acorn_acres = {_format_list(tc.acorn_acres)}",
        f"bossbot_hq = {_format_list(tc.bossbot_hq)}",
        f"cashbot_hq = {_format_list(tc.cashbot_hq)}",
        f"donalds_dock = {_format_list(tc.donalds_dock)}",
        f"dreamland = {_format_list(tc.dreamland)}",
        f"daisy_gardens = {_format_list(tc.daisy_gardens)}",
        f"estate = {_format_list(tc.estate)}",
        f"goofy_speedway = {_format_list(tc.goofy_speedway)}",
        f"lawbot_hq = {_format_list(tc.lawbot_hq)}",
        f"melodyland = {_format_list(tc.melodyland)}",
        f"playground = {_format_list(tc.playground)}",
        f"sellbot_hq = {_format_list(tc.sellbot_hq)}",
        f"ttc = {_format_list(tc.ttc)}",
        "",
        "[teleport.colors]",
        f"book_open_color = {_format_list(tcol.book_open_color)}",
        "",
    ]
