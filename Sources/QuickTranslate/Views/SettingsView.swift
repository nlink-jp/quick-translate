import KeyboardShortcuts
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        TabView {
            GeneralSettingsView()
                .environmentObject(settings)
                .tabItem { Label("General", systemImage: "gear") }

            GlossarySettingsView()
                .tabItem { Label("Glossary", systemImage: "book") }
        }
        .frame(width: 500, height: 400)
    }
}

struct GeneralSettingsView: View {
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
    }
}

struct GlossarySettingsView: View {
    @State private var entries: [GlossaryEntry] = []
    @State private var newSource = ""
    @State private var newTarget = ""

    var body: some View {
        VStack(spacing: 0) {
            // Add new entry
            HStack {
                TextField("Source term", text: $newSource)
                    .textFieldStyle(.roundedBorder)
                TextField("Translation", text: $newTarget)
                    .textFieldStyle(.roundedBorder)
                Button {
                    addEntry()
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .disabled(newSource.isEmpty || newTarget.isEmpty)
                .buttonStyle(.borderless)
            }
            .padding(12)

            Divider()

            // Entry list
            if entries.isEmpty {
                Spacer()
                Text("No glossary entries")
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                List {
                    ForEach($entries) { $entry in
                        HStack {
                            TextField("Source", text: $entry.source)
                                .textFieldStyle(.plain)
                            Text("→")
                                .foregroundColor(.secondary)
                            TextField("Translation", text: $entry.target)
                                .textFieldStyle(.plain)
                        }
                    }
                    .onDelete(perform: deleteEntries)
                }
            }

            Divider()

            // Footer
            HStack {
                Text("\(entries.count) entries")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Button("Save") {
                    save()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(12)
        }
        .onAppear {
            entries = GlossaryManager.load()
        }
    }

    private func addEntry() {
        let trimmedSource = newSource.trimmingCharacters(in: .whitespaces)
        let trimmedTarget = newTarget.trimmingCharacters(in: .whitespaces)
        guard !trimmedSource.isEmpty, !trimmedTarget.isEmpty else { return }

        entries.append(GlossaryEntry(source: trimmedSource, target: trimmedTarget))
        newSource = ""
        newTarget = ""
        save()
    }

    private func deleteEntries(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    private func save() {
        // Remove entries with empty source or target
        entries = entries.filter { !$0.source.isEmpty && !$0.target.isEmpty }
        try? GlossaryManager.save(entries)
    }
}
