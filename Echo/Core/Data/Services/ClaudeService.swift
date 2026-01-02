import Foundation

enum ClaudeError: Error {
    case invalidAPIKey
    case rateLimitExceeded
    case apiError(statusCode: Int)
    case parsingFailed
    case networkError(Error)
}

final class ClaudeService: ClaudeServiceProtocol {
    private let apiKey: String
    private let baseURL = "https://api.anthropic.com/v1"
    private let model = "claude-sonnet-4-20250514"

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    // MARK: - Shadow Reader Questions

    func generateShadowReaderQuestions(transcript: String) async throws -> [String] {
        let prompt = """
        Analysiere folgendes Transkript einer Sprachaufnahme und generiere 2-3 intelligente Rückfragen,
        die helfen, den Gedanken zu vertiefen und zu präzisieren.

        Die Fragen sollten:
        - Konkret und auf den Inhalt bezogen sein
        - Helfen, unklare Punkte zu klären
        - Zum Weiterdenken anregen

        Transkript:
        \(transcript)

        Gib NUR die Fragen zurück, nummeriert (1., 2., 3.), ohne weitere Erklärungen.
        """

        let response = try await callClaude(prompt: prompt)
        return parseQuestions(from: response)
    }

    // MARK: - Text Generation

    func generateText(transcript: String, style: String) async throws -> String {
        let styleDescription: String
        switch style.lowercased() {
        case "formal":
            styleDescription = "einen formellen, professionellen Schreibstil"
        case "informal":
            styleDescription = "einen lockeren, persönlichen Schreibstil"
        case "obsidian":
            styleDescription = """
            eine Obsidian-Notiz mit:
            - Frontmatter (tags, created, aliases)
            - Internen Links [[Begriff]] wo sinnvoll
            - Strukturierten Überschriften
            - Bullet Points für Listen
            """
        default:
            styleDescription = "einen neutralen Schreibstil"
        }

        let prompt = """
        Wandle folgendes Sprach-Transkript in einen gut strukturierten Text um.

        Verwende \(styleDescription).

        Transkript:
        \(transcript)

        Erstelle daraus einen sauberen Markdown-Text. Korrigiere Grammatik und Satzbau,
        aber behalte den ursprünglichen Inhalt und die Aussagen bei.
        """

        return try await callClaude(prompt: prompt)
    }

    // MARK: - Private

    private func callClaude(prompt: String) async throws -> String {
        let url = URL(string: "\(baseURL)/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        struct ClaudeRequest: Codable {
            let model: String
            let max_tokens: Int
            let messages: [Message]

            struct Message: Codable {
                let role: String
                let content: String
            }
        }

        let body = ClaudeRequest(
            model: model,
            max_tokens: 4096,
            messages: [
                .init(role: "user", content: prompt)
            ]
        )

        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 200...299:
                break
            case 401:
                throw ClaudeError.invalidAPIKey
            case 429:
                throw ClaudeError.rateLimitExceeded
            default:
                throw ClaudeError.apiError(statusCode: httpResponse.statusCode)
            }
        }

        struct ClaudeResponse: Codable {
            let content: [Content]

            struct Content: Codable {
                let text: String
            }
        }

        let claudeResponse = try JSONDecoder().decode(ClaudeResponse.self, from: data)
        return claudeResponse.content.first?.text ?? ""
    }

    private func parseQuestions(from text: String) -> [String] {
        let lines = text.components(separatedBy: "\n")
        return lines
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { line in
                guard let first = line.first else { return false }
                return first.isNumber
            }
            .map { line in
                // Remove numbering prefix like "1. " or "1) "
                var result = line
                if let range = line.range(of: #"^\d+[\.\)]\s*"#, options: .regularExpression) {
                    result = String(line[range.upperBound...])
                }
                return result
            }
    }
}
