import SwiftUI

struct MultipleChoiceView: View {
    let options: [String]
    let correctIndex: Int
    @Binding var selectedIndex: Int?
    var isSubmitted: Bool
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            ForEach(0..<options.count, id: \.self) { index in
                Button {
                    if !isSubmitted {
                        selectedIndex = index
                    }
                } label: {
                    optionLabel(index: index)
                }
                .buttonStyle(.plain)
                .disabled(isSubmitted)
                .accessibilityLabel("Pilihan \(index + 1): \(options[index])")
            }
        }
    }
    
    private func optionLabel(index: Int) -> some View {
        HStack {
            Text(options[index])
                .font(.body)
            Spacer()
            if isSubmitted {
                if index == correctIndex {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else if index == selectedIndex {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundColor(for: index), in: RoundedRectangle(cornerRadius: CornerRadius.card))
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: CornerRadius.card))
        .overlay {
            if selectedIndex == index && !isSubmitted {
                RoundedRectangle(cornerRadius: CornerRadius.card)
                    .stroke(Color.accentColor, lineWidth: 2)
            }
        }
    }
    
    private func backgroundColor(for index: Int) -> Color {
        if isSubmitted {
            if index == correctIndex {
                return Color.green.mix(with: .white, by: 0.8)
            } else if index == selectedIndex {
                return Color.orange.mix(with: .white, by: 0.8)
            }
        }
        return Color.background
    }
}

#Preview {
    @State var selected: Int? = nil
    return MultipleChoiceView(
        options: ["Apple", "Banana", "Cherry", "Date"],
        correctIndex: 1,
        selectedIndex: $selected,
        isSubmitted: false
    )
    .padding()
}
