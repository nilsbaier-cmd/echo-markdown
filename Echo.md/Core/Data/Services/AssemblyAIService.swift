import Foundation

enum AssemblyAIError: Error {
    case uploadFailed
    case transcriptionFailed
    case invalidResponse
    case networkError(Error)
}

final class AssemblyAIService: AssemblyAIServiceProtocol {
    private let apiKey: String
    private let baseURL = "https://api.assemblyai.com/v2"

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func uploadAudio(_ url: URL) async throws -> String {
        let uploadURL = URL(string: "\(baseURL)/upload")!

        var request = URLRequest(url: uploadURL)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")

        let audioData = try Data(contentsOf: url)

        do {
            let (data, response) = try await URLSession.shared.upload(for: request, from: audioData)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw AssemblyAIError.uploadFailed
            }

            let json = try JSONDecoder().decode([String: String].self, from: data)
            guard let uploadUrl = json["upload_url"] else {
                throw AssemblyAIError.invalidResponse
            }

            // Now create transcription
            return try await createTranscription(audioUrl: uploadUrl)
        } catch let error as AssemblyAIError {
            throw error
        } catch {
            throw AssemblyAIError.networkError(error)
        }
    }

    private func createTranscription(audioUrl: String) async throws -> String {
        let transcriptURL = URL(string: "\(baseURL)/transcript")!

        var request = URLRequest(url: transcriptURL)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["audio_url": audioUrl, "language_code": "de"]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, _) = try await URLSession.shared.data(for: request)
        let transcript = try JSONDecoder().decode(AssemblyAITranscript.self, from: data)

        return transcript.id
    }

    func getTranscript(id: String) async throws -> AssemblyAITranscript {
        let url = URL(string: "\(baseURL)/transcript/\(id)")!

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(AssemblyAITranscript.self, from: data)
    }
}
