#!/bin/bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ../common/lib.sh

# mac setup: Claude Code (CLI) / vim (vim-plug + plugins) / VS Code settings + extensions / dotfiles (.zshrc, .tmux.conf)
# Usage:
#   ./install_all.sh

# Install the CLI + set PATH + place CLAUDE.md / agents
../claude/install.sh

echo "== vim =="
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
copy_file ../linux/.vimrc ~/.vimrc
vim -c PlugInstall -c q -c q!
mkdir -p ~/.vim/colors
cp ~/.vim/plugged/jellybeans.vim/colors/jellybeans.vim ~/.vim/colors/

echo "== dotfiles =="
# Append the repo's .zshrc contents; copy .tmux.conf (shared with linux)
append_block ./.zshrc ~/.zshrc
if ! command -v tmux >/dev/null 2>&1; then
    if command -v brew >/dev/null 2>&1; then
        brew install tmux
    else
        echo "[WARN] tmux is not installed and brew was not found. Please install tmux."
    fi
fi
copy_file ../linux/.tmux.conf ~/.tmux.conf

echo "== VS Code settings =="
vscode_dir="$HOME/Library/Application Support/Code/User"
mkdir -p "$vscode_dir"
copy_file ../vscode/settings.json "$vscode_dir/settings.json"

echo "== VS Code extensions =="
if command -v code >/dev/null 2>&1; then
    ../vscode/install.sh
else
    echo "'code' command not found. Run 'Shell Command: Install code command in PATH' from the VS Code command palette, then run ../vscode/install.sh."
fi

echo "Done. Restart your shell, then run: claude"
