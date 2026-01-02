import Foundation

final class FetchRecordingsUseCase: FetchRecordingsUseCaseProtocol {
    private let repository: RecordingRepositoryProtocol

    init(repository: RecordingRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [Recording] {
        try await repository.fetchAll()
    }
}
