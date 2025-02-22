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

# Step 4: Add django and create django project.
uv add django
uv run django-admin startproject "$project_name" .


