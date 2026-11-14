# Claude Code 設定

Claude Code の **CLI 本体のインストール**と、グローバル設定 (`CLAUDE.md`)・サブエージェント定義の配置をまとめたものです。
各OSの `install_all.*` からこのフォルダのスクリプトが呼ばれます（単独で実行する場合は下記）。

## ファイル
| ファイル | 配置先 | 内容 |
|---|---|---|
| `CLAUDE.md` | `~/.claude/CLAUDE.md` | 全プロジェクト共通のルール（日本語で回答・コード内は英語、安全、コーディング、エージェントの使い分け） |
| `agents/planner.md` | `~/.claude/agents/` | 設計・計画担当 (Opus、読み取り専用) |
| `agents/developer.md` | 同上 | 実装担当 (Sonnet) |
| `agents/reviewer.md` | 同上 | レビュー担当 (Opus、読み取り専用) |
| `agents/explorer.md` | 同上 | 調査担当 (Haiku、読み取り専用) |
| `agents/worker.md` | 同上 | 定型作業担当 (Haiku) |
| `install.sh` / `install.ps1` | - | CLI 本体のインストール + PATH 設定 + 上記を `~/.claude` にコピー (Linux・macOS・Raspberry Pi / Windows) |

## インストール
```bash
./install.sh                  # Linux / macOS / Raspberry Pi
./install.sh --config-only    # 設定の配置だけ (CLI のインストールを省略)
```
```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1                # Windows
powershell -ExecutionPolicy Bypass -File .\install.ps1 -ConfigOnly    # 設定の配置だけ
```
- CLI は未導入のときだけインストールします（導入済みなら更新は `claude update`）。64bit OS が必要で、32bit の Raspberry Pi OS では CLI をスキップし設定だけ配置します。
- `~/.local/bin` が PATH に無ければ、`~/.bashrc`（Linux では常に、macOS ではファイルがある場合のみ）と、`~/.zshrc`（zsh が入っているか、ファイルがある場合）に追記します。
- 内容が同じなら何もしません。違う場合は上書きします（バックアップは作りません）。
- インストール後は Claude Code を再起動してください。`/agents` で一覧を確認できます。
- `settings.json`（テーマなどの個人設定）は管理しません。上書きもしません。
- `CLAUDE_CONFIG_DIR` を設定している場合は、そのディレクトリに配置します。

## エージェントとモデルの使い分け
作業の性質に応じてモデルを分け、品質とコスト・速度のバランスを取ります。

| エージェント | モデル | effort | 役割 | 権限 |
|---|---|---|---|---|
| メイン | Sonnet | medium | 調整役（下記の個人設定で指定） | - |
| `planner` | Opus | high | 設計・方針決定・実装計画 | 読み取りのみ |
| `developer` | Sonnet | medium | 実装・バグ修正・テスト作成 | 読み書き |
| `reviewer` | Opus | high | 変更後のレビュー（バグ・セキュリティ・設計） | 読み取りのみ |
| `explorer` | Haiku | medium | コードの調査（どこに何があるか・処理の流れ・慣習の把握） | 読み取りのみ |
| `worker` | Haiku | low | 機械的な置換・ログ整形・テスト実行と要約 | 読み書き（限定的な指示のみ） |

標準の流れ: `planner`（大きい作業のときだけ）→ `developer` → `reviewer`

```
あなた → メイン (Sonnet) ─┬→ planner  (Opus)    計画を作る
                           ├→ developer (Sonnet) 実装する
                           ├→ reviewer (Opus)    レビューする
                           ├→ explorer (Haiku)   コードの調査 (複数を並列で)
                           └→ worker   (Haiku)   定型作業 (複数を並列で)
```

- **メインのセッションが調整役**です。サブエージェントは別のサブエージェントを起動できません。
- 使い方の例:
  - 「`reviewer` で今の変更をレビューして」
  - 「`explorer` を並列に使って、各ディレクトリの README の有無を調べて」
  - 「まず `planner` で計画を立ててから、`developer` で実装して」
- 説明文 (`description`) に基づいて、Claude が自動で委譲することもあります。
- モデル指定は `opus` / `sonnet` / `haiku` の別名です。新しい世代が出たら自動で最新を使います。固定したい場合は `agents/*.md` の `model:` にモデル ID を書いてください。
- `effort`（`low` / `medium` / `high` / `xhigh` / `max`）は考える量の指定で、`agents/*.md` の `effort:` がそのエージェントの動作中だけセッションの値を上書きします。判断の重い `planner` / `reviewer` は `high`、方針が決まった実装の `developer` は `medium`、調査の `explorer` は `medium`（どこを探すかの判断が要るため）、機械的な `worker` は `low` にしています。`effort:` を省略すると、メインと別モデルのエージェントにはセッションの値が引き継がれず、そのモデルの `modelSettings` の値か既定値で動きます。

## 推奨する個人設定（`~/.claude/settings.json`、手動）
このリポジトリでは管理しませんが、以下を使っています。

```json
{
  "model": "sonnet",
  "advisorModel": "opus",
  "modelSettings": {
    "claude-sonnet-5-5": {
      "effortLevel": "medium"
    }
  }
}
```
- メインは Sonnet（速度とコストのバランス）、難しい判断は Opus のアドバイザーに相談する構成です。
- メインの effort はモデルごとに `modelSettings.<モデルID>.effortLevel` で指定します（`/effort` で選ぶと自動で保存されます）。新しいモデルに切り替えたときは、そのモデルIDで指定し直してください。

## ベストプラクティス（`CLAUDE.md` に反映済み）
- **調べてから書く**: 変更前に関連コードを読む。推測で書かない。
- **範囲を守る**: 頼まれたことだけを変更する。
- **動作確認**: 完了前にテスト・実行で確認し、できなかったことは正直に報告する。
- **安全**: commit / push / 削除は依頼されたときだけ。秘密情報に触れない。破壊的操作は事前に確認。
- **文脈を節約**: 話題が変わったら `/clear`、長くなったら `/compact`。調査や大量出力の作業は `explorer` / `worker` に任せて要約だけ受け取る。
- **計画してから実装**: 大きな作業は Plan モードまたは `planner` で計画を作る。
- **CLAUDE.md は短く**: プロジェクト固有のルールは、各リポジトリの `CLAUDE.md` に書く。

## 編集方法
このリポジトリ側のファイルを編集し、`install.sh`（または `install_all`）を再実行して反映します。
エージェントを追加するときは `agents/<名前>.md` を作ってください（`name` / `description` / `tools` / `model` / `effort` を frontmatter に書きます）。
リポジトリから削除したエージェントは、`~/.claude/agents/` に残るので手動で削除してください。
