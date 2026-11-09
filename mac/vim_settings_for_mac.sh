#!/bin/bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
cp ../linux/.vimrc ~/
vim -c PlugInstall -c q -c q!
mkdir -p ~/.vim/colors
cp ~/.vim/plugged/jellybeans.vim/colors/jellybeans.vim ~/.vim/colors/

# vs code
vscode_dir="$HOME/Library/Application Support/Code/User"
mkdir -p "$vscode_dir"
cp ../vscode/settings.json "$vscode_dir/"
