# quick-translate

> **⚠️ Archived (2026-08-30) — superseded by [instant-translate](https://github.com/nlink-jp/instant-translate).**
> instant-translate is the same menu-bar workflow on the on-device macOS
> Translation framework instead of a local LLM: no model to download or
> host, no API endpoint to configure, and no credentials — but it requires
> macOS 26 or later. quick-translate receives no further updates; the
> repository stays public for reference and the notarized builds remain
> downloadable from the
> [Releases](https://github.com/nlink-jp/quick-translate/releases) page.
> On macOS 26+: `brew install nlink-jp/tap/instant-translate`.

A macOS menu-bar-resident translation tool powered by local LLM.

## Features

- **Menu bar resident** — always accessible via global shortcut (⌘⇧T) or menu bar icon
- **Floating panel** — stays above other windows, resizable, remembers position and size
- **Two-pane UI** — source text on the left, editable translation on the right
- **Local LLM** — uses OpenAI-compatible API (LM Studio by default)
- **Auto language detection** — detects source language and translates to the other direction
- **Privacy first** — all processing stays on your machine
- **Glossary** — custom term mappings managed via Settings UI
- **Configurable shortcut** — change the global hotkey in Settings

The app is single-instance: starting a second copy (for example, a
notification click resolving to a different copy of the .app) logs to
stderr and exits, leaving the running instance alone.

## Requirements

- macOS 14 Sonoma or later
- [LM Studio](https://lmstudio.ai/) with a loaded model (default: `google/gemma-4-26b-a4b`)

## Installation

Download the `.zip` from [Releases](https://github.com/nlink-jp/quick-translate/releases), unzip it, and move `QuickTranslate.app` to Applications. The `.app` is **Developer ID signed and Apple-notarized** (stapled), so it launches without Gatekeeper prompts and works offline.

Or build from source:

```bash
make build-app
open dist/QuickTranslate.app
```

## Usage

1. Launch QuickTranslate — it appears in the menu bar
2. Press **⌘⇧T** (or click the menu bar icon → Show / Hide Panel) to open the translation panel
3. Type or paste text in the left pane
4. Translation appears in the right pane after a short delay, or press **⌘ Return** to translate immediately
5. Edit the translation if needed, then click **Copy** to copy to clipboard
6. Press **⌘⇧T** or **⌘W** to close the panel

## Configuration

Open **Settings** from the menu bar icon. Two tabs are available:

### General

| Setting | Default | Description |
|---------|---------|-------------|
| Endpoint | `http://localhost:1234/v1` | OpenAI-compatible API base URL |
| API Key | (empty) | Bearer token for API authentication (optional) |
| Model | `google/gemma-4-26b-a4b` | LLM model name |
| Target Language | Japanese | Default translation target (also selectable in the panel) |
| Debounce | 2.0s | Auto-translate delay after typing stops |
| Toggle Panel | ⌘⇧T | Global keyboard shortcut (customizable) |

### Glossary

Add, edit, and delete term mappings directly in the UI. Entries are saved automatically to:

```
~/Library/Application Support/QuickTranslate/glossary.json
```

## Build

### Prerequisites

- **Xcode 15.2 or later** (includes Swift 5.9+ toolchain and macOS SDK)
  - Or install Command Line Tools: `xcode-select --install`
  - Verify SDK is available: `xcrun --show-sdk-path`
- **make**

### Commands

```bash
make build        # Build release binary
make build-app    # Build .app bundle → dist/
make test         # Run tests
make clean        # Remove build artifacts
```

## License

MIT
