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

# Проверка установки менеджера пакетов uv
check_uv() {
    print_step "Шаг 0: проверка установки менеджера пакетов uv"
    
    if ! command -v uv &>/dev/null; then
        print_error "Менеджер пакетов uv не найден, работа скрипта прекращается!"
        exit 1
    else
        print_info "Начинаем настройку проекта."
    fi
}

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

# Закрепление версии Python
pin_python_version() {
    print_step "Закрепляем версию python."

    if [[ ! -f ".python-version" ]]; then
        uv python pin "$PYTHON_VERSION"
        print_success "Python $PYTHON_VERSION закреплен для проекта."
    else
        print_warn "Директория уже содержит файл .python-version!"
    fi
}

# Инициализация проекта с использованием uv
init_uv_project() {
    print_step "Шаг 4: инициализация проекта."

    if [[ ! -f "pyproject.toml" ]]; then
        uv init . --bare
        print_success "Файл pyproject.toml создан в текущей директории."
    else
        print_warn "Файл pyproject.toml уже существует!"
    fi
}

setup_venv() {
    print_step "Шаг 5: создание виртуального окружения."

    if [[ ! -d ".venv" ]]; then
        uv venv
        print_success "Виртуальное окружение создано."
    else 
        print_warn "Виртуальное окружение уже существует."
    fi
}

# Добавляем зависимости
install_dependencies() {
    print_step "Шаг 6: установка зависимостей проекта."

    uv add fastapi uvicorn
    print_success "FastAPI + uvicorn утсановлены."
}

# Создаем в проекте файл README.md
create_readme() {
    print_step "Шаг 7: создание файла README.md"

    cat > README.md << EOF
# $PROJECT_NAME

$PROJECT_DESCRIPTION

## Быстрый старт

\`\`\`bash
# Запуск сервера разработки
uv run src/main.py
\`\`\`

## Зависимости

- [FastAPI](https://fastapi.tiangolo.com/)
- [Uvicorn](https://www.uvicorn.org/)

## Структура проекта

\`\`\`
.
├── src/
│   └── main.py          # Точка входа
├── pyproject.toml       # Конфигурация проекта
├── README.md            # Описание проекта
└── .gitignore           # Исключения Git
\`\`\`
EOF
    print_success "README.md создан."
}

# Создание файла .gitignore.
create_gitignore() {
    print_step "Шаг 8: создание .gitignore."

    cat > .gitignore << EOF
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class

# C extensions
*.so

# Distribution / packaging
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
share/python-wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# PyInstaller
*.manifest
*.spec

# Installer logs
pip-log.txt
pip-delete-this-directory.txt

# Logs
/logs/

# Unit test / coverage reports
htmlcov/
.tox/
.nox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.py,cover
.hypothesis/
.pytest_cache/
cover/

# Translations
*.mo
*.pot

# Django stuff:
*.log
local_settings.py
db.sqlite3
db.sqlite3-journal

# Flask stuff:
instance/
.webassets-cache

# Scrapy stuff:
.scrapy

# Sphinx documentation
docs/_build/

# PyBuilder
.pybuilder/
target/

# Jupyter Notebook
.ipynb_checkpoints

# IPython
profile_default/
ipython_config.py

# PEP 582; used by e.g. github.com/David-OConnor/pyflow
__pypackages__/

# Celery stuff
celerybeat-schedule
celerybeat.pid

# SageMath parsed files
*.sage.py

# Environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# Spyder project settings
.spyderproject
.spyproject

# Rope project settings
.ropeproject

# mkdocs documentation
/site

# mypy
.mypy_cache/
.dmypy.json
dmypy.json

# Pyre type checker
.pyre/

# pytype static type analyzer
.pytype/

# Cython debug symbols
cython_debug/

# Editors
.vscode/
.idea/

# Vagrant
.vagrant/

# Mac/OSX
.DS_Store

# Windows
Thumbs.db

# pyenv
.python-version

# Project specific
functionalTesting/geckodriver.log
functionalTesting/swb/geckodriver
/other_files/
/getinfoapp/files/
EOF

    print_success "Файл .gitignore создан."
}

# Главная функция
main() {
    echo ""
    echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║     FastAPI Project Bootstrap Script                         ║${NC}"
    echo -e "${CYAN}${BOLD}║     Ubuntu 24.04 | WSL2 | UV | FastAPI                       ║${NC}"
    echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    check_uv
    ask_project_info
    setup_directory
    pin_python_version
    init_uv_project
    setup_venv
    install_dependencies
    # create_readme
    # create_gitignore
    # create_src
    # start_project
}

main "$@"