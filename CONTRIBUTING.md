# Contributing to n8n Setup Scripts

Thank you for your interest in contributing to the n8n Setup Scripts project! This guide will help you get started with contributing to our automated installation scripts for n8n.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Guidelines](#development-guidelines)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)
- [Issue Reporting](#issue-reporting)
- [Feature Requests](#feature-requests)

## 📜 Code of Conduct

This project adheres to a code of conduct that we expect all contributors to follow. Please be respectful, inclusive, and constructive in all interactions.

### Our Standards

- Use welcoming and inclusive language
- Be respectful of differing viewpoints and experiences
- Gracefully accept constructive criticism
- Focus on what is best for the community
- Show empathy towards other community members

## 🚀 Getting Started

### Prerequisites

- **macOS**: Bash shell, basic command line knowledge
- **Windows**: PowerShell 5.1+, basic command line knowledge
- **Git**: For version control
- **Test Environment**: Access to clean macOS and/or Windows systems for testing

### Repository Structure

```
n8n-setup-scripts/
├── install-n8n-mac.sh          # Main macOS installation script
├── install-n8n-windows.ps1     # Main Windows installation script
├── uninstall-n8n-mac.sh        # macOS uninstallation script
├── uninstall-n8n-windows.ps1   # Windows uninstallation script
├── README.md                    # Project documentation
├── TROUBLESHOOTING.md           # Troubleshooting guide
├── CONTRIBUTING.md              # This file
├── LICENSE                      # MIT License
├── .gitignore                   # Git ignore rules
├── assets/                      # Project assets
│   └── images/                  # Screenshots and images
└── logs/                        # Log directory
    └── .gitkeep                 # Git placeholder
```

## 🤝 How to Contribute

### Types of Contributions

We welcome various types of contributions:

1. **Bug Fixes**: Fix issues with existing scripts
2. **Feature Enhancements**: Improve existing functionality
3. **New Features**: Add new capabilities to the scripts
4. **Documentation**: Improve README, troubleshooting guides, or comments
5. **Testing**: Help test scripts on different systems
6. **Platform Support**: Add support for new platforms or OS versions

### Getting the Code

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR-USERNAME/n8n-setup-scripts.git
   cd n8n-setup-scripts
   ```
3. **Create a branch** for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/issue-description
   ```

## 💻 Development Guidelines

### Script Development Standards

#### Shell Scripts (macOS)

```bash
#!/bin/bash
# Always use strict mode
set -e

# Use meaningful variable names
SCRIPT_VERSION="1.0.0"
LOG_FILE="$HOME/installation.log"

# Functions should be well-documented
# Function: Install required packages
install_packages() {
    local package_name="$1"
    # Implementation here
}

# Error handling
handle_error() {
    echo "Error: $1" >&2
    exit 1
}
```

#### PowerShell Scripts (Windows)

```powershell
# Use strict mode and proper error handling
#Requires -Version 5.1
$ErrorActionPreference = "Stop"

# Use approved PowerShell verbs
function Install-RequiredPackage {
    param([string]$PackageName)
    # Implementation here
}

# Proper error handling
try {
    # Code that might fail
}
catch {
    Write-Error "Failed to install: $($_.Exception.Message)"
    exit 1
}
```

### Code Standards

1. **Error Handling**: Always include comprehensive error handling
2. **Logging**: Log important steps and errors
3. **User Feedback**: Provide clear progress indicators and messages
4. **Idempotency**: Scripts should be safe to run multiple times
5. **Cross-Platform**: Consider differences between platforms
6. **Comments**: Add clear comments explaining complex logic
7. **Modularity**: Use functions for reusable code blocks

### Variable Naming

- **Constants**: `UPPER_CASE_WITH_UNDERSCORES`
- **Variables**: `lower_case_with_underscores` (Bash) or `PascalCase` (PowerShell)
- **Functions**: `verb_noun_format` (Bash) or `Verb-Noun` (PowerShell)

### Security Considerations

- Never hardcode credentials or sensitive information
- Validate all user inputs
- Use HTTPS for all downloads
- Verify checksums when possible
- Follow principle of least privilege

## 🧪 Testing

### Testing Requirements

Before submitting changes, ensure:

1. **Script Syntax**: Scripts pass syntax checks
2. **Functionality**: Core functionality works as expected
3. **Error Scenarios**: Error handling works correctly
4. **Multiple Runs**: Scripts are idempotent
5. **Clean Systems**: Test on fresh installations

### Testing Commands

**macOS:**
```bash
# Syntax check
bash -n install-n8n-mac.sh

# ShellCheck (install with: brew install shellcheck)
shellcheck install-n8n-mac.sh

# Test on clean system (recommended)
# Use a VM or container for testing
```

**Windows:**
```powershell
# Syntax check
powershell -NoProfile -NonInteractive -Command "& { . '.\install-n8n-windows.ps1'; exit 0 }"

# PSScriptAnalyzer (install with: Install-Module -Name PSScriptAnalyzer)
Invoke-ScriptAnalyzer -Path .\install-n8n-windows.ps1

# Test on clean system (recommended)
# Use a VM for testing
```

### Test Environments

We encourage testing on:

- **macOS**: 10.15+, 11.x, 12.x, 13.x, 14.x
- **Windows**: Windows 10 (1903+), Windows 11
- **Architecture**: Intel x64, ARM64 (Apple Silicon), Windows ARM64

## 📤 Submitting Changes

### Commit Guidelines

Use clear, descriptive commit messages:

```bash
# Format: type(scope): description
feat(mac): add support for Apple Silicon
fix(windows): resolve PowerShell execution policy issue
docs(readme): update installation instructions
test(scripts): add validation for Node.js installation
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `test`: Test additions or changes
- `refactor`: Code refactoring
- `style`: Code style changes
- `chore`: Maintenance tasks

### Pull Request Process

1. **Update Documentation**: Ensure README and other docs are updated
2. **Add Tests**: Include tests for new functionality
3. **Update Changelog**: Add entry describing your changes
4. **Check List**: Ensure all items in the PR template are completed

### Pull Request Template

When creating a PR, include:

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Other (describe):

## Testing
- [ ] Tested on macOS
- [ ] Tested on Windows
- [ ] Added/updated tests
- [ ] All existing tests pass

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Changes generate no new warnings
```

## 🐛 Issue Reporting

### Before Reporting

1. **Search Existing Issues**: Check if the issue already exists
2. **Check Documentation**: Review README and troubleshooting guide
3. **Test on Clean System**: Verify the issue on a fresh installation

### Issue Template

```markdown
## Bug Description
Clear description of the bug

## Environment
- OS: macOS 12.0 / Windows 11
- Architecture: Intel x64 / ARM64
- Script Version: 1.0.0
- Installation Method: curl / git clone

## Steps to Reproduce
1. Step one
2. Step two
3. Step three

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Logs
```
Paste relevant log entries here
```

## Additional Context
Any other relevant information
```

## 💡 Feature Requests

### Feature Request Template

```markdown
## Feature Description
Clear description of the proposed feature

## Use Case
Why is this feature needed?

## Proposed Solution
How should this feature work?

## Alternatives Considered
Other solutions you've considered

## Additional Context
Any other relevant information
```

## 📚 Documentation

### Documentation Standards

- Use clear, concise language
- Include code examples where helpful
- Keep documentation up-to-date with code changes
- Consider different skill levels of users

### Areas Needing Documentation

- Installation procedures
- Troubleshooting guides
- Configuration options
- Platform-specific notes
- Security considerations

## 🏷️ Release Process

### Version Management

We use [Semantic Versioning](https://semver.org/):

- **MAJOR**: Incompatible API changes
- **MINOR**: Backward-compatible functionality additions
- **PATCH**: Backward-compatible bug fixes

### Release Checklist

- [ ] All tests pass
- [ ] Documentation updated
- [ ] Changelog updated
- [ ] Version numbers updated
- [ ] GitHub release created
- [ ] Release notes written

## 🎯 Good First Issues

Looking for ways to contribute? Check issues labeled:

- `good first issue`: Perfect for newcomers
- `help wanted`: We need community help
- `documentation`: Documentation improvements needed
- `testing`: Testing help needed

## 🤔 Questions?

- **General Questions**: [GitHub Discussions](https://github.com/YOUR-USERNAME/n8n-setup-scripts/discussions)
- **Bug Reports**: [GitHub Issues](https://github.com/YOUR-USERNAME/n8n-setup-scripts/issues)
- **Security Issues**: Email [security@yourproject.com]
- **Chat**: [Discord Channel] (if available)

## 🙏 Recognition

Contributors will be recognized in:

- GitHub contributors list
- Project README
- Release notes
- Social media shoutouts (with permission)

## 📄 License

By contributing to this project, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for contributing to n8n Setup Scripts!** 🎉

Your contributions help make n8n more accessible to everyone. Whether you're fixing a small bug or adding a major feature, every contribution matters. 