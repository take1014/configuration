#!/bin/bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ../common/lib.sh

# Raspberry Pi (Raspberry Pi OS / Debian 系) セットアップ:
#   vim (apt 版) / tmux / bashrc / Claude Code (CLI)
# 実行方法:
#   ./install_all.sh   (スクリプト全体を sudo で実行する必要はありません)

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
# .bashrc はリポジトリ (linux/.bashrc) の内容を追記、.tmux.conf はコピー
append_block ../linux/.bashrc ~/.bashrc
copy_file ../linux/.tmux.conf ~/.tmux.conf

# CLI 本体のインストール (64bit OS のみ) + PATH + CLAUDE.md / agents の配置
../claude/install.sh

echo "Done. Restart your shell (or: source ~/.bashrc), then run: claude"
