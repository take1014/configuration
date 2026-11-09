#!/bin/bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

# Raspberry Pi (Raspberry Pi OS / Debian 系) セットアップ:
#   vim (apt 版) / tmux / bash 設定 / Claude Code (CLI)
# 実行方法:
#   ./install_all.sh   (スクリプト全体を sudo で実行する必要はありません)

echo "== Install packages =="
sudo apt-get update
sudo apt-get full-upgrade -y
sudo apt-get install -y vim tmux git curl silversearcher-ag python3-dev python3-venv

# vi -> vim
sudo ln -sf /usr/bin/vim /usr/bin/vi

echo "== vim plugins =="
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
cp ../linux/.vimrc ~/
vim -c PlugInstall -c q -c q!
mkdir -p ~/.vim/colors
cp ~/.vim/plugged/jellybeans.vim/colors/jellybeans.vim ~/.vim/colors/

echo "== tmux =="
cp ../linux/.tmux.conf ~/

echo "== bashrc =="
# 未設定の場合のみ追記
if ! grep -q '# --- raspi install_all.sh ---' ~/.bashrc 2>/dev/null; then
    cat >> ~/.bashrc <<'RC'

# --- raspi install_all.sh ---
alias ls='ls --color'
alias ll='ls -a'
export CLICOLOR=1
export EDITOR='vim'
export PS1='\u@\h:\[\e[01;32m\]\w\[\e[0m\]\$ '
RC
fi

echo "== Claude Code (CLI) =="
# ネイティブインストーラは 64bit OS (aarch64) が必要
if [ "$(uname -m)" = "aarch64" ] || [ "$(uname -m)" = "x86_64" ]; then
    curl -fsSL https://claude.ai/install.sh | bash
    # ~/.local/bin を PATH に追加 (未設定の場合のみ)
    if ! grep -q '\.local/bin' ~/.bashrc 2>/dev/null; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    fi
else
    echo "[WARN] $(uname -m) は未対応のため Claude Code のインストールをスキップします (64bit OS が必要)。"
fi

echo "Done. Restart your shell (or: source ~/.bashrc), then run: claude"
