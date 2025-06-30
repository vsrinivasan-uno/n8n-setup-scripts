#!/bin/bash

# n8n Uninstallation Script for macOS
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
LOG_FILE="$HOME/n8n-uninstall.log"
N8N_USER_FOLDER="$HOME/.n8n"

# Print colored messages
print_step() {
    echo -e "${BLUE}[$1] $2${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Stop n8n processes
stop_n8n() {
    print_step "1/5" "Stopping n8n processes..."
    
    # Find and kill n8n processes
    if pgrep -f "n8n" >/dev/null; then
        print_info "Stopping n8n processes..."
        pkill -f "n8n" || true
        sleep 2
        
        # Force kill if still running
        if pgrep -f "n8n" >/dev/null; then
            print_warning "Force stopping n8n processes..."
            pkill -9 -f "n8n" || true
        fi
        
        print_success "n8n processes stopped"
    else
        print_info "No running n8n processes found"
    fi
}

# Remove n8n package
remove_n8n() {
    print_step "2/5" "Removing n8n package..."
    
    if command -v n8n >/dev/null 2>&1; then
        print_info "Uninstalling n8n globally..."
        npm uninstall -g n8n || print_warning "Failed to uninstall n8n via npm"
        print_success "n8n package removed"
    else
        print_info "n8n package not found"
    fi
}

# Remove n8n data and configuration
remove_n8n_data() {
    print_step "3/5" "Removing n8n data and configuration..."
    
    echo -e "${YELLOW}This will remove all your n8n workflows, credentials, and settings.${NC}"
    read -p "Do you want to remove n8n data? (y/N): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ -d "$N8N_USER_FOLDER" ]; then
            print_info "Removing n8n user folder: $N8N_USER_FOLDER"
            rm -rf "$N8N_USER_FOLDER"
            print_success "n8n data removed"
        else
            print_info "n8n user folder not found"
        fi
        
        # Remove startup scripts
        if [ -f "$HOME/start-n8n.sh" ]; then
            rm -f "$HOME/start-n8n.sh"
            print_success "Removed startup script"
        fi
        
        # Remove environment variables from .zprofile
        if [ -f "$HOME/.zprofile" ]; then
            print_info "Removing n8n environment variables from .zprofile..."
            grep -v "N8N_USER_FOLDER\|N8N_PORT" "$HOME/.zprofile" > "$HOME/.zprofile.tmp" || true
            mv "$HOME/.zprofile.tmp" "$HOME/.zprofile" || true
            print_success "Environment variables removed"
        fi
    else
        print_warning "Keeping n8n data and configuration"
    fi
}

# Optional: Remove Node.js
remove_nodejs() {
    print_step "4/5" "Optional: Remove Node.js..."
    
    echo -e "${YELLOW}Node.js may be used by other applications.${NC}"
    read -p "Do you want to remove Node.js? (y/N): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if command -v brew >/dev/null 2>&1; then
            if brew list | grep -q "node@20"; then
                print_info "Removing Node.js via Homebrew..."
                brew uninstall node@20 || print_warning "Failed to remove Node.js"
                print_success "Node.js removed"
            elif brew list | grep -q "node"; then
                print_info "Removing Node.js via Homebrew..."
                brew uninstall node || print_warning "Failed to remove Node.js"
                print_success "Node.js removed"
            else
                print_info "Node.js not found in Homebrew"
            fi
            
            # Remove Node.js PATH entries from .zprofile
            if [ -f "$HOME/.zprofile" ]; then
                print_info "Removing Node.js PATH entries..."
                grep -v "node@20\|nodejs" "$HOME/.zprofile" > "$HOME/.zprofile.tmp" || true
                mv "$HOME/.zprofile.tmp" "$HOME/.zprofile" || true
            fi
        else
            print_warning "Homebrew not found - cannot remove Node.js automatically"
        fi
    else
        print_info "Keeping Node.js"
    fi
}

# Optional: Remove Homebrew
remove_homebrew() {
    print_step "5/5" "Optional: Remove Homebrew..."
    
    echo -e "${YELLOW}Homebrew may be used by other applications.${NC}"
    read -p "Do you want to remove Homebrew? (y/N): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if command -v brew >/dev/null 2>&1; then
            print_info "Removing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)" || print_warning "Failed to remove Homebrew"
            
            # Remove Homebrew PATH entries from .zprofile
            if [ -f "$HOME/.zprofile" ]; then
                print_info "Removing Homebrew PATH entries..."
                grep -v "homebrew\|brew" "$HOME/.zprofile" > "$HOME/.zprofile.tmp" || true
                mv "$HOME/.zprofile.tmp" "$HOME/.zprofile" || true
            fi
            
            print_success "Homebrew removed"
        else
            print_info "Homebrew not found"
        fi
    else
        print_info "Keeping Homebrew"
    fi
}

# Cleanup function
cleanup() {
    print_info "Cleaning up temporary files..."
    # Remove empty .zprofile if it exists
    if [ -f "$HOME/.zprofile" ] && [ ! -s "$HOME/.zprofile" ]; then
        rm -f "$HOME/.zprofile"
    fi
}

# Main uninstallation function
main() {
    # Setup
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    n8n Uninstaller                          ║"
    echo "║                       for macOS                             ║"
    echo "║                     Version $SCRIPT_VERSION                        ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    
    # Create log file
    echo "n8n Uninstallation Log - $(date)" > "$LOG_FILE"
    print_info "Uninstallation log: $LOG_FILE"
    echo ""
    
    print_warning "This will remove n8n from your system."
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Uninstallation cancelled"
        exit 0
    fi
    
    # Run uninstallation steps
    stop_n8n
    remove_n8n
    remove_n8n_data
    remove_nodejs
    remove_homebrew
    
    # Cleanup
    cleanup
    
    # Final message
    echo ""
    echo -e "${GREEN}🗑️ Uninstallation Complete! 🗑️${NC}"
    echo ""
    echo -e "${CYAN}n8n has been removed from your system.${NC}"
    echo ""
    print_info "Uninstallation log saved to: $LOG_FILE"
    echo ""
}

# Handle script interruption
trap 'echo -e "\n${RED}Uninstallation interrupted by user${NC}"; exit 1' INT TERM

# Run main function
main "$@" 