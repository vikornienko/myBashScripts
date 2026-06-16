#!/usr/bin/env bash
# shellcheck disable=SC1091
################################################################
# Author: Valeriy Kornienko vikornienko76@gmail.com
# Version: 2.0.0.
# This script is used for the initial setup of a Django project.
# Saquence of actions:
# - prompts for the project name;
# - prompts for the Python version;
# - installs the virtuals environment and activate it;
# - removes unnecessary files;
# - add files: .gitignore, README.md, Makefile;
# - install Django dependencies;
# - creates the Django project;
# - starts the development server to verifuy the installation.
#################################################################

set -euo pipefail  # Exit on any error

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
    print_step "Шаг 3: закрепляем версию python."

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


# Function to create README.md
# TODO: переделать Make на Just
create_readme() {
    print_step "Шаг 6: создание файла README.md"
        
    cat > README.md << 'EOF'
# $PROJECT_NAME

$PROJECT_DESCRIPTION

## Setup

This project uses uv for dependency management.

## Commands

- \`make rs\` - Run development server
- \`make mm\` - Make migrations
- \`make mig\` - Apply migrations
- \`make csu\` - Create superuser
- \`make sa\` - Start new app
EOF

    print_success "Файл README.md создан."
}

# Function to create .gitignore
create_gitignore() {

    cat > .gitignore << 'EOF'
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
}

# Function to create Makefile
# TODO: переделать Make на Just
create_makefile() {
    local project_name="$1"
    
    cat > Makefile << EOF
.PHONY: rs mm mig csu sa

rs:
	uv run $project_name/manage.py runserver

mm:
	uv run $project_name/manage.py makemigrations

mig:
	uv run $project_name/manage.py migrate

csu:
	uv run $project_name/manage.py createsuperuser

sa:
	@echo -n "Enter app name: "; read app_name; uv run $project_name/manage.py startapp \$\$app_name
EOF
}

# Function to setup Django project
# TODO: переписать функцию в связи с новыми переменными
setup_django_project() {
    local project_name="$1"
    
    echo "Adding Django dependency..."
    uv add django
    
    echo "Creating Django project..."
    uv run django-admin startproject "$project_name"
}

# TODO: Добавить создание документов для проекта
# TODO: Добавить файл настройки ruff
# TODO: Добавить файл настройки тайп чеккера
# TODO: Добавить файл настройки pre-commit
# TODO: Добавить директорию для тестов
# TODO: Добавить функцию для установки зависимостей
# Main execution
# TODO: переписать функцию в связи с новыми функциями и переменными
main() {
    echo "=== Django Project Setup with UV ==="
    echo
    
    # Get user input
    get_user_input "Enter the project name" "project_name" "validate_project_name"
    get_user_input "Enter Python version (e.g., 3.11)" "python_version" "validate_python_version"
    get_user_input "Enter the project description" "project_description"
    
    echo
    echo "Creating project '$project_name' with Python $python_version..."
    
    # Create and initialize project
    uv init "$project_name" --python "$python_version"
    cd "$project_name" || { echo "Failed to enter project directory"; exit 1; }
    
    # Create virtual environment
    echo "Creating virtual environment..."
    uv venv
    
    # Setup project files
    cleanup_files
    create_readme "$project_name" "$project_description"
    create_gitignore
    create_makefile "$project_name"
    
    # Setup Django
    setup_django_project "$project_name"
    
    echo
    echo "✅ Project '$project_name' created successfully!"
    echo "📁 Location: $(pwd)"
    echo
    echo "Available commands:"
    echo "  make rs  - Run development server"
    echo "  make mm  - Make migrations"
    echo "  make mig - Apply migrations"
    echo "  make csu - Create superuser"
    echo "  make sa  - Start new app"
    echo
    
    # Ask if user wants to start the server
    echo -n "Start development server now? (y/N): "
    read -r start_server
    if [[ "$start_server" =~ ^[Yy]$ ]]; then
        make rs
    fi
}

# Run main function
main "$@"


