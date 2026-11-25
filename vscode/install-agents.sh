#!/bin/bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ../common/lib.sh

# Place Copilot Chat user instructions and custom agents in ~/.copilot.
# - Files: do nothing if identical; otherwise overwrite (no backup).
# - Agents mirror ./agents: *.agent.md files in ~/.copilot/agents that are not in this repository are deleted.

dest="$HOME/.copilot"
mkdir -p "$dest/agents"
copy_file ./copilot-instructions.md "$dest/copilot-instructions.md"

# Remove stale agents before copying, so a case-only rename is not undone
# on case-insensitive file systems (macOS / Windows).
for f in "$dest"/agents/*.agent.md; do
    [ -f "$f" ] || continue
    name="$(basename "$f")"
    keep=0
    for src in ./agents/*.agent.md; do
        if [ "$(basename "$src")" = "$name" ]; then keep=1; break; fi
    done
    if [ "$keep" -eq 0 ]; then
        rm -f "$f"
        echo "removed: $f  (not in repository)"
    fi
done

for f in ./agents/*.agent.md; do
    copy_file "$f" "$dest/agents/$(basename "$f")"
done

echo "Done. Restart VS Code to load the Copilot Chat instructions and agents."
