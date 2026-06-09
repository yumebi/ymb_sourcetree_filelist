#!/bin/bash
# get_commit_files_mac.sh
REPO_PATH="$1"
COMMIT_HASH="$2"

# ハッシュ未取得の場合は静かに終了
if [ -z "$COMMIT_HASH" ] || [ "$COMMIT_HASH" = '$SHA' ] || [ "$COMMIT_HASH" = '$REFS' ]; then
    exit 0
fi

cd "$REPO_PATH" || exit 1
export LANG=ja_JP.UTF-8

# コミット情報取得
COMMIT_INFO=$(git -c i18n.logOutputEncoding=utf-8 log -1 --format="%h  %ai  %an%n%s" "$COMMIT_HASH" 2>&1)
if [ $? -ne 0 ]; then
    osascript -e "display dialog \"コミットが見つかりません：$COMMIT_HASH\" with title \"エラー\" buttons {\"閉じる\"}"
    exit 1
fi

# ファイル一覧取得・分類
ADDED=""; MODIFIED=""; DELETED=""; RENAMED=""
ALL_FILES=""

while IFS=$'\t' read -r status file; do
    [ -z "$file" ] && continue
    case "${status:0:1}" in
        A) ADDED="$ADDED  [追加] $file\n" ;;
        M) MODIFIED="$MODIFIED  [変更] $file\n" ;;
        D) DELETED="$DELETED  [削除] $file\n" ;;
        R) RENAMED="$RENAMED  [移動] $file\n" ;;
    esac
    ALL_FILES="$ALL_FILES$file\n"
done < <(git diff-tree --no-commit-id -r --name-status "$COMMIT_HASH" 2>&1)

COUNT=$(printf "$ALL_FILES" | grep -c ".")

# 表示テキスト組み立て
MSG="コミット : $COMMIT_HASH\n$COMMIT_INFO\n\n変更ファイル数: $COUNT\n"
[ -n "$ADDED" ]    && MSG="${MSG}\n=== 追加 ===\n${ADDED}"
[ -n "$MODIFIED" ] && MSG="${MSG}\n=== 変更 ===\n${MODIFIED}"
[ -n "$DELETED" ]  && MSG="${MSG}\n=== 削除 ===\n${DELETED}"
[ -n "$RENAMED" ]  && MSG="${MSG}\n=== リネーム ===\n${RENAMED}"

# クリップボードにコピー
printf "$ALL_FILES" | pbcopy

# ダイアログ表示
DISPLAY_TEXT=$(printf "$MSG")
osascript <<APPLESCRIPT
set theText to "$DISPLAY_TEXT"
tell application "System Events"
    activate
    display dialog theText with title "コミット変更ファイル一覧" buttons {"閉じる"} default button "閉じる"
end tell
APPLESCRIPT