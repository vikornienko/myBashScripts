#!/bin/bash
# Telegraf with CommonJS.
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

# Step 4: Create a bot.js file and other files. Adding code for first run.
# Create file bot.js
cat <<EOF >bot.js
require('dotenv').config()
const { Telegraf } = require('telegraf')
const { message } = require('telegraf/filters')
const { CommandHandler } = require('./handlers/commandHandler')

const bot = new Telegraf(process.env.BOT_TOKEN)

CommandHandler(bot)

bot.launch()

// Enable graceful stop
process.once('SIGINT', () => bot.stop('SIGINT'))
process.once('SIGTERM', () => bot.stop('SIGTERM'))
EOF
# Create file buttons.js
cat <<EOF >buttons.js
const Telegraf = require('telegraf')
const { Markup } = Telegraf

module.exports.InlineKeyboard = {
  buttons_start: () => {
    return Markup.inlineKeyboard([
      Markup.button.callback("Start", "start"),
    ])
  }
EOF
mkdir handlers && cd ./handlers || exit
cat <<EOF >commandHandler.js
const { InlineKeyboard } = require('../buttons')

module.exports.CommandHandler = (bot) => {
    bot.start(async (ctx) => {
        await ctx.replyWithHTML(
            "Привет! Я ${description}.",
            InlineKeyboard.buttons_start()
        )
    });
    bot.help(async (ctx) => {
        ctx.reply("Send me a sticker")
    });
}
EOF
# TODO: Add a callbackHandler.js file.
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
# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*
.pnpm-debug.log*

# Diagnostic reports (https://nodejs.org/api/report.html)
report.[0-9]*.[0-9]*.[0-9]*.[0-9]*.json

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Directory for instrumented libs generated by jscoverage/JSCover
lib-cov

# Coverage directory used by tools like istanbul
coverage
*.lcov

# nyc test coverage
.nyc_output

# Grunt intermediate storage (https://gruntjs.com/creating-plugins#storing-task-files)
.grunt

# Bower dependency directory (https://bower.io/)
bower_components

# node-waf configuration
.lock-wscript

# Compiled binary addons (https://nodejs.org/api/addons.html)
build/Release

# Dependency directories
node_modules/
jspm_packages/

# Snowpack dependency directory (https://snowpack.dev/)
web_modules/

# TypeScript cache
*.tsbuildinfo

# Optional npm cache directory
.npm

# Optional eslint cache
.eslintcache

# Optional stylelint cache
.stylelintcache

# Microbundle cache
.rpt2_cache/
.rts2_cache_cjs/
.rts2_cache_es/
.rts2_cache_umd/

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# dotenv environment variable files
.env
.env.development.local
.env.test.local
.env.production.local
.env.local

# parcel-bundler cache (https://parceljs.org/)
.cache
.parcel-cache

# Next.js build output
.next
out

# Nuxt.js build / generate output
.nuxt
dist

# Gatsby files
.cache/
# Comment in the public line in if your project uses Gatsby and not Next.js
# https://nextjs.org/blog/next-9-1#public-directory-support
# public

# vuepress build output
.vuepress/dist

# vuepress v2.x temp and cache directory
.temp
.cache

# Docusaurus cache and generated files
.docusaurus

# Serverless directories
.serverless/

# FuseBox cache
.fusebox/

# DynamoDB Local files
.dynamodb/

# TernJS port file
.tern-port

# Stores VSCode versions used for testing VSCode extensions
.vscode-test

# yarn v2
.yarn/cache
.yarn/unplugged
.yarn/build-state.yml
.yarn/install-state.gz
.pnp.*
EOF
# Step 9: Install dependencies from package.json file.
npm i
# Step 10: Start VSCode in project directory.
code .