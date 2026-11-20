$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '..\common\lib.ps1')

$dest = Join-Path $HOME '.copilot'
$agentsDest = Join-Path $dest 'agents'
New-Item $agentsDest -ItemType Directory -Force | Out-Null

Copy-IfChanged (Join-Path $PSScriptRoot 'copilot-instructions.md') (Join-Path $dest 'copilot-instructions.md')
Get-ChildItem (Join-Path $PSScriptRoot 'agents') -Filter *.agent.md | ForEach-Object {
    Copy-IfChanged $_.FullName (Join-Path $agentsDest $_.Name)
}

Write-Host 'Done. Restart VS Code to load the Copilot Chat instructions and agents.'
