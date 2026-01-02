import Foundation

enum AssemblyAIError: Error {
    case invalidResponse
    case networkError(Error)
    case uploadFailed
    case transcriptionFailed
    case timeout
}

final class AssemblyAIService: AssemblyAIServiceProtocol {
    private let apiKey: String
    private let baseURL = "https://api.assemblyai.com/v2"

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    // MARK: - Upload Audio

    func uploadAudio(_ url: URL) async throws -> String {
        // Step 1: Upload audio file
        let uploadURL = "\(baseURL)/upload"
        let audioData = try Data(contentsOf: url)

        var uploadRequest = URLRequest(url: URL(string: uploadURL)!)
        uploadRequest.httpMethod = "POST"
        uploadRequest.setValue(apiKey, forHTTPHeaderField: "authorization")
        uploadRequest.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        uploadRequest.httpBody = audioData

        let (uploadData, _) = try await URLSession.shared.data(for: uploadRequest)

        struct UploadResponse: Codable {
            let upload_url: String
        }

        let uploadResponse = try JSONDecoder().decode(UploadResponse.self, from: uploadData)

        // Step 2: Request transcription
        let transcriptURL = "\(baseURL)/transcript"
        var transcriptRequest = URLRequest(url: URL(string: transcriptURL)!)
        transcriptRequest.httpMethod = "POST"
        transcriptRequest.setValue(apiKey, forHTTPHeaderField: "authorization")
        transcriptRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        struct TranscriptRequestBody: Codable {
            let audio_url: String
            let language_code: String
        }

        let body = TranscriptRequestBody(
            audio_url: uploadResponse.upload_url,
            language_code: "de"  // German language
        )
        transcriptRequest.httpBody = try JSONEncoder().encode(body)

        let (transcriptData, _) = try await URLSession.shared.data(for: transcriptRequest)
        let transcriptResponse = try JSONDecoder().decode(AssemblyAITranscript.self, from: transcriptData)

        return transcriptResponse.id
    }

    // MARK: - Get Transcript

    func getTranscript(id: String) async throws -> AssemblyAITranscript {
        let url = "\(baseURL)/transcript/\(id)"
        var request = URLRequest(url: URL(string: url)!)
        request.setValue(apiKey, forHTTPHeaderField: "authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(AssemblyAITranscript.self, from: data)
    }
}
