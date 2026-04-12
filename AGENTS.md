# AGENTS.md — quick-translate

## Summary

macOS menu-bar-resident translation tool powered by local LLM (OpenAI-compatible API).
Swift / SwiftUI. Translates between Japanese and English with automatic language detection.

## Build & Test

```bash
make build        # Build release binary
make build-app    # Build .app bundle → dist/QuickTranslate.app
make test         # Run tests
make run          # Build and run (debug)
make clean        # Remove build artifacts
```

## Project Structure

```
quick-translate/
├── Package.swift                          # Swift Package Manager manifest
├── Makefile                               # Build automation (always use make)
├── Sources/QuickTranslate/
│   ├── QuickTranslateApp.swift            # @main — MenuBarExtra entry point
│   ├── Views/
│   │   ├── TranslationPanel.swift         # 2-pane translation UI
│   │   ├── TranslationViewModel.swift     # Translation logic + debounce
│   │   └── SettingsView.swift             # Preferences window
│   ├── Services/
│   │   ├── TranslationService.swift       # OpenAI-compatible API client
│   │   └── GlossaryManager.swift          # JSON glossary file management
│   └── Models/
│       ├── AppSettings.swift              # @AppStorage-backed settings
│       └── ChatCompletion.swift           # API request/response types
├── Info.plist                             # App bundle metadata (LSUIElement)
├── Tests/QuickTranslateTests/
│   ├── TranslationServiceTests.swift      # Language detection tests
│   └── ChatCompletionTests.swift          # JSON encode/decode tests
└── docs/
    ├── en/quick-translate-rfp.md
    └── ja/quick-translate-rfp.ja.md
```

## Key Details

- **Platform**: macOS 14 Sonoma+
- **Menu bar app**: `LSUIElement = true` in Info.plist (no Dock icon)
- **Default API**: LM Studio at `http://localhost:1234/v1`
- **Default model**: `google/gemma-4-26b-a4b`
- **Settings**: Persisted via `@AppStorage` (UserDefaults)
- **Glossary**: `~/Library/Application Support/QuickTranslate/glossary.json`
- **Translation prompt**: Embedded (not user-customizable) to prevent prompt injection

## Gotchas

- `swift build` alone produces a CLI binary, not a `.app` bundle — use `make build-app`
- MenuBarExtra requires macOS 13+; this project targets macOS 14+
- Accessibility permission needed for global shortcuts (Phase 1 TODO)
- NSLinguisticTagger is legacy but works; NLLanguageRecognizer is the modern alternative
