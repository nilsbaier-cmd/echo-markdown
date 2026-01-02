# Echo.md

Voice-to-Text iOS App mit KI-Unterstützung.

## Features (MVP)

- Sprachaufnahmen mit Live-Waveform
- Transkription via AssemblyAI
- Shadow Reader: KI-generierte Rückfragen zur Vertiefung
- Textgenerierung in verschiedenen Stilen (formell, informell, Obsidian)
- Export zu Obsidian Vault oder Share Sheet

## Technologie

- **Framework:** SwiftUI
- **Architektur:** MVVM + Clean Architecture
- **Datenspeicherung:** SwiftData
- **iOS Target:** 17.0+
- **APIs:** AssemblyAI (Transkription), Claude (Textverarbeitung)

## Projekt-Konfiguration

| Attribut | Wert |
|----------|------|
| **Bundle ID** | `com.resonance.Echo-md` |
| **Display Name** | Echo.md |
| **iOS Minimum** | 17.0 |

## Ordnerstruktur

```
Echo/
├── Core/
│   ├── Domain/
│   │   ├── Models/          # Recording, GeneratedText, etc. (@Model)
│   │   ├── Protocols/       # Repository & Service Interfaces
│   │   └── UseCases/        # Business Logic
│   ├── Data/
│   │   ├── Repositories/    # SwiftData Repository Implementierungen
│   │   └── Services/        # API Services, SwiftDataService
│   └── Platform/
│       ├── Audio/           # AVFoundation Service
│       ├── Keychain/        # Secrets Storage
│       ├── FileExport/      # Obsidian Export
│       └── Haptic/          # Haptic Feedback
├── Features/
│   ├── Onboarding/
│   ├── Home/
│   ├── Recording/
│   ├── ShadowReader/
│   ├── Editor/
│   └── Settings/
├── Shared/
│   ├── UI/Components/       # Wiederverwendbare Views
│   ├── DI/                  # Dependency Injection
│   ├── Extensions/
│   └── Utils/
└── Resources/
    └── Assets.xcassets
```

## API Keys

Die App benötigt API-Keys für:
- **AssemblyAI:** https://www.assemblyai.com
- **Claude (Anthropic):** https://console.anthropic.com

Keys werden sicher im iOS Keychain gespeichert.

## Entwicklungsplan

Siehe: [[Echo - Sprintplan]] im Obsidian Vault

## Lizenz

Private Nutzung
