#!/bin/bash
# setup_mac.sh
DEST="$HOME/Documents/SourcetreeTools"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="$SCRIPT_DIR/get_commit_files_mac.sh"

# コピー先ディレクトリ作成
mkdir -p "$DEST"

# スクリプトが見つからない場合
if [ ! -f "$SRC" ]; then
    osascript -e 'display dialog "get_commit_files_mac.sh が見つかりません。\nsetup_mac.sh と同じフォルダに置いてください。" with title "エラー" buttons {"閉じる"}'
    exit 1
fi

# コピーして実行権限を付与
cp "$SRC" "$DEST/get_commit_files_mac.sh"
chmod +x "$DEST/get_commit_files_mac.sh"

PARAM="$DEST/get_commit_files_mac.sh \$REPO \$SHA"

osascript <<APPLESCRIPT
set paramText to "$PARAM"
tell application "System Events"
    activate
    display dialog "インストールが完了しました。

【Sourcetreeへの登録手順】

1. Sourcetree を開く
2. 環境設定 → カスタムアクション → 追加
3. 以下の通り入力して OK

  メニューキャプション : コミットのファイル一覧
  スクリプトを開く     : /bin/bash
  パラメーター         : " & paramText & "

4. コミット履歴でコミットを右クリック
   → カスタムアクション → コミットのファイル一覧" \
    with title "セットアップ完了" buttons {"閉じる"} default button "閉じる"
end tell
APPLESCRIPT