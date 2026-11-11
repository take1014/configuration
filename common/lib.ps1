# Common functions, dot-sourced by the Windows setup scripts (windows/install_all.ps1, claude/install.ps1)

# Copy-IfChanged <src> <dst>
#   Copy $src to $dst. Do nothing if identical; otherwise overwrite (no backup).
function Copy-IfChanged($src, $dst) {
    if (Test-Path $dst) {
        if ((Get-FileHash $src).Hash -eq (Get-FileHash $dst).Hash) {
            Write-Host "up to date: $dst"
            return
        }
    }
    Copy-Item $src $dst -Force
    Write-Host "copied: $dst"
}
