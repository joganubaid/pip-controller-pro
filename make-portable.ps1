# Simple Portable Version Builder
# Creates a ZIP package ready for distribution

$Version = "2.0.0"
$AppName = "PiPControllerPro"

Write-Host "Creating PiP Controller Pro v$Version Portable Edition..." -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green

# Clean and create directories
if (Test-Path "dist") { Remove-Item "dist" -Recurse -Force }
if (Test-Path "temp") { Remove-Item "temp" -Recurse -Force }
New-Item -ItemType Directory -Path "dist" -Force | Out-Null
New-Item -ItemType Directory -Path "temp\Portable" -Force | Out-Null

# Build the executable first
Write-Host "Building executable..." -ForegroundColor Yellow
& ".\build.ps1" -Build
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

# Copy files to portable directory
Write-Host "Copying files..." -ForegroundColor Yellow
Copy-Item "pip-controller.exe" "temp\Portable\"
Copy-Item "README.md" "temp\Portable\"
Copy-Item "LICENSE.txt" "temp\Portable\"

# Create portable readme
$portableReadme = @"
PiP Controller Pro v$Version - Portable Edition
=============================================

🎬 Professional Picture-in-Picture Window Controller

This is a portable version that doesn't require installation.

QUICK START:
1. Run pip-controller.exe
2. Right-click the system tray icon for full menu
3. Open Chrome/Edge, play a video, enable Picture-in-Picture
4. Hover over PiP window to see transparency effects
5. Hold Shift while hovering for full opacity

FEATURES:
• No installation required - run from anywhere
• Settings automatically saved to: %AppData%\PiPController\
• Professional system tray integration with submenus
• Status Dashboard (Ctrl+Alt+C or tray menu)
• 6 transparency presets (Almost Invisible to Opaque)
• 5 response speed settings (Ultra Fast to Slow)
• Browser testing tools for Chrome and Edge
• Multiple reset options for troubleshooting

TRAY MENU FEATURES:
• Quick Transparency - 6 instant preset levels
• Response Speed - 5 performance levels  
• Browser Tools - Test and reset PiP windows
• Reset Options - Multiple reset levels
• Status Dashboard - Real-time monitoring GUI
• Enable/Disable - Toggle functionality

HOTKEYS:
• Ctrl+Alt+C: Open Status Dashboard
• Ctrl+Alt+P: Pause/Resume
• Ctrl+Alt+X: Exit

BROWSER SUPPORT:
✅ Google Chrome
✅ Microsoft Edge  
❓ Firefox (may work with modifications)

SYSTEM REQUIREMENTS:
• Windows 10/11 (Windows 7/8 may work)
• Minimal memory usage (< 15 MB RAM)
• No administrator rights required

For detailed information, see README.md

LICENSE: MIT License - Free for personal and commercial use
SUPPORT: https://github.com/yourusername/pip-controller

Enjoy your enhanced Picture-in-Picture experience! 🚀
"@

$portableReadme | Out-File -FilePath "temp\Portable\PORTABLE-README.txt" -Encoding UTF8

# Create the ZIP file
Write-Host "Creating ZIP package..." -ForegroundColor Yellow
$zipPath = "dist\$AppName-v$Version-Portable.zip"

Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory("temp\Portable", $zipPath)

# Get file size
$zipSize = [math]::Round((Get-Item $zipPath).Length / 1KB, 2)

Write-Host ""
Write-Host "✅ SUCCESS! Portable version created:" -ForegroundColor Green
Write-Host "File: $AppName-v$Version-Portable.zip ($zipSize KB)" -ForegroundColor White
Write-Host "Location: $(Resolve-Path $zipPath)" -ForegroundColor Gray
Write-Host ""
Write-Host "🚀 Ready for distribution!" -ForegroundColor Cyan

# Clean up
Remove-Item "temp" -Recurse -Force

Write-Host ""
Write-Host "Package Contents:" -ForegroundColor Yellow
Write-Host "• pip-controller.exe - Main application" -ForegroundColor White
Write-Host "• README.md - Full documentation" -ForegroundColor White  
Write-Host "• LICENSE.txt - MIT License" -ForegroundColor White
Write-Host "• PORTABLE-README.txt - Quick start guide" -ForegroundColor White
