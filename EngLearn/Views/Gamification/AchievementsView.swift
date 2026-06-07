import SwiftUI
import SwiftData

struct AchievementsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var unlockedAchievements: [AchievementRecord]
    
    @State private var allAchievements: [AchievementService.AchievementDTO] = []
    private let achievementService = AchievementService()
    
    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: Spacing.md)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: Spacing.xxl) {
                    StreakHeatmapView()
                        .padding(.horizontal, Spacing.lg)
                    
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        HStack {
                            Image(systemName: "trophy.fill")
                                .foregroundColor(.yellow)
                            Text("Pencapaian Kamu")
                                .font(.headline)
                        }
                        .padding(.leading, Spacing.lg)
                        
                        LazyVGrid(columns: columns, spacing: Spacing.md) {
                            ForEach(allAchievements, id: \.id) { dto in
                                achievementCard(dto: dto)
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                    }
                }
                .padding(.vertical, Spacing.lg)
            }
            .navigationTitle("Pencapaian")
            .background(.regularMaterial)
            .onAppear {
                allAchievements = achievementService.loadAchievements()
            }
        }
    }
    
    private func achievementCard(dto: AchievementService.AchievementDTO) -> some View {
        let unlocked = unlockedAchievements.first(where: { $0.achievementID == dto.id })
        
        return VStack(spacing: Spacing.sm) {
            ZStack {
                Circle()
                    .fill(unlocked != nil ? Color.accentColor : Color.gray.mix(with: .white, by: 0.8))
                    .frame(width: 60, height: 60)
                
                Image(systemName: dto.icon)
                    .font(.title)
                    .foregroundColor(unlocked != nil ? .white : .secondary)
            }
            
            Text(dto.title)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(dto.description_id)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(height: 40)
            
            if let date = unlocked?.unlockedAt {
                Text(date, style: .date)
                    .font(.system(size: 8))
                    .foregroundColor(.accentColor)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.background, in: RoundedRectangle(cornerRadius: CornerRadius.card))
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: CornerRadius.card))
        .grayscale(unlocked != nil ? 0 : 1)
        .opacity(unlocked != nil ? 1 : 0.6)
        .accessibilityLabel("\(dto.title): \(dto.description_id)")
    }
}

#Preview {
    AchievementsView()
        .modelContainer(for: [AchievementRecord.self], inMemory: true)
}
