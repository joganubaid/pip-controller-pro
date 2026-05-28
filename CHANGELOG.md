# Changelog

All notable changes to PiP Controller Pro will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.2.1] - 2026-05-28

### Added
- **In-app update check**: a new "Check for Updates" tray menu item, plus a silent automatic check 10 seconds after startup. Both hit `https://api.github.com/repos/joganubaid/pip-controller-pro/releases/latest`, compare semver, and surface a `TrayTip` when a newer version is available. The startup check is silent on success; the menu version always reports the result.
- **Signed and checksummed release artifacts**: every release now ships with `SHA256SUMS.txt` and per-artifact Sigstore keyless signatures (`*.sigstore`). Verification instructions are in the new [`SIGNING.md`](SIGNING.md).
- **CI startup smoke test**: every PR / push to `main` now boots the freshly-built `pip-controller.exe` and requires it to survive 5 seconds without crashing. Catches runtime regressions that pass the syntax check but blow up on first frame.
- **`SECURITY.md`**: documents the supported version, scope, and the private-disclosure flow via GitHub Security Advisories.
- **`.github/dependabot.yml`**: monthly bumps for the `github-actions` ecosystem so the SHA-pinned actions don't go stale.
- **`.github/pull_request_template.md`**: structured PR description with a per-browser "tested on" checklist.

### Changed
- **CI / release workflows hardened**: all third-party actions are now SHA-pinned to their current major (`actions/checkout@v6`, `actions/upload-artifact@v7`, `softprops/action-gh-release@v3`, `sigstore/cosign-installer@v4`). Removes the Node 20 deprecation timeline and adds supply-chain integrity.
- **`release.yml` permissions**: `id-token: write` added on the release job so cosign can use the GitHub OIDC issuer for keyless signing.
- **`ci.yml` PSScriptAnalyzer step**: now prefers the copy preinstalled on the windows-2025 runner image and only falls back to PSGallery (with 3x retry + backoff) when the module is missing. Absorbs transient PSGallery flake.

### Security
- **Branch protection on `main`**: pushes now go through PRs, require the `Validate` CI check to pass, and disallow force-pushes / deletions. The maintainer can still hot-push when needed (admins are not enforced).

## [2.2.0] - 2026-05-28

### Added
- **Multi-browser support**: Brave, Vivaldi, and Opera are now detected via their `*.exe` process names (they're Chromium-based with the same PiP window title as Chrome).
- **Firefox support (best-effort)**: Firefox PiP windows are detected by scoping a "contains" title match to `firefox.exe`. Detection depends on the Firefox version exposing "Picture-in-Picture" in the window title.
- **Per-browser Test menu items**: the Browser Tools submenu now has a dedicated `Test <Browser> PiP` entry for each supported browser. Each one verifies its specific target process instead of all of them returning "any PiP window found".
- **`FindPiPWindowForExe(exe)` helper**: extracted from `FindPiPWindow()` so both the unified scan and per-browser test items share one detection path.
- **CI workflow** (`.github/workflows/ci.yml`): on every PR / push to `main`, pinned AutoHotkey 1.1.37.02 is installed and `Ahk2Exe` runs against the script as a syntax check. PSScriptAnalyzer runs against `build.ps1`, the VERSION/AppVersion consistency is verified, and the portable build is smoke-tested.
- **Release workflow** (`.github/workflows/release.yml`): pushing a `v*.*.*` tag triggers a Windows runner that installs AHK 1.1 + Inno Setup 6.3.3, builds the executable + portable zip + installer, extracts release notes from the matching `[<version>]` CHANGELOG section, and attaches everything to a GitHub Release.
- **`VERSION` file**: single source of truth for the version, consumed by `build.ps1` (patches the AHK source's `AppVersion` line at build time and names the output artifacts) and `installer.iss` (read at preprocessor time via `AddBackslash(SourcePath) + "VERSION"`).
- **`build.ps1` local-compiler fallback**: `Get-AhkCompiler` now also looks at `.ahk/Compiler/Ahk2Exe.exe` so contributors who drop the AutoHotkey 1.1 portable zip into `.ahk/` can build without a system-wide AHK install.
- **`build.ps1` explicit `/base`**: `Get-AhkBase` finds the `.bin` next to `Ahk2Exe.exe` and passes it as `/base`. The portable AHK distribution does not ship with `Ahk2Exe.ini`, so Ahk2Exe's default-base lookup fails ("No default Base file specified" dialog). Passing it explicitly also makes the system-installed path more reproducible.

### Fixed
- **`Ctrl+Alt+P` actually pauses now** (regression / never-worked bug): `Suspend` only disables hotkeys/hotstrings, not `SetTimer` — so the transparency loop kept running. The handler now toggles the timer explicitly, and `Suspend, Permit` makes the hotkey survive the suspend so it can also un-suspend itself.
- **Tray menu rename drift**: `ToggleEnabled` / `ToggleAutoStart` previously did `Menu, Tray, Rename, Enable/Disable, …` against a label that had already been renamed on the first toggle, so subsequent toggles silently failed to update the visible label. Replaced with a single `UpdateMenuState` sub that tracks the last-applied label in script-level globals.
- **`ResetAllSettings` left registry stale**: the "factory reset" turned the `autoStart` flag off but never removed the actual `HKCU\…\Run\PiPControllerPro` registry value the previous "enable autostart" wrote — so the app would still launch with Windows. Now also drops the registry value.
- **`ResetAllSettings` did not refresh the menu labels**: now calls the unified `UpdateMenuState` sub.
- **`TestChrome` / `TestEdge` were misnamed**: both handlers called the generic `FindPiPWindow()` so each reported "any browser PiP" instead of testing its specific target. Now each per-browser test scans only its own `ahk_exe`.
- **`build.ps1` used `$args`**: this is a PowerShell automatic variable (the script's argument array). Renamed to `$compilerArgs`.
- **`build.ps1 -BuildPortable` was not idempotent**: rerunning it failed because `[ZipFile]::CreateFromDirectory` refuses to overwrite. Now it removes the existing zip first and wipes the staging dir so prior builds don't leak files.

### Removed
- **`Show All Windows` tray menu item**: the handler was a stub that opened a MsgBox saying "disabled in simple mode" — it had been advertised in the menu, README, and CHANGELOG without an implementation since v2.1.0. Removed for honesty; a real debug-window listing can be reintroduced later if there's demand.
- **Old `.github/workflows/build.yml`**: superseded by `ci.yml` and `release.yml`. The old one used `https://www.autohotkey.com/download/ahk-install.exe` which now serves AutoHotkey v2 (which cannot compile v1 scripts), and pinned deprecated `actions/checkout@v3` / `actions/upload-artifact@v3`.

### Docs
- README v2.2.0 header, "What's New in v2.2.0" section, browser-support table, Quick Start guide, Browser Tools listing, and download URLs all updated.
- `CONTRIBUTING.md` `github.com/yourusername/…` template placeholder corrected to the real repo URL. Testing checklist expanded to all supported browsers.
- `installer.iss` welcome screen no longer says the tool is "for controlling Chrome Picture-in-Picture windows" — broadened to all supported browsers.
- `RELEASE_NOTES.md` rewritten for v2.2.0.
- `.github/ISSUE_TEMPLATE/bug_report.md` browser list updated to include all supported browsers.

## [2.1.0] - 2026-01-29

### Added
- **Settings Persistence**: All settings automatically saved and restored between sessions
- **Auto-Start Support**: Option to start with Windows automatically via registry integration
- **Enhanced Status Dashboard**: Real-time monitoring with detailed window information and diagnostics
- **Reset Options Menu**: Multiple reset levels for troubleshooting
- **Show All Windows Tool**: Debug tool to display all Chrome and Edge windows
- **Reset Current PiP**: Reset only the currently active PiP window
- **Reset All Settings**: Factory reset option with confirmation dialog
- **New Hotkey**: Ctrl+Alt+C to open Status Dashboard
- **Settings File Management**: Automatic creation and management of settings directory
- **Registry Integration**: Proper Windows startup integration for auto-start functionality

### Changed
- **Improved Edge Compatibility**: Better detection and handling of Microsoft Edge PiP windows
- **Enhanced Window Detection**: Added fallback methods for PiP window detection
- **Performance Optimizations**: Better error handling and resource management
- **Status Dashboard**: Enhanced with window information, position, and size details
- **System Tray Menu**: Reorganized with better structure and additional options
- **Error Handling**: More robust error recovery and user feedback
- **Memory Management**: Optimized resource usage and cleanup
- **Default Action**: Double-click tray icon now opens Status Dashboard instead of About

### Fixed
- **Settings Not Persisting**: Resolved issue where settings weren't saved between sessions
- **Edge Detection Issues**: Fixed Microsoft Edge Picture-in-Picture detection problems
- **Window State Management**: Better handling of window state changes and errors
- **Menu Item Updates**: Fixed auto-start menu item not updating correctly
- **Error Recovery**: Improved handling of missing or invalid windows
- **Resource Cleanup**: Better cleanup when windows are closed or moved

### Technical
- **Settings File**: `%AppData%\PiPController\settings.ini`
- **Registry Keys**: `HKCU\Software\Microsoft\Windows\CurrentVersion\Run\PiPControllerPro`
- **Error Handling**: Enhanced ErrorLevel checks and null validation
- **Code Structure**: Improved function organization and modularity

## [2.0.1] - 2024-01-XX

### Added
- **Enhanced Edge Compatibility**: Fixed Microsoft Edge Picture-in-Picture detection issues
- **Diagnostic Tool**: Added Edge PiP diagnostic tool for troubleshooting
- **Professional System Tray**: Complete control from system tray with submenus
- **Status Dashboard**: Real-time monitoring of PiP windows and app status
- **Multiple Transparency Presets**: Quick selection from 6 preset levels
- **Response Speed Control**: Adjust from Ultra Fast to Slow response times
- **Browser Tools**: Test Chrome and Edge PiP detection
- **Reset Options**: Multiple reset levels for troubleshooting
- **Enhanced Hotkeys**: Ctrl+Alt+C for Status Dashboard access

### Changed
- **Bug Fixes**: Resolved AutoHotkey runtime errors and improved window detection
- **Better Performance**: Improved error handling and null checks
- **Clean Architecture**: Simplified, maintainable codebase
- **Professional Installer**: Inno Setup-based installer with proper uninstall
- **Portable Version**: No-install ZIP package option
- **Modern Tray Menu**: Professional menu with icons and submenus
- **Smart Detection**: Enhanced PiP window detection for Chrome and Edge
- **Visual Feedback**: Notifications and status indicators

### Fixed
- **AutoHotkey Compilation Errors**: Fixed build process issues
- **Tray Menu Initialization**: Resolved menu creation problems
- **PiP Window Detection**: Improved reliability of window detection
- **Settings Persistence**: Fixed settings not persisting across restarts

## [2.0.0] - 2024-01-XX

### Added
- **Professional System Tray Integration**: Complete control from system tray
- **Multiple Transparency Levels**: 6 preset transparency options
- **Response Speed Control**: 5 performance levels
- **Browser Support**: Chrome and Edge compatibility
- **Hotkeys**: Pause/resume and exit functionality
- **Status Monitoring**: Real-time status information
- **Professional Build System**: PowerShell build scripts
- **Distribution Tools**: Installer and portable version creation

### Changed
- **Complete Rewrite**: Professional version with enhanced features
- **Improved UI**: Modern system tray interface
- **Better Performance**: Optimized mouse position checking
- **Enhanced Compatibility**: Multi-browser support
- **Professional Documentation**: Comprehensive README and guides

### Fixed
- **Window Detection**: Improved PiP window identification
- **Transparency Control**: Better transparency and click-through handling
- **Error Handling**: More robust error recovery
- **Build Process**: Streamlined compilation and distribution

## [1.0.0] - 2024-01-XX

### Added
- **Basic PiP Control**: Automatic transparency when hovering over PiP windows
- **Click-through Functionality**: Allow clicking through transparent windows
- **Shift Override**: Hold Shift to make window fully opaque and interactive
- **Chrome Support**: Basic Chrome Picture-in-Picture window detection
- **Simple Hotkeys**: Basic pause/resume and exit functionality

### Technical
- **AutoHotkey Script**: Basic functionality implementation
- **Mouse Position Monitoring**: Continuous mouse position checking
- **Window Transparency**: Dynamic transparency control
- **Click-through Toggle**: Enable/disable click-through functionality

---

## Version History Summary

- **v2.1.0**: Settings persistence, auto-start, enhanced dashboard, improved Edge compatibility
- **v2.0.1**: Professional system tray, diagnostic tools, enhanced browser support
- **v2.0.0**: Complete rewrite with professional features and multi-browser support
- **v1.0.0**: Initial release with basic PiP control functionality

## Future Plans

- **Custom Transparency**: User-defined transparency levels
- **Advanced Hotkeys**: More customizable hotkey options
- **Plugin System**: Extensible architecture for additional features
- **Multi-Monitor Support**: Enhanced multi-monitor compatibility
- **Performance Monitoring**: Built-in performance metrics and optimization
- **Document Picture-in-Picture (Chrome 116+)**: Detect the new always-on-top floating window introduced by the [Document PiP API](https://developer.chrome.com/docs/web-platform/document-picture-in-picture) (any JS-set title; not caught by the current title heuristic).
- **Firefox detection robustness**: Firefox PiP titles vary across versions; investigate window-class or always-on-top heuristics to detect PiP windows whose title doesn't expose "Picture-in-Picture".
