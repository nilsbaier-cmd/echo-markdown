import Foundation

final class RecordingUseCase: RecordingUseCaseProtocol {
    private let audioService: AudioServiceProtocol
    private let recordingRepository: RecordingRepositoryProtocol

    init(audioService: AudioServiceProtocol, recordingRepository: RecordingRepositoryProtocol) {
        self.audioService = audioService
        self.recordingRepository = recordingRepository
    }

    func startRecording() async throws -> Recording {
        let audioURL = try await audioService.startRecording()
        let recording = Recording(
            audioURL: audioURL,
            timestamp: Date(),
            status: .recorded
        )
        try await recordingRepository.save(recording)
        return recording
    }

    func stopRecording(id: UUID) async throws -> Recording {
        try await audioService.stopRecording()
        guard var recording = try await recordingRepository.fetch(id: id) else {
            throw RecordingUseCaseError.recordingNotFound
        }
        recording.status = .recorded
        try await recordingRepository.update(recording)
        return recording
    }

    func deleteRecording(id: UUID) async throws {
        try await recordingRepository.delete(id: id)
    }
}

enum RecordingUseCaseError: Error {
    case recordingNotFound
}
