# get_changed_files.ps1
param(
    [string]$RepoPath = "."
)

Set-Location $RepoPath

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$staged    = git diff --cached --name-only 2>&1
$unstaged  = git diff --name-only 2>&1
$untracked = git ls-files --others --exclude-standard 2>&1

$lines = @()
if ($staged)    { $lines += "=== ステージ済み ===";  $lines += $staged    | ForEach-Object { "  [追加] $_" }; $lines += "" }
if ($unstaged)  { $lines += "=== 未ステージ ===";    $lines += $unstaged  | ForEach-Object { "  [変更] $_" }; $lines += "" }
if ($untracked) { $lines += "=== 未追跡 ===";        $lines += $untracked | ForEach-Object { "  [新規] $_" }; $lines += "" }

$total = @($staged) + @($unstaged) + @($untracked) | Where-Object { $_ } | Select-Object -Unique
$count = ($total | Where-Object { $_ }).Count

if ($count -eq 0) {
    $message = "変更されたファイルはありません。"
} else {
    $message = "変更ファイル数: $count`r`n`r`n" + ($lines -join "`r`n")
}

$plainList = ($total | Where-Object { $_ }) -join "`r`n"
Set-Clipboard -Value $plainList

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "変更ファイル一覧 — $RepoPath"
$form.Size = New-Object System.Drawing.Size(640, 520)
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