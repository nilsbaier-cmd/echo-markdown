# Echo

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
- **iOS Target:** 16.0+
- **APIs:** AssemblyAI (Transkription), Claude (Textverarbeitung)

## Projekt Setup

### Xcode-Projekt erstellen

1. Xcode öffnen
2. **File → New → Project**
3. Template: **iOS → App**
4. Konfiguration:
   - Product Name: `Echo`
   - Bundle Identifier: `com.nils.echo`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: **None** (Core Data wird manuell hinzugefügt)
5. Speicherort: Dieses Verzeichnis wählen
6. Bestehende Dateien durch generierte ersetzen lassen

### Dateien hinzufügen

Nach dem Erstellen des Xcode-Projekts:

1. Im Xcode Navigator: Rechtsklick auf "Echo" Ordner
2. **Add Files to "Echo"...**
3. Den gesamten `Echo/` Ordner auswählen
4. "Create groups" aktivieren
5. **Add**

### Core Data Model erstellen

1. **File → New → File...**
2. **Core Data → Data Model**
3. Name: `EchoDataModel`
4. Speichern im `Echo/Core/Data/CoreData/` Ordner

## Ordnerstruktur

```
Echo/
├── Core/
│   ├── Domain/
│   │   ├── Models/          # Recording, GeneratedText, etc.
│   │   ├── Protocols/       # Repository & Service Interfaces
│   │   └── UseCases/        # Business Logic
│   ├── Data/
│   │   ├── Repositories/    # Repository Implementierungen
│   │   ├── Services/        # API Services
│   │   └── CoreData/        # Core Data Entities
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
