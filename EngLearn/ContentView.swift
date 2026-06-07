import SwiftUI
import SwiftData
import OSLog

struct ContentView: View {
    @SceneStorage("selectedModule") private var selectedModule: String?
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("dailyGoalMinutes") private var dailyGoalMinutes = 10
    @State private var searchQuery = ""
    @State private var searchResults: SearchResults?
    
    @Query private var vocabularyEntries: [VocabularyEntry]
    
    struct SearchResults: Equatable {
        let lessons: [Lesson]
        let vocabulary: [VocabularyEntry]
    }
    
    @Query(sort: \DailyStreak.date, order: .reverse) private var streaks: [DailyStreak]

    var body: some View {
        if hasCompletedOnboarding {
            mainContent
        } else {
            OnboardingView()
        }
    }

    private var mainContent: some View {
        NavigationSplitView {
            sidebar
                .navigationSplitViewColumnWidth(
                    min: AppConstants.Window.sidebarMinWidth,
                    ideal: AppConstants.Window.sidebarIdealWidth,
                    max: AppConstants.Window.sidebarMaxWidth
                )
        } detail: {
            if searchQuery.isEmpty {
                detailView
            } else {
                searchResultsView
            }
        }
        .frame(
            minWidth: AppConstants.Window.minWidth,
            minHeight: AppConstants.Window.minHeight
        )
        .searchable(text: $searchQuery, prompt: "Cari kosakata atau materi...")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                HStack(spacing: Spacing.md) {
                    // Streak indicator
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                        Text("\(currentStreakCount)")
                            .font(.caption.bold())
                            .monospacedDigit()
                    }
                    .padding(.horizontal, Spacing.sm)
                    .accessibilityLabel("Streak \(currentStreakCount) hari")

                    // Daily goal progress  
                    HStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .stroke(Color.primary.opacity(0.1), lineWidth: 2)
                                .frame(width: 14, height: 14)
                            Circle()
                                .trim(from: 0, to: dailyGoalProgress)
                                .stroke(Color.green, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                                .frame(width: 14, height: 14)
                                .rotationEffect(.degrees(-90))
                        }
                        Text("\(todayMinutes)m")
                            .font(.caption.bold())
                            .monospacedDigit()
                    }
                    .padding(.horizontal, Spacing.sm)
                    .accessibilityLabel("Hari ini: \(todayMinutes) menit dari \(dailyGoalTarget) menit target")
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .selectModule)) { notification in
            if let module = notification.object as? ModuleType {
                selectedModule = module.rawValue
            }
        }
        .task(id: searchQuery) {
            await performSearch()
        }
    }

    private var sidebar: some View {
        List(selection: $selectedModule) {
            Section("Belajar") {
                sidebarItem(.dashboard)
                sidebarItem(.dailyLesson)
                sidebarItem(.grammar)
                sidebarItem(.vocabulary)
                sidebarItem(.reading)
                sidebarItem(.listening)
                sidebarItem(.writing)
                sidebarItem(.speaking)
            }

            Section("Jelajahi") {
                sidebarItem(.immersion)
                sidebarItem(.levelTest)
            }

            Section("Progres") {
                sidebarItem(.achievements)
                sidebarItem(.settings)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle(AppConstants.appName)
    }

    private func sidebarItem(_ module: ModuleType) -> some View {
        Label(module.displayName, systemImage: module.systemImage)
            .tag(module.rawValue)
    }

    @ViewBuilder
    private var detailView: some View {
        if let selected = selectedModule, let module = ModuleType(rawValue: selected) {
            switch module {
            case .dashboard:
                DashboardView()
            case .dailyLesson:
                DailyLessonView()
            case .grammar:
                GrammarModuleView()
            case .vocabulary:
                VocabularyModuleView()
            case .reading:
                ReadingModuleView()
            case .listening:
                ListeningModuleView()
            case .writing:
                WritingModuleView()
            case .speaking:
                SpeakingModuleView()
            case .immersion:
                ImmersionZoneView()
            case .levelTest:
                LevelTestView()
            case .achievements:
                AchievementsView()
            case .settings:
                SettingsView()
            }
        } else {
            DashboardView()
        }
    }

    private var searchResultsView: some View {
        SearchResultsView(query: searchQuery, vocabularyEntries: vocabularyEntries)
    }

    private var currentStreakCount: Int {
        streaks.count
    }

    private var todayMinutes: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        return streaks.first(where: { calendar.isDate($0.date, inSameDayAs: today) })?.minutesSpent ?? 0
    }

    private var dailyGoalTarget: Int {
        dailyGoalMinutes
    }

    private var dailyGoalProgress: Double {
        guard dailyGoalTarget > 0 else { return 0 }
        return min(1.0, Double(todayMinutes) / Double(dailyGoalTarget))
    }
    
    private func performSearch() async {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if query.isEmpty {
            searchResults = nil
            return
        }
        
        let matchingVocab = vocabularyEntries.filter {
            $0.word.lowercased().contains(query) ||
            $0.definitionID.lowercased().contains(query) ||
            $0.definitionEN.lowercased().contains(query)
        }
        
        var matchingLessons: [Lesson] = []
        let lessonService = LessonService()
        for skill in [SkillType.grammar, SkillType.vocabulary] {
            for level in CEFRLevel.allCases {
                if let lessons = try? lessonService.lessons(for: skill, level: level) {
                    matchingLessons.append(contentsOf: lessons.filter {
                        $0.title.lowercased().contains(query) ||
                        $0.theme.lowercased().contains(query)
                    })
                }
            }
        }
        
        await MainActor.run {
            searchResults = SearchResults(lessons: matchingLessons, vocabulary: matchingVocab)
        }
        Log.ui.info("Search for '\(query)': \(matchingLessons.count) lessons, \(matchingVocab.count) vocab entries")
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [DailyStreak.self], inMemory: true)
}
