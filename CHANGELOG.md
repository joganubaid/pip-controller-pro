# Changelog

All notable changes to PiP Controller Pro will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

- **Firefox Support**: Add compatibility with Firefox browser
- **Custom Transparency**: User-defined transparency levels
- **Advanced Hotkeys**: More customizable hotkey options
- **Plugin System**: Extensible architecture for additional features
- **Multi-Monitor Support**: Enhanced multi-monitor compatibility
- **Performance Monitoring**: Built-in performance metrics and optimization
