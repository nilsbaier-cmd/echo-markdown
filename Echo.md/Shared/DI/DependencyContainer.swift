import SwiftUI
import SwiftData

// MARK: - Dependency Container Protocol

protocol DependencyContainer {
    // Services
    var audioService: AudioServiceProtocol { get }
    var hapticService: HapticServiceProtocol { get }
    var assemblyAIService: AssemblyAIServiceProtocol { get }
    var claudeService: ClaudeServiceProtocol { get }
    var keychainService: KeychainServiceProtocol { get }
    var fileExportService: FileExportServiceProtocol { get }

    // Repositories
    var recordingRepository: RecordingRepositoryProtocol { get }
    var settingsRepository: SettingsRepositoryProtocol { get }

    // Use Cases
    var recordingUseCase: RecordingUseCaseProtocol { get }
    var fetchRecordingsUseCase: FetchRecordingsUseCaseProtocol { get }
    var transcriptionUseCase: TranscriptionUseCaseProtocol { get }
    var shadowReaderUseCase: ShadowReaderUseCaseProtocol { get }
    var textGenerationUseCase: TextGenerationUseCaseProtocol { get }
    var exportUseCase: ExportUseCaseProtocol { get }
}

// MARK: - Default Implementation

@MainActor
class DefaultDependencyContainer: DependencyContainer {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Services (Lazy Singletons)

    lazy var audioService: AudioServiceProtocol = AudioService()
    lazy var hapticService: HapticServiceProtocol = HapticService()
    lazy var keychainService: KeychainServiceProtocol = KeychainService()
    lazy var fileExportService: FileExportServiceProtocol = FileExportService()

    lazy var assemblyAIService: AssemblyAIServiceProtocol = {
        let apiKey = settingsRepository.getAPIKey(for: .assemblyAI) ?? ""
        return AssemblyAIService(apiKey: apiKey)
    }()

    lazy var claudeService: ClaudeServiceProtocol = {
        let apiKey = settingsRepository.getAPIKey(for: .claude) ?? ""
        return ClaudeService(apiKey: apiKey)
    }()

    // MARK: - Repositories

    lazy var recordingRepository: RecordingRepositoryProtocol = RecordingRepository(
        modelContext: modelContext
    )

    lazy var settingsRepository: SettingsRepositoryProtocol = SettingsRepository(
        keychainService: keychainService,
        userDefaults: .standard
    )

    // MARK: - Use Cases

    lazy var recordingUseCase: RecordingUseCaseProtocol = RecordingUseCase(
        audioService: audioService,
        recordingRepository: recordingRepository
    )

    lazy var fetchRecordingsUseCase: FetchRecordingsUseCaseProtocol = FetchRecordingsUseCase(
        repository: recordingRepository
    )

    lazy var transcriptionUseCase: TranscriptionUseCaseProtocol = TranscriptionUseCase(
        assemblyAIService: assemblyAIService,
        recordingRepository: recordingRepository
    )

    lazy var shadowReaderUseCase: ShadowReaderUseCaseProtocol = ShadowReaderUseCase(
        claudeService: claudeService
    )

    lazy var textGenerationUseCase: TextGenerationUseCaseProtocol = TextGenerationUseCase(
        claudeService: claudeService
    )

    lazy var exportUseCase: ExportUseCaseProtocol = ExportUseCase(
        fileExportService: fileExportService,
        settingsRepository: settingsRepository
    )
}
