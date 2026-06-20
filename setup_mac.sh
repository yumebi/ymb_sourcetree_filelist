#!/bin/bash
# setup_mac.sh
# version: 1.1.0
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="$SCRIPT_DIR/get_commit_files_mac.sh"

LANG_CHOICE=$(osascript -e 'button returned of (display dialog "Language / 言語" with title "Setup" buttons {"日本語", "English"} default button "日本語")')
APP_LANG="ja"
[ "$LANG_CHOICE" = "English" ] && APP_LANG="en"

if [ "$APP_LANG" = "en" ]; then
    MSG_NOTFOUND="get_commit_files_mac.sh not found.\nPlace it in the same folder as setup_mac.sh."
    MSG_ERROR="Error"
    MSG_FOLDER_PROMPT="Choose install folder (Cancel uses default)"
else
    MSG_NOTFOUND="get_commit_files_mac.sh が見つかりません。\nsetup_mac.sh と同じフォルダに置いてください。"
    MSG_ERROR="エラー"
    MSG_FOLDER_PROMPT="インストール先フォルダを選択（キャンセルで既定値を使用）"
fi

if [ ! -f "$SRC" ]; then
    osascript -e "display dialog \"$MSG_NOTFOUND\" with title \"$MSG_ERROR\" buttons {\"OK\"}"
    exit 1
fi

CHOSEN=$(osascript -e "try
    POSIX path of (choose folder with prompt \"$MSG_FOLDER_PROMPT\")
on error
    \"\"
end try")

if [ -n "$CHOSEN" ]; then
    DEST="${CHOSEN%/}/SourcetreeTools"
else
    DEST="$HOME/Documents/SourcetreeTools"
fi

mkdir -p "$DEST"
cp "$SRC" "$DEST/get_commit_files_mac.sh"
chmod +x "$DEST/get_commit_files_mac.sh"
echo "$APP_LANG" > "$DEST/lang.txt"

MARKER_DIR="$HOME/Library/Application Support/SourcetreeFileList"
mkdir -p "$MARKER_DIR"
echo "$DEST" > "$MARKER_DIR/install_path.txt"

INSTALL_PATH="$DEST/get_commit_files_mac.sh"

if [ "$APP_LANG" = "en" ]; then
osascript <<EOF
set installPath to "$INSTALL_PATH"
set paramText to installPath & " \$REPO \$SHA"
set msg to "Installation complete." & return & return
set msg to msg & "Sourcetree Setup Steps:" & return & return
set msg to msg & "1. Open Sourcetree" & return
set msg to msg & "2. Preferences -> Custom Actions -> Add" & return
set msg to msg & "3. Enter the following and click OK" & return & return
set msg to msg & "  Menu Caption : Commit File List" & return
set msg to msg & "  Script to run : /bin/bash" & return
set msg to msg & "  Parameters    : " & paramText & return & return
set msg to msg & "4. Right-click a commit in history" & return
set msg to msg & "   -> Custom Actions -> Commit File List"
tell application "System Events"
    activate
    display dialog msg with title "Setup Complete" buttons {"Close"} default button "Close"
end tell
EOF
else
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
fi