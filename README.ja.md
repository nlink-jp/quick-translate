# quick-translate

ローカルLLMを使ったmacOSメニューバー常駐型翻訳ツール。

## 特徴

- **メニューバー常駐** — グローバルショートカットまたはメニューバーアイコンで即座にアクセス
- **2ペインUI** — 左に原文、右に訳文を表示
- **ローカルLLM** — OpenAI互換API（デフォルトはLM Studio）を使用
- **言語自動認識** — 原文の言語を自動検出
- **プライバシー重視** — すべての処理がローカルで完結
- **用語集** — カスタム用語マッピングで一貫した翻訳を実現

## 動作要件

- macOS 14 Sonoma 以降
- [LM Studio](https://lmstudio.ai/) でモデルをロード済み（デフォルト: `google/gemma-4-26b-a4b`）

## インストール

[Releases](https://github.com/nlink-jp/quick-translate/releases) から `QuickTranslate.app` をダウンロード。

またはソースからビルド：

```bash
make build-app
open dist/QuickTranslate.app
```

## 使い方

1. QuickTranslateを起動 — メニューバーにアイコンが表示される
2. メニューバーアイコン（またはグローバルショートカット）をクリックして翻訳パネルを表示
3. 左ペインにテキストを入力またはペースト
4. 少し待つと右ペインに翻訳結果が表示される。**⌘ Return** で即座に翻訳も可能
5. **Copy** ボタンで翻訳結果をクリップボードにコピー

## 設定

メニューバーアイコンから **Settings** を開いて設定：

| 設定項目 | デフォルト値 | 説明 |
|---------|------------|------|
| API Endpoint | `http://localhost:1234/v1` | OpenAI互換APIのベースURL |
| API Key | (空) | API認証用Bearerトークン（任意） |
| Model | `google/gemma-4-26b-a4b` | LLMモデル名 |
| Target Language | Japanese | デフォルトの翻訳先言語 |
| Debounce | 2.0秒 | 入力停止後の自動翻訳待機時間 |

## 用語集

以下のパスに `glossary.json` を配置：

```
~/Library/Application Support/QuickTranslate/glossary.json
```

形式：

```json
[
  {"source": "endpoint", "target": "エンドポイント"},
  {"source": "deploy", "target": "デプロイ"}
]
```

## ビルド

```bash
make build        # リリースバイナリをビルド
make build-app    # .appバンドルを生成 → dist/
make test         # テスト実行
make clean        # ビルド成果物を削除
```

## ライセンス

MIT
