# RFP: quick-translate

> Generated: 2026-04-12
> Status: Draft

## 1. Problem Statement

quick-translate is a macOS menu-bar-resident translation tool powered by a local LLM.

DeepL's subscription cost is high, and its macOS native app frequently breaks due to bugs. To address this, quick-translate leverages a local LLM (LM Studio) to provide a cost-free and stable translation environment.

The app resides in the menu bar and summons a two-pane translation panel via a global shortcut. When the user types or pastes source text, the app sends a request to an OpenAI-compatible API running locally, automatically detects the source language, and displays the translation (primarily Japanese/English) in the output pane. It is a macOS-exclusive tool that ensures both privacy and offline availability.

The primary target user is the developer themselves, though others are welcome to use it.

## 2. Functional Specification

### Commands / API Surface

macOS GUI application (not a CLI).

- **Menu bar icon** — click to show popover panel
- **Global shortcut** — configurable keybinding to toggle panel visibility
- **Translation panel** — two-pane layout (left: source input, right: translated output)
- **Translate button** — manually trigger translation
- **Copy button** — one-click copy of translated text to clipboard

### Input / Output

- **Input**: Direct text entry or paste into the source text field
- **Output**: Translated text displayed in the output pane
- **Auto-paste from clipboard**: No (intentionally excluded)
- **Translation triggers**:
  - Debounce (auto-translate N seconds after input stops)
  - Manual button press

### Configuration

Settings (in-app settings UI + config file):

| Item | Default | Description |
|------|---------|-------------|
| API endpoint | `http://localhost:1234/v1` | Base URL for OpenAI-compatible API |
| Model name | `google/gemma-4-26b-a4b` | LLM model to use |
| Target language | Japanese | Default target language |
| Shortcut key | (to be configured) | Global keyboard shortcut |
| Debounce delay | (to be tuned) | Seconds to wait after input stops before auto-translating |

### External Dependencies

- **LM Studio** — local LLM server (OpenAI-compatible API)
- macOS standard frameworks (SwiftUI, AppKit, URLSession)

## 3. Design Decisions

### Language / Framework: Swift / SwiftUI

macOS menu-bar residency (MenuBarExtra), global shortcuts, and popover panels are all available through native OS APIs. Based on prior experience with Tauri v2, a native framework avoids bridge-related issues and provides better stability.

### Complementary Existing Tools

This is the second GUI application in util-series, following mail-analyzer-gui (Tauri v2). Its local-LLM philosophy aligns with the lite-series tools (lite-llm, lite-switch, etc.).

### Embedded Prompt

The translation prompt is embedded in the app; user customization is not provided. Making it customizable would complicate prompt injection countermeasures.

### Stateless Design

No translation history is retained. The policy is to avoid storing unnecessary data.

### Glossary

- JSON file format, 1:1 source-term to target-term mapping
- Scale: up to approximately 100 terms
- Injected into the system prompt to improve translation accuracy

### Explicitly Out of Scope

- Batch file translation
- Simultaneous multi-LLM comparison
- iOS / iPad support (no menu bar on those platforms)

## 4. Development Plan

### Phase 1: Core

- Menu-bar residency (MenuBarExtra) + global shortcut to show popover
- Two-pane UI (source input / translated output)
- Translation requests to OpenAI-compatible API (auto-detect language → target language)
- Debounce + manual button translation triggers
- One-click copy of translated text
- Basic settings (API endpoint, model name, target language, shortcut key, debounce delay)
- Unit tests (API communication, debounce logic, language detection)

### Phase 2: Features

- Glossary feature (JSON management, system prompt injection)
- Settings UI refinement

### Phase 3: Release

- Documentation (README.md / README.ja.md / CHANGELOG.md / AGENTS.md)
- Release build (.app distribution)
- Integration as a util-series submodule

Each phase can be reviewed independently.

## 5. Required API Scopes / Permissions

No external cloud APIs are used.

macOS permissions:
- **Accessibility permission** — required for global shortcut key monitoring (one-time user approval)
- **Local network communication** — HTTP communication to localhost (LM Studio API)

## 6. Series Placement

Series: **util-series**
Reason: mail-analyzer-gui (a Tauri v2 GUI app) already exists in util-series, establishing a precedent for GUI applications. While not a pipe-friendly CLI, the data transformation/processing purpose aligns with util-series scope.

## 7. External Platform Constraints

- **Minimum macOS version**: macOS 14 Sonoma or later (stable MenuBarExtra API)
- **LM Studio API**: OpenAI-compatible, but streaming response behavior may vary by model
- **Accessibility permission**: System Settings approval required for global shortcut registration (one-time)
- **Model dependency**: The default model (gemma-4-26b-a4b) must be pre-downloaded in LM Studio

---

## Discussion Log

1. **Tool naming** — Three candidates were considered: lite-translate, local-translator, and quick-translate. quick-translate was chosen to reflect the "quick access" nature of menu-bar residency and shortcut-driven invocation.

2. **UI framework** — SwiftUI, Wails (Go), and rumps (Python) were compared. Considering past difficulties with Tauri v2, SwiftUI was selected as it provides the most natural access to macOS native APIs for menu-bar apps. While Swift is a new language for the nlink-jp ecosystem (primarily Go/Python), the trade-off was deemed worthwhile for the menu-bar residency requirement.

3. **Translation trigger** — Real-time translation was deemed impractical given LLM response latency. A debounce approach (auto-translate N seconds after input stops) combined with a manual button was adopted.

4. **Clipboard integration** — Auto-paste on launch was excluded to avoid unintended data exposure. One-click copy of translated output was adopted.

5. **Prompt management** — Customizable prompts would complicate prompt injection defenses, so the prompt is embedded and fixed. Security was prioritized.

6. **Glossary** — Initially proposed as out of scope, but reconsidered as feasible via system prompt injection. JSON format, 1:1 mapping, up to ~100 terms. Scheduled for Phase 2.

7. **Series placement** — While the local-LLM philosophy aligns with lite-series, the precedent of mail-analyzer-gui as a GUI app in util-series led to placement in util-series.

8. **Minimum macOS version** — Set to macOS 14 Sonoma as the current standard version.
