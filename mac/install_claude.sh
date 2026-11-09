#!/bin/bash
set -e

# Claude Code (CLI) install script (native installer)
# 実行方法:
#   chmod +x install_claude.sh
#   ./install_claude.sh

curl -fsSL https://claude.ai/install.sh | bash

# ~/.local/bin を PATH に追加 (未設定の場合のみ)
if ! grep -q '\.local/bin' ~/.zshrc 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
fi

echo "Done. Restart your shell, then run: claude"
