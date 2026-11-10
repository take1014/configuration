#!/bin/bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ../common/lib.sh

# Raspberry Pi (Raspberry Pi OS / Debian-based) setup:
#   vim (apt version) / tmux / bashrc / Claude Code (CLI)
# Usage:
#   ./install_all.sh   (do not run the whole script with sudo)

echo "== Install packages =="
sudo apt-get update
sudo apt-get full-upgrade -y
sudo apt-get install -y vim tmux git curl silversearcher-ag xsel python3-dev python3-venv

# vi -> vim
sudo ln -sf /usr/bin/vim /usr/bin/vi

echo "== vim plugins =="
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
copy_file ../linux/.vimrc ~/.vimrc
vim -c PlugInstall -c q -c q!
mkdir -p ~/.vim/colors
cp ~/.vim/plugged/jellybeans.vim/colors/jellybeans.vim ~/.vim/colors/

echo "== dotfiles =="
# Append the repo's linux/.bashrc contents to .bashrc; copy .tmux.conf
append_block ../linux/.bashrc ~/.bashrc
copy_file ../linux/.tmux.conf ~/.tmux.conf

# Install the CLI (64-bit OS only) + set PATH + place CLAUDE.md / agents
../claude/install.sh

echo "Done. Restart your shell (or: source ~/.bashrc), then run: claude"
