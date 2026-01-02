import Foundation
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var recordings: [Recording] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let recordingUseCase: RecordingUseCaseProtocol
    private let fetchRecordingsUseCase: FetchRecordingsUseCaseProtocol

    init(recordingUseCase: RecordingUseCaseProtocol, fetchRecordingsUseCase: FetchRecordingsUseCaseProtocol) {
        self.recordingUseCase = recordingUseCase
        self.fetchRecordingsUseCase = fetchRecordingsUseCase
    }

    func loadRecordings() async {
        isLoading = true
        errorMessage = nil

        do {
            recordings = try await fetchRecordingsUseCase.execute()
        } catch {
            errorMessage = "Fehler beim Laden: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func deleteRecording(_ recording: Recording) async {
        do {
            try await recordingUseCase.deleteRecording(id: recording.id)
            recordings.removeAll { $0.id == recording.id }
        } catch {
            errorMessage = "Fehler beim Löschen: \(error.localizedDescription)"
        }
    }
}
