#!/bin/bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

sudo apt-get update
sudo apt-get full-upgrade -y
sudo apt-get install -y vim tmux curl python3-dev python3-venv libncurses5-dev libx11-dev libxtst-dev libxt-dev libsm-dev libxpm-dev

# change symbolic link for vi
sudo ln -sf /usr/bin/vim /usr/bin/vi

# install plugins
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
cp ../linux/.vimrc ~/
vim -c PlugInstall -c q -c q!
mkdir -p ~/.vim/colors
cp ~/.vim/plugged/jellybeans.vim/colors/jellybeans.vim ~/.vim/colors/
cp ../linux/.tmux.conf ~/

# edit bashrc (未設定の場合のみ追記)
if ! grep -q '# --- raspi install.sh ---' ~/.bashrc 2>/dev/null; then
    cat >> ~/.bashrc <<'RC'

# --- raspi install.sh ---
alias ls='ls --color'
alias ll='ls -a'
export CLICOLOR=1
export EDITOR='vim'
export PS1='\u@\h:\[\e[01;32m\]\w\[\e[0m\]\$ '
RC
fi

echo "Done. Restart your shell (or: source ~/.bashrc)"
