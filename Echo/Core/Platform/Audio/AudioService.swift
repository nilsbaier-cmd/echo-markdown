import Foundation
import AVFoundation

enum AudioError: Error {
    case permissionDenied
    case recordingFailed
    case audioSessionError
    case playbackFailed
}

final class AudioService: NSObject, AudioServiceProtocol {
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingURL: URL?

    // MARK: - Recording

    func startRecording() async throws -> URL {
        // Request permission
        let permission = await AVAudioApplication.requestRecordPermission()
        guard permission else {
            throw AudioError.permissionDenied
        }

        // Configure audio session
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.record, mode: .default)
            try session.setActive(true)
        } catch {
            throw AudioError.audioSessionError
        }

        // Create recording URL
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("\(UUID().uuidString).m4a")

        // Recording settings (optimized for speech)
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()

            recordingURL = audioFilename
            return audioFilename
        } catch {
            throw AudioError.recordingFailed
        }
    }

    func stopRecording() async throws {
        audioRecorder?.stop()
        audioRecorder = nil

        let session = AVAudioSession.sharedInstance()
        try? session.setActive(false)
    }

    func getAveragePower() -> Float {
        audioRecorder?.updateMeters()
        return audioRecorder?.averagePower(forChannel: 0) ?? -160
    }

    // MARK: - Playback

    func playAudio(url: URL) async throws {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            throw AudioError.audioSessionError
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            throw AudioError.playbackFailed
        }
    }

    func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}

// MARK: - AVAudioRecorderDelegate

extension AudioService: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("Recording finished unsuccessfully")
        }
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("Recording encode error: \(error.localizedDescription)")
        }
    }
}
