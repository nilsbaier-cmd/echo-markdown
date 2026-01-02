import Foundation

struct Recording: Identifiable, Codable {
    let id: UUID
    let audioURL: URL
    var transcript: String?
    let timestamp: Date
    var status: RecordingStatus
    var generatedTexts: [GeneratedText]

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
        self.status = status
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
