# setup.ps1
# version: 1.1.0
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$langResult = [System.Windows.Forms.MessageBox]::Show(
    "Use English UI?`nYes = English / No = 日本語",
    "Language / 言語", "YesNo", "Question"
)
$lang = if ($langResult -eq "Yes") { "en" } else { "ja" }

$T = @{
    ja = @{
        NotFoundSrc = "get_commit_files.ps1 が見つかりません。`nsetup.bat と同じフォルダに置いてください。"
        ErrorTitle = "エラー"; Done = "インストールが完了しました。`n以下の手順でSourcetreeに登録してください。"
        Steps = "1.  Sourcetree を開く`n2.  ツール → オプション → カスタムアクション → 追加`n3.  以下の通り入力して OK"
        Col1 = "項目"; Col2 = "入力値"; Caption = "メニューキャプション"; CaptionVal = "コミットのファイル一覧"
        OpenScript = "スクリプトを開く"; Param = "パラメーター"
        Step4 = "4.  コミット履歴でコミットを右クリック → カスタムアクション → コミットのファイル一覧"
        CopyBtn = "パラメーターをコピー"; Copied = "コピーしました！"; CloseBtn = "閉じる"
        Title = "セットアップ完了"
        FolderPrompt = "インストール先フォルダを選択（キャンセルで既定値を使用）"
    }
    en = @{
        NotFoundSrc = "get_commit_files.ps1 not found.`nPlace it in the same folder as setup.bat."
        ErrorTitle = "Error"; Done = "Installation complete.`nFollow the steps below to register with Sourcetree."
        Steps = "1.  Open Sourcetree`n2.  Tools -> Options -> Custom Actions -> Add`n3.  Enter the following and click OK"
        Col1 = "Item"; Col2 = "Value"; Caption = "Menu Caption"; CaptionVal = "Commit File List"
        OpenScript = "Script to run"; Param = "Parameters"
        Step4 = "4.  Right-click a commit in history -> Custom Actions -> Commit File List"
        CopyBtn = "Copy parameters"; Copied = "Copied!"; CloseBtn = "Close"
        Title = "Setup Complete"
        FolderPrompt = "Choose install folder (Cancel uses default)"
    }
}
$S = $T[$lang]

# インストール先フォルダ選択（キャンセル時は既定値）
$defaultDest = "$env:USERPROFILE\Documents\SourcetreeTools"
$destDir = $defaultDest
$fbd = New-Object System.Windows.Forms.FolderBrowserDialog
$fbd.Description = $S.FolderPrompt
$fbd.SelectedPath = "$env:USERPROFILE\Documents"
if ($fbd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    $destDir = Join-Path $fbd.SelectedPath "SourcetreeTools"
}

$destFile = "$destDir\get_commit_files.ps1"
$srcFile  = Join-Path $PSScriptRoot "get_commit_files.ps1"

if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir | Out-Null }

if (-not (Test-Path $srcFile)) {
    [System.Windows.Forms.MessageBox]::Show($S.NotFoundSrc, $S.ErrorTitle, "OK", "Error")
    exit 1
}

Copy-Item -Path $srcFile -Destination $destFile -Force
Set-Content -Path "$destDir\lang.txt" -Value $lang -Encoding ASCII -NoNewline

# アンインストーラーが見つけられるよう、インストール先を記録
$markerDir = "$env:APPDATA\SourcetreeFileList"
if (-not (Test-Path $markerDir)) { New-Item -ItemType Directory -Path $markerDir | Out-Null }
Set-Content -Path "$markerDir\install_path.txt" -Value $destDir -Encoding UTF8 -NoNewline

$param = "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$destFile`" `"`$REPO`" `"`$SHA`""

$form = New-Object System.Windows.Forms.Form
$form.Text = $S.Title
$form.Size = New-Object System.Drawing.Size(620, 420)
$form.StartPosition = "CenterScreen"
$form.TopMost = $true
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

$lbl1 = New-Object System.Windows.Forms.Label
$lbl1.Text = $S.Done
$lbl1.Location = New-Object System.Drawing.Point(16, 16)
$lbl1.Size     = New-Object System.Drawing.Size(580, 40)
$lbl1.Font     = New-Object System.Drawing.Font("Meiryo UI", 10)

$lbl2 = New-Object System.Windows.Forms.Label
$lbl2.Text = $S.Steps
$lbl2.Location = New-Object System.Drawing.Point(16, 64)
$lbl2.Size     = New-Object System.Drawing.Size(580, 70)
$lbl2.Font     = New-Object System.Drawing.Font("Meiryo UI", 9)

$grid = New-Object System.Windows.Forms.DataGridView
$grid.Location              = New-Object System.Drawing.Point(16, 144)
$grid.Size                  = New-Object System.Drawing.Size(576, 110)
$grid.ColumnCount           = 2
$grid.Columns[0].HeaderText = $S.Col1
$grid.Columns[0].Width      = 160
$grid.Columns[1].HeaderText = $S.Col2
$grid.Columns[1].Width      = 390
$grid.AllowUserToAddRows    = $false
$grid.ReadOnly              = $true
$grid.RowHeadersVisible     = $false
$grid.Font                  = New-Object System.Drawing.Font("Consolas", 9)
$grid.Rows.Add($S.Caption, $S.CaptionVal) | Out-Null
$grid.Rows.Add($S.OpenScript, "powershell") | Out-Null
$grid.Rows.Add($S.Param, $param) | Out-Null

$lbl3 = New-Object System.Windows.Forms.Label
$lbl3.Text = $S.Step4
$lbl3.Location = New-Object System.Drawing.Point(16, 262)
$lbl3.Size     = New-Object System.Drawing.Size(580, 40)
$lbl3.Font     = New-Object System.Drawing.Font("Meiryo UI", 9)

$btnCopy = New-Object System.Windows.Forms.Button
$btnCopy.Text     = $S.CopyBtn
$btnCopy.Location = New-Object System.Drawing.Point(16, 310)
$btnCopy.Size     = New-Object System.Drawing.Size(160, 30)
$btnCopy.Add_Click({ Set-Clipboard -Value $param; $btnCopy.Text = $S.Copied })

$btnClose = New-Object System.Windows.Forms.Button
$btnClose.Text     = $S.CloseBtn
$btnClose.Location = New-Object System.Drawing.Point(510, 310)
$btnClose.Size     = New-Object System.Drawing.Size(80, 30)
$btnClose.Add_Click({ $form.Close() })

$form.Controls.AddRange(@($lbl1, $lbl2, $grid, $lbl3, $btnCopy, $btnClose))
[void]$form.ShowDialog()