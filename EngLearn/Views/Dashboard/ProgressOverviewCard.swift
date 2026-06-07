import SwiftUI
import SwiftData

struct ProgressOverviewCard: View {
    let skill: SkillType
    let progress: Double // 0.0 to 1.0
    let completedCount: Int
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            progressRing
            
            VStack(alignment: .leading, spacing: 2) {
                Text(skill.displayName)
                    .font(.headline)
                
                Text("\(completedCount) Pelajaran Selesai")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(Int(progress * 100))%")
                .font(.system(size: 24, weight: .black))
                .foregroundColor(progressColor)
        }
        .padding(Spacing.lg)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: CornerRadius.card))
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: CornerRadius.card))
        .accessibilityLabel("\(skill.displayName), \(Int(progress * 100))% selesai")
    }
    
    private var progressRing: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.1), lineWidth: 6)
                .frame(width: 50, height: 50)
            
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(progressColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .frame(width: 50, height: 50)
                .rotationEffect(.degrees(-90))
            
            Image(systemName: skill.systemImage)
                .font(.system(size: 16))
                .foregroundColor(progressColor)
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
        ProgressOverviewCard(skill: .grammar, progress: 0.75, completedCount: 12)
        ProgressOverviewCard(skill: .vocabulary, progress: 0.3, completedCount: 45)
    }
    .padding()
}
