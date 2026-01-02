import SwiftUI

// MARK: - Dependency Container Protocol

protocol DependencyContainer {
    // Services
    var audioService: AudioServiceProtocol { get }
    var hapticService: HapticServiceProtocol { get }
    var assemblyAIService: AssemblyAIServiceProtocol { get }
    var claudeService: ClaudeServiceProtocol { get }
    var keychainService: KeychainServiceProtocol { get }
    var coreDataService: CoreDataServiceProtocol { get }
    var fileExportService: FileExportServiceProtocol { get }

    // Repositories
    var recordingRepository: RecordingRepositoryProtocol { get }
    var settingsRepository: SettingsRepositoryProtocol { get }

    // Use Cases
    var recordingUseCase: RecordingUseCaseProtocol { get }
    var transcriptionUseCase: TranscriptionUseCaseProtocol { get }
    var shadowReaderUseCase: ShadowReaderUseCaseProtocol { get }
    var textGenerationUseCase: TextGenerationUseCaseProtocol { get }
    var exportUseCase: ExportUseCaseProtocol { get }

    // ViewModels
    func makeHomeViewModel() -> HomeViewModel
    func makeRecordingViewModel() -> RecordingViewModel
    func makeShadowReaderViewModel() -> ShadowReaderViewModel
    func makeEditorViewModel() -> EditorViewModel
    func makeOnboardingViewModel() -> OnboardingViewModel
    func makeSettingsViewModel() -> SettingsViewModel
}

// MARK: - Default Implementation

class DefaultDependencyContainer: DependencyContainer {
    // MARK: - Services (Lazy Singletons)

    lazy var audioService: AudioServiceProtocol = AudioService()
    lazy var hapticService: HapticServiceProtocol = HapticService()
    lazy var keychainService: KeychainServiceProtocol = KeychainService()
    lazy var coreDataService: CoreDataServiceProtocol = CoreDataService()
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
        coreDataService: coreDataService
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

    lazy var transcriptionUseCase: TranscriptionUseCaseProtocol = TranscriptionUseCase(
        assemblyAIService: assemblyAIService
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

    // MARK: - ViewModel Factories

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            recordingUseCase: recordingUseCase,
            fetchRecordingsUseCase: FetchRecordingsUseCase(repository: recordingRepository)
        )
    }

    func makeRecordingViewModel() -> RecordingViewModel {
        RecordingViewModel(
            recordingUseCase: recordingUseCase,
            audioService: audioService,
            hapticService: hapticService
        )
    }

    func makeShadowReaderViewModel() -> ShadowReaderViewModel {
        ShadowReaderViewModel(
            transcriptionUseCase: transcriptionUseCase,
            shadowReaderUseCase: shadowReaderUseCase
        )
    }

    func makeEditorViewModel() -> EditorViewModel {
        EditorViewModel(
            textGenerationUseCase: textGenerationUseCase,
            exportUseCase: exportUseCase
        )
    }

    func makeOnboardingViewModel() -> OnboardingViewModel {
        OnboardingViewModel(settingsRepository: settingsRepository)
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(settingsRepository: settingsRepository)
    }
}

// MARK: - Environment Key

private struct DependencyContainerKey: EnvironmentKey {
    static let defaultValue: DependencyContainer = DefaultDependencyContainer()
}

extension EnvironmentValues {
    var container: DependencyContainer {
        get { self[DependencyContainerKey.self] }
        set { self[DependencyContainerKey.self] = newValue }
    }
}
