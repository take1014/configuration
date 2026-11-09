# configuration

開発環境の設定ファイルとセットアップスクリプト集です。
OS ごとに `install_all` を1回実行するだけで、**Claude Code (CLI)・vim・VS Code** などが揃います。

## クイックスタート

まずリポジトリを clone します（vim 設定などをフォルダ間で共用しているため、リポジトリ全体が必要です）。

```bash
git clone git@github.com:take1014/configuration.git
cd configuration
```

使っている環境を選んで実行してください。

### Linux (Ubuntu)
```bash
cd linux
./install_all.sh              # Docker / VS Code / Claude Code / vim
./install_all.sh --nvidia     # + NVIDIA Container Toolkit (GPU を使う場合)
```
詳細: [linux/README.md](linux/README.md)

### macOS
```bash
cd mac
./install_all.sh              # Claude Code / vim / VS Code (設定 + 拡張機能)
```
詳細: [mac/README.md](mac/README.md)

### Windows (PowerShell)
```powershell
cd windows
powershell -ExecutionPolicy Bypass -File .\install_all.ps1   # Claude Code / vim / VS Code
```
詳細: [windows/README.md](windows/README.md)

### Raspberry Pi
```bash
cd raspi
./install_all.sh              # vim / tmux / bash 設定 / Claude Code
```
詳細: [raspi/README.md](raspi/README.md)

## 環境ごとの対応表

| | Linux | macOS | Windows | Raspberry Pi |
|---|:-:|:-:|:-:|:-:|
| Claude Code (CLI) | ✅ | ✅ | ✅ | ✅ (64bit OS) |
| vim + プラグイン | ✅ (ソースビルド) | ✅ | ✅ | ✅ (apt) |
| VS Code 設定 + 拡張機能 | ✅ (本体も) | ✅ | ✅ | - |
| Docker | ✅ | - | - | - |
| tmux 設定 | - | - | - | ✅ |

## 共通の注意
- スクリプト全体を `sudo` で実行する必要はありません（必要な箇所だけ内部で `sudo` します）。Windows も管理者権限は不要です。
- 再実行しても安全です（設定の追記は未設定のときだけ）。
- 終わったらシェル（ターミナル）を再起動し、`claude` で起動確認してください。

## フォルダ構成
| フォルダ | 内容 |
|---|---|
| `linux/` | Ubuntu 用セットアップ、`.vimrc` / `.tmux.conf` / `.bashrc` / `.zshrc`（vim・tmux 設定は mac・raspi も共用） |
| `mac/` | macOS 用セットアップ、`.zshrc` |
| `windows/` | Windows 用セットアップ、`.vimrc` |
| `raspi/` | Raspberry Pi 用セットアップ |
| `vscode/` | VS Code の `settings.json` と拡張機能インストーラ（各 OS から呼ばれる）: [vscode/README.md](vscode/README.md) |

## フォント
VS Code の設定（`editor.fontFamily`）で使用します。事前にインストールしてください。
- [Inconsolata](https://fonts.google.com/specimen/Inconsolata)
- [Migu-1M](https://mix-mplus-ipa.osdn.jp/migu/)

## 補足: vim-plug を手動で入れる場合
`install_all` が自動で行うため通常は不要です。

```bash
# unix
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```
```powershell
# windows
iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim | ni $HOME/vimfiles/autoload/plug.vim -Force
```
