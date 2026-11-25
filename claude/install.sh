#!/bin/bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ../common/lib.sh

# Install Claude Code (CLI + CLAUDE.md / agents / settings.json) (Linux / macOS / Raspberry Pi)
# Usage:
#   ./install.sh                # install the CLI (only if not installed) + place config in ~/.claude
#   ./install.sh --config-only  # place config (CLAUDE.md / agents / settings.json) only
#   ./install.sh --help         # show usage
# - Config files: do nothing if identical; otherwise overwrite (no backup).
# - Config-only mode mirrors agents/: agent .md files not in this repository are deleted.
#   A full install deletes only the listed obsolete agents (renamed or removed).
# - settings.json is merged, never overwritten (both modes): keys missing from the existing file are added,
#   arrays (e.g. permissions.deny) get the missing entries appended, and existing values are kept.
#   A backup (settings.json.bak) is written before any change. Requires jq.

usage() {
    cat <<'USAGE'
Usage: ./install.sh [--config-only] [-h|--help]

  (no option)    install the CLI (only if not installed) + place config in ~/.claude
  --config-only  place config (CLAUDE.md / agents / settings.json) only; skip the CLI install
  -h, --help     show this help

Env: CLAUDE_CONFIG_DIR overrides the destination (default: ~/.claude)
USAGE
}

config_only=0
for arg in "$@"; do
    case "$arg" in
        --config-only) config_only=1 ;;
        -h|--help)     usage; exit 0 ;;
        *)             echo "[ERROR] unknown option: $arg" >&2; usage >&2; exit 1 ;;
    esac
done

install_cli() {
    echo "== Claude Code (CLI) =="
    # The native installer requires a 64-bit OS (e.g. 32-bit Raspberry Pi OS is not supported)
    case "$(uname -m)" in
        x86_64|aarch64|arm64) ;;
        *) echo "[WARN] $(uname -m)  is not supported; skipping CLI install (64-bit OS required)."
           return 0 ;;
    esac

    if ! command -v curl >/dev/null 2>&1; then
        if command -v apt-get >/dev/null 2>&1; then
            sudo apt-get update
            sudo apt-get install -y curl
        else
            echo "[ERROR] curl not found. Install it and re-run." >&2
            exit 1
        fi
    fi

    if command -v claude >/dev/null 2>&1 || [ -x "$HOME/.local/bin/claude" ]; then
        echo "already installed: claude (run 'claude update' to upgrade)"
    else
        curl -fsSL https://claude.ai/install.sh | bash
    fi

    # Add ~/.local/bin to PATH (only if not already set)
    #   .bashrc: always on Linux, on macOS only if it exists; .zshrc: if zsh is installed or the file exists
    local rc
    for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
        case "$rc" in
            */.bashrc) [ "$(uname -s)" != Darwin ] || [ -f "$rc" ] || continue ;;
            */.zshrc)  command -v zsh >/dev/null 2>&1 || [ -f "$rc" ] || continue ;;
        esac
        if ! grep -q '\.local/bin' "$rc" 2>/dev/null; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc"
            echo "updated: $rc  (PATH)"
        fi
    done
}

# merge_settings <src> <dest>
#   Merge <src> into <dest> without overriding the user's values:
#   objects are merged recursively, arrays get missing entries appended, existing scalars win.
#   Copy <src> if <dest> does not exist. Do nothing if nothing is missing.
merge_settings() {
    local src="$1" dest="$2" tmp
    if [ ! -f "$dest" ]; then
        cp "$src" "$dest"
        echo "copied: $dest"
        return 0
    fi
    if ! command -v jq >/dev/null 2>&1; then
        if command -v apt-get >/dev/null 2>&1; then
            sudo apt-get update
            sudo apt-get install -y jq
        else
            echo "[WARN] jq not found; skipping $dest (install jq and re-run)." >&2
            return 0
        fi
    fi
    if ! jq empty "$dest" >/dev/null 2>&1; then
        echo "[ERROR] $dest is not valid JSON; fix it manually and re-run." >&2
        return 1
    fi
    tmp="$(mktemp)"
    jq --slurpfile repo "$src" '
        def merge($a; $b):
            if ($a | type) == "object" and ($b | type) == "object" then
                reduce ($b | keys_unsorted[]) as $k ($a;
                    .[$k] = (if $a | has($k) then merge($a[$k]; $b[$k]) else $b[$k] end))
            elif ($a | type) == "array" and ($b | type) == "array" then
                $a + ($b - $a)
            else $a end;
        merge(.; $repo[0])
    ' "$dest" > "$tmp"
    if [ "$(jq -cS . "$dest")" = "$(jq -cS . "$tmp")" ]; then
        rm -f "$tmp"
        echo "up to date: $dest"
        return 0
    fi
    cp "$dest" "$dest.bak"
    # Write back in place (keeps symlinks and permissions of $dest)
    cat "$tmp" > "$dest"
    rm -f "$tmp"
    echo "merged: $dest  (backup: $dest.bak)"
}

install_config() {
    echo "== Claude Code (CLAUDE.md / agents / settings.json) =="
    local dest="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
    mkdir -p "$dest/agents"
    copy_file ./CLAUDE.md "$dest/CLAUDE.md"
    # Remove stale agents before copying, so a case-only rename is not undone
    # on case-insensitive file systems (macOS / Windows).
    local f name src keep
    if [ "$config_only" -eq 1 ]; then
        # --config-only: mirror ./agents; remove every agent file that is not in this repository
        for f in "$dest"/agents/*.md; do
            [ -f "$f" ] || continue
            name="$(basename "$f")"
            keep=0
            for src in ./agents/*.md; do
                if [ "$(basename "$src")" = "$name" ]; then keep=1; break; fi
            done
            if [ "$keep" -eq 0 ]; then
                rm -f "$f"
                echo "removed: $f  (not in repository)"
            fi
        done
    else
        # Full install: remove only agents that were renamed or removed from this repository
        for name in explorer.md; do
            if [ -f "$dest/agents/$name" ]; then
                rm -f "$dest/agents/$name"
                echo "removed: $dest/agents/$name  (obsolete)"
            fi
        done
    fi
    for f in ./agents/*.md; do
        copy_file "$f" "$dest/agents/$(basename "$f")"
    done
    merge_settings ./settings.json "$dest/settings.json"
}

[ "$config_only" -eq 1 ] || install_cli
install_config

echo "Done. Restart Claude Code (or run /agents to verify)."
