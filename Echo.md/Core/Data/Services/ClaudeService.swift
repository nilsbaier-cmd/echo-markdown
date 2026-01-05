import Foundation

// MARK: - Claude Error

enum ClaudeError: Error, LocalizedError {
    case requestFailed(statusCode: Int)
    case invalidResponse
    case networkError(Error)
    case apiKeyMissing

    var errorDescription: String? {
        switch self {
        case .requestFailed(let code):
            return "API-Anfrage fehlgeschlagen (Status: \(code))"
        case .invalidResponse:
            return "Ungueltige API-Antwort"
        case .networkError(let error):
            return "Netzwerkfehler: \(error.localizedDescription)"
        case .apiKeyMissing:
            return "Claude API-Key fehlt"
        }
    }
}

// MARK: - Claude Service

final class ClaudeService: ClaudeServiceProtocol {
    private let apiKey: String
    private let baseURL = "https://api.anthropic.com/v1/messages"
    private let model = "claude-sonnet-4-5-20250929"

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    // MARK: - Initial Questions

    func generateReflectQuestions(transcript: String) async throws -> [String] {
        let prompt = """
        Du bist ein einfuehlsamer Gespraechspartner, der hilft, Gedanken zu vertiefen.

        Analysiere dieses Transkript einer Sprachnotiz und stelle genau 2-3 klaerende Rueckfragen.

        Regeln fuer die Fragen:
        - Konkret auf den Inhalt eingehen (keine generischen Fragen)
        - Zum Nachdenken anregen, ohne zu belehren
        - Kurz und praegnant (max. 1-2 Saetze pro Frage)
        - Natuerlich und gespraechsnah formulieren

        Gute Beispiele:
        - "Kannst du das mit einem konkreten Beispiel erklaeren?"
        - "Was genau meinst du mit [Begriff aus Transkript]?"
        - "Wie wuerdest du das in der Praxis umsetzen?"

        Transkript:
        ---
        \(transcript)
        ---

        Antworte NUR mit den Fragen, eine pro Zeile, ohne Nummerierung oder Aufzaehlungszeichen.
        """

        let response = try await sendMessage(prompt, maxTokens: 512)
        return parseQuestions(response)
    }

    // MARK: - Follow-up Questions

    func generateFollowUpQuestions(
        originalTranscript: String,
        previousQA: [(question: String, answer: String)]
    ) async throws -> [String] {

        let qaContext = previousQA.enumerated().map { index, qa in
            """
            Frage \(index + 1): \(qa.question)
            Antwort \(index + 1): \(qa.answer)
            """
        }.joined(separator: "\n\n")

        let prompt = """
        Du fuehrst einen natuerlichen Reflexionsdialog. Basierend auf der neuesten Antwort, stelle 2-3 weitere vertiefende Fragen.

        Urspruengliches Transkript:
        ---
        \(originalTranscript)
        ---

        Bisheriger Dialog:
        ---
        \(qaContext)
        ---

        Regeln fuer die neuen Fragen:
        - Direkt auf die letzte Antwort eingehen
        - Neue Aspekte aufgreifen, die noch nicht besprochen wurden
        - Nicht bereits gestellte Fragen wiederholen
        - Konkretisierung oder Beispiele anregen
        - Natuerlich und im Gespraechsfluss bleiben

        Antworte NUR mit den neuen Fragen, eine pro Zeile, ohne Nummerierung.
        Falls das Thema erschoepfend behandelt wurde, antworte exakt mit: DIALOG_ABGESCHLOSSEN
        """

        let response = try await sendMessage(prompt, maxTokens: 512)

        if response.contains("DIALOG_ABGESCHLOSSEN") {
            return []
        }

        return parseQuestions(response)
    }

    // MARK: - Integrate Answers

    func integrateContentWithAnswers(
        originalTranscript: String,
        qaHistory: [(question: String, answer: String)]
    ) async throws -> String {

        guard !qaHistory.isEmpty else {
            return originalTranscript
        }

        let qaContext = qaHistory.map { qa in
            """
            F: \(qa.question)
            A: \(qa.answer)
            """
        }.joined(separator: "\n\n")

        let prompt = """
        Reichere das folgende Transkript mit den zusaetzlichen Informationen aus dem Dialog an.

        Urspruengliches Transkript:
        ---
        \(originalTranscript)
        ---

        Zusaetzliche Informationen aus Rueckfragen:
        ---
        \(qaContext)
        ---

        Aufgabe:
        1. Integriere die Informationen aus den Antworten natuerlich in den Text
        2. Behalte den urspruenglichen Inhalt vollstaendig bei
        3. Fuege neue Details an passenden Stellen ein
        4. Halte den Schreibstil konsistent
        5. Der Text soll wie ein zusammenhaengender Gedankenfluss wirken
        6. KEINE Markierungen wie "[ergaenzt]" oder aehnliches

        Gib nur das angereicherte Transkript aus, ohne Kommentare.
        """

        return try await sendMessage(prompt, maxTokens: 2048)
    }

    // MARK: - Text Generation

    func generateText(transcript: String, style: String) async throws -> String {
        let styleInstructions: String
        switch style.lowercased() {
        case "notiz":
            styleInstructions = "Eine informelle, persoenliche Notiz. Kurze Saetze, direkte Sprache."
        case "zusammenfassung":
            styleInstructions = "Eine praegnante Zusammenfassung der Kernpunkte. Strukturiert mit klaren Absaetzen."
        case "artikel":
            styleInstructions = "Ein ausformulierter Artikel mit Einleitung, Hauptteil und Schluss. Professioneller Ton."
        case "stichpunkte":
            styleInstructions = "Strukturierte Stichpunkte mit Hauptpunkten und Unterpunkten. Knapp und uebersichtlich."
        default:
            styleInstructions = "Einen gut strukturierten, lesbaren Text."
        }

        let prompt = """
        Wandle das folgende Transkript in einen strukturierten Text um.

        Gewuenschter Stil: \(style)
        Anweisungen: \(styleInstructions)

        Transkript:
        ---
        \(transcript)
        ---

        Wichtig:
        - Behalte alle wichtigen Informationen bei
        - Strukturiere mit Absaetzen oder Aufzaehlungen wo sinnvoll
        - Korrigiere offensichtliche Sprachfehler aus der Transkription
        - Der Text soll gut lesbar und verstaendlich sein
        """

        return try await sendMessage(prompt, maxTokens: 2048)
    }

    // MARK: - Private Helpers

    private func sendMessage(_ content: String, maxTokens: Int = 1024) async throws -> String {
        guard !apiKey.isEmpty else {
            throw ClaudeError.apiKeyMissing
        }

        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": model,
            "max_tokens": maxTokens,
            "messages": [
                ["role": "user", "content": content]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw ClaudeError.requestFailed(statusCode: 0)
            }

            guard httpResponse.statusCode == 200 else {
                #if DEBUG
                if let errorBody = String(data: data, encoding: .utf8) {
                    print("Claude API Error (\(httpResponse.statusCode)): \(errorBody)")
                }
                #endif
                throw ClaudeError.requestFailed(statusCode: httpResponse.statusCode)
            }

            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let contentArray = json["content"] as? [[String: Any]],
                  let firstContent = contentArray.first,
                  let text = firstContent["text"] as? String else {
                throw ClaudeError.invalidResponse
            }

            return text.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch let error as ClaudeError {
            throw error
        } catch {
            throw ClaudeError.networkError(error)
        }
    }

    private func parseQuestions(_ response: String) -> [String] {
        response
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { line in
                var cleanLine = line
                // Remove bullet points
                if cleanLine.hasPrefix("- ") {
                    cleanLine = String(cleanLine.dropFirst(2))
                }
                // Remove numbering (1. 2. etc.)
                if let firstChar = cleanLine.first,
                   firstChar.isNumber,
                   cleanLine.dropFirst().first == "." {
                    cleanLine = String(cleanLine.dropFirst(3))
                }
                return cleanLine.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .filter { !$0.isEmpty }
    }
}
