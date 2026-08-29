# AGENTS.md — quick-translate

> **Archived (2026-08-30)** — superseded by
> [instant-translate](https://github.com/nlink-jp/instant-translate). This
> repository is read-only and no longer maintained; do not plan new work here.

## Summary

macOS menu-bar-resident translation tool powered by local LLM (OpenAI-compatible API).
Swift / SwiftUI. Translates between Japanese and English with automatic language detection.
Floating panel toggled by global shortcut (⌘⇧T).

## Build & Test

```bash
make build        # Build release binary
make build-app    # Build .app bundle → dist/QuickTranslate.app
make verify-release  # gate: .notarized marker + stapler validate (run before upload)
make test         # Run tests
make run          # Build and run (debug)
make clean        # Remove build artifacts
```

## Project Structure

```
quick-translate/
├── Package.swift                          # Swift Package Manager manifest
├── Makefile                               # Build automation (always use make)
├── icon.icns                              # App icon
├── Info.plist                             # App bundle metadata (LSUIElement=true)
├── Sources/QuickTranslate/
│   ├── Entry.swift                        # @main — single-instance guard, then QuickTranslateApp.main()
│   ├── SingleInstance.swift               # singleInstanceDecision() — startup duplicate-instance guard (pure)
│   ├── QuickTranslateApp.swift            # MenuBarExtra + AppDelegate
│   ├── PanelManager.swift                 # Floating panel show/hide + activation policy
│   ├── Views/
│   │   ├── FloatingPanel.swift            # NSPanel subclass with frame persistence
│   │   ├── TranslationPanel.swift         # 2-pane translation UI
│   │   ├── TranslationViewModel.swift     # Translation logic + debounce
│   │   └── SettingsView.swift             # Tabbed settings (General + Glossary)
│   ├── Services/
│   │   ├── TranslationService.swift       # OpenAI-compatible API client
│   │   └── GlossaryManager.swift          # JSON glossary file management
│   └── Models/
│       ├── AppSettings.swift              # @AppStorage-backed settings
│       └── ChatCompletion.swift           # API request/response types
├── Tests/QuickTranslateTests/
│   ├── TranslationServiceTests.swift      # Language detection tests
│   ├── ChatCompletionTests.swift          # JSON encode/decode tests
│   └── SingleInstanceTests.swift          # singleInstanceDecision() tests
└── docs/
    ├── en/quick-translate-rfp.md
    └── ja/quick-translate-rfp.ja.md
```

## Key Details

- **Platform**: macOS 14 Sonoma+
- **Menu bar app**: `LSUIElement = true` in Info.plist (no permanent Dock icon)
- **Dock icon**: appears only while panel or Settings is open (activation policy toggle)
- **Default API**: LM Studio at `http://localhost:1234/v1`
- **Default model**: `google/gemma-4-26b-a4b`
- **Global shortcut**: ⌘⇧T (customizable via KeyboardShortcuts package)
- **Settings**: Persisted via `@AppStorage` (UserDefaults)
- **Glossary**: `~/Library/Application Support/QuickTranslate/glossary.json`
- **Translation prompt**: Embedded (not user-customizable) to prevent prompt injection
- **Language detection**: Client-side (NSLinguisticTagger), determines translation direction before sending to LLM

## Gotchas

- `swift build` alone produces a CLI binary, not a `.app` bundle — use `make build-app`
- MenuBarExtra requires macOS 13+; this project targets macOS 14+
- Activation policy toggles between `.regular` and `.accessory` for keyboard focus — removing this breaks text input
- Panel frame (position/size) is saved to UserDefaults key `panelFrame`
- NSLinguisticTagger is legacy but works; NLLanguageRecognizer is the modern alternative
- KeyboardShortcuts package handles Carbon API registration for global hotkeys
- **Notification clicks launch by bundle ID — enforce a single instance.**
  Clicking a banner makes notificationd open the app via LaunchServices,
  which resolves `jp.nlink.quick-translate` among *all* registered copies
  (`dist/` dev builds, release-verification extractions, `/Applications`)
  and may start a different copy than the running one → two menu bar
  items, two copies racing to register the global shortcut. Guarded at
  two layers: `LSMultipleInstancesProhibited` (Info.plist, stops
  LaunchServices launches) and a startup check in `Entry.main`
  (`singleInstanceDecision`, pure + tested) that exits with a stderr note
  (covers direct exec / `open -n`). Side effect: to run a `dist/` build,
  quit the installed instance first — a second copy now refuses to start.
