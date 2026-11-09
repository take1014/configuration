#!/bin/bash
# linux / mac / raspi のセットアップスクリプトから source して使う共通関数

# append_block <src> <dest>
#   <src> の内容を <dest> に「マーカー付きブロック」として追記する。
#   既にブロックがあれば、そのブロックだけを最新の内容に置き換える (重複追記しない)。
append_block() {
    local src="$1" dest="$2" name begin end replaced=0
    name="$(basename "$src")"
    begin="# >>> configuration: ${name} >>>"
    end="# <<< configuration: ${name} <<<"

    touch "$dest"
    if grep -qxF "$begin" "$dest"; then
        awk -v b="$begin" -v e="$end" '
            $0 == b { skip = 1 }
            !skip   { print }
            $0 == e { skip = 0 }
        ' "$dest" > "$dest.tmp" && mv "$dest.tmp" "$dest"
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
#   <src> を <dest> にコピーする。内容が同じなら何もしない。
#   <dest> が既にあり内容が違う場合は、<dest>.bak.<日時> にバックアップしてから上書きする。
copy_file() {
    local src="$1" dest="$2"
    if [ -f "$dest" ]; then
        if cmp -s "$src" "$dest"; then
            echo "up to date: $dest"
            return 0
        fi
        cp "$dest" "$dest.bak.$(date +%Y%m%d%H%M%S)"
        echo "backup: $dest.bak.*"
    fi
    cp "$src" "$dest"
    echo "copied: $dest"
}
