import SwiftUI

// MARK: - Input Mode

enum ReflectInputMode {
    case audio
    case text
}

// MARK: - Reflect Answer Input

struct ReflectAnswerInput: View {
    @Binding var textAnswer: String
    let isRecording: Bool
    let currentPower: Float
    let onStartRecording: () -> Void
    let onStopRecording: () -> Void
    let onSubmitText: () -> Void
    let onCancel: () -> Void

    @State private var inputMode: ReflectInputMode = .audio
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(spacing: 16) {
            // Mode Picker
            Picker("Eingabemodus", selection: $inputMode) {
                Label("Sprechen", systemImage: "mic.fill")
                    .tag(ReflectInputMode.audio)
                Label("Tippen", systemImage: "keyboard")
                    .tag(ReflectInputMode.text)
            }
            .pickerStyle(.segmented)

            // Input Area
            switch inputMode {
            case .audio:
                audioInputView
            case .text:
                textInputView
            }

            // Cancel Button
            Button("Abbrechen", role: .cancel) {
                onCancel()
            }
            .font(.subheadline)
        }
    }

    // MARK: - Audio Input

    private var audioInputView: some View {
        VStack(spacing: 12) {
            Button(action: onStartRecording) {
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(.blue)
                            .frame(width: 64, height: 64)

                        Image(systemName: "mic.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }

                    Text("Tippen zum Aufnehmen")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Text Input

    private var textInputView: some View {
        HStack(spacing: 12) {
            TextField("Deine Antwort...", text: $textAnswer, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...6)
                .focused($isTextFieldFocused)
                .onAppear {
                    isTextFieldFocused = true
                }

            Button(action: onSubmitText) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title)
                    .foregroundStyle(canSubmitText ? .blue : .gray)
            }
            .disabled(!canSubmitText)
        }
    }

    private var canSubmitText: Bool {
        !textAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - Preview

#Preview {
    VStack {
        Spacer()

        ReflectAnswerInput(
            textAnswer: .constant(""),
            isRecording: false,
            currentPower: -160,
            onStartRecording: {},
            onStopRecording: {},
            onSubmitText: {},
            onCancel: {}
        )
        .padding()
        .background(Color(.systemGray6))
    }
}
