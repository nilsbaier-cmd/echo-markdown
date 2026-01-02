import Foundation

final class ExportUseCase: ExportUseCaseProtocol {
    private let fileExportService: FileExportServiceProtocol
    private let settingsRepository: SettingsRepositoryProtocol

    init(fileExportService: FileExportServiceProtocol, settingsRepository: SettingsRepositoryProtocol) {
        self.fileExportService = fileExportService
        self.settingsRepository = settingsRepository
    }

    func exportToVault(text: String, filename: String) async throws {
        guard let bookmark = settingsRepository.getVaultBookmark() else {
            throw ExportError.noVaultConfigured
        }

        let markdownFilename = filename.hasSuffix(".md") ? filename : "\(filename).md"
        try await fileExportService.saveToVault(content: text, filename: markdownFilename, vaultBookmark: bookmark)
    }

    func shareText(_ text: String) -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("Echo_Export_\(Date().timeIntervalSince1970).md")
        try? text.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }
}

enum ExportError: Error {
    case noVaultConfigured
}
