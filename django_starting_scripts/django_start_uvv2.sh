#!/usr/bin/env bash
# shellcheck disable=SC1091
################################################################
# Author: Valerij Kornienko vikornienko76@gmail.com
# Version: 2.0.0.
# This script is used for the initial setup of a Django project.
# Saquence of actions:
# - prompts for the project name;
# - prompts for the Python version;
# - installs the virtuals environment and activate it;
# - removes unnecessary files;
# - add files: .gitignore, README.md, Makefile, ruff.toml;
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
    PROJECT_DESCRIPTION="${PROJECT_DESCRIPTION:-Учебный проект на Django}"

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
    local project_name="$PROJECT_NAME"
    
    cat > Makefile << EOF
.PHONY: rs mm mig csu sa rc rcf rf rfc rm

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

rc:
    uv run ruff check .

rcf:
    uv run ruff check . --fix

rf:
    uv run ruff format .

rfc:
    uv run ruff format --check .

rm:
    uv run mypy --config-file mypy.ini
EOF
}

# Function to creat the ruff.toml file
create_rufftomlfile() {
    cat > ruff.toml << EOF
    # ---------- Общие настройки ----------
target-version = "py313"
line-length = 88

# Корни исходного кода.
# Нужно в основном для правильного определения first-party импортов.
# Если у вас исходники лежат в директории `src`, укажите ["src"].
src = ["$PROJECT_NAME"]

extend-exclude = [
    ".git",
    ".venv",
    ".mypy_cache",
    ".pytest_cache",
    ".ruff_cache",
    "htmlcov",
    "media",
    "static",
    "**/migrations",
]

# ---------- Линтер ----------
[lint]
select = [
    "E",    # pycodestyle errors
    "W",    # pycodestyle warnings
    "F",    # pyflakes
    "I",    # isort
    "N",    # pep8-naming
    "UP",   # pyupgrade
    "B",    # flake8-bugbear
    "A",    # flake8-builtins
    "C4",   # flake8-comprehensions
    "C90",   # mccabe: контроль цикломатической сложности функций
    "T20",   # flake8-print: запрет print()/pprint() — только logging
    "PERF",  # Perflint: очевидные проблемы производительности
    "ARG",  # flake8-unused-arguments
    "SIM",  # flake8-simplify
    "PT",   # flake8-pytest-style
    "DJ",   # flake8-django
    "S",    # flake8-bandit — проверка безопасности
    "RUF",  # собственные правила Ruff
    # Подмножество pylint без самых шумных правил.
    "PLC",
    "PLE",
    "PLW",
]

ignore = [
    "DJ001",  # null=True на CharField/TextField
]

fixable = ["ALL"]
unfixable = []

[lint.per-file-ignores]
# settings.py: допустимы "звёздочные" импорты и длинные строки конфигов,
# а также hardcoded SECRET_KEY в примере/дев-настройках
"*/settings/*.py" = ["E501", "F403", "F405", "S105", "S106"]

# В тестах: assert — обычная практика pytest, hardcoded-пароли для фикстур — ок
"tests/*.py" = ["S101", "S105", "S106", "S608", "PLR2004"]
"*/test_*.py" = ["S101", "S105", "S106"]
"conftest.py" = ["S101"]

"*/migrations/*.py" = ["E501", "N806"]

[lint.isort]
known-first-party = ["$PROJECT_NAME"]
section-order = [
    "future",
    "standard-library",
    "third-party",
    "django",
    "first-party",
    "local-folder",
]

[lint.isort.sections]
django = ["django"]

[lint.pep8-naming]
classmethod-decorators = ["classmethod", "django.utils.decorators.classproperty"]

# ---------- Настройка flake8-bandit (правила S) ----------
[lint.flake8-bandit]
# Разрешённые для использования без предупреждения функции хеширования
# (например, если где-то нужен md5 не для паролей, а для чек-сумм файлов)
hash-builtin-functions = []

# Если в коде используете subprocess/os.system — можно разрешить
# конкретные "безопасные" случаи через noqa с указанием кода, а не глобально

# ---------- Форматтер ----------
[format]
quote-style = "double"
indent-style = "space"
skip-magic-trailing-comma = false
line-ending = "lf"
docstring-code-format = true
EOF
}

# Function to create mypy.ini file
create_mypyini() {
    cat > mypy.ini << EOF
    [mypy]
python_version = 3.13
strict = true
plugins = mypy_django_plugin.main

# Путь к модулю настроек Django — обязателен для плагина
# (можно вынести в переменную окружения DJANGO_SETTINGS_MODULE)

mypy_path = "$PROJECT_NAME"

# Базовая строгость — хороший баланс для учебного проекта
check_untyped_defs = true
disallow_untyped_defs = false        # пока не требуем типизировать абсолютно всё
disallow_incomplete_defs = true
warn_redundant_casts = true
warn_unused_ignores = true
warn_unused_configs = true
warn_return_any = true
no_implicit_optional = true
strict_equality = true
show_error_codes = true
show_error_context = true
show_column_numbers = true
pretty = true

# Игнорируем отсутствие типов у некоторых пакетов
ignore_missing_imports = false

# Не проверяем автогенерированные миграции
exclude = (?x)(^\.git/ | ^\.venv/ | ^\.mypy_cache/ | ^\.pytest_cache/ | ^\.ruff_cache/ | ^htmlcov/ | ^build/ | ^dist/ | ^migrations/ | ^.*/migrations/)

[mypy.plugins.django-stubs]
django_settings_module = "$PROJECT_NAME.settings"
# замените "config.settings" на реальный путь к вашему settings.py

# ---------- Исключения для сторонних библиотек без типов ----------
[mypy-playwright.*]
ignore_missing_imports = true

[mypy-pytest_django.*]
ignore_missing_imports = true

# ---------- Отдельные модули внутри проекта ----------
# В тестах можно быть менее строгим
[mypy-tests.*]
disallow_untyped_defs = false
check_untyped_defs = false

# В миграциях вообще не проверяем типы (на случай если exclude не сработает)
[mypy-*.migrations.*]
ignore_errors = true
EOF
}

# Function to setup pre-commit
create_precommit() {
    cat > .pre-commit-config.yaml << 'EOF'
    # Конфигурация pre-commit для Django-проекта.
#
# Предполагается:
# - проект работает в WSL2 Ubuntu 24.04;
# - ruff и mypy установлены локально;
# - настройки Ruff находятся в файле ruff.toml;
# - настройки Mypy находятся в файле mypy.ini.
#
# Если вы используете uv-окружение проекта, хуки запускаются через `uv run`.
# Это гарантирует, что будут использованы версии инструментов из окружения проекта.
#
# Если вы установили ruff и mypy глобально и они доступны в PATH без uv,
# замените:
#   uv run ruff ... -> ruff ...
#   uv run mypy ... -> mypy ...

fail_fast: false

repos:
  - repo: local
    hooks:
      # Проверка линтером с автоматическими исправлениями.
      - id: ruff-check
        name: Ruff check (auto-fix)
        entry: uv run ruff check --config ruff.toml --fix --exit-non-zero-on-fix
        language: system
        types_or: [python, pyi]
        require_serial: true

      # Форматирование кода.
      - id: ruff-format
        name: Ruff format
        entry: uv run ruff format --config ruff.toml
        language: system
        types_or: [python, pyi]
        require_serial: true

      # Проверка типов через mypy и django-stubs.
      #
      # pass_filenames: false важен для mypy:
      # лучше проверять весь проект целиком, а не только изменённые файлы,
      # так как Django-модели, формы, настройки и приложения связаны между собой.
      - id: mypy
        name: Mypy (Django)
        entry: uv run mypy --config-file mypy.ini .
        language: system
        types_or: [python, pyi]
        pass_filenames: false
        require_serial: true

        # Если для импорта настроек Django нужны переменные окружения,
        # раскомментируйте и укажите нужные значения.
        #
        # Например:
        #
        # env:
        #   DJANGO_SETTINGS_MODULE: config.settings
        #   DEBUG: "1"
        #   SECRET_KEY: "local-typecheck-only-key"
EOF
    }

# Function to setup Django project
setup_django_project() {
    local project_name="$PROJECT_NAME"
    
    echo "Adding Django dependency..."
    uv add django django-environ
    uv add --dev mypy django-stubs django-stubs-ext ruff pytest pytest-django pytest-cov django-debug-toolbar pre-commit
    uv run pre-commit install
    
    echo "Creating Django project..."
    uv run django-admin startproject "$project_name"
}

# Function for first start project
start_project() {
    make rs
}

# TODO: Добавить создание документов для проекта
# TODO: Добавить директорию для тестов
# TODO: Добавить функцию для старта сервера для проверки правильности установки
# Main execution
# TODO: переписать функцию в связи с новыми функциями и переменными
main() {
    echo ""
    echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║     Django Project Bootstrap Script                          ║${NC}"
    echo -e "${CYAN}${BOLD}║     Ubuntu 24.04 | WSL2 | UV | Django                        ║${NC}"
    echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    check_uv
    ask_project_info
    setup_directory
    pin_python_version
    init_uv_project
    setup_venv
    create_readme
    create_gitignore
    create_makefile
    create_rufftomlfile
    create_mypyinifile
    create_precommit
    setup_django_project
    start_project    
}

# Run main function
main "$@"
