import Foundation
import Combine
import SwiftUI

@MainActor
final class RecordingViewModel: ObservableObject {
    @Published var isRecording = false
    @Published var currentPower: Float = -160
    @Published var recordingDuration: TimeInterval = 0
    @Published var errorMessage: String?

    private let recordingUseCase: RecordingUseCaseProtocol
    private let audioService: AudioServiceProtocol
    private let hapticService: HapticServiceProtocol

    private var currentRecording: Recording?
    private var timer: Timer?

    init(
        recordingUseCase: RecordingUseCaseProtocol,
        audioService: AudioServiceProtocol,
        hapticService: HapticServiceProtocol
    ) {
        self.recordingUseCase = recordingUseCase
        self.audioService = audioService
        self.hapticService = hapticService
    }

    func startRecording() async {
        hapticService.impact(.medium)

        do {
            currentRecording = try await recordingUseCase.startRecording()
            isRecording = true
            startMetering()
        } catch {
            errorMessage = "Aufnahme konnte nicht gestartet werden: \(error.localizedDescription)"
            hapticService.notification(.error)
        }
    }

    func stopRecording() async {
        hapticService.impact(.medium)
        stopMetering()

        guard let recording = currentRecording else { return }

        do {
            recording.duration = recordingDuration
            try await recordingUseCase.stopRecording(recording)
            isRecording = false
            recordingDuration = 0
            hapticService.notification(.success)
        } catch {
            errorMessage = "Aufnahme konnte nicht gestoppt werden: \(error.localizedDescription)"
            hapticService.notification(.error)
        }
    }

    private func startMetering() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                self.currentPower = self.audioService.getAveragePower()
                self.recordingDuration += 0.05
            }
        }
    }

    private func stopMetering() {
        timer?.invalidate()
        timer = nil
    }
}
