import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var recordings: [Recording] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let recordingUseCase: RecordingUseCaseProtocol
    private let fetchRecordingsUseCase: FetchRecordingsUseCaseProtocol

    init(
        recordingUseCase: RecordingUseCaseProtocol,
        fetchRecordingsUseCase: FetchRecordingsUseCaseProtocol
    ) {
        self.recordingUseCase = recordingUseCase
        self.fetchRecordingsUseCase = fetchRecordingsUseCase
    }

    func loadRecordings() async {
        isLoading = true
        do {
            recordings = try await fetchRecordingsUseCase.execute()
        } catch {
            errorMessage = "Fehler beim Laden: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
