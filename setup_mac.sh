#!/bin/bash
# setup_mac.sh
# version: 1.0.0
DEST="$HOME/Documents/SourcetreeTools"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="$SCRIPT_DIR/get_commit_files_mac.sh"

mkdir -p "$DEST"

if [ ! -f "$SRC" ]; then
    osascript -e 'display dialog "get_commit_files_mac.sh が見つかりません。\nsetup_mac.sh と同じフォルダに置いてください。" with title "エラー" buttons {"閉じる"}'
    exit 1
fi

cp "$SRC" "$DEST/get_commit_files_mac.sh"
chmod +x "$DEST/get_commit_files_mac.sh"

INSTALL_PATH="$DEST/get_commit_files_mac.sh"

# return連結方式でAppleScriptの改行を安全に組み立てる（$REPO $SHA はリテラルとして渡す）
osascript <<EOF
set installPath to "$INSTALL_PATH"
set paramText to installPath & " \$REPO \$SHA"
set msg to "インストールが完了しました。" & return & return
set msg to msg & "【Sourcetreeへの登録手順】" & return & return
set msg to msg & "1. Sourcetree を開く" & return
set msg to msg & "2. 環境設定 → カスタムアクション → 追加" & return
set msg to msg & "3. 以下の通り入力して OK" & return & return
set msg to msg & "  メニューキャプション : コミットのファイル一覧" & return
set msg to msg & "  スクリプトを開く     : /bin/bash" & return
set msg to msg & "  パラメーター         : " & paramText & return & return
set msg to msg & "4. コミット履歴でコミットを右クリック" & return
set msg to msg & "   → カスタムアクション → コミットのファイル一覧"
tell application "System Events"
    activate
    display dialog msg with title "セットアップ完了" buttons {"閉じる"} default button "閉じる"
end tell
EOF