import Foundation

enum APIService: String, CaseIterable {
    case claude = "claude"
    case assemblyAI = "assemblyai"

    var keychainKey: String {
        return "echo.apikey.\(self.rawValue)"
    }

    var displayName: String {
        switch self {
        case .claude: return "Claude (Anthropic)"
        case .assemblyAI: return "AssemblyAI"
        }
    }
}
