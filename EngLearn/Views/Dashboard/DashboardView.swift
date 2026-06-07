import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query private var userProgress: [UserProgress]
    @Query private var lessonRecords: [LessonRecord]
    @Query private var vocabEntries: [VocabularyEntry]
    @Query(sort: \DailyStreak.date, order: .reverse) private var streaks: [DailyStreak]
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: Spacing.xl) {
                welcomeSection
                
                quickStatsRow
                
                StreakHeatmapView()
                
                progressSection
                
                continueLearningSection
            }
            .padding(Spacing.lg)
        }
        .navigationTitle("Dashboard")
    }
    
    // MARK: - Sections
    
    private var welcomeSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(timeBasedGreeting)
                    .font(.title2.bold())
                Text("Siap untuk meningkatkan kemampuan bahasamu hari ini?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if let level = userProgress.first?.level {
                LevelBadge(level: level)
                    .scaleEffect(1.2)
            }
        }
        .padding(Spacing.lg)
        .background {
            RoundedRectangle(cornerRadius: CornerRadius.hero)
                .fill(.background)
                .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
        }
        .glassEffect(.regular, in: .rect(cornerRadius: CornerRadius.hero))
    }
    
    private var quickStatsRow: some View {
        let stats = [
            (title: "Pelajaran", value: "\(userProgress.first?.totalLessonsCompleted ?? 0)", icon: "book.fill", color: Color.blue),
            (title: "Kosakata", value: "\(vocabEntries.count)", icon: "character.book.closed.fill", color: Color.orange),
            (title: "Akurasi", value: "\(Int(calculateOverallAccuracy()))%", icon: "target", color: Color.green),
            (title: "Streak", value: "\(streaks.count)", icon: "flame.fill", color: Color.red)
        ]
        
        return HStack(spacing: Spacing.md) {
            ForEach(stats, id: \.title) { stat in
                VStack(spacing: 4) {
                    Image(systemName: stat.icon)
                        .font(.headline)
                        .foregroundColor(stat.color)
                    Text(stat.value)
                        .font(.headline)
                    Text(stat.title)
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                .background {
                    RoundedRectangle(cornerRadius: CornerRadius.card)
                        .fill(.background)
                        .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
                }
                .glassEffect(.regular, in: .rect(cornerRadius: CornerRadius.card))
            }
        }
    }
    
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            headerLabel("Kemajuan Modul", icon: "chart.line.uptrend.xyaxis")
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.md) {
                ProgressOverviewCard(skill: .grammar, progress: calculateProgress(for: .grammar), completedCount: countCompleted(for: .grammar))
                ProgressOverviewCard(skill: .vocabulary, progress: calculateProgress(for: .vocabulary), completedCount: countCompleted(for: .vocabulary))
                ProgressOverviewCard(skill: .reading, progress: calculateProgress(for: .reading), completedCount: countCompleted(for: .reading))
                ProgressOverviewCard(skill: .listening, progress: calculateProgress(for: .listening), completedCount: countCompleted(for: .listening))
            }
        }
    }
    
    private var continueLearningSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            headerLabel("Lanjutkan Belajar", icon: "play.circle.fill")
            
            HStack(spacing: Spacing.md) {
                Image(systemName: "pencil.and.outline")
                    .font(.title)
                    .foregroundColor(.accentColor)
                    .frame(width: 44, height: 44)
                    .background(.accentColor.opacity(0.1), in: Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Terakhir dipelajari:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(lessonRecords.last?.lessonID.capitalized ?? "Belum ada materi")
                        .font(.headline)
                }
                Spacer()
                Image(systemName: "chevron.right.circle.fill")
                    .font(.title2)
                    .foregroundColor(.accentColor)
            }
            .padding(Spacing.lg)
            .background {
                RoundedRectangle(cornerRadius: CornerRadius.card)
                    .fill(.background)
                    .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
            }
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: CornerRadius.card))
        }
    }
    
    // MARK: - Helpers
    
    private func headerLabel(_ title: String, icon: String) -> some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .foregroundStyle(.tint)
            Text(title)
                .font(.headline)
        }
        .padding(.leading, 4)
    }
    
    private var timeBasedGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 11 { return "Selamat Pagi!" }
        if hour < 15 { return "Selamat Siang!" }
        if hour < 18 { return "Selamat Sore!" }
        return "Selamat Malam!"
    }
    
    private func calculateProgress(for skill: SkillType) -> Double {
        let records = lessonRecords.filter { $0.skill == skill.rawValue }
        guard !records.isEmpty else { return 0.0 }
        let totalScore = records.reduce(0) { $0 + $1.scorePercentage }
        return totalScore / Double(records.count * 100)
    }
    
    private func countCompleted(for skill: SkillType) -> Int {
        lessonRecords.filter { $0.skill == skill.rawValue && $0.scorePercentage >= 80 }.count
    }
    
    private func calculateOverallAccuracy() -> Double {
        guard !lessonRecords.isEmpty else { return 0.0 }
        let total = lessonRecords.reduce(0.0) { $0 + $1.scorePercentage }
        return total / Double(lessonRecords.count)
    }
}

#Preview {
    NavigationStack {
        DashboardView()
            .modelContainer(for: [UserProgress.self, LessonRecord.self, DailyStreak.self, VocabularyEntry.self], inMemory: true)
    }
}
