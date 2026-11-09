# Windows セットアップ

## 入るもの
- Claude Code (CLI)
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
- 管理者権限は不要です。

## 補足
- 再実行しても安全です（ディレクトリは `-Force` で作成、ファイルは上書き）。
- フォント: [Inconsolata](https://fonts.google.com/specimen/Inconsolata) / [Migu-1M](https://mix-mplus-ipa.osdn.jp/migu/)
