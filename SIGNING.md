# Release Signing and Verification

PiP Controller Pro releases ship with two integrity layers. Neither of them
removes Windows SmartScreen warnings yet (see "About SmartScreen" below for
why and what we plan to do about it), but together they let any user prove
that a downloaded binary came from this repo's official release workflow
and hasn't been tampered with in transit.

## What ships with each release

For every release (e.g. `v2.2.0`) the [Releases page](https://github.com/joganubaid/pip-controller-pro/releases)
will include:

| File                                           | What it is                                         |
| ---------------------------------------------- | -------------------------------------------------- |
| `pip-controller.exe`                           | The bare compiled executable.                      |
| `PiPControllerPro-vX.Y.Z-Portable.zip`         | The portable bundle (exe + README).                |
| `PiPControllerPro-vX.Y.Z-Setup.exe`            | The Inno Setup installer.                          |
| `SHA256SUMS.txt`                               | SHA256 hashes of the three artifacts above.        |
| `*.sigstore`                                   | Sigstore keyless signature bundle per artifact.    |

## Layer 1: SHA256 checksums (no tools needed)

Anyone with PowerShell or `sha256sum` can verify an artifact's hash matches
what the release lists. From PowerShell, after downloading the artifact
and `SHA256SUMS.txt` into the same folder:

```powershell
# Spot-check one file:
$expected = (Get-Content SHA256SUMS.txt | Select-String 'pip-controller.exe').Line.Split(' ')[0]
$actual   = (Get-FileHash pip-controller.exe -Algorithm SHA256).Hash.ToLower()
if ($actual -eq $expected) { Write-Host "OK" } else { Write-Host "MISMATCH"; exit 1 }
```

This proves the file you downloaded matches what the release published,
but it does **not** prove the `SHA256SUMS.txt` itself came from this
repo's release workflow — that's what layer 2 is for.

## Layer 2: Sigstore keyless signatures

Each artifact has a `<name>.sigstore` bundle signed via Sigstore's keyless
flow. The signature is bound to the GitHub Actions OIDC identity of the
release workflow — meaning it can only be produced by a job running in
this repository, on a tag matching `v*.*.*`, from the `release.yml`
workflow file.

To verify, install [cosign](https://docs.sigstore.dev/system_config/installation/)
once, then for each artifact:

```bash
cosign verify-blob \
  --bundle pip-controller.exe.sigstore \
  --certificate-identity-regexp 'https://github.com/joganubaid/pip-controller-pro/\.github/workflows/release\.yml@.*' \
  --certificate-oidc-issuer 'https://token.actions.githubusercontent.com' \
  pip-controller.exe
```

A successful run prints `Verified OK`. Any tamper, swap, or impersonation
attempt fails the verification.

## About Windows SmartScreen

You will still see a SmartScreen warning ("Windows protected your PC")
when running the installer or the portable exe. Sigstore signatures are
not Authenticode — Windows only suppresses SmartScreen for binaries signed
with a real Authenticode certificate whose hash has built reputation with
Microsoft.

To bypass the warning manually: click **More info** → **Run anyway**.

We plan to upgrade to real Authenticode signing via the free
[SignPath OSS](https://about.signpath.io/products/oss) program, which
provides a real Authenticode certificate for free to qualifying
open-source projects. Application is manual; the workflow scaffolding
will be added once SignPath approves us.

## Reporting a signature verification failure

If `cosign verify-blob` fails on a fresh download of a release artifact,
please [report it as a security issue](https://github.com/joganubaid/pip-controller-pro/security/advisories/new)
rather than opening a public issue. A failed verification could mean a
compromised release.
