# Security Policy

## Supported Versions

PiP Controller Pro follows a "latest stable only" support model — the latest
released version on the [Releases page](https://github.com/joganubaid/pip-controller-pro/releases)
is the only version that receives security fixes. There is no LTS branch.

| Version  | Supported          |
| -------- | ------------------ |
| 2.2.x    | :white_check_mark: |
| 2.1.x    | :x:                |
| 2.0.x    | :x:                |
| < 2.0    | :x:                |

If you're on an older version, please update before reporting — the fix may
already be in the latest release.

## Reporting a Vulnerability

**Do not open a public GitHub issue for security vulnerabilities.** Public
disclosure before a fix is available exposes every user.

Instead, please use GitHub's private vulnerability reporting:

1. Go to <https://github.com/joganubaid/pip-controller-pro/security/advisories/new>
2. Fill out the form with as much detail as you can share:
   - Affected version(s)
   - Steps to reproduce (or a proof-of-concept)
   - The impact you observed (privilege escalation, data exposure, etc.)
   - Any suggested mitigation

You'll get an acknowledgement within **5 business days**. After triage we'll
agree on a disclosure timeline (typically 30–90 days depending on severity)
and credit you in the release notes when the fix ships, unless you'd prefer
to stay anonymous.

If GitHub Security Advisories is unavailable to you for any reason, email
the maintainer listed in the repo profile instead.

## Scope

In scope:

- Vulnerabilities in the compiled `pip-controller.exe` or the Inno Setup
  installer that ship from this repo's release workflow.
- Issues in the build pipeline (`build.ps1`, `.github/workflows/*`) that
  could lead to a compromised release artifact.
- Supply-chain concerns with our pinned actions or AutoHotkey runtime.

Out of scope:

- Vulnerabilities in AutoHotkey itself — please report those upstream at
  <https://github.com/AutoHotkey/AutoHotkey>.
- Vulnerabilities in third-party browsers' Picture-in-Picture
  implementations — report those to the browser vendor.
- Social-engineering attacks that require the user to ignore Windows
  SmartScreen and a UAC prompt to install a custom build.

## Verifying releases

Every release artifact is checksummed (`SHA256SUMS.txt`) and signed via
Sigstore keyless signing (`*.sigstore`) so you can prove an artifact came
from this repo's `release.yml` workflow. See [SIGNING.md](SIGNING.md) for
the verification command.
