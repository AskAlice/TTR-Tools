"""Interactive calibration tool for capturing pixel coordinates and colors.

Two modes:
  1. Guided wizard (--calibrate): Step-by-step prompts to capture each coordinate/color
  2. Crosshair inspector (--inspect): Real-time mouse position + pixel color under cursor

All captured coordinates are stored in logical space (pynput/OS coordinates).
The scaling layer handles physical conversion transparently.
"""

from __future__ import annotations

import logging
import time
from datetime import UTC, datetime

from ttr_tools.automation import InputController
from ttr_tools.config import (
    CalibrationMeta,
    CalibrationProfile,
    GardenCalibration,
    GardenColors,
    GardenCoords,
    TeleportCalibration,
    TeleportColors,
    TeleportCoords,
    save_calibration,
)
from ttr_tools.pixels import PixelReader
from ttr_tools.scaling import CoordinateScaler
from ttr_tools.window import find_ttr_window

logger = logging.getLogger(__name__)


def _wait_for_enter(prompt: str) -> None:
    input(f"\n>>> {prompt}\n    Press Enter when ready...")


def _capture_point(
    input_ctrl: InputController, pixel_reader: PixelReader, label: str
) -> tuple[list[int], list[int]]:
    """Capture the current mouse position and pixel color.

    Returns (coord_xy, color_rgb) both as lists for TOML storage.
    """
    _wait_for_enter(f"Move your mouse over the **{label}** and press Enter.")
    x, y = input_ctrl.mouse_position
    color = pixel_reader.get_pixel_color(x, y)
    print(f"    Captured: ({x}, {y}) color=RGB{color}")
    return [x, y], list(color)


def _capture_coord(input_ctrl: InputController, label: str) -> list[int]:
    """Capture just a coordinate (no color needed)."""
    _wait_for_enter(f"Move your mouse over the **{label}** and press Enter.")
    x, y = input_ctrl.mouse_position
    print(f"    Captured: ({x}, {y})")
    return [x, y]


def _capture_spacing(input_ctrl: InputController, label_first: str, label_second: str) -> int:
    """Capture spacing between two elements by measuring both positions."""
    _wait_for_enter(f"Move your mouse over the **{label_first}** and press Enter.")
    x1, _ = input_ctrl.mouse_position
    print(f"    First position: x={x1}")
    _wait_for_enter(f"Now move to the **{label_second}** and press Enter.")
    x2, _ = input_ctrl.mouse_position
    spacing = abs(x2 - x1)
    print(f"    Second position: x={x2}, spacing={spacing}px")
    return spacing


def run_guided_calibration() -> None:
    """Run the full guided calibration wizard via terminal prompts."""
    print("=" * 60)
    print("  TTR-Tools Calibration Wizard")
    print("=" * 60)
    print()
    print("This wizard will walk you through capturing pixel positions")
    print("and colors from your Toontown Rewritten window.")
    print()
    print("Requirements:")
    print("  - TTR must be open and visible")
    print("  - Your toon should be at their estate (for garden calibration)")
    print("  - Do not resize the TTR window during calibration")
    print()

    scaler = CoordinateScaler()
    pixel_reader = PixelReader(scaler)
    input_ctrl = InputController()

    # Detect window
    info = find_ttr_window()
    if info is None:
        print("ERROR: Toontown Rewritten window not found. Please open the game first.")
        return

    bounds = info["bounds"]
    win_w = int(bounds.get("Width", 816))
    win_h = int(bounds.get("Height", 639))
    print(f"Found TTR window: {win_w}x{win_h}")

    meta = CalibrationMeta(
        created=datetime.now(UTC).isoformat(),
        window_width=win_w,
        window_height=win_h,
        scale_factor=scaler.scale_factor,
    )

    # --- Garden calibration ---
    print("\n--- GARDEN CALIBRATION ---")
    print("Navigate your toon to a flower pot in your estate garden.\n")

    sidebar_coord, sidebar_color = _capture_point(
        input_ctrl, pixel_reader, "garden sidebar header (yellow bar)"
    )
    shovel_coord, shovel_color = _capture_point(input_ctrl, pixel_reader, "shovel icon")
    shovel_click = _capture_coord(input_ctrl, "shovel click target (center of shovel button)")
    bucket_coord, bucket_color = _capture_point(input_ctrl, pixel_reader, "water bucket icon")
    picker_coord, picker_color = _capture_point(
        input_ctrl, pixel_reader, "bean picker background (open the planting window first)"
    )

    print("\n  Now let's calibrate the bean positions.")
    bean_origin = _capture_coord(input_ctrl, "first bean (leftmost)")
    bean_spacing = _capture_spacing(input_ctrl, "first bean (leftmost)", "second bean (next one)")

    print("\n  Now the bean box positions.")
    box_origin = _capture_coord(input_ctrl, "first bean box (leftmost)")
    box_spacing = _capture_spacing(input_ctrl, "first bean box", "second bean box")

    plant_btn = _capture_coord(input_ctrl, "Plant button")
    reset_btn = _capture_coord(input_ctrl, "Reset/Cancel button")
    ok_btn = _capture_coord(input_ctrl, "OK button (after planting)")

    print("\n  Capture remove-plant confirmation button positions (4 clicks).")
    remove_x_coord = _capture_coord(input_ctrl, "remove-plant confirm button")
    remove_x = remove_x_coord[0]
    remove_ys: list[int] = [remove_x_coord[1]]
    for i in range(2, 5):
        c = _capture_coord(input_ctrl, f"remove-plant confirm button #{i}")
        remove_ys.append(c[1])

    garden_coords = GardenCoords(
        sidebar_header=sidebar_coord,
        shovel_icon=shovel_coord,
        shovel_click=shovel_click,
        water_bucket=bucket_coord,
        bean_picker_check=picker_coord,
        bean_origin=bean_origin,
        bean_spacing=bean_spacing,
        box_origin=box_origin,
        box_spacing=box_spacing,
        plant_button=plant_btn,
        reset_button=reset_btn,
        ok_button=ok_btn,
        remove_confirm_x=remove_x,
        remove_confirm_y_positions=remove_ys,
    )

    # Read box colors from defaults — these are UI chrome colors unlikely to change
    _wait_for_enter("Hover over an inactive (grey) bean box")
    _, box_inactive = _capture_point(input_ctrl, pixel_reader, "inactive bean box")
    _wait_for_enter("Hover over the first (white/selected) bean box")
    _, box_first = _capture_point(input_ctrl, pixel_reader, "selected bean box")
    _, ok_dialog_color = _capture_point(
        input_ctrl, pixel_reader, "OK dialog background (after planting)"
    )

    garden_colors = GardenColors(
        sidebar_color=sidebar_color,
        bucket_color=bucket_color,
        shovel_color=shovel_color,
        bean_picker_open_color=picker_color,
        box_inactive_color=box_inactive,
        box_first_color=box_first,
        ok_dialog_color=ok_dialog_color,
    )

    # --- Teleport calibration ---
    print("\n--- TELEPORT CALIBRATION ---")
    print("We need to capture the Shticker Book and map positions.\n")

    book_btn = _capture_coord(input_ctrl, "Shticker Book button (bottom right)")
    map_tab = _capture_coord(input_ctrl, "Map tab in the Shticker Book")
    book_check_coord, book_check_color = _capture_point(
        input_ctrl, pixel_reader, "book-open detection pixel (dark blue area of open book)"
    )

    destinations = [
        ("Acorn Acres", "acorn_acres"),
        ("Bossbot HQ", "bossbot_hq"),
        ("Cashbot HQ", "cashbot_hq"),
        ("Donald's Dock", "donalds_dock"),
        ("Donald's Dreamland", "dreamland"),
        ("Daisy Gardens", "daisy_gardens"),
        ("Estate", "estate"),
        ("Goofy Speedway", "goofy_speedway"),
        ("Lawbot HQ", "lawbot_hq"),
        ("Minnie's Melodyland", "melodyland"),
        ("Playground", "playground"),
        ("Sellbot HQ", "sellbot_hq"),
        ("Toontown Central", "ttc"),
    ]

    tp_coords_dict: dict[str, list[int]] = {}
    print("\n  Click each destination on the map when prompted.")
    for display_name, field_name in destinations:
        tp_coords_dict[field_name] = _capture_coord(input_ctrl, f"{display_name} on the map")

    teleport_coords = TeleportCoords(
        book_button=book_btn,
        map_tab=map_tab,
        book_open_check=book_check_coord,
        **tp_coords_dict,
    )
    teleport_colors = TeleportColors(book_open_color=book_check_color)

    # --- Save ---
    profile = CalibrationProfile(
        meta=meta,
        garden=GardenCalibration(coords=garden_coords, colors=garden_colors),
        teleport=TeleportCalibration(coords=teleport_coords, colors=teleport_colors),
    )
    save_calibration(profile)
    print("\n" + "=" * 60)
    print("  Calibration complete! Profile saved.")
    print("=" * 60)

    pixel_reader.close()


def run_crosshair_inspector() -> None:
    """Real-time crosshair inspector — shows mouse pos and pixel color continuously."""
    print("=" * 60)
    print("  TTR-Tools Crosshair Inspector")
    print("=" * 60)
    print()
    print("Move your mouse around. Current position and pixel color are shown below.")
    print("Press Ctrl+C to exit.\n")

    scaler = CoordinateScaler()
    pixel_reader = PixelReader(scaler)
    input_ctrl = InputController()

    try:
        while True:
            x, y = input_ctrl.mouse_position
            try:
                color = pixel_reader.get_pixel_color(x, y)
                print(
                    f"\r  Position: ({x:4d}, {y:4d})  |  "
                    f"Color: RGB({color[0]:3d}, {color[1]:3d}, {color[2]:3d})  |  "
                    f"Hex: #{color[0]:02X}{color[1]:02X}{color[2]:02X}",
                    end="",
                    flush=True,
                )
            except Exception:
                print(
                    f"\r  Position: ({x:4d}, {y:4d})  |  Color: (capture error)", end="", flush=True
                )
            time.sleep(0.1)
    except KeyboardInterrupt:
        print("\n\nInspector closed.")
    finally:
        pixel_reader.close()
