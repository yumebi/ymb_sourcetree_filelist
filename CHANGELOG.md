# Changelog

## v1.1.4 (2026-06-20)

- CI修正：macos-latestランナーにshellcheck未搭載のためlint-macが毎回失敗していた問題を修正（brewでインストール追加）

## v1.1.3 (2026-06-20)

- mainへのpush時に自動でリリースを更新するよう変更（CHANGELOGの先頭バージョンからタグ自動作成→Release自動更新）

## v1.1.2 (2026-06-20)

- ウィンドウ・出力にバージョン番号を表示
- README訂正：複数コミット選択時もSourcetreeから渡るのは右クリックした1コミットのみ（v1.1.1の「個別プロセスで実行」記述は誤り）

## v1.1.1 (2026-06-20)

- Windows：複数コミット選択時に各ウィンドウがCenterScreenで重なり1個しか見えない不具合を修正（WindowsDefaultLocationでカスケード表示）
- README：Sourcetreeは複数選択時コミットごとに別プロセスで実行する旨を明記（1コミット1ウィンドウ）

## v1.1.0 (2026-06-20)

- 日本語 / English UI切り替えに対応（セットアップ時に選択、lang.txtで管理）
- インストール先フォルダを選択可能に（キャンセルで既定値）
- アンインストーラーを追加（Windows: uninstall.ps1/.bat、Mac: uninstall_mac.sh）
- Release用zipにREADME.md・LICENSEを同梱
- Lint強化（Windows: PSScriptAnalyzer、Mac: shellcheck）
- READMEにMacのquarantine属性解除手順を追加

## v1.0.0 (2026-06-20)

- コミット選択時に変更ファイル一覧をダイアログ表示
- 複数コミット選択に対応
- マージコミットに対応（差分が空の場合は第1親との差分にフォールバック）
- 日本語ファイル名に対応（`core.quotepath=false`）
- Windows（PowerShell）/ Mac（bash）両対応
- MITライセンス
