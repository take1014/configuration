#!/bin/bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ../common/lib.sh

# mac セットアップ: Claude Code (CLI) / vim (vim-plug + プラグイン) / VS Code settings + 拡張機能 / dotfiles (.zshrc, .tmux.conf)
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
copy_file ../linux/.vimrc ~/.vimrc
vim -c PlugInstall -c q -c q!
mkdir -p ~/.vim/colors
cp ~/.vim/plugged/jellybeans.vim/colors/jellybeans.vim ~/.vim/colors/

echo "== dotfiles =="
# .zshrc はリポジトリの内容を追記、.tmux.conf (linux と共用) はコピー
append_block ./.zshrc ~/.zshrc
if ! command -v tmux >/dev/null 2>&1; then
    if command -v brew >/dev/null 2>&1; then
        brew install tmux
    else
        echo "[WARN] tmux が未インストールで brew も見つかりません。tmux を入れてください。"
    fi
fi
copy_file ../linux/.tmux.conf ~/.tmux.conf

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
