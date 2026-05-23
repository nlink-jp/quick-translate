# Changelog

## [0.1.1] - 2026-05-23

### Changed

- **macOS builds are Developer ID signed and Apple-notarized.**
  `make build-app` now signs `QuickTranslate.app` with the Developer
  ID Application identity (Hardened Runtime + Apple secure timestamp)
  during the bundle step, and `make package` submits the signed `.app`
  to Apple's notary service and staples the ticket onto the bundle so
  offline first-launch works without a Gatekeeper verification dialog.
  Native Swift + AppKit does not embed WebKit, so no JIT entitlements
  are needed — Hardened Runtime alone is sufficient. End users on
  macOS no longer need the right-click → Open workaround or
  `xattr -d com.apple.quarantine` on downloaded builds. Local users
  who place `QuickTranslate.app` under Dropbox / iCloud / OneDrive-
  synced paths are no longer killed by macOS's ad-hoc +
  `com.apple.provenance` distrust policy.

No behaviour change to the app itself — feature-wise this is
identical to v0.1.0.

## [0.1.0] - 2026-04-13

### Added

- Menu bar resident app with floating translation panel
- Global shortcut (⌘⇧T, customizable) to toggle panel
- Two-pane UI (source input / editable translated output)
- OpenAI-compatible API integration (default: LM Studio / gemma-4-26b-a4b)
- API Key support for authenticated endpoints
- Automatic language detection (NSLinguisticTagger) with client-side direction resolution
- Debounce + manual button (⌘Return) translation triggers
- One-click copy of translated text
- Target language picker in panel header
- Resizable panel with position/size persistence
- Settings UI with General and Glossary tabs
- Glossary management (add/edit/delete) with auto-save
- Custom app icon
