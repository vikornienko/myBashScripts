#!/bin/sh
# shellcheck disable=SC1091,SC2039
# Author: Valeriy Kornienko vikornienko76@gmail.com
# This script is used for Node.js and Python development environment setup.

set -eu

# Colors for output (using printf for POSIX compatibility)
RED=$(printf '\033[0;31m')
GREEN=$(printf '\033[0;32m')
YELLOW=$(printf '\033[1;33m')
BLUE=$(printf '\033[0;34m')
NC=$(printf '\033[0m') # No Color

# Logging function
log() {
    printf '[%s] %s%s%s\n' "$(date +'%Y-%m-%d %H:%M:%S')" "$BLUE" "$1" "$NC"
}

log_success() {
    printf '[%s] %s✓ %s%s\n' "$(date +'%Y-%m-%d %H:%M:%S')" "$GREEN" "$1" "$NC"
}

log_error() {
    printf '[%s] %s✗ %s%s\n' "$(date +'%Y-%m-%d %H:%M:%S')" "$RED" "$1" "$NC"
}

log_warning() {
    printf '[%s] %s⚠ %s%s\n' "$(date +'%Y-%m-%d %H:%M:%S')" "$YELLOW" "$1" "$NC"
}

# Function to check if command exists
check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        log_success "$1 is already installed"
        return 0
    else
        log_error "$1 is not installed"
        return 1
    fi
}

# Function to install package with error handling
install_package() {
    package="$1"
    log "Installing $package..."
    if sudo apt install -y "$package"; then
        log_success "$package installed successfully"
    else
        log_error "Failed to install $package"
        return 1
    fi
}

# Function to check if running on supported OS
check_os() {
    if ! command -v apt >/dev/null 2>&1; then
        log_error "This script is designed for Debian/Ubuntu systems with apt package manager"
        exit 1
    fi
}

# Main setup function
main() {
    log "Starting development environment setup..."

    # Check OS compatibility
    check_os

    # Display current shell info
    log "Current shell: $SHELL"
    log "Available shells:"
    cat /etc/shells

    # Update system
    log "Updating system packages..."
    sudo apt update && sudo apt upgrade -y

    # 1. Install Python development tools
    log "Setting up Python development environment..."

    if ! check_command python3; then
        install_package python3
    fi

    # Install Python development packages
    # Using a loop for POSIX sh compatibility instead of array
    for package in python3-pip build-essential libssl-dev libffi-dev python3-dev python3-venv; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            install_package "$package"
        else
            log_success "$package is already installed"
        fi
    done

    # 2. Install pipx and uv
    log "Installing pipx..."
    if ! check_command pipx; then
        install_package pipx
        pipx ensurepath
        # Source profile or relevant file to make pipx available
        # This might need manual adjustment based on the shell configuration
        if [ -f "$HOME/.profile" ]; then
             . "$HOME/.profile"
        elif [ -f "$HOME/.shrc" ]; then # Common for sh
             . "$HOME/.shrc"
        elif [ -f "$HOME/.bashrc" ]; then # Fallback if .profile is not sourced by sh
             . "$HOME/.bashrc"
        fi
        export PATH="$HOME/.local/bin:$PATH"
    fi

    log "Installing uv via pipx..."
    if ! check_command uv; then
        pipx install uv
    fi

    # 3. Install sqlite3
    log "Installing sqlite3..."
    if ! check_command sqlite3; then
        install_package sqlite3
    fi

    # 4. Install nvm and Node.js
    log "Installing nvm..."
    if [ ! -d "$HOME/.nvm" ]; then
        # Download and install nvm
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | sh # Use sh explicitly

        # Source nvm immediately
        export NVM_DIR="$HOME/.nvm"
        if [ -s "$NVM_DIR/nvm.sh" ]; then
            . "$NVM_DIR/nvm.sh"
        fi
        # bash_completion might not work in sh, so we skip it or handle it differently if needed
        # [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

        # Install Node.js LTS
        log "Installing Node.js LTS..."
        nvm install --lts
        nvm use --lts
        nvm alias default node

        log_success "nvm and Node.js installed successfully"
    else
        log_success "nvm is already installed"

        # Try to load nvm and check Node.js
        export NVM_DIR="$HOME/.nvm"
        if [ -s "$NVM_DIR/nvm.sh" ]; then
            . "$NVM_DIR/nvm.sh"
        fi

        if ! check_command node; then
            log "Installing Node.js LTS..."
            nvm install --lts
            nvm use --lts
            nvm alias default node
        fi
    fi

    # 5. Install additional development tools
    log "Installing additional development tools..."
    for tool in git curl wget vim tree htop; do
        if ! check_command "$tool"; then
            install_package "$tool"
        fi
    done

    # 6. Optional Docker installation
    printf '\n'
    printf "Do you want to install Docker? (y/n): "
    read -r REPLY
    printf '\n'
    # Using case for POSIX sh compatibility instead of [[ ... =~ ... ]]
    case "$REPLY" in
        [Yy]*)
            log "Installing Docker..."
            if ! check_command docker; then
                curl -fsSL https://get.docker.com -o get-docker.sh
                sudo sh get-docker.sh
                sudo usermod -aG docker "$USER"
                rm get-docker.sh
                log_success "Docker installed successfully"
                log_warning "Please log out and log back in for Docker group changes to take effect"
            else
                log_success "Docker is already installed"
            fi
            ;;
        *)
            log "Skipping Docker installation."
            ;;
    esac

    # Final status report
    printf '\n'
    log_success "Setup completed!"
    log_warning "Please restart your terminal or run 'source ~/.profile' (or equivalent for your sh setup) to apply all changes."
    printf '\n'
    log "Installed tools status:"
    echo "Python: $(python3 --version 2>/dev/null || echo 'Not found')"
    echo "pip: $(pip3 --version 2>/dev/null || echo 'Not found')"
    echo "pipx: $(pipx --version 2>/dev/null || echo 'Not found')"
    echo "uv: $(uv --version 2>/dev/null || echo 'Not found')"
    echo "Node.js: $(node --version 2>/dev/null || echo 'Not found')"
    echo "npm: $(npm --version 2>/dev/null || echo 'Not found')"
    echo "Git: $(git --version 2>/dev/null || echo 'Not found')"
    echo "Docker: $(docker --version 2>/dev/null || echo 'Not found')"
}

# Run main function
main "$@"