import KeyboardShortcuts
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        Form {
            Section("API") {
                TextField("Endpoint", text: $settings.apiEndpoint)
                    .textFieldStyle(.roundedBorder)
                SecureField("API Key (optional)", text: $settings.apiKey)
                    .textFieldStyle(.roundedBorder)
                TextField("Model", text: $settings.modelName)
                    .textFieldStyle(.roundedBorder)
            }

            Section("Translation") {
                Picker("Target Language", selection: $settings.targetLanguage) {
                    Text("Japanese").tag("Japanese")
                    Text("English").tag("English")
                }
                HStack {
                    Text("Debounce (seconds)")
                    Slider(value: $settings.debounceSeconds, in: 0.5...5.0, step: 0.5)
                    Text(String(format: "%.1f", settings.debounceSeconds))
                        .monospacedDigit()
                        .frame(width: 30)
                }
            }

            Section("Shortcut") {
                HStack {
                    Text("Toggle Panel")
                    Spacer()
                    KeyboardShortcuts.Recorder(for: .togglePanel)
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 400, height: 350)
    }
}
