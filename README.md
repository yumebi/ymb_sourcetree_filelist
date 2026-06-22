# ymb_sourcetree_filelist

Sourcetreeのカスタムアクションとして登録する、コミット変更ファイル一覧表示ツールです。
コミット履歴で任意のコミットを右クリックするだけで、変更されたファイルの一覧をダイアログ表示します。
表示と同時にファイル名をクリップボードにコピーします。

UIは日本語 / English の切り替えに対応しています（セットアップ時に選択）。変更履歴は [CHANGELOG](CHANGELOG.md) を参照。

---

## 主な機能

```
コミット : a3f9c12
a3f9c12  2026-06-09 10:22:11  山田
ログイン処理を修正

変更ファイル数: 4

=== 追加 (1) ===
  [追加] src/auth/validator.js

=== 変更 (2) ===
  [変更] src/auth/login.js
  [変更] tests/auth.test.js

=== 削除 (1) ===
  [削除] src/auth/old_validator.js
```

---

## 使い方

1. Sourcetreeのコミット履歴で確認したいコミットを**右クリック**（複数選択も可）
2. `カスタムアクション` → `コミットのファイル一覧` を選択
3. 変更ファイル一覧がダイアログに表示される
4. ファイル名はクリップボードに自動コピーされる

> コミットを選択せずに実行した場合は何も表示せず終了します。
> 複数コミットを選択しても、Sourcetreeのカスタムアクションには**右クリックした1コミットのみ**が `$SHA` として渡されます（Sourcetree側の仕様上の制限）。複数コミットの内容をまとめて確認したい場合は、1つずつ右クリックして実行してください。

---

## セットアップ

### Windows

1. `setup.bat` と `get_commit_files.ps1` を同じフォルダに置く
2. `setup.bat` をダブルクリック
3. 言語を選択（日本語 / English）
4. インストール先フォルダを選択（キャンセルで既定値 `ドキュメント\SourcetreeTools`）
5. 表示されたダイアログの手順に従いSourcetreeにカスタムアクションを登録する

**Sourcetreeへの登録内容**

| 項目 | 値 |
|------|----|
| メニューキャプション | `コミットのファイル一覧` |
| スクリプトを開く | `powershell` |
| パラメーター | `-WindowStyle Hidden -ExecutionPolicy Bypass -File "インストール先\get_commit_files.ps1" "$REPO" "$SHA"` |
| バックグラウンドで実行する | チェックあり |

---

### Mac

1. `setup_mac.sh` と `get_commit_files_mac.sh` を同じフォルダに置く
2. ターミナルで実行権限を付与する

```bash
chmod +x setup_mac.sh get_commit_files_mac.sh
```

3. ダウンロードしたファイルの場合はquarantine属性を解除する（Gatekeeperでブロックされるため）

```bash
xattr -d com.apple.quarantine *.sh
```

4. `setup_mac.sh` を実行する

```bash
./setup_mac.sh
```

5. 言語を選択（日本語 / English）→ インストール先フォルダを選択（キャンセルで既定値 `~/Documents/SourcetreeTools`）
6. 表示されたダイアログの手順に従いSourcetreeにカスタムアクションを登録する

**Sourcetreeへの登録内容**

| 項目 | 値 |
|------|----|
| メニューキャプション | `コミットのファイル一覧` |
| スクリプトを開く | `/bin/bash` |
| パラメーター | `インストール先/get_commit_files_mac.sh $REPO $SHA` |

---

## アンインストール

### Windows

`uninstall.bat` をダブルクリック → 確認ダイアログで「はい」を選択

### Mac

```bash
chmod +x uninstall_mac.sh
./uninstall_mac.sh
```

> いずれもインストールしたスクリプトファイルのみ削除します。Sourcetreeのカスタムアクション登録は手動で削除してください（ツール/環境設定 → カスタムアクション）。

---

## 技術スタック

| 用途 | 言語/ツール |
|---|---|
| Windows本体スクリプト | PowerShell 5.x |
| Mac本体スクリプト | Bash (zsh環境でも動作) |
| 配布形式 | スクリプト直接配布(外部依存ライブラリなし) |
| CI/CD | GitHub Actions(mainへのpushで自動更新) |

---

## プロジェクト構成

| ファイル | OS | 用途 |
|----------|----|------|
| `get_commit_files.ps1` | Windows | 本体スクリプト |
| `setup.ps1` | Windows | セットアップ本体 |
| `setup.bat` | Windows | セットアップ起動用バッチ |
| `uninstall.ps1` | Windows | アンインストール本体 |
| `uninstall.bat` | Windows | アンインストール起動用バッチ |
| `get_commit_files_mac.sh` | Mac | 本体スクリプト |
| `setup_mac.sh` | Mac | セットアップスクリプト |
| `uninstall_mac.sh` | Mac | アンインストールスクリプト |

---

## 動作確認環境

| OS | バージョン |
|----|-----------|
| Windows | Windows 11 / PowerShell 5.x |
| Mac | macOS Sequoia / zsh・bash |

---

## ダウンロード

最新版は [Releases](https://github.com/yumebi/ymb_sourcetree_filelist/releases) から取得してください（mainへのpush時にGitHub Actionsで自動更新）。

---

## ライセンス

[MIT License](LICENSE) © 2026 ymb
