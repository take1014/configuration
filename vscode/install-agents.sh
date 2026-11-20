#!/bin/bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ../common/lib.sh

dest="$HOME/.copilot"
mkdir -p "$dest/agents"
copy_file ./copilot-instructions.md "$dest/copilot-instructions.md"

for f in ./agents/*.agent.md; do
    copy_file "$f" "$dest/agents/$(basename "$f")"
done

echo "Done. Restart VS Code to load the Copilot Chat instructions and agents."
