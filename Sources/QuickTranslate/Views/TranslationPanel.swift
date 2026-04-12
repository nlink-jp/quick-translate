import SwiftUI

struct TranslationPanel: View {
    @EnvironmentObject var settings: AppSettings
    @StateObject private var viewModel = TranslationViewModel()
    @FocusState private var isSourceFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            HStack(spacing: 0) {
                sourcePane
                Divider()
                targetPane
            }
        }
        .frame(minWidth: 500, minHeight: 300)
        .onAppear {
            viewModel.configure(settings: settings)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isSourceFocused = true
            }
        }
    }

    private var header: some View {
        HStack {
            Text("QuickTranslate")
                .font(.headline)
            Spacer()
            Text(viewModel.detectedLanguage)
                .font(.caption)
                .foregroundColor(.secondary)
            Image(systemName: "arrow.right")
                .font(.caption)
                .foregroundColor(.secondary)
            Picker("", selection: $settings.targetLanguage) {
                Text("Japanese").tag("Japanese")
                Text("English").tag("English")
            }
            .labelsHidden()
            .frame(width: 100)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var sourcePane: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Source")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.top, 8)

            TextEditor(text: $viewModel.sourceText)
                .font(.title2)
                .focused($isSourceFocused)
                .padding(4)
                .onChange(of: viewModel.sourceText) {
                    viewModel.onSourceTextChanged()
                }

            HStack {
                Button("Translate") {
                    viewModel.translate()
                }
                .keyboardShortcut(.return, modifiers: .command)

                Spacer()

                ProgressView()
                    .scaleEffect(0.7)
                    .opacity(viewModel.isTranslating ? 1 : 0)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
    }

    private var targetPane: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Translation")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.top, 8)

            TextEditor(text: $viewModel.translatedText)
                .font(.title2)
                .padding(4)

            HStack {
                Spacer()
                Button {
                    viewModel.copyTranslation()
                } label: {
                    Label(
                        viewModel.copied ? "Copied!" : "Copy",
                        systemImage: viewModel.copied ? "checkmark" : "doc.on.doc"
                    )
                }
                .disabled(viewModel.translatedText.isEmpty)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
    }
}
