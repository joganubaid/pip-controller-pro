# PiP Controller Pro v2.1.0

🎬 **Professional Picture-in-Picture Window Controller**

A powerful Windows utility that enhances your Picture-in-Picture experience with automatic transparency, click-through functionality, and professional system tray integration.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: Windows](https://img.shields.io/badge/Platform-Windows-blue.svg)](https://www.microsoft.com/windows/)
[![AutoHotkey](https://img.shields.io/badge/AutoHotkey-v1.1+-green.svg)](https://www.autohotkey.com/)

![PiP Controller Pro](https://via.placeholder.com/800x400/2196F3/FFFFFF?text=PiP+Controller+Pro+v2.1.0)

## 🆕 What's New in v2.1.0

- **💾 Settings Persistence**: All settings automatically saved and restored between sessions
- **🚀 Auto-Start Support**: Option to start with Windows automatically
- **📊 Enhanced Status Dashboard**: Real-time monitoring with detailed window information
- **🔧 Improved Edge Compatibility**: Better detection and handling of Microsoft Edge PiP windows
- **🔄 Reset Options**: Multiple reset levels for troubleshooting
- **🎯 Smart Detection**: Enhanced PiP window detection with fallback methods
- **⚡ Performance Optimizations**: Better error handling and resource management

## ✨ Features

- **Automatic transparency**: Makes PiP windows semi-transparent when mouse hovers over them
- **Click-through**: Allows clicking through the PiP window to interact with content behind it
- **Shift override**: Hold Shift key to make the window fully opaque and interactive
- **Multi-browser support**: Works with Chrome and Microsoft Edge
- **Settings persistence**: All preferences saved automatically
- **Auto-start option**: Start with Windows automatically
- **Professional system tray**: Complete control from your system tray
- **Status dashboard**: Real-time monitoring and diagnostics
- **Multiple transparency presets**: 6 preset levels from almost invisible to opaque
- **Response speed control**: 5 performance levels from ultra fast to slow
- **Browser tools**: Test and reset PiP windows for troubleshooting
- **Hotkeys**: Quick access to all features

## 📥 Download & Install

### 🔧 Option 1: Portable Version (RECOMMENDED)
**File:** [PiPControllerPro-v2.1.0-Portable.zip](https://github.com/joganubaid/pip-controller-pro/releases/download/v2.1.0/PiPControllerPro-v2.1.0-Portable.zip) (~3 MB)

✅ **Choose this if you want:**
- No installation required
- Complete package with documentation
- Run from anywhere (USB drive, desktop, etc.)
- Easy to share or backup
- Settings saved to user profile

**📥 How to use:**
1. Click the download link above
2. Extract the ZIP file anywhere
3. Run `pip-controller.exe`
4. Done! No installation needed

### 📁 Option 2: Direct Executable
**File:** [pip-controller.exe](https://github.com/joganubaid/pip-controller-pro/raw/main/pip-controller.exe) (~1.2 MB)

✅ **Choose this if you want:**
- Single file download
- Just the executable
- Quick and simple
- Minimal download size

**📥 How to use:**
1. Click the download link above
2. Save the file anywhere
3. Double-click to run
4. Done! Ready to use

## 🚀 Quick Start Guide

After installing or extracting:

1. **Launch the app** - It will appear in your system tray
2. **Right-click the tray icon** → Access all settings and options
3. **Open Chrome or Edge** and play any video (YouTube, Netflix, etc.)
4. **Right-click the video** → Select "Picture in picture"
5. **Hover over the PiP window** → Watch it become transparent! ✨
6. **Hold Shift while hovering** → Makes it fully opaque and clickable
7. **Use Ctrl+Alt+C** → Open Status Dashboard for monitoring

### 🎮 Hotkeys
- **Ctrl+Alt+C** - Open Status Dashboard
- **Ctrl+Alt+P** - Pause/Resume transparency
- **Ctrl+Alt+X** - Exit application

## 🎯 System Tray Features

### 📊 Status Dashboard
- Real-time monitoring of PiP windows
- Current settings and status
- Window information and diagnostics
- Quick access via Ctrl+Alt+C or tray menu

### 🎨 Quick Transparency
- **Almost Invisible (25)** - Very transparent
- **Very Light (64)** - Light transparency
- **Medium (128)** - Balanced transparency
- **Default (179)** - Recommended setting
- **Slight (230)** - Minimal transparency
- **Opaque (255)** - No transparency

### ⚡ Response Speed
- **Ultra Fast (10ms)** - Maximum responsiveness
- **Very Fast (25ms)** - High performance
- **Fast (50ms)** - Recommended setting
- **Normal (100ms)** - Balanced performance
- **Slow (200ms)** - Lower CPU usage

### 🔧 Browser Tools
- **Test Chrome PiP** - Check Chrome detection
- **Test Edge PiP** - Check Edge detection
- **Show All Windows** - Debug window list
- **Reset All PiP** - Reset all PiP windows

### 🔄 Reset Options
- **Reset Current PiP** - Reset active window
- **Reset All PiP Windows** - Reset all windows
- **Reset All Settings** - Factory defaults

## 🛠️ Build Options (For Developers)

We provide a single, powerful build script:

```powershell
# Build everything (Installer and Portable - Recommended)
.\build.ps1 -BuildAll

# Build only the portable ZIP
.\build.ps1 -BuildPortable

# Build only the installer
.\build.ps1 -BuildInstaller
```

## 📁 Settings & Configuration

### Settings File Location
Settings are automatically saved to: `%AppData%\PiPController\settings.ini`

### Manual Configuration
You can modify these settings in the `pip-controller.ahk` file:

```autohotkey
transparency := 179       ; Default transparency (0-255, where 0 is invisible)
checkInterval := 50       ; How often to check mouse position (milliseconds)
isEnabled := true         ; Whether the script is enabled
autoStart := false        ; Whether to start with Windows
```

## 🔧 How It Works

1. The script continuously monitors mouse position
2. When mouse hovers over a Picture-in-Picture window:
   - If Shift is NOT pressed: Makes window semi-transparent and click-through
   - If Shift IS pressed: Makes window fully opaque and interactive
3. When mouse moves away: Restores window to normal state
4. All settings are automatically saved and restored

## 🌐 Browser Support

- ✅ **Google Chrome** - Full support
- ✅ **Microsoft Edge** - Full support
- ✅ **Brave** - Full support (Chromium-based, same PiP behavior as Chrome)
- ✅ **Vivaldi / Opera** - Full support (Chromium-based)
- 🟡 **Firefox** - Best-effort support via window-title heuristic. Detection depends on the Firefox version exposing "Picture-in-Picture" in the window title; if your build doesn't, the script won't see the PiP window. Open an issue if it doesn't work for you.

## 🐛 Troubleshooting

### PiP Window Not Detected
- Use **Browser Tools** → **Test Chrome PiP** or **Test Edge PiP**
- Try **Show All Windows** to see available windows
- Restart the script after opening PiP mode
- Check if the window title contains "Picture-in-picture"

### Script Not Working
- Check if AutoHotkey is installed properly
- Run as administrator if needed
- Ensure no other AutoHotkey scripts are interfering
- Use **Reset All PiP** to clear any stuck states

### Settings Issues
- Use **Reset All Settings** to restore defaults
- Check settings file at: `%AppData%\PiPController\settings.ini`
- Restart the application after changing settings

### Build Fails
- Make sure you have internet connection for AutoHotkey download
- Run PowerShell as administrator
- Check Windows Defender/antivirus isn't blocking the compilation

## 📋 System Requirements

- **OS**: Windows 10/11 (Windows 7/8 may work)
- **Memory**: Minimal (< 15 MB RAM usage)
- **Permissions**: No administrator rights required
- **Browsers**: Chrome, Edge, Brave, Vivaldi, Opera (full); Firefox (best-effort)

## 📁 Files

- `pip-controller.ahk` - Main AutoHotkey script
- `build.ps1` - Master build script
- `installer.iss` - Inno Setup installer script
- `pip-controller.exe` - Compiled executable (after build)
- `README.md` - This documentation
- `LICENSE.txt` - MIT License

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

### Development Setup
1. Fork the repository
2. Install AutoHotkey v1.1+ (the script uses v1 syntax — v2 will not run it)
3. Run `.\build.ps1 -BuildAll` (or `-BuildPortable` / `-BuildInstaller` for a single artifact)
4. Test thoroughly on Windows 10/11
5. Submit a pull request

## 📄 License

Free to use and modify for personal and commercial purposes under the MIT License.

## 🆘 Support

- **Issues**: Report at [GitHub Issues](https://github.com/joganubaid/pip-controller-pro/issues)
- **Documentation**: See README.md included with download
- **License**: MIT License - free for personal and commercial use

---

**Enjoy your enhanced Picture-in-Picture experience!** 🎬
