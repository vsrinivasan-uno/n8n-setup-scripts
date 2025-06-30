#!/bin/bash

# n8n Automated Installation Script for macOS
# Version: 1.0.0
# Author: n8n Setup Scripts
# License: MIT

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_VERSION="1.0.0"
N8N_PORT="${N8N_PORT:-5678}"
LOG_FILE="$HOME/n8n-install.log"
N8N_USER_FOLDER="$HOME/.n8n"
MIN_NODE_VERSION="18"
REQUIRED_DISK_SPACE_GB=2
REQUIRED_RAM_GB=4

# GitHub repository information
GITHUB_REPO="n8n-setup-scripts"
GITHUB_USER="vsrinivasan-uno"
UPDATE_CHECK_URL="https://api.github.com/repos/${GITHUB_USER}/${GITHUB_REPO}/releases/latest"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
    echo -e "$1"
}

# Print colored messages
print_step() {
    echo -e "${BLUE}[$1] $2${NC}"
    log "[$1] $2"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
    log "SUCCESS: $1"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
    log "WARNING: $1"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
    log "ERROR: $1"
}

print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
    log "INFO: $1"
}

# Error handling
handle_error() {
    print_error "Installation failed at step: $1"
    print_error "Check the log file at: $LOG_FILE"
    print_info "For troubleshooting help, visit: https://github.com/${GITHUB_USER}/${GITHUB_REPO}/blob/main/TROUBLESHOOTING.md"
    exit 1
}

# Check for script updates
check_for_updates() {
    print_info "Checking for script updates..."
    
    if command -v curl >/dev/null 2>&1; then
        LATEST_VERSION=$(curl -s "$UPDATE_CHECK_URL" 2>/dev/null | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/' || echo "")
        
        if [ -n "$LATEST_VERSION" ] && [ "$LATEST_VERSION" != "$SCRIPT_VERSION" ]; then
            print_warning "A newer version ($LATEST_VERSION) of this script is available!"
            print_info "Download the latest version from: https://github.com/${GITHUB_USER}/${GITHUB_REPO}"
            echo ""
            read -p "Continue with current version? (y/N): " -n 1 -r
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 0
            fi
        fi
    fi
}

# System requirements check
check_system_requirements() {
    print_step "1/6" "Checking system requirements..."
    
    # Check macOS version
    macos_version=$(sw_vers -productVersion)
    macos_major=$(echo "$macos_version" | cut -d. -f1)
    macos_minor=$(echo "$macos_version" | cut -d. -f2)
    
    if [ "$macos_major" -lt 10 ] || ([ "$macos_major" -eq 10 ] && [ "$macos_minor" -lt 15 ]); then
        handle_error "macOS 10.15 (Catalina) or later is required. Found: $macos_version"
    fi
    print_success "macOS version: $macos_version"
    
    # Check available disk space
    available_space=$(df -g "$HOME" | awk 'NR==2 {print $4}')
    if [ "$available_space" -lt "$REQUIRED_DISK_SPACE_GB" ]; then
        handle_error "Insufficient disk space. Required: ${REQUIRED_DISK_SPACE_GB}GB, Available: ${available_space}GB"
    fi
    print_success "Available disk space: ${available_space}GB"
    
    # Check available RAM
    total_ram_bytes=$(sysctl -n hw.memsize)
    total_ram_gb=$((total_ram_bytes / 1024 / 1024 / 1024))
    if [ "$total_ram_gb" -lt "$REQUIRED_RAM_GB" ]; then
        print_warning "Low RAM detected. Recommended: ${REQUIRED_RAM_GB}GB, Available: ${total_ram_gb}GB"
    else
        print_success "Available RAM: ${total_ram_gb}GB"
    fi
    
    # Check internet connectivity
    if ! ping -c 1 google.com >/dev/null 2>&1; then
        handle_error "No internet connection detected"
    fi
    print_success "Internet connectivity verified"
    
    # Check if running as root (not recommended)
    if [ "$EUID" -eq 0 ]; then
        print_warning "Running as root is not recommended. Continue anyway? (y/N)"
        read -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi
    fi
}

# Install Homebrew
install_homebrew() {
    print_step "2/6" "Setting up Homebrew package manager..."
    
    if command -v brew >/dev/null 2>&1; then
        print_success "Homebrew is already installed"
        print_info "Updating Homebrew..."
        brew update || print_warning "Failed to update Homebrew, continuing..."
    else
        print_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || handle_error "Failed to install Homebrew"
        
        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ $(uname -m) == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.zprofile"
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        
        print_success "Homebrew installed successfully"
    fi
}

# Install Node.js
install_nodejs() {
    print_step "3/6" "Installing Node.js..."
    
    if command -v node >/dev/null 2>&1; then
        current_version=$(node -v | sed 's/v//' | cut -d. -f1)
        if [ "$current_version" -ge "$MIN_NODE_VERSION" ]; then
            print_success "Node.js $(node -v) is already installed"
            return
        else
            print_warning "Node.js version $(node -v) is too old. Installing newer version..."
        fi
    fi
    
    print_info "Installing Node.js LTS via Homebrew..."
    brew install node@20 || handle_error "Failed to install Node.js"
    
    # Ensure Node.js is in PATH
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'export PATH="/opt/homebrew/opt/node@20/bin:$PATH"' >> "$HOME/.zprofile"
        export PATH="/opt/homebrew/opt/node@20/bin:$PATH"
    else
        echo 'export PATH="/usr/local/opt/node@20/bin:$PATH"' >> "$HOME/.zprofile"
        export PATH="/usr/local/opt/node@20/bin:$PATH"
    fi
    
    # Verify installation
    if command -v node >/dev/null 2>&1; then
        print_success "Node.js $(node -v) installed successfully"
        print_success "npm $(npm -v) available"
    else
        handle_error "Node.js installation verification failed"
    fi
}

# Install n8n
install_n8n() {
    print_step "4/6" "Installing n8n..."
    
    if command -v n8n >/dev/null 2>&1; then
        print_warning "n8n is already installed. Upgrading to latest version..."
        npm install -g n8n@latest || handle_error "Failed to upgrade n8n"
    else
        print_info "Installing n8n globally..."
        npm install -g n8n || handle_error "Failed to install n8n"
    fi
    
    # Verify installation
    if command -v n8n >/dev/null 2>&1; then
        n8n_version=$(n8n --version 2>/dev/null || echo "unknown")
        print_success "n8n $n8n_version installed successfully"
    else
        handle_error "n8n installation verification failed"
    fi
}

# Configure n8n
configure_n8n() {
    print_step "5/6" "Configuring n8n..."
    
    # Create n8n directory
    mkdir -p "$N8N_USER_FOLDER"
    print_success "Created n8n user folder: $N8N_USER_FOLDER"
    
    # Set environment variables
    echo "export N8N_USER_FOLDER=\"$N8N_USER_FOLDER\"" >> "$HOME/.zprofile"
    echo "export N8N_PORT=\"$N8N_PORT\"" >> "$HOME/.zprofile"
    export N8N_USER_FOLDER="$N8N_USER_FOLDER"
    export N8N_PORT="$N8N_PORT"
    
    # Create basic configuration
    cat > "$N8N_USER_FOLDER/config" << EOF
# n8n Configuration
N8N_USER_FOLDER=$N8N_USER_FOLDER
N8N_PORT=$N8N_PORT
N8N_PROTOCOL=http
N8N_HOST=localhost
EOF

    print_success "n8n configuration completed"
    
    # Create startup script
    cat > "$HOME/start-n8n.sh" << 'EOF'
#!/bin/bash
echo "Starting n8n..."
source ~/.zprofile
n8n start
EOF
    
    chmod +x "$HOME/start-n8n.sh"
    print_success "Created startup script: $HOME/start-n8n.sh"
}

# Start n8n server
start_n8n() {
    print_step "6/6" "Starting n8n server..."
    
    print_info "Starting n8n on port $N8N_PORT..."
    print_info "This may take a moment for the first startup..."
    
    # Start n8n in background
    nohup n8n start > "$N8N_USER_FOLDER/n8n.log" 2>&1 &
    N8N_PID=$!
    
    # Wait for n8n to start
    print_info "Waiting for n8n to start..."
    for i in {1..30}; do
        if curl -s "http://localhost:$N8N_PORT" >/dev/null 2>&1; then
            break
        fi
        sleep 2
        echo -n "."
    done
    echo ""
    
    # Check if n8n is running
    if curl -s "http://localhost:$N8N_PORT" >/dev/null 2>&1; then
        print_success "n8n server started successfully!"
        print_success "Access n8n at: http://localhost:$N8N_PORT"
        
        # Open browser
        print_info "Opening n8n in your default browser..."
        open "http://localhost:$N8N_PORT"
        
        # Display final instructions
        echo ""
        echo -e "${GREEN}🎉 Installation Complete! 🎉${NC}"
        echo ""
        echo -e "${CYAN}n8n is now running on your system!${NC}"
        echo ""
        echo -e "${YELLOW}Quick Start:${NC}"
        echo "• Access n8n: http://localhost:$N8N_PORT"
        echo "• Start n8n: $HOME/start-n8n.sh"
        echo "• Stop n8n: killall node"
        echo "• Logs: $N8N_USER_FOLDER/n8n.log"
        echo "• Installation log: $LOG_FILE"
        echo ""
        echo -e "${PURPLE}Need help?${NC}"
        echo "• Documentation: https://docs.n8n.io"
        echo "• Troubleshooting: https://github.com/${GITHUB_USER}/${GITHUB_REPO}/blob/main/TROUBLESHOOTING.md"
        echo "• Issues: https://github.com/${GITHUB_USER}/${GITHUB_REPO}/issues"
        echo ""
        
    else
        handle_error "n8n failed to start. Check logs at: $N8N_USER_FOLDER/n8n.log"
    fi
}

# Cleanup function
cleanup() {
    print_info "Cleaning up temporary files..."
    # Add any cleanup logic here
}

# Main installation function
main() {
    # Print intro
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║              n8n Automated Installer for macOS               ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Built by Vishva Prasanth Srinivasan | AI-CCORE${NC}"
    echo -e "${CYAN}LinkedIn: https://www.linkedin.com/in/vishvaprasanth/${NC}"
    echo ""

    # Create log file
    echo "n8n Installation Log - $(date)" > "$LOG_FILE"
    print_info "Installation log: $LOG_FILE"
    echo ""
    
    # Check for updates
    check_for_updates
    
    # Run installation steps
    check_system_requirements
    install_homebrew
    install_nodejs
    install_n8n
    configure_n8n
    start_n8n
    
    # Cleanup
    cleanup
}

# Handle script interruption
trap 'echo -e "\n${RED}Installation interrupted by user${NC}"; cleanup; exit 1' INT TERM

# Run main function
main "$@" 