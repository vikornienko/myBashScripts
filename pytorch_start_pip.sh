#!/bin/bash
# shellcheck disable=SC1091

# Step 1: asks user for the project name
echo "Enter the project name: " 
read -r project_name

echo "Enter description"
read -r description

# Step 2: navigate to projects directoty and create directory (if not exist)
if ! [ -d ./"$project_name" ] 
then
echo "Directory $project_name does not exist but will be created."
mkdir "$project_name"
fi
cd ./"$project_name" || exit

# Step 3: create the virtual environment
python3 -m venv .venv

# Step 4: Activate the virtual environment
source .venv/bin/activate

# Step 5: Install python packages
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

# Step 6: Create .gitignore file.
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

# Step 7: create README.md
cat <<EOF >README.md
# $project_name

$description
EOF

# Step 6: add main.py file.
cat <<EOF >main.py
import torch

print(torch.__version__)
EOF

# Step 7: start VS Code
code .


