import Foundation
import AVFoundation
import UIKit

// MARK: - Audio Service

protocol AudioServiceProtocol {
    func startRecording() async throws -> URL
    func stopRecording() async throws
    func getAveragePower() -> Float
    func playAudio(url: URL) async throws
    func stopPlayback()
}

// MARK: - Haptic Service

protocol HapticServiceProtocol {
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle)
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType)
}

// MARK: - Keychain Service

protocol KeychainServiceProtocol {
    func save(key: String, value: String) throws
    func get(key: String) -> String?
    func delete(key: String) throws
}

// MARK: - Core Data Service

protocol CoreDataServiceProtocol {
    func saveContext() throws
}

// MARK: - File Export Service

protocol FileExportServiceProtocol {
    func saveToVault(content: String, filename: String, vaultBookmark: Data) async throws
    func createBookmark(for url: URL) throws -> Data
}

// MARK: - AssemblyAI Service

protocol AssemblyAIServiceProtocol {
    func uploadAudio(_ url: URL) async throws -> String
    func getTranscript(id: String) async throws -> AssemblyAITranscript
}

struct AssemblyAITranscript: Codable {
    let id: String
    let status: String
    let text: String?
}

// MARK: - Claude Service

protocol ClaudeServiceProtocol {
    func generateShadowReaderQuestions(transcript: String) async throws -> [String]
    func generateText(transcript: String, style: String) async throws -> String
}
