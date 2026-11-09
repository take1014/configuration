# Claude Code (CLI) install script (native installer, Windows PowerShell)
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\install_claude.ps1

irm https://claude.ai/install.ps1 | iex

Write-Host "`nDone. Restart your terminal, then run: claude"
