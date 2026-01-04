import SwiftUI

// MARK: - Editor View

struct EditorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: EditorViewModel

    let transcript: String
    let recording: Recording

    private let container: DependencyContainer

    init(
        transcript: String,
        recording: Recording,
        container: DependencyContainer
    ) {
        self.transcript = transcript
        self.recording = recording
        self.container = container
        _viewModel = StateObject(wrappedValue: EditorViewModel(
            textGenerationUseCase: container.textGenerationUseCase,
            exportUseCase: container.exportUseCase
        ))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Style Picker
                stylePicker

                Divider()

                // Content Area
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.generatedText.isEmpty {
                    transcriptPreview
                } else {
                    generatedTextView
                }

                Divider()

                // Action Buttons
                actionButtons
            }
            .navigationTitle("Editor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Schliessen") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    exportMenu
                }
            }
        }
        .alert("Fehler", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    // MARK: - Style Picker

    private var stylePicker: some View {
        Picker("Stil", selection: $viewModel.selectedStyle) {
            ForEach(TextStyle.allCases, id: \.self) { style in
                Text(style.rawValue).tag(style)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
            Text("Generiere Text...")
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    // MARK: - Transcript Preview

    private var transcriptPreview: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Angereichertes Transkript")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Button {
                        UIPasteboard.general.string = transcript
                    } label: {
                        Label("Kopieren", systemImage: "doc.on.doc")
                            .font(.subheadline)
                    }
                }

                Text(transcript)
                    .font(.body)
                    .textSelection(.enabled)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding()
        }
    }

    // MARK: - Generated Text View

    private var generatedTextView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Generierter Text")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Button {
                        UIPasteboard.general.string = viewModel.generatedText
                    } label: {
                        Label("Kopieren", systemImage: "doc.on.doc")
                            .font(.subheadline)
                    }
                }

                Text(viewModel.generatedText)
                    .font(.body)
                    .textSelection(.enabled)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding()
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    await viewModel.generateText(from: transcript)
                }
            } label: {
                HStack {
                    Image(systemName: "wand.and.stars")
                    Text(viewModel.generatedText.isEmpty ? "Text generieren" : "Neu generieren")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(viewModel.isLoading)
        }
        .padding()
    }

    // MARK: - Export Menu

    @ViewBuilder
    private var exportMenu: some View {
        if !viewModel.generatedText.isEmpty {
            Menu {
                Button {
                    Task {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        let filename = "Echo_\(dateFormatter.string(from: recording.createdAt))"
                        await viewModel.exportToVault(filename: filename)
                    }
                } label: {
                    Label("Nach Obsidian", systemImage: "arrow.up.doc")
                }

                ShareLink(item: viewModel.generatedText) {
                    Label("Teilen", systemImage: "square.and.arrow.up")
                }
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let transcript = """
    Heute moechte ich ueber meine Ideen fuer das neue Projekt sprechen.
    Es geht darum, eine App zu entwickeln, die Sprachnotizen in strukturierte Texte umwandelt.
    Dabei soll KI verwendet werden, um Rueckfragen zu stellen und den Inhalt zu vertiefen.
    """

    // Note: Preview requires mock dependencies
    Text("EditorView Preview")
}
