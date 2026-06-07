import SwiftUI

struct TrueFalseView: View {
    let prompt: String
    let isCorrectTrue: Bool
    @Binding var selectedAnswer: Bool?
    var isSubmitted: Bool
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            Text(prompt)
                .font(.body)
                .padding(.bottom, Spacing.sm)
            
            HStack(spacing: Spacing.md) {
                tfButton(title: "Benar", value: true)
                tfButton(title: "Salah", value: false)
            }
        }
    }
    
    private func tfButton(title: String, value: Bool) -> some View {
        Button {
            if !isSubmitted {
                selectedAnswer = value
            }
        } label: {
            HStack {
                Text(title)
                Spacer()
                if isSubmitted {
                    if value == isCorrectTrue {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else if value == selectedAnswer {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(backgroundColor(for: value), in: RoundedRectangle(cornerRadius: CornerRadius.card))
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: CornerRadius.card))
            .overlay {
                if selectedAnswer == value && !isSubmitted {
                    RoundedRectangle(cornerRadius: CornerRadius.card)
                        .stroke(Color.accentColor, lineWidth: 2)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(isSubmitted)
        .accessibilityLabel(title)
    }
    
    private func backgroundColor(for value: Bool) -> Color {
        if isSubmitted {
            if value == isCorrectTrue {
                return Color.green.mix(with: .white, by: 0.8)
            } else if value == selectedAnswer {
                return Color.orange.mix(with: .white, by: 0.8)
            }
        }
        return .clear
    }
}

#Preview {
    @Previewable @State var ans: Bool? = nil
    return TrueFalseView(
        prompt: "'I is' is correct English.",
        isCorrectTrue: false,
        selectedAnswer: $ans,
        isSubmitted: false
    )
    .padding()
}
