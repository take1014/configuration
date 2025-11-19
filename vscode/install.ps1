# VS Code extension batch install script (Windows PowerShell)
# Usage:
#   1. Save this as install_extensions.ps1
#   2. Run in PowerShell (e.g., powershell -ExecutionPolicy Bypass -File .\install_extensions.ps1)

$extensions = @(
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

# Check if 'code' command is available
if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
    Write-Host "`n[ERROR] 'code' command not found."
    Write-Host "Please run 'Shell Command: Install ''code'' command in PATH' from the VS Code command palette.`n"
    exit 1
}

foreach ($extension in $extensions) {
    Write-Host "Installing $extension ..."
    $result = code --install-extension $extension 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Failed to install $extension."
        Write-Host $result
    }
}

Write-Host "`nAll extensions processed."
