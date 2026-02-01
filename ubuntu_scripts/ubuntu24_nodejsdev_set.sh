#!/usr/bin/env bash

#============================================================
# Скрипт установки окружения для разработки на Node.js
# Версия: 1.0
# ОС: Ubuntu 24.04
#============================================================

set -e  # Прерывание скрипта при ошибке

#============================================================
# КОНСТАНТЫ И ПЕРЕМЕННЫЕ
#============================================================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="${SCRIPT_DIR}/setup_$(date +%Y%m%d_%H%M%S).log"
readonly REQUIRED_OS="Ubuntu"
readonly REQUIRED_VERSION="24.04"
readonly NVM_VERSION="v0.40.3"
readonly NVM_INSTALL_URL="https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh"

# Цвета для вывода
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_NC='\033[0m' # No Color

# Версия Node.js (по умолчанию, можно переопределить через аргумент)
NODE_VERSION="${1:-16.20.2}"

#============================================================
# ФУНКЦИЯ ЛОГИРОВАНИЯ
#============================================================

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_entry="[${timestamp}] [${level}] ${message}"
    
    # Запись в файл
    echo "${log_entry}" >> "${LOG_FILE}"
    
    # Вывод в консоль с цветом
    case "${level}" in
        INFO)
            echo -e "${COLOR_BLUE}ℹ ${message}${COLOR_NC}"
            ;;
        SUCCESS)
            echo -e "${COLOR_GREEN}✓ ${message}${COLOR_NC}"
            ;;
        WARNING)
            echo -e "${COLOR_YELLOW}⚠ ${message}${COLOR_NC}"
            ;;
        ERROR)
            echo -e "${COLOR_RED}✗ ${message}${COLOR_NC}"
            ;;
        *)
            echo "${message}"
            ;;
    esac
}

#============================================================
# ФУНКЦИЯ ПРОВЕРКИ ВЕРСИИ ОПЕРАЦИОННОЙ СИСТЕМЫ
#============================================================

check_os_version() {
    log "INFO" "Проверка версии операционной системы..."
    
    if [[ ! -f /etc/os-release ]]; then
        log "ERROR" "Файл /etc/os-release не найден"
        exit 1
    fi
    
    source /etc/os-release
    
    if [[ "${NAME}" != "${REQUIRED_OS}" ]]; then
        log "ERROR" "Требуется ${REQUIRED_OS}, обнаружено: ${NAME}"
        exit 1
    fi
    
    if [[ "${VERSION_ID}" != "${REQUIRED_VERSION}" ]]; then
        log "ERROR" "Требуется версия ${REQUIRED_VERSION}, обнаружено: ${VERSION_ID}"
        exit 1
    fi
    
    log "SUCCESS" "Версия ОС корректна: ${NAME} ${VERSION_ID}"
}

#============================================================
# ФУНКЦИЯ ОБНОВЛЕНИЯ СИСТЕМЫ
#============================================================

update_system() {
    log "Обновление списков пакетов и системы..."
    sudo apt update
    sudo apt upgrade -y
    log "Система успешно обновлена."
}

#============================================================
# ФУНКЦИЯ ПРОВЕРКИ НАЛИЧИЯ КОМАНДЫ
#============================================================

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

#============================================================
# ФУНКЦИЯ ПРОВЕРКИ НАЛИЧИЯ ПАКЕТА
#============================================================

package_installed() {
    dpkg -l "$1" 2>/dev/null | grep -q "^ii"
}

#============================================================
# ФУНКЦИЯ УСТАНОВКИ СИСТЕМНЫХ ПАКЕТОВ
#============================================================

install_system_packages() {
    log "INFO" "Проверка и установка необходимых системных пакетов..."
    
    local packages=(
        "curl"
        "wget"
        "build-essential"
        "libssl-dev"
        "ca-certificates"
        "gnupg"
        "lsb-release"
        "software-properties-common"        
    )
    
    local to_install=()
    
    for package in "${packages[@]}"; do
        if package_installed "${package}"; then
            log "SUCCESS" "Пакет ${package} уже установлен"
        else
            log "INFO" "Пакет ${package} будет установлен"
            to_install+=("${package}")
        fi
    done
    
    if [[ ${#to_install[@]} -gt 0 ]]; then
        log "INFO" "Установка пакетов: ${to_install[*]}"
        if ! DEBIAN_FRONTEND=noninteractive apt install -y "${to_install[@]}" >> "${LOG_FILE}" 2>&1; then
            log "ERROR" "Ошибка при установке системных пакетов"
            exit 1
        fi
        log "SUCCESS" "Системные пакеты установлены"
    else
        log "SUCCESS" "Все системные пакеты уже установлены"
    fi
}

#============================================================
# ФУНКЦИЯ УСТАНОВКИ GIT
#============================================================

install_git() {
    log "INFO" "Проверка установки Git..."
    
    if command_exists git; then
        local git_version=$(git --version | awk '{print $3}')
        log "SUCCESS" "Git уже установлен (версия: ${git_version})"
        return 0
    fi
    
    log "INFO" "Установка Git..."
    if ! DEBIAN_FRONTEND=noninteractive apt install -y git >> "${LOG_FILE}" 2>&1; then
        log "ERROR" "Ошибка при установке Git"
        exit 1
    fi
    
    local git_version=$(git --version | awk '{print $3}')
    log "SUCCESS" "Git установлен (версия: ${git_version})"
}

#============================================================
# ФУНКЦИЯ УСТАНОВКИ NVM
#============================================================

install_nvm() {
    log "INFO" "Проверка установки NVM..."
    
    # NVM устанавливается в домашнюю директорию пользователя
    local nvm_dir="${HOME}/.nvm"
    
    if [[ -d "${nvm_dir}" ]] && [[ -s "${nvm_dir}/nvm.sh" ]]; then
        source "${nvm_dir}/nvm.sh"
        local nvm_version=$(nvm --version 2>/dev/null || echo "unknown")
        log "SUCCESS" "NVM уже установлен (версия: ${nvm_version})"
        return 0
    fi
    
    log "INFO" "Установка NVM версии ${NVM_VERSION}..."
    
    # Скачивание и установка NVM
    if ! curl -o- "${NVM_INSTALL_URL}" | bash >> "${LOG_FILE}" 2>&1; then
        log "ERROR" "Ошибка при установке NVM"
        exit 1
    fi
    
    # Загрузка NVM в текущую сессию
    export NVM_DIR="${nvm_dir}"
    if [[ -s "${NVM_DIR}/nvm.sh" ]]; then
        source "${NVM_DIR}/nvm.sh"
    else
        log "ERROR" "Не удалось найти скрипт NVM после установки"
        exit 1
    fi
    
    # Добавление NVM в конфигурационные файлы, если еще не добавлено
    local shell_configs=(
        "${HOME}/.bashrc"
        "${HOME}/.profile"
    )
    
    for config in "${shell_configs[@]}"; do
        if [[ -f "${config}" ]] && ! grep -q 'NVM_DIR' "${config}"; then
            cat >> "${config}" << 'EOF'

# NVM Configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF
            log "INFO" "NVM добавлен в ${config}"
        fi
    done
    
    local nvm_version=$(nvm --version)
    log "SUCCESS" "NVM установлен (версия: ${nvm_version})"
}

#============================================================
# ФУНКЦИЯ УСТАНОВКИ NODE.JS
#============================================================

install_nodejs() {
    log "INFO" "Проверка установки Node.js..."
    
    # Загрузка NVM
    export NVM_DIR="${HOME}/.nvm"
    if [[ -s "${NVM_DIR}/nvm.sh" ]]; then
        source "${NVM_DIR}/nvm.sh"
    else
        log "ERROR" "NVM не установлен"
        exit 1
    fi
    
    # Проверка, установлена ли уже нужная версия Node.js
    if nvm ls "${NODE_VERSION}" >/dev/null 2>&1; then
        log "SUCCESS" "Node.js версии ${NODE_VERSION} уже установлен"
        nvm use "${NODE_VERSION}" >> "${LOG_FILE}" 2>&1
    else
        log "INFO" "Установка Node.js версии ${NODE_VERSION}..."
        if ! nvm install "${NODE_VERSION}" >> "${LOG_FILE}" 2>&1; then
            log "ERROR" "Ошибка при установке Node.js"
            exit 1
        fi
        log "SUCCESS" "Node.js версии ${NODE_VERSION} установлен"
    fi
    
    # Установка версии по умолчанию
    nvm alias default "${NODE_VERSION}" >> "${LOG_FILE}" 2>&1
    nvm use default >> "${LOG_FILE}" 2>&1
    
    # Вывод версий
    local node_version=$(node --version)
    local npm_version=$(npm --version)
    log "SUCCESS" "Node.js: ${node_version}, npm: ${npm_version}"
    
    # Обновление npm до последней версии
    log "INFO" "Обновление npm до последней версии..."
    if npm install -g npm@latest >> "${LOG_FILE}" 2>&1; then
        local npm_new_version=$(npm --version)
        log "SUCCESS" "npm обновлен до версии ${npm_new_version}"
    fi
}

#============================================================
# ФУНКЦИЯ УСТАНОВКИ POSTGRESQL
#============================================================

install_postgresql() {
    log "INFO" "Проверка установки PostgreSQL..."
    
    if command_exists psql; then
        local pg_version=$(psql --version | awk '{print $3}')
        log "SUCCESS" "PostgreSQL уже установлен (версия: ${pg_version})"
        return 0
    fi
    
    log "INFO" "Установка PostgreSQL..."
    
    # Установка PostgreSQL и дополнительных пакетов
    local pg_packages=(
        "postgresql"
        "postgresql-contrib"
        "libpq-dev"
    )
    
    if ! DEBIAN_FRONTEND=noninteractive apt install -y "${pg_packages[@]}" >> "${LOG_FILE}" 2>&1; then
        log "ERROR" "Ошибка при установке PostgreSQL"
        exit 1
    fi
    
    log "SUCCESS" "PostgreSQL установлен"
    
    # Запуск и включение автозапуска PostgreSQL
    log "INFO" "Настройка автозапуска PostgreSQL..."
    systemctl enable postgresql >> "${LOG_FILE}" 2>&1
    systemctl start postgresql >> "${LOG_FILE}" 2>&1
    
    if systemctl is-active --quiet postgresql; then
        log "SUCCESS" "PostgreSQL запущен и работает"
    else
        log "WARNING" "PostgreSQL установлен, но не запущен"
    fi
    
    local pg_version=$(psql --version | awk '{print $3}')
    log "SUCCESS" "PostgreSQL версии ${pg_version} готов к использованию"
    
    # Информация о следующих шагах
    log "INFO" "Для создания пользователя и базы данных выполните:"
    log "INFO" "  sudo -u postgres createuser -P your_username"
    log "INFO" "  sudo -u postgres createdb -O your_username your_database"
}

#============================================================
# ФУНКЦИЯ ВЫВОДА ИТОГОВОЙ ИНФОРМАЦИИ
#============================================================

print_summary() {
    log "INFO" "======================================"
    log "INFO" "УСТАНОВКА ЗАВЕРШЕНА УСПЕШНО!"
    log "INFO" "======================================"
    
    echo ""
    log "INFO" "Установленные компоненты:"
    
    if command_exists git; then
        echo "  • Git: $(git --version | awk '{print $3}')"
    fi
    
    export NVM_DIR="${HOME}/.nvm"
    if [[ -s "${NVM_DIR}/nvm.sh" ]]; then
        source "${NVM_DIR}/nvm.sh"
        echo "  • NVM: $(nvm --version)"
        echo "  • Node.js: $(node --version)"
        echo "  • npm: $(npm --version)"
    fi
    
    if command_exists psql; then
        echo "  • PostgreSQL: $(psql --version | awk '{print $3}')"
    fi
    
    echo ""
    log "INFO" "Лог установки сохранен в: ${LOG_FILE}"
    echo ""
    log "WARNING" "ВАЖНО: Перезагрузите терминал или выполните:"
    log "WARNING" "  source ~/.bashrc"
    log "WARNING" "для применения всех изменений окружения"
    echo ""
}

#============================================================
# ГЛАВНАЯ ФУНКЦИЯ
#============================================================

main() {
    log "INFO" "======================================"
    log "INFO" "Начало установки окружения Node.js"
    log "INFO" "======================================"
    log "INFO" "Лог-файл: ${LOG_FILE}"
    echo ""
    
    # Проверка прав суперпользователя
    if [[ $EUID -eq 0 ]]; then
        log "ERROR" "Не запускайте этот скрипт от root!"
        log "ERROR" "Используйте: bash $0"
        log "ERROR" "Sudo будет запрошен при необходимости"
        exit 1
    fi
    
    # Проверка версии ОС
    check_os_version
    
    # Обновление системы
    sudo -v  # Запрос sudo один раз
    update_system
    
    # Установка системных пакетов
    install_system_packages
    
    # Установка Git
    install_git
    
    # Установка NVM
    # install_nvm
    
    # Установка Node.js
    # install_nodejs
    
    # Установка PostgreSQL
    # install_postgresql
    
    # Итоговая информация
    print_summary
    
    log "SUCCESS" "Все задачи выполнены успешно!"
}

#============================================================
# ЗАПУСК СКРИПТА
#============================================================

# Проверка аргументов
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    echo "Использование: $0 [версия_nodejs]"
    echo ""
    echo "Примеры:"
    echo "  $0           # Установит Node.js версии 20 (по умолчанию)"
    echo "  $0 18        # Установит Node.js версии 18"
    echo "  $0 20.10.0   # Установит Node.js версии 20.10.0"
    echo ""
    echo "Скрипт установит:"
    echo "  - Системные пакеты (curl, wget, build-essential и др.)"
    echo "  - Git"
    echo "  - NVM (Node Version Manager)"
    echo "  - Node.js указанной версии"
    echo "  - PostgreSQL"
    echo ""
    exit 0
fi

# Запуск основной функции
main