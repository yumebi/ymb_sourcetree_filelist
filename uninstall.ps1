# uninstall.ps1
# version: 1.1.0
Add-Type -AssemblyName System.Windows.Forms

$langResult = [System.Windows.Forms.MessageBox]::Show(
    "Use English UI?`nYes = English / No = 日本語",
    "Language / 言語", "YesNo", "Question"
)
$lang = if ($langResult -eq "Yes") { "en" } else { "ja" }

$T = @{
    ja = @{
        NoMarker = "インストール情報が見つかりません。`n手動でフォルダを削除してください。"
        Confirm = "以下を削除します。よろしいですか？`n`n"
        Done = "アンインストールが完了しました。`n`nSourcetreeのカスタムアクションは手動で削除してください。`n（ツール → オプション → カスタムアクション）"
        Title = "アンインストール"
    }
    en = @{
        NoMarker = "Install info not found.`nPlease delete the folder manually."
        Confirm = "The following will be removed. Continue?`n`n"
        Done = "Uninstall complete.`n`nPlease manually remove the Sourcetree custom action.`n(Tools -> Options -> Custom Actions)"
        Title = "Uninstall"
    }
}
$S = $T[$lang]

$markerFile = "$env:APPDATA\SourcetreeFileList\install_path.txt"

if (-not (Test-Path $markerFile)) {
    [System.Windows.Forms.MessageBox]::Show($S.NoMarker, $S.Title, "OK", "Warning")
    exit 1
}

$installPath = (Get-Content $markerFile -Raw).Trim()

$confirm = [System.Windows.Forms.MessageBox]::Show(
    "$($S.Confirm)$installPath",
    $S.Title, "YesNo", "Warning"
)
if ($confirm -ne "Yes") { exit }

if (Test-Path $installPath) {
    Get-ChildItem -Path $installPath -Recurse | Remove-Item -Force -Recurse
    Remove-Item -Path $installPath -Force
}
$markerDir = "$env:APPDATA\SourcetreeFileList"
if (Test-Path $markerDir) {
    Get-ChildItem -Path $markerDir -Recurse | Remove-Item -Force -Recurse
    Remove-Item -Path $markerDir -Force
}

[System.Windows.Forms.MessageBox]::Show($S.Done, $S.Title, "OK", "Information")
