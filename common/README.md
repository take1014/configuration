# common

Linux / macOS / Raspberry Pi のセットアップスクリプトから共通で使うシェル関数をまとめたフォルダです。
単体で実行するものではありません。

## lib.sh の役割
各 OS の `install_all.sh` で「dotfiles を追記する」「設定ファイルをコピーする」処理が重複していたため、
その2つを関数にして1か所にまとめています。再実行しても結果が変わらない（冪等な）書き方にしてあります。

### 使っているスクリプト
| スクリプト | 使い方 |
|---|---|
| `linux/install_all.sh` | `.bashrc` / `.zshrc` の追記、`.vimrc` / `.tmux.conf` / VS Code `settings.json` のコピー |
| `mac/install_all.sh` | `.zshrc` の追記、`.vimrc` / `.tmux.conf` / VS Code `settings.json` のコピー |
| `raspi/install_all.sh` | `.bashrc` の追記、`.vimrc` / `.tmux.conf` のコピー |
| `claude/install.sh` | `CLAUDE.md` とサブエージェント定義を `~/.claude` にコピー |

各スクリプトは自分のフォルダに `cd` した状態で次のように読み込みます（相対パスなので、リポジトリ全体を clone しておく必要があります）。

```bash
source ../common/lib.sh
```

Windows は PowerShell の `install_all.ps1` 内に同等の処理（`Copy-IfChanged`）があり、`lib.sh` は使いません。

## 関数

### `append_block <src> <dest>`
`<src>` の内容を、マーカーで囲んだブロックとして `<dest>` の末尾に追記します。
既存の `~/.bashrc` などを丸ごと上書きせず、このリポジトリの設定だけを足すために使います。

```bash
# >>> configuration: .bashrc >>>
（<src> の内容）
# <<< configuration: .bashrc <<<
```

- マーカー名には `<src>` のファイル名が入ります。
- 同じマーカーのブロックがすでにあれば、そのブロックだけを削除して最新内容を末尾に書き直します（重複しません）。ブロック外の内容はそのまま残ります。
- `<dest>` が無ければ作成します。

### `copy_file <src> <dest>`
`<src>` を `<dest>` にコピーします。

- 内容が同じなら何もしません（`up to date` と表示）。
- 内容が違えば**バックアップを取らずに上書き**します。`<dest>` 側で手で変えた内容は消えるので、変更はリポジトリ側で行ってください。
