import Foundation

final class RecordingUseCase: RecordingUseCaseProtocol {
    private let audioService: AudioServiceProtocol
    private let recordingRepository: RecordingRepositoryProtocol

    init(audioService: AudioServiceProtocol, recordingRepository: RecordingRepositoryProtocol) {
        self.audioService = audioService
        self.recordingRepository = recordingRepository
    }

    func startRecording() async throws -> Recording {
        let url = try await audioService.startRecording()
        let recording = Recording(audioURL: url, status: .recording)
        try await recordingRepository.save(recording)
        return recording
    }

    func stopRecording(_ recording: Recording) async throws {
        try await audioService.stopRecording()
        recording.status = .recorded
        try await recordingRepository.save(recording)
    }
}
