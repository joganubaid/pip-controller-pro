# PiP Controller Pro - Distribution Build Script
# Creates professional installer and portable versions for publishing

param(
    [switch]$BuildAll = $false,
    [switch]$BuildPortable = $false,
    [switch]$BuildInstaller = $false,
    [switch]$Clean = $false
)

$Version = "2.0.0"
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
$buildResult = & "$scriptDir\build.ps1" -Build
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to build main executable!" -ForegroundColor Red
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

Visit: https://github.com/yourusername/pip-controller
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

### ✨ Features
- **Professional System Tray Integration** - Complete control from your system tray
- **Status Dashboard** - Real-time monitoring of PiP windows and app status
- **Multiple Transparency Presets** - Quick selection from 6 preset levels
- **Response Speed Control** - Adjust from Ultra Fast to Slow response times
- **Browser Tools** - Test Chrome and Edge PiP detection
- **Reset Options** - Multiple reset levels for troubleshooting
- **Enhanced Hotkeys** - Ctrl+Alt+C for Status Dashboard access

### 🔧 Technical Improvements
- **Clean Architecture** - Simplified, maintainable codebase
- **Professional Installer** - Inno Setup-based installer with proper uninstall
- **Portable Version** - No-install ZIP package option
- **Settings Persistence** - All settings saved automatically
- **Error Handling** - Robust error handling and recovery

### 🖱️ User Interface
- **Modern Tray Menu** - Professional menu with icons and submenus
- **Status Dashboard** - Beautiful GUI with real-time information
- **Smart Detection** - Enhanced PiP window detection for Chrome and Edge
- **Visual Feedback** - Notifications and status indicators

## 📦 Distribution Options

### 🚀 Installer Version (Recommended)
- **File**: \`$AppName-v$Version-Setup.exe\`
- **Features**: Professional installation, Start Menu shortcuts, optional Windows startup
- **Uninstall**: Proper Windows uninstaller with settings cleanup

### 📁 Portable Version
- **File**: \`$AppName-v$Version-Portable.zip\`
- **Features**: No installation required, run from any location
- **Settings**: Saved to user AppData folder

## 🎯 How to Use

1. **Install or extract** the application
2. **Run PiP Controller Pro**
3. **Right-click the tray icon** for all options
4. **Open Chrome/Edge**, play a video, enable Picture-in-Picture
5. **Hover over PiP window** - enjoy automatic transparency!
6. **Hold Shift** while hovering for full opacity

## 🔧 System Requirements

- **OS**: Windows 10/11 (Windows 7/8 may work)
- **Memory**: Minimal (< 15 MB RAM usage)
- **Browsers**: Chrome, Edge (Firefox may work with modifications)
- **Permissions**: No administrator rights required

## 🐛 Bug Fixes

- Fixed AutoHotkey compilation errors
- Resolved tray menu initialization issues
- Improved PiP window detection reliability
- Fixed settings persistence across restarts

## 📞 Support

- **Issues**: Report at [GitHub Issues](https://github.com/yourusername/pip-controller/issues)
- **Documentation**: See README.md included with download
- **License**: MIT License - free for personal and commercial use

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
