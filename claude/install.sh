#!/bin/bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ../common/lib.sh

# Claude Code のインストール (CLI 本体 + CLAUDE.md / agents) (Linux / macOS / Raspberry Pi)
# 実行方法:
#   ./install.sh                # CLI をインストール (未導入時のみ) + 設定を ~/.claude に配置
#   ./install.sh --config-only  # 設定 (CLAUDE.md / agents) の配置だけ行う
# - 設定は内容が同じなら何もしない。違う場合は .bak.<日時> にバックアップしてから上書きする。
# - settings.json は個人設定 (テーマ等) を含むため、管理・上書きしない。

config_only=0
[ "${1:-}" = "--config-only" ] && config_only=1

install_cli() {
    echo "== Claude Code (CLI) =="
    # ネイティブインストーラは 64bit OS が必要 (Raspberry Pi の 32bit OS 等は対象外)
    case "$(uname -m)" in
        x86_64|aarch64|arm64) ;;
        *) echo "[WARN] $(uname -m) は未対応のため CLI のインストールをスキップします (64bit OS が必要)。"
           return 0 ;;
    esac

    if ! command -v curl >/dev/null 2>&1; then
        if command -v apt-get >/dev/null 2>&1; then
            sudo apt-get update
            sudo apt-get install -y curl
        else
            echo "[ERROR] curl が見つかりません。インストールして再実行してください。" >&2
            exit 1
        fi
    fi

    if command -v claude >/dev/null 2>&1 || [ -x "$HOME/.local/bin/claude" ]; then
        echo "already installed: claude (更新は 'claude update')"
    else
        curl -fsSL https://claude.ai/install.sh | bash
    fi

    # ~/.local/bin を PATH に追加 (未設定の場合のみ)
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

echo "Done. Claude Code を再起動 (または /agents で確認) してください。"
