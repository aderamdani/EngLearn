import SwiftUI

struct FillBlankView: View {
    let prompt: String
    let correctAnswer: String
    let hint: String?
    @Binding var inputText: String
    var isSubmitted: Bool
    var showHint: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(prompt)
                .font(.body)
                .padding(.bottom, Spacing.sm)
            
            TextField("Ketik jawabanmu di sini...", text: $inputText)
                .textFieldStyle(.plain)
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: CornerRadius.standard))
                .overlay {
                    RoundedRectangle(cornerRadius: CornerRadius.standard)
                        .stroke(borderColor, lineWidth: 1)
                }
                .disabled(isSubmitted)
                .autocorrectionDisabled()
                .accessibilityLabel("Kotak input jawaban")
            
            if showHint && !isSubmitted, let hint = hint {
                Label(hint, systemImage: "lightbulb")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.top, Spacing.xs)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: CornerRadius.card))
        .glassEffect(.regular, in: .rect(cornerRadius: CornerRadius.card))
    }
    
    private var borderColor: Color {
        if isSubmitted {
            return inputText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == correctAnswer.lowercased() 
                ? .green : .orange
        }
        return .secondary.opacity(0.3)
    }
}

#Preview {
    @Previewable @State var text = ""
    return FillBlankView(
        prompt: "I ___ (be) a student.",
        correctAnswer: "am",
        hint: "Gunakan bentuk 'be' untuk 'I'.",
        inputText: $text,
        isSubmitted: false,
        showHint: true
    )
    .padding()
}
