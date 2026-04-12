import Foundation
import NaturalLanguage

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

        let detected = detectLanguage(text: text)
        let translateInto = resolveTargetLanguage(detected: detected)
        let systemPrompt = buildSystemPrompt(translateInto: translateInto)
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
        let apiKey = settings.apiKey
        if !apiKey.isEmpty {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try JSONEncoder().encode(body)
        request.timeoutInterval = 120

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw TranslationError.invalidResponse
        }
        guard httpResponse.statusCode == 200 else {
            let body = String(data: data.prefix(512), encoding: .utf8) ?? "unknown"
            throw TranslationError.apiError(statusCode: httpResponse.statusCode, body: body)
        }

        let completion = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
        guard let content = completion.choices.first?.message.content else {
            throw TranslationError.emptyResponse
        }

        return TranslationResult(translation: content, detectedLanguage: detected)
    }

    /// Determine which language to translate into based on detected source language.
    private func resolveTargetLanguage(detected: String) -> String {
        let target = settings.targetLanguage
        // If source is already the target language, flip direction
        if detected == target {
            return target == "Japanese" ? "English" : "Japanese"
        }
        return target
    }

    private func buildSystemPrompt(translateInto: String) -> String {
        var prompt = """
            Translate the following text into \(translateInto).
            Output ONLY the translation. No explanations, no notes.
            Preserve formatting (line breaks, bullet points).
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
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        guard let language = recognizer.dominantLanguage else { return "Unknown" }
        let locale = Locale(identifier: "en")
        return locale.localizedString(forLanguageCode: language.rawValue) ?? language.rawValue
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
