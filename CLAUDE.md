# CLAUDE.md — quick-translate

## Project Rules

- **Always `make build` or `make build-app`** — never `swift build` directly for distribution
- **Tests required** — `make test` must pass before committing
- **Translation prompt is embedded** — do not expose it to user configuration (prompt injection risk)
- **Glossary is system-prompt injection only** — terms are appended to the system prompt, never to user messages
- **macOS 14 Sonoma minimum** — do not use APIs from macOS 15+
- **No Dock icon** — `LSUIElement = true` must remain in Info.plist

## Series

Part of **util-series**. Follows nlink-jp organization conventions:
https://github.com/nlink-jp/.github/blob/main/CONVENTIONS.md
