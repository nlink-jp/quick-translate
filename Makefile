APP_NAME    := QuickTranslate
# NAME is the kebab-case tool/repo name used for the release archive, per the
# org Release Archive Standard (<name>-v<version>-<os>-<arch>.zip). The .app
# bundle inside keeps its CamelCase name ($(APP_NAME).app).
NAME        := quick-translate
BUNDLE_ID   := jp.nlink.quick-translate
VERSION     := $(shell git describe --tags --always --dirty 2>/dev/null || echo "0.1.0")
BUILD_DIR   := .build/release
DIST_DIR    := dist
APP_BUNDLE  := $(DIST_DIR)/$(APP_NAME).app

# macOS Developer ID signing / notarization (see nlink-jp/.github
# CONVENTIONS.md §Code Signing → Wails / GUI apps; the same .app
# pipeline applies to native Swift apps). Pure Swift / AppKit doesn't
# embed WebKit, so no JIT entitlements are needed — Hardened Runtime
# alone is sufficient. The codesign script accepts an empty 3rd arg
# to skip --entitlements.
CODESIGN_IDENTITY ?= Developer ID Application
NOTARY_PROFILE    ?= nlink-jp-notary

CODESIGN_SCRIPT := scripts/codesign-darwin-app.sh
NOTARIZE_SCRIPT := scripts/notarize-darwin-app.sh

.PHONY: build build-app package test clean run dev

## build: Build release binary
build:
	@mkdir -p $(DIST_DIR)
	swift build -c release

## build-app: Build .app bundle for distribution, signed with Developer ID
build-app: build
	@rm -rf $(APP_BUNDLE)
	@mkdir -p $(APP_BUNDLE)/Contents/MacOS
	@mkdir -p $(APP_BUNDLE)/Contents/Resources
	@cp $(BUILD_DIR)/$(APP_NAME) $(APP_BUNDLE)/Contents/MacOS/
	@sed 's/$${VERSION}/$(VERSION)/g; s/$${BUNDLE_ID}/$(BUNDLE_ID)/g; s/$${APP_NAME}/$(APP_NAME)/g' \
		Info.plist > $(APP_BUNDLE)/Contents/Info.plist
	@cp icon.icns $(APP_BUNDLE)/Contents/Resources/icon.icns
	@$(CODESIGN_SCRIPT) $(APP_BUNDLE) "$(CODESIGN_IDENTITY)"
	@echo "Built $(APP_BUNDLE) ($(VERSION))"

## package: build-app, notarize the .app (staples the ticket), then
## zip the now-stapled bundle for upload to GitHub Releases.
package: build-app
	@$(NOTARIZE_SCRIPT) $(APP_BUNDLE) "$(NOTARY_PROFILE)"
	@cd $(DIST_DIR) && /usr/bin/ditto -c -k --keepParent $(APP_NAME).app $(NAME)-$(VERSION)-darwin-arm64.zip
	@ls -la $(DIST_DIR)/$(NAME)-$(VERSION)-darwin-arm64.zip

## test: Run tests
test:
	swift test

## clean: Remove build artifacts
clean:
	rm -rf $(DIST_DIR) .build

## run: Build and run (debug)
run:
	swift run

## dev: Build and run (debug, verbose)
dev:
	swift run 2>&1
