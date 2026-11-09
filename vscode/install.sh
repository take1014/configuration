#!/bin/bash
set -uo pipefail

# VS Code 拡張機能一括インストールスクリプト
# 使い方:
#   ./install.sh
# 'code' コマンドが PATH にある必要があります。

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

if ! command -v code >/dev/null 2>&1; then
    echo "[ERROR] 'code' command not found." >&2
    echo "VS Code のコマンドパレットから 'Shell Command: Install code command in PATH' を実行してください。" >&2
    exit 1
fi

# 既インストールの拡張はスキップ
installed="$(code --list-extensions | tr '[:upper:]' '[:lower:]')"
failed=()
for extension in "${extensions[@]}"; do
    if grep -qxi "$extension" <<< "$installed"; then
        echo "Skip (already installed): $extension"
        continue
    fi
    echo "Installing $extension ..."
    code --install-extension "$extension" || failed+=("$extension")
done

if [ ${#failed[@]} -gt 0 ]; then
    echo "Failed: ${failed[*]}" >&2
    exit 1
fi
echo "All extensions installed."
