import Foundation
import UIKit

// MARK: - Recording Use Case

protocol RecordingUseCaseProtocol {
    func startRecording() async throws -> Recording
    func stopRecording(id: UUID) async throws -> Recording
    func deleteRecording(id: UUID) async throws
}

// MARK: - Fetch Recordings Use Case

protocol FetchRecordingsUseCaseProtocol {
    func execute() async throws -> [Recording]
}

// MARK: - Transcription Use Case

protocol TranscriptionUseCaseProtocol {
    func transcribe(recording: Recording) async throws -> String
}

// MARK: - Shadow Reader Use Case

protocol ShadowReaderUseCaseProtocol {
    func analyzeTranscript(_ transcript: String) async throws -> [ShadowReaderQuestion]
    func answerQuestion(_ question: ShadowReaderQuestion, answer: String) async throws -> String
}

// MARK: - Text Generation Use Case

protocol TextGenerationUseCaseProtocol {
    func generateText(transcript: String, style: TextStyle) async throws -> String
}

// MARK: - Export Use Case

protocol ExportUseCaseProtocol {
    func exportToObsidian(text: String, filename: String) async throws
    func shareText(text: String) -> UIActivityViewController
}
