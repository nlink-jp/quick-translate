# RFP: quick-translate

> Generated: 2026-04-12
> Status: Draft

## 1. Problem Statement

quick-translateは、ローカルLLMを使ったmacOS常駐型翻訳ツールである。

DeepLはサブスクリプション費用が高く、macOSネイティブアプリがバグで正常に動作しないことが多い。この問題を解決するため、ローカルLLM（LM Studio）を活用し、コストゼロかつ安定した翻訳環境を提供する。

メニューバーに常駐し、ショートカットキーで2ペイン翻訳パネルを呼び出す。原文を入力またはペーストすると、OpenAI互換API経由でローカルLLMが言語を自動認識し、指定言語（主に日本語・英語）に翻訳して訳文パネルに表示する。プライバシーとオフライン利用を両立するmacOS専用ツール。

対象ユーザーは主に開発者自身だが、他のユーザーも利用可能。

## 2. Functional Specification

### Commands / API Surface

macOS GUIアプリケーション（CLIではない）。

- **メニューバーアイコン** — クリックでポップオーバーパネル表示
- **グローバルショートカット** — 設定可能なキーバインドでパネル表示/非表示を切り替え
- **翻訳パネル** — 2ペイン構成（左: 原文入力、右: 訳文表示）
- **翻訳ボタン** — 手動で翻訳を実行
- **コピーボタン** — 訳文をワンクリックでクリップボードにコピー

### Input / Output

- **入力**: テキストフィールドへの直接入力またはペースト
- **出力**: 訳文パネルへのテキスト表示
- **クリップボード自動ペースト**: なし（意図的に除外）
- **翻訳トリガー**:
  - デバウンス方式（入力停止後N秒で自動翻訳）
  - 手動ボタン押下

### Configuration

設定項目（アプリ内設定UI + 設定ファイル）:

| 項目 | デフォルト値 | 説明 |
|------|-------------|------|
| APIエンドポイント | `http://localhost:1234/v1` | OpenAI互換APIのベースURL |
| モデル名 | `google/gemma-4-26b-a4b` | 使用するLLMモデル |
| 翻訳先言語 | 日本語 | デフォルトの翻訳先言語 |
| ショートカットキー | （要設定） | グローバルショートカット |
| デバウンス秒数 | （要調整） | 入力停止後の自動翻訳待機時間 |

### External Dependencies

- **LM Studio** — ローカルLLMサーバー（OpenAI互換API）
- macOS標準フレームワーク（SwiftUI, AppKit, URLSession）

## 3. Design Decisions

### 言語・フレームワーク: Swift / SwiftUI

macOSのメニューバー常駐（MenuBarExtra）、グローバルショートカット、ポップオーバーパネルがすべてOS標準APIで実現できる。Tauri v2での開発経験から、ネイティブフレームワークの方がブリッジ問題を回避でき安定性が高いと判断。

### 補完する既存ツール

util-seriesのmail-analyzer-gui（Tauri v2）に続くGUIアプリケーション。lite-seriesのローカルLLM路線（lite-llm, lite-switch等）と思想が近い。

### プロンプト内蔵

翻訳プロンプトはアプリに内蔵し、ユーザーによるカスタマイズは提供しない。カスタマイズ可能にするとプロンプトインジェクション対策が難しくなるため。

### ステートレス設計

翻訳履歴は保持しない。不要なデータを残さない方針。

### 用語集

- JSONファイル形式、1:1の原語→訳語マッピング
- 規模: 最大100語程度を想定
- システムプロンプトに展開して翻訳精度を向上

### 明確にスコープ外

- ファイル一括翻訳
- 複数LLMの同時比較
- iOS / iPad対応（メニューバーが存在しない）

## 4. Development Plan

### Phase 1: Core

- メニューバー常駐（MenuBarExtra）+ グローバルショートカットでポップオーバー表示
- 2ペインUI（原文入力 / 訳文表示）
- OpenAI互換APIへの翻訳リクエスト（言語自動認識 → 指定言語）
- デバウンス + 手動ボタンによる翻訳トリガー
- 訳文ワンクリックコピー
- 基本設定（APIエンドポイント、モデル名、翻訳先言語、ショートカットキー、デバウンス秒数）
- ユニットテスト（API通信、デバウンスロジック、言語認識）

### Phase 2: Features

- 用語集機能（JSON管理、システムプロンプトへの展開）
- 設定UIの整備

### Phase 3: Release

- ドキュメント整備（README.md / README.ja.md / CHANGELOG.md / AGENTS.md）
- リリースビルド（.app配布形式）
- util-seriesサブモジュールとして統合

各Phaseは独立してレビュー可能。

## 5. Required API Scopes / Permissions

外部クラウドAPIは使用しない。

macOSの権限:
- **Accessibility権限** — グローバルショートカットのキー監視に必要（初回のみユーザー許可）
- **ローカルネットワーク通信** — localhost（LM Studio API）へのHTTP通信

## 6. Series Placement

Series: **util-series**
Reason: mail-analyzer-gui（Tauri v2 GUIアプリ）が既にutil-seriesに存在しており、GUIアプリケーションの前例がある。パイプフレンドリーなCLIではないが、データ変換・処理という目的はutil-seriesのスコープに合致する。

## 7. External Platform Constraints

- **macOS最低バージョン**: macOS 14 Sonoma以降（MenuBarExtra APIの安定版）
- **LM Studio API**: OpenAI互換だが、ストリーミング応答の挙動がモデルにより異なる場合がある
- **Accessibility権限**: グローバルショートカット登録時にシステム環境設定での許可が必要（初回のみ）
- **モデル依存**: デフォルトモデル（gemma-4-26b-a4b）はLM Studioで事前にダウンロードが必要

---

## Discussion Log

1. **ツール名の選定** — lite-translate, local-translator, quick-translateの3候補から、メニューバー常駐・ショートカット起動の「手軽さ」を反映するquick-translateを採用。

2. **UIフレームワーク** — SwiftUI, Wails (Go), rumps (Python) を比較検討。Tauri v2での過去の苦労を考慮し、macOSネイティブAPIが最も自然に使えるSwiftUIを選択。nlink-jpエコシステム（Go/Python）とは異なる言語だが、メニューバー常駐の要件に対するトレードオフとして妥当と判断。

3. **翻訳トリガー** — リアルタイム翻訳はLLMの応答速度を考慮すると非現実的。デバウンス方式（入力停止後N秒）+ 手動ボタンの併用に決定。

4. **クリップボード連携** — 起動時の自動ペーストは意図しないデータが入る可能性があるため除外。訳文のワンクリックコピーは採用。

5. **プロンプト管理** — カスタマイズ可能にするとプロンプトインジェクション対策が困難になるため、内蔵プロンプトに限定。セキュリティを優先した判断。

6. **用語集** — 当初スコープ外として提案したが、システムプロンプトへの展開で実現可能と判断し採用。JSON形式、1:1マッピング、最大100語程度。Phase 2で実装。

7. **シリーズ配置** — lite-seriesのローカルLLM路線と思想は近いが、mail-analyzer-guiがutil-seriesにGUIアプリとして既存する前例から、util-seriesに配置。

8. **macOS最低バージョン** — 現時点の標準的なバージョンとしてmacOS 14 Sonoma以降に設定。
