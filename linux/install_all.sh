#!/bin/bash
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

# Linux (Ubuntu) 必須セットアップ: docker / VS Code / Claude Code / vim
# 実行方法:
#   ./install_all.sh              # 必須の4つ
#   ./install_all.sh --nvidia     # docker に NVIDIA Container Toolkit も追加
#   (スクリプト全体を sudo で実行する必要はありません)
# 途中で失敗しても残りは続行し、最後に結果を表示します。

WITH_NVIDIA=0
[ "${1:-}" = "--nvidia" ] && WITH_NVIDIA=1

# ---------------------------------------------------------------- docker
install_docker() (
    set -euo pipefail
    ARCH="$(dpkg --print-architecture)"

    echo "== Install Docker =="
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    sudo install -m 0755 -d /usr/share/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor --yes -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=${ARCH} signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
        | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    sudo systemctl enable --now docker
    sudo docker --version
    sudo usermod -aG docker "$USER"

    echo "== Install QEMU =="
    sudo apt-get install -y qemu-user-static binfmt-support
    sudo docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

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
        # no-cgroups = false に設定 (コメントアウトされていても対応)
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
    cp ../vscode/settings.json ~/.config/Code/User/
    ../vscode/install.sh
)

# ---------------------------------------------------------------- Claude Code
install_claude() (
    set -euo pipefail
    echo "== Install Claude Code (CLI) =="
    if ! command -v curl >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y curl
    fi
    curl -fsSL https://claude.ai/install.sh | bash

    # ~/.local/bin を PATH に追加 (未設定の場合のみ)
    if ! grep -q '\.local/bin' ~/.bashrc 2>/dev/null; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    fi
)

# ---------------------------------------------------------------- vim
install_vim() (
    set -euo pipefail
    # Conda 環境は事前に deactivate しておくこと!
    echo "== Build & install vim =="
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
)

# ---------------------------------------------------------------- main
failed=()
run() {
    local name="$1"; shift
    echo
    echo "################ $name ################"
    "$@" || failed+=("$name")
}

run docker      install_docker
run vscode      install_vscode
run claude      install_claude
run vim         install_vim

echo
if [ ${#failed[@]} -gt 0 ]; then
    echo "Failed: ${failed[*]}" >&2
    exit 1
fi
echo "All done. docker グループ反映のため、再ログインしてください。"
