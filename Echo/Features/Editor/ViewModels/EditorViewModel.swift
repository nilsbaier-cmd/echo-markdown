import Foundation
import SwiftUI
import UIKit

@MainActor
final class EditorViewModel: ObservableObject {
    @Published var generatedText: String = ""
    @Published var selectedStyle: TextStyle = .obsidian
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showShareSheet: Bool = false

    private let textGenerationUseCase: TextGenerationUseCaseProtocol
    private let exportUseCase: ExportUseCaseProtocol

    private var transcript: String = ""

    init(
        textGenerationUseCase: TextGenerationUseCaseProtocol,
        exportUseCase: ExportUseCaseProtocol
    ) {
        self.textGenerationUseCase = textGenerationUseCase
        self.exportUseCase = exportUseCase
    }

    func setTranscript(_ transcript: String) {
        self.transcript = transcript
        self.generatedText = transcript
    }

    func generateText() async {
        guard !transcript.isEmpty else { return }

        isLoading = true
        errorMessage = nil

        do {
            generatedText = try await textGenerationUseCase.generateText(
                transcript: transcript,
                style: selectedStyle
            )
        } catch {
            errorMessage = "Textgenerierung fehlgeschlagen: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func exportToObsidian() async {
        guard !generatedText.isEmpty else { return }

        isLoading = true
        errorMessage = nil

        let filename = generateFilename()

        do {
            try await exportUseCase.exportToObsidian(text: generatedText, filename: filename)
        } catch ExportUseCaseError.noVaultConfigured {
            errorMessage = "Kein Obsidian-Vault konfiguriert. Bitte in den Einstellungen festlegen."
        } catch {
            errorMessage = "Export fehlgeschlagen: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func share() -> UIActivityViewController {
        exportUseCase.shareText(text: generatedText)
    }

    // MARK: - Private

    private func generateFilename() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HHmmss"
        let timestamp = dateFormatter.string(from: Date())
        return "Echo-Notiz_\(timestamp).md"
    }
}
