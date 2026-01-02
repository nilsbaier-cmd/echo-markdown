import Foundation
import AVFoundation

enum AudioError: Error {
    case recordingFailed
    case playbackFailed
    case permissionDenied
    case noActiveRecording
}

final class AudioService: NSObject, AudioServiceProtocol {
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var currentRecordingURL: URL?

    override init() {
        super.init()
    }

    func startRecording() async throws -> URL {
        let session = AVAudioSession.sharedInstance()

        // Check permission
        let permissionGranted = await withCheckedContinuation { continuation in
            session.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }

        guard permissionGranted else {
            throw AudioError.permissionDenied
        }

        try session.setCategory(.playAndRecord, mode: .default)
        try session.setActive(true)

        let url = getRecordingURL()
        currentRecordingURL = url

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        audioRecorder = try AVAudioRecorder(url: url, settings: settings)
        audioRecorder?.isMeteringEnabled = true
        audioRecorder?.record()

        return url
    }

    func stopRecording() async throws {
        guard let recorder = audioRecorder, recorder.isRecording else {
            throw AudioError.noActiveRecording
        }
        recorder.stop()
        audioRecorder = nil
    }

    func getAveragePower() -> Float {
        audioRecorder?.updateMeters()
        return audioRecorder?.averagePower(forChannel: 0) ?? -160
    }

    func playAudio(url: URL) async throws {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            throw AudioError.playbackFailed
        }
    }

    func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
    }

    private func getRecordingURL() -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "recording_\(Date().timeIntervalSince1970).m4a"
        return documentsPath.appendingPathComponent(fileName)
    }
}
