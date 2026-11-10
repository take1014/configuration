# Windows セットアップ: Claude Code (CLI) / vim (vim-plug + プラグイン) / VS Code settings + 拡張機能
# 実行方法 (PowerShell):
#   powershell -ExecutionPolicy Bypass -File .\install_all.ps1
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

# CLI 本体のインストール + CLAUDE.md / agents の配置
& "..\claude\install.ps1"

Write-Host "== vim =="
if (-not (Get-Command vim -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] 'vim' command not found. Install vim first (e.g. winget install vim.vim) and re-run."
    exit 1
}
New-Item "$HOME/vimfiles/autoload" -ItemType Directory -Force | Out-Null
iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim | ni "$HOME/vimfiles/autoload/plug.vim" -Force
Copy-Item -Path ./.vimrc -Destination $HOME/ -Force
vim -c PlugInstall -c q -c q!
New-Item "$HOME/vimfiles/colors" -ItemType Directory -Force | Out-Null
Copy-Item -Path "$HOME/.vim/plugged/jellybeans.vim/colors/jellybeans.vim" -Destination "$HOME/vimfiles/colors/" -Force

Write-Host "== VS Code settings =="
New-Item "$env:APPDATA\Code\User" -ItemType Directory -Force | Out-Null
Copy-Item -Path "..\vscode\settings.json" -Destination "$env:APPDATA\Code\User\" -Force

Write-Host "== VS Code extensions =="
if (Get-Command code -ErrorAction SilentlyContinue) {
    & "..\vscode\install.ps1"
} else {
    Write-Host "'code' command not found. Run 'Shell Command: Install code command in PATH' from the VS Code command palette, then run ..\vscode\install.ps1."
}

Write-Host "`nDone. Restart your terminal, then run: claude"
