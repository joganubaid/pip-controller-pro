# Chrome PiP Controller Build Script
# This script will compile the AutoHotkey script to an executable

param(
    [switch]$InstallAHK = $false,
    [switch]$Build = $false
)

$scriptDir = $PSScriptRoot
$ahkScript = Join-Path $scriptDir "pip-controller.ahk"
$outputExe = Join-Path $scriptDir "pip-controller.exe"

Write-Host "Chrome Picture-in-Picture Controller Build Script" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green

# Function to check if AutoHotkey is installed
function Test-AutoHotkeyInstalled {
    $ahkPaths = @(
        "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe",
        "C:\Program Files (x86)\AutoHotkey\Compiler\Ahk2Exe.exe"
    )
    
    foreach ($path in $ahkPaths) {
        if (Test-Path $path) {
            return $path
        }
    }
    
    # Check in PATH
    try {
        $ahkPath = (Get-Command "Ahk2Exe.exe" -ErrorAction Stop).Source
        return $ahkPath
    } catch {
        return $null
    }
}

# Function to install AutoHotkey
function Install-AutoHotkey {
    Write-Host "Installing AutoHotkey..." -ForegroundColor Yellow
    
    # Download AutoHotkey installer
    $downloadUrl = "https://www.autohotkey.com/download/ahk-install.exe"
    $installerPath = Join-Path $env:TEMP "ahk-install.exe"
    
    try {
        Write-Host "Downloading AutoHotkey installer..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath -UseBasicParsing
        
        Write-Host "Running AutoHotkey installer..." -ForegroundColor Yellow
        Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait
        
        Write-Host "AutoHotkey installation completed!" -ForegroundColor Green
        Remove-Item $installerPath -ErrorAction SilentlyContinue
    } catch {
        Write-Host "Failed to download or install AutoHotkey: $_" -ForegroundColor Red
        return $false
    }
    
    return $true
}

# Function to build the executable
function Build-Executable {
    param($ahkCompilerPath)
    
Write-Host "Building executable with verbose output..." -ForegroundColor Yellow
Write-Host "Input:  $ahkScript" -ForegroundColor Gray
Write-Host "Output: $outputExe" -ForegroundColor Gray

# Ensure directory is writable environment
Write-Host "Checking directory permissions..." -ForegroundColor Gray
if (-not (Test-Path $scriptDir)) {
    Write-Host "Directory $scriptDir does not exist! Creating..." -ForegroundColor Yellow
    New-Item -Path $scriptDir -ItemType Directory -Force
}

# Remove any existing compiled executable prior to build
if (Test-Path $outputExe) {
    Write-Host "Removing existing executable to avoid conflicts..." -ForegroundColor Yellow
    Remove-Item $outputExe -Force
}
    
    try {
        # Run the AutoHotkey compiler
        $arguments = @(
            "/in", "`"$ahkScript`"",
            "/out", "`"$outputExe`""
        )
        
        Start-Process -FilePath $ahkCompilerPath -ArgumentList $arguments -Wait -NoNewWindow
        
        if (Test-Path $outputExe) {
            Write-Host "Build successful! Executable created at:" -ForegroundColor Green
            Write-Host $outputExe -ForegroundColor White
            
            # Get file size
            $fileSize = (Get-Item $outputExe).Length
            $fileSizeKB = [math]::Round($fileSize / 1KB, 2)
            Write-Host "File size: $fileSizeKB KB" -ForegroundColor Gray
            
            return $true
        } else {
            Write-Host "Build failed - executable not created" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "Build failed: $_" -ForegroundColor Red
        return $false
    }
}

# Main execution
if ($InstallAHK) {
    if (-not (Install-AutoHotkey)) {
        exit 1
    }
}

if ($Build) {
    $ahkCompiler = Test-AutoHotkeyInstalled
    
    if (-not $ahkCompiler) {
        Write-Host "AutoHotkey compiler not found!" -ForegroundColor Red
        Write-Host "Run with -InstallAHK to install AutoHotkey first." -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "Found AutoHotkey compiler at: $ahkCompiler" -ForegroundColor Green
    
    if (-not (Test-Path $ahkScript)) {
        Write-Host "AutoHotkey script not found: $ahkScript" -ForegroundColor Red
        exit 1
    }
    
    if (Build-Executable $ahkCompiler) {
        Write-Host "`nBuild completed successfully!" -ForegroundColor Green
        Write-Host "You can now run: $outputExe" -ForegroundColor White
    } else {
        exit 1
    }
}

if (-not $InstallAHK -and -not $Build) {
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\build.ps1 -InstallAHK    # Install AutoHotkey" -ForegroundColor White
    Write-Host "  .\build.ps1 -Build         # Build the executable" -ForegroundColor White
    Write-Host "  .\build.ps1 -InstallAHK -Build  # Install and build" -ForegroundColor White
    Write-Host ""
    Write-Host "Files:" -ForegroundColor Yellow
    Write-Host "  Source: $ahkScript" -ForegroundColor White
    Write-Host "  Output: $outputExe" -ForegroundColor White
}
