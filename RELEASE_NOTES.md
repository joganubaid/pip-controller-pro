# PiP Controller Pro v2.2.1

**Professional Picture-in-Picture Control for Windows**

## Downloads

Choose the version that fits your needs:

| Type | File | Description |
|------|------|-------------|
| **Installer** (Recommended) | [**PiPControllerPro-v2.2.1-Setup.exe**](https://github.com/joganubaid/pip-controller-pro/releases/download/v2.2.1/PiPControllerPro-v2.2.1-Setup.exe) | Easy installation, Start Menu shortcuts, uninstaller. |
| **Portable** | [**PiPControllerPro-v2.2.1-Portable.zip**](https://github.com/joganubaid/pip-controller-pro/releases/download/v2.2.1/PiPControllerPro-v2.2.1-Portable.zip) | No install needed. Extract and run `pip-controller.exe`. |
| **Direct exe** | [**pip-controller.exe**](https://github.com/joganubaid/pip-controller-pro/releases/download/v2.2.1/pip-controller.exe) | Single executable. Run directly. |
| **Source Code** | [**Source Code (zip)**](https://github.com/joganubaid/pip-controller-pro/archive/refs/tags/v2.2.1.zip) | Raw AutoHotkey scripts for developers. |

Every artifact ships with a SHA256 checksum (`SHA256SUMS.txt`) and a Sigstore keyless signature (`*.sigstore`). See [SIGNING.md](SIGNING.md) for verification.

---

## What's New in v2.2.1

### Added
- **In-app update check** — new "Check for Updates" tray item, plus a silent automatic check 10 seconds after startup. Surfaces a TrayTip when a newer version is available.
- **Signed and checksummed release artifacts** — every release now ships with `SHA256SUMS.txt` and per-artifact Sigstore keyless signatures (`*.sigstore`).
- **CI startup smoke test** — every push boots the freshly-built exe and requires it to survive 5 seconds without crashing.
- **`SECURITY.md`** — supported versions and private-disclosure flow via GitHub Security Advisories.

### Changed
- **Hardened CI/release pipeline** — all third-party actions SHA-pinned; Dependabot keeps them current.
- **`release.yml` permissions** — `id-token: write` added so cosign can use the GitHub OIDC issuer for keyless signing.

See the full list in [CHANGELOG.md](CHANGELOG.md).

---

## Developer Guidance

### Requirements
- **AutoHotkey v1.1+**: [Download](https://www.autohotkey.com/download/1.1/AutoHotkey_1.1.37.02_setup.exe) (the script uses v1 syntax; v2 will not run it).
- **Windows 10/11**
- For building the installer: **[Inno Setup 6+](https://jrsoftware.org/isdl.php)**

### Running from Source
1. Download the Source Code (zip) or `git clone` the repo.
2. Install AutoHotkey v1.1.
3. Double-click `pip-controller.ahk`.

### Building Yourself
```powershell
# Build the portable ZIP only (no Inno Setup needed)
.\build.ps1 -BuildPortable

# Build everything (requires Inno Setup installed)
.\build.ps1 -BuildAll
```

If you don't want to install AutoHotkey system-wide, drop the official AutoHotkey 1.1 portable zip into `.ahk/` at the repo root — `build.ps1` will use the `.ahk/Compiler/Ahk2Exe.exe` it finds there.
