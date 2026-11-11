# Install Claude Code (CLI + CLAUDE.md / agents) (Windows)
# Usage (PowerShell):
#   powershell -ExecutionPolicy Bypass -File .\install.ps1                # CLI (only if not installed) + config
#   powershell -ExecutionPolicy Bypass -File .\install.ps1 -ConfigOnly    # config files only
# - Config files: do nothing if identical; otherwise overwrite (no backup).
# - settings.json holds personal settings (theme etc.), so it is neither managed nor overwritten.
param([switch]$ConfigOnly)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '..\common\lib.ps1')

if (-not $ConfigOnly) {
    Write-Host "== Claude Code (CLI) =="
    $local = Join-Path $HOME '.local\bin\claude.exe'
    if ((Get-Command claude -ErrorAction SilentlyContinue) -or (Test-Path $local)) {
        Write-Host "already installed: claude (run 'claude update' to upgrade)"
    } else {
        irm https://claude.ai/install.ps1 | iex
    }
}

Write-Host "== Claude Code (CLAUDE.md / agents) =="
$dest = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $HOME '.claude' }
New-Item (Join-Path $dest 'agents') -ItemType Directory -Force | Out-Null

Copy-IfChanged (Join-Path $PSScriptRoot 'CLAUDE.md') (Join-Path $dest 'CLAUDE.md')
Get-ChildItem (Join-Path $PSScriptRoot 'agents') -Filter *.md | ForEach-Object {
    Copy-IfChanged $_.FullName (Join-Path $dest "agents/$($_.Name)")
}

Write-Host "Done. Restart Claude Code (or run /agents to verify)."
