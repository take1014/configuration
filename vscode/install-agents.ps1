# Place Copilot Chat user instructions and custom agents in ~\.copilot.
# - Files: do nothing if identical; otherwise overwrite (no backup).
# - Agents mirror .\agents: *.agent.md files in ~\.copilot\agents that are not in this repository are deleted.
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '..\common\lib.ps1')

$dest = Join-Path $HOME '.copilot'
$agentsDest = Join-Path $dest 'agents'
New-Item $agentsDest -ItemType Directory -Force | Out-Null

Copy-IfChanged (Join-Path $PSScriptRoot 'copilot-instructions.md') (Join-Path $dest 'copilot-instructions.md')
$srcAgents = @(Get-ChildItem (Join-Path $PSScriptRoot 'agents') -Filter *.agent.md -File)
# Remove stale agents before copying, so a case-only rename is not undone
# on case-insensitive file systems.
$srcNames = @($srcAgents | ForEach-Object { $_.Name })
Get-ChildItem $agentsDest -Filter *.agent.md -File |
    Where-Object { $srcNames -cnotcontains $_.Name } |
    ForEach-Object {
        Remove-Item $_.FullName -Force
        Write-Host "removed: $($_.FullName)  (not in repository)"
    }
$srcAgents | ForEach-Object {
    Copy-IfChanged $_.FullName (Join-Path $agentsDest $_.Name)
}

Write-Host 'Done. Restart VS Code to load the Copilot Chat instructions and agents.'
