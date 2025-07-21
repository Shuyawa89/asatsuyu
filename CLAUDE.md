# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

**Asatsuyu（朝露）** は、macOS向けのポモドーロ+メモネイティブアプリケーションです。Dynamic Island/ノッチを利用したUI/UXとObsidian連携機能を特徴とします。

## 技術スタック

- **プラットフォーム**: macOS 15 Sequoia以降
- **開発言語**: Swift 6.0+ + SwiftUI 5.0+
- **アーキテクチャ**: MVVM + Combine
- **主要フレームワーク**: 
  - DynamicNotchKit (ノッチ拡張UI) *Swift Package*
  - Core Animation (視覚エフェクト・進捗アニメーション)
  - UserNotifications (通知システム)
  - Core Data (統計データ永続化)
- **外部連携**: Obsidian Daily Note（Markdownファイル）
- **Bundle ID**: com.shuya.asatsuyu

## アーキテクチャ

### 主要機能モジュール

1. **ポモドーロタイマー機能**
   - タイマー時間: 作業30分・短い休憩5分・長い休憩15分（すべてカスタマイズ可能）
   - サイクル管理: 4回の作業サイクル後に長い休憩
   - 操作: 開始/一時停止/再開/中断/リセット
   - バックグラウンド実行対応

2. **ノッチ拡張UI統合**
   - DynamicNotchKit または独自オーバーレイウィンドウによる実装
   - ノッチ周辺での進捗アーク表示（ノッチを視覚的に拡張）
   - Core Animation による滑らかなアニメーション
   - 色分け: 作業中（システムアクセント）・短い休憩（緑）・長い休憩（青）
   - フォールバック: ノッチ未搭載Mac での MenuBarExtra 表示
   - 展開表示: MenuBarExtra ウィンドウ (320x400px)

3. **メモ機能とObsidian連携**
   - Vault自動検出: `~/Documents/Obsidian/`・iCloud・ユーザー指定パス
   - Daily Note形式: `YYYY-MM-DD.md`
   - タイムスタンプ付き自動保存: `HH:MM` + Markdown
   - リアルタイムプレビュー機能

4. **統計・データ管理**
   - Core Data による永続化
   - エンティティ: PomodoroSession, DailySummary
   - 集計データ: 完了セッション数・総作業時間・集中度スコア
   - CSV エクスポート機能

## データモデル

### UserDefaults 設定項目
```swift
"timer.workDuration": TimeInterval        // 作業時間（デフォルト30分）
"timer.shortBreakDuration": TimeInterval  // 短い休憩（デフォルト5分）
"timer.longBreakDuration": TimeInterval   // 長い休憩（デフォルト15分）
"timer.cyclesUntilLongBreak": Int         // 長い休憩までのサイクル数（デフォルト4）
"notifications.soundEnabled": Bool        // 音声通知（デフォルトtrue）
"obsidian.vaultPath": String?             // Obsidian Vault パス
"obsidian.autoSaveEnabled": Bool          // 自動保存（デフォルトtrue）
```

### Core Data エンティティ
- **PomodoroSession**: 個別セッションの記録（開始・終了時刻、種別、完了状況、中断回数）
- **DailySummary**: 日別集計データ（日付、完了セッション数、総時間、集中度スコア）

## 開発フェーズ詳細

### Phase 1: 基盤構築 (2-3週間)
1. **プロジェクト初期化**: Xcode プロジェクト・Core Data・MVVM基盤
2. **タイマー機能コア**: PomodoroTimer モデル・Combine Publisher・状態管理
3. **基本UI**: MenuBarExtra・円形プログレス・操作ボタン
4. **ノッチ拡張UI統合**: DynamicNotchKit・オーバーレイウィンドウ・進捗アーク

### Phase 2: 通知とメモ機能 (2-3週間)
1. **通知システム**: UserNotifications・権限管理・音声設定
2. **Obsidian連携基盤**: Vault検出・ファイル操作・権限処理
3. **メモ機能UI**: Markdownエディタ・プレビュー・自動保存

### Phase 3: 高度な機能 (3-4週間)
1. **設定画面**: 各種設定UI・UserDefaults連携
2. **統計機能**: データ集計・グラフ表示・CSV エクスポート
3. **品質向上**: アクセシビリティ・キーボードショートカット・エラーハンドリング

### Phase 4: リリース準備 (1-2週間)
1. **テスト・デバッグ**: ユニットテスト・UIテスト・メモリリーク検証
2. **リリース準備**: App Store Connect・アイコン・プライバシーポリシー

## 開発時の注意点

### ノッチ拡張UI開発
- DynamicNotchKit の適切な統合と設定
- オーバーレイウィンドウの NSWindow.Level 調整
- constrainFrameRect オーバーライドによるフレーム制約回避
- Core Animation での進捗アーク描画とアニメーション
- ノッチ検出とフォールバック処理の実装
- システムテーマ（ライト/ダーク）への自動対応

### ファイル操作・権限管理
- Obsidian Vault の段階的検出ロジック
- サンドボックス環境でのファイルアクセス権限
- UTF-8 エンコーディングでの安全な読み書き
- エラーハンドリング（権限不足・ファイル競合等）

### バックグラウンド実行
- タイマーの精度維持（アプリ非アクティブ時）
- 通知スケジューリングのタイミング管理
- システムスリープ時の動作保証

### データ永続化
- Core Data のスレッドセーフな操作
- UserDefaults の適切なキー設計
- 統計データの整合性保証

### アクセシビリティ対応
- VoiceOver 対応（全UI要素への適切なラベル）
- キーボードナビゲーション実装
- カラーコントラスト基準の遵守

## 主要コマンド

### プロジェクト管理
```bash
# プロジェクトビルド
xcodebuild -scheme Asatsuyu -configuration Debug build

# テスト実行
xcodebuild test -scheme Asatsuyu -destination 'platform=macOS'

# アーカイブ作成（リリース時）
xcodebuild -scheme Asatsuyu -configuration Release archive
```

### 依存関係管理
```swift
// Package.swift での DynamicNotchKit 追加
dependencies: [
    .package(url: "https://github.com/MrKai77/DynamicNotchKit", from: "1.0.0")
]
```

### 開発ツール
- **Xcode**: 16.0 以降
- **iOS Simulator**: 不要（macOS専用）
- **インストルメンツ**: メモリリーク・パフォーマンス検証用

## 技術的制約・考慮事項

### ノッチ拡張UI制約
- macOS システムによるノッチエリアのアクセス制限
- NSWindow.Level 設定による他アプリとの競合可能性  
- ノッチ未搭載Mac でのフォールバック実装必要
- DynamicNotchKit 依存による外部ライブラリリスク
- オーバーレイウィンドウのパフォーマンス影響

### App Store 審査対策
- ファイルアクセス権限の明確な説明
- プライバシーポリシーの適切な記載
- サンドボックス制限の遵守

### パフォーマンス要件
- メモリ使用量: 50MB未満を目標
- CPU使用率: アイドル時1%未満
- バッテリー効率の最適化


## Geminiの使い方
Gemini CLIを使うことで、他のAIに質問したり、Webを介して検索をすることができます。
- 使い方
gemini --prompt "1から10までの素数をリストアップして"

のようにすると、メッセージの内容をgeminiに投げて、検索や意見を聞くことができます。