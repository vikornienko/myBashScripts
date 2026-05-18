#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2039
# Author: Valeriy Kornienko vikornienko76@gmail.com
# For automated start projects with fastapi.
# version: 0.1.1

set -euo pipefail

# Глобальные переменные для хранения введённых данных
PROJECT_NAME=""
PYTHON_VERSION=""
PROJECT_DESCRIPTION=""

# Цвета для вывода логов
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Логирование
print_info()    { echo -e "${BLUE}[INFO]${NC}  $1"; }
print_success() { echo -e "${GREEN}[OK]${NC}    $1"; }
print_error()   { echo -e "${RED}[ERROR]${NC} $1" >&2; }
print_warn()    { echo -e "${YELLOW}[WARN]${NC}  $1"; }
print_step()    { echo -e "\n${CYAN}${BOLD}▶ $1${NC}"; }

# Запрос информации о проекте
ask_project_info() {
    print_step "Шаг 1: Сбор информации о проекте"

    # Наименование проекта
    read -rp "Введите наименование проекта: " PROJECT_NAME
    while [[ -z "${PROJECT_NAME// /}" ]]; do
        print_error "Наименование проекта не может быть пустым!"
        read -rp "Введите наименование проекта: " PROJECT_NAME
    done

    # Версия Python
    read -rp "Введите версию Python [3.13]: " PYTHON_VERSION
    PYTHON_VERSION="${PYTHON_VERSION:-3.13}"

    # Описание для README
    read -rp "Введите краткое описание проекта: " PROJECT_DESCRIPTION
    PROJECT_DESCRIPTION="${PROJECT_DESCRIPTION:-Учебный проект на FastAPI}"

    print_success "Проект: '$PROJECT_NAME' | Python: $PYTHON_VERSION"
}

# Создание/проверка существования директории проекта
setup_directory() {
    print_step "Шаг 2: Создание/проверка директории проекта"

    if [[ ! -d "$PROJECT_NAME" ]]; then
        mkdir -p "$PROJECT_NAME"
        print_success "Создана директория: $PROJECT_NAME"
    else
        print_warn "Директория '$PROJECT_NAME' уже существует"
    fi

    cd "$PROJECT_NAME" || {
        print_error "Не удалось перейти в директорию '$PROJECT_NAME'"
        exit 1
    }

    print_success "Директория проекта: $(pwd)"
}

# Главная функция
main() {
    echo ""
    echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║     FastAPI Project Bootstrap Script                         ║${NC}"
    echo -e "${CYAN}${BOLD}║     Ubuntu 24.04 | WSL2 | UV | FastAPI                       ║${NC}"
    echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    ask_project_info
    setup_directory
    # pin_python_version
    # init_uv_project
    # setup_venv
    # install_dependencies
    # create_readme
    # create_gitignore
    # create_src
    # start_project
}

main "$@"