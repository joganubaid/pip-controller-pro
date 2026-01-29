# Contributing to PiP Controller Pro

Thank you for your interest in contributing to PiP Controller Pro! We welcome contributions from the community.

## How to Contribute

### Reporting Bugs
1. Check if the bug has already been reported in [Issues](https://github.com/yourusername/pip-controller/issues)
2. If not, create a new issue using the bug report template
3. Provide detailed information about your system and steps to reproduce

### Suggesting Features
1. Check existing [Issues](https://github.com/yourusername/pip-controller/issues) for similar requests
2. Create a new issue using the feature request template
3. Explain the use case and benefit of the feature

### Contributing Code
1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes
4. Test thoroughly on Windows 10/11
5. Commit with clear messages: `git commit -m "Add feature description"`
6. Push to your fork: `git push origin feature-name`
7. Create a Pull Request

## Development Setup

### Prerequisites
- Windows 10/11
- AutoHotkey v1.1+ installed
- Git for version control
- PowerShell for build scripts

### Building
### Building
```powershell
# Build everything (Installer and Portable)
.\build.ps1 -BuildAll

# Options:
# -BuildPortable    : Build only the ZIP package
# -BuildInstaller   : Build only the Setup exe
# -Clean            : Clean previous builds
```

### Testing
1. Test on multiple Windows versions
2. Verify Chrome and Edge compatibility
3. Test all transparency levels and speeds
4. Ensure system tray functionality works
5. Test settings persistence and auto-start functionality
6. Verify Status Dashboard and diagnostic tools
7. Test reset options and error recovery

## Code Style
- Use clear, descriptive variable names
- Add comments for complex logic
- Follow AutoHotkey best practices
- Test all changes thoroughly

## Pull Request Process
1. Ensure your code builds without errors
2. Update documentation if needed
3. Add tests for new features
4. Update version numbers if needed
5. Describe your changes clearly in the PR

## Questions?
Feel free to create an issue with the question label if you need help!

Thank you for contributing! 🎉
