import SwiftUI
import Combine

@MainActor
final class TranslationViewModel: ObservableObject {
    @Published var sourceText = ""
    @Published var translatedText = ""
    @Published var detectedLanguage = "Auto"
    @Published var isTranslating = false
    @Published var copied = false

    private var settings: AppSettings?
    private var translationService: TranslationService?
    private var debounceTask: Task<Void, Never>?

    func configure(settings: AppSettings) {
        self.settings = settings
        self.translationService = TranslationService(settings: settings)
    }

    func onSourceTextChanged() {
        debounceTask?.cancel()
        guard !sourceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            translatedText = ""
            detectedLanguage = "Auto"
            return
        }

        guard let settings else { return }
        let delay = settings.debounceSeconds

        debounceTask = Task {
            try? await Task.sleep(for: .seconds(delay))
            guard !Task.isCancelled else { return }
            translate()
        }
    }

    func translate() {
        debounceTask?.cancel()
        let text = sourceText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, let service = translationService else { return }

        isTranslating = true
        translatedText = ""

        Task {
            defer { isTranslating = false }
            do {
                let result = try await service.translate(text: text)
                translatedText = result.translation
                detectedLanguage = result.detectedLanguage
            } catch {
                translatedText = "Error: \(error.localizedDescription)"
            }
        }
    }

    func copyTranslation() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(translatedText, forType: .string)
        copied = true
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            copied = false
        }
    }
}
