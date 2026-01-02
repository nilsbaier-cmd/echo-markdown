import Foundation
import CoreData

final class RecordingRepository: RecordingRepositoryProtocol {
    private let coreDataService: CoreDataServiceProtocol

    init(coreDataService: CoreDataServiceProtocol) {
        self.coreDataService = coreDataService
    }

    func save(_ recording: Recording) async throws {
        // TODO: Implement Core Data save
        // Will be implemented when Core Data model is created
    }

    func fetch(id: UUID) async throws -> Recording? {
        // TODO: Implement Core Data fetch
        return nil
    }

    func fetchAll() async throws -> [Recording] {
        // TODO: Implement Core Data fetch all
        return []
    }

    func delete(id: UUID) async throws {
        // TODO: Implement Core Data delete
    }

    func update(_ recording: Recording) async throws {
        // TODO: Implement Core Data update
    }
}
