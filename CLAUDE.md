# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

**Asatsuyu（朝露）** は、macOS向けのポモドーロ+メモネイティブアプリケーションです。Dynamic Island/ノッチを利用したUI/UXとObsidian連携機能を特徴とします。

## 技術スタック

- **プラットフォーム**: macOS 13 Ventura以降 (MenuBarExtra対応)
- **開発言語**: Swift 6.0+ + SwiftUI 5.0+
- **ビルドシステム**: Swift Package Manager + Xcode併用
- **アーキテクチャ**: MVVM + Combine
- **主要フレームワーク**: 
  - AppKit (NotchOverlayWindow独自実装)
  - Core Graphics (進捗アーク描画)
  - UserNotifications (通知システム) *未実装*
  - Core Data (統計データ永続化・in-memory)
- **外部連携**: Obsidian Daily Note（Markdownファイル）
- **Bundle ID**: com.shuya.asatsuyu

## アーキテクチャ

### 主要機能モジュール

1. **ポモドーロタイマー機能**
   - タイマー時間: 作業30分・短い休憩5分・長い休憩15分（すべてカスタマイズ可能）
   - サイクル管理: 4回の作業サイクル後に長い休憩
   - 操作: 開始/一時停止/再開/中断/リセット
   - バックグラウンド実行対応

2. **ノッチオーバーレイ統合** ✅ 実装済み
   - NotchOverlayWindow 独自実装（NSWindow.Level(.screenSaver)）
   - safeAreaInsetsによる自動ノッチ検出 + 解像度フォールバック
   - Core Graphics による270度進捗アーク描画
   - 色分け: 作業中（システムアクセント）・短い休憩（緑）・長い休憩（青）
   - constrainFrameRect制約無効化でノッチエリアアクセス
   - 統合管理: NotchOverlayManager + Combine Publisher監視

3. **メモ機能とObsidian連携** 🚧 Phase2予定
   - Vault自動検出: `~/Documents/Obsidian/`・iCloud・ユーザー指定パス
   - Daily Note形式: `YYYY-MM-DD.md`
   - タイムスタンプ付き自動保存: `HH:MM` + Markdown
   - リアルタイムプレビュー機能

4. **統計・データ管理** ✅ 基盤完成
   - Core Data in-memoryストア（開発段階）
   - エンティティ: PomodoroSession, DailySummary
   - PersistenceController @MainActor対応
   - 統計UI・CSV エクスポート機能は Phase3予定

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

### Phase 1: 基盤構築 ✅ 完了
1. ✅ **プロジェクト初期化**: Swift Package Manager・Xcode併用・Core Data基盤
2. ✅ **タイマー機能コア**: PomodoroTimer モデル・Combine Publisher・状態管理
3. ✅ **基本UI**: MenuBarExtra・SwiftUI基本画面・操作ボタン
4. ✅ **ノッチ拡張UI統合**: NotchOverlayWindow・進捗アーク・Combine連携

**実装済み機能**: 10個の原子的コミットで以下を完成
- Swift 6.0 + strict concurrency対応
- NotchOverlayWindow（constrainFrameRect無効化）
- NotchProgressView（Core Graphics 270度アーク）
- NotchOverlayManager（Combine統合）
- PomodoroTimer（TimerState・SessionType）
- TimerViewModel（@Published + MVVM）
- MenuBarExtra統合
- PersistenceController（in-memory）
- SettingsManager（UserDefaults）

### Phase 2: 通知とメモ機能 🚧 開発中
1. **通知システム**: UserNotifications・権限管理・音声設定
2. **Obsidian連携基盤**: Vault検出・ファイル操作・権限処理
3. **メモ機能UI**: Markdownエディタ・プレビュー・自動保存

### Phase 3: 高度な機能 ⏳ 未着手
1. **設定画面**: 各種設定UI・UserDefaults連携
2. **統計機能**: データ集計・グラフ表示・CSV エクスポート
3. **品質向上**: アクセシビリティ・キーボードショートカット・エラーハンドリング

### Phase 4: リリース準備 ⏳ 未着手
1. **テスト・デバッグ**: ユニットテスト・UIテスト・メモリリーク検証
2. **リリース準備**: App Store Connect・アイコン・プライバシーポリシー

## 開発時の注意点

### ノッチ拡張UI開発 ✅ 実装済み
- ✅ NotchOverlayWindow による独自実装（DynamicNotchKit代替）
- ✅ NSWindow.Level(.screenSaver) によるオーバーレイウィンドウ
- ✅ constrainFrameRect オーバーライドによるフレーム制約回避
- ✅ Core Graphics での進捗アーク描画（270度）
- ✅ safeAreaInsets + 解像度フォールバックによるノッチ検出
- ✅ セッション種別による色分け（作業・短い休憩・長い休憩）
- [ ] システムテーマ（ライト/ダーク）への自動対応

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

### ノッチ拡張UI制約 ✅ 大部分解決済み
- ✅ constrainFrameRect オーバーライドでノッチエリア制限を回避
- ✅ NSWindow.Level(.screenSaver) によるメニューバー上表示
- ✅ ノッチ未搭載Mac での200x32px テスト表示対応
- ✅ 外部ライブラリ依存を排除（DynamicNotchKit除去済み）
- 🔧 実機ノッチ搭載Macでの最終位置調整が必要

### App Store 審査対策
- ファイルアクセス権限の明確な説明
- プライバシーポリシーの適切な記載
- サンドボックス制限の遵守

### パフォーマンス要件
- メモリ使用量: 50MB未満を目標
- CPU使用率: アイドル時1%未満
- バッテリー効率の最適化


## Git開発ワークフロー

### コミットメッセージ規約 ⚠️ 厳守
~/.claude/CLAUDE.mdで指定された形式に従う：

```
fix: バグ修正の説明
hotfix: 緊急バグ修正の説明  
add: 新機能追加の説明
update: 既存機能の変更・改善の説明
ref: リファクタリングの説明
remove: 削除対象の説明
revert: 戻し対象の説明
```

### コミット単位の原則 ⚠️ TDD準拠
1. **原子的コミット**: 1つの論理的変更につき1コミット
2. **TDDサイクル準拠**: Red-Green-Refactor の各段階でコミット
3. **単一責任**: コミットは1つの明確な目的のみを持つ
4. **ビルド可能**: 各コミット時点でコンパイル・実行可能な状態を維持
5. **最大変更量**: 50-100行程度の変更に抑制（大規模変更は分割）

### 正しいコミット例
```bash
# ❌ 悪い例（複数機能を1つのコミットに混在）
git commit -m "add: timer functionality and notch overlay"

# ✅ 良い例（機能を分割）
git commit -m "add: PomodoroTimerモデルの基本実装"
git commit -m "add: TimerViewModelのCombine統合"
git commit -m "add: NotchOverlayWindow基盤実装"
```

### ブランチ戦略
- **main**: リリース可能な安定版
- **feature/機能名**: 新機能開発用（例: feature/notification-system）
- **fix/修正内容**: バグ修正用
- **hotfix/緊急修正**: 本番環境の緊急修正

### 過去のコミット履歴参考
Phase 1で作成した10個の原子的コミット：
1. `add: プロジェクト基盤セットアップとSwift Package Manager設定`
2. `add: Core Dataモデル定義とPersistenceController実装`
3. `add: PomodoroTimerモデルの基本実装とタイマー状態管理`
4. `add: SettingsManagerのUserDefaults統合実装`
5. `add: TimerViewModelのCombine統合とMVVMパターン実装`
6. `add: SwiftUI ContentViewの基本UI実装`
7. `add: MenuBarExtraシステム統合と環境オブジェクト設定`
8. `add: NotchOverlayWindow基盤実装とフレーム制約回避`
9. `add: NotchProgressViewのCore Graphics進捗アーク描画`
10. `add: NotchOverlayManagerのCombine統合と完全連携`

## GitHub PR管理ワークフロー

### リポジトリ情報
- **GitHub URL**: https://github.com/Shuyawa89/asatsuyu
- **Claude Code Actions**: 統合済み（@claudeメンションで自動対応）
- **CI/CD**: Swift 6.0 ビルド・テスト自動実行

### Claude Codeで可能なGitHub操作
✅ **直接操作可能**:
- `gh` コマンドによる全GitHub操作
- リモートpush・PR作成・マージ
- Issue/PRコメント確認・返信
- GitHub Actions ワークフロー実行

✅ **GitHub Actions連携**:
- Issue/PRで `@claude` メンション → 自動コード生成・修正
- PR作成時の自動ビルド・テスト実行
- コードレビューの自動化

### PR作成〜マージまでの標準フロー

#### 1. 機能開発ブランチ作成
```bash
# 新機能開発開始
git checkout -b feature/notification-system
git push -u origin feature/notification-system
```

#### 2. 原子的コミット開発
```bash
# TDDサイクル: Red → Green → Refactor で段階的コミット
git commit -m "add: UserNotifications基盤実装"
git commit -m "add: 通知権限管理とプロンプト表示"
git commit -m "add: タイマー完了通知の統合"
git push origin feature/notification-system
```

#### 3. PR作成（Claude Code実行）
```bash
# PRを自動作成（テンプレート使用）
gh pr create --title "add: 通知システム統合実装" --body "$(cat <<'EOF'
## 概要
ポモドーロタイマーの通知システムを実装しました。

## 実装内容
- [ ] UserNotifications権限管理
- [ ] タイマー完了時の自動通知
- [ ] 設定画面での通知設定切り替え

## テスト計画
- [ ] 通知権限の正常な取得確認
- [ ] 各セッション完了時の通知発火確認
- [ ] 通知設定の永続化確認

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)"
```

#### 4. 自動CI/CDとレビュー
- GitHub Actions自動実行: Swift 6.0ビルド・テスト
- PRに `@claude` でコードレビュー要請可能
- Claude Codeが自動でコードレビュー・提案

#### 5. レビュー対応とマージ申請
```bash
# PRレビューの確認と分析（カスタムコマンド使用）
/check-pr

# レビュー内容に基づく修正実装
# レビューのフィードバックを実装後、ユーザーにマージ申請
echo "✅ レビュー対応完了。マージの許可をお願いします。"
```

⚠️ **重要**: **マージはユーザーの明示的許可が必要**
- Claude Codeは自動マージを行いません
- レビュー対応完了後、ユーザーにマージ許可を求めます
- ユーザーが承認後、squashマージを実行します

### Issue駆動開発の活用
```bash
# Issue作成でタスク管理
gh issue create --title "Phase 2: Obsidian連携システム実装" --body "@claude Phase 2の実装を開始してください。要件定義.mdを参考に、Obsidian Daily Note連携機能を実装してください。"

# Claude CodeがIssue内容を解析してPR自動作成
```

### コードレビューのベストプラクティス
1. **人間主導レビュー**: ユーザーや他のAIがコードレビューを実施
2. **Claude Code対応**: `/check-pr` でレビュー内容を分析・実装提案
3. **機能テスト**: 各PRでの動作確認とスクリーンショット添付  
4. **パフォーマンス**: メモリ使用量・CPU使用率の測定結果記載
5. **セキュリティ**: APIキー・ファイルアクセス権限の適切性確認

### /check-pr カスタムコマンド
PRレビューの分析と対応提案を行うカスタムコマンド：
```bash
# 使用方法
/check-pr

# 機能
- 最新PRのレビューコメント取得・分析
- コードベース文脈での妥当性評価  
- 実装提案の優先度付け（Accept/Reject/Modify/Discuss）
- 具体的な対応方法の提示
```

### 緊急修正時のHotfixワークフロー
```bash
# main から hotfix ブランチ作成
git checkout main && git pull origin main
git checkout -b hotfix/critical-timer-bug
# 修正実装
git commit -m "hotfix: タイマーリセット時のメモリリーク修正"
git push origin hotfix/critical-timer-bug
gh pr create --title "hotfix: Critical timer memory leak" --base main
gh pr merge --squash --delete-branch  # 即座にマージ
```

## Geminiの使い方
Gemini CLIを使うことで、他のAIに質問したり、Webを介して検索をすることができます。
- 使い方
gemini --prompt "1から10までの素数をリストアップして"

のようにすると、メッセージの内容をgeminiに投げて、検索や意見を聞くことができます。