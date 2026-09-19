# Fat パターン監査レポート

最終更新: 2026-09-19
対象Issue: #26 Fat Controller / Fat Model の解消（RuboCop）

## 概要

本レポートは、`app/controllers` と `app/models` 配下のクラスに
Fat Controller / Fat Model（責務の集中）パターンがないかを監査し、
その結果を記録したものです。

## 監査結果

### コントローラ（app/controllers）

| クラス | 行数 | 責務 | 判定 |
|--------|------|------|------|
| ApplicationController | 4 | 共通設定 | ✅ 問題なし |
| TopsController | 9 | トップページ表示 | ✅ 問題なし |
| ClothingItemsController | 60 | 洋服のCRUD | ✅ 標準的な7アクションで責務が明確 |
| OutfitsController | 65 | コーデの保存・一覧・再利用 | ✅ 各アクションが単一責務で、ロジックが簡潔 |

### モデル（app/models）

| クラス | 行数 | 責務 | 判定 |
|--------|------|------|------|
| ApplicationRecord | 3 | 基底クラス | ✅ 問題なし |
| User | 9 | ユーザー（devise） | ✅ 問題なし |
| Category | 6 | カテゴリ | ✅ 問題なし |
| ClothingItem | 12 | 洋服・in_use?判定 | ✅ 問題なし |
| Outfit | 24 | コーデ・enum/バリデーション | ✅ 問題なし |
| OutfitClothingItem | 6 | 中間テーブル | ✅ 問題なし |

## 結論

- 全クラスが行数・責務ともに健全で、**Fat Controller / Fat Model パターンは存在しない**ことを確認しました。
- 現状の規模ではサービス層（Service層）への分離は**過剰設計**となるため、導入しません。
- RuboCop（bin/rubocop）は全ファイルで 0 offenses（指摘なし）を維持しています。

以後、クラスが肥大化した場合は本レポートを起点に責務の分離を検討します。