import Foundation
import SwiftUI
import Combine

@MainActor
final class RecordingViewModel: ObservableObject {
    @Published var isRecording: Bool = false
    @Published var currentRecording: Recording?
    @Published var audioLevels: [Float] = []
    @Published var recordingDuration: TimeInterval = 0
    @Published var errorMessage: String?

    private let recordingUseCase: RecordingUseCaseProtocol
    private let audioService: AudioServiceProtocol
    private let hapticService: HapticServiceProtocol

    private var levelTimer: Timer?
    private var durationTimer: Timer?
    private var startTime: Date?

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
            startTime = Date()
            startMonitoring()
        } catch {
            errorMessage = "Aufnahme konnte nicht gestartet werden: \(error.localizedDescription)"
            hapticService.notification(.error)
        }
    }

    func stopRecording() async {
        hapticService.impact(.heavy)
        stopMonitoring()

        guard let recording = currentRecording else { return }

        do {
            currentRecording = try await recordingUseCase.stopRecording(id: recording.id)
            isRecording = false
        } catch {
            errorMessage = "Aufnahme konnte nicht gestoppt werden: \(error.localizedDescription)"
            hapticService.notification(.error)
        }
    }

    // MARK: - Private

    private func startMonitoring() {
        // Audio level monitoring (60 FPS)
        levelTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                let level = self.audioService.getAveragePower()
                // Normalize: -160dB to 0dB → 0.0 to 1.0
                let normalized = (level + 160) / 160
                self.audioLevels.append(max(0, min(1, normalized)))

                // Keep only last 50 values for performance
                if self.audioLevels.count > 50 {
                    self.audioLevels.removeFirst()
                }
            }
        }

        // Duration timer (1 second interval)
        durationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, let start = self.startTime else { return }
                self.recordingDuration = Date().timeIntervalSince(start)
            }
        }
    }

    private func stopMonitoring() {
        levelTimer?.invalidate()
        levelTimer = nil
        durationTimer?.invalidate()
        durationTimer = nil
        audioLevels = []
        recordingDuration = 0
        startTime = nil
    }

    var formattedDuration: String {
        let minutes = Int(recordingDuration) / 60
        let seconds = Int(recordingDuration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
