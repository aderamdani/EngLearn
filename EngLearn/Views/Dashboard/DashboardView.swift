import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query private var userProgress: [UserProgress]
    @Query private var lessonRecords: [LessonRecord]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.xxl) {
                welcomeSection
                
                StreakHeatmapView()
                
                progressSection
            }
            .padding(Spacing.xxl)
        }
        .navigationTitle("Dashboard")
    }
    
    // MARK: - Sections
    
    private var welcomeSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Halo, Semangat Belajar!")
                    .font(.title2.bold())
                
                Text("Mari lanjutkan perjalanan belajarmu hari ini.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let level = userProgress.first?.level {
                LevelBadge(level: level)
            }
        }
        .padding(Spacing.lg)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: CornerRadius.hero))
        .glassEffect(.regular, in: .rect(cornerRadius: CornerRadius.hero))
    }
    
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Kemajuan Belajar")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 280))], spacing: Spacing.lg) {
                ProgressOverviewCard(skill: .grammar, progress: calculateProgress(for: .grammar))
                ProgressOverviewCard(skill: .vocabulary, progress: calculateProgress(for: .vocabulary))
                ProgressOverviewCard(skill: .reading, progress: calculateProgress(for: .reading))
                ProgressOverviewCard(skill: .listening, progress: calculateProgress(for: .listening))
            }
        }
    }
    
    // MARK: - Helpers
    
    private func calculateProgress(for skill: SkillType) -> Double {
        let records = lessonRecords.filter { $0.skill == skill.rawValue }
        guard !records.isEmpty else { return 0.0 } // Placeholder for demo
        
        // Simple average score as progress for now
        let totalScore = records.reduce(0) { $0 + $1.scorePercentage }
        return totalScore / Double(records.count * 100)
    }
}

#Preview {
    NavigationStack {
        DashboardView()
            .modelContainer(for: [UserProgress.self, LessonRecord.self, DailyStreak.self], inMemory: true)
    }
}
