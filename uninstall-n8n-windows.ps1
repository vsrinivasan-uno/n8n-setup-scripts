# n8n Uninstallation Script for Windows
# Version: 1.0.0
# Author: n8n Setup Scripts
# License: MIT
# Requires: PowerShell 5.1 or later

#Requires -Version 5.1

param(
    [switch]$NoInteraction,
    [switch]$KeepData
)

# Script configuration
$ScriptVersion = "1.0.0"
$LogFile = "$env:USERPROFILE\n8n-uninstall.log"
$N8nUserFolder = "$env:USERPROFILE\.n8n"

# Color configuration
$Colors = @{
    Red = "Red"
    Green = "Green"
    Yellow = "Yellow"
    Blue = "Blue"
    Purple = "Magenta"
    Cyan = "Cyan"
    White = "White"
}

# Logging function
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $LogFile -Append -Encoding UTF8
    Write-Host $Message
}

# Print functions with colors
function Write-Step {
    param([string]$Step, [string]$Message)
    Write-Host "[$Step] $Message" -ForegroundColor $Colors.Blue
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
    Write-Host "ℹ $Message" -ForegroundColor $Colors.Cyan
    Write-Log "INFO: $Message"
}

# Stop n8n processes
function Stop-N8nProcesses {
    Write-Step "1/5" "Stopping n8n processes..."
    
    $n8nProcesses = Get-Process -Name "node" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like "*n8n*" }
    
    if ($n8nProcesses) {
        Write-Info "Stopping n8n processes..."
        $n8nProcesses | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        Write-Success "n8n processes stopped"
    }
    else {
        Write-Info "No running n8n processes found"
    }
    
    # Also stop any remaining node processes that might be n8n
    $allNodeProcesses = Get-Process -Name "node" -ErrorAction SilentlyContinue
    if ($allNodeProcesses) {
        foreach ($process in $allNodeProcesses) {
            try {
                $commandLine = (Get-WmiObject Win32_Process -Filter "ProcessId = $($process.Id)").CommandLine
                if ($commandLine -like "*n8n*") {
                    $process | Stop-Process -Force -ErrorAction SilentlyContinue
                    Write-Info "Stopped n8n process: $($process.Id)"
                }
            }
            catch {
                # Ignore errors when checking command line
            }
        }
    }
}

# Remove n8n package
function Remove-N8nPackage {
    Write-Step "2/5" "Removing n8n package..."
    
    if (Get-Command n8n -ErrorAction SilentlyContinue) {
        Write-Info "Uninstalling n8n globally..."
        try {
            npm uninstall -g n8n | Out-Null
            Write-Success "n8n package removed"
        }
        catch {
            Write-Warning "Failed to uninstall n8n via npm: $($_.Exception.Message)"
        }
    }
    else {
        Write-Info "n8n package not found"
    }
}

# Remove n8n data and configuration
function Remove-N8nData {
    Write-Step "3/5" "Removing n8n data and configuration..."
    
    if ($KeepData) {
        Write-Warning "Keeping n8n data and configuration (--KeepData flag specified)"
        return
    }
    
    Write-Warning "This will remove all your n8n workflows, credentials, and settings."
    
    $removeData = $true
    if (-not $NoInteraction) {
        $response = Read-Host "Do you want to remove n8n data? (y/N)"
        $removeData = $response -match '^[Yy]$'
    }
    
    if ($removeData) {
        if (Test-Path $N8nUserFolder) {
            Write-Info "Removing n8n user folder: $N8nUserFolder"
            try {
                Remove-Item -Path $N8nUserFolder -Recurse -Force
                Write-Success "n8n data removed"
            }
            catch {
                Write-Warning "Failed to remove n8n data folder: $($_.Exception.Message)"
            }
        }
        else {
            Write-Info "n8n user folder not found"
        }
        
        # Remove startup scripts
        $startupScripts = @(
            "$env:USERPROFILE\start-n8n.bat",
            "$env:USERPROFILE\start-n8n.ps1"
        )
        
        foreach ($script in $startupScripts) {
            if (Test-Path $script) {
                Remove-Item -Path $script -Force
                Write-Success "Removed startup script: $(Split-Path $script -Leaf)"
            }
        }
        
        # Remove environment variables
        try {
            [Environment]::SetEnvironmentVariable("N8N_USER_FOLDER", $null, "User")
            [Environment]::SetEnvironmentVariable("N8N_PORT", $null, "User")
            Write-Success "Environment variables removed"
        }
        catch {
            Write-Warning "Failed to remove environment variables: $($_.Exception.Message)"
        }
        
        # Remove firewall rules
        try {
            $firewallRule = Get-NetFirewallRule -DisplayName "n8n" -ErrorAction SilentlyContinue
            if ($firewallRule) {
                Remove-NetFirewallRule -DisplayName "n8n"
                Write-Success "Removed firewall rule"
            }
        }
        catch {
            Write-Warning "Could not remove firewall rule: $($_.Exception.Message)"
        }
    }
    else {
        Write-Warning "Keeping n8n data and configuration"
    }
}

# Optional: Remove Node.js
function Remove-NodeJS {
    Write-Step "4/5" "Optional: Remove Node.js..."
    
    Write-Warning "Node.js may be used by other applications."
    
    $removeNode = $false
    if (-not $NoInteraction) {
        $response = Read-Host "Do you want to remove Node.js? (y/N)"
        $removeNode = $response -match '^[Yy]$'
    }
    
    if ($removeNode) {
        if (Get-Command choco -ErrorAction SilentlyContinue) {
            try {
                $nodePackages = choco list --local-only | Where-Object { $_ -like "*nodejs*" -or $_ -like "*node-js*" }
                
                if ($nodePackages) {
                    Write-Info "Removing Node.js via Chocolatey..."
                    choco uninstall nodejs-lts -y | Out-Null
                    choco uninstall nodejs -y | Out-Null
                    Write-Success "Node.js removed"
                }
                else {
                    Write-Info "Node.js not found in Chocolatey packages"
                }
            }
            catch {
                Write-Warning "Failed to remove Node.js via Chocolatey: $($_.Exception.Message)"
            }
        }
        else {
            Write-Warning "Chocolatey not found - cannot remove Node.js automatically"
            Write-Info "You may need to uninstall Node.js manually from Control Panel"
        }
    }
    else {
        Write-Info "Keeping Node.js"
    }
}

# Optional: Remove Chocolatey
function Remove-Chocolatey {
    Write-Step "5/5" "Optional: Remove Chocolatey..."
    
    Write-Warning "Chocolatey may be used by other applications."
    
    $removeChoco = $false
    if (-not $NoInteraction) {
        $response = Read-Host "Do you want to remove Chocolatey? (y/N)"
        $removeChoco = $response -match '^[Yy]$'
    }
    
    if ($removeChoco) {
        if (Get-Command choco -ErrorAction SilentlyContinue) {
            try {
                Write-Info "Removing Chocolatey..."
                
                # Use Chocolatey's official removal script
                $chocoPath = (Get-Command choco).Source
                $chocoRoot = Split-Path (Split-Path $chocoPath -Parent) -Parent
                
                if (Test-Path "$chocoRoot\uninstall.ps1") {
                    & "$chocoRoot\uninstall.ps1"
                }
                else {
                    # Manual removal
                    $chocoInstallPath = $env:ChocolateyInstall
                    if ($chocoInstallPath -and (Test-Path $chocoInstallPath)) {
                        Remove-Item -Path $chocoInstallPath -Recurse -Force
                    }
                    
                    # Remove from PATH
                    $path = [Environment]::GetEnvironmentVariable("PATH", "Machine")
                    $newPath = ($path.Split(';') | Where-Object { $_ -notlike "*chocolatey*" }) -join ';'
                    [Environment]::SetEnvironmentVariable("PATH", $newPath, "Machine")
                    
                    $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
                    $newUserPath = ($userPath.Split(';') | Where-Object { $_ -notlike "*chocolatey*" }) -join ';'
                    [Environment]::SetEnvironmentVariable("PATH", $newUserPath, "User")
                }
                
                Write-Success "Chocolatey removed"
            }
            catch {
                Write-Warning "Failed to remove Chocolatey automatically: $($_.Exception.Message)"
                Write-Info "You may need to remove Chocolatey manually"
            }
        }
        else {
            Write-Info "Chocolatey not found"
        }
    }
    else {
        Write-Info "Keeping Chocolatey"
    }
}

# Cleanup function
function Invoke-Cleanup {
    Write-Info "Cleaning up temporary files..."
    # Add any cleanup logic here
}

# Main uninstallation function
function Start-Uninstallation {
    # Setup
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║                     n8n Uninstaller                         ║" -ForegroundColor Magenta
    Write-Host "║                       for Windows                           ║" -ForegroundColor Magenta
    Write-Host "║                      Version $ScriptVersion                        ║" -ForegroundColor Magenta
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
    Write-Host ""
    
    # Create log file
    "n8n Uninstallation Log - $(Get-Date)" | Out-File -FilePath $LogFile -Encoding UTF8
    Write-Info "Uninstallation log: $LogFile"
    Write-Host ""
    
    Write-Warning "This will remove n8n from your system."
    
    $continue = $true
    if (-not $NoInteraction) {
        $response = Read-Host "Are you sure you want to continue? (y/N)"
        $continue = $response -match '^[Yy]$'
    }
    
    if (-not $continue) {
        Write-Info "Uninstallation cancelled"
        exit 0
    }
    
    # Run uninstallation steps
    Stop-N8nProcesses
    Remove-N8nPackage
    Remove-N8nData
    Remove-NodeJS
    Remove-Chocolatey
    
    # Cleanup
    Invoke-Cleanup
    
    # Final message
    Write-Host ""
    Write-Host "🗑️ Uninstallation Complete! 🗑️" -ForegroundColor Green
    Write-Host ""
    Write-Host "n8n has been removed from your system." -ForegroundColor Cyan
    Write-Host ""
    Write-Info "Uninstallation log saved to: $LogFile"
    Write-Host ""
    Write-Warning "You may need to restart your computer to complete the removal process."
    Write-Host ""
}

# Error handling
trap {
    Write-Error "Uninstallation interrupted: $($_.Exception.Message)"
    Invoke-Cleanup
    exit 1
}

# Display help if requested
if ($args -contains "-h" -or $args -contains "--help") {
    Write-Host "n8n Uninstaller for Windows v$ScriptVersion" -ForegroundColor Green
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\uninstall-n8n-windows.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "  -NoInteraction    Run without user prompts"
    Write-Host "  -KeepData         Keep n8n data and configuration"
    Write-Host "  -h, --help        Show this help message"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  .\uninstall-n8n-windows.ps1"
    Write-Host "  .\uninstall-n8n-windows.ps1 -NoInteraction"
    Write-Host "  .\uninstall-n8n-windows.ps1 -KeepData"
    exit 0
}

# Run main function
Start-Uninstallation 