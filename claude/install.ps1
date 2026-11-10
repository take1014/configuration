# Claude Code のインストール (CLI 本体 + CLAUDE.md / agents) (Windows)
# 実行方法 (PowerShell):
#   powershell -ExecutionPolicy Bypass -File .\install.ps1                # CLI (未導入時のみ) + 設定
#   powershell -ExecutionPolicy Bypass -File .\install.ps1 -ConfigOnly    # 設定の配置だけ
# - 設定は内容が同じなら何もしない。違う場合は .bak.<日時> にバックアップしてから上書きする。
# - settings.json は個人設定 (テーマ等) を含むため、管理・上書きしない。
param([switch]$ConfigOnly)
$ErrorActionPreference = 'Stop'

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

if (-not $ConfigOnly) {
    Write-Host "== Claude Code (CLI) =="
    $local = Join-Path $HOME '.local\bin\claude.exe'
    if ((Get-Command claude -ErrorAction SilentlyContinue) -or (Test-Path $local)) {
        Write-Host "already installed: claude (更新は 'claude update')"
    } else {
        irm https://claude.ai/install.ps1 | iex
    }
}

Write-Host "== Claude Code (CLAUDE.md / agents) =="
$dest = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $HOME '.claude' }
New-Item (Join-Path $dest 'agents') -ItemType Directory -Force | Out-Null

Copy-WithBackup (Join-Path $PSScriptRoot 'CLAUDE.md') (Join-Path $dest 'CLAUDE.md')
Get-ChildItem (Join-Path $PSScriptRoot 'agents') -Filter *.md | ForEach-Object {
    Copy-WithBackup $_.FullName (Join-Path $dest "agents/$($_.Name)")
}

Write-Host "Done. Claude Code を再起動 (または /agents で確認) してください。"
