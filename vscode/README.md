# VS Code 設定

VS Code の設定と拡張機能を揃えるためのファイル群です。
各OSの `install_all.*` から自動で呼ばれるので、通常は単独で実行する必要はありません。

| ファイル | 内容 |
|---|---|
| `settings.json` | エディタ / vim 拡張 / テーマ / git などの設定 |
| `copilot-instructions.md` | Copilot Chat のユーザー共通指示 |
| `agents/*.agent.md` | Copilot Chat のカスタムエージェント定義 |
| `install.sh` | 拡張機能の一括インストール (Linux / macOS) |
| `install.ps1` | 拡張機能の一括インストール (Windows) |
| `install-agents.sh` / `install-agents.ps1` | Copilot Chat の指示とエージェントをユーザー領域に配置 |

## 設定ファイル (`settings.json`) の配置先
| OS | 配置先 |
|---|---|
| Linux | `~/.config/Code/User/` |
| macOS | `~/Library/Application Support/Code/User/` |
| Windows | `%APPDATA%\Code\User\` |

各OSのセットアップスクリプトがコピーします。手動の場合は上記へ上書きコピーしてください。

> **注意**: 内容が違えば、バックアップなしで上書きします。VS Code の設定画面などで変えた設定は、セットアップスクリプトを再実行すると消えます。残したい設定は、先にこのリポジトリの `settings.json` に反映してください。

## 拡張機能のインストール
前提: `code` コマンドが PATH にあること。
無い場合は VS Code のコマンドパレット (`Ctrl/Cmd+Shift+P`) で
`Shell Command: Install 'code' command in PATH` を実行します。

```bash
# Linux / macOS
./install.sh
```
```powershell
# Windows
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

- `install.sh` / `install.ps1` はインストール済みの拡張をスキップし、失敗した拡張は最後にまとめて表示します。
- 再実行しても安全です。

## 主な拡張機能
- **AI**: Claude Code (`anthropic.claude-code`)、GitHub Copilot Chat
- **Python / Jupyter**: Python, Pylance, isort, debugpy, Jupyter 一式
- **C/C++ / Go**: cpptools, CMake Tools, Go
- **Remote**: Remote - SSH / Containers
- **その他**: Vim, Material Icon Theme, Jellybeans テーマ, PDF / CSV ビューア など

## Copilot Chat カスタムエージェント
`install_all` は、個人向け指示ファイルとエージェント定義をユーザー領域の `~/.copilot/` に配置します。`install-agents.sh` / `install-agents.ps1` を単独で実行して配置することもできます。VS Code を再起動すると、設定したエージェントを Copilot Chat から利用できます。

| OS | 配置先 |
|---|---|
| Linux / macOS | `~/.copilot/copilot-instructions.md`、`~/.copilot/agents/` |
| Windows | `%USERPROFILE%\.copilot\copilot-instructions.md`、`%USERPROFILE%\.copilot\agents\` |

エージェントは Claude 設定と同じ役割分担です。モデル名は Copilot Chat が認識するモデル名で指定しているため、契約や環境で利用できない場合は `agents/*.agent.md` の `model:` を VS Code のモデル選択に表示される名前に合わせてください。`reasoning-effort:` は Copilot が対応する場合に適用されます。

## 拡張機能の追加・削除
`install.sh` と `install.ps1` の `extensions` リストを **両方** 編集してください（同じ内容に保ちます）。
拡張機能 ID は Marketplace のページ、または `code --list-extensions` で確認できます。

## フォント
`settings.json` は `Inconsolata` と `Migu 1M` を指定しています。事前にインストールしてください。
- [Inconsolata](https://fonts.google.com/specimen/Inconsolata)
- [Migu-1M](https://mix-mplus-ipa.osdn.jp/migu/)
