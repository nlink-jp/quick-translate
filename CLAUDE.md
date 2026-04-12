# CLAUDE.md — quick-translate

## Project Rules

- **Always `make build-app`** — never `swift build` directly for distribution
- **Tests required** — `make test` must pass before committing
- **Translation prompt is embedded** — do not expose it to user configuration (prompt injection risk)
- **Glossary is system-prompt injection only** — terms are appended to the system prompt, never to user messages
- **macOS 14 Sonoma minimum** — do not use APIs from macOS 15+
- **LSUIElement = true** — Dock icon is controlled via activation policy toggle, not Info.plist
- **Activation policy toggle is required** — `.regular` when panel/Settings visible, `.accessory` when hidden; removing this breaks keyboard input
- **Language detection is client-side** — NLLanguageRecognizer determines direction before LLM call; do not ask the LLM to detect language
- **API key in Keychain** — never store secrets in UserDefaults/@AppStorage; use KeychainHelper

## Series

Part of **util-series**. Follows nlink-jp organization conventions:
https://github.com/nlink-jp/.github/blob/main/CONVENTIONS.md
