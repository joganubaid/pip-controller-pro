# PiP Controller Pro v2.2.0

**Professional Picture-in-Picture Control for Windows**

## Downloads

Choose the version that fits your needs:

| Type | File | Description |
|------|------|-------------|
| **Installer** (Recommended) | [**PiPControllerPro-v2.2.0-Setup.exe**](https://github.com/joganubaid/pip-controller-pro/releases/download/v2.2.0/PiPControllerPro-v2.2.0-Setup.exe) | Easy installation, Start Menu shortcuts, uninstaller. |
| **Portable** | [**PiPControllerPro-v2.2.0-Portable.zip**](https://github.com/joganubaid/pip-controller-pro/releases/download/v2.2.0/PiPControllerPro-v2.2.0-Portable.zip) | No install needed. Extract and run `pip-controller.exe`. |
| **Direct exe** | [**pip-controller.exe**](https://github.com/joganubaid/pip-controller-pro/releases/download/v2.2.0/pip-controller.exe) | Single executable. Run directly. |
| **Source Code** | [**Source Code (zip)**](https://github.com/joganubaid/pip-controller-pro/archive/refs/tags/v2.2.0.zip) | Raw AutoHotkey scripts for developers. |

---

## What's New in v2.2.0

### Added
- **Brave, Vivaldi, Opera support** — all Chromium-based, same PiP behavior as Chrome.
- **Best-effort Firefox support** — PiP windows detected via a "contains" title match scoped to `firefox.exe`.
- **Per-browser Test items** — Browser Tools submenu now has a dedicated Test entry for each supported browser.
- **GitHub Actions CI/CD** — push to `main` runs syntax check + smoke build; pushing a `v*.*.*` tag builds and publishes a GitHub Release automatically.
- **`VERSION` file** — single source of truth for the version, consumed by both `build.ps1` and `installer.iss`.

### Fixed
- **`Ctrl+Alt+P` actually pauses now** — previously `Suspend` did not stop the transparency timer and disabled the hotkey itself, so once paused there was no way to resume.
- **Tray menu rename drift** — toggling Enable/Disable or Auto-Start more than once now consistently updates the visible label.
- **Factory reset cleans the registry** — Reset All Settings now removes the autostart Run-key value.
- **`$args` in `build.ps1`** — renamed (it's a PowerShell automatic variable).

### Removed
- **Stub "Show All Windows" tray item** — handler was a MsgBox saying "disabled in simple mode". Removed for honesty; can return when implemented.

See the full diff in [CHANGELOG.md](CHANGELOG.md#220---2026-05-28).

---

## Developer Guidance

### Requirements
- **AutoHotkey v1.1+**: [Download](https://www.autohotkey.com/download/1.1/AutoHotkey_1.1.37.02_setup.exe) (the script uses v1 syntax; v2 will not run it).
- **Windows 10/11**
- For building the installer: **[Inno Setup 6+](https://jrsoftware.org/isdl.php)**

### Running from Source
1. Download the Source Code (zip) or `git clone` the repo.
2. Install AutoHotkey v1.1.
3. Double-click `pip-controller.ahk`.

### Building Yourself
```powershell
# Build the portable ZIP only (no Inno Setup needed)
.\build.ps1 -BuildPortable

# Build everything (requires Inno Setup installed)
.\build.ps1 -BuildAll
```

If you don't want to install AutoHotkey system-wide, drop the official AutoHotkey 1.1 portable zip into `.ahk/` at the repo root — `build.ps1` will use the `.ahk/Compiler/Ahk2Exe.exe` it finds there.
