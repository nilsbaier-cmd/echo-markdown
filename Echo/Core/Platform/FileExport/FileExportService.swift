import Foundation

enum FileExportError: Error {
    case accessDenied
    case bookmarkStale
    case writeFailed
    case invalidBookmark
}

final class FileExportService: FileExportServiceProtocol {

    func saveToVault(content: String, filename: String, vaultBookmark: Data) async throws {
        var isStale = false

        guard let url = try? URL(
            resolvingBookmarkData: vaultBookmark,
            options: .withSecurityScope,
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        ) else {
            throw FileExportError.invalidBookmark
        }

        if isStale {
            throw FileExportError.bookmarkStale
        }

        guard url.startAccessingSecurityScopedResource() else {
            throw FileExportError.accessDenied
        }
        defer { url.stopAccessingSecurityScopedResource() }

        let fileURL = url.appendingPathComponent(filename)

        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            throw FileExportError.writeFailed
        }
    }

    func createBookmark(for url: URL) throws -> Data {
        try url.bookmarkData(
            options: .minimalBookmark,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
    }
}
