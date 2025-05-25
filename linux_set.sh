#!/bin/bash
# shellcheck disable=SC1091
# Author: Valeriy Kornienko vikornienko76@gmail.com
# This script using for node js and python development settings.
# 1. Install python for development:
# Instructions from
# https://www.digitalocean.com/community/tutorials/how-to-install-python-3-and-set-up-a-programming-environment-on-an-ubuntu-22-04-server
sudo apt install -y python3-pip
sudo apt install -y build-essential libssl-dev libffi-dev python3-dev
sudo apt install -y python3-venv

# 2. Install pipx and uv;
# Instructions for pipx installation from https://pipx.pypa.io/stable/installation/
sudo apt install pipx
pipx ensurepath
# Instructions for uv installation from 
#https://docs.astral.sh/uv/getting-started/installation/#standalone-installer
pipx install uv

# 3. Install sqlite3
sudo apt install sqlite3

# 4. Install nvm and node js.