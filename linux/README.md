# Linux Configuration Scripts

Ubuntu用のセットアップスクリプト集です。Linux環境を構築する際に各種ツール・アプリケーションを自動インストール・設定できます。

## スクリプト一覧

### 1. **docker_install.sh**
Dockerとその関連ツールをインストールします。

- **Docker**: コンテナ仮想化プラットフォーム
- **QEMU**: マルチアーキテクチャサポート（ARM等）
- **NVIDIA Docker**: GPU対応Dockerコンテナ実行環境

**実行方法:**
```bash
chmod +x docker_install.sh
./docker_install.sh
```

---

### 2. **install_code_for_linux.sh**
Visual Studio Code（VS Code）をインストールし、設定を適用します。

- VS Codeエディタのインストール
- 設定ファイル（settings.json）の配置
- 拡張機能のインストール

**実行方法:**
```bash
chmod +x install_code_for_linux.sh
./install_code_for_linux.sh
```

**前提条件:** `vscode/`ディレクトリに`settings.json`と`install.sh`が必要です

---

### 3. **install_discord.sh**
Discord（チャットアプリケーション）をインストールします。

- オフィシャルのDeb形式からダウンロード・インストール

**実行方法:**
```bash
chmod +x install_discord.sh
./install_discord.sh
```

---

### 4. **install_tlp.sh**
TLP（電源管理ツール）をインストール・設定します。ThinkPad X13 Gen 5向けの最適化設定が含まれています。

- TLPのインストール
- 電力管理プロファイル設定
- バッテリー最適化
- 競合する`power-profiles-daemon`の無効化

**実行方法:**
```bash
sudo chmod +x install_tlp.sh
sudo ./install_tlp.sh
```

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

### 5. **pyenv_setup_for_linux.sh**
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

### 6. **vim_settings_for_linux.sh**
Vimエディタを最新版からビルド・インストールし、プラグイン環境を整えます。

- Vimソースコードからのビルド
- Python3対応（IDE機能・スクリプト実行に必要）
- vim-plug（プラグインマネージャー）のインストール
- プリインストールプラグイン（jellybeans カラースキーム等）の配置

**実行方法:**
```bash
chmod +x vim_settings_for_linux.sh
./vim_settings_for_linux.sh
```

**重要な注意:** Conda環境がアクティブになっている場合は、事前に無効化してください
```bash
conda deactivate
```

---

## 実行順序（推奨）

新しいUbuntu環境でセットアップする場合は、以下の順序での実行を推奨します：

1. `pyenv_setup_for_linux.sh` - Python開発環境
2. `vim_settings_for_linux.sh` - Vimエディタ
3. `install_code_for_linux.sh` - VS Code
4. `docker_install.sh` - Docker（rootアクセス必要）
5. `install_tlp.sh` - 電源管理（ThinkPad利用時）
6. `install_discord.sh` - Discord

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
