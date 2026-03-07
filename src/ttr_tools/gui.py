"""CustomTkinter GUI with tabs for Gardening, Teleport, Calibration, and Settings.

Bot work runs on worker threads. Log messages are dispatched to the GUI via
``root.after()`` for thread-safe Tkinter updates.
"""

from __future__ import annotations

import contextlib
import logging
import threading
from typing import TYPE_CHECKING

import customtkinter as ctk

from ttr_tools.automation import InputController
from ttr_tools.config import (
    is_using_defaults,
    load_app_config,
    load_calibration,
    save_app_config,
)
from ttr_tools.garden import GardenBot
from ttr_tools.pixels import PixelReader
from ttr_tools.scaling import CoordinateScaler
from ttr_tools.teleport import resolve_location, teleport_to
from ttr_tools.window import WindowWatchdog

if TYPE_CHECKING:
    pass

logger = logging.getLogger(__name__)


class GUILogHandler(logging.Handler):
    """Routes log records to a CTkTextbox widget via root.after()."""

    def __init__(self, textbox: ctk.CTkTextbox, root: ctk.CTk) -> None:
        super().__init__()
        self._textbox = textbox
        self._root = root

    def emit(self, record: logging.LogRecord) -> None:
        msg = self.format(record) + "\n"
        with contextlib.suppress(Exception):
            self._root.after(0, self._append, msg)

    def _append(self, msg: str) -> None:
        self._textbox.configure(state="normal")
        self._textbox.insert("end", msg)
        self._textbox.see("end")
        self._textbox.configure(state="disabled")


class TTRToolsApp:
    """Main application window."""

    def __init__(self) -> None:
        self._config = load_app_config()
        self._calibration = load_calibration()
        self._scaler = CoordinateScaler()
        self._watchdog = WindowWatchdog(
            self._config.window_name,
            (self._calibration.meta.window_width, self._calibration.meta.window_height),
        )
        self._garden_bot: GardenBot | None = None
        self._bot_lock = threading.Lock()

        ctk.set_appearance_mode("dark")
        ctk.set_default_color_theme("blue")

        self._root = ctk.CTk()
        self._root.title("TTR-Tools v2.0")
        self._root.geometry("700x520")
        self._root.resizable(False, False)
        self._root.protocol("WM_DELETE_WINDOW", self._on_close)

        self._build_ui()
        self._setup_logging()

        if is_using_defaults():
            self._log_to_garden(
                "WARNING: Using default calibration (2017 values). "
                "Run calibration for accurate results."
            )

    def _build_ui(self) -> None:
        tabview = ctk.CTkTabview(self._root, width=680, height=480)
        tabview.pack(padx=10, pady=10)

        self._build_garden_tab(tabview.add("Garden"))
        self._build_teleport_tab(tabview.add("Teleport"))
        self._build_calibration_tab(tabview.add("Calibration"))
        self._build_settings_tab(tabview.add("Settings"))

    # -- Garden Tab --

    def _build_garden_tab(self, tab: ctk.CTkFrame) -> None:
        btn_frame = ctk.CTkFrame(tab, fg_color="transparent")
        btn_frame.pack(fill="x", padx=5, pady=5)

        self._garden_btn = ctk.CTkButton(
            btn_frame, text="Start Auto-Garden", command=self._toggle_garden, width=180
        )
        self._garden_btn.pack(side="left", padx=5)

        self._can_train_btn = ctk.CTkButton(
            btn_frame, text="Train Watering Can", command=self._start_can_trainer, width=180
        )
        self._can_train_btn.pack(side="left", padx=5)

        stop_btn = ctk.CTkButton(
            btn_frame, text="Stop", command=self._stop_garden, width=100, fg_color="#C0392B"
        )
        stop_btn.pack(side="left", padx=5)

        qp_frame = ctk.CTkFrame(tab, fg_color="transparent")
        qp_frame.pack(fill="x", padx=5, pady=2)
        ctk.CTkLabel(qp_frame, text="Quick Plant:").pack(side="left", padx=5)
        for i in range(1, 6):
            ctk.CTkButton(
                qp_frame,
                text=f"#{i}",
                width=50,
                command=lambda n=i: self._quick_plant(n),
            ).pack(side="left", padx=2)

        self._garden_log = ctk.CTkTextbox(tab, height=320, state="disabled")
        self._garden_log.pack(fill="both", expand=True, padx=5, pady=5)

    def _log_to_garden(self, msg: str) -> None:
        self._root.after(0, self._append_garden_log, msg)

    def _append_garden_log(self, msg: str) -> None:
        self._garden_log.configure(state="normal")
        self._garden_log.insert("end", msg + "\n")
        self._garden_log.see("end")
        self._garden_log.configure(state="disabled")

    def _get_garden_bot(self) -> GardenBot:
        if self._garden_bot is None or not self._garden_bot.is_running:
            self._garden_bot = GardenBot(
                self._config,
                self._calibration,
                self._scaler,
                self._watchdog,
                log_callback=self._log_to_garden,
            )
        return self._garden_bot

    def _toggle_garden(self) -> None:
        with self._bot_lock:
            bot = self._get_garden_bot()
            if bot.is_running:
                bot.stop()
                self._garden_btn.configure(text="Start Auto-Garden")
            else:
                self._watchdog.start()
                bot.start_auto_garden()
                self._garden_btn.configure(text="Stop Auto-Garden")

    def _start_can_trainer(self) -> None:
        with self._bot_lock:
            bot = self._get_garden_bot()
            if not bot.is_running:
                self._watchdog.start()
                bot.start_can_trainer()

    def _quick_plant(self, number: int) -> None:
        with self._bot_lock:
            bot = self._get_garden_bot()
            if not bot.is_running:
                self._watchdog.start()
                bot.start_quick_plant(number)

    def _stop_garden(self) -> None:
        with self._bot_lock:
            if self._garden_bot is not None:
                self._garden_bot.stop()
                self._garden_btn.configure(text="Start Auto-Garden")

    # -- Teleport Tab --

    def _build_teleport_tab(self, tab: ctk.CTkFrame) -> None:
        input_frame = ctk.CTkFrame(tab, fg_color="transparent")
        input_frame.pack(fill="x", padx=5, pady=10)

        ctk.CTkLabel(input_frame, text="Teleport to:").pack(side="left", padx=5)
        self._tp_entry = ctk.CTkEntry(input_frame, width=200, placeholder_text="e.g. ddl, estate")
        self._tp_entry.pack(side="left", padx=5)
        self._tp_entry.bind("<Return>", lambda e: self._do_teleport())
        ctk.CTkButton(input_frame, text="Go", command=self._do_teleport, width=60).pack(
            side="left", padx=5
        )

        grid_frame = ctk.CTkFrame(tab, fg_color="transparent")
        grid_frame.pack(fill="both", expand=True, padx=5, pady=5)

        destinations = [
            ("TTC", "ttc"),
            ("Donald's Dock", "dd"),
            ("Daisy Gardens", "dg"),
            ("Melodyland", "mml"),
            ("Dreamland", "ddl"),
            ("Acorn Acres", "aa"),
            ("Goofy Speedway", "gs"),
            ("Estate", "estate"),
            ("Playground", "p"),
            ("Sellbot HQ", "sbhq"),
            ("Cashbot HQ", "cbhq"),
            ("Lawbot HQ", "lbhq"),
            ("Bossbot HQ", "bbhq"),
        ]

        for idx, (label, code) in enumerate(destinations):
            row, col = divmod(idx, 4)
            ctk.CTkButton(
                grid_frame,
                text=label,
                width=150,
                command=lambda c=code: self._teleport_shortcut(c),
            ).grid(row=row, column=col, padx=4, pady=4)

        self._tp_status = ctk.CTkLabel(tab, text="")
        self._tp_status.pack(pady=5)

    def _do_teleport(self) -> None:
        text = self._tp_entry.get().strip()
        if not text:
            return
        location = resolve_location(text)
        if location is None:
            self._tp_status.configure(text=f"Unknown location: {text}")
            return
        self._execute_teleport(location)

    def _teleport_shortcut(self, code: str) -> None:
        location = resolve_location(code)
        if location:
            self._execute_teleport(location)

    def _execute_teleport(self, location_field: str) -> None:
        self._watchdog.start()
        pixel_reader = PixelReader(self._scaler)
        input_ctrl = InputController()

        def _run() -> None:
            ok = teleport_to(
                location_field, self._calibration, input_ctrl, pixel_reader, self._watchdog
            )
            status = (
                f"Teleported to {location_field}" if ok else f"Teleport to {location_field} failed"
            )
            self._root.after(0, self._tp_status.configure, {"text": status})
            pixel_reader.close()

        threading.Thread(target=_run, name="teleport", daemon=True).start()

    # -- Calibration Tab --

    def _build_calibration_tab(self, tab: ctk.CTkFrame) -> None:
        info = ctk.CTkLabel(
            tab,
            text="Calibration captures pixel positions and colors from\n"
            "your TTR window so the bots know where to click.",
            justify="left",
        )
        info.pack(padx=10, pady=10, anchor="w")

        status_text = (
            "Using DEFAULT calibration (2017)"
            if is_using_defaults()
            else "Using custom calibration"
        )
        self._cal_status = ctk.CTkLabel(tab, text=status_text, font=("", 14, "bold"))
        self._cal_status.pack(padx=10, pady=5, anchor="w")

        meta = self._calibration.meta
        details = (
            f"Window: {meta.window_width}x{meta.window_height}  |  "
            f"Scale: {meta.scale_factor}x  |  Created: {meta.created or 'N/A'}"
        )
        ctk.CTkLabel(tab, text=details).pack(padx=10, pady=2, anchor="w")

        btn_frame = ctk.CTkFrame(tab, fg_color="transparent")
        btn_frame.pack(fill="x", padx=10, pady=15)

        ctk.CTkButton(
            btn_frame,
            text="Run Calibration Wizard",
            command=self._run_calibration,
            width=220,
        ).pack(side="left", padx=5)

        ctk.CTkButton(
            btn_frame,
            text="Run Crosshair Inspector",
            command=self._run_inspector,
            width=220,
        ).pack(side="left", padx=5)

        ctk.CTkLabel(
            tab,
            text="Note: Calibration runs in the terminal. Switch to your\n"
            "terminal window after clicking a button above.",
            text_color="grey",
        ).pack(padx=10, pady=10, anchor="w")

    def _run_calibration(self) -> None:
        threading.Thread(target=self._calibration_thread, daemon=True).start()

    def _calibration_thread(self) -> None:
        from ttr_tools.calibrate import run_guided_calibration

        run_guided_calibration()
        self._calibration = load_calibration()
        self._root.after(0, self._cal_status.configure, {"text": "Using custom calibration"})

    def _run_inspector(self) -> None:
        threading.Thread(target=self._inspector_thread, daemon=True).start()

    def _inspector_thread(self) -> None:
        from ttr_tools.calibrate import run_crosshair_inspector

        run_crosshair_inspector()

    # -- Settings Tab --

    def _build_settings_tab(self, tab: ctk.CTkFrame) -> None:
        ctk.CTkLabel(tab, text="Settings", font=("", 18, "bold")).pack(padx=10, pady=10, anchor="w")

        row1 = ctk.CTkFrame(tab, fg_color="transparent")
        row1.pack(fill="x", padx=10, pady=5)
        ctk.CTkLabel(row1, text="Window Name:").pack(side="left")
        self._window_name_entry = ctk.CTkEntry(row1, width=250)
        self._window_name_entry.insert(0, self._config.window_name)
        self._window_name_entry.pack(side="left", padx=10)

        row2 = ctk.CTkFrame(tab, fg_color="transparent")
        row2.pack(fill="x", padx=10, pady=5)
        ctk.CTkLabel(row2, text="Times to Water:").pack(side="left")
        self._water_times_entry = ctk.CTkEntry(row2, width=60)
        self._water_times_entry.insert(0, str(self._config.garden.times_to_water))
        self._water_times_entry.pack(side="left", padx=10)

        row3 = ctk.CTkFrame(tab, fg_color="transparent")
        row3.pack(fill="x", padx=10, pady=5)
        self._replant_var = ctk.BooleanVar(value=self._config.garden.replant)
        ctk.CTkCheckBox(row3, text="Enable Replanting", variable=self._replant_var).pack(
            side="left"
        )

        ctk.CTkButton(tab, text="Save Settings", command=self._save_settings, width=140).pack(
            padx=10, pady=15, anchor="w"
        )

        ctk.CTkLabel(
            tab,
            text="Hotkeys:\n"
            "  Cmd+Shift+G — Toggle Auto-Garden\n"
            "  F5 — Fast Teleport (prompts in terminal)\n"
            "  Numpad 1-5 — Quick Plant\n"
            "  Numpad . — Watering Can Trainer\n"
            "  Cmd+Shift+Q — Quit",
            justify="left",
            font=("", 12),
            text_color="grey",
        ).pack(padx=10, pady=10, anchor="w")

    def _save_settings(self) -> None:
        self._config.window_name = self._window_name_entry.get().strip() or "Toontown Rewritten"
        with contextlib.suppress(ValueError):
            self._config.garden.times_to_water = int(self._water_times_entry.get())
        self._config.garden.replant = self._replant_var.get()
        save_app_config(self._config)
        logger.info("Settings saved")

    # -- Logging --

    def _setup_logging(self) -> None:
        handler = GUILogHandler(self._garden_log, self._root)
        handler.setFormatter(
            logging.Formatter("%(asctime)s [%(levelname)s] %(message)s", datefmt="%H:%M:%S")
        )
        handler.setLevel(logging.INFO)
        logging.getLogger("ttr_tools").addHandler(handler)

    # -- Lifecycle --

    def _on_close(self) -> None:
        if self._garden_bot is not None:
            self._garden_bot.stop()
        self._watchdog.stop()
        self._root.destroy()

    def run(self) -> None:
        self._root.mainloop()
