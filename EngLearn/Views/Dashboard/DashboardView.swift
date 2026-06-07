import SwiftUI
import SwiftData
import OSLog

struct DashboardView: View {
    @Query private var userProgress: [UserProgress]
    @Query(sort: \LessonRecord.completedAt, order: .reverse) private var recentRecords: [LessonRecord]
    @Query(sort: \DailyStreak.date, order: .reverse) private var streaks: [DailyStreak]
    
    @AppStorage("dailyGoalMinutes") private var dailyGoalMinutes = 10
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: Spacing.xl) {
                heroCard
                
                dailyProgressStrip
                
                moduleGrid
                
                recentActivitySection
            }
            .padding(Spacing.lg)
        }
        .navigationTitle("Dashboard")
    }
    
    // MARK: - Sections
    
    private var heroCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text(timeBasedGreeting)
                    .font(.title2.bold())
                Spacer()
                if let progress = userProgress.first {
                    LevelBadge(level: progress.level)
                }
            }
            
            if recentRecords.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text("Selamat datang! Pilih modul pertamamu.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: Spacing.md) {
                        quickStartButton(title: "Grammar", icon: "textformat", module: .grammar)
                        quickStartButton(title: "Vocabulary", icon: "character.book.closed.fill", module: .vocabulary)
                        quickStartButton(title: "Daily", icon: "bolt.fill", module: .dailyLesson)
                    }
                }
            } else if let lastRecord = recentRecords.first {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Lanjutkan:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text(lastRecord.lessonID.replacingOccurrences(of: "_", with: " ").capitalized)
                            .font(.headline)
                        Spacer()
                        Button("Lanjut") {
                            navigateToModule(for: lastRecord.skill)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    
                    ProgressView(value: lastRecord.scorePercentage, total: 100)
                        .tint(progressColor(score: lastRecord.scorePercentage))
                }
            }
        }
        .padding(Spacing.lg)
        .background {
            RoundedRectangle(cornerRadius: CornerRadius.hero)
                .fill(.background)
                .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
        }
    }
    
    private func quickStartButton(title: String, icon: String, module: ModuleType) -> some View {
        Button {
            NotificationCenter.default.post(name: .selectModule, object: module)
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.headline)
                Text(title)
                    .font(.caption2.bold())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background {
                RoundedRectangle(cornerRadius: CornerRadius.card)
                    .fill(.background)
            }
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: CornerRadius.card))
        }
        .buttonStyle(.plain)
    }
    
    private var dailyProgressStrip: some View {
        HStack(spacing: Spacing.md) {
            dailyStatPill(icon: "circle.dotted", value: "\(todayMinutes)m", color: .green, progress: dailyGoalProgress)
            dailyStatPill(icon: "flame.fill", value: "\(streaks.count)", color: .orange)
            dailyStatPill(icon: "checkmark.circle.fill", value: "\(todayExercises) lat", color: .blue)
            dailyStatPill(icon: "target", value: "\(Int(todayAccuracy))%", color: .red)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func dailyStatPill(icon: String, value: String, color: Color, progress: Double? = nil) -> some View {
        HStack(spacing: 6) {
            if let progress = progress {
                ZStack {
                    Circle().stroke(color.opacity(0.2), lineWidth: 2)
                    Circle().trim(from: 0, to: CGFloat(progress))
                        .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                }
                .frame(width: 14, height: 14)
            } else {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.system(size: 10, weight: .bold))
                .monospacedDigit()
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial, in: Capsule())
    }
    
    private var moduleGrid: some View {
        let modules: [(title: String, icon: String, type: ModuleType)] = [
            ("Grammar", "textformat", .grammar),
            ("Vocabulary", "character.book.closed.fill", .vocabulary),
            ("Reading", "book.fill", .reading),
            ("Listening", "headphones", .listening),
            ("Writing", "pencil.line", .writing),
            ("Speaking", "waveform", .speaking),
            ("Daily Lesson", "bolt.fill", .dailyLesson),
            ("Immersion", "sparkles", .immersion)
        ]
        
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.md) {
            ForEach(modules, id: \.title) { mod in
                Button {
                    NotificationCenter.default.post(name: .selectModule, object: mod.type)
                } label: {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Image(systemName: mod.icon)
                            .font(.system(size: 24))
                            .foregroundStyle(.tint)
                        
                        Text(mod.title)
                            .font(.subheadline.bold())
                        
                        ProgressView(value: calculateModuleProgress(for: mod.type))
                            .controlSize(.small)
                    }
                    .padding(Spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background {
                        RoundedRectangle(cornerRadius: CornerRadius.card)
                            .fill(.background)
                            .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
                    }
                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: CornerRadius.card))
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.accentColor)
                Text("Aktivitas Terakhir")
                    .font(.headline)
            }
            
            if recentRecords.isEmpty {
                Text("Belum ada aktivitas. Mulai pelajaran pertamamu!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, Spacing.xl)
            } else {
                VStack(spacing: Spacing.sm) {
                    ForEach(recentRecords.prefix(3)) { record in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(record.skill.capitalized): \(record.lessonID.replacingOccurrences(of: "_", with: " ").capitalized)")
                                    .font(.subheadline.bold())
                                Text("\(Text(record.completedAt, style: .relative)) yang lalu")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("\(Int(record.scorePercentage))%")
                                .font(.subheadline.bold())
                                .foregroundColor(progressColor(score: record.scorePercentage))
                        }
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: CornerRadius.card)
                                .fill(.background)
                                .shadow(color: .black.opacity(0.05), radius: 4, y: 1)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Logic & Helpers
    
    private var timeBasedGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if (5...11).contains(hour) { return "Selamat Pagi" }
        if (12...17).contains(hour) { return "Selamat Siang" }
        return "Selamat Malam"
    }
    
    private var todayMinutes: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        return streaks.first(where: { calendar.isDate($0.date, inSameDayAs: today) })?.minutesSpent ?? 0
    }
    
    private var todayExercises: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        return streaks.first(where: { calendar.isDate($0.date, inSameDayAs: today) })?.exercisesCompleted ?? 0
    }
    
    private var todayAccuracy: Double {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let todayRecords = recentRecords.filter { calendar.isDate($0.completedAt, inSameDayAs: today) }
        guard !todayRecords.isEmpty else { return 0.0 }
        let total = todayRecords.reduce(0.0) { $0 + $1.scorePercentage }
        return total / Double(todayRecords.count)
    }
    
    private var dailyGoalProgress: Double {
        guard dailyGoalMinutes > 0 else { return 0 }
        return min(1.0, Double(todayMinutes) / Double(dailyGoalMinutes))
    }
    
    private func calculateModuleProgress(for module: ModuleType) -> Double {
        let skillStr: String
        switch module {
        case .grammar: skillStr = SkillType.grammar.rawValue
        case .vocabulary: skillStr = SkillType.vocabulary.rawValue
        case .reading: skillStr = SkillType.reading.rawValue
        case .listening: skillStr = SkillType.listening.rawValue
        case .writing: skillStr = SkillType.writing.rawValue
        case .speaking: skillStr = SkillType.speaking.rawValue
        default: return 0.0
        }
        
        let records = recentRecords.filter { $0.skill == skillStr }
        guard !records.isEmpty else { return 0.0 }
        let total = records.reduce(0.0) { $0 + $1.scorePercentage }
        return total / Double(records.count * 100)
    }
    
    private func progressColor(score: Double) -> Color {
        if score >= 80 { return .green }
        if score >= 40 { return .blue }
        return .orange
    }
    
    private func navigateToModule(for skill: String) {
        if let skillType = SkillType(rawValue: skill) {
            let module: ModuleType
            switch skillType {
            case .grammar: module = .grammar
            case .vocabulary: module = .vocabulary
            case .reading: module = .reading
            case .listening: module = .listening
            case .writing: module = .writing
            case .speaking: module = .speaking
            case .dailyLesson: module = .dailyLesson
            default: return
            }
            NotificationCenter.default.post(name: .selectModule, object: module)
        }
    }
}

#Preview {
    NavigationStack {
        DashboardView()
            .modelContainer(for: [UserProgress.self, LessonRecord.self, DailyStreak.self, VocabularyEntry.self], inMemory: true)
    }
}
