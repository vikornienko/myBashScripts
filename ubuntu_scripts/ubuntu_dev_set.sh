#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2039
# Author: Valeriy Kornienko vikornienko76@gmail.com
# This script is used for Node.js and Python development environment setup.
# And settings for computer vision packages.
# Скрипт устанавливает на ubuntu набор пакетов для разработки на python, node js.
# Устанавливает docker и sqlite3
# TODO: Сделать описание скрипта.
# TODO: Сделать логирование в файл.
# TODO: Сделать добавление в .bashrc скрипта для использования файлов .nvmrc
# TODO: Добавить установку typescript.

set -uo pipefail

readonly PACKAGES_PYTHON=(
    python3-pip
    build-essential
    libssl-dev
    libffi-dev
    python3-dev
    python3-venv
    cmake
    openssh-server
    )

readonly PACKAGES_TOOLS=(
    git
    curl
    wget
    tree
    htop
    unzip
    pkg-config
    git-lfs
    ca-certificates
    gnupg
    sqlite3
    libssl-dev
    libffi-dev
)

readonly PACKAGES_CV=(
    libglib2.0-0
    libsm6
    libxrender1
    libxext6
    libgl1-mesa-glx
    libgstreamer1.0-dev
    libgstreamer-plugins-base1.0-dev
)

readonly PACKAGES_PDF=(
    libpoppler-cpp-dev
    poppler-utils
    ghostscript
    libmagic1
)

readonly PACKAGES_OCR=(
    tesseract-ocr
    tesseract-ocr-rus
    tesseract-ocr-eng
    libtesseract-dev
    libleptonica-dev
)
# Colors for output (using printf for POSIX compatibility)
RED=$(printf '\033[0;31m')
GREEN=$(printf '\033[0;32m')
YELLOW=$(printf '\033[1;33m')
BLUE=$(printf '\033[0;34m')
NC=$(printf '\033[0m') # No Color

# Logging functions
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
    command -v "$1" >/dev/null 2>&1
}

# Function to install package with error handling
install_package() {
    local package="$1"
    log "Installing $package..."
    if sudo apt install -y "$package"; then
        log_success "$package installed successfully"
    else
        log_error "Failed to install $package"
        return 1
    fi
}

install_tools() {
    # 5. Install additional development tools
    log "Installing additional development tools..."
    for tool in "${PACKAGES_TOOLS[@]}"; do
        if ! check_command "$tool"; then
            install_package "$tool"
        else
            log_success "$tool is already installed."
        fi
    done
}

install_pydev() {
    # 1. Install Python development tools
    log "Setting up Python development environment..."
    # Install Python development packages
    # Using a loop for POSIX sh compatibility instead of array
    for package in "${PACKAGES_PYTHON[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            install_package "$package"
        else
            log_success "$package is already installed"
        fi
    done
}

install_pipx_uv() {
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
}

install_nvm_node() {
        # 4. Install nvm and Node.js
    log "Installing nvm..."
    if [ ! -d "$HOME/.nvm" ]; then
        # Download and install nvm
        curl -o- curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash # Use bash explicitly

        # Source nvm immediately
        export NVM_DIR="$HOME/.nvm"
        if [ -s "$NVM_DIR/nvm.sh" ]; then
            . "$NVM_DIR/nvm.sh"
        fi
        # bash_completion might not work in sh, so we skip it or handle it differently if needed
        # [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

        # Install Node.js LTS
        log "Installing Node.js LTS..."
        nvm install 24
        nvm alias default node

        log_success "nvm and Node.js installed successfully"
    else
        log_success "nvm is already installed"

        # Try to load nvm and check Node.js
        export NVM_DIR="$HOME/.nvm"
        if [ -s "$NVM_DIR/nvm.sh" ]; then
            . "$NVM_DIR/nvm.sh"
        fi        
    fi
}

install_docker() {
    # 6. Install Docker
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
}

install_cvtools() {
    log "Installing CV tools..."
    for tool in "${PACKAGES_CV[@]}"; do
        if ! check_command "$tool"; then
            install_package "$tool"
        else
            log_success "$tool is already installed."
        fi
    done
}

install_pdftools() {
    log "Installing PDF tools..."
    for tool in "${PACKAGES_PDF[@]}"; do
        if ! check_command "$tool"; then
            install_package "$tool"
        else
            log_success "$tool is already installed."
        fi
    done
}

install_cuda() {
    log "Installing CUDA..."
    if ! check_command nvcc; then
        sudo apt install -y linux-headers-$(uname -r)
        wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
        sudo dpkg -i cuda-keyring_1.1-1_all.deb
        sudo apt update
        sudo apt install -y cuda-toolkit
        log_success "CUDA toolkit installed successfully"
        log_warning "CUDA don't installed"
    else
        log_success "cuda-toolkit already installed."
}

# Main setup function
main() {
    log "Starting development environment setup..."


    # Display current shell info
    log "Current shell: $SHELL"
    log "Available shells:"
    cat /etc/shells

    # Update system
    log "Updating system packages..."
    sudo apt update && sudo apt upgrade -y

    install_tools
    install_pydev
    install_pipx_uv
    install_nvm_node
    install_docker
    install_cvtools
    install_pdftools
    install_cuda    

         
    # 7. Install CUDA
    log "Installing CUDA..."
    if ! check_command nvcc; then
        sudo apt install -y linux-headers-$(uname -r)
        wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
        sudo dpkg -i cuda-keyring_1.1-1_all.deb
        sudo apt update
        sudo apt install -y cuda-toolkit
        log_success "CUDA toolkit installed successfully"
        log_warning "CUDA don't installed"
    else
        log_success "cuda-toolkit already installed."
        

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