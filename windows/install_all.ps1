# Windows setup: Claude Code (CLI) / vim (vim-plug + plugins) / VS Code settings + extensions
# Usage (PowerShell):
#   powershell -ExecutionPolicy Bypass -File .\install_all.ps1
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

# Copy $src to $dst. Do nothing if identical; otherwise back up to $dst.bak.<timestamp> first.
function Copy-WithBackup($src, $dst) {
    if (Test-Path $dst) {
        if ((Get-FileHash $src).Hash -eq (Get-FileHash $dst).Hash) {
            Write-Host "up to date: $dst"
            return
        }
        Copy-Item $dst "$dst.bak.$(Get-Date -Format yyyyMMddHHmmss)"
        Write-Host "backup: $dst.bak.*"
    }
    Copy-Item $src $dst -Force
    Write-Host "copied: $dst"
}

# Install the CLI + place CLAUDE.md / agents
& "..\claude\install.ps1"

Write-Host "== vim =="
if (-not (Get-Command vim -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] 'vim' command not found. Install vim first (e.g. winget install vim.vim) and re-run."
    exit 1
}
New-Item "$HOME/vimfiles/autoload" -ItemType Directory -Force | Out-Null
iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim | ni "$HOME/vimfiles/autoload/plug.vim" -Force
Copy-WithBackup ".\.vimrc" "$HOME\.vimrc"
vim -c PlugInstall -c q -c q!
New-Item "$HOME/vimfiles/colors" -ItemType Directory -Force | Out-Null
Copy-Item -Path "$HOME/.vim/plugged/jellybeans.vim/colors/jellybeans.vim" -Destination "$HOME/vimfiles/colors/" -Force

Write-Host "== VS Code settings =="
New-Item "$env:APPDATA\Code\User" -ItemType Directory -Force | Out-Null
Copy-WithBackup "..\vscode\settings.json" "$env:APPDATA\Code\User\settings.json"

Write-Host "== VS Code extensions =="
if (Get-Command code -ErrorAction SilentlyContinue) {
    & "..\vscode\install.ps1"
} else {
    Write-Host "'code' command not found. Run 'Shell Command: Install code command in PATH' from the VS Code command palette, then run ..\vscode\install.ps1."
}

Write-Host "`nDone. Restart your terminal, then run: claude"
