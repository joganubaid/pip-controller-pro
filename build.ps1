param(
    [switch]$BuildAll = $false,
    [switch]$BuildPortable = $false,
    [switch]$BuildInstaller = $false,
    [switch]$Clean = $false
)

$scriptDir = $PSScriptRoot
$versionFile = Join-Path $scriptDir "VERSION"
if (-not (Test-Path $versionFile)) {
    Write-Host "VERSION file not found at $versionFile" -ForegroundColor Red
    exit 1
}
$Version = (Get-Content $versionFile -Raw).Trim()
$AppName = "PiPControllerPro"
$distDir = Join-Path $scriptDir "dist"
$tempDir = Join-Path $scriptDir "temp"

# Function to get AHK compiler path
function Get-AhkCompiler {
    $compilerPath = "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe"
    if (Test-Path $compilerPath) { return $compilerPath }
    
    $compilerPath = "C:\Program Files (x86)\AutoHotkey\Compiler\Ahk2Exe.exe"
    if (Test-Path $compilerPath) { return $compilerPath }
    
    return $null
}

# Clean
if ($Clean -or $BuildAll) {
    if (Test-Path $distDir) { Remove-Item $distDir -Recurse -Force }
    if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
}

# Directories
New-Item -ItemType Directory -Path $distDir -Force | Out-Null
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

# Build EXE
Write-Host "Building executable..." -ForegroundColor Yellow
$ahkExe = Join-Path $scriptDir "pip-controller.exe"
$ahkScript = Join-Path $scriptDir "pip-controller.ahk"
$compiler = Get-AhkCompiler

if (-not $compiler) {
    Write-Host "AutoHotkey Compiler not found!" -ForegroundColor Red
    exit 1
}

# Patch the AppVersion line in the .ahk to match VERSION (single source of truth).
# Always restored in finally so the working tree isn't dirtied on success or failure.
$ahkBytes = [System.IO.File]::ReadAllBytes($ahkScript)
$ahkText  = [System.Text.Encoding]::UTF8.GetString($ahkBytes)
$patched  = [regex]::Replace($ahkText, 'AppVersion := "[^"]*"', "AppVersion := `"$Version`"")
$needsRestore = ($patched -ne $ahkText)
if ($needsRestore) {
    [System.IO.File]::WriteAllText($ahkScript, $patched, [System.Text.UTF8Encoding]::new($false))
}

try {
    # Simple compilation command - NO custom base, rely on defaults.
    # Use $compilerArgs (not $args — that's a PowerShell automatic variable).
    $compilerArgs = "/in `"$ahkScript`" /out `"$ahkExe`""
    Start-Process -FilePath $compiler -ArgumentList $compilerArgs -Wait -NoNewWindow

    if (-not (Test-Path $ahkExe)) {
        Write-Host "Compilation failed." -ForegroundColor Red
        exit 1
    }
    Write-Host "Executable built." -ForegroundColor Green
}
finally {
    if ($needsRestore) {
        [System.IO.File]::WriteAllBytes($ahkScript, $ahkBytes)
    }
}

# Portable
if ($BuildPortable -or $BuildAll) {
    Write-Host "Creating portable..." -ForegroundColor Yellow
    $portableDir = Join-Path $tempDir "Portable"
    New-Item -ItemType Directory -Path $portableDir -Force | Out-Null
    Copy-Item $ahkExe $portableDir
    Copy-Item "$scriptDir\README.md" $portableDir
    
    $zipPath = Join-Path $distDir "$AppName-v$Version-Portable.zip"
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory($portableDir, $zipPath)
    Write-Host "Portable zip created." -ForegroundColor Green
}

# Installer
if ($BuildInstaller -or $BuildAll) {
    Write-Host "Creating installer..." -ForegroundColor Yellow
    $iscc = "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe"
    if (-not (Test-Path $iscc)) {
        $iscc = "${env:ProgramFiles}\Inno Setup 6\ISCC.exe"
    }
    
    if (Test-Path $iscc) {
        $iss = Join-Path $scriptDir "installer.iss"
        Start-Process -FilePath $iscc -ArgumentList "/Q `"$iss`"" -Wait -NoNewWindow
        Write-Host "Installer created." -ForegroundColor Green
    } else {
        Write-Host "Inno Setup not found." -ForegroundColor Red
    }
}
