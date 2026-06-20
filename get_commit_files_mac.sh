#!/bin/bash
# get_commit_files_mac.sh
# version: 1.0.0
REPO_PATH="$1"
COMMIT_HASH="$2"

if [ -z "$COMMIT_HASH" ] || [ "$COMMIT_HASH" = '$SHA' ] || [ "$COMMIT_HASH" = '$REFS' ]; then
    exit 0
fi

cd "$REPO_PATH" || exit 1
export LANG=ja_JP.UTF-8

ADDED=""; MODIFIED=""; DELETED=""; RENAMED=""; ALL_FILES=""
SUMMARY=""
VALID_COUNT=0
HASH_COUNT=0

# 複数コミット選択対応（$SHAはスペース区切りで複数渡る）
for HASH in $COMMIT_HASH; do
    HASH_COUNT=$((HASH_COUNT + 1))
    COMMIT_INFO=$(git -c i18n.logOutputEncoding=utf-8 log -1 --format="%h  %ai  %an%n%s" "$HASH" 2>&1)
    if [ $? -ne 0 ]; then
        continue
    fi
    VALID_COUNT=$((VALID_COUNT + 1))
    SUMMARY="${SUMMARY}コミット : ${HASH}\n${COMMIT_INFO}\n\n"

    # ファイル一覧取得（日本語ファイル名対応）
    FILE_LIST=$(git -c core.quotepath=false diff-tree --no-commit-id -r --name-status "$HASH" 2>&1)

    # マージコミット対応：差分が空の場合は第1親との差分にフォールバック
    if ! echo "$FILE_LIST" | grep -q "^[AMDRC]"; then
        FILE_LIST=$(git -c core.quotepath=false diff "${HASH}^1" "$HASH" --name-status 2>&1)
    fi

    while IFS=$'\t' read -r status file; do
        [ -z "$file" ] && continue
        case "${status:0:1}" in
            A) ADDED="${ADDED}  [追加] ${file}\n" ;;
            M) MODIFIED="${MODIFIED}  [変更] ${file}\n" ;;
            D) DELETED="${DELETED}  [削除] ${file}\n" ;;
            R) RENAMED="${RENAMED}  [移動] ${file}\n" ;;
        esac
        ALL_FILES="${ALL_FILES}${file}\n"
    done <<< "$FILE_LIST"
done

if [ "$VALID_COUNT" -eq 0 ]; then
    osascript -e "display dialog \"コミットが見つかりません：$COMMIT_HASH\" with title \"エラー\" buttons {\"閉じる\"}"
    exit 1
fi

# クリップボード・件数用に重複ファイルを除去
ALL_FILES_DEDUP=$(printf "%b" "$ALL_FILES" | awk 'NF && !seen[$0]++')
COUNT=0
[ -n "$ALL_FILES_DEDUP" ] && COUNT=$(echo "$ALL_FILES_DEDUP" | grep -c ".")

MSG="※ファイル名をクリップボードにコピーしました\n"
MSG="${MSG}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
[ "$HASH_COUNT" -gt 1 ] && MSG="${MSG}選択コミット数: ${HASH_COUNT}（有効: ${VALID_COUNT}）\n\n"
MSG="${MSG}$(printf "%b" "$SUMMARY")"
MSG="${MSG}変更ファイル数: ${COUNT}\n"
[ -n "$ADDED" ]    && MSG="${MSG}\n=== 追加 ===\n${ADDED}"
[ -n "$MODIFIED" ] && MSG="${MSG}\n=== 変更 ===\n${MODIFIED}"
[ -n "$DELETED" ]  && MSG="${MSG}\n=== 削除 ===\n${DELETED}"
[ -n "$RENAMED" ]  && MSG="${MSG}\n=== リネーム ===\n${RENAMED}"

printf "%s\n" "$ALL_FILES_DEDUP" | pbcopy

FIRST_HASH=$(echo "$COMMIT_HASH" | awk '{print $1}')
TMPFILE="/tmp/commit_files_${FIRST_HASH:0:7}.txt"
printf "%b" "$MSG" > "$TMPFILE"
open -e "$TMPFILE"