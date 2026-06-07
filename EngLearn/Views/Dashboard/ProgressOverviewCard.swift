import SwiftUI

struct ProgressOverviewCard: View {
    let skill: SkillType
    let progress: Double // 0.0 to 1.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            headerView
            
            ProgressView(value: progress)
                .tint(progressColor)
                .accessibilityValue(String(format: "%.0f%%", progress * 100))
            
            Text("\(Int(progress * 100))% Terlampaui")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(Spacing.md)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: CornerRadius.card))
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: CornerRadius.card))
    }
    
    private var headerView: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: skill.systemImage)
                .font(.title3)
                .foregroundColor(.accentColor)
                .frame(width: 32, height: 32)
                .background(.ultraThinMaterial, in: Circle())
            
            Text(skill.displayName)
                .font(.headline)
            
            Spacer()
        }
    }
    
    private var progressColor: Color {
        if progress >= 0.8 { return .green }
        if progress >= 0.4 { return .blue }
        return .orange
    }
}

#Preview {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.md) {
        ProgressOverviewCard(skill: .grammar, progress: 0.75)
        ProgressOverviewCard(skill: .vocabulary, progress: 0.3)
        ProgressOverviewCard(skill: .listening, progress: 0.9)
    }
    .padding()
}
