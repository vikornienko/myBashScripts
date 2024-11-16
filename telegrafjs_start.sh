#!/bin/bash
# Telegraf with CommonJS.
# Author: Valeriy Kornienko vikornienko76@gmail.com
# Step 1: asks user for the project name
echo "Prepare the telegram bot token in advance - you will need to add it when running this script."

echo "Enter the project name: " 
read -r project_name

echo "Enter directory for project: "
read -r directory_name

echo "Enter author name: "
read -r author_name

echo "Enter description: "
read -r description

# Step 2: navigete to projects directoty and create directory (if not exist) and project folder
if ! [ -d ./"$directory_name" ] 
then
echo "Directory $directory_name does not exist but will be created."
mkdir "$directory_name"
fi
cd ./"$directory_name" || exit
# Step 2: Create a package.json file. Add the project name to it.
cat <<EOF >package.json
{
  "name": "$project_name",
  "version": "1.0.0",
  "description": "$description",
  "main": "bot.js",
  "scripts": {
    "start": "nodemon bot.js",
    "start:debug": "nodemon --inspect bot.js",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [
    "node.js",
    "telegraf.js"
  ],
  "author": "$author_name",
  "license": "ISC",
  "dependencies": {
    "dotenv": "^16.4.5",
    "telegraf": "^4.16.3"
  },
  "devDependencies": {
    "nodemon": "^3.1.7"
  }
}
EOF
# Step 3: Create a README.md file. Add the project name to it.
cat <<EOF >README.md
# $project_name

A repository for self-study on writing telegram bots on node.js.

$description
To create the bot in this repository, the following were used:
- telegraf node.js library;
- dotenv library for storing variables in the .env file;
- nodemon for automatically applying changes to files.
EOF
# Step 4: Create a bot.js file. Adding code for first run.
cat <<EOF >bot.js
require('dotenv').config()
const { Telegraf } = require('telegraf')
const { message } = require('telegraf/filters')

const bot = new Telegraf(process.env.BOT_TOKEN)
bot.start((ctx) => ctx.reply('Welcome'))
bot.help((ctx) => ctx.reply('Send me a sticker'))
bot.on(message('sticker'), (ctx) => ctx.reply('👍'))
bot.hears('hi', (ctx) => ctx.reply('Hey there'))
bot.launch()

// Enable graceful stop
process.once('SIGINT', () => bot.stop('SIGINT'))
process.once('SIGTERM', () => bot.stop('SIGTERM'))
EOF
# Step 5: Request a bot token.
echo "Enter bot token: "
read -r token
# Step 6: Creating a .env file. Saving the bot token in it.
cat <<EOF >.env
BOT_TOKEN="$token"
EOF
# Step 7: Creating a .envexample file.
cat <<EOF >.envexample
BOT_TOKEN="insert_your_token_here"
EOF
# Step 8: Createing a .gitignore file.
cat <<EOF >.gitignore
/dist
/node_modules
/.vscode
file.txt
.env
EOF
# Step 9: Install dependencies from package.json file.
npm i
# Step 10: Start VSCode in project directory.
code .