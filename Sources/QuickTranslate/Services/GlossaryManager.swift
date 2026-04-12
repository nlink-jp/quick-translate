import Foundation

struct GlossaryEntry: Codable, Identifiable {
    var id = UUID()
    var source: String
    var target: String

    enum CodingKeys: String, CodingKey {
        case source, target
    }
}

enum GlossaryManager {
    static let glossaryURL: URL = {
        guard let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask
        ).first else {
            // Fallback to tmp if Application Support is unavailable
            return FileManager.default.temporaryDirectory
                .appendingPathComponent("QuickTranslate/glossary.json")
        }
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
