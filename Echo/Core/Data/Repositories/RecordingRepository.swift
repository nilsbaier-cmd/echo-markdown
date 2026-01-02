import Foundation
import SwiftData

@MainActor
final class RecordingRepository: RecordingRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func save(_ recording: Recording) async throws {
        modelContext.insert(recording)
        try modelContext.save()
    }

    func fetch(id: UUID) async throws -> Recording? {
        let descriptor = FetchDescriptor<Recording>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }

    func fetchAll() async throws -> [Recording] {
        let descriptor = FetchDescriptor<Recording>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func delete(id: UUID) async throws {
        if let recording = try await fetch(id: id) {
            modelContext.delete(recording)
            try modelContext.save()
        }
    }

    func update(_ recording: Recording) async throws {
        try modelContext.save()
    }
}
