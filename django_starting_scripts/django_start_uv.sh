#!/usr/bin/env bash
# shellcheck disable=SC1091
# Author: Valeriy Kornienko vikornienko76@gmail.com

set -e  # Exit on any error

# Function to get user input with validation
get_user_input() {
    local prompt="$1"
    local var_name="$2"
    local validation_func="$3"
    
    while true; do
        echo -n "$prompt: "
        read -r input
        
        if [[ -n "$input" ]] && { [[ -z "$validation_func" ]] || "$validation_func" "$input"; }; then
            eval "$var_name='$input'"
            break
        else
            echo "Invalid input. Please try again."
        fi
    done
}

# Function to validate project name
validate_project_name() {
    local name="$1"
    [[ "$name" =~ ^[a-zA-Z][a-zA-Z0-9_-]*$ ]]
}

# Function to validate Python version
validate_python_version() {
    local version="$1"
    [[ "$version" =~ ^3\.[0-9]+$ ]]
}

# Function to create README.md
create_readme() {
    local project_name="$1"
    local description="$2"
    
    cat > README.md << EOF
# $project_name

$description

## Setup

This project uses uv for dependency management.

## Commands

- \`make rs\` - Run development server
- \`make mm\` - Make migrations
- \`make mig\` - Apply migrations
- \`make csu\` - Create superuser
- \`make sa\` - Start new app
EOF
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
setup_django_project() {
    local project_name="$1"
    
    echo "Adding Django dependency..."
    uv add django
    
    echo "Creating Django project..."
    uv run django-admin startproject "$project_name"
}

# Function to cleanup files
cleanup_files() {
    echo "Cleaning up unnecessary files..."
    rm -f main.py 2>/dev/null || true
    rm -f .gitignore 2>/dev/null || true
}

# Main execution
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


