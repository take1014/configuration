#!/bin/bash
set -e

# Claude Code (CLI) install script (native installer)
# 実行方法:
#   chmod +x install_claude.sh
#   ./install_claude.sh

if ! command -v curl >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y curl
fi

curl -fsSL https://claude.ai/install.sh | bash

# ~/.local/bin を PATH に追加 (未設定の場合のみ)
if ! grep -q '\.local/bin' ~/.bashrc 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

echo "Done. Restart your shell, then run: claude"
