# VS Code 設定

VS Code の設定と拡張機能を揃えるためのファイル群です。
各OSの `install_all.*` から自動で呼ばれるので、通常は単独で実行する必要はありません。

| ファイル | 内容 |
|---|---|
| `settings.json` | エディタ / vim 拡張 / テーマ / git / Copilot Chat のコマンド確認ルールなどの設定 |
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

- `~/.copilot/agents/*.agent.md` のうちリポジトリに無いものは削除してから配置します（改名・廃止したエージェントを残さないため。自分で作った `.agent.md` も消えるので注意）。`.agent.md` 以外のファイルには触りません。
- 指示ファイルとエージェントは、内容が同じなら何もしません。違う場合は上書きします（バックアップは作りません）。

エージェントと指示は、Claude 設定（`claude/`）と同じ方針・役割分担です。

| エージェント | モデル | reasoning-effort | 役割 |
|---|---|---|---|
| `planner` | Opus 5.5 | high | 切り離せる設計・影響調査（普段の計画はメインの Plan エージェントで行う） |
| `developer` | Sonnet 5.5 | medium | 方針が決まった、切り離せる・並列の実装 |
| `reviewer` | Opus 5.5 | high | 重要・高リスクな変更のレビュー。依頼や仕様に照らして確認し、スタイルの指摘はしない |
| `explorer` | Haiku 5.5 | medium | コードの調査 |
| `worker` | Haiku 5.5 | low | 機械的な作業・コマンド実行と要約 |
| `researcher` | Sonnet 5.5 | medium | Web 調査（検索語に個人情報やリポジトリ名を入れない） |
| `debugger` | Opus 5.5 | high | 原因が分からないバグの原因特定（修正はしない） |

- 方針: 複数ファイルの作業はメインの Plan エージェントで計画し、難しい作業ではモデル選択画面で reasoning effort を上げます。サブエージェントは切り離せる作業・並列の作業・出力が多い作業に使い、数回で終わる作業は任せません。
- Opus を使うエージェント（`planner` / `reviewer` / `debugger`）は、プレミアムリクエストの消費が大きくなります。
- モデル名は Copilot Chat が認識するモデル名で指定しているため、契約や環境で利用できない場合は `agents/*.agent.md` の `model:` を VS Code のモデル選択に表示される名前に合わせてください。`reasoning-effort:` は、モデルが対応している場合に初期値として使われます。
- VS Code は `~/.claude/agents`（Claude 形式のエージェント）も読み込むため、Claude 側のエージェント（`Explore` など）が Copilot Chat にも表示されることがあります。

### コマンド実行の確認ルール（`settings.json`）
`chat.tools.terminal.autoApprove` で、`git push`・`git reset --hard`・`rm -rf`・`sudo` は必ず確認を出すようにしています（`false` は「確認する」の意味で、禁止ではありません）。この確認ルールは、自動承認や過去の「常に許可」より優先されます。
- VS Code には `.env` などの機密ファイルの読み取りを止める設定が無いため、秘密情報の扱いは指示ファイル（`copilot-instructions.md`）での指示に頼っています。

## 拡張機能の追加・削除
`install.sh` と `install.ps1` の `extensions` リストを **両方** 編集してください（同じ内容に保ちます）。
拡張機能 ID は Marketplace のページ、または `code --list-extensions` で確認できます。

## フォント
`settings.json` は `Inconsolata` と `Migu 1M` を指定しています。事前にインストールしてください。
- [Inconsolata](https://fonts.google.com/specimen/Inconsolata)
- [Migu-1M](https://mix-mplus-ipa.osdn.jp/migu/)
