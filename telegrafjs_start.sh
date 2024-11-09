#!/bin/bash
# Telegraf with CommonJS.
# Step 1: asks user for the project name
echo "Prepare the telegram bot token in advance - you will need to add it when running this script."

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
# TODO: Create a package.json file. Add the project name to it.
# TODO: Create a README.md file. Add the project name to it.
# TODO: Create a bot.js file. Adding code for first run.
# TODO: Request a bot token.
# TODO: Creating a .env file. Saving the bot token in it. 
# TODO: Creating a .envexample file.
# TODO: Createing a .gitignore file.
# TODO: Install dependencies from package.json file.
# TODO: Start VSCode in project directory.
