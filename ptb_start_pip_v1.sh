#!/bin/bash
# shellcheck disable=SC1091
# Bash script for starting projects with python-telegram-bot.
# Author: Valeriy Kornienko <vikornienko76@gmail.com>
# Step 1: asks user for the project name
echo "Prepare the telegram bot token in advance - you will need to add it when running this script."

echo "Enter the project name: " 
read -r project_name
echo "Enter description: "
read -r description

# Step 2: Create the projects directoty (if not exist) and the project structure.
if ! [ -d ./"$project_name" ] 
then
echo "Directory $project_name does not exist but will be created."
mkdir "$project_name"
fi
cd ./"$project_name" || exit && echo "Exit from string 18."

# Step 3: create the virtual environment
python3 -m venv .venv

# Step 4: Activate the virtual environment
source .venv/bin/activate

# Step 5: Create a README.md file. Add the project name to it.
cat <<EOF >README.md
# $project_name

A repository for self-study on writing telegram bots on ptb.

$description
To create the bot in this repository, the following were used:
- python-telegram-bot library;
- python-dotenv library for storing variables in the .env file;
- py-mon for automatically applying changes to files;
- sqlite3 as database.
For starting bot use command in terminal: pymon bot.py.
Or using Makefile like this repository.
EOF

# Step 6: Create the .gitignore file
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

# Step 7: Request the bot token.
echo "Enter bot token: "
read -r token
# Step 8: Creating a .env file. Saving the bot token in it.
cat <<EOF >.env
BOT_TOKEN="$token"
EOF
# Step 9: Creating the .env.example file.
cat <<EOF >.env.example
BOT_TOKEN="insert_your_token_here"
EOF

# Step 11: Create the makefile
cat <<EOF >Makefile
.PHONY: start
start:
    pymon bot.py
EOF

# Step 10: Install python packages
pip install python-telegram-bot py-mon python-dotenv

# Step 11: Create bot.py file.
