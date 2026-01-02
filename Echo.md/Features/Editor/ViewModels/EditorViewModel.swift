import Foundation
import Combine

@MainActor
final class EditorViewModel: ObservableObject {
    @Published var generatedText: String = ""
    @Published var selectedStyle: TextStyle = .note
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let textGenerationUseCase: TextGenerationUseCaseProtocol
    private let exportUseCase: ExportUseCaseProtocol

    init(
        textGenerationUseCase: TextGenerationUseCaseProtocol,
        exportUseCase: ExportUseCaseProtocol
    ) {
        self.textGenerationUseCase = textGenerationUseCase
        self.exportUseCase = exportUseCase
    }

    func generateText(from transcript: String) async {
        isLoading = true
        do {
            generatedText = try await textGenerationUseCase.generate(from: transcript, style: selectedStyle)
        } catch {
            errorMessage = "Fehler bei der Textgenerierung: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func exportToVault(filename: String) async {
        do {
            try await exportUseCase.exportToVault(text: generatedText, filename: filename)
        } catch {
            errorMessage = "Fehler beim Export: \(error.localizedDescription)"
        }
    }

    func getShareURL() -> URL {
        exportUseCase.shareText(generatedText)
    }
}
