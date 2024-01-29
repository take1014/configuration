$extensions = @(
    "christian-kohler.npm-intellisense",
    "christian-kohler.path-intellisense",
    "eamodio.gitlens",
    "GitHub.vscode-pull-request-github",
    "golang.go",
    "janisdd.vscode-edit-csv",
    "jeff-hykin.better-cpp-syntax",
    "mosapride.zenkaku",
    "ms-python.isort",
    "ms-python.python",
    "ms-python.vscode-pylance",
    "ms-toolsai.jupyter",
    "ms-toolsai.jupyter-keymap",
    "ms-toolsai.jupyter-renderers",
    "ms-toolsai.vscode-jupyter-cell-tags",
    "ms-toolsai.vscode-jupyter-slideshow",
    "ms-vscode.cmake-tools",
    "ms-vscode.cpptools",
    "ms-vscode.cpptools-extension-pack",
    "ms-vscode.cpptools-themes",
    "ms-vscode.makefile-tools",
    "PKief.material-icon-theme",
    "shardulm94.trailing-spaces",
    "siwatts.jellybeans-vim-theme",
    "tomoki1207.pdf",
    "twxs.cmake",
    "VisualStudioExptTeam.intellicode-api-usage-examples",
    "VisualStudioExptTeam.vscodeintellicode",
    "vscodevim.vim"
)

foreach ($extension in $extensions) {
    code --install-extension $extension
}
