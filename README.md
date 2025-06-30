# n8n Setup Scripts

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: macOS](https://img.shields.io/badge/Platform-macOS-blue)](https://www.apple.com/macos/)
[![Platform: Windows](https://img.shields.io/badge/Platform-Windows-blue)](https://www.microsoft.com/windows/)
[![n8n](https://img.shields.io/badge/n8n-Latest-orange)](https://n8n.io/)

**One-command n8n installation scripts for macOS and Windows that handle everything automatically.**

Perfect for students, educators, and anyone who needs n8n running quickly without technical setup hassles.

## 🚀 Quick Install

### macOS
```bash
curl -fsSL https://raw.githubusercontent.com/vsrinivasan-uno/n8n-setup-scripts/main/install-n8n-mac.sh | bash
```

### Windows (PowerShell as Administrator)
```powershell
irm https://raw.githubusercontent.com/vsrinivasan-uno/n8n-setup-scripts/main/install-n8n-windows.ps1 | iex
```

## 📋 What Gets Installed

- **Node.js LTS** (v18.x or v20.x)
- **n8n** (latest stable version)
- **Package Managers** (Homebrew for macOS, Chocolatey for Windows)
- **SQLite Database** (default n8n database)
- **Firewall Rules** (Windows only)
- **Startup Scripts** for easy n8n management

## 📖 Alternative Installation Methods

### Git Clone Method

**macOS:**
```bash
git clone https://github.com/vsrinivasan-uno/n8n-setup-scripts.git
cd n8n-setup-scripts
chmod +x install-n8n-mac.sh
./install-n8n-mac.sh
```

**Windows:**
```powershell
git clone https://github.com/vsrinivasan-uno/n8n-setup-scripts.git
cd n8n-setup-scripts
powershell -ExecutionPolicy Bypass -File .\install-n8n-windows.ps1
```

### Manual Download

1. Download the appropriate script for your platform
2. Run the script with execution permissions

## 📊 System Requirements

| Requirement | macOS | Windows |
|-------------|-------|---------|
| **OS Version** | macOS 10.15+ (Catalina) | Windows 10+ |
| **RAM** | 4GB minimum (recommended) | 4GB minimum (recommended) |
| **Disk Space** | 2GB free space | 2GB free space |
| **Internet** | Required for downloads | Required for downloads |
| **PowerShell** | N/A | 5.1+ |

## ⚡ What Happens During Installation

1. **System Check** - Validates OS version, disk space, RAM, and internet connectivity
2. **Package Manager Setup** - Installs Homebrew (macOS) or Chocolatey (Windows)
3. **Node.js Installation** - Downloads and installs Node.js LTS
4. **n8n Installation** - Installs n8n globally via npm
5. **Configuration** - Sets up n8n folder, environment variables, and startup scripts
6. **Server Launch** - Starts n8n and opens it in your browser

## 🎯 After Installation

Once installation completes successfully:

- **Access n8n**: Open http://localhost:5678 in your browser
- **n8n will auto-open** in your default browser
- **Data Location**: 
  - macOS: `~/.n8n`
  - Windows: `%USERPROFILE%\.n8n`

### Starting n8n Later

**macOS:**
```bash
~/start-n8n.sh
```

**Windows (Command Prompt):**
```cmd
%USERPROFILE%\start-n8n.bat
```

**Windows (PowerShell):**
```powershell
& "$env:USERPROFILE\start-n8n.ps1"
```

### Stopping n8n

**macOS:**
```bash
killall node
```

**Windows:**
```powershell
Stop-Process -Name node
```

## 🗑️ Uninstallation

### macOS
```bash
curl -fsSL https://raw.githubusercontent.com/vsrinivasan-uno/n8n-setup-scripts/main/uninstall-n8n-mac.sh | bash
```

### Windows
```powershell
irm https://raw.githubusercontent.com/vsrinivasan-uno/n8n-setup-scripts/main/uninstall-n8n-windows.ps1 | iex
```

The uninstaller will:
- Stop any running n8n processes
- Remove the n8n package
- Optionally remove user data (you'll be prompted)
- Optionally remove Node.js and package managers (you'll be prompted)

## 🔧 Advanced Usage

### Custom Port Installation

**macOS:**
```bash
export N8N_PORT=3000
curl -fsSL https://raw.githubusercontent.com/vsrinivasan-uno/n8n-setup-scripts/main/install-n8n-mac.sh | bash
```

**Windows:**
```powershell
$env:N8N_PORT = "3000"; irm https://raw.githubusercontent.com/vsrinivasan-uno/n8n-setup-scripts/main/install-n8n-windows.ps1 | iex
```

### Silent Installation (Windows)

```powershell
# Download and run with no user interaction
irm https://raw.githubusercontent.com/vsrinivasan-uno/n8n-setup-scripts/main/install-n8n-windows.ps1 | iex -c "Start-Installation -NoInteraction"
```

### Keep Data During Uninstall

**Windows:**
```powershell
.\uninstall-n8n-windows.ps1 -KeepData
```

## 🏗️ For Developers

### Script Parameters

**Windows PowerShell Script Parameters:**

| Parameter | Description | Default |
|-----------|-------------|---------|
| `-Port` | Custom port for n8n | `5678` |
| `-SkipUpdates` | Skip checking for script updates | `false` |
| `-NoInteraction` | Run without user prompts | `false` |

**Windows Uninstaller Parameters:**

| Parameter | Description | Default |
|-----------|-------------|---------|
| `-NoInteraction` | Run without user prompts | `false` |
| `-KeepData` | Keep n8n data and configuration | `false` |

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `N8N_PORT` | Port for n8n server | `5678` |
| `N8N_USER_FOLDER` | n8n data directory | `~/.n8n` |

## 📁 File Locations

### macOS
- **n8n Data**: `~/.n8n/`
- **Startup Script**: `~/start-n8n.sh`
- **Install Log**: `~/n8n-install.log`
- **Uninstall Log**: `~/n8n-uninstall.log`
- **Environment**: `~/.zprofile`

### Windows
- **n8n Data**: `%USERPROFILE%\.n8n\`
- **Startup Scripts**: 
  - `%USERPROFILE%\start-n8n.bat`
  - `%USERPROFILE%\start-n8n.ps1`
- **Install Log**: `%USERPROFILE%\n8n-install.log`
- **Uninstall Log**: `%USERPROFILE%\n8n-uninstall.log`
- **Environment**: System Environment Variables

## 🚨 Troubleshooting

### Common Issues

**"Permission Denied" (macOS)**
```bash
chmod +x install-n8n-mac.sh
./install-n8n-mac.sh
```

**"Execution Policy" Error (Windows)**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Port Already in Use**
- Check if another application is using port 5678
- Use a custom port: `export N8N_PORT=3000` (macOS) or `$env:N8N_PORT="3000"` (Windows)

**n8n Won't Start**
1. Check the logs: `~/.n8n/n8n.log` (macOS) or `%USERPROFILE%\.n8n\n8n.log` (Windows)
2. Verify Node.js installation: `node --version`
3. Verify n8n installation: `n8n --version`

For more detailed troubleshooting, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

## ❓ FAQ

### Q: Can I install n8n on a different port?
**A:** Yes! Set the `N8N_PORT` environment variable before running the installer.

### Q: Will this interfere with existing Node.js installations?
**A:** The script checks for existing Node.js and only installs if needed or if the version is too old.

### Q: Can I run this script multiple times?
**A:** Yes! The scripts are idempotent and safe to run multiple times.

### Q: How do I update n8n later?
**A:** Run the installation script again - it will upgrade n8n to the latest version.

### Q: What if I don't want to install Homebrew/Chocolatey?
**A:** These package managers are required for the automated installation. You can install n8n manually if you prefer.

## ❤️ Credits and Author

This project was built by **Vishva Prasanth Srinivasan** | AI-CCORE.

- **LinkedIn:** [https://www.linkedin.com/in/vishvaprasanth/](https://www.linkedin.com/in/vishvaprasanth/)
- **GitHub:** [https://github.com/vsrinivasan-uno](https://github.com/vsrinivasan-uno)

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Issues and Feature Requests

- **Bug Reports**: [Create an issue](https://github.com/vsrinivasan-uno/n8n-setup-scripts/issues)
- **Feature Requests**: [Create an issue](https://github.com/vsrinivasan-uno/n8n-setup-scripts/issues)
- **Questions**: [Start a discussion](https://github.com/vsrinivasan-uno/n8n-setup-scripts/discussions)

## 📚 Resources

- **n8n Documentation**: https://docs.n8n.io
- **n8n Community**: https://community.n8n.io
- **n8n GitHub**: https://github.com/n8n-io/n8n
- **Node.js**: https://nodejs.org
- **Homebrew**: https://brew.sh
- **Chocolatey**: https://chocolatey.org

## 🔒 Security

This script downloads and executes code from the internet. Please review the scripts before running them in production environments.

- Scripts are hosted on GitHub and can be audited
- All downloads use HTTPS
- Package managers verify checksums automatically
- See [SECURITY.md](SECURITY.md) for security policy

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🌟 Support

If this project helped you, please consider:
- ⭐ Starring this repository
- 🐛 Reporting bugs
- 💡 Suggesting improvements
- 📢 Sharing with others

## 📈 Project Status

- ✅ **macOS Support**: Full automation
- ✅ **Windows Support**: Full automation  
- ✅ **Uninstallation**: Complete removal scripts
- ✅ **Documentation**: Comprehensive guides
- 🔄 **Maintenance**: Active development

---

**Made with ❤️ for the n8n community**

*"Automate everything, including the automation setup!"* 