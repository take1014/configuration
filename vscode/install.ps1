# VS Code extension batch install script (Windows PowerShell)
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\install.ps1

$extensions = @(
    # --- AI ---
    "anthropic.claude-code"
    "github.copilot-chat"

    # --- Intellisense ---
    "christian-kohler.path-intellisense"
    "ms-python.vscode-pylance"
    "ms-python.vscode-python-envs"

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

# Skip extensions that are already installed (-contains is case-insensitive)
$installed = @(code --list-extensions)
$failed = @()
foreach ($extension in $extensions) {
    if ($installed -contains $extension) {
        Write-Host "Skip (already installed): $extension"
        continue
    }
    Write-Host "Installing $extension ..."
    code --install-extension $extension
    if ($LASTEXITCODE -ne 0) { $failed += $extension }
}

if ($failed.Count -gt 0) {
    Write-Host "Failed: $($failed -join ' ')"
    exit 1
}
Write-Host "`nAll extensions installed."
