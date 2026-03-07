# TTR-Tools v2.0 — macOS

Toontown Rewritten automation tools for macOS. A complete rewrite of the original [AskAlice/TTR-Tools](https://github.com/AskAlice/TTR-Tools) (Windows/AutoHotkey) in Python.

## Features

- **Auto-Garden Bot** — walks between flower pots, plants optimal bean combos, waters, and replants
- **Fast Teleport** — open the Shticker Book map and teleport by typing a location name or clicking a button
- **Watering Can Trainer** — automatically plants, waters, and removes flowers to level your watering can
- **Quick Plant** — one-key planting for a specific flower index
- **Pixel Calibration** — interactive wizard to capture fresh pixel coordinates from your game window
- **Crosshair Inspector** — real-time display of mouse position and pixel color for debugging
- **Retina Display Support** — automatic 2x scaling detection and coordinate conversion
- **Global Hotkeys** — Cmd+Shift+G (garden), F5 (teleport), Numpad 1-5 (quick plant), and more

## Requirements

- macOS 12+ (Monterey or later)
- Python 3.12+
- [uv](https://docs.astral.sh/uv/) package manager
- Toontown Rewritten installed and running

## Quick Start

```bash
# Clone the repo
git clone https://github.com/shanmufti/TTR-Tools.git
cd TTR-Tools
git checkout macos-rewrite

# Install dependencies and run
uv sync
uv run ttr-tools
```

## CLI Options

```bash
uv run ttr-tools                # Launch the GUI
uv run ttr-tools --calibrate    # Run the calibration wizard
uv run ttr-tools --inspect      # Run the crosshair inspector
uv run ttr-tools --verbose      # Enable debug logging
```

## Accessibility Permissions

TTR-Tools requires macOS Accessibility permissions to control mouse and keyboard input. On first launch, a system dialog will prompt you to grant access.

If the bots don't respond to hotkeys or fail to click:

1. Open **System Settings → Privacy & Security → Accessibility**
2. Find your terminal app (Terminal, iTerm2, etc.) and enable the toggle
3. Restart TTR-Tools

## Calibration

The bundled calibration profile contains pixel coordinates from the original 2017 AHK code. Since Toontown Rewritten may have changed its UI, you should run calibration to capture fresh values:

```bash
uv run ttr-tools --calibrate
```

The wizard walks you through hovering over each UI element and pressing Enter. Captured values are saved to `~/Library/Application Support/TTR-Tools/calibration.toml`.

To inspect pixel colors at any position (useful for debugging):

```bash
uv run ttr-tools --inspect
```

## Hotkeys

| Hotkey | Action |
|---|---|
| Cmd+Shift+G | Start/Stop Auto-Garden |
| F5 | Fast Teleport (text prompt) |
| Numpad 1-5 | Quick Plant flower #1-5 |
| Numpad . | Watering Can Trainer |
| Cmd+Shift+Q | Quit |

## Configuration

Settings are stored in `~/Library/Application Support/TTR-Tools/`:
- `config.toml` — app settings (window name, watering count, replant toggle)
- `calibration.toml` — pixel coordinates and colors from calibration

## Development

```bash
# Format code
uv run ruff format src/

# Lint
uv run ruff check src/

# Lint with auto-fix
uv run ruff check --fix src/
```

## Architecture

```
src/ttr_tools/
├── __init__.py          # Package version
├── __main__.py          # CLI entry point, logging, permission checks
├── automation.py        # pynput mouse/keyboard controllers
├── calibrate.py         # Calibration wizard and crosshair inspector
├── config.py            # TOML config/calibration loading and saving
├── default_calibration.toml  # Bundled 2017 fallback calibration
├── default_config.toml  # Bundled default settings
├── garden.py            # Gardening bot (auto-garden, quick plant, can trainer)
├── gui.py               # CustomTkinter GUI
├── hotkeys.py           # Global hotkey manager (pynput listener)
├── pixels.py            # mss screenshot pixel reader
├── scaling.py           # Retina display detection and coordinate conversion
├── teleport.py          # Fast Teleport
└── window.py            # Quartz window management and watchdog
```

## Credits

Original project by [AskAlice](https://github.com/AskAlice/TTR-Tools). macOS rewrite by [shanmufti](https://github.com/shanmufti).

## License

See [LICENSE](LICENSE) for details.
