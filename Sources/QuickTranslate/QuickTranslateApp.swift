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
    }
}
