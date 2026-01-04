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
    /// Generate initial questions for a transcript
    func generateQuestions(for transcript: String) async throws -> [ReflectQuestion]

    /// Generate follow-up questions based on answered questions
    func generateFollowUpQuestions(
        originalTranscript: String,
        answeredQuestions: [ReflectQuestion]
    ) async throws -> [ReflectQuestion]

    /// Integrate answers into the original transcript
    func integrateAnswers(
        originalTranscript: String,
        answeredQuestions: [ReflectQuestion]
    ) async throws -> String
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
