#!/bin/bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

# mac セットアップ: Claude Code (CLI) / vim (vim-plug + プラグイン) / VS Code settings + 拡張機能
# 実行方法:
#   ./install_all.sh

echo "== Claude Code (CLI) =="
curl -fsSL https://claude.ai/install.sh | bash

# ~/.local/bin を PATH に追加 (未設定の場合のみ)
if ! grep -q '\.local/bin' ~/.zshrc 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
fi

echo "== vim =="
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
cp ../linux/.vimrc ~/
vim -c PlugInstall -c q -c q!
mkdir -p ~/.vim/colors
cp ~/.vim/plugged/jellybeans.vim/colors/jellybeans.vim ~/.vim/colors/

echo "== VS Code settings =="
vscode_dir="$HOME/Library/Application Support/Code/User"
mkdir -p "$vscode_dir"
cp ../vscode/settings.json "$vscode_dir/"

echo "== VS Code extensions =="
if command -v code >/dev/null 2>&1; then
    ../vscode/install.sh
else
    echo "'code' command not found. VS Code のコマンドパレットで 'Shell Command: Install code command in PATH' を実行後、../vscode/install.sh を実行してください。"
fi

echo "Done. Restart your shell, then run: claude"
