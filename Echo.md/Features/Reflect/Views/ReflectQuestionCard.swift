import SwiftUI

// MARK: - Reflect Question Card

struct ReflectQuestionCard: View {
    let question: ReflectQuestion
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Question
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: question.isAnswered ? "checkmark.circle.fill" : "questionmark.circle")
                    .foregroundStyle(question.isAnswered ? .green : .blue)
                    .font(.title3)

                Text(question.question)
                    .font(.body)
                    .foregroundStyle(question.isAnswered ? .secondary : .primary)
            }

            // Answer (if exists)
            if let answer = question.answer {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: answerIcon)
                        .foregroundStyle(.green)
                        .font(.caption)
                        .frame(width: 24)

                    Text(answer)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.leading, 4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: isSelected ? 2 : 1)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if !question.isAnswered {
                onSelect()
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .animation(.easeInOut(duration: 0.2), value: question.isAnswered)
    }

    // MARK: - Private Computed Properties

    private var backgroundColor: Color {
        if question.isAnswered {
            return Color.green.opacity(0.05)
        } else if isSelected {
            return Color.blue.opacity(0.1)
        } else {
            return Color(.systemBackground)
        }
    }

    private var borderColor: Color {
        if question.isAnswered {
            return .green.opacity(0.3)
        } else if isSelected {
            return .blue
        } else {
            return Color(.systemGray4)
        }
    }

    private var answerIcon: String {
        switch question.answerSource {
        case .audio:
            return "waveform"
        case .text:
            return "text.bubble"
        case .none:
            return "arrow.turn.down.right"
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        ReflectQuestionCard(
            question: ReflectQuestion(question: "Kannst du das mit einem Beispiel erklaeren?"),
            isSelected: false,
            onSelect: {}
        )

        ReflectQuestionCard(
            question: ReflectQuestion(question: "Was meinst du genau damit?"),
            isSelected: true,
            onSelect: {}
        )

        ReflectQuestionCard(
            question: {
                let q = ReflectQuestion(question: "Wie wuerdest du das umsetzen?")
                q.answer = "Ich wuerde zuerst einen Plan erstellen und dann schrittweise vorgehen."
                q.answerSource = .text
                return q
            }(),
            isSelected: false,
            onSelect: {}
        )
    }
    .padding()
}
