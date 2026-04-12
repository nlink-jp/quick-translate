# quick-translate

A macOS menu-bar-resident translation tool powered by local LLM.

## Features

- **Menu bar resident** — always accessible via global shortcut or menu bar icon
- **Two-pane UI** — source text on the left, translation on the right
- **Local LLM** — uses OpenAI-compatible API (LM Studio by default)
- **Auto language detection** — detects source language automatically
- **Privacy first** — all processing stays on your machine
- **Glossary** — custom term mappings for consistent translations

## Requirements

- macOS 14 Sonoma or later
- [LM Studio](https://lmstudio.ai/) with a loaded model (default: `google/gemma-4-26b-a4b`)

## Installation

Download `QuickTranslate.app` from [Releases](https://github.com/nlink-jp/quick-translate/releases).

Or build from source:

```bash
make build-app
open dist/QuickTranslate.app
```

## Usage

1. Launch QuickTranslate — it appears in the menu bar
2. Click the menu bar icon (or use the global shortcut) to open the translation panel
3. Type or paste text in the left pane
4. Translation appears in the right pane after a short delay, or press **⌘ Return** to translate immediately
5. Click **Copy** to copy the translation to clipboard

## Configuration

Open **Settings** from the menu bar icon to configure:

| Setting | Default | Description |
|---------|---------|-------------|
| API Endpoint | `http://localhost:1234/v1` | OpenAI-compatible API base URL |
| API Key | (empty) | Bearer token for API authentication (optional) |
| Model | `google/gemma-4-26b-a4b` | LLM model name |
| Target Language | Japanese | Default translation target |
| Debounce | 2.0s | Auto-translate delay after typing stops |

## Glossary

Place a `glossary.json` file at:

```
~/Library/Application Support/QuickTranslate/glossary.json
```

Format:

```json
[
  {"source": "endpoint", "target": "エンドポイント"},
  {"source": "deploy", "target": "デプロイ"}
]
```

## Build

```bash
make build        # Build release binary
make build-app    # Build .app bundle → dist/
make test         # Run tests
make clean        # Remove build artifacts
```

## License

MIT
