# mac セットアップ

## 入るもの
- Claude Code (CLI)（`~/.local/bin` を `~/.zshrc` の PATH に追加）
- Claude Code の設定（`CLAUDE.md` とサブエージェントを `~/.claude` に配置、詳細は [../claude/README.md](../claude/README.md)）
- vim の設定（vim-plug、`.vimrc`、プラグイン、jellybeans カラースキーム）
- VS Code の `settings.json` と拡張機能（`anthropic.claude-code` を含む）
- dotfiles: `~/.zshrc` に `mac/.zshrc` を**追記**、`~/.tmux.conf` に `linux/.tmux.conf` を**コピー**（tmux が無ければ Homebrew で導入）

## 手順
```bash
git clone git@github.com:take1014/configuration.git
cd configuration/mac
./install_all.sh
```
終わったらシェルを再起動し、`claude` で起動確認します。

## 前提
- `vim` と `curl`（macOS 標準で可。プラグインを使う場合は Homebrew 版 vim 推奨）
- VS Code の拡張機能インストールには `code` コマンドが必要です。
  無い場合は VS Code のコマンドパレットで `Shell Command: Install 'code' command in PATH` を実行し、
  `../vscode/install.sh` を単独で実行してください（`install_all.sh` は案内を表示して続行します）。
- スクリプト全体を `sudo` で実行する必要はありません。

## dotfiles の扱い
| ファイル | 方法 | 再実行時 |
|---|---|---|
| `.zshrc` | `# >>> configuration: .zshrc >>>` 〜 `# <<< ... <<<` のブロックとして**追記** | ブロックだけを最新内容に置き換え（ブロック外の自分の記述は保持） |
| `.tmux.conf` / `.vimrc` | `linux/` のものを**コピー**（linux と共用） | 同じ内容なら何もしない。違う場合は上書き |

設定を変えたいときは、リポジトリ側のファイルを編集して `install_all.sh` を再実行してください。

注意:
- 以前に `.zshrc` へ手動で追記済みの場合、初回実行でブロックが追加され内容が二重になります（動作に問題はありませんが、気になる場合は手動分を削除してください）。
- `linux/.tmux.conf` の copy-mode（`y` / `Enter`）は Linux 用の `xsel` を使っています。mac でクリップボード連携が必要なら `pbcopy` への切り替えが必要です。

## 補足
- 再実行しても安全です（上記のとおり、`.zshrc` はブロックを置き換え、`.tmux.conf` / `.vimrc` は差分があるときだけバックアップ付きで上書きします）。
- フォント: [Inconsolata](https://fonts.google.com/specimen/Inconsolata) / [Migu-1M](https://mix-mplus-ipa.osdn.jp/migu/)（VS Code の `editor.fontFamily` で使用）
