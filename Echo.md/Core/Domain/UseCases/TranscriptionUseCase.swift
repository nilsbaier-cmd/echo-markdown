import Foundation

final class TranscriptionUseCase: TranscriptionUseCaseProtocol {
    private let assemblyAIService: AssemblyAIServiceProtocol
    private let recordingRepository: RecordingRepositoryProtocol

    init(assemblyAIService: AssemblyAIServiceProtocol, recordingRepository: RecordingRepositoryProtocol) {
        self.assemblyAIService = assemblyAIService
        self.recordingRepository = recordingRepository
    }

    func transcribe(_ recording: Recording) async throws -> String {
        guard let audioURL = recording.audioURL else {
            throw TranscriptionError.noAudioFile
        }

        recording.status = .uploading
        try await recordingRepository.save(recording)

        let transcriptId = try await assemblyAIService.uploadAudio(audioURL)

        recording.status = .transcribing
        try await recordingRepository.save(recording)

        // Poll for completion
        var transcript: AssemblyAITranscript
        repeat {
            try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
            transcript = try await assemblyAIService.getTranscript(id: transcriptId)
        } while transcript.status == "queued" || transcript.status == "processing"

        guard transcript.status == "completed", let text = transcript.text else {
            recording.status = .failed
            try await recordingRepository.save(recording)
            throw TranscriptionError.transcriptionFailed
        }

        recording.transcript = text
        recording.status = .transcribed
        try await recordingRepository.save(recording)

        return text
    }
}

enum TranscriptionError: Error {
    case noAudioFile
    case transcriptionFailed
}
