#!/bin/bash

# Скрипт для установки Node.js 16.20.2 на Ubuntu 18.04
# Устанавливает curl, скачивает бинарник Node.js, распаковывает и добавляет в PATH

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Функция для цветного вывода
print_error() { echo -e "${RED}$1${NC}"; }
print_success() { echo -e "${GREEN}$1${NC}"; }
print_info() { echo -e "${YELLOW}$1${NC}"; }

# Обновление системы
print_info "Обновление системы..."
sudo apt update && sudo apt upgrade -y

NODE_VERSION="16.20.2"
ARCH="x64"
NODE_DISTRO="node-v$NODE_VERSION-linux-$ARCH"

# Проверка наличия пакета
is_installed() {
    command -v "$1" >/dev/null 2>&1
}

# Установка git
install_git() {
    print_info "Установка git..."
    sudo apt-get install -y git
    if is_installed git; then
        print_success "Git успешно установлен: $(git --version)"
    else
        print_error "Ошибка установки git"
        exit 1
    fi
}

# Установка nvm и Node.js через nvm
install_nodejs() {
    print_info "Установка nvm (Node Version Manager)..."
    if [ ! -d "$HOME/.nvm" ]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    else
        print_info "nvm уже установлен."
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    fi
    print_info "Установка Node.js $NODE_VERSION через nvm..."
    nvm install $NODE_VERSION
    nvm use $NODE_VERSION
    nvm alias default $NODE_VERSION
    if is_installed node; then
        print_success "Node.js установлен: $(node -v)"
    else
        print_error "Ошибка установки Node.js"
        exit 1
    fi
    if is_installed npm; then
        print_success "npm установлен: $(npm -v)"
    else
        print_error "Ошибка установки npm"
        exit 1
    fi
}

# Установка PostgreSQL
install_postgresql() {
    print_info "Установка PostgreSQL..."
    sudo apt-get install -y postgresql postgresql-contrib
    if is_installed psql; then
        print_success "PostgreSQL успешно установлен: $(psql --version)"
    else
        print_error "Ошибка установки PostgreSQL"
        exit 1
    fi
}

# Установка пакетов для nodejs-разработки
install_nodejs_dev_packages() {
    print_info "Установка пакетов для nodejs-разработки..."
    sudo apt-get install -y build-essential gcc g++ make 
    print_success "Пакеты для nodejs-разработки успешно установлены."
}

# Установка curl, если не установлен
if ! is_installed curl; then
    print_info "Установка curl..."
    sudo apt-get install -y curl
fi

# Проверка и установка git
if is_installed git; then
    print_success "Git уже установлен: $(git --version)"
else
    install_git
fi

# Проверка и установка PostgreSQL
if is_installed psql; then
    print_success "PostgreSQL уже установлен: $(psql --version)"
else
    install_postgresql
fi

# Проверка и установка Node.js
if is_installed node; then
    print_success "Node.js уже установлен: $(node -v)"
else
    install_nodejs
fi

# Установка dev-пакетов для nodejs
install_nodejs_dev_packages

print_info "Node.js $NODE_VERSION успешно установлен. Перезапустите терминал или выполните 'source ~/.profile' для обновления PATH."
