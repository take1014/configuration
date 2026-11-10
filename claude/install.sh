#!/bin/bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ../common/lib.sh

# Install Claude Code (CLI + CLAUDE.md / agents) (Linux / macOS / Raspberry Pi)
# Usage:
#   ./install.sh                # install the CLI (only if not installed) + place config in ~/.claude
#   ./install.sh --config-only  # place config (CLAUDE.md / agents) only
# - Config files: do nothing if identical; otherwise back up to .bak.<timestamp> and overwrite.
# - settings.json holds personal settings (theme etc.), so it is neither managed nor overwritten.

config_only=0
[ "${1:-}" = "--config-only" ] && config_only=1

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
    local rc="$HOME/.bashrc"
    case "${SHELL:-}" in */zsh) rc="$HOME/.zshrc" ;; esac
    if ! grep -q '\.local/bin' "$rc" 2>/dev/null; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc"
        echo "updated: $rc  (PATH)"
    fi
}

install_config() {
    echo "== Claude Code (CLAUDE.md / agents) =="
    local dest="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
    mkdir -p "$dest/agents"
    copy_file ./CLAUDE.md "$dest/CLAUDE.md"
    local f
    for f in ./agents/*.md; do
        copy_file "$f" "$dest/agents/$(basename "$f")"
    done
}

[ "$config_only" -eq 1 ] || install_cli
install_config

echo "Done. Restart Claude Code (or run /agents to verify)."
