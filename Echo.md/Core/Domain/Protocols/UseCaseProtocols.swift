import Foundation

// MARK: - Recording Use Case

protocol RecordingUseCaseProtocol {
    func startRecording() async throws -> Recording
    func stopRecording(_ recording: Recording) async throws
}

// MARK: - Fetch Recordings Use Case

protocol FetchRecordingsUseCaseProtocol {
    func execute() async throws -> [Recording]
}

// MARK: - Transcription Use Case

protocol TranscriptionUseCaseProtocol {
    func transcribe(_ recording: Recording) async throws -> String
}

// MARK: - Reflect Use Case

protocol ReflectUseCaseProtocol {
    func generateQuestions(for transcript: String) async throws -> [ReflectQuestion]
}

// MARK: - Text Generation Use Case

protocol TextGenerationUseCaseProtocol {
    func generate(from transcript: String, style: TextStyle) async throws -> String
}

// MARK: - Export Use Case

protocol ExportUseCaseProtocol {
    func exportToVault(text: String, filename: String) async throws
    func shareText(_ text: String) -> URL
}
