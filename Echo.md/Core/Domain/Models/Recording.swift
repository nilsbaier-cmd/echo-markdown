import Foundation
import SwiftData

@Model
final class Recording {
    var id: UUID
    var createdAt: Date
    var audioURL: URL?
    var duration: TimeInterval
    var transcript: String?
    var status: RecordingStatus

    @Relationship(deleteRule: .cascade)
    var generatedTexts: [GeneratedText]?

    @Relationship(deleteRule: .cascade)
    var reflectSession: ReflectSession?

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        audioURL: URL? = nil,
        duration: TimeInterval = 0,
        transcript: String? = nil,
        status: RecordingStatus = .recording
    ) {
        self.id = id
        self.createdAt = createdAt
        self.audioURL = audioURL
        self.duration = duration
        self.transcript = transcript
        self.status = status
        self.generatedTexts = []
    }
}

enum RecordingStatus: String, Codable {
    case recording
    case recorded
    case uploading
    case transcribing
    case transcribed
    case processing
    case completed
    case failed
}
