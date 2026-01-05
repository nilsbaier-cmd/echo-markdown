import Foundation
import Combine
import SwiftUI

// MARK: - Recording View Model

@MainActor
final class RecordingViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var isRecording = false
    @Published var currentPower: Float = -160
    @Published var recordingDuration: TimeInterval = 0
    @Published var errorMessage: String?

    // Navigation properties for automatic flow
    @Published var transcribedRecording: Recording?
    @Published var shouldNavigateToReflect = false
    @Published var isTranscribing = false

    // MARK: - Dependencies

    private let recordingUseCase: RecordingUseCaseProtocol
    private let transcriptionUseCase: TranscriptionUseCaseProtocol
    private let audioService: AudioServiceProtocol
    private let hapticService: HapticServiceProtocol

    // MARK: - Private State

    private var currentRecording: Recording?
    private var timer: Timer?

    // MARK: - Init

    init(
        recordingUseCase: RecordingUseCaseProtocol,
        transcriptionUseCase: TranscriptionUseCaseProtocol,
        audioService: AudioServiceProtocol,
        hapticService: HapticServiceProtocol
    ) {
        self.recordingUseCase = recordingUseCase
        self.transcriptionUseCase = transcriptionUseCase
        self.audioService = audioService
        self.hapticService = hapticService
    }

    // MARK: - Recording Methods

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

            // Start transcription and wait for it to complete
            isTranscribing = true
            await transcribeRecording(recording)
        } catch {
            errorMessage = "Aufnahme konnte nicht gestoppt werden: \(error.localizedDescription)"
            hapticService.notification(.error)
        }
    }

    // MARK: - Transcription

    private func transcribeRecording(_ recording: Recording) async {
        do {
            print("🎯 [RecordingVM] Starting transcription...")
            _ = try await transcriptionUseCase.transcribe(recording)

            // Transcription successful - trigger navigation to Reflect
            print("✅ [RecordingVM] Transcription successful!")
            print("🔄 [RecordingVM] Setting shouldNavigateToReflect = true")
            isTranscribing = false
            transcribedRecording = recording
            shouldNavigateToReflect = true
            print("📍 [RecordingVM] shouldNavigateToReflect is now: \(shouldNavigateToReflect)")
            hapticService.notification(.success)
        } catch {
            isTranscribing = false
            errorMessage = "Transkription fehlgeschlagen: \(error.localizedDescription)"
            hapticService.notification(.error)
            print("❌ [RecordingVM] Transkription fehlgeschlagen: \(error.localizedDescription)")
        }
    }

    // MARK: - Navigation Reset

    func resetNavigation() {
        shouldNavigateToReflect = false
        transcribedRecording = nil
    }

    // MARK: - Private Helpers

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
