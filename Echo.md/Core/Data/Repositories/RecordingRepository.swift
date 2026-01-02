import Foundation
import SwiftData

final class RecordingRepository: RecordingRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func save(_ recording: Recording) async throws {
        modelContext.insert(recording)
        try modelContext.save()
    }

    func fetchAll() async throws -> [Recording] {
        let descriptor = FetchDescriptor<Recording>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetch(by id: UUID) async throws -> Recording? {
        let descriptor = FetchDescriptor<Recording>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }

    func delete(_ recording: Recording) async throws {
        modelContext.delete(recording)
        try modelContext.save()
    }

    func deleteAll() async throws {
        let recordings = try await fetchAll()
        for recording in recordings {
            modelContext.delete(recording)
        }
        try modelContext.save()
    }
}
