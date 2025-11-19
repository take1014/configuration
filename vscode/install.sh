#!/bin/bash

# VS Code拡張機能一括インストールスクリプト
# 使い方:
#   1. この内容を install_vscode_extensions.sh などのファイル名で保存
#   2. chmod +x install_vscode_extensions.sh で実行権限を付与
#   3. ./install_vscode_extensions.sh で実行

extensions=(
    # --- Intellisense ---
    "christian-kohler.path-intellisense"
    "github.copilot"
    "github.copilot-chat"
    "ms-python.vscode-pylance"
    "ms-python.vscode-python-envs"
    "VisualStudioExptTeam.vscodeintellicode"

    # --- Python ---
    "ms-python.python"
    "ms-python.isort"
    "ms-python.debugpy"

    # --- Jupyter ---
    "ms-toolsai.jupyter"
    "ms-toolsai.jupyter-keymap"
    "ms-toolsai.jupyter-renderers"
    "ms-toolsai.vscode-jupyter-cell-tags"
    "ms-toolsai.vscode-jupyter-slideshow"

    # --- Go ---
    "golang.go"

    # --- C/C++ ---
    "ms-vscode.cmake-tools"
    "ms-vscode.cpptools"
    "ms-vscode.cpptools-extension-pack"
    "ms-vscode.cpptools-themes"
    "twxs.cmake"
    "jeff-hykin.better-cpp-syntax"

    # --- Remote/Container ---
    "ms-azuretools.vscode-containers"
    "ms-vscode-remote.remote-containers"
    "ms-vscode-remote.remote-ssh"
    "ms-vscode-remote.remote-ssh-edit"
    "ms-vscode.remote-explorer"

    # --- PDF/CSV/Netron ---
    "janisdd.vscode-edit-csv"
    "vincent-templier.vscode-netron"
    "tomoki1207.pdf"

    # --- UI/Theme ---
    "pkief.material-icon-theme"
    "siwatts.jellybeans-vim-theme"

    # --- Utility ---
    "mosapride.zenkaku"
    "shardulm94.trailing-spaces"
    "vscodevim.vim"
)

for extension in "${extensions[@]}"
do
    echo "Installing $extension ..."
    code --install-extension "$extension"
done

echo "All extensions installed."
