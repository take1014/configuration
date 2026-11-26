# Claude Code 設定

Claude Code の **CLI 本体のインストール**と、グローバル設定 (`CLAUDE.md`・`settings.json`)・サブエージェント定義の配置をまとめたものです。
各OSの `install_all.*` からこのフォルダのスクリプトが呼ばれます（単独で実行する場合は下記）。

## ファイル
| ファイル | 配置先 | 内容 |
|---|---|---|
| `CLAUDE.md` | `~/.claude/CLAUDE.md` | 全プロジェクト共通のルール（日本語で回答・コード内は英語、安全、コーディング、計画と委譲の方針） |
| `settings.json` | `~/.claude/settings.json` | モデル・effort・権限ルール・ステータスラインなど（既存のファイルにマージ。上書きしない） |
| `agents/planner.md` | `~/.claude/agents/` | 設計・計画担当 (Opus / high、切り離せる設計・影響調査向け、読み取り専用) |
| `agents/developer.md` | 同上 | 実装担当 (Sonnet、切り離せる・並列の実装向け) |
| `agents/reviewer.md` | 同上 | レビュー担当 (Opus、高リスク変更向け、読み取り専用) |
| `agents/Explore.md` | 同上 | 調査担当 (Haiku、読み取り専用、組み込みの Explore を置き換え) |
| `agents/worker.md` | 同上 | 定型作業担当 (Haiku) |
| `agents/researcher.md` | 同上 | Web 調査担当 (Sonnet、Web 検索・取得のみ) |
| `agents/debugger.md` | 同上 | 原因調査担当 (Opus、修正はしない) |
| `install.sh` / `install.ps1` | - | CLI 本体・Node.js・プラグインのインストール + PATH 設定 + 上記を `~/.claude` にコピー (Linux・macOS・Raspberry Pi / Windows) |

## インストール
```bash
./install.sh                  # Linux / macOS / Raspberry Pi
./install.sh --config-only    # 設定の配置だけ (CLI のインストールを省略、agents はリポジトリと完全に一致させる)
./install.sh --help           # オプションの一覧
```
```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1                # Windows
powershell -ExecutionPolicy Bypass -File .\install.ps1 -ConfigOnly    # 設定の配置だけ (agents はリポジトリと完全に一致させる)
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Help          # オプションの一覧
```
- CLI は未導入のときだけインストールします（導入済みなら更新は `claude update`）。64bit OS が必要で、32bit の Raspberry Pi OS では CLI をスキップし設定だけ配置します。
- Node.js 18 以上が見つからないときだけ、公式サイトから最新の LTS をダウンロードし、SHA256 を照合してから入れます（sudo・管理者権限は不要。`--config-only` / `-ConfigOnly` では省略）。プラグインのフック（caveman など）は Node.js 18 以上で動き、無いと何もせずに終了するためです。
  - Linux・macOS: `~/.local/opt/node-<版>-<OS>` に展開し、`~/.local/opt/node` からリンクを張って、`node` / `npm` / `npx` / `corepack` のリンクを `~/.local/bin` に置きます。64bit（x86_64 / arm64）のみ対応です。18 未満の `node`（apt で入れたものなど）があっても入れ、`~/.local/bin` が PATH の先頭にあるのでこちらが優先されます。
  - Windows: `~\.local\opt\node-<版>-<OS>` に展開し、ジャンクション `~\.local\opt\node` をユーザーの PATH に追加します（新しいターミナルから有効）。
    - 公式インストーラー（MSI）や winget で入れた Node.js は、ターミナルを開き直す前でも検出して、そのまま使います（システム / ユーザーの PATH と `C:\Program Files\nodejs` を確認）。
    - 見つかった `node` が 18 未満なら、警告だけ出して入れません。システムの PATH はユーザーの PATH より優先されるので、別に入れても使われないためです。インストーラーか `winget upgrade OpenJS.NodeJS.LTS` で更新してから再実行してください。
    - このスクリプトで入れた後に公式インストーラーで入れた場合は、そちらが優先されます。不要になった `~\.local\opt\node*` とユーザーの PATH の項目は手で削除してください。
  - 更新は自動ではしません。新しい版に上げるときは、次のリンクを消してから再実行してください（古い版のフォルダは手で削除）。
    - Linux・macOS: `rm -f ~/.local/opt/node ~/.local/bin/node ~/.local/bin/npm ~/.local/bin/npx ~/.local/bin/corepack`
    - Windows: `cmd /c rmdir "%USERPROFILE%\.local\opt\node"`（ジャンクションだけを消します。`Remove-Item -Recurse` はリンク先の中身まで消すので使わないでください）
- `~/.local/bin` が PATH に無ければ、`~/.bashrc`（Linux では常に、macOS ではファイルがある場合のみ）と、`~/.zshrc`（zsh が入っているか、ファイルがある場合）に追記します。
- `CLAUDE.md` と agents は、内容が同じなら何もしません。違う場合は上書きします（バックアップは作りません）。
- `--config-only` / `-ConfigOnly` では、配置先の `agents/*.md` のうちリポジトリに無いものをすべて削除してから上書きします（`/agents` で自分で作ったエージェントも消えるので注意）。`.md` 以外のファイルには触りません。
- オプションなしのときは、改名・廃止したエージェント（現在は `explorer.md`）だけを削除します。
- インストール後は Claude Code を再起動してください。`/agents` で一覧を確認できます。
- `settings.json` は**どちらのモードでも上書きせずマージ**します（Claude Code 自身も `/effort` や `/model` などでこのファイルを書き換えるため）。
  - ファイルが無ければ、リポジトリの `settings.json` をそのままコピーします。
  - あれば、足りないキーだけを追加し、配列（`permissions.deny` など）には足りない項目だけを末尾に追加します。既にある値（`/effort` で選んだ effort やテーマなど）は変えません。
  - 書き換えるときは `settings.json.bak` にバックアップを作ります。足りないものが無ければ何もしません。
  - リポジトリから消したルールは既存のファイルからは消えません。手で削除してください。
  - Linux・macOS では `jq` を使います（無ければ apt で入れます。apt が無い環境では警告を出してスキップ）。Windows は PowerShell の JSON 機能を使います。既存のファイルが壊れた JSON のときはエラーで止まり、ファイルには触りません。
- `CLAUDE_CONFIG_DIR` を設定している場合は、そのディレクトリに配置します。

## エージェントとモデルの使い分け
公式ドキュメントとコミュニティ（下記の参考）の推奨に合わせ、メインは Opus / medium で文脈を持ったまま計画・実装します。難しい作業はメイン自身の effort を上げて対応します（サブエージェントに任せても賢くはならないため）。サブエージェントは、切り離せる作業・並列にできる作業・出力が多い作業・会話に引きずられない独立したレビューに使います。

| エージェント | モデル | effort | 役割 | 権限 |
|---|---|---|---|---|
| メイン | Opus | medium | 計画（Plan モード）・実装・調整。難しい作業は `/effort high` 以上に上げる（下記の個人設定で指定） | - |
| `planner` | Opus | high | 切り離せる設計・影響調査（並列で使うとき、会話に左右されない独立した案がほしいとき） | 読み取りのみ |
| `developer` | Sonnet | medium | 方針が決まった、切り離せる・並列の実装・テスト作成 | 読み書き |
| `reviewer` | Opus | high | 重要・高リスクな変更のレビュー。依頼や仕様に照らして確認し、スタイルの指摘はしない | 読み取りのみ |
| `Explore` | Haiku | medium | コードの調査（どこに何があるか・処理の流れ・慣習の把握） | 読み取りのみ |
| `worker` | Haiku | low | 機械的な置換・ログ整形・テスト実行と要約 | 読み書き（限定的な指示のみ） |
| `researcher` | Sonnet | medium | Web 調査（公式ドキュメント・リリースノート・手順の変更・既知の問題） | Web 検索・取得のみ（ローカルのファイルは読まない） |
| `debugger` | Opus | high | 原因が分からないバグ・エラーの再現と原因の特定（修正はしない） | 読み取り + 再現のためのコマンド実行 |

- 標準の流れ: メインで計画（大きい作業は Plan モード）→ メインで実装（切り離せる・並列の実装は `developer`）→ `reviewer`（重要・高リスクな変更のとき）
- 難しい作業（実質的に異なる方針が複数ある／3つ以上のモジュールや公開 API に影響する／データ移行・セキュリティ・互換性に関わる）: Claude が `/effort high`・`xhigh` か `ultrathink` を提案するので、上げてから Plan モードで計画します。
- 原因が分からないバグ: `debugger` → 修正 → `reviewer`（変更が重要・高リスクなとき）

```
あなた → メイン (Opus) ─┬→ planner    (Opus)   切り離せる設計・影響調査
                         ├→ developer  (Sonnet) 切り離せる・並列の実装
                         ├→ reviewer   (Opus)   重要な変更をレビューする
                         ├→ Explore    (Haiku)  コードの調査 (複数を並列で)
                         ├→ worker     (Haiku)  定型作業 (複数を並列で)
                         ├→ researcher (Sonnet) Web 調査
                         └→ debugger   (Opus)   バグの原因を特定する
```

- **メインのセッションが調整役**です。サブエージェントは別のサブエージェントを起動できません。
- 使い方の例:
  - 「`reviewer` で今の変更をレビューして」
  - 「`Explore` を並列に使って、各ディレクトリの README の有無を調べて」
  - 「`researcher` で docker の公式インストール手順が変わっていないか調べて」
  - 「`debugger` でこのテストが落ちる原因を調べてから直して」
- 説明文 (`description`) に基づいて、Claude が自動で委譲することもあります。数回のツール呼び出しで終わる作業は任せません。ファイルを編集するエージェントを並列で動かすときは、worktree で作業場所を分けます。
- サブエージェントは会話を引き継がず、既定では `CLAUDE.md` を読み込みます。`Explore` / `worker` / `researcher` は必要なルールを自分のプロンプトに持っているので、`omitClaudeMd: true` で読み込みを省いています。Haiku の `Explore` / `worker` は `maxTurns` で暴走を防いでいます。
- `Explore` は組み込みの Explore エージェントを同じ名前で置き換えます（組み込みはメインと同じモデルで動くため）。
- 読み取り専用は `tools` で Edit / Write を外し、プロンプトで指示しているだけです。Bash 経由の書き込みまでは強制していません。
- モデル指定は `opus` / `sonnet` / `haiku` の別名です。新しい世代が出たら自動で最新を使います。固定したい場合は `agents/*.md` の `model:` にモデル ID を書いてください。
- `effort`（`low` / `medium` / `high` / `xhigh` / `max`）は考える量の指定で、`agents/*.md` の `effort:` がそのエージェントの動作中だけセッションの値を上書きします。`effort:` を省略すると、メインと別モデルのエージェントにはセッションの値が引き継がれず、そのモデルの `modelSettings` の値か既定値で動きます。

## 個人設定（`settings.json`）
`settings.json` の内容は、公式の設定例と Trail of Bits の設定を参考にしています。インストール時に `~/.claude/settings.json` にマージされます（上記）。好みの設定（テーマ、自動圧縮の範囲など）は `~/.claude/settings.json` 側に書けば、そのまま残ります。

- **モデル / effort**: メインは Opus / medium（Opus 5.5 の既定）。難しい作業は `/effort high`、長い自律的な作業は `/effort xhigh`、一回だけ深く考えさせたいときはプロンプトに `ultrathink` を入れます。`max` は考えすぎになりやすいので普段は使いません。
- effort はモデルごとに `modelSettings.<モデルID>.effortLevel` で指定します（`/effort` で Enter を押すと自動で保存されます）。トップレベルの `effortLevel` は Opus 5.5 には効きません。`max` は保存できず、そのセッション限りです。新しいモデルに切り替えたときは、そのモデルIDで指定し直してください。
- **advisor** は使いません（`advisorModel` は設定しない）。Opus のメインに付けられる advisor は Opus と Fable だけで、呼ばれるたびに会話全体をキャッシュなしで読み直すためです。リスクの高い変更は `reviewer` で確認します。
- **permissions**: 「絶対にさせたくないこと」は `CLAUDE.md` ではなく設定で強制します（`CLAUDE.md` の指示は守られない場合があるため）。
  - `deny`: 秘密情報（`.env`・認証情報）の読み取り、`sudo`、強制 push。deny はどのモード（auto を含む）でも有効です。対象は `.env`・`.env.local`・`.env.*.local`・`.env.production`・`.env.development`・`.env.staging`・`.env.test` と `secrets/` で、`.env.example` などのひな形は読めるようにしています。
  - `ask`: push・`git reset --hard`・`rm -rf` を確認対象にしています（auto モードでも確認が出るかは未検証）。
  - 限界: `Read` の deny が Bash にどこまで効くかは情報が分かれます。公式は「`cat .env` のような単純な読み取りは止めるが、ファイルを開くスクリプトは止めない」、Trail of Bits は「`/sandbox` なしでは Bash で回避できる」としています。Bash のルールも書かれたコマンドの形に一致するだけなので、`git -C . push` のような書き方は対象外です。徹底するなら `/sandbox` を併用します。
- **enableAllProjectMcpServers: false**: リポジトリに含まれる `.mcp.json` の MCP サーバーを自動で有効にしません（悪意のあるサーバーを防ぐため）。
- **statusLine**: モデル名とコンテキストの使用率を表示します。`jq` が必要です（Linux・Windows では別途インストール）。

### 入れていないもの（必要に応じて）
- `/sandbox`: シェルコマンドを閉じ込め、deny ルールを Bash にも効かせます。無人実行や `--dangerously-skip-permissions` を使うなら必須です。
- 許可リスト（`permissions.allow`）: auto モードでは効果が小さいため入れていません。確認が多いと感じたら `/fewer-permission-prompts` で作れます。
- フック: 編集後の自動整形（PostToolUse）や、完了前にテストを通す（Stop）はプロジェクトごとに設定するのが一般的です。デスクトップ通知（Notification）は好みで。
- テレメトリ無効化の環境変数: `DISABLE_TELEMETRY` は advisor などフラグ取得が必要な機能を止めるので入れていません。

## 運用のコツ（公式・コミュニティ）
| 場面 | やること |
|---|---|
| 別のタスクに移る | `/clear`。関係ない話を同じ会話で続けない（1セッション1タスク） |
| 修正が2回うまくいかない | 3回目を重ねず、`/rewind`（Esc 2回）で戻すか `/clear` して、より具体的な指示で出し直す |
| 長い作業の途中 | `/compact 残したいこと`（例: `/compact API の変更点とテストコマンドを残して`）。自動の圧縮に任せきりにしない |
| 作業を中断・再開する | `/rename 名前` → `claude --resume 名前`（直前の会話は `claude --continue`） |
| 本題と関係ない質問 | `/btw` で聞く（会話の履歴に残らない） |
| 難しい作業 | `/effort high`・`xhigh` か `ultrathink`。大きな機能は Plan モードで、Claude に質問させて仕様を固めてから実装 |
| 完了と言われたとき | 実行したコマンドと結果を確認する。`/code-review` で会話を見ていない別の視点からレビュー |
| 使用量・読み込み内容の確認 | `/usage`（スキル・サブエージェント別の使用量）、`/context`（読み込まれている CLAUDE.md など） |
| 同じ指摘を2回した | `CLAUDE.md` にルールを足す。それでも守られないならフックや permissions で強制する |
| CLAUDE.md の見直し | `/doctor` で不要な記述を確認。「これがないと Claude はどんな間違いをするか」に答えられない行は削る |
| 作業を別のセッションに引き継ぐ | 計画と進み具合をファイルに書かせ（必要ならコミット）、`/clear` してから新しいセッションでそのファイルを読ませる。長い会話を `/compact` で引きずるより確実 |
| 週に一度の振り返り | `/insights` と `/usage` を見て、繰り返し出る問題を `CLAUDE.md` のルール・スキル・フックに落とし込む。1日に何度もする作業はスキルやコマンドにする |

- コミュニティでは「コンテキストの使用率が 40〜60% を超えると質が落ちやすい」という声もあります（公式の数値ではありません）。statusLine の使用率を目安に、早めに `/compact` や `/clear` をします。

## ベストプラクティス（`CLAUDE.md` に反映済み）
- **調べてから書く**: 変更前に関連コードを読む。バージョンや API は記憶に頼らず現在のドキュメントで確認する。
- **範囲を守る**: 頼まれたことだけを変更する。
- **証拠で報告**: 完了と言うときは、実行したコマンドと主な結果を示す。できなかったことは正直に報告する。
- **やり直しの判断**: 同じ修正に2回失敗したら、重ねずに `/rewind`・`/clear` を提案する。
- **安全**: commit / push / 削除は依頼されたときだけ。秘密情報に触れない。破壊的操作は事前に確認（設定でも強制）。
- **文脈を節約**: 区切りでは Claude が `/clear` / `/compact <残す内容>` を提案する。調査や大量出力の作業は `Explore` / `worker` / `researcher` に任せて要約だけ受け取る。数回で終わる作業は任せない。
- **計画してから実装**: 大きな作業はメインの Plan モードで計画する（文脈を失わないため）。難しい作業は effort を上げることを提案する。
- **CLAUDE.md は短く**: プロジェクト固有のルールは、各リポジトリの `CLAUDE.md` に書く。

## 参考
- 公式: [Best practices](https://code.claude.com/docs/en/best-practices) / [Subagents](https://code.claude.com/docs/en/sub-agents) / [Model configuration](https://code.claude.com/docs/en/model-config) / [Settings examples](https://code.claude.com/docs/en/settings-example) / [Advisor](https://code.claude.com/docs/en/advisor)
- コミュニティ: [trailofbits/claude-code-config](https://github.com/trailofbits/claude-code-config) / [shanraisshan/claude-code-best-practice](https://github.com/shanraisshan/claude-code-best-practice)

## 編集方法
このリポジトリ側のファイルを編集し、`install.sh`（または `install_all`）を再実行して反映します。
エージェントを追加するときは `agents/<名前>.md` を作ってください（`name` / `description` / `tools` / `model` / `effort` を frontmatter に書きます）。
リポジトリから削除・改名したエージェントは、`--config-only` / `-ConfigOnly` で実行すれば配置先からも削除されます。オプションなしのインストールでも消したい場合は、インストーラーの削除リスト（`install.sh` / `install.ps1` の `explorer.md` など）に追加してください。
