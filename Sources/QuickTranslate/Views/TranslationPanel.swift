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
            Text(settings.targetLanguage)
                .font(.caption)
                .foregroundColor(.secondary)
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
                .font(.body)
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

                if viewModel.isTranslating {
                    ProgressView()
                        .scaleEffect(0.7)
                }
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

            ScrollView {
                Text(viewModel.translatedText)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
                    .textSelection(.enabled)
            }

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
