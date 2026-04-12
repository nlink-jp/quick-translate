import SwiftUI

final class AppSettings: ObservableObject {
    @AppStorage("apiEndpoint") var apiEndpoint = "http://localhost:1234/v1"
    @AppStorage("apiKey") var apiKey = ""
    @AppStorage("modelName") var modelName = "google/gemma-4-26b-a4b"
    @AppStorage("targetLanguage") var targetLanguage = "Japanese"
    @AppStorage("debounceSeconds") var debounceSeconds = 2.0
}
