import Foundation

struct GeneratedText: Identifiable, Codable {
    let id: UUID
    let content: String
    let style: TextStyle
    let timestamp: Date

    init(
        id: UUID = UUID(),
        content: String,
        style: TextStyle,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.content = content
        self.style = style
        self.timestamp = timestamp
    }
}

enum TextStyle: String, Codable, CaseIterable {
    case formal
    case informal
    case obsidian

    var displayName: String {
        switch self {
        case .formal: return "Formell"
        case .informal: return "Informell"
        case .obsidian: return "Obsidian-Notiz"
        }
    }
}
