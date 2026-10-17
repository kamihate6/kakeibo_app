# 家計簿アプリ Ver1.1 テスト仕様書

## 1. 文書情報

| 項目 | 内容 |
|------|------|
| システム名 | 家計簿アプリ |
| バージョン | Ver1.1 |
| テスト種別 | Integration Test |
| 作成日 | 2026-10-15 |
| 作成者 | 開発チーム |
| 対応ブランチ | feature/auto-login |

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

# 3. リリース概要

## Ver1.1 追加機能

| 機能 | 内容 |
|------|------|
| 自動ログイン | Session保持時に認証画面をスキップ |
| SplashPage | 起動時の画面遷移制御 |
| Session判定 | Supabase Session確認処理 |
| 自動ログインテスト | Integration Test追加 |

---

# 4. 対象ソース一覧

| ファイル | 機能 |
|----------|----------|
| main.dart | アプリ起動 |
| splash_page.dart | Session判定 |
| auth_page.dart | 認証 |
| home_page.dart | ホーム画面 |

---

# 5. テスト実行手順

## 自動ログインテスト

実行コマンド

```powershell
flutter test integration_test/auto_login_test.dart -d windows
```

---

# 6. テストケース一覧

| ID | テストコード | 機能 | 状態 |
|------|------|------|------|
| TC-011 | auto_login_test.dart | 自動ログイン | PASS |

---

# 7. テストケース詳細

## TC-011 自動ログイン確認

| 項目 | 内容 |
|------|------|
| 対象 | main.dart |
| 対象 | splash_page.dart |
| テストコード | auto_login_test.dart |
| 手順 | アプリ起動 |
| 手順 | Session確認 |
| 手順 | Home画面表示 |
| 期待結果 | SplashPage表示 |
| 期待結果 | Session取得成功 |
| 期待結果 | Home画面表示 |
| 期待結果 | Auth画面を経由しない |
| 実績 | PASS |

### 前提条件

| 項目 | 内容 |
|------|------|
| テストユーザ | kakeibo003@example.com |
| パスワード | 1234567890 |
| Session | 有効 |

### テスト詳細手順

| No | 操作 | 期待結果 |
|------|------|------|
| 1 | アプリ起動 | SplashPage表示 |
| 2 | Session取得 | Session取得成功 |
| 3 | Session判定 | session != null |
| 4 | HomePage遷移 | HomePage表示 |
| 5 | 支出登録ボタン確認 | 表示される |
| 6 | 支出履歴ボタン確認 | 表示される |
| 7 | 予算ボタン確認 | 表示される |
| 8 | ダッシュボードボタン確認 | 表示される |
| 9 | AuthPage表示確認 | 表示されない |

### 対象ソース

| ファイル | 用途 |
|------|------|
| main.dart | アプリ起動 |
| splash_page.dart | Session判定 |
| auth_page.dart | 未ログイン遷移先 |
| home_page.dart | ログイン済み遷移先 |

---

# 8. 機能網羅状況

| 機能 | テスト有無 | 状態 |
|--------|--------|--------|
| SplashPage | ○ | PASS |
| Session判定 | ○ | PASS |
| 自動ログイン | ○ | PASS |
| Home画面遷移 | ○ | PASS |

---

# 9. 変更内容

## 変更対象ソース

| ファイル | 変更内容 |
|------|------|
| main.dart | 起動先をAuthPageからSplashPageへ変更 |
| splash_page.dart | 新規作成 |

---

## 動作概要

```text
アプリ起動
↓
SplashPage
↓
Session確認

Sessionあり
↓
HomePage

Sessionなし
↓
AuthPage
```

---

# 10. テスト結果

| テストコード | 結果 |
|------|------|
| auto_login_test.dart | PASS |

---

# 11. 既知課題

| ID | 内容 | 優先度 |
|------|------|------|
| K-001 | integration_test一括実行時にWindows Desktopで不安定になる場合がある | 低 |
| K-002 | Debug Connectionエラーが発生する場合がある | 低 |
| K-003 | 個別実行では全テスト成功 | 確認済 |

---

# 12. リリース判定

| 項目 | 状態 |
|------|------|
| SplashPage実装 | ✅ |
| Session判定実装 | ✅ |
| 自動ログイン実装 | ✅ |
| Integration Test作成 | ✅ |
| 手動動作確認 | ✅ |

## 判定

✅ Ver1.1 リリース可能

---

# 13. Git管理情報

| 項目 | 内容 |
|------|------|
| 開発ブランチ | feature/auto-login |
| ベースブランチ | develop |
| バージョン | Ver1.1 |
| 機能名 | Auto Login |

``