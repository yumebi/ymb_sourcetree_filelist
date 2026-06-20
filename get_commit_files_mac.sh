#!/bin/bash
# get_commit_files_mac.sh
# version: 1.1.2
VERSION="1.1.2"
REPO_PATH="$1"
COMMIT_HASH="$2"

if [ -z "$COMMIT_HASH" ] || [ "$COMMIT_HASH" = '$SHA' ] || [ "$COMMIT_HASH" = '$REFS' ]; then
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_LANG="ja"
if [ -f "$SCRIPT_DIR/lang.txt" ]; then
    L=$(tr -d '[:space:]' < "$SCRIPT_DIR/lang.txt")
    [ "$L" = "en" ] && APP_LANG="en"
fi

if [ "$APP_LANG" = "en" ]; then
    T_ERROR="Error"; T_NOTFOUND="Commit not found:"
    T_ADDED="Added"; T_MODIFIED="Modified"; T_DELETED="Deleted"; T_RENAMED="Renamed"
    T_COUNT="Changed files"; T_CLIP="* File names copied to clipboard"
    T_COMMIT="Commit"; T_SELECTED="Selected commits"; T_VALID="valid"
else
    T_ERROR="エラー"; T_NOTFOUND="コミットが見つかりません："
    T_ADDED="追加"; T_MODIFIED="変更"; T_DELETED="削除"; T_RENAMED="移動"
    T_COUNT="変更ファイル数"; T_CLIP="※ファイル名をクリップボードにコピーしました"
    T_COMMIT="コミット"; T_SELECTED="選択コミット数"; T_VALID="有効"
fi

cd "$REPO_PATH" || exit 1
export LANG=ja_JP.UTF-8

ADDED=""; MODIFIED=""; DELETED=""; RENAMED=""; ALL_FILES=""
SUMMARY=""
VALID_COUNT=0
HASH_COUNT=0

for HASH in $COMMIT_HASH; do
    HASH_COUNT=$((HASH_COUNT + 1))
    COMMIT_INFO=$(git -c i18n.logOutputEncoding=utf-8 log -1 --format="%h  %ai  %an%n%s" "$HASH" 2>&1)
    if [ $? -ne 0 ]; then
        continue
    fi
    VALID_COUNT=$((VALID_COUNT + 1))
    SUMMARY="${SUMMARY}${T_COMMIT} : ${HASH}\n${COMMIT_INFO}\n\n"

    FILE_LIST=$(git -c core.quotepath=false diff-tree --no-commit-id -r --name-status "$HASH" 2>&1)
    if ! echo "$FILE_LIST" | grep -q "^[AMDRC]"; then
        FILE_LIST=$(git -c core.quotepath=false diff "${HASH}^1" "$HASH" --name-status 2>&1)
    fi

    while IFS=$'\t' read -r status file; do
        [ -z "$file" ] && continue
        case "${status:0:1}" in
            A) ADDED="${ADDED}  [${T_ADDED}] ${file}\n" ;;
            M) MODIFIED="${MODIFIED}  [${T_MODIFIED}] ${file}\n" ;;
            D) DELETED="${DELETED}  [${T_DELETED}] ${file}\n" ;;
            R) RENAMED="${RENAMED}  [${T_RENAMED}] ${file}\n" ;;
        esac
        ALL_FILES="${ALL_FILES}${file}\n"
    done <<< "$FILE_LIST"
done

if [ "$VALID_COUNT" -eq 0 ]; then
    osascript -e "display dialog \"${T_NOTFOUND} $COMMIT_HASH\" with title \"$T_ERROR\" buttons {\"OK\"}"
    exit 1
fi

ALL_FILES_DEDUP=$(printf "%b" "$ALL_FILES" | awk 'NF && !seen[$0]++')
COUNT=0
[ -n "$ALL_FILES_DEDUP" ] && COUNT=$(echo "$ALL_FILES_DEDUP" | grep -c ".")

MSG="ymb_sourcetree_filelist v${VERSION}\n"
MSG="${MSG}${T_CLIP}\n"
MSG="${MSG}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
[ "$HASH_COUNT" -gt 1 ] && MSG="${MSG}${T_SELECTED}: ${HASH_COUNT} (${T_VALID}: ${VALID_COUNT})\n\n"
MSG="${MSG}$(printf "%b" "$SUMMARY")"
MSG="${MSG}${T_COUNT}: ${COUNT}\n"
[ -n "$ADDED" ]    && MSG="${MSG}\n=== ${T_ADDED} ===\n${ADDED}"
[ -n "$MODIFIED" ] && MSG="${MSG}\n=== ${T_MODIFIED} ===\n${MODIFIED}"
[ -n "$DELETED" ]  && MSG="${MSG}\n=== ${T_DELETED} ===\n${DELETED}"
[ -n "$RENAMED" ]  && MSG="${MSG}\n=== ${T_RENAMED} ===\n${RENAMED}"

printf "%s\n" "$ALL_FILES_DEDUP" | pbcopy

FIRST_HASH=$(echo "$COMMIT_HASH" | awk '{print $1}')
TMPFILE="/tmp/commit_files_${FIRST_HASH:0:7}.txt"
printf "%b" "$MSG" > "$TMPFILE"
open -e "$TMPFILE"