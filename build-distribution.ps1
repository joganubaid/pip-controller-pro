# PiP Controller Pro - Distribution Build Script
# Creates professional installer and portable versions for publishing

param(
    [switch]$BuildAll = $false,
    [switch]$BuildPortable = $false,
    [switch]$BuildInstaller = $false,
    [switch]$Clean = $false
)

$Version = "2.1.0"
$AppName = "PiPControllerPro"
$scriptDir = $PSScriptRoot
$distDir = Join-Path $scriptDir "dist"
$tempDir = Join-Path $scriptDir "temp"

Write-Host "PiP Controller Pro - Distribution Builder v$Version" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green

# Clean previous builds
if ($Clean -or $BuildAll) {
    Write-Host "Cleaning previous builds..." -ForegroundColor Yellow
    if (Test-Path $distDir) {
        Remove-Item $distDir -Recurse -Force
    }
    if (Test-Path $tempDir) {
        Remove-Item $tempDir -Recurse -Force
    }
}

# Create directories
New-Item -ItemType Directory -Path $distDir -Force | Out-Null
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

# Build the main executable first
Write-Host "Building main executable..." -ForegroundColor Yellow
try {
    $buildProcess = Start-Process -FilePath "powershell.exe" -ArgumentList "-File", "`"$scriptDir\build.ps1`"", "-Build" -Wait -PassThru -NoNewWindow
    if ($buildProcess.ExitCode -ne 0) {
        Write-Host "Build process failed with exit code: $($buildProcess.ExitCode)" -ForegroundColor Red
        
        # Try alternative build method
        Write-Host "Attempting alternative build method..." -ForegroundColor Yellow
        & "$scriptDir\build.ps1" -Build
        
        if (-not (Test-Path "$scriptDir\pip-controller.exe")) {
            Write-Host "Failed to build main executable!" -ForegroundColor Red
            Write-Host "Please run '.\build.ps1 -Build' manually to see detailed error messages." -ForegroundColor Yellow
            exit 1
        }
    }
} catch {
    Write-Host "Build execution failed: $_" -ForegroundColor Red
    exit 1
}

# Verify executable exists
if (-not (Test-Path "$scriptDir\pip-controller.exe")) {
    Write-Host "Executable not found after build attempt!" -ForegroundColor Red
    Write-Host "Please ensure AutoHotkey is properly installed and try running '.\build.ps1 -Build' manually." -ForegroundColor Yellow
    exit 1
}

# Function to create portable version
function Build-PortableVersion {
    Write-Host "Creating portable version..." -ForegroundColor Yellow
    
    $portableDir = Join-Path $tempDir "Portable"
    New-Item -ItemType Directory -Path $portableDir -Force | Out-Null
    
    # Copy main files
    Copy-Item "$scriptDir\pip-controller.exe" $portableDir
    Copy-Item "$scriptDir\README.md" $portableDir
    Copy-Item "$scriptDir\LICENSE.txt" $portableDir
    
    # Create portable info file
    $portableInfo = @"
PiP Controller Pro v$Version - Portable Edition

This is a portable version that doesn't require installation.

Quick Start:
1. Run pip-controller.exe
2. Right-click the system tray icon for options
3. Open a video in Chrome/Edge and enable Picture-in-Picture
4. Hover over PiP window to see transparency effects

Features:
• No installation required
• Settings saved to: %AppData%\PiPController\
• Professional system tray integration
• Multiple transparency presets
• Status monitoring dashboard

For more information, see README.md

Visit: https://github.com/joganubaid/pip-controller-pro
"@
    
    $portableInfo | Out-File -FilePath "$portableDir\PORTABLE-README.txt" -Encoding UTF8
    
    # Create portable ZIP
    $portableZip = Join-Path $distDir "$AppName-v$Version-Portable.zip"
    Write-Host "Creating portable ZIP: $portableZip" -ForegroundColor Gray
    
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory($portableDir, $portableZip)
    
    Write-Host "✅ Portable version created: $(Split-Path $portableZip -Leaf)" -ForegroundColor Green
}

# Function to create installer version
function Build-InstallerVersion {
    Write-Host "Creating installer version..." -ForegroundColor Yellow
    
    # Check if Inno Setup is installed
    $innoSetupPaths = @(
        "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
        "${env:ProgramFiles}\Inno Setup 6\ISCC.exe",
        "${env:ProgramFiles(x86)}\Inno Setup 5\ISCC.exe",
        "${env:ProgramFiles}\Inno Setup 5\ISCC.exe"
    )
    
    $innoSetupPath = $null
    foreach ($path in $innoSetupPaths) {
        if (Test-Path $path) {
            $innoSetupPath = $path
            break
        }
    }
    
    if (-not $innoSetupPath) {
        Write-Host "❌ Inno Setup not found! Please install Inno Setup from: https://jrsoftware.org/isinfo.php" -ForegroundColor Red
        Write-Host "Looking for Inno Setup in:" -ForegroundColor Yellow
        foreach ($path in $innoSetupPaths) {
            Write-Host "  $path" -ForegroundColor Gray
        }
        return $false
    }
    
    Write-Host "Found Inno Setup: $innoSetupPath" -ForegroundColor Green
    
    # Build installer
    $installerScript = Join-Path $scriptDir "installer.iss"
    Write-Host "Building installer with script: $installerScript" -ForegroundColor Gray
    
    $processArgs = @{
        FilePath = $innoSetupPath
        ArgumentList = @("/Q", "`"$installerScript`"")
        Wait = $true
        NoNewWindow = $true
    }
    
    $process = Start-Process @processArgs -PassThru
    
    if ($process.ExitCode -eq 0) {
        $installerPath = Join-Path $distDir "$AppName-v$Version-Setup.exe"
        if (Test-Path $installerPath) {
            $fileSize = [math]::Round((Get-Item $installerPath).Length / 1MB, 2)
            Write-Host "✅ Installer created: $(Split-Path $installerPath -Leaf) ($fileSize MB)" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ Installer file not found after compilation!" -ForegroundColor Red
            return $false
        }
    } else {
        Write-Host "❌ Installer compilation failed with exit code: $($process.ExitCode)" -ForegroundColor Red
        return $false
    }
}

# Function to create release notes
function Create-ReleaseNotes {
    Write-Host "Creating release notes..." -ForegroundColor Yellow
    
    $releaseNotes = @"
# PiP Controller Pro v$Version Release Notes

## 🎉 What's New in v$Version

### ✨ New Features
- **💾 Settings Persistence** - All settings automatically saved and restored between sessions
- **🚀 Auto-Start Support** - Option to start with Windows automatically
- **📊 Enhanced Status Dashboard** - Real-time monitoring with detailed window information
- **🔄 Reset Options** - Multiple reset levels for troubleshooting
- **🎯 Smart Detection** - Enhanced PiP window detection with fallback methods

### 🔧 Technical Improvements
- **Improved Edge Compatibility** - Better detection and handling of Microsoft Edge PiP windows
- **Performance Optimizations** - Better error handling and resource management
- **Settings Management** - Automatic settings file creation and management
- **Registry Integration** - Proper Windows startup integration
- **Enhanced Error Handling** - More robust error recovery and user feedback

### 🖱️ User Interface Enhancements
- **Professional System Tray** - Complete control from your system tray with submenus
- **Status Dashboard** - Real-time monitoring with window information and diagnostics
- **Multiple Transparency Presets** - 6 preset levels from almost invisible to opaque
- **Response Speed Control** - 5 performance levels from ultra fast to slow
- **Browser Tools** - Test and reset PiP windows for troubleshooting
- **Visual Feedback** - Enhanced notifications and status indicators

## 📦 Distribution Options

### 🚀 Installer Version (Recommended)
- **File**: \`$AppName-v$Version-Setup.exe\`
- **Features**: Professional installation, Start Menu shortcuts, optional Windows startup
- **Uninstall**: Proper Windows uninstaller with settings cleanup
- **Registry**: Clean registry integration for auto-start functionality

### 📁 Portable Version
- **File**: \`$AppName-v$Version-Portable.zip\`
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

## 🐛 Bug Fixes & Improvements

- **Enhanced Edge Compatibility** - Fixed Microsoft Edge Picture-in-Picture detection issues
- **Settings Persistence** - Resolved settings not being saved between sessions
- **Auto-Start Integration** - Proper Windows registry integration for startup
- **Window Detection** - Improved PiP window detection with fallback methods
- **Error Recovery** - Better handling of window state changes and errors
- **Memory Management** - Optimized resource usage and cleanup

## 🆕 New Hotkeys

- **Ctrl+Alt+C** - Open Status Dashboard
- **Ctrl+Alt+P** - Pause/Resume transparency (existing)
- **Ctrl+Alt+X** - Exit application (existing)

## 📁 Settings & Configuration

- **Settings File**: Automatically saved to \`%AppData%\PiPController\settings.ini\`
- **Auto-Start**: Windows registry integration for startup
- **Transparency**: 6 preset levels (25-255)
- **Response Speed**: 5 performance levels (10-200ms)
- **Browser Support**: Enhanced Chrome and Edge detection

## 📞 Support

- **Issues**: Report at [GitHub Issues](https://github.com/joganubaid/pip-controller-pro/issues)
- **Documentation**: See README.md included with download
- **License**: MIT License - free for personal and commercial use
- **Troubleshooting**: Built-in diagnostic tools and reset options

---

**Enjoy your enhanced Picture-in-Picture experience!** 🎬
"@
    
    $releaseNotesPath = Join-Path $distDir "RELEASE-NOTES-v$Version.md"
    $releaseNotes | Out-File -FilePath $releaseNotesPath -Encoding UTF8
    
    Write-Host "✅ Release notes created: $(Split-Path $releaseNotesPath -Leaf)" -ForegroundColor Green
}

# Main execution
$success = $true

if ($BuildPortable -or $BuildAll) {
    Build-PortableVersion
}

if ($BuildInstaller -or $BuildAll) {
    $installerSuccess = Build-InstallerVersion
    $success = $success -and $installerSuccess
}

if ($BuildAll) {
    Create-ReleaseNotes
}

# Summary
Write-Host ""
Write-Host "Build Summary:" -ForegroundColor Yellow
Write-Host "==============" -ForegroundColor Yellow

$distFiles = Get-ChildItem $distDir -ErrorAction SilentlyContinue
if ($distFiles) {
    foreach ($file in $distFiles) {
        $size = if ($file.Length -gt 1MB) { 
            "$([math]::Round($file.Length / 1MB, 2)) MB" 
        } else { 
            "$([math]::Round($file.Length / 1KB, 2)) KB" 
        }
        Write-Host "📦 $($file.Name) ($size)" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "✅ Distribution files created in: $distDir" -ForegroundColor Green
    Write-Host ""
    Write-Host "🚀 Ready for publishing!" -ForegroundColor Cyan
} else {
    Write-Host "❌ No distribution files created!" -ForegroundColor Red
    $success = $false
}

# Clean up temp directory
if (Test-Path $tempDir) {
    Remove-Item $tempDir -Recurse -Force
}

if (-not $BuildPortable -and -not $BuildInstaller -and -not $BuildAll) {
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\build-distribution.ps1 -BuildAll         # Build everything" -ForegroundColor White
    Write-Host "  .\build-distribution.ps1 -BuildPortable    # Build portable ZIP only" -ForegroundColor White
    Write-Host "  .\build-distribution.ps1 -BuildInstaller   # Build installer only" -ForegroundColor White
    Write-Host "  .\build-distribution.ps1 -Clean            # Clean previous builds" -ForegroundColor White
    Write-Host ""
    Write-Host "For publishing, run: .\build-distribution.ps1 -BuildAll" -ForegroundColor Cyan
}

if ($success) { exit 0 } else { exit 1 }
