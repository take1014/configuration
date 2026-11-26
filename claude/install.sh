#!/bin/bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ../common/lib.sh

# Install Claude Code (CLI + Node.js + plugins + CLAUDE.md / agents / settings.json) (Linux / macOS / Raspberry Pi)
# Usage:
#   ./install.sh                # install the CLI, Node.js and plugins (only if not installed) + place config in ~/.claude
#   ./install.sh --config-only  # place config (CLAUDE.md / agents / settings.json) only
#   ./install.sh --help         # show usage
# - Node.js 18+ (needed by plugin hooks): latest LTS into ~/.local/opt unless node 18+ exists; skipped with --config-only.
# - Plugins (caveman, superpowers): installed in user scope only if not installed; skipped with --config-only.
# - Config files: do nothing if identical; otherwise overwrite (no backup).
# - Config-only mode mirrors agents/: agent .md files not in this repository are deleted.
#   A full install deletes only the listed obsolete agents (renamed or removed).
# - settings.json is merged, never overwritten (both modes): keys missing from the existing file are added,
#   arrays (e.g. permissions.deny) get the missing entries appended, and existing values are kept.
#   A backup (settings.json.bak) is written before any change. Requires jq.

usage() {
    cat <<'USAGE'
Usage: ./install.sh [--config-only] [-h|--help]

  (no option)    install the CLI, Node.js and plugins (only if not installed) + place config in ~/.claude
  --config-only  place config (CLAUDE.md / agents / settings.json) only; skip the CLI, Node.js and plugin install
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

# install_node
#   Install the latest Node.js LTS from nodejs.org into ~/.local/opt (no sudo), unless node 18+ exists.
#   Plugin hooks (e.g. caveman) run with node and silently do nothing without it; they need Node.js 18+.
#   An older node (e.g. from apt on Raspberry Pi OS) is left as is; ~/.local/bin comes first in PATH.
#   Layout: ~/.local/opt/node-<ver>-<platform>, linked as ~/.local/opt/node; bin links in ~/.local/bin.
#   Failures only warn, so the rest of the install continues.
NODE_MIN_MAJOR=18
install_node() {
    echo "== Node.js (for plugin hooks) =="
    local bin_dir="$HOME/.local/bin" opt_dir="$HOME/.local/opt" os arch platform ver file tmp sum b
    local node_cmd node_ver node_major
    node_cmd="$(command -v node 2>/dev/null || true)"
    if [ -z "$node_cmd" ] && [ -x "$bin_dir/node" ]; then
        node_cmd="$bin_dir/node"
    fi
    if [ -n "$node_cmd" ]; then
        node_ver="$("$node_cmd" --version 2>/dev/null || true)"
        node_major="${node_ver#v}"
        node_major="${node_major%%.*}"
        if [[ "$node_major" =~ ^[0-9]+$ ]] && [ "$node_major" -ge "$NODE_MIN_MAJOR" ]; then
            echo "already installed: node $node_ver  ($node_cmd)"
            return 0
        fi
        echo "[WARN] node ${node_ver:-(unknown version)} at $node_cmd is older than v$NODE_MIN_MAJOR," \
            "which plugin hooks need; installing the LTS into $opt_dir." >&2
    fi
    case "$(uname -s)" in
        Linux)  os=linux ;;
        Darwin) os=darwin ;;
        *) echo "[WARN] $(uname -s) is not supported; skipping Node.js install." >&2; return 0 ;;
    esac
    case "$(uname -m)" in
        x86_64)        arch=x64 ;;
        aarch64|arm64) arch=arm64 ;;
        *) echo "[WARN] $(uname -m) is not supported; skipping Node.js install (64-bit OS required)." >&2
           return 0 ;;
    esac
    platform="$os-$arch"
    # ln -sfn would create the link inside a real directory instead of replacing it
    if [ -e "$opt_dir/node" ] && [ ! -L "$opt_dir/node" ]; then
        echo "[WARN] $opt_dir/node exists and is not a symlink; skipping Node.js install (remove it and re-run)." >&2
        return 0
    fi

    tmp="$(mktemp -d)"
    # index.json lists one release per line, newest first; LTS releases have "lts":"<codename>"
    # (downloaded to a file first, so an early-exiting grep cannot fail the pipeline via SIGPIPE)
    ver=""
    if curl -fsSL -o "$tmp/index.json" https://nodejs.org/dist/index.json; then
        ver="$(grep -m1 '"lts":"' "$tmp/index.json" | sed -E 's/.*"version":"(v[0-9.]+)".*/\1/' || true)"
    fi
    if ! printf '%s' "$ver" | grep -qE '^v[0-9]+\.[0-9]+\.[0-9]+$'; then
        echo "[WARN] could not determine the Node.js LTS version; skipping Node.js install." >&2
        rm -rf "$tmp"
        return 0
    fi
    file="node-$ver-$platform.tar.gz"

    if ! curl -fsSL -o "$tmp/$file" "https://nodejs.org/dist/$ver/$file" \
        || ! curl -fsSL -o "$tmp/SHASUMS256.txt" "https://nodejs.org/dist/$ver/SHASUMS256.txt"; then
        echo "[WARN] failed to download Node.js $ver; skipping Node.js install." >&2
        rm -rf "$tmp"
        return 0
    fi
    if command -v sha256sum >/dev/null 2>&1; then
        sum="$(sha256sum "$tmp/$file" | cut -d' ' -f1)"
    elif command -v shasum >/dev/null 2>&1; then
        sum="$(shasum -a 256 "$tmp/$file" | cut -d' ' -f1)"
    else
        echo "[WARN] sha256sum / shasum not found; skipping Node.js install." >&2
        rm -rf "$tmp"
        return 0
    fi
    if ! grep -qxF "$sum  $file" "$tmp/SHASUMS256.txt"; then
        echo "[WARN] checksum mismatch for $file; skipping Node.js install." >&2
        rm -rf "$tmp"
        return 0
    fi

    if ! mkdir -p "$opt_dir" "$bin_dir" || ! tar -xzf "$tmp/$file" -C "$opt_dir"; then
        echo "[WARN] failed to extract $file into $opt_dir; skipping Node.js install." >&2
        rm -rf "$tmp"
        return 0
    fi
    rm -rf "$tmp"
    if ! ln -sfn "$opt_dir/node-$ver-$platform" "$opt_dir/node"; then
        echo "[WARN] failed to link $opt_dir/node; skipping Node.js install." >&2
        return 0
    fi
    for b in node npm npx corepack; do
        [ -e "$opt_dir/node/bin/$b" ] || continue
        # Never overwrite a real file that this script did not create
        if [ -e "$bin_dir/$b" ] && [ ! -L "$bin_dir/$b" ]; then
            echo "[WARN] $bin_dir/$b exists and is not a symlink; not linking it." >&2
        elif ! ln -sfn "$opt_dir/node/bin/$b" "$bin_dir/$b"; then
            echo "[WARN] failed to link $bin_dir/$b" >&2
        fi
    done
    echo "installed: node $ver  ($opt_dir/node-$ver-$platform)"
}

# Plugins to install, as "<plugin>@<marketplace> <marketplace source>"
PLUGINS=(
    "caveman@caveman JuliusBrussee/caveman"
    "superpowers@claude-plugins-official anthropics/claude-plugins-official"
)

install_plugins() {
    echo "== Claude Code (plugins) =="
    local claude_bin entry id src installed
    claude_bin="$(command -v claude 2>/dev/null || true)"
    [ -n "$claude_bin" ] || [ ! -x "$HOME/.local/bin/claude" ] || claude_bin="$HOME/.local/bin/claude"
    if [ -z "$claude_bin" ]; then
        echo "[WARN] claude not found; skipping plugin install." >&2
        return 0
    fi
    installed="$("$claude_bin" plugin list --json 2>/dev/null || true)"
    for entry in "${PLUGINS[@]}"; do
        id="${entry%% *}"
        src="${entry#* }"
        if printf '%s' "$installed" | grep -q "\"id\": *\"$id\""; then
            echo "already installed: $id"
            continue
        fi
        # --marketplace adds the marketplace first if it is not configured yet
        if "$claude_bin" plugin install "${id%@*}" --marketplace "$src" --scope user; then
            echo "installed: $id"
        else
            echo "[WARN] failed to install plugin: $id" >&2
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

if [ "$config_only" -eq 0 ]; then
    install_cli
    install_node
    install_plugins
fi
install_config

echo "Done. Restart Claude Code (or run /agents to verify)."
