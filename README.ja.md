# quick-translate

ローカルLLMを使ったmacOSメニューバー常駐型翻訳ツール。

## 特徴

- **メニューバー常駐** — グローバルショートカット（⌘⇧T）またはメニューバーアイコンで即座にアクセス
- **フローティングパネル** — 他のウィンドウの上に表示、リサイズ可能、位置とサイズを記憶
- **2ペインUI** — 左に原文入力、右に編集可能な訳文を表示
- **ローカルLLM** — OpenAI互換API（デフォルトはLM Studio）を使用
- **言語自動認識** — 原文の言語を自動検出し、反対の言語に翻訳
- **プライバシー重視** — すべての処理がローカルで完結
- **用語集** — 設定UIからカスタム用語マッピングを管理
- **ショートカット設定** — 設定画面でグローバルホットキーを変更可能

## 動作要件

- macOS 14 Sonoma 以降
- [LM Studio](https://lmstudio.ai/) でモデルをロード済み（デフォルト: `google/gemma-4-26b-a4b`）

## インストール

[Releases](https://github.com/nlink-jp/quick-translate/releases) から `.zip` をダウンロード・解凍し、`QuickTranslate.app` をアプリケーションフォルダに移動してください。`.app` は **Apple Developer ID 署名済 + Apple notarize 済** (ticket staple 済) です。Gatekeeper ダイアログなしで起動でき、オフラインでも動作します。

またはソースからビルド：

```bash
make build-app
open dist/QuickTranslate.app
```

## 使い方

1. QuickTranslateを起動 — メニューバーにアイコンが表示される
2. **⌘⇧T**（またはメニューバーアイコン → Show / Hide Panel）で翻訳パネルを表示
3. 左ペインにテキストを入力またはペースト
4. 少し待つと右ペインに翻訳結果が表示される。**⌘ Return** で即座に翻訳も可能
5. 必要に応じて訳文を編集し、**Copy** ボタンでクリップボードにコピー
6. **⌘⇧T** または **⌘W** でパネルを閉じる

## 設定

メニューバーアイコンから **Settings** を開く。2つのタブがある：

### General

| 設定項目 | デフォルト値 | 説明 |
|---------|------------|------|
| Endpoint | `http://localhost:1234/v1` | OpenAI互換APIのベースURL |
| API Key | (空) | API認証用Bearerトークン（任意） |
| Model | `google/gemma-4-26b-a4b` | LLMモデル名 |
| Target Language | Japanese | デフォルトの翻訳先言語（パネルでも変更可能） |
| Debounce | 2.0秒 | 入力停止後の自動翻訳待機時間 |
| Toggle Panel | ⌘⇧T | グローバルショートカット（変更可能） |

### Glossary

UIから用語マッピングの追加・編集・削除が可能。エントリは自動保存：

```
~/Library/Application Support/QuickTranslate/glossary.json
```

## ビルド

### 前提条件

- **Xcode 15.2 以降**（Swift 5.9+ ツールチェーンおよび macOS SDK を含む）
  - または Command Line Tools をインストール: `xcode-select --install`
  - SDK が利用可能か確認: `xcrun --show-sdk-path`
- **make**

### コマンド

```bash
make build        # リリースバイナリをビルド
make build-app    # .appバンドルを生成 → dist/
make test         # テスト実行
make clean        # ビルド成果物を削除
```

## ライセンス

MIT
