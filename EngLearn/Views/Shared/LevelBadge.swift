import SwiftUI

struct LevelBadge: View {
    let level: CEFRLevel
    var isSmall: Bool = false
    
    var body: some View {
        Text(level.displayName.uppercased())
            .font(isSmall ? .caption2.bold() : .caption.bold())
            .padding(.horizontal, isSmall ? Spacing.xs : Spacing.sm)
            .padding(.vertical, isSmall ? 2 : Spacing.xs)
            .background {
                Capsule()
                    .fill(Color.cefrColor(for: level))
            }
            .foregroundColor(.white)
            .accessibilityLabel(String(localized: "Level \(level.displayName)", comment: "Accessibility label for level badge"))
    }
}

#Preview {
    HStack {
        LevelBadge(level: .a1)
        LevelBadge(level: .b2)
        LevelBadge(level: .c2, isSmall: true)
    }
    .padding()
}
