# Windows セットアップ

## 入るもの
- Claude Code (CLI)
- Claude Code の設定（`CLAUDE.md` とサブエージェントを `~/.claude` に配置、詳細は [../claude/README.md](../claude/README.md)）
- vim の設定（vim-plug、`.vimrc`、プラグイン、jellybeans カラースキーム）
- VS Code の `settings.json` と拡張機能（`anthropic.claude-code` を含む）

## 手順 (PowerShell)
```powershell
git clone git@github.com:take1014/configuration.git
cd configuration\windows
powershell -ExecutionPolicy Bypass -File .\install_all.ps1
```
終わったらターミナルを再起動し、`claude` で起動確認します。

## 前提
- `vim` が PATH にあること（無い場合: `winget install vim.vim`）。無いとスクリプトはエラーで止まります。
- VS Code の拡張機能インストールには `code` コマンドが必要です。
  無い場合は VS Code のコマンドパレットで `Shell Command: Install 'code' command in PATH` を実行し、
  `..\vscode\install.ps1` を単独で実行してください（`install_all.ps1` は案内を表示して続行します）。
- `ag`（the_silver_searcher）は任意です。無い場合は警告のみで、vim の `:Ag` コマンドは使えません（`scoop install ag` などで入れると有効になります）。パターンを囲むときはダブルクォートを使ってください（例: `:Ag "foo bar"`。cmd.exe はシングルクォートを引用符として扱いません）。
- 管理者権限は不要です。

## 補足
- 再実行しても安全です（ディレクトリは `-Force` で作成、ファイルは上書き）。VS Code 拡張機能はインストール済みならスキップします。
- フォント: [Inconsolata](https://fonts.google.com/specimen/Inconsolata) / [Migu-1M](https://mix-mplus-ipa.osdn.jp/migu/)
