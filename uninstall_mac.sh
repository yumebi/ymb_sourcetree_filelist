#!/bin/bash
# uninstall_mac.sh
# version: 1.1.0

LANG_CHOICE=$(osascript -e 'button returned of (display dialog "Language / 言語" with title "Uninstall" buttons {"日本語", "English"} default button "日本語")')
APP_LANG="ja"
[ "$LANG_CHOICE" = "English" ] && APP_LANG="en"

MARKER="$HOME/Library/Application Support/SourcetreeFileList/install_path.txt"

if [ "$APP_LANG" = "en" ]; then
    T_NOMARKER="Install info not found.\nPlease delete the folder manually."
    T_TITLE="Uninstall"
    T_DONE="Uninstall complete.\n\nPlease manually remove the Sourcetree custom action.\n(Preferences -> Custom Actions)"
else
    T_NOMARKER="インストール情報が見つかりません。\n手動でフォルダを削除してください。"
    T_TITLE="アンインストール"
    T_DONE="アンインストールが完了しました。\n\nSourcetreeのカスタムアクションは手動で削除してください。\n（環境設定 → カスタムアクション）"
fi

if [ ! -f "$MARKER" ]; then
    osascript -e "display dialog \"$T_NOMARKER\" with title \"$T_TITLE\" buttons {\"OK\"}"
    exit 1
fi

INSTALL_PATH=$(cat "$MARKER")

CONFIRM=$(osascript -e "button returned of (display dialog \"$INSTALL_PATH\" with title \"$T_TITLE\" buttons {\"Cancel\", \"OK\"} default button \"OK\")")
if [ "$CONFIRM" != "OK" ]; then
    exit 0
fi

find "$INSTALL_PATH" -delete
find "$HOME/Library/Application Support/SourcetreeFileList" -delete

osascript -e "display dialog \"$T_DONE\" with title \"$T_TITLE\" buttons {\"OK\"}"
