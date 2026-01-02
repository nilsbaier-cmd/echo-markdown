import Foundation

final class TranscriptionUseCase: TranscriptionUseCaseProtocol {
    private let assemblyAIService: AssemblyAIServiceProtocol

    init(assemblyAIService: AssemblyAIServiceProtocol) {
        self.assemblyAIService = assemblyAIService
    }

    func transcribe(_ recording: Recording) async throws -> String {
        guard let audioURL = recording.audioURL else {
            throw TranscriptionError.noAudioFile
        }

        recording.status = .uploading
        let transcriptId = try await assemblyAIService.uploadAudio(audioURL)

        recording.status = .transcribing

        // Poll for completion
        var transcript: AssemblyAITranscript
        repeat {
            try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
            transcript = try await assemblyAIService.getTranscript(id: transcriptId)
        } while transcript.status == "queued" || transcript.status == "processing"

        guard transcript.status == "completed", let text = transcript.text else {
            throw TranscriptionError.transcriptionFailed
        }

        recording.transcript = text
        recording.status = .transcribed

        return text
    }
}

enum TranscriptionError: Error {
    case noAudioFile
    case transcriptionFailed
}
