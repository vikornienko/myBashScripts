#!/bin/bash

# Step 1: asks user for the project name
echo "Enter the project name: " 
read -r project_name

# Step 2: navigete to projects directoty and create project folder
cd ../ && mkdir "$project_name" && cd "$project_name" || exit

# Step 3: create the virtual environment
python3 -m venv .venv

# Step 4: Activate virtual environment
source .venv/bin/activate

# Step 5: Install python packages
pip install django pytest-playwright pytest-django

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