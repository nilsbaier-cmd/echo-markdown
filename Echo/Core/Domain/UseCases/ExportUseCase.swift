import Foundation
import UIKit

final class ExportUseCase: ExportUseCaseProtocol {
    private let fileExportService: FileExportServiceProtocol
    private let settingsRepository: SettingsRepositoryProtocol

    init(fileExportService: FileExportServiceProtocol, settingsRepository: SettingsRepositoryProtocol) {
        self.fileExportService = fileExportService
        self.settingsRepository = settingsRepository
    }

    func exportToObsidian(text: String, filename: String) async throws {
        guard let bookmark = settingsRepository.getVaultBookmark() else {
            throw ExportUseCaseError.noVaultConfigured
        }

        let sanitizedFilename = sanitizeFilename(filename)
        try await fileExportService.saveToVault(
            content: text,
            filename: sanitizedFilename,
            vaultBookmark: bookmark
        )
    }

    func shareText(text: String) -> UIActivityViewController {
        let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        return activityVC
    }

    // MARK: - Private

    private func sanitizeFilename(_ filename: String) -> String {
        var result = filename

        // Remove invalid characters
        let invalidCharacters = CharacterSet(charactersIn: ":/\\?%*|\"<>")
        result = result.components(separatedBy: invalidCharacters).joined(separator: "-")

        // Ensure .md extension
        if !result.hasSuffix(".md") {
            result += ".md"
        }

        return result
    }
}

enum ExportUseCaseError: Error {
    case noVaultConfigured
}
