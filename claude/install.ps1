# Install Claude Code (CLI + Node.js + plugins + CLAUDE.md / agents / settings.json) (Windows)
# Usage (PowerShell):
#   powershell -ExecutionPolicy Bypass -File .\install.ps1                # CLI, Node.js and plugins (only if not installed) + config
#   powershell -ExecutionPolicy Bypass -File .\install.ps1 -ConfigOnly    # config files only
#   powershell -ExecutionPolicy Bypass -File .\install.ps1 -Help          # show usage
# - Node.js 22+ (needed by plugin hooks and typescript-language-server): latest LTS into ~\.local\opt only if
#   no node is found (including an MSI / winget install); an older node only warns. Skipped with -ConfigOnly.
# - Language servers for the LSP plugins (pyright, typescript-language-server, clangd): installed only if not on PATH;
#   skipped with -ConfigOnly. npm packages go to ~\.local\opt\npm-global (no admin); clangd uses winget LLVM.LLVM,
#   or the clangd release zip into ~\.local\opt (no admin) when winget is missing or fails.
# - Plugins (caveman, superpowers, context7, pyright-lsp, clangd-lsp, typescript-lsp): installed in user scope only if not installed; skipped with -ConfigOnly.
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

  (no option)  install the CLI, Node.js, language servers and plugins (only if not installed) + place config in ~\.claude
  -ConfigOnly  place config (CLAUDE.md / agents / settings.json) only; skip the CLI, Node.js, language server and plugin install
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

    Write-Host "== Node.js (for plugin hooks and LSP servers) =="
    # Plugin hooks (e.g. caveman) run with node and silently do nothing without it; they need Node.js 18+.
    # typescript-language-server (for the typescript-lsp plugin) needs Node.js 22+ (6.1.0: >=22.22.2).
    # An existing node is reused, including one from the official installer (MSI) or winget that is only
    # on the persisted PATH because this terminal was opened before it was installed.
    # Otherwise install the latest LTS zip from nodejs.org into ~\.local\opt (no admin).
    # Layout: ~\.local\opt\node-<ver>-<platform>, junction ~\.local\opt\node (added to the user PATH).
    # Failures only warn, so the rest of the install continues.
    $nodeMinMajor = 22
    $optDir = Join-Path $HOME '.local\opt'
    $nodeHome = Join-Path $optDir 'node'

    # Find node.exe: this session's PATH, then the persisted Machine / User PATH, then the MSI default folder
    function Find-Node {
        $cmd = Get-Command node.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($cmd) { return $cmd.Path }
        $dirs = @(([Environment]::GetEnvironmentVariable('Path', 'Machine'),
                   [Environment]::GetEnvironmentVariable('Path', 'User')) -join ';' -split ';') +
                (Join-Path $env:ProgramFiles 'nodejs')
        foreach ($d in $dirs) {
            try {
                $d = [Environment]::ExpandEnvironmentVariables($d).Trim('"')
                if (-not $d) { continue }
                $exe = [System.IO.Path]::Combine($d, 'node.exe')
                if (Test-Path -LiteralPath $exe -PathType Leaf) { return $exe }
            } catch { continue }  # malformed PATH entry
        }
        return $null
    }

    # Add $Dir to the user PATH via the registry, keeping REG_EXPAND_SZ and unexpanded %VARS%
    function Add-UserPath([string]$Dir) {
        # Compare expanded paths, so an entry written as %USERPROFILE%\... also matches
        $norm = { [Environment]::ExpandEnvironmentVariables("$($args[0])").Trim('"').TrimEnd('\') }
        $target = & $norm $Dir
        $userPath = (Get-Item 'HKCU:\Environment').GetValue('Path', '', 'DoNotExpandEnvironmentNames')
        $entries = @($userPath -split ';' | Where-Object { $_ })
        if (-not ($entries | Where-Object { (& $norm $_) -ieq $target })) {
            Set-ItemProperty 'HKCU:\Environment' -Name Path -Value (($entries + $Dir) -join ';') -Type ExpandString
            # Tell running programs (e.g. Explorer) that the environment changed
            if (-not ('ClaudeInstall.NativeMethods' -as [type])) {
                Add-Type -Namespace ClaudeInstall -Name NativeMethods -MemberDefinition @'
[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam,
    uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
'@
            }
            $result = [UIntPtr]::Zero
            [ClaudeInstall.NativeMethods]::SendMessageTimeout([IntPtr]0xffff, 0x1A, [UIntPtr]::Zero,
                'Environment', 2, 5000, [ref]$result) | Out-Null
            Write-Host "updated: user PATH  (+ $Dir; open a new terminal to use it)"
        }
        if (-not (@($env:Path -split ';' | ForEach-Object { & $norm $_ }) -icontains $target)) {
            $env:Path = "$env:Path;$Dir"
        }
    }

    $nodeExe = Find-Node
    if ($nodeExe) {
        $nodeVer = $null
        try { $nodeVer = "$(& $nodeExe --version | Select-Object -First 1)".Trim() } catch { }
        if ($nodeVer -match '^v(\d+)\.' -and [int]$Matches[1] -ge $nodeMinMajor) {
            Write-Host "already installed: node $nodeVer  ($nodeExe)"
        } else {
            # Not replaced automatically: a machine-wide node (MSI) comes before the user PATH,
            # so another copy under ~\.local\opt would not take effect.
            Write-Warning ("node $(if ($nodeVer) { $nodeVer } else { '(unknown version)' }) at $nodeExe is older than " +
                "v$nodeMinMajor, which plugin hooks and typescript-language-server need. " +
                "Upgrade it (e.g. 'winget upgrade OpenJS.NodeJS.LTS' or the installer from nodejs.org) and re-run.")
        }
    } elseif (Test-Path -LiteralPath (Join-Path $nodeHome 'node.exe') -PathType Leaf) {
        # Installed by this script earlier, but its user PATH entry is gone: restore it
        try {
            Add-UserPath $nodeHome
            Write-Host "already installed: node  ($nodeHome)"
        } catch {
            Write-Warning "failed to add $nodeHome to the user PATH: $($_.Exception.Message)"
        }
    } else {
        $platform = switch ($env:PROCESSOR_ARCHITECTURE) {
            'AMD64' { 'win-x64' }
            'ARM64' { 'win-arm64' }
            default { $null }
        }
        if (-not $platform) {
            Write-Warning "$($env:PROCESSOR_ARCHITECTURE) is not supported; skipping Node.js install."
        } else {
            $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
            New-Item $tmp -ItemType Directory -Force | Out-Null
            # Progress bars make Invoke-WebRequest / Expand-Archive very slow on Windows PowerShell 5.1
            $savedProgress = $ProgressPreference
            $ProgressPreference = 'SilentlyContinue'
            try {
                # Assign first: Windows PowerShell 5.1 sends a JSON array down the pipeline as one object
                $index = Invoke-RestMethod https://nodejs.org/dist/index.json
                $release = $index |
                    Where-Object { $_.lts -and $_.files -contains "$platform-zip" } |
                    Select-Object -First 1
                if (-not $release) { throw "could not determine the Node.js LTS version" }
                $ver = $release.version
                $name = "node-$ver-$platform"
                $zip = Join-Path $tmp "$name.zip"
                Invoke-WebRequest "https://nodejs.org/dist/$ver/$name.zip" -OutFile $zip -UseBasicParsing
                $sums = (Invoke-WebRequest "https://nodejs.org/dist/$ver/SHASUMS256.txt" -UseBasicParsing).Content
                $expected = ($sums -split "`n" | Where-Object { $_ -match "^([0-9a-f]{64})\s+$([regex]::Escape("$name.zip"))\s*$" } |
                    Select-Object -First 1) -replace '\s.*$', ''
                if (-not $expected -or (Get-FileHash $zip -Algorithm SHA256).Hash -ine $expected) {
                    throw "checksum mismatch for $name.zip"
                }
                New-Item $optDir -ItemType Directory -Force | Out-Null
                Expand-Archive $zip -DestinationPath $optDir -Force
                # Junction (no admin needed) so the PATH entry survives version upgrades
                # Get-Item -Force also finds a broken junction (Test-Path returns False for it on PS 5.1).
                # DirectoryInfo.Delete() removes only the junction, not its target.
                $oldLink = Get-Item -LiteralPath $nodeHome -Force -ErrorAction SilentlyContinue
                if ($oldLink) { $oldLink.Delete() }
                New-Item $nodeHome -ItemType Junction -Value (Join-Path $optDir $name) | Out-Null
                Add-UserPath $nodeHome
                Write-Host "installed: node $ver  ($(Join-Path $optDir $name))"
            } catch {
                Write-Warning "failed to install Node.js: $($_.Exception.Message)"
            } finally {
                $ProgressPreference = $savedProgress
                Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }

    Write-Host "== Language servers (for LSP plugins) =="
    # Install the language servers that the LSP plugins run, only if not found. Failures only warn.
    # - pyright-langserver / typescript-language-server: npm global install into ~\.local\opt\npm-global
    #   (no admin), which is added to the user PATH
    # - clangd: winget LLVM.LLVM (may ask for admin); C:\Program Files\LLVM\bin is added to the user PATH
    #   (or, without winget / when it fails, the clangd zip from GitHub into ~\.local\opt\clangd_<ver>, no admin)
    $npmPrefix = Join-Path $optDir 'npm-global'
    $pkgs = @()
    # typescript is pinned to 6: TypeScript 7 (native port) ships no tsserver.js, which typescript-language-server needs.
    foreach ($s in @(@{ Cmd = 'pyright-langserver'; Pkgs = @('pyright') },
                     @{ Cmd = 'typescript-language-server'; Pkgs = @('typescript-language-server', 'typescript@6') })) {
        if ((Get-Command $s.Cmd -ErrorAction SilentlyContinue) -or
            (Test-Path -LiteralPath (Join-Path $npmPrefix "$($s.Cmd).cmd") -PathType Leaf)) {
            Write-Host "already installed: $($s.Cmd)"
        } else {
            $pkgs += $s.Pkgs
        }
    }
    if ($pkgs) {
        # npm.cmd runs the node.exe next to it, so it also works when node is not on this session's PATH
        $npm = (Get-Command npm.cmd -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1).Path
        foreach ($dir in @($(if ($nodeExe) { Split-Path $nodeExe }), $nodeHome)) {
            if ($npm -or -not $dir) { continue }
            $c = Join-Path $dir 'npm.cmd'
            if (Test-Path -LiteralPath $c -PathType Leaf) { $npm = $c }
        }
        if (-not $npm) {
            Write-Warning "npm not found; skipping $($pkgs -join ' ') (install Node.js and re-run)."
        } else {
            try {
                & $npm install -g --prefix $npmPrefix @pkgs
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "installed: $($pkgs -join ' ')  ($npmPrefix)"
                } else {
                    Write-Warning "failed to install: $($pkgs -join ' ')"
                }
            } catch {
                Write-Warning "failed to install $($pkgs -join ' '): $($_.Exception.Message)"
            }
        }
    }
    # Also restores the PATH entry if the servers were installed here earlier
    if (Test-Path -LiteralPath $npmPrefix -PathType Container) {
        try { Add-UserPath $npmPrefix } catch { Write-Warning "failed to add $npmPrefix to the user PATH: $($_.Exception.Message)" }
    }

    $llvmBin = Join-Path $env:ProgramFiles 'LLVM\bin'
    $clangdExe = Join-Path $llvmBin 'clangd.exe'
    $clangdHome = Join-Path $optDir 'clangd'
    $clangdHomeBin = Join-Path $clangdHome 'bin'
    if (Get-Command clangd -ErrorAction SilentlyContinue) {
        Write-Host "already installed: clangd"
    } elseif (Test-Path -LiteralPath (Join-Path $clangdHomeBin 'clangd.exe') -PathType Leaf) {
        # Installed from the zip by this script earlier, but its user PATH entry is gone: restore it
        try {
            Add-UserPath $clangdHomeBin
            Write-Host "already installed: clangd  ($clangdHomeBin)"
        } catch {
            Write-Warning "failed to add $clangdHomeBin to the user PATH: $($_.Exception.Message)"
        }
    } else {
        if (-not (Test-Path -LiteralPath $clangdExe -PathType Leaf)) {
            if (Get-Command winget -ErrorAction SilentlyContinue) {
                try {
                    winget install --id LLVM.LLVM -e --accept-source-agreements --accept-package-agreements
                    if ($LASTEXITCODE -ne 0) { Write-Warning "failed to install LLVM (clangd) with winget; trying the clangd zip." }
                } catch {
                    Write-Warning "failed to install LLVM (clangd) with winget: $($_.Exception.Message); trying the clangd zip."
                }
            } else {
                Write-Host "winget not found; trying the clangd zip."
            }
        }
        if (Test-Path -LiteralPath $clangdExe -PathType Leaf) {
            # The LLVM installer does not add itself to PATH by default
            try {
                Add-UserPath $llvmBin
                Write-Host "installed: clangd  ($clangdExe)"
            } catch {
                Write-Warning "failed to add $llvmBin to the user PATH: $($_.Exception.Message)"
            }
        } elseif ($env:PROCESSOR_ARCHITECTURE -ne 'AMD64') {
            Write-Warning "no clangd zip for $($env:PROCESSOR_ARCHITECTURE); install clangd manually: https://clangd.llvm.org/installation"
        } else {
            # Fallback without winget or admin: the standalone clangd release zip from GitHub into ~\.local\opt.
            # Layout: ~\.local\opt\clangd_<ver>, junction ~\.local\opt\clangd (its bin is added to the user PATH).
            $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
            New-Item $tmp -ItemType Directory -Force | Out-Null
            $savedProgress = $ProgressPreference
            $ProgressPreference = 'SilentlyContinue'
            try {
                $release = Invoke-RestMethod https://api.github.com/repos/clangd/clangd/releases/latest -UseBasicParsing
                $ver = $release.tag_name
                $asset = $release.assets | Where-Object { $_.name -eq "clangd-windows-$ver.zip" } | Select-Object -First 1
                if (-not $asset) { throw "clangd-windows-$ver.zip not found in the latest release" }
                $zip = Join-Path $tmp $asset.name
                Invoke-WebRequest $asset.browser_download_url -OutFile $zip -UseBasicParsing
                # GitHub publishes each asset's SHA-256 as "sha256:<hex>"
                $expected = "$($asset.digest)" -replace '^sha256:', ''
                if ($expected -notmatch '^[0-9a-fA-F]{64}$' -or (Get-FileHash $zip -Algorithm SHA256).Hash -ine $expected) {
                    throw "checksum mismatch for $($asset.name)"
                }
                New-Item $optDir -ItemType Directory -Force | Out-Null
                Expand-Archive $zip -DestinationPath $optDir -Force
                $name = "clangd_$ver"
                if (-not (Test-Path -LiteralPath (Join-Path $optDir "$name\bin\clangd.exe") -PathType Leaf)) {
                    throw "clangd.exe not found in $(Join-Path $optDir $name)"
                }
                # Junction (no admin needed) so the PATH entry survives version upgrades; see the Node.js step
                $oldLink = Get-Item -LiteralPath $clangdHome -Force -ErrorAction SilentlyContinue
                if ($oldLink) { $oldLink.Delete() }
                New-Item $clangdHome -ItemType Junction -Value (Join-Path $optDir $name) | Out-Null
                Add-UserPath $clangdHomeBin
                Write-Host "installed: clangd $ver  ($(Join-Path $optDir $name))"
            } catch {
                Write-Warning "failed to install clangd from the zip: $($_.Exception.Message); install it manually: https://clangd.llvm.org/installation"
            } finally {
                $ProgressPreference = $savedProgress
                Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }

    Write-Host "== Claude Code (plugins) =="
    # Plugins to install: <plugin>@<marketplace> = <marketplace source>
    $plugins = [ordered]@{
        'caveman@caveman'                     = 'JuliusBrussee/caveman'
        'superpowers@claude-plugins-official' = 'anthropics/claude-plugins-official'
        'context7@claude-plugins-official'    = 'anthropics/claude-plugins-official'
        # LSP plugins: each needs its language server on PATH (pyright-langserver / clangd / typescript-language-server)
        'pyright-lsp@claude-plugins-official'    = 'anthropics/claude-plugins-official'
        'clangd-lsp@claude-plugins-official'     = 'anthropics/claude-plugins-official'
        'typescript-lsp@claude-plugins-official' = 'anthropics/claude-plugins-official'
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
