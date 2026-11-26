# Install Claude Code (CLI + plugins + CLAUDE.md / agents / settings.json) (Windows)
# Usage (PowerShell):
#   powershell -ExecutionPolicy Bypass -File .\install.ps1                # CLI and plugins (only if not installed) + config
#   powershell -ExecutionPolicy Bypass -File .\install.ps1 -ConfigOnly    # config files only
#   powershell -ExecutionPolicy Bypass -File .\install.ps1 -Help          # show usage
# - Plugins (caveman, superpowers): installed in user scope only if not installed; skipped with -ConfigOnly.
# - Config files: do nothing if identical; otherwise overwrite (no backup).
# - Config-only mode mirrors agents/: agent .md files not in this repository are deleted.
#   A full install deletes only the listed obsolete agents (renamed or removed).
# - settings.json is merged, never overwritten (both modes): keys missing from the existing file are added,
#   arrays (e.g. permissions.deny) get the missing entries appended, and existing values are kept.
#   A backup (settings.json.bak) is written before any change.
[CmdletBinding()]
param([switch]$ConfigOnly, [switch]$Help)
$ErrorActionPreference = 'Stop'

if ($Help) {
    @'
Usage: powershell -ExecutionPolicy Bypass -File .\install.ps1 [-ConfigOnly] [-Help]

  (no option)  install the CLI and plugins (only if not installed) + place config in ~\.claude
  -ConfigOnly  place config (CLAUDE.md / agents / settings.json) only; skip the CLI and plugin install
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

    Write-Host "== Claude Code (plugins) =="
    # Plugins to install: <plugin>@<marketplace> = <marketplace source>
    $plugins = [ordered]@{
        'caveman@caveman'                     = 'JuliusBrussee/caveman'
        'superpowers@claude-plugins-official' = 'anthropics/claude-plugins-official'
    }
    $claudeBin = (Get-Command claude -ErrorAction SilentlyContinue).Source
    if (-not $claudeBin -and (Test-Path $local)) { $claudeBin = $local }
    if (-not $claudeBin) {
        Write-Warning "claude not found; skipping plugin install."
    } else {
        $installed = @()
        try {
            $installed = @((& $claudeBin plugin list --json | Out-String | ConvertFrom-Json) | ForEach-Object { $_.id })
        } catch { }
        foreach ($id in $plugins.Keys) {
            if ($installed -ccontains $id) {
                Write-Host "already installed: $id"
                continue
            }
            # --marketplace adds the marketplace first if it is not configured yet
            & $claudeBin plugin install ($id -split '@')[0] --marketplace $plugins[$id] --scope user
            if ($LASTEXITCODE -eq 0) {
                Write-Host "installed: $id"
            } else {
                Write-Warning "failed to install plugin: $id"
            }
        }
    }
}

# Merge-Settings <existing> <repo>
#   Objects are merged recursively, arrays get missing entries appended, existing scalars win.
function Merge-Settings($a, $b) {
    $obj = [System.Management.Automation.PSCustomObject]
    if ($a -is $obj -and $b -is $obj) {
        foreach ($p in $b.PSObject.Properties) {
            $cur = $a.PSObject.Properties[$p.Name]
            if ($null -eq $cur) {
                $a | Add-Member -NotePropertyName $p.Name -NotePropertyValue $p.Value
            } else {
                $cur.Value = Merge-Settings $cur.Value $p.Value
            }
        }
        return $a
    }
    if ($a -is [array] -and $b -is [array]) {
        $missing = @($b | Where-Object { $a -cnotcontains $_ })
        return ,(@($a) + $missing)
    }
    if ($a -is [array]) { return ,$a }
    return $a
}

# Merge-SettingsFile <src> <dest>
#   Copy <src> if <dest> does not exist; otherwise merge it in. Do nothing if nothing is missing.
function Merge-SettingsFile($src, $dst) {
    if (-not (Test-Path $dst)) {
        Copy-Item $src $dst
        Write-Host "copied: $dst"
        return
    }
    try {
        $existing = Get-Content $dst -Raw | ConvertFrom-Json
    } catch {
        throw "$dst is not valid JSON; fix it manually and re-run."
    }
    $repo = Get-Content $src -Raw | ConvertFrom-Json
    $before = $existing | ConvertTo-Json -Depth 32 -Compress
    $merged = Merge-Settings $existing $repo
    if (($merged | ConvertTo-Json -Depth 32 -Compress) -ceq $before) {
        Write-Host "up to date: $dst"
        return
    }
    Copy-Item $dst "$dst.bak" -Force
    # UTF-8 without BOM
    [System.IO.File]::WriteAllText($dst, ($merged | ConvertTo-Json -Depth 32) + "`n", (New-Object System.Text.UTF8Encoding $false))
    Write-Host "merged: $dst  (backup: $dst.bak)"
}

Write-Host "== Claude Code (CLAUDE.md / agents / settings.json) =="
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
Merge-SettingsFile (Join-Path $PSScriptRoot 'settings.json') (Join-Path $dest 'settings.json')

Write-Host "Done. Restart Claude Code (or run /agents to verify)."
