#! /bin/bash
# shellcheck disable=SC1091
# Author: Valeriy Kornienko vikornienko76@gmail.com

# Step 1: asks user for the project name and python version
echo "Enter the project name: " 
read -r project_name

echo "Enter python version: "
read -r python_version

# Step 2: navigate to projects directoty and create directory (if not exist)
# Old code.
# if ! [ -d ./"$project_name" ] 
# then
# echo "Directory $project_name does not exist but will be created."
# mkdir "$project_name"
# fi
# cd "$project_name" || exit
# Step 2 v.2:
# Create project directory and init project
uv init "$project_name"

# Step 3: Create venv with the requered version of python.
cd "$project_name" || exit && echo "The project directory was not created."
uv venv --python "$python_version"

# Step 4: Fill README.md file.

echo "Enter the project description: "
read -r project_description

{
  echo "# $project_name"
  echo ""
  echo "$project_description"
} > README.md

# Step 5: Delete .gitignore and add new.
rm -f .gitignore || exit && echo "The file .gitignore was not deleted"

cat <<EOF >.gitignore
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*\$py.class

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
#  Usually these files are written by a python script from a template
#  before PyInstaller builds the exe, so as to inject date/other infos into it.
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

functionalTesting/geckodriver.log

functionalTesting/swb/geckodriver

/other_files/
/getinfoapp/files/
EOF

# Step 4: Add django and create django project.
uv add django
uv run django-admin startproject "$project_name"

# Step 6: create the makefile
cat <<EOF >Makefile
.PHONY: rs
rs:
	uv run manage.py runserver

.PHONY: mm
mm:
	uv run manage.py makemigrations

.PHONY: mig
mig:
	uv run manage.py migrate

.PHONY: csu
mig:
	uv run manage.py createsuperuser

.PHONY: sa
mig:
	uv run manage.py startapp
EOF

# Step 7: start server
make rs


