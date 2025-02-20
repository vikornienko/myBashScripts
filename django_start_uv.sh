#! /bin/bash
# shellcheck disable=SC1091
# Author: Valeriy Kornienko vikornienko76@gmail.com

# Step 1: asks user for the project name
echo "Enter the project name: " 
read -r project_name

# Step 2: navigate to projects directoty and create directory (if not exist)
if ! [ -d ./"$project_name" ] 
then
echo "Directory $project_name does not exist but will be created."
mkdir "$project_name"
fi
cd "$project_name" || exit

# Step 3: init project using uv.
uv init .

