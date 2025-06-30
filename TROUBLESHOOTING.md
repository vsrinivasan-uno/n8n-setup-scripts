# Troubleshooting Guide

This guide helps you resolve common issues with the n8n setup scripts.

## 🔍 Quick Diagnosis

### Check Installation Status

**macOS:**
```bash
# Check if n8n is installed
which n8n

# Check n8n version
n8n --version

# Check if n8n is running
pgrep -f n8n

# Check installation log
tail -f ~/n8n-install.log
```

**Windows:**
```powershell
# Check if n8n is installed
Get-Command n8n -ErrorAction SilentlyContinue

# Check n8n version
n8n --version

# Check if n8n is running
Get-Process -Name node -ErrorAction SilentlyContinue

# Check installation log
Get-Content "$env:USERPROFILE\n8n-install.log" -Tail 20
```

## 🚨 Common Issues

### 1. Permission Errors

#### macOS: "Permission denied"

**Symptoms:**
```
bash: ./install-n8n-mac.sh: Permission denied
```

**Solutions:**
```bash
# Make script executable
chmod +x install-n8n-mac.sh

# Run with bash explicitly
bash install-n8n-mac.sh

# Check file permissions
ls -la install-n8n-mac.sh
```

#### Windows: "Execution policy" Error

**Symptoms:**
```
execution of scripts is disabled on this system
```

**Solutions:**
```powershell
# Set execution policy for current user
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Temporarily bypass execution policy
powershell -ExecutionPolicy Bypass -File .\install-n8n-windows.ps1

# Check current execution policy
Get-ExecutionPolicy -List
```

### 2. Network and Download Issues

#### "Cannot connect" or "Download failed"

**Symptoms:**
- Timeouts during package downloads
- SSL/TLS certificate errors
- DNS resolution failures

**Solutions:**

**macOS:**
```bash
# Test internet connectivity
ping -c 3 google.com

# Test specific domains
curl -I https://raw.githubusercontent.com
curl -I https://api.github.com

# Check DNS resolution
nslookup github.com

# Reset DNS cache
sudo dscacheutil -flushcache
```

**Windows:**
```powershell
# Test internet connectivity
Test-Connection google.com -Count 3

# Test specific domains
Invoke-WebRequest -Uri https://raw.githubusercontent.com -Method Head
Invoke-WebRequest -Uri https://api.github.com -Method Head

# Check DNS resolution
Resolve-DnsName github.com

# Reset DNS cache
ipconfig /flushdns
```

#### Corporate Firewall/Proxy Issues

**Solutions:**
```bash
# macOS: Set proxy for curl
export https_proxy=http://proxy.company.com:8080
export http_proxy=http://proxy.company.com:8080

# Configure git proxy
git config --global http.proxy http://proxy.company.com:8080
git config --global https.proxy http://proxy.company.com:8080
```

```powershell
# Windows: Set proxy
$env:https_proxy = "http://proxy.company.com:8080"
$env:http_proxy = "http://proxy.company.com:8080"

# Configure npm proxy
npm config set proxy http://proxy.company.com:8080
npm config set https-proxy http://proxy.company.com:8080
```

### 3. Package Manager Issues

#### Homebrew Installation Failed (macOS)

**Symptoms:**
```
Failed to install Homebrew
curl: (7) Failed to connect to raw.githubusercontent.com
```

**Solutions:**
```bash
# Manual Homebrew installation
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Check Homebrew installation
brew --version

# Update Homebrew
brew update

# Fix Homebrew permissions
sudo chown -R $(whoami) /usr/local/Homebrew
```

#### Chocolatey Installation Failed (Windows)

**Symptoms:**
```
Failed to install Chocolatey
Access to the path is denied
```

**Solutions:**
```powershell
# Run PowerShell as Administrator
# Then try manual installation:
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Check Chocolatey installation
choco --version

# Update Chocolatey
choco upgrade chocolatey
```

### 4. Node.js Issues

#### Node.js Version Conflict

**Symptoms:**
```
Node.js version v16.x.x is too old
npm WARN deprecated
```

**Solutions:**

**macOS:**
```bash
# Check current Node.js version
node --version

# Uninstall old Node.js via Homebrew
brew uninstall node
brew uninstall node@16

# Install latest LTS
brew install node@20

# Update PATH
echo 'export PATH="/opt/homebrew/opt/node@20/bin:$PATH"' >> ~/.zprofile
source ~/.zprofile
```

**Windows:**
```powershell
# Check current Node.js version
node --version

# Uninstall via Chocolatey
choco uninstall nodejs
choco uninstall nodejs-lts

# Install latest LTS
choco install nodejs-lts

# Refresh environment
refreshenv
```

#### npm Permission Issues

**macOS:**
```bash
# Fix npm permissions
sudo chown -R $(whoami) $(npm config get prefix)/{lib/node_modules,bin,share}

# Use npm prefix in home directory
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.zprofile
source ~/.zprofile
```

**Windows:**
```powershell
# Run as Administrator and reinstall npm
npm install -g npm@latest

# Clear npm cache
npm cache clean --force
```

### 5. n8n Installation Issues

#### n8n Installation Failed

**Symptoms:**
```
npm ERR! code EACCES
npm ERR! syscall access
Failed to install n8n
```

**Solutions:**

**macOS:**
```bash
# Try with sudo (not recommended for production)
sudo npm install -g n8n

# Better: Fix npm permissions first, then reinstall
npm config set prefix ~/.npm-global
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.zprofile
source ~/.zprofile
npm install -g n8n
```

**Windows:**
```powershell
# Run PowerShell as Administrator
npm install -g n8n

# Alternative: Use yarn
npm install -g yarn
yarn global add n8n
```

#### n8n Command Not Found

**Symptoms:**
```
command not found: n8n
'n8n' is not recognized as an internal or external command
```

**Solutions:**

**macOS:**
```bash
# Check if n8n is in npm global packages
npm list -g --depth=0 | grep n8n

# Find n8n location
find /usr/local -name "n8n" 2>/dev/null
find ~/.npm-global -name "n8n" 2>/dev/null

# Add to PATH
echo 'export PATH="~/.npm-global/bin:$PATH"' >> ~/.zprofile
source ~/.zprofile

# Reinstall if necessary
npm install -g n8n
```

**Windows:**
```powershell
# Check npm global packages
npm list -g --depth=0

# Check PATH
$env:PATH -split ';' | Where-Object { $_ -like "*npm*" }

# Refresh environment variables
refreshenv

# Reinstall if necessary
npm install -g n8n
```

### 6. n8n Runtime Issues

#### n8n Won't Start

**Symptoms:**
```
Error: listen EADDRINUSE :::5678
Cannot start n8n server
```

**Solutions:**

**Check what's using the port:**

**macOS:**
```bash
# Check what's using port 5678
lsof -i :5678

# Kill process using the port
sudo lsof -t -i:5678 | xargs kill -9

# Use different port
export N8N_PORT=3000
n8n start
```

**Windows:**
```powershell
# Check what's using port 5678
netstat -ano | findstr 5678

# Kill process using the port (replace PID with actual process ID)
taskkill /PID <PID> /F

# Use different port
$env:N8N_PORT = "3000"
n8n start
```

#### n8n Database Issues

**Symptoms:**
```
Database connection failed
SQLite error: database is locked
```

**Solutions:**
```bash
# macOS/Windows: Stop all n8n processes
killall node  # macOS
Stop-Process -Name node  # Windows

# Remove lock file
rm ~/.n8n/database.sqlite-wal  # macOS
Remove-Item "$env:USERPROFILE\.n8n\database.sqlite-wal"  # Windows

# Restart n8n
n8n start
```

### 7. Browser and Access Issues

#### Browser Doesn't Open

**Solutions:**

**macOS:**
```bash
# Manually open browser
open http://localhost:5678

# Check if n8n is actually running
curl http://localhost:5678
```

**Windows:**
```powershell
# Manually open browser
Start-Process "http://localhost:5678"

# Check if n8n is actually running
Invoke-WebRequest http://localhost:5678
```

#### "This site can't be reached"

**Solutions:**
1. Verify n8n is running: `pgrep -f n8n` (macOS) or `Get-Process -Name node` (Windows)
2. Check the correct port: `echo $N8N_PORT` (macOS) or `echo $env:N8N_PORT` (Windows)
3. Check firewall settings
4. Try accessing `http://127.0.0.1:5678` instead of `localhost`

### 8. Environment and Configuration Issues

#### Environment Variables Not Set

**macOS:**
```bash
# Check current environment
echo $N8N_USER_FOLDER
echo $N8N_PORT

# Set manually
export N8N_USER_FOLDER="$HOME/.n8n"
export N8N_PORT="5678"

# Make permanent
echo 'export N8N_USER_FOLDER="$HOME/.n8n"' >> ~/.zprofile
echo 'export N8N_PORT="5678"' >> ~/.zprofile
source ~/.zprofile
```

**Windows:**
```powershell
# Check current environment
$env:N8N_USER_FOLDER
$env:N8N_PORT

# Set for current session
$env:N8N_USER_FOLDER = "$env:USERPROFILE\.n8n"
$env:N8N_PORT = "5678"

# Set permanently
[Environment]::SetEnvironmentVariable("N8N_USER_FOLDER", "$env:USERPROFILE\.n8n", "User")
[Environment]::SetEnvironmentVariable("N8N_PORT", "5678", "User")
```

## 🔧 Advanced Debugging

### Enable Verbose Logging

**macOS:**
```bash
# Run with debug output
DEBUG=* n8n start

# Or specific debug categories
DEBUG=n8n* n8n start
```

**Windows:**
```powershell
# Run with debug output
$env:DEBUG = "*"
n8n start

# Or specific debug categories
$env:DEBUG = "n8n*"
n8n start
```

### Check System Resources

**macOS:**
```bash
# Check memory usage
top -l 1 | grep PhysMem

# Check disk space
df -h

# Check CPU usage
top -l 1 | grep "CPU usage"
```

**Windows:**
```powershell
# Check memory usage
Get-WmiObject -Class Win32_OperatingSystem | Select-Object TotalVisibleMemorySize, FreePhysicalMemory

# Check disk space
Get-WmiObject -Class Win32_LogicalDisk | Select-Object DeviceID, Size, FreeSpace

# Check CPU usage
Get-WmiObject -Class Win32_Processor | Select-Object LoadPercentage
```

## 🏥 Recovery Procedures

### Complete Reset

If nothing else works, try a complete reset:

**macOS:**
```bash
# Stop all n8n processes
killall node

# Remove n8n data
rm -rf ~/.n8n

# Uninstall n8n
npm uninstall -g n8n

# Clear npm cache
npm cache clean --force

# Reinstall
npm install -g n8n

# Start fresh
n8n start
```

**Windows:**
```powershell
# Stop all n8n processes
Stop-Process -Name node -Force

# Remove n8n data
Remove-Item -Recurse -Force "$env:USERPROFILE\.n8n"

# Uninstall n8n
npm uninstall -g n8n

# Clear npm cache
npm cache clean --force

# Reinstall
npm install -g n8n

# Start fresh
n8n start
```

### Backup and Restore

**Before making changes, backup your data:**

**macOS:**
```bash
# Backup n8n data
cp -r ~/.n8n ~/.n8n.backup

# Restore if needed
rm -rf ~/.n8n
mv ~/.n8n.backup ~/.n8n
```

**Windows:**
```powershell
# Backup n8n data
Copy-Item -Recurse "$env:USERPROFILE\.n8n" "$env:USERPROFILE\.n8n.backup"

# Restore if needed
Remove-Item -Recurse "$env:USERPROFILE\.n8n"
Move-Item "$env:USERPROFILE\.n8n.backup" "$env:USERPROFILE\.n8n"
```

## 📞 Getting Help

### Gather Information for Support

When asking for help, please provide:

1. **Operating System**: `uname -a` (macOS) or `Get-ComputerInfo` (Windows)
2. **Script Version**: Check the version in the script files
3. **Error Messages**: Copy exact error messages
4. **Log Files**: Include relevant log entries
5. **Installation Method**: Direct curl/download or git clone

### Useful Commands for Diagnostics

**macOS:**
```bash
# System information
system_profiler SPSoftwareDataType
sw_vers

# Node.js information
node --version
npm --version
which node
which npm

# n8n information
n8n --version
which n8n

# Environment
env | grep -i n8n
echo $PATH
```

**Windows:**
```powershell
# System information
Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion
$PSVersionTable

# Node.js information
node --version
npm --version
Get-Command node
Get-Command npm

# n8n information
n8n --version
Get-Command n8n

# Environment
Get-ChildItem Env: | Where-Object {$_.Name -like "*N8N*"}
$env:PATH -split ';'
```

### Community Resources

- **n8n Community Forum**: https://community.n8n.io
- **GitHub Issues**: https://github.com/vsrinivasan-uno/n8n-setup-scripts/issues
- **Discord**: https://discord.gg/n8n
- **Documentation**: https://docs.n8n.io

### Professional Support

For enterprise environments or critical issues:
- Consider n8n Cloud: https://n8n.io/cloud/
- Professional services: https://n8n.io/pricing/

## 📚 Prevention Tips

1. **Regular Updates**: Keep your system and packages updated
2. **Backup Data**: Regular backups of your `.n8n` folder
3. **Environment Consistency**: Use the same Node.js version across environments
4. **Resource Monitoring**: Monitor disk space and memory usage
5. **Security**: Keep your system and n8n updated for security patches

---

**Still having issues?** Create an issue on GitHub with the information gathering steps above, and we'll help you resolve it! 