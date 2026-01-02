import Foundation

final class TranscriptionUseCase: TranscriptionUseCaseProtocol {
    private let assemblyAIService: AssemblyAIServiceProtocol
    private let maxPollingAttempts = 60
    private let pollingInterval: UInt64 = 2_000_000_000 // 2 seconds in nanoseconds

    init(assemblyAIService: AssemblyAIServiceProtocol) {
        self.assemblyAIService = assemblyAIService
    }

    func transcribe(recording: Recording) async throws -> String {
        // Upload audio and get transcript ID
        let transcriptID = try await assemblyAIService.uploadAudio(recording.audioURL)

        // Poll for completion
        for _ in 0..<maxPollingAttempts {
            let transcript = try await assemblyAIService.getTranscript(id: transcriptID)

            switch transcript.status {
            case "completed":
                return transcript.text ?? ""
            case "error":
                throw TranscriptionUseCaseError.transcriptionFailed
            default:
                // Still processing, wait and retry
                try await Task.sleep(nanoseconds: pollingInterval)
            }
        }

        throw TranscriptionUseCaseError.timeout
    }
}

enum TranscriptionUseCaseError: Error {
    case transcriptionFailed
    case timeout
}
