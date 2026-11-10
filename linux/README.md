# Linux (Ubuntu) セットアップ

## 手順
```bash
git clone git@github.com:take1014/configuration.git
cd configuration/linux
./install_all.sh              # 必須セットアップ
./install_all.sh --nvidia     # + NVIDIA Container Toolkit
```

`install_all.sh` で入るもの:

| 項目 | 内容 |
|---|---|
| Docker | Docker CE / QEMU（`--nvidia` で NVIDIA Container Toolkit も） |
| VS Code | 本体、`settings.json`、拡張機能（`anthropic.claude-code` を含む） |
| Claude Code | CLI（`~/.local/bin` を `~/.bashrc` の PATH に追加）と、`CLAUDE.md` / サブエージェントの `~/.claude` への配置（[claude/README.md](../claude/README.md)） |
| vim | ソースからビルド（Python3 対応）、vim-plug、プラグイン、jellybeans |
| dotfiles | `~/.bashrc` に `linux/.bashrc` を**追記**、zsh があれば `~/.zshrc` に `linux/.zshrc` を**追記**、`~/.tmux.conf` に `linux/.tmux.conf` を**コピー**（tmux / xsel も導入） |

- スクリプト全体を `sudo` で実行する必要はありません（内部で必要な箇所だけ `sudo` を使います）。
- 途中で失敗しても残りは続行し、最後に失敗した項目を表示します。
- 完了後は **再ログイン**（docker グループ反映）し、`claude` で起動確認します。
- Conda 環境が有効なら、事前に `conda deactivate` してください（vim ビルド用）。
- 再実行しても安全です。

### dotfiles の扱い
| ファイル | 方法 | 再実行時 |
|---|---|---|
| `.bashrc` / `.zshrc` | `# >>> configuration: ... >>>` 〜 `# <<< ... <<<` で囲んだブロックとして**追記** | ブロックだけを最新内容に置き換え（重複しない。ブロック外の自分の記述は保持） |
| `.tmux.conf` / `.vimrc` | **コピー** | 同じ内容なら何もしない。違う場合は `~/.tmux.conf.bak.<日時>` にバックアップしてから上書き |

設定を変えたいときは、リポジトリ側のファイルを編集して `install_all.sh` を再実行してください。
`.tmux.conf` / `.vimrc` は mac・raspi と共用です（`linux/` に置いています）。

## 任意のスクリプト
必要に応じて個別に実行します。

```bash
./pyenv_setup_for_linux.sh   # pyenv / pyenv-virtualenv / Poetry
./install_tlp.sh             # TLP 電源管理 (ThinkPad X13 Gen 5 向け)
./install_discord.sh         # Discord
```

---

### install_discord.sh
Discord（チャットアプリケーション）をインストールします。

- オフィシャルのDeb形式からダウンロード・インストール

**実行方法:**
```bash
chmod +x install_discord.sh
./install_discord.sh
```

---

### install_tlp.sh
TLP（電源管理ツール）をインストール・設定します。ThinkPad X13 Gen 5向けの最適化設定が含まれています。

- TLPのインストール
- 電力管理プロファイル設定
- バッテリー最適化
- 競合する`power-profiles-daemon`の無効化

**実行方法:**
```bash
chmod +x install_tlp.sh
./install_tlp.sh  # スクリプト内で必要なコマンドは個別にsudoを使います
```

実行ユーザーが `sudo` 権限を持っていることを確認してください。

**サービス管理コマンド:**
```bash
# 有効化
sudo systemctl enable tlp
# 無効化
sudo systemctl disable tlp
# 開始
sudo systemctl start tlp
# 停止
sudo systemctl stop tlp
# 状態確認
systemctl status tlp
```

---

### pyenv_setup_for_linux.sh
Python開発環境をセットアップします。

- **pyenv**: Python バージョン管理ツール
- **pyenv-virtualenv**: 仮想環境プラグイン
- **Poetry**: Python パッケージ管理ツール
- 開発に必要なライブラリの自動インストール

**.bashrc自動編集** により、bashシェルで以下が有効化されます：
```bash
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
```

**実行方法:**
```bash
chmod +x pyenv_setup_for_linux.sh
./pyenv_setup_for_linux.sh
source ~/.bashrc  # 設定を反映
```

---

## トラブルシューティング

### 権限エラーが出る場合
```bash
sudo chmod +x script_name.sh
```

### スクリプト実行中に停止した場合
- インターネット接続を確認
- ディスク容量を確認（特にDocker・Vimビルド）
- エラーメッセージをログに記録して再実行

---

## ライセンス・参考リンク

各ツールのライセンスは公式ドキュメントを参照してください：

- [Docker](https://www.docker.com/)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Discord](https://discord.com/)
- [TLP](https://linrunner.de/tlp/)
- [pyenv](https://github.com/pyenv/pyenv)
- [Vim](https://www.vim.org/)
