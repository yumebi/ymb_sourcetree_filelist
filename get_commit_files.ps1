# get_commit_files.ps1
param(
    [string]$RepoPath = ".",
    [string]$CommitHash = ""
)

Set-Location $RepoPath

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$env:GIT_TERMINAL_PROMPT = "0"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$invalid = ($CommitHash -eq "") -or ($CommitHash -eq '$REFS') -or ($CommitHash -eq '$SHA')
if ($invalid) { exit }

$commitInfo = git -c i18n.logOutputEncoding=utf-8 log -1 --format="%h  %ai  %an%n%s" $CommitHash 2>&1
if ($LASTEXITCODE -ne 0) {
    [System.Windows.Forms.MessageBox]::Show(
        "コミットが見つかりません：`n$CommitHash",
        "エラー", "OK", "Error"
    )
    exit
}

$fileList = git diff-tree --no-commit-id -r --name-status $CommitHash 2>&1

$added = @(); $modified = @(); $deleted = @(); $renamed = @(); $other = @()

foreach ($line in $fileList) {
    if ($line -match "^([AMDRC])\d*\t(.+)$") {
        $status = $Matches[1]; $file = $Matches[2]
        switch ($status) {
            "A" { $added    += $file }
            "M" { $modified += $file }
            "D" { $deleted  += $file }
            "R" { $renamed  += $file }
            default { $other += $file }
        }
    } elseif ($line -match "\S") {
        $other += $line
    }
}

$allFiles = @($added) + @($modified) + @($deleted) + @($renamed) + @($other)
$count = $allFiles.Count

$lines = @()
$lines += "コミット : $CommitHash"
$lines += $commitInfo
$lines += ""
$lines += "変更ファイル数: $count"
$lines += ""
if ($added)    { $lines += "=== 追加 ($($added.Count)) ===";      $lines += $added    | % { "  [追加] $_" }; $lines += "" }
if ($modified) { $lines += "=== 変更 ($($modified.Count)) ===";   $lines += $modified | % { "  [変更] $_" }; $lines += "" }
if ($deleted)  { $lines += "=== 削除 ($($deleted.Count)) ===";    $lines += $deleted  | % { "  [削除] $_" }; $lines += "" }
if ($renamed)  { $lines += "=== リネーム ($($renamed.Count)) ==="; $lines += $renamed  | % { "  [移動] $_" }; $lines += "" }
if ($other)    { $lines += "=== その他 ===";                       $lines += $other    | % { "  [　　] $_" }; $lines += "" }

$message = $lines -join "`r`n"
$plainList = ($allFiles | Where-Object { $_ }) -join "`r`n"
Set-Clipboard -Value $plainList

$form = New-Object System.Windows.Forms.Form
$form.Text = "コミット変更ファイル一覧 — $CommitHash"
$form.Size = New-Object System.Drawing.Size(700, 560)
$form.StartPosition = "CenterScreen"
$form.TopMost = $true

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Multiline = $true
$textBox.ScrollBars = "Vertical"
$textBox.ReadOnly = $true
$textBox.Dock = "Fill"
$textBox.Font = New-Object System.Drawing.Font("Consolas", 10)
$textBox.Text = $message

$panel = New-Object System.Windows.Forms.FlowLayoutPanel
$panel.Dock = "Bottom"
$panel.Height = 40
$panel.FlowDirection = "RightToLeft"

$btnClose = New-Object System.Windows.Forms.Button
$btnClose.Text = "閉じる"
$btnClose.Width = 80
$btnClose.Add_Click({ $form.Close() })

$lbl = New-Object System.Windows.Forms.Label
$lbl.Text = "※ファイル名をクリップボードにコピーしました"
$lbl.AutoSize = $true
$lbl.TextAlign = "MiddleLeft"
$lbl.Padding = New-Object System.Windows.Forms.Padding(5, 0, 0, 0)

$panel.Controls.Add($btnClose)
$panel.Controls.Add($lbl)
$form.Controls.Add($textBox)
$form.Controls.Add($panel)

[void]$form.ShowDialog()