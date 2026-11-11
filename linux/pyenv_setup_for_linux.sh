#!/bin/bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ../common/lib.sh

# pyenv + pyenv-virtualenv + poetry setup (Ubuntu / bash)

# install dependencies
sudo apt-get update
sudo apt-get install -y git build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev curl llvm \
    libncurses-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev \
    liblzma-dev libsasl2-dev python3-dev libldap2-dev python3-poetry

# clone pyenv / pyenv-virtualenv (skip if already present)
export PYENV_ROOT="$HOME/.pyenv"
[ -d "$PYENV_ROOT" ] || git clone https://github.com/pyenv/pyenv.git "$PYENV_ROOT"
[ -d "$PYENV_ROOT/plugins/pyenv-virtualenv" ] || \
    git clone https://github.com/pyenv/pyenv-virtualenv.git "$PYENV_ROOT/plugins/pyenv-virtualenv"

# add settings to .bashrc (marker block; re-running replaces it)
append_block ./.bashrc_pyenv ~/.bashrc

# set poetry's workdir
poetry config virtualenvs.in-project true

echo "Done. Restart your shell (or: source ~/.bashrc)"
