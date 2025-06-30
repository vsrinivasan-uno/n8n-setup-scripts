#Requires -Version 5.1

<#
.SYNOPSIS
    Automated n8n Installation Script for Windows
.DESCRIPTION
    One-command installation script for n8n workflow automation platform on Windows systems
.PARAMETER Port
    Port number for n8n server (default: 5678)
.PARAMETER NoInteraction
    Run script without user prompts
#>

param(
    [int]$Port = 5678,
    [switch]$NoInteraction = $false
)

# Configuration
$ScriptVersion = "1.0.1"
$MinNodeVersion = 18
$RequiredDiskSpaceGB = 2
$RequiredRAMGB = 4
$GitHubUser = "vsrinivasan-uno"
$GitHubRepo = "n8n-setup-scripts"
$N8nUserFolder = "$env:USERPROFILE\.n8n"
$LogFile = "$env:TEMP\n8n-installation.log"

# Color configuration
$Colors = @{
    Red = "Red"
    Green = "Green"
    Yellow = "Yellow"
    Cyan = "Cyan"
    Magenta = "Magenta"
    White = "White"
}

# Logging function
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $LogFile -Append -Encoding UTF8
}

# Print functions with colors
function Write-Step {
    param([string]$Step, [string]$Message)
    Write-Host "[$Step] $Message" -ForegroundColor $Colors.Cyan
    Write-Log "[$Step] $Message"
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor $Colors.Green
    Write-Log "SUCCESS: $Message"
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor $Colors.Yellow
    Write-Log "WARNING: $Message"
}

function Write-Error {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor $Colors.Red
    Write-Log "ERROR: $Message"
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" -ForegroundColor $Colors.White
    Write-Log "INFO: $Message"
}

# Error handling function
function Handle-Error {
    param([string]$Message)
    Write-Error $Message
    Write-Host "Installation failed. Check log at: $LogFile" -ForegroundColor $Colors.Red
    exit 1
}

# Check for script updates
function Test-ScriptUpdates {
    Write-Info "Checking for script updates..."
    
    try {
        $uri = "https://api.github.com/repos/$GitHubUser/$GitHubRepo/releases/latest"
        $latestVersion = (Invoke-RestMethod -Uri $uri -ErrorAction SilentlyContinue).tag_name
        
        if ($latestVersion -and $latestVersion -ne $ScriptVersion) {
            Write-Warning "A newer version ($latestVersion) is available at https://github.com/$GitHubUser/$GitHubRepo"
            if (-not $NoInteraction) {
                $continue = Read-Host "Continue with current version? (y/N)"
                if ($continue -notmatch '^[Yy]$') {
                    exit 0
                }
            }
        }
    }
    catch {
        Write-Info "Could not check for updates."
    }
}

# System requirements check
function Test-SystemRequirements {
    Write-Step "1/6" "Checking system requirements"
    
    # Check Windows version
    $osVersion = [System.Environment]::OSVersion.Version
    if ($osVersion.Major -lt 10) {
        Handle-Error "Windows 10 or later is required."
    }
    
    # Check PowerShell version
    $psVersion = $PSVersionTable.PSVersion
    if ($psVersion.Major -lt 5) {
        Handle-Error "PowerShell 5.1 or later is required."
    }
    
    # Check disk space
    $systemDrive = $env:SystemDrive
    $disk = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='$systemDrive'"
    $availableSpaceGB = [math]::Round($disk.FreeSpace / 1GB, 2)
    
    if ($availableSpaceGB -lt $RequiredDiskSpaceGB) {
        Handle-Error "Insufficient disk space."
    }
    
    # Check RAM
    $totalRamGB = [math]::Round((Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
    if ($totalRamGB -lt $RequiredRAMGB) {
        Handle-Error "Insufficient RAM."
    }
    
    # Check internet connectivity
    if (-not (Test-NetConnection -ComputerName "google.com" -Port 80 -InformationLevel Quiet -ErrorAction SilentlyContinue)) {
        Write-Warning "Could not verify internet connection."
    }
    
    Write-Success "System requirements check passed."
}

# Install Chocolatey
function Install-Chocolatey {
    Write-Step "2/6" "Checking Chocolatey package manager"
    
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Success "Chocolatey is already installed."
    }
    else {
        Write-Info "Installing Chocolatey..."
        try {
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
            Write-Success "Chocolatey installed successfully."
        }
        catch {
            Handle-Error "Failed to install Chocolatey: $($_.Exception.Message)"
        }
    }
}

# Install Node.js
function Install-NodeJS {
    Write-Step "3/6" "Checking Node.js"
    
    # Check if Node.js is already installed
    if (Get-Command node -ErrorAction SilentlyContinue) {
        $currentVersion = (node --version) -replace '^v', ''
        $currentMajor = [int]($currentVersion.Split('.')[0])
        
        if ($currentMajor -ge $MinNodeVersion) {
            Write-Success "Node.js v$currentVersion is already installed."
            return
        }
        else {
            Write-Warning "Node.js version v$currentVersion is too old. Upgrading..."
        }
    }
    
    Write-Info "Installing Node.js LTS via Chocolatey..."
    try {
        choco install nodejs-lts -y --force | Out-Null
        
        # Refresh environment variables
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        
        # Verify installation
        if (Get-Command node -ErrorAction SilentlyContinue) {
            $nodeVersion = node --version
            $npmVersion = npm --version
            Write-Success "Node.js $nodeVersion installed successfully"
            Write-Success "npm v$npmVersion available"
        }
        else {
            Handle-Error "Node.js installation failed."
        }
    }
    catch {
        Handle-Error "Failed to install Node.js: $($_.Exception.Message)"
    }
}

# Install n8n
function Install-N8n {
    Write-Step "4/6" "Installing n8n"
    try {
        if (Get-Command n8n -ErrorAction SilentlyContinue) {
            $currentVersion = (n8n --version 2>$null) -replace '^v', '' -replace '\s', ''
            $latestVersion = (npm view n8n version 2>$null) -replace '^v', '' -replace '\s', ''
            if ($currentVersion -eq $latestVersion) {
                Write-Success "n8n is already up to date (Version $currentVersion)."
                return
            }
            else {
                Write-Warning "n8n (v$currentVersion) is outdated. Upgrading to latest (v$latestVersion)..."
                npm install -g n8n@latest | Out-Null
            }
        } else {
            Write-Info "Installing n8n globally via npm..."
            npm install -g n8n | Out-Null
        }
        if (Get-Command n8n -ErrorAction SilentlyContinue) {
            $n8nVersion = (n8n --version 2>$null)
            Write-Success "n8n $($n8nVersion) installed successfully."
        } else { Handle-Error "n8n installation failed." }
    } catch { Handle-Error "Failed to install n8n: $($_.Exception.Message)" }
}

# Configure n8n
function Set-N8nConfiguration {
    Write-Step "5/6" "Configuring n8n"
    
    # Create n8n directory
    if (-not (Test-Path $N8nUserFolder)) {
        New-Item -ItemType Directory -Path $N8nUserFolder -Force | Out-Null
    }
    Write-Success "Created n8n user folder: $N8nUserFolder"
    
    # Set environment variables
    [Environment]::SetEnvironmentVariable("N8N_USER_FOLDER", $N8nUserFolder, "User")
    [Environment]::SetEnvironmentVariable("N8N_PORT", $Port, "User")
    $env:N8N_USER_FOLDER = $N8nUserFolder
    $env:N8N_PORT = $Port
    
    # Create basic configuration
    $configContent = "# n8n Configuration`nN8N_USER_FOLDER=$N8nUserFolder`nN8N_PORT=$Port`nN8N_PROTOCOL=http`nN8N_HOST=localhost"
    
    $configPath = Join-Path $N8nUserFolder "config"
    $configContent | Out-File -FilePath $configPath -Encoding UTF8
    Write-Success "n8n configuration completed"
    
    # Create startup script
    $startupScript = "@echo off`necho Starting n8n...`nn8n start`npause"
    
    $startupPath = "$env:USERPROFILE\start-n8n.bat"
    $startupScript | Out-File -FilePath $startupPath -Encoding ASCII
    Write-Success "Created startup script: $startupPath"
    
    # Create PowerShell startup script
    $psStartupScript = "# n8n Startup Script`nWrite-Host `"Starting n8n...`" -ForegroundColor Green`n`$env:N8N_USER_FOLDER = `"$N8nUserFolder`"`n`$env:N8N_PORT = `"$Port`"`nn8n start"
    
    $psStartupPath = "$env:USERPROFILE\start-n8n.ps1"
    $psStartupScript | Out-File -FilePath $psStartupPath -Encoding UTF8
    Write-Success "Created PowerShell startup script: $psStartupPath"
}

# Configure Windows Firewall
function Set-FirewallRules {
    Write-Info "Configuring Windows Firewall..."
    
    try {
        # Check if rule already exists
        $existingRule = Get-NetFirewallRule -DisplayName "n8n" -ErrorAction SilentlyContinue
        
        if ($existingRule) {
            Write-Success "Firewall rule for n8n already exists"
        }
        else {
            # Create firewall rule for n8n
            New-NetFirewallRule -DisplayName "n8n" -Direction Inbound -Protocol TCP -LocalPort $Port -Action Allow | Out-Null
            Write-Success "Added firewall rule for n8n on port $Port"
        }
    }
    catch {
        Write-Warning "Could not configure firewall automatically. You may need to allow n8n through Windows Firewall manually."
    }
}

# Start n8n server
function Start-N8nServer {
    Write-Step "6/6" "Starting n8n server"
    
    # Configure firewall
    Set-FirewallRules
    
    Write-Info "Starting n8n on http://localhost:$Port. This may take a moment..."
    $logPath = Join-Path $N8nUserFolder "n8n.log"
    Start-Job -ScriptBlock { 
        param($UserFolder, $Port)
        $env:N8N_USER_FOLDER = $UserFolder; $env:N8N_PORT = $Port
        n8n start 2>&1 | Tee-Object -FilePath $using:logPath -Append
    } -ArgumentList $N8nUserFolder, $Port

    $maxAttempts = 30; $attempt = 0
    do {
        Start-Sleep -Seconds 2; $attempt++; Write-Host "." -NoNewline
        try {
            if ((Invoke-WebRequest -Uri "http://localhost:$Port" -UseBasicParsing -TimeoutSec 2).StatusCode -eq 200) { break }
        } catch { }
    } while ($attempt -lt $maxAttempts)
    Write-Host ""

    if ($attempt -lt $maxAttempts) {
        Write-Success "n8n server started successfully!"
        Write-Info "Opening n8n in your default browser..."
        Start-Process "http://localhost:$Port"
        Write-Host "`n🎉 Installation Complete! 🎉`n" -ForegroundColor Green
        Write-Host "Access n8n at: http://localhost:$Port" -ForegroundColor Cyan
    } else {
        Handle-Error "n8n failed to start. Check logs at: $logPath"
    }
}

# Cleanup function
function Invoke-Cleanup {
    Write-Info "Cleaning up temporary files..."
    # Add any cleanup logic here
}

# Main installation function
function Start-Installation {
    # Setup
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║            n8n Automated Installer for Windows             ║" -ForegroundColor Magenta
    Write-Host "║                       Version $ScriptVersion                       ║" -ForegroundColor Magenta
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "Built by Vishva Prasanth Srinivasan | AI-CCORE" -ForegroundColor "Gray"
    Write-Host "LinkedIn: https://www.linkedin.com/in/vishvaprasanth/" -ForegroundColor "Gray"
    Write-Host ""
    
    # Create log file
    "n8n Installation Log - $(Get-Date)" | Out-File -FilePath $LogFile -Encoding UTF8
    Write-Info "Installation log will be saved to $LogFile"
    Write-Host ""
    
    # Check for updates
    Test-ScriptUpdates
    
    # Run installation steps
    Test-SystemRequirements
    Install-Chocolatey
    Install-NodeJS
    Install-N8n
    Set-N8nConfiguration
    Start-N8nServer
    
    # Cleanup
    Invoke-Cleanup
}

# --- Execution Logic ---

trap {
    Write-Error "Script interrupted: $($_.Exception.Message)"
    exit 1
}

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")
if (-not $isAdmin) {
    Write-Error "This script requires Administrator privileges."
    Write-Info "Please re-run this script from a PowerShell terminal with 'Run as Administrator'."
    # Pause for 5 seconds to allow user to read the message.
    Start-Sleep -Seconds 5
    exit 1
}

# All checks passed, starting the installation.
Start-Installation 