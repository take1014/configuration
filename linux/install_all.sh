#!/bin/bash
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ../common/lib.sh

# Linux (Ubuntu) required setup: docker / VS Code / Claude Code / vim / dotfiles
# Usage:
#   ./install_all.sh              # the required components
#   ./install_all.sh --nvidia     # also add the NVIDIA Container Toolkit to docker
#   (do not run the whole script with sudo)
# Continues past failures and prints a summary at the end.

WITH_NVIDIA=0
[ "${1:-}" = "--nvidia" ] && WITH_NVIDIA=1

# ---------------------------------------------------------------- docker
install_docker() (
    set -euo pipefail
    ARCH="$(dpkg --print-architecture)"
    CODENAME="$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")"

    echo "== Install Docker =="
    # Remove the repo entry/keyring written by older versions of this script
    # (a different Signed-By for the same repo makes every apt-get update fail)
    sudo rm -f /etc/apt/sources.list.d/docker.list /usr/share/keyrings/docker-archive-keyring.gpg
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${CODENAME} stable" \
        | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl enable --now docker
    sudo docker --version
    sudo usermod -aG docker "$USER"

    echo "== Install QEMU (binfmt for multi-arch containers) =="
    # Ubuntu's qemu-user-static registers binfmt handlers persistently; no helper container needed
    sudo apt-get install -y qemu-user-static binfmt-support

    if [ "$WITH_NVIDIA" -eq 1 ]; then
        # https://highreso.jp/edgehub/machinelearning/ubuntudocker.html#index_id7
        echo "== Install NVIDIA Container Toolkit =="
        curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor --yes -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
        curl -fsSL https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list \
            | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
            | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list > /dev/null
        sudo apt-get update
        sudo apt-get install -y nvidia-container-toolkit
        sudo nvidia-ctk runtime configure --runtime=docker
        # Set no-cgroups = false (also handles the commented-out form)
        sudo sed -i -E 's/^#?\s*no-cgroups\s*=.*/no-cgroups = false/' /etc/nvidia-container-runtime/config.toml
        sudo systemctl restart docker
        echo "test: docker run -it --rm --runtime=nvidia --gpus all nvidia/cuda:12.1.0-cudnn8-devel-ubuntu22.04 /bin/bash"
    fi
)

# ---------------------------------------------------------------- VS Code
install_vscode() (
    set -euo pipefail
    echo "== Install VS Code =="
    sudo apt-get install -y software-properties-common apt-transport-https wget gpg
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor --yes -o /usr/share/keyrings/microsoft.gpg
    echo "deb [signed-by=/usr/share/keyrings/microsoft.gpg arch=$(dpkg --print-architecture)] https://packages.microsoft.com/repos/vscode stable main" \
        | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y code

    mkdir -p ~/.config/Code/User
    copy_file ../vscode/settings.json ~/.config/Code/User/settings.json
    ../vscode/install.sh
)

# ---------------------------------------------------------------- Claude Code
install_claude() (
    set -euo pipefail
    # Install the CLI + set PATH + place CLAUDE.md / agents
    ../claude/install.sh
)

# ---------------------------------------------------------------- vim
install_vim() (
    set -euo pipefail
    # Deactivate any Conda environment beforehand!
    echo "== Build & install vim =="
    sudo apt-get update
    sudo apt-get install -y git tmux python3-dev python3-venv libncurses-dev libx11-dev \
        libxtst-dev libxt-dev libsm-dev libxpm-dev silversearcher-ag curl build-essential

    # Japanese folder name -> English folder name
    LANG=C xdg-user-dirs-gtk-update || true

    # Auto-detect the python3 config dir
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

    # Point vi to the built vim via alternatives (do not overwrite /usr/bin/vi directly)
    sudo update-alternatives --install /usr/bin/vi vi /usr/local/bin/vim 100
    sudo update-alternatives --set vi /usr/local/bin/vim

    # install plugins
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    copy_file ./.vimrc ~/.vimrc
    vim -c PlugInstall -c q -c q!
    mkdir -p ~/.vim/colors
    cp ~/.vim/plugged/jellybeans.vim/colors/jellybeans.vim ~/.vim/colors/
)

# ---------------------------------------------------------------- dotfiles
# Append the repo's .bashrc / .zshrc contents; copy .tmux.conf
install_dotfiles() (
    set -euo pipefail
    echo "== dotfiles =="
    # xsel: used by copy-mode (y) in .tmux.conf for clipboard integration
    sudo apt-get install -y tmux xsel
    append_block ./.bashrc ~/.bashrc
    if command -v zsh >/dev/null 2>&1 || [ -f ~/.zshrc ]; then
        append_block ./.zshrc ~/.zshrc
    fi
    copy_file ./.tmux.conf ~/.tmux.conf
)

# ---------------------------------------------------------------- main
failed=()
run() {
    local name="$1"; shift
    echo
    echo "################ $name ################"
    # Do not put "$@" on the left of || / && or inside if: that disables errexit in the step
    "$@"
    local rc=$?
    [ "$rc" -eq 0 ] || failed+=("$name")
}

run docker      install_docker
run vscode      install_vscode
run claude      install_claude
run vim         install_vim
run dotfiles    install_dotfiles

echo
if [ ${#failed[@]} -gt 0 ]; then
    echo "Failed: ${failed[*]}" >&2
    exit 1
fi
echo "All done. Log out and back in to apply the docker group."
