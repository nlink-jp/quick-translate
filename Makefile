APP_NAME    := QuickTranslate
BUNDLE_ID   := jp.nlink.quick-translate
VERSION     := $(shell git describe --tags --always --dirty 2>/dev/null || echo "0.1.0")
BUILD_DIR   := .build/release
DIST_DIR    := dist
APP_BUNDLE  := $(DIST_DIR)/$(APP_NAME).app

.PHONY: build build-app test clean run dev

## build: Build release binary
build:
	@mkdir -p $(DIST_DIR)
	swift build -c release

## build-app: Build .app bundle for distribution
build-app: build
	@rm -rf $(APP_BUNDLE)
	@mkdir -p $(APP_BUNDLE)/Contents/MacOS
	@mkdir -p $(APP_BUNDLE)/Contents/Resources
	@cp $(BUILD_DIR)/$(APP_NAME) $(APP_BUNDLE)/Contents/MacOS/
	@sed 's/$${VERSION}/$(VERSION)/g; s/$${BUNDLE_ID}/$(BUNDLE_ID)/g; s/$${APP_NAME}/$(APP_NAME)/g' \
		Info.plist > $(APP_BUNDLE)/Contents/Info.plist
	@cp icon.icns $(APP_BUNDLE)/Contents/Resources/icon.icns
	@echo "Built $(APP_BUNDLE) ($(VERSION))"

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
