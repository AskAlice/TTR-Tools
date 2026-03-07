"""Entry point for TTR-Tools.

Handles CLI argument parsing, accessibility permission checks, structured
logging setup, and launches either the GUI or a CLI tool (calibrate/inspect).
"""

from __future__ import annotations

import argparse
import logging

from ttr_tools.config import APP_DIR

LOG_FORMAT = "%(asctime)s [%(levelname)s] %(name)s: %(message)s"
LOG_FILE = APP_DIR / "ttr-tools.log"


def setup_logging(verbose: bool = False) -> None:
    APP_DIR.mkdir(parents=True, exist_ok=True)
    level = logging.DEBUG if verbose else logging.INFO
    logging.basicConfig(level=level, format=LOG_FORMAT)

    file_handler = logging.FileHandler(LOG_FILE)
    file_handler.setFormatter(logging.Formatter(LOG_FORMAT))
    file_handler.setLevel(logging.DEBUG)
    logging.getLogger().addHandler(file_handler)


def check_accessibility() -> bool:
    """Check macOS Accessibility permissions. Returns True if granted."""
    try:
        from ApplicationServices import AXIsProcessTrusted, AXIsProcessTrustedWithOptions

        trusted = AXIsProcessTrusted()
        if not trusted:
            # Trigger the system prompt
            options = {
                "AXTrustedCheckOptionPrompt": True,
            }
            AXIsProcessTrustedWithOptions(options)
            print(
                "\n"
                "Accessibility permission is required for TTR-Tools to control\n"
                "mouse and keyboard input.\n"
                "\n"
                "A system dialog should have appeared. Please:\n"
                "  1. Open System Settings > Privacy & Security > Accessibility\n"
                "  2. Enable access for your terminal app (Terminal, iTerm2, etc.)\n"
                "  3. Restart TTR-Tools\n"
            )
        return trusted
    except ImportError:
        logging.getLogger(__name__).warning(
            "Could not import ApplicationServices — skipping accessibility check"
        )
        return True


def main() -> None:
    parser = argparse.ArgumentParser(
        prog="ttr-tools",
        description="Toontown Rewritten automation tools for macOS",
    )
    parser.add_argument("--calibrate", action="store_true", help="Run the calibration wizard")
    parser.add_argument("--inspect", action="store_true", help="Run the crosshair inspector")
    parser.add_argument("--verbose", "-v", action="store_true", help="Enable debug logging")
    args = parser.parse_args()

    setup_logging(verbose=args.verbose)
    logger = logging.getLogger(__name__)
    logger.info("TTR-Tools v2.0 starting")

    if args.calibrate:
        from ttr_tools.calibrate import run_guided_calibration

        check_accessibility()
        run_guided_calibration()
        return

    if args.inspect:
        from ttr_tools.calibrate import run_crosshair_inspector

        check_accessibility()
        run_crosshair_inspector()
        return

    # GUI mode
    if not check_accessibility():
        logger.warning("Accessibility permission not granted — bot features may not work")

    from ttr_tools.gui import TTRToolsApp
    from ttr_tools.hotkeys import HotkeyManager

    app = TTRToolsApp()

    hotkeys = HotkeyManager()
    hotkeys.register("toggle_garden", app._toggle_garden)
    hotkeys.register("quit", app._on_close)

    def _teleport_prompt() -> None:
        """F5 teleport via terminal input (matching original AHK behavior)."""
        import tkinter.simpledialog as sd

        location = sd.askstring("Teleport", "Enter location name:", parent=app._root)
        if location:
            from ttr_tools.teleport import resolve_location

            field = resolve_location(location)
            if field:
                app._execute_teleport(field)

    hotkeys.register("teleport", _teleport_prompt)

    for i in range(1, 6):
        hotkeys.register(f"quick_plant_{i}", lambda n=i: app._quick_plant(n))
    hotkeys.register("train_watering_can", app._start_can_trainer)

    hotkeys.start()
    logger.info("Hotkeys registered, launching GUI")

    try:
        app.run()
    finally:
        hotkeys.stop()
        logger.info("TTR-Tools exiting")


if __name__ == "__main__":
    main()
