import Foundation
import SwiftData

@Model
final class Recording {
    @Attribute(.unique) var id: UUID
    var audioURL: URL
    var transcript: String?
    var timestamp: Date
    var statusRawValue: String
    @Relationship(deleteRule: .cascade) var generatedTexts: [GeneratedText]

    var status: RecordingStatus {
        get { RecordingStatus(rawValue: statusRawValue) ?? .recorded }
        set { statusRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        audioURL: URL,
        transcript: String? = nil,
        timestamp: Date = Date(),
        status: RecordingStatus = .recorded,
        generatedTexts: [GeneratedText] = []
    ) {
        self.id = id
        self.audioURL = audioURL
        self.transcript = transcript
        self.timestamp = timestamp
        self.statusRawValue = status.rawValue
        self.generatedTexts = generatedTexts
    }
}

enum RecordingStatus: String, Codable {
    case recorded
    case transcribing
    case transcribed
    case analyzed
    case exported
}
