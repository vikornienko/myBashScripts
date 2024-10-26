#!/bin/bash
# shellcheck disable=SC1091

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

# Step 4: Activate virtual environment
source .venv/bin/activate

# Step 5: Install python packages
pip install django pytest-playwright pytest-django python-dotenv 'sentry-sdk[django]'

# Step 6: Initialize the Django project
django-admin startproject "$project_name" .

# Step 7: Create pytest.ini file.
cat <<EOF >pytest.ini
# -- FILE: pytest.ini (or tox.ini)
[pytest]
DJANGO_SETTINGS_MODULE = $project_name.settings
# -- recommended but optional:
python_files = tests.py test_*.py *_tests.py
EOF

# TODO: add gitignore file.
# TODO: add make file.
# TODO: initialize repozitory
# TODO: vs code starting