import KeyboardShortcuts
import SwiftUI

extension KeyboardShortcuts.Name {
    static let togglePanel = Self("togglePanel", default: .init(.t, modifiers: [.command, .shift]))
}

@main
struct QuickTranslateApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("QuickTranslate", systemImage: "translate") {
            Button("Show / Hide Panel") {
                appDelegate.panelManager.toggle()
            }
            .keyboardShortcut("t", modifiers: [.command, .shift])

            Divider()

            SettingsLink {
                Text("Settings…")
            }

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }

        Settings {
            SettingsView()
                .environmentObject(appDelegate.settings)
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let settings = AppSettings()
    lazy var panelManager = PanelManager(settings: settings)

    func applicationDidFinishLaunching(_ notification: Notification) {
        KeyboardShortcuts.onKeyUp(for: .togglePanel) { [weak self] in
            Task { @MainActor in
                self?.panelManager.toggle()
            }
        }

        // Watch for any window becoming visible (e.g. Settings) to activate the app
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidBecomeKey),
            name: NSWindow.didBecomeKeyNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(checkWindows),
            name: NSWindow.willCloseNotification,
            object: nil
        )
    }

    @objc private func windowDidBecomeKey(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }
        if window is FloatingPanel {
            // Floating panel became key — restore floating level
            panelManager.setFloating(true)
        } else if window.isVisible {
            // Another window (Settings etc.) became key — lower floating panel
            NSApp.setActivationPolicy(.regular)
            NSApp.activate(ignoringOtherApps: true)
            panelManager.setFloating(false)
        }
    }

    @objc private func checkWindows(_ notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self else { return }
            let hasOtherWindows = NSApp.windows.contains(where: {
                $0.isVisible && !($0 is FloatingPanel) && $0.canBecomeKey
            })
            if !hasOtherWindows {
                self.panelManager.setFloating(true)
            }
            if !self.panelManager.isVisible && !hasOtherWindows {
                NSApp.setActivationPolicy(.accessory)
            }
        }
    }
}
