# get_commit_files.ps1
# version: 1.1.2
param(
    [string]$RepoPath = ".",
    [string]$CommitHash = ""
)

$Version = "1.1.2"
Set-Location $RepoPath

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$env:GIT_TERMINAL_PROMPT = "0"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# 言語設定読み込み（lang.txt: ja/en、なければja）
$lang = "ja"
$langFile = Join-Path $PSScriptRoot "lang.txt"
if (Test-Path $langFile) {
    $l = Get-Content $langFile -Raw -ErrorAction SilentlyContinue
    if ($l) { $l = $l.Trim() }
    if ($l -eq "en") { $lang = "en" }
}

$T = @{
    ja = @{
        ErrorTitle = "エラー"; NotFound = "コミットが見つかりません："
        Count = "変更ファイル数"; Added = "追加"; Modified = "変更"; Deleted = "削除"; Renamed = "移動"; Other = "その他"
        Close = "閉じる"; Clip = "※ファイル名をクリップボードにコピーしました"
        Commit = "コミット"; Selected = "選択コミット数"; Valid = "有効"; Title = "コミット変更ファイル一覧"; Commits = "件のコミット"
    }
    en = @{
        ErrorTitle = "Error"; NotFound = "Commit not found:"
        Count = "Changed files"; Added = "Added"; Modified = "Modified"; Deleted = "Deleted"; Renamed = "Renamed"; Other = "Other"
        Close = "Close"; Clip = "* File names copied to clipboard"
        Commit = "Commit"; Selected = "Selected commits"; Valid = "valid"; Title = "Commit Changed Files"; Commits = " commits"
    }
}
$S = $T[$lang]

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
    $commitSummaries += "$($S.Commit) : $hash"
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
        "$($S.NotFound)`n$CommitHash",
        $S.ErrorTitle, "OK", "Error"
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
if ($hashes.Count -gt 1) { $lines += "$($S.Selected): $($hashes.Count) ($($S.Valid): $validCount)"; $lines += "" }
$lines += $commitSummaries
$lines += "$($S.Count): $count"
$lines += ""
if ($added)    { $lines += "=== $($S.Added) ($($added.Count)) ===";    $lines += $added    | % { "  [$($S.Added)] $_" }; $lines += "" }
if ($modified) { $lines += "=== $($S.Modified) ($($modified.Count)) ===";    $lines += $modified | % { "  [$($S.Modified)] $_" }; $lines += "" }
if ($deleted)  { $lines += "=== $($S.Deleted) ($($deleted.Count)) ===";    $lines += $deleted  | % { "  [$($S.Deleted)] $_" }; $lines += "" }
if ($renamed)  { $lines += "=== $($S.Renamed) ($($renamed.Count)) ===";    $lines += $renamed  | % { "  [$($S.Renamed)] $_" }; $lines += "" }
if ($other)    { $lines += "=== $($S.Other) ===";    $lines += $other    | % { "  [ ] $_" }; $lines += "" }

$message = $lines -join "`r`n"
$plainList = ($allFiles | Where-Object { $_ }) -join "`r`n"
Set-Clipboard -Value $plainList

$titleHash = if ($hashes.Count -gt 1) { "$($hashes.Count)$($S.Commits)" } else { $hashes[0] }

$form = New-Object System.Windows.Forms.Form
$form.Text = "$($S.Title) v$Version -- $titleHash"
$form.Size = New-Object System.Drawing.Size(700, 560)
$form.StartPosition = "WindowsDefaultLocation"
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
$btnClose.Text = $S.Close
$btnClose.Width = 80
$btnClose.Add_Click({ $form.Close() })

$lbl = New-Object System.Windows.Forms.Label
$lbl.Text = $S.Clip
$lbl.AutoSize = $true
$lbl.TextAlign = "MiddleLeft"
$lbl.Padding = New-Object System.Windows.Forms.Padding(5, 0, 0, 0)

$panel.Controls.Add($btnClose)
$panel.Controls.Add($lbl)
$form.Controls.Add($textBox)
$form.Controls.Add($panel)

[void]$form.ShowDialog()