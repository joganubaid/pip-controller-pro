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

# Function to get AHK compiler path. Checks system install first, then a
# repo-local portable install at .ahk/Compiler/ — handy for contributors who
# don't want a system-wide AutoHotkey install.
function Get-AhkCompiler {
    $candidates = @(
        "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe",
        "C:\Program Files (x86)\AutoHotkey\Compiler\Ahk2Exe.exe",
        (Join-Path $scriptDir ".ahk\Compiler\Ahk2Exe.exe")
    )
    foreach ($p in $candidates) {
        if (Test-Path $p) { return $p }
    }
    return $null
}

# Find the matching base .bin next to the compiler. Passing /base explicitly is
# more reproducible than relying on Ahk2Exe's default-base lookup (which depends
# on an Ahk2Exe.ini that the portable distribution does not ship with).
function Get-AhkBase {
    param([Parameter(Mandatory = $true)][string] $compilerPath)
    $dir = Split-Path -Parent $compilerPath
    foreach ($name in @("Unicode 64-bit.bin","Unicode 32-bit.bin","ANSI 32-bit.bin")) {
        $candidate = Join-Path $dir $name
        if (Test-Path $candidate) { return $candidate }
    }
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
    # Use $compilerArgs (not $args — that's a PowerShell automatic variable).
    $compilerArgs = "/in `"$ahkScript`" /out `"$ahkExe`""
    $base = Get-AhkBase -compilerPath $compiler
    if ($base) {
        $compilerArgs = "$compilerArgs /base `"$base`""
    } else {
        Write-Host "No base .bin found next to Ahk2Exe — falling back to Ahk2Exe default." -ForegroundColor Yellow
    }
    $proc = Start-Process -FilePath $compiler -ArgumentList $compilerArgs -Wait -NoNewWindow -PassThru
    if ($proc.ExitCode -ne 0 -or -not (Test-Path $ahkExe)) {
        Write-Host "Compilation failed (Ahk2Exe exit=$($proc.ExitCode))." -ForegroundColor Red
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
    # Wipe the staging dir so previous builds don't leak stale files into the zip.
    if (Test-Path $portableDir) { Remove-Item $portableDir -Recurse -Force }
    New-Item -ItemType Directory -Path $portableDir -Force | Out-Null
    Copy-Item $ahkExe $portableDir -Force
    Copy-Item "$scriptDir\README.md" $portableDir -Force

    $zipPath = Join-Path $distDir "$AppName-v$Version-Portable.zip"
    # ZipFile.CreateFromDirectory does not overwrite — delete first if rerunning.
    if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
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
