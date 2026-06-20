# get_commit_files.ps1
# version: 1.0.0
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

# ハッシュ未取得の場合は静かに終了
$invalid = ($CommitHash -eq "") -or ($CommitHash -eq '$REFS') -or ($CommitHash -eq '$SHA')
if ($invalid) { exit }

# 複数コミット選択対応（$SHAはスペース区切りで複数渡る）
$hashes = $CommitHash -split '\s+' | Where-Object { $_ }

$commitSummaries = @()
$added = @(); $modified = @(); $deleted = @(); $renamed = @(); $other = @()
$validCount = 0

foreach ($hash in $hashes) {
    $commitInfo = git -c i18n.logOutputEncoding=utf-8 log -1 --format="%h  %ai  %an%n%s" $hash 2>&1
    if ($LASTEXITCODE -ne 0) { continue }
    $validCount++
    $commitSummaries += "コミット : $hash"
    $commitSummaries += $commitInfo
    $commitSummaries += ""

    # ファイル一覧取得（日本語ファイル名対応）
    $fileList = git -c core.quotepath=false diff-tree --no-commit-id -r --name-status $hash 2>&1

    # マージコミット対応：差分が空の場合は第1親との差分にフォールバック
    if (-not ($fileList | Where-Object { $_ -match "^[AMDRC]" })) {
        $fileList = git -c core.quotepath=false diff "${hash}^1" $hash --name-status 2>&1
    }

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
}

if ($validCount -eq 0) {
    [System.Windows.Forms.MessageBox]::Show(
        "コミットが見つかりません：`n$CommitHash",
        "エラー", "OK", "Error"
    )
    exit
}

# コミットをまたいで重複するファイルは1つにまとめる
$added    = $added    | Select-Object -Unique
$modified = $modified | Select-Object -Unique
$deleted  = $deleted  | Select-Object -Unique
$renamed  = $renamed  | Select-Object -Unique
$other    = $other    | Select-Object -Unique

$allFiles = @($added) + @($modified) + @($deleted) + @($renamed) + @($other) | Select-Object -Unique
$count = $allFiles.Count

$lines = @()
if ($hashes.Count -gt 1) { $lines += "選択コミット数: $($hashes.Count)（有効: $validCount）"; $lines += "" }
$lines += $commitSummaries
$lines += "変更ファイル数: $count"
$lines += ""
if ($added)    { $lines += "=== 追加 ($($added.Count)) ===";       $lines += $added    | % { "  [追加] $_" }; $lines += "" }
if ($modified) { $lines += "=== 変更 ($($modified.Count)) ===";    $lines += $modified | % { "  [変更] $_" }; $lines += "" }
if ($deleted)  { $lines += "=== 削除 ($($deleted.Count)) ===";     $lines += $deleted  | % { "  [削除] $_" }; $lines += "" }
if ($renamed)  { $lines += "=== リネーム ($($renamed.Count)) ==="; $lines += $renamed  | % { "  [移動] $_" }; $lines += "" }
if ($other)    { $lines += "=== その他 ===";                        $lines += $other    | % { "  [　　] $_" }; $lines += "" }

$message = $lines -join "`r`n"
$plainList = ($allFiles | Where-Object { $_ }) -join "`r`n"
Set-Clipboard -Value $plainList

$titleHash = if ($hashes.Count -gt 1) { "$($hashes.Count)件のコミット" } else { $hashes[0] }

$form = New-Object System.Windows.Forms.Form
$form.Text = "コミット変更ファイル一覧 — $titleHash"
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