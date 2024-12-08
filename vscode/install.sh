#!/bin/bash
sudo apt update
sudo apt install -y software-properties-common apt-transport-https wget
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/
rm microsoft.gpg

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
sudo apt update
sudo apt install -y code

extensions=(
    "christian-kohler.npm-intellisense"
    "christian-kohler.path-intellisense"
    "eamodio.gitlens"
    "GitHub.vscode-pull-request-github"
    "golang.go"
    "janisdd.vscode-edit-csv"
    "jeff-hykin.better-cpp-syntax"
    "mosapride.zenkaku"
    "ms-python.isort"
    "ms-python.python"
    "ms-python.vscode-pylance"
    "ms-toolsai.jupyter"
    "ms-toolsai.jupyter-keymap"
    "ms-toolsai.jupyter-renderers"
    "ms-toolsai.vscode-jupyter-cell-tags"
    "ms-toolsai.vscode-jupyter-slideshow"
    "ms-vscode.cmake-tools"
    "ms-vscode.cpptools"
    "ms-vscode.cpptools-extension-pack"
    "ms-vscode.cpptools-themes"
    "ms-vscode.makefile-tools",
    "PKief.material-icon-theme"
    "shardulm94.trailing-spaces"
    "siwatts.jellybeans-vim-theme"
    "tomoki1207.pdf"
    "twxs.cmake"
    "VisualStudioExptTeam.intellicode-api-usage-examples"
    "VisualStudioExptTeam.vscodeintellicode"
    "vscodevim.vim"
)

for extension in "${extensions[@]}"
do
    code --install-extension "$extension"
done
