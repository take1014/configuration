# mac セットアップ

## 入るもの
- Claude Code (CLI)（`~/.local/bin` を `~/.zshrc` の PATH に追加）
- vim の設定（vim-plug、`.vimrc`、プラグイン、jellybeans カラースキーム）
- VS Code の `settings.json` と拡張機能（`anthropic.claude-code` を含む）

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

## 補足
- 再実行しても安全です（`.zshrc` への追記は未設定のときだけ）。
- フォント: [Inconsolata](https://fonts.google.com/specimen/Inconsolata) / [Migu-1M](https://mix-mplus-ipa.osdn.jp/migu/)（VS Code の `editor.fontFamily` で使用）
