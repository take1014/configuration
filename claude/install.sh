#!/bin/bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ../common/lib.sh

# Claude Code の設定 (CLAUDE.md / agents) を ~/.claude にコピーする (Linux / macOS / Raspberry Pi)
# 実行方法:
#   ./install.sh
# - 内容が同じなら何もしない。違う場合は .bak.<日時> にバックアップしてから上書きする。
# - settings.json は個人設定 (テーマ等) を含むため、管理・上書きしない。

dest="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
mkdir -p "$dest/agents"

copy_file ./CLAUDE.md "$dest/CLAUDE.md"
for f in ./agents/*.md; do
    copy_file "$f" "$dest/agents/$(basename "$f")"
done

echo "Done. Claude Code を再起動 (または /agents で確認) してください。"
