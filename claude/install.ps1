# Install Claude Code (CLI + CLAUDE.md / agents) (Windows)
# Usage (PowerShell):
#   powershell -ExecutionPolicy Bypass -File .\install.ps1                # CLI (only if not installed) + config
#   powershell -ExecutionPolicy Bypass -File .\install.ps1 -ConfigOnly    # config files only
#   powershell -ExecutionPolicy Bypass -File .\install.ps1 -Help          # show usage
# - Config files: do nothing if identical; otherwise overwrite (no backup).
# - Config-only mode mirrors agents/: agent .md files not in this repository are deleted.
#   A full install deletes only the listed obsolete agents (renamed or removed).
# - settings.json holds personal settings (theme etc.), so it is neither managed nor overwritten.
[CmdletBinding()]
param([switch]$ConfigOnly, [switch]$Help)
$ErrorActionPreference = 'Stop'

if ($Help) {
    @'
Usage: powershell -ExecutionPolicy Bypass -File .\install.ps1 [-ConfigOnly] [-Help]

  (no option)  install the CLI (only if not installed) + place config in ~\.claude
  -ConfigOnly  place config (CLAUDE.md / agents) only; skip the CLI install
  -Help        show this help

Env: CLAUDE_CONFIG_DIR overrides the destination (default: ~\.claude)
'@ | Write-Host
    exit 0
}

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
$srcAgents = @(Get-ChildItem (Join-Path $PSScriptRoot 'agents') -Filter *.md -File)
# Remove stale agents before copying, so a case-only rename is not undone
# on case-insensitive file systems.
if ($ConfigOnly) {
    # -ConfigOnly: mirror .\agents; remove every agent file that is not in this repository
    $srcNames = @($srcAgents | ForEach-Object { $_.Name })
    Get-ChildItem (Join-Path $dest 'agents') -Filter *.md -File |
        Where-Object { $srcNames -cnotcontains $_.Name } |
        ForEach-Object {
            Remove-Item $_.FullName -Force
            Write-Host "removed: $($_.FullName)  (not in repository)"
        }
} else {
    # Full install: remove only agents that were renamed or removed from this repository
    foreach ($name in @('explorer.md')) {
        $obsolete = Join-Path $dest "agents/$name"
        if (Test-Path $obsolete -PathType Leaf) {
            Remove-Item $obsolete -Force
            Write-Host "removed: $obsolete  (obsolete)"
        }
    }
}
$srcAgents | ForEach-Object {
    Copy-IfChanged $_.FullName (Join-Path $dest "agents/$($_.Name)")
}

Write-Host "Done. Restart Claude Code (or run /agents to verify)."
