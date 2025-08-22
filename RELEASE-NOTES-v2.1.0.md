# PiP Controller Pro v2.1.0 Release Notes

## 🎉 What's New in v2.1.0

### ✨ New Features

#### 💾 Settings Persistence
- **Automatic Settings Save**: All preferences automatically saved between sessions
- **Settings File**: Stored in `%AppData%\PiPController\settings.ini`
- **Persistent Configuration**: Transparency, speed, and preferences remembered
- **Clean Management**: Automatic settings directory creation and management

#### 🚀 Auto-Start Support
- **Windows Integration**: Option to start with Windows automatically
- **Registry Integration**: Proper Windows registry integration for startup
- **User Control**: Easy enable/disable from system tray menu
- **Clean Uninstall**: Proper cleanup when auto-start is disabled

#### 📊 Enhanced Status Dashboard
- **Real-time Monitoring**: Live status of PiP windows and application state
- **Window Information**: Detailed window title, size, and position data
- **Settings Overview**: Current transparency, speed, and auto-start status
- **Quick Access**: Available via Ctrl+Alt+C hotkey or tray menu
- **Visual Indicators**: Clear status indicators with emojis

#### 🔄 Reset Options
- **Reset Current PiP**: Reset only the currently active PiP window
- **Reset All PiP Windows**: Reset all detected PiP windows
- **Reset All Settings**: Factory reset with confirmation dialog
- **Troubleshooting Tools**: Multiple reset levels for different scenarios

#### 🎯 Smart Detection
- **Enhanced Edge Compatibility**: Better detection and handling of Microsoft Edge PiP windows
- **Fallback Methods**: Multiple detection strategies for reliable PiP window identification
- **Debug Tools**: Show All Windows tool for troubleshooting
- **Improved Reliability**: Better handling of window state changes

### 🔧 Technical Improvements

#### Performance Optimizations
- **Better Error Handling**: More robust error recovery and user feedback
- **Resource Management**: Optimized memory usage and cleanup
- **Window State Management**: Better handling of window state changes and errors
- **Memory Efficiency**: Reduced resource consumption

#### Enhanced User Interface
- **Reorganized Menu**: Better structured system tray menu with logical grouping
- **Visual Feedback**: Enhanced notifications and status indicators
- **Default Action**: Double-click tray icon now opens Status Dashboard
- **Menu Item Updates**: Dynamic menu item updates based on current state

#### Code Quality
- **Modular Functions**: Better function organization and reusability
- **Error Recovery**: Enhanced ErrorLevel checks and null validation
- **Settings Management**: Clean settings file handling
- **Registry Operations**: Proper Windows registry integration

### 🐛 Bug Fixes

#### Settings Issues
- **Settings Not Persisting**: Fixed issue where settings weren't saved between sessions
- **Auto-Start Menu**: Fixed auto-start menu item not updating correctly
- **Settings File**: Proper creation and management of settings directory

#### Edge Compatibility
- **Edge Detection Issues**: Fixed Microsoft Edge Picture-in-Picture detection problems
- **Window Identification**: Improved reliability of PiP window detection
- **Fallback Detection**: Added multiple detection methods for Edge windows

#### Error Handling
- **Window State Management**: Better handling of window state changes and errors
- **Error Recovery**: Improved handling of missing or invalid windows
- **Resource Cleanup**: Better cleanup when windows are closed or moved

### 🆕 New Hotkeys

- **Ctrl+Alt+C**: Open Status Dashboard
- **Ctrl+Alt+P**: Pause/Resume transparency (existing)
- **Ctrl+Alt+X**: Exit application (existing)

## 📦 Distribution Options

### 🚀 Installer Version (Recommended)
- **File**: `PiPControllerPro-v2.1.0-Setup.exe`
- **Features**: Professional installation, Start Menu shortcuts, optional Windows startup
- **Uninstall**: Proper Windows uninstaller with settings cleanup
- **Registry**: Clean registry integration for auto-start functionality

### 📁 Portable Version
- **File**: `PiPControllerPro-v2.1.0-Portable.zip`
- **Features**: No installation required, run from any location
- **Settings**: Saved to user AppData folder
- **Portability**: Complete package with documentation

## 🎯 How to Use

1. **Install or extract** the application
2. **Run PiP Controller Pro** - appears in system tray
3. **Right-click the tray icon** for all options and settings
4. **Open Chrome/Edge**, play a video, enable Picture-in-Picture
5. **Hover over PiP window** - enjoy automatic transparency!
6. **Hold Shift** while hovering for full opacity
7. **Use Ctrl+Alt+C** for Status Dashboard access

## 🔧 System Requirements

- **OS**: Windows 10/11 (Windows 7/8 may work)
- **Memory**: Minimal (< 15 MB RAM usage)
- **Browsers**: Chrome, Edge (Firefox may work with modifications)
- **Permissions**: No administrator rights required
- **Storage**: ~1.2 MB for executable, settings saved to AppData

## 📁 Settings & Configuration

- **Settings File**: Automatically saved to `%AppData%\PiPController\settings.ini`
- **Auto-Start**: Windows registry integration for startup
- **Transparency**: 6 preset levels (25-255)
- **Response Speed**: 5 performance levels (10-200ms)
- **Browser Support**: Enhanced Chrome and Edge detection

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

### Auto-Start Issues
- Check Windows registry: `HKCU\Software\Microsoft\Windows\CurrentVersion\Run\PiPControllerPro`
- Use **Reset All Settings** to clear auto-start configuration
- Ensure the executable path is correct

## 📞 Support

- **Issues**: Report at [GitHub Issues](https://github.com/joganubaid/pip-controller-pro/issues)
- **Documentation**: See README.md included with download
- **License**: MIT License - free for personal and commercial use
- **Troubleshooting**: Built-in diagnostic tools and reset options

## 🔄 Migration from v2.0.1

### New Features to Try
1. **Settings Persistence**: Your preferences will now be remembered
2. **Auto-Start**: Enable automatic startup with Windows
3. **Status Dashboard**: Use Ctrl+Alt+C for detailed monitoring
4. **Reset Options**: Multiple troubleshooting tools available

### Breaking Changes
- None - this is a fully backward compatible update
- All existing functionality preserved
- Enhanced with new features and improvements

---

**Enjoy your enhanced Picture-in-Picture experience!** 🎬

*PiP Controller Pro v2.1.0 - Professional Picture-in-Picture Window Controller*
