# setup.ps1
# version: 1.0.0
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$destDir  = "$env:USERPROFILE\Documents\SourcetreeTools"
$destFile = "$destDir\get_commit_files.ps1"
$srcFile  = Join-Path $PSScriptRoot "get_commit_files.ps1"

if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir | Out-Null }

if (-not (Test-Path $srcFile)) {
    [System.Windows.Forms.MessageBox]::Show(
        "get_commit_files.ps1 が見つかりません。`nsetup.bat と同じフォルダに置いてください。",
        "エラー", "OK", "Error"
    )
    exit 1
}

Copy-Item -Path $srcFile -Destination $destFile -Force

$param = "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$destFile`" `"`$REPO`" `"`$SHA`""

$form = New-Object System.Windows.Forms.Form
$form.Text = "セットアップ完了"
$form.Size = New-Object System.Drawing.Size(620, 420)
$form.StartPosition = "CenterScreen"
$form.TopMost = $true
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

$lbl1 = New-Object System.Windows.Forms.Label
$lbl1.Text = "インストールが完了しました。`n以下の手順でSourcetreeに登録してください。"
$lbl1.Location = New-Object System.Drawing.Point(16, 16)
$lbl1.Size     = New-Object System.Drawing.Size(580, 40)
$lbl1.Font     = New-Object System.Drawing.Font("Meiryo UI", 10)

$lbl2 = New-Object System.Windows.Forms.Label
$lbl2.Text = "1.  Sourcetree を開く`n2.  ツール → オプション → カスタムアクション → 追加`n3.  以下の通り入力して OK"
$lbl2.Location = New-Object System.Drawing.Point(16, 64)
$lbl2.Size     = New-Object System.Drawing.Size(580, 70)
$lbl2.Font     = New-Object System.Drawing.Font("Meiryo UI", 9)

$grid = New-Object System.Windows.Forms.DataGridView
$grid.Location              = New-Object System.Drawing.Point(16, 144)
$grid.Size                  = New-Object System.Drawing.Size(576, 110)
$grid.ColumnCount           = 2
$grid.Columns[0].HeaderText = "項目"
$grid.Columns[0].Width      = 160
$grid.Columns[1].HeaderText = "入力値"
$grid.Columns[1].Width      = 390
$grid.AllowUserToAddRows    = $false
$grid.ReadOnly              = $true
$grid.RowHeadersVisible     = $false
$grid.Font                  = New-Object System.Drawing.Font("Consolas", 9)
$grid.Rows.Add("メニューキャプション", "コミットのファイル一覧") | Out-Null
$grid.Rows.Add("スクリプトを開く",     "powershell")             | Out-Null
$grid.Rows.Add("パラメーター",         $param)                   | Out-Null

$lbl3 = New-Object System.Windows.Forms.Label
$lbl3.Text = "4.  コミット履歴でコミットを右クリック → カスタムアクション → コミットのファイル一覧"
$lbl3.Location = New-Object System.Drawing.Point(16, 262)
$lbl3.Size     = New-Object System.Drawing.Size(580, 40)
$lbl3.Font     = New-Object System.Drawing.Font("Meiryo UI", 9)

$btnCopy = New-Object System.Windows.Forms.Button
$btnCopy.Text     = "パラメーターをコピー"
$btnCopy.Location = New-Object System.Drawing.Point(16, 310)
$btnCopy.Size     = New-Object System.Drawing.Size(160, 30)
$btnCopy.Add_Click({ Set-Clipboard -Value $param; $btnCopy.Text = "コピーしました！" })

$btnClose = New-Object System.Windows.Forms.Button
$btnClose.Text     = "閉じる"
$btnClose.Location = New-Object System.Drawing.Point(510, 310)
$btnClose.Size     = New-Object System.Drawing.Size(80, 30)
$btnClose.Add_Click({ $form.Close() })

$form.Controls.AddRange(@($lbl1, $lbl2, $grid, $lbl3, $btnCopy, $btnClose))
[void]$form.ShowDialog()