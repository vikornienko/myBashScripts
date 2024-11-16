#!/bin/bash
# shellcheck disable=SC1091
# Author: Valeriy Kornienko vikornienko76@gmail.com

# Step 1: asks user for the project name
echo "Enter the project name: " 
read -r project_name

echo "Enter directory for project: "
read -r directory_name

# Step 2: navigete to projects directoty and create directory (if not exist) and project folder
if ! [ -d ./"$directory_name" ] 
then
echo "Directory $directory_name does not exist but will be created."
mkdir "$directory_name"
fi
cd ./"$directory_name" && mkdir "$project_name" && cd "$project_name" || exit

# Step 3: create the virtual environment
python3 -m venv .venv

# Step 4: Activate the virtual environment
source .venv/bin/activate

# Step 5: Install python packages
pip install django
# Install other pyghon packages if your project requires it. 
pip install pytest-playwright pytest-django python-dotenv 'sentry-sdk[django]'

# Step 6: Initialize the Django project
django-admin startproject "$project_name" .

# Step 7: Create the pytest.ini file.
cat <<EOF >pytest.ini
# -- FILE: pytest.ini (or tox.ini)
[pytest]
DJANGO_SETTINGS_MODULE = $project_name.settings
# -- recommended but optional:
python_files = tests.py test_*.py *_tests.py
EOF

# Step 8: Create the .gitignore file
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

# Step 9: create the makefile
cat <<EOF >Makefile
.PHONY: rs
rs:
	python3 manage.py runserver

.PHONY: mm
mm:
	python3 manage.py makemigrations

.PHONY: mig
mig:
	python3 manage.py migrate
EOF
# Step 10: create requirements-dev.txt file
pip freeze > requirements-dev.txt
# TODO: create .env file
# TODO: copy the key value in the settings.py file and move it to .env
# TODO: insert a link to the key value from the .env file into the settings.py file
# TODO: add in manage.py file code for python-dotenv settings
# TODO: add in settings.py file code for python-dotenv settings
# TODO: create django applications
# TODO: add script for firs start finctional test
# TODO: create README.md file
# TODO: initialize repozitory with first commit text
# TODO: vs code starting
# TODO: run django built-in server using Makefile
# TODO: run functional test for first start checking