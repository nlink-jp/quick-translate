import Foundation

struct GlossaryEntry: Codable {
    let source: String
    let target: String
}

enum GlossaryManager {
    static let glossaryURL: URL = {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask
        ).first!
        let dir = appSupport.appendingPathComponent("QuickTranslate", isDirectory: true)
        return dir.appendingPathComponent("glossary.json")
    }()

    static func load() -> [GlossaryEntry] {
        guard FileManager.default.fileExists(atPath: glossaryURL.path) else {
            return []
        }
        do {
            let data = try Data(contentsOf: glossaryURL)
            return try JSONDecoder().decode([GlossaryEntry].self, from: data)
        } catch {
            return []
        }
    }

    static func save(_ entries: [GlossaryEntry]) throws {
        let dir = glossaryURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let data = try JSONEncoder().encode(entries)
        try data.write(to: glossaryURL)
    }
}
