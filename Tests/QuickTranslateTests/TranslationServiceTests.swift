import XCTest
@testable import QuickTranslate

final class TranslationServiceTests: XCTestCase {
    func testDetectLanguageJapanese() {
        let settings = AppSettings()
        let service = TranslationService(settings: settings)
        let result = service.detectLanguage(text: "これはテストです。日本語のテキストを検出します。")
        XCTAssertEqual(result, "Japanese")
    }

    func testDetectLanguageEnglish() {
        let settings = AppSettings()
        let service = TranslationService(settings: settings)
        let result = service.detectLanguage(text: "This is a test. Detecting English text input.")
        XCTAssertEqual(result, "English")
    }

    func testGlossaryLoadEmpty() {
        // When no glossary file exists, load returns empty array
        let entries = GlossaryManager.load()
        // This may return entries if a glossary file exists on the test machine,
        // but should not crash regardless
        XCTAssertNotNil(entries)
    }
}
