#!/bin/bash
# Common functions, sourced by the linux / mac / raspi setup scripts

# append_block <src> <dest>
#   Append the contents of <src> to <dest> as a marker-delimited block.
#   If the block already exists, replace only that block with the latest contents (no duplicates).
append_block() {
    local src="$1" dest="$2" name begin end tmp replaced=0
    name="$(basename "$src")"
    begin="# >>> configuration: ${name} >>>"
    end="# <<< configuration: ${name} <<<"

    touch "$dest"
    if grep -qxF "$begin" "$dest"; then
        if ! grep -qxF "$end" "$dest"; then
            echo "[ERROR] $dest has '$begin' but no matching end marker; fix it manually." >&2
            return 1
        fi
        tmp="$(mktemp)"
        awk -v b="$begin" -v e="$end" '
            $0 == b { skip = 1 }
            !skip   { print }
            $0 == e { skip = 0 }
        ' "$dest" > "$tmp"
        # Write back in place (keeps symlinks and permissions of $dest)
        cat "$tmp" > "$dest"
        rm -f "$tmp"
        replaced=1
    fi
    {
        [ "$replaced" -eq 0 ] && echo
        echo "$begin"
        cat "$src"
        echo "$end"
    } >> "$dest"
    echo "updated: $dest  (block: $name)"
}

# copy_file <src> <dest>
#   Copy <src> to <dest>. Do nothing if the contents are identical.
#   If <dest> exists and differs, overwrite it (no backup).
copy_file() {
    local src="$1" dest="$2"
    if [ -f "$dest" ]; then
        if cmp -s "$src" "$dest"; then
            echo "up to date: $dest"
            return 0
        fi
    fi
    cp "$src" "$dest"
    echo "copied: $dest"
}
