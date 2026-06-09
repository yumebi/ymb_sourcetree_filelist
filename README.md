# ymb_sourcetree_filelist

Sourcetreeのカスタムアクションとして登録する、コミット変更ファイル一覧表示ツールです。  
コミット履歴で任意のコミットを右クリックするだけで、変更されたファイルの一覧をダイアログ表示します。  
表示と同時にファイル名をクリップボードにコピーします。

---

## 表示内容

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

## ファイル構成

| ファイル | OS | 用途 |
|----------|----|------|
| `get_commit_files.ps1` | Windows | 本体スクリプト |
| `setup.ps1` | Windows | セットアップ本体 |
| `setup.bat` | Windows | セットアップ起動用バッチ |
| `get_commit_files_mac.sh` | Mac | 本体スクリプト |
| `setup_mac.sh` | Mac | セットアップスクリプト |

---

## セットアップ

### Windows

1. `setup.bat` と `get_commit_files.ps1` を同じフォルダに置く
2. `setup.bat` をダブルクリック
3. 表示されたダイアログの手順に従いSourcetreeにカスタムアクションを登録する

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

3. `setup_mac.sh` を実行する

```bash
./setup_mac.sh
```

4. 表示されたダイアログの手順に従いSourcetreeにカスタムアクションを登録する

**Sourcetreeへの登録内容**

| 項目 | 値 |
|------|----|
| メニューキャプション | `コミットのファイル一覧` |
| スクリプトを開く | `/bin/bash` |
| パラメーター | `~/Documents/SourcetreeTools/get_commit_files_mac.sh $REPO $SHA` |

---

## 使い方

1. Sourcetreeのコミット履歴で確認したいコミットを**右クリック**
2. `カスタムアクション` → `コミットのファイル一覧` を選択
3. 変更ファイル一覧がダイアログに表示される
4. ファイル名はクリップボードに自動コピーされる

> コミットを選択せずに実行した場合は何も表示せず終了します。

---

## 動作確認環境

| OS | バージョン |
|----|-----------|
| Windows | Windows 11 / PowerShell 5.x |
| Mac | macOS Sequoia / zsh・bash |

---

## ライセンス

MIT License © 2026 ymb
