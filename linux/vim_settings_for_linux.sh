#!/bin/bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

# Build vim from source and install plugins (Ubuntu)
# Conda 環境は事前に deactivate しておくこと!

sudo apt-get update
sudo apt-get install -y git tmux python3-dev python3-venv libncurses5-dev libx11-dev \
    libxtst-dev libxt-dev libsm-dev libxpm-dev silversearcher-ag curl build-essential

# Japanese folder name -> English folder name
LANG=C xdg-user-dirs-gtk-update || true

# python3 config dir を自動検出
PYTHON3_CONFIG_DIR="$(python3-config --configdir)"

build_dir="$(mktemp -d)"
trap 'rm -rf "$build_dir"' EXIT
git clone --depth 1 https://github.com/vim/vim.git "$build_dir/vim"
(
    cd "$build_dir/vim"
    ./configure --with-features=huge \
                --enable-multibyte \
                --disable-rubyinterp \
                --enable-python3interp \
                --with-python3-config-dir="$PYTHON3_CONFIG_DIR" \
                --disable-perlinterp \
                --disable-luainterp \
                --enable-fail-if-missing \
                --prefix=/usr/local \
                --disable-gui \
                --with-x
    make -j"$(nproc)"
    sudo make install
)

# change symbolic link for vi
sudo ln -sf /usr/local/bin/vim /usr/bin/vi

# install plugins
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
cp ./.vimrc ~/
vim -c PlugInstall -c q -c q!
mkdir -p ~/.vim/colors
cp ~/.vim/plugged/jellybeans.vim/colors/jellybeans.vim ~/.vim/colors/
