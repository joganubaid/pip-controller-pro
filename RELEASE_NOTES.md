# PiP Controller Pro v2.1.0

**Professional Picture-in-Picture Control for Windows**

## 📥 Downloads

Choose the version that fits your needs:

| Type | File | Description |
|------|------|-------------|
| **Installer** (Recommended) | [**PiPControllerPro-v2.1.0-Setup.exe**](PiPControllerPro-v2.1.0-Setup.exe) | Easy installation, Start Menu shortcuts, uninstaller. |
| **Portable** | [**PiPControllerPro-v2.1.0-Portable.zip**](PiPControllerPro-v2.1.0-Portable.zip) | No install needed. Extract and run `pip-controller.exe`. |
| **Source Code** | [**Source Code (zip)**](https://github.com/joganubaid/pip-controller-pro/archive/refs/tags/v2.1.0.zip) | Raw AutoHotkey scripts for developers. |

---

## 🎉 What's New in v2.1.0

### ✨ Key Features
- **💾 Settings Persistence**: Your preferences (transparency, speed) are now saved automatically between sessions.
- **🚀 Auto-Start Support**: Option to automatically start the application with Windows.
- **📊 Enhanced Status Dashboard**: Real-time monitoring of active PiP windows and system status (Ctrl+Alt+C).
- **🔧 Improved Edge Support**: Significantly better detection for Microsoft Edge Picture-in-Picture windows.
- **🔄 Reset Options**: New troubleshooting menu to reset stuck windows or restore factory settings.

### 🐛 Bug Fixes
- Fixed settings not saving after restart.
- Resolved build system errors for developers.
- Improved error handling for window detection.

---

## 👨‍💻 Developer Guidance

If you want to run from source or modify the code:

### Requirements
- **AutoHotkey v1.1+**: [Download Here](https://www.autohotkey.com/download/ahk-install.exe)
- **Windows 10/11**

### Running from Source
1. Download the **Source Code**.
2. Install AutoHotkey.
3. Double-click `pip-controller.ahk` to run.

### Building Yourself
To create your own executables, use the included build script in PowerShell:

```powershell
# Build everything (Installer + Portable)
.\build.ps1 -BuildAll
```
