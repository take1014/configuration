# Raspberry Pi セットアップ

Raspberry Pi OS (Debian 系) 向けです。

## 入るもの
- vim (apt 版) と vim-plug、`.vimrc`、プラグイン、jellybeans カラースキーム（`vi` も update-alternatives で vim に切り替え）
- tmux（xsel も導入）
- dotfiles: `~/.bashrc` に `linux/.bashrc` を**追記**（alias、`EDITOR`、プロンプト色）、`~/.tmux.conf` に `linux/.tmux.conf` を**コピー**
- Claude Code (CLI)（`~/.local/bin` を PATH に追加）
- Claude Code の設定（`CLAUDE.md` とサブエージェントを `~/.claude` に配置、詳細は [../claude/README.md](../claude/README.md)）

## 手順
```bash
git clone git@github.com:take1014/configuration.git
cd configuration/raspi
./install_all.sh
```
終わったらシェルを再起動し（`source ~/.bashrc`）、`claude` で起動確認します。

## 前提・注意
- Claude Code のインストールには **64bit OS (aarch64)** が必要です。32bit OS の場合はその部分をスキップして警告を表示し、他は続行します。
  `uname -m` が `aarch64` なら対象です。
- 初回は `apt full-upgrade` を実行するため時間がかかります。
- スクリプト全体を `sudo` で実行する必要はありません。
- 再実行しても安全です。`.bashrc` は `# >>> configuration: .bashrc >>>` のブロックだけを最新内容に置き換え、`.tmux.conf` / `.vimrc` は内容が違えば上書きします。
- `linux/.vimrc` と `linux/.tmux.conf` を共用しています。リポジトリ全体を clone した状態で実行してください。
