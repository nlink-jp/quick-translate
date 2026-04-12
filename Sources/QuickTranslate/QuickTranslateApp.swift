import SwiftUI

@main
struct QuickTranslateApp: App {
    @StateObject private var settings = AppSettings()

    var body: some Scene {
        MenuBarExtra("QuickTranslate", systemImage: "translate") {
            TranslationPanel()
                .environmentObject(settings)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environmentObject(settings)
        }
    }
}
