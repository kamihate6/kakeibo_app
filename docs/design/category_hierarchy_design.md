# Category Hierarchy Design

## 概要

カテゴリを大分類・小分類の2階層構造に対応させる。

現在は1階層のみ管理している。

変更後は大分類配下に小分類を持てるようにする。

---

## 現状

```text
食費
交通費
日用品
```

---

## 変更後

```text
食費
├ スーパー
├ コンビニ
└ 外食

交通費
├ 電車
├ バス
└ ガソリン

日用品
├ 洗剤
├ ティッシュ
└ トイレットペーパー
```

---

## テーブル設計

### categories

#### 現状

```sql
id
name
```

#### 変更後

```sql
id uuid primary key

name text not null

parent_id uuid null

sort_order int default 0

created_at timestamptz default now()
```

---

## parent_id

親カテゴリを保持する。

### 親カテゴリ

```text
食費
```

```text
parent_id = NULL
```

### 子カテゴリ

```text
コンビニ
```

```text
parent_id = 食費のID
```

---

## 支出テーブル

変更なし。

```sql
expenses

id
category_id
amount
memo
expense_date
```

支出は子カテゴリを保持する。

---

## 支出登録画面

### 現状

```text
カテゴリ

[食費 ▼]
```

### 変更後

```text
大分類

[食費 ▼]

小分類

[コンビニ ▼]
```

---

## 実装手順

### Step1

categories テーブルへ parent_id を追加する。

```sql
alter table categories
add column parent_id uuid null;
```

### Step2

categories テーブルへ sort_order を追加する。

```sql
alter table categories
add column sort_order int default 0;
```

### Step3

親カテゴリを登録する。

```text
食費
交通費
日用品
```

### Step4

子カテゴリを登録する。

```text
スーパー
コンビニ
外食

電車
バス
ガソリン

洗剤
ティッシュ
トイレットペーパー
```

### Step5

支出登録画面を2階層対応する。

### Step6

Integration Test を更新する。

### Step7

Regression Test を実行する。

## カテゴリ管理

### 一覧表示

親カテゴリと子カテゴリを階層表示する。

### カテゴリ追加

利用者が画面から追加可能とする。

### カテゴリ編集

名称変更可能とする。

### カテゴリ削除

物理削除は行わず、
is_active=false とする。