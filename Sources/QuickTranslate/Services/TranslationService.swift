import Foundation

struct TranslationResult {
    let translation: String
    let detectedLanguage: String
}

final class TranslationService {
    private let settings: AppSettings

    init(settings: AppSettings) {
        self.settings = settings
    }

    func translate(text: String) async throws -> TranslationResult {
        let endpoint = settings.apiEndpoint.trimmingCharacters(in: .init(charactersIn: "/"))
        guard let url = URL(string: "\(endpoint)/chat/completions") else {
            throw TranslationError.invalidEndpoint
        }

        let systemPrompt = buildSystemPrompt()
        let body = ChatCompletionRequest(
            model: settings.modelName,
            messages: [
                .init(role: "system", content: systemPrompt),
                .init(role: "user", content: text),
            ],
            temperature: 0.1
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if !settings.apiKey.isEmpty {
            request.setValue("Bearer \(settings.apiKey)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try JSONEncoder().encode(body)
        request.timeoutInterval = 120

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw TranslationError.invalidResponse
        }
        guard httpResponse.statusCode == 200 else {
            let body = String(data: data, encoding: .utf8) ?? "unknown"
            throw TranslationError.apiError(statusCode: httpResponse.statusCode, body: body)
        }

        let completion = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
        guard let content = completion.choices.first?.message.content else {
            throw TranslationError.emptyResponse
        }

        let detected = detectLanguage(text: text)
        return TranslationResult(translation: content, detectedLanguage: detected)
    }

    private func buildSystemPrompt() -> String {
        let target = settings.targetLanguage
        var prompt = """
            You are a professional translator. Translate the user's text into \(target).
            Rules:
            - Detect the source language automatically.
            - Output ONLY the translated text, nothing else.
            - Preserve the original formatting (line breaks, bullet points, etc.).
            - If the source text is already in \(target), translate it into English instead.
            """

        let glossary = GlossaryManager.load()
        if !glossary.isEmpty {
            prompt += "\n\nGlossary (use these translations for the specified terms):\n"
            for entry in glossary {
                prompt += "- \"\(entry.source)\" → \"\(entry.target)\"\n"
            }
        }

        return prompt
    }

    func detectLanguage(text: String) -> String {
        let tagger = NSLinguisticTagger(tagSchemes: [.language], options: 0)
        tagger.string = text
        guard let language = tagger.dominantLanguage else { return "Unknown" }
        let locale = Locale(identifier: "en")
        return locale.localizedString(forLanguageCode: language) ?? language
    }
}

enum TranslationError: LocalizedError {
    case invalidEndpoint
    case invalidResponse
    case apiError(statusCode: Int, body: String)
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .invalidEndpoint:
            return "Invalid API endpoint URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .apiError(let code, let body):
            return "API error (\(code)): \(body)"
        case .emptyResponse:
            return "Empty response from API"
        }
    }
}
