# PiP Controller Pro v2.0.0

🎬 **Professional Picture-in-Picture Window Controller**

A powerful Windows utility that enhances your Picture-in-Picture experience with automatic transparency, click-through functionality, and professional system tray integration.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: Windows](https://img.shields.io/badge/Platform-Windows-blue.svg)](https://www.microsoft.com/windows/)
[![AutoHotkey](https://img.shields.io/badge/AutoHotkey-v1.1+-green.svg)](https://www.autohotkey.com/)

![PiP Controller Pro](https://via.placeholder.com/800x400/2196F3/FFFFFF?text=PiP+Controller+Pro+v2.0.0)

## Features

- **Automatic transparency**: Makes PiP windows semi-transparent when mouse hovers over them
- **Click-through**: Allows clicking through the PiP window to interact with content behind it
- **Shift override**: Hold Shift key to make the window fully opaque and interactive
- **Multi-browser support**: Works with Chrome and Microsoft Edge
- **Configurable**: Adjustable transparency levels and check intervals
- **Hotkeys**: Pause/resume and exit hotkeys included

## 📥 Download & Install

### 🔧 Option 1: Windows Installer (RECOMMENDED)
**File:** [PiPControllerPro-v2.0.0-Setup.exe](https://github.com/joganubaid/pip-controller-pro/releases/download/v2.0.0/PiPControllerPro-v2.0.0-Setup.exe) (2.22 MB)

✅ **Choose this if you want:**
- Easy installation with setup wizard
- Start Menu shortcuts
- Windows integration
- Automatic updates

**How to install:**
1. Download the installer
2. Double-click to run
3. Follow the setup wizard
4. Done! Find it in Start Menu

### 📁 Option 2: Portable Version
**File:** [PiPControllerPro-v2.0.0-Portable.zip](https://github.com/joganubaid/pip-controller-pro/releases/download/v2.0.0/PiPControllerPro-v2.0.0-Portable.zip) (604 KB)

✅ **Choose this if you want:**
- No installation required
- Run from USB drive
- Portable software
- Limited permissions

**How to use:**
1. Download and extract the ZIP
2. Run `pip-controller.exe`
3. Done! No installation needed

## Build Options

```powershell
# Show help
.\build.ps1

# Install AutoHotkey only
.\build.ps1 -InstallAHK

# Build executable only (requires AutoHotkey)
.\build.ps1 -Build

# Install and build in one command
.\build.ps1 -InstallAHK -Build
```

## Usage

1. **Start the application** (either the .exe or .ahk file)
2. **Open a video** in Chrome or Edge and enable Picture-in-Picture mode
3. **Hover over the PiP window** - it will become semi-transparent and click-through
4. **Hold Shift** while hovering to make it fully opaque and interactive
5. **Move away** from the PiP window to restore it to normal

## Hotkeys

- **Ctrl+Alt+P**: Pause/Resume the script
- **Ctrl+Alt+X**: Exit the script

## Configuration

You can modify these settings in the `pip-controller.ahk` file:

```autohotkey
transparency := 80       ; Default transparency (0-255, where 0 is invisible)
checkInterval := 50      ; How often to check mouse position (milliseconds)
```

## How It Works

1. The script continuously monitors mouse position
2. When mouse hovers over a Picture-in-Picture window:
   - If Shift is NOT pressed: Makes window semi-transparent and click-through
   - If Shift IS pressed: Makes window fully opaque and interactive
3. When mouse moves away: Restores window to normal state

## Browser Support

- ✅ Google Chrome
- ✅ Microsoft Edge
- ❓ Firefox (not tested, may work with modifications)

## Troubleshooting

### PiP Window Not Detected
- Make sure the window title contains "Picture-in-picture" or "Picture in picture"
- Try restarting the script after opening PiP mode

### Script Not Working
- Check if AutoHotkey is installed properly
- Run as administrator if needed
- Ensure no other AutoHotkey scripts are interfering

### Build Fails
- Make sure you have internet connection for AutoHotkey download
- Run PowerShell as administrator
- Check Windows Defender/antivirus isn't blocking the compilation

## Files

- `pip-controller.ahk` - Main AutoHotkey script
- `build.ps1` - PowerShell build script
- `pip-controller.exe` - Compiled executable (after build)
- `README.md` - This documentation

## License

Free to use and modify for personal and commercial purposes.
