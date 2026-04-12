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
        .frame(width: 500, height: 480)
    }
}

struct GeneralSettingsView: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                sectionHeader("API")
                VStack(alignment: .leading, spacing: 8) {
                    Text("Endpoint").font(.caption).foregroundColor(.secondary)
                    TextField("http://localhost:1234/v1", text: $settings.apiEndpoint)
                        .textFieldStyle(.roundedBorder)
                    Text("API Key").font(.caption).foregroundColor(.secondary)
                    SecureField("optional", text: $settings.apiKey)
                        .textFieldStyle(.roundedBorder)
                    Text("Model").font(.caption).foregroundColor(.secondary)
                    TextField("google/gemma-4-26b-a4b", text: $settings.modelName)
                        .textFieldStyle(.roundedBorder)
                }

                Divider()

                sectionHeader("Translation")
                VStack(alignment: .leading, spacing: 8) {
                    Picker("Target Language", selection: $settings.targetLanguage) {
                        Text("Japanese").tag("Japanese")
                        Text("English").tag("English")
                    }
                    HStack {
                        Text("Debounce")
                        Slider(value: $settings.debounceSeconds, in: 0.5...5.0, step: 0.5)
                        Text(String(format: "%.1fs", settings.debounceSeconds))
                            .monospacedDigit()
                            .frame(width: 40)
                    }
                }

                Divider()

                sectionHeader("Shortcut")
                HStack {
                    Text("Toggle Panel")
                    Spacer()
                    KeyboardShortcuts.Recorder(for: .togglePanel)
                }
            }
            .padding(20)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
    }
}

struct GlossarySettingsView: View {
    @State private var entries: [GlossaryEntry] = GlossaryManager.load()
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
                                .onChange(of: entry.source) { save() }
                            Text("→")
                                .foregroundColor(.secondary)
                            TextField("Translation", text: $entry.target)
                                .textFieldStyle(.plain)
                                .onChange(of: entry.target) { save() }
                            Button {
                                if let index = entries.firstIndex(where: { $0.id == entry.id }) {
                                    entries.remove(at: index)
                                    save()
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }

            Divider()

            // Footer
            HStack {
                Text("\(entries.count) entries")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(12)
        }
        .onAppear {
            // Reload only if @State was initialized before file existed
            let loaded = GlossaryManager.load()
            if entries.isEmpty && !loaded.isEmpty {
                entries = loaded
            }
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
