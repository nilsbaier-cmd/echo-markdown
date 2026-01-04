import Foundation

enum ClaudeError: Error {
    case requestFailed
    case invalidResponse
    case networkError(Error)
}

final class ClaudeService: ClaudeServiceProtocol {
    private let apiKey: String
    private let baseURL = "https://api.anthropic.com/v1/messages"

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func generateReflectQuestions(transcript: String) async throws -> [String] {
        let prompt = """
        Analysiere das folgende Transkript einer Sprachnotiz und stelle 2-3 klärende Rückfragen,
        die helfen würden, den Inhalt besser zu verstehen oder zu vervollständigen.

        Transkript:
        \(transcript)

        Antworte nur mit den Fragen, eine pro Zeile, ohne Nummerierung.
        """

        let response = try await sendMessage(prompt)
        return response.components(separatedBy: "\n").filter { !$0.isEmpty }
    }

    func generateText(transcript: String, style: String) async throws -> String {
        let prompt = """
        Wandle das folgende Transkript in einen gut strukturierten Text um.
        Stil: \(style)

        Transkript:
        \(transcript)

        Erstelle einen flüssigen, gut lesbaren Text im gewünschten Stil.
        """

        return try await sendMessage(prompt)
    }

    private func sendMessage(_ content: String) async throws -> String {
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "claude-sonnet-4-20250514",
            "max_tokens": 1024,
            "messages": [
                ["role": "user", "content": content]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw ClaudeError.requestFailed
            }

            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let contentArray = json["content"] as? [[String: Any]],
                  let firstContent = contentArray.first,
                  let text = firstContent["text"] as? String else {
                throw ClaudeError.invalidResponse
            }

            return text
        } catch let error as ClaudeError {
            throw error
        } catch {
            throw ClaudeError.networkError(error)
        }
    }
}
