# 家計簿アプリ Ver1.0 テスト仕様書

## 1. 文書情報

| 項目 | 内容 |
|------|------|
| システム名 | 家計簿アプリ |
| バージョン | Ver1.0 |
| テスト種別 | Integration Test |
| 作成日 | 2026-10-14 |
| 作成者 | 開発チーム |

---

# 2. テスト環境

| 項目 | 内容 |
|------|------|
| OS | Windows 11 |
| Framework | Flutter |
| Backend | Supabase |
| 実行方法 | flutter test |
| テスト実行端末 | Windows Desktop |

## テストユーザ

| 項目 | 内容 |
|------|------|
| メールアドレス | kakeibo003@example.com |
| パスワード | 1234567890 |

---

# 3. システム構成

## 対象ソース一覧

| ファイル | 機能 |
|----------|----------|
| main.dart | アプリ起動 |
| auth_page.dart | 認証 |
| household_setup_page.dart | 世帯作成 |
| home_page.dart | ホーム |
| add_expense_page.dart | 支出登録 |
| expense_edit_page.dart | 支出編集 |
| history_page.dart | 支出履歴 |
| budget_page.dart | 予算管理 |
| dashboard_page.dart | ダッシュボード |

---

# 4. テスト実行手順

## アプリ起動テスト

実行コマンド

```powershell
flutter test integration_test/app_test.dart -d windows
```

---

## 認証画面テスト

実行コマンド

```powershell
flutter test integration_test/auth_test.dart -d windows
```

---

## ログインテスト

実行コマンド

```powershell
flutter test integration_test/login_flow_test.dart -d windows
```

---

## 支出登録テスト

実行コマンド

```powershell
flutter test integration_test/expense_create_test.dart -d windows
```

---

## 支出編集テスト

実行コマンド

```powershell
flutter test integration_test/expense_edit_test.dart -d windows
```

---

## 支出削除テスト

実行コマンド

```powershell
flutter test integration_test/expense_delete_test.dart -d windows
```

---

## 予算登録テスト

実行コマンド

```powershell
flutter test integration_test/budget_create_test.dart -d windows
```

---

## ダッシュボードテスト

実行コマンド

```powershell
flutter test integration_test/dashboard_view_test.dart -d windows
```

---

## 回帰テスト

実行コマンド

```powershell
flutter test integration_test/regression_test.dart -d windows
```

---

# 5. テストケース一覧

| ID | テストコード | 機能 | 状態 |
|------|------|------|------|
| TC-001 | smoke_test.dart | テスト環境確認 | PASS |
| TC-002 | app_test.dart | アプリ起動 | PASS |
| TC-003 | auth_test.dart | 認証画面 | PASS |
| TC-004 | login_flow_test.dart | ログイン | PASS |
| TC-005 | expense_create_test.dart | 支出登録 | PASS |
| TC-006 | expense_edit_test.dart | 支出編集 | PASS |
| TC-007 | expense_delete_test.dart | 支出削除 | PASS |
| TC-008 | budget_create_test.dart | 予算登録 | PASS |
| TC-009 | dashboard_view_test.dart | ダッシュボード表示 | PASS |
| TC-010 | regression_test.dart | 回帰テスト | PASS |
| TC-011 | auto\_login\_test.dart | 自動ログイン | PASS |


---

# 6. テストケース詳細

## TC-001 アプリ起動確認

| 項目 | 内容 |
|------|------|
| 対象 | main.dart |
| テストコード | app_test.dart |
| 手順 | アプリ起動 |
| 期待結果 | ログイン画面表示 |
| 実績 | PASS |

---

## TC-002 認証画面確認

| 項目 | 内容 |
|------|------|
| 対象 | auth_page.dart |
| テストコード | auth_test.dart |
| 手順 | 認証画面表示 |
| 期待結果 | メールアドレス入力欄表示 |
| 期待結果 | パスワード入力欄表示 |
| 期待結果 | ログインボタン表示 |
| 期待結果 | 新規登録ボタン表示 |
| 実績 | PASS |

---

## TC-003 ログイン

| 項目 | 内容 |
|------|------|
| 対象 | auth_page.dart |
| テストコード | login_flow_test.dart |
| 手順 | ログイン実行 |
| 期待結果 | Home画面表示 |
| 実績 | PASS |

---

## TC-004 支出登録

| 項目 | 内容 |
|------|------|
| 対象 | add_expense_page.dart |
| テストコード | expense_create_test.dart |
| 手順 | 支出登録実行 |
| 期待結果 | 支出登録完了メッセージ |
| 実績 | PASS |

---

## TC-005 支出編集

| 項目 | 内容 |
|------|------|
| 対象 | expense_edit_page.dart |
| テストコード | expense_edit_test.dart |
| 手順 | 支出編集 |
| 期待結果 | 更新しましたメッセージ |
| 実績 | PASS |

---

## TC-006 支出削除

| 項目 | 内容 |
|------|------|
| 対象 | history_page.dart |
| テストコード | expense_delete_test.dart |
| 手順 | 支出削除 |
| 期待結果 | 削除確認後に削除完了 |
| 実績 | PASS |

---

## TC-007 予算登録

| 項目 | 内容 |
|------|------|
| 対象 | budget_page.dart |
| テストコード | budget_create_test.dart |
| 手順 | 予算登録 |
| 期待結果 | 予算登録完了メッセージ |
| 実績 | PASS |

---

## TC-008 ダッシュボード表示

| 項目 | 内容 |
|------|------|
| 対象 | dashboard_page.dart |
| テストコード | dashboard_view_test.dart |
| 手順 | ダッシュボード表示 |
| 期待結果 | ダッシュボード表示 |
| 実績 | PASS |

---

## TC-009 回帰テスト

| 項目 | 内容 |
|------|------|
| 対象 | Home画面 |
| テストコード | regression_test.dart |
| 手順 | ログイン後Home表示 |
| 期待結果 | 支出登録表示 |
| 期待結果 | 支出履歴表示 |
| 期待結果 | 予算表示 |
| 期待結果 | ダッシュボード表示 |
| 実績 | PASS |

---

# 7. 機能網羅状況

| 機能 | テスト有無 | 状態 |
|--------|--------|--------|
| 認証 | ○ | PASS |
| ログイン | ○ | PASS |
| 世帯作成 | △ | 手動確認のみ |
| 支出登録 | ○ | PASS |
| 支出編集 | ○ | PASS |
| 支出削除 | ○ | PASS |
| 支出履歴 | ○ | PASS |
| 予算登録 | ○ | PASS |
| 予算更新 | ○ | PASS |
| ダッシュボード | ○ | PASS |
| カテゴリ集計 | △ | 表示確認のみ |
| 予算消化率 | △ | 表示確認のみ |

---

# 8. 既知課題

| ID | 内容 | 優先度 |
|------|------|------|
| K-001 | flutter test integration_test 一括実行時に Dashboardテストで不安定になることがある | 低 |
| K-002 | Windows Desktop Integration Testで Debug Connection エラーが発生する場合がある | 低 |
| K-003 | 個別実行では全テスト成功 | 確認済 |

---

# 9. リリース判定

| 項目 | 状態 |
|------|------|
| 認証 | ✅ |
| 支出CRUD | ✅ |
| 予算管理 | ✅ |
| ダッシュボード | ✅ |
| Integration Test | ✅ |

## 判定

✅ Ver1.0 リリース可能