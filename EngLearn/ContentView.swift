import SwiftUI
import SwiftData

struct ContentView: View {
    @SceneStorage("selectedModule") private var selectedModule: String?
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("dailyGoalMinutes") private var dailyGoalMinutes = 10
    @State private var searchQuery = ""
    
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
            detailView
        }
        .frame(
            minWidth: AppConstants.Window.minWidth,
            minHeight: AppConstants.Window.minHeight
        )
        .searchable(
            text: $searchQuery,
            placement: .toolbar,
            prompt: String(localized: "Cari pelajaran, kosakata...", comment: "Search placeholder")
        )
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                HStack(spacing: 8) {
                    // Streak indicator
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                            .imageScale(.small)
                        Text("\(currentStreakCount)")
                            .font(.caption.bold())
                            .monospacedDigit()
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                    .background(.ultraThinMaterial, in: Capsule())
                    .accessibilityLabel("Streak \(currentStreakCount) hari")

                    // Daily goal progress  
                    HStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .stroke(Color.primary.opacity(0.1), lineWidth: 2)
                                .frame(width: 16, height: 16)
                            Circle()
                                .trim(from: 0, to: dailyGoalProgress)
                                .stroke(Color.green, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                                .frame(width: 16, height: 16)
                                .rotationEffect(.degrees(-90))
                        }
                        Text("\(todayMinutes) min")
                            .font(.caption)
                            .monospacedDigit()
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                    .background(.ultraThinMaterial, in: Capsule())
                    .accessibilityLabel("Hari ini: \(todayMinutes) menit dari \(dailyGoalTarget) menit target")
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .selectModule)) { notification in
            if let module = notification.object as? ModuleType {
                selectedModule = module.rawValue
            }
        }
    }

    private var sidebar: some View {
        List(selection: $selectedModule) {
            Section(String(localized: "Belajar", comment: "Sidebar section")) {
                sidebarItem(.dashboard)
                sidebarItem(.dailyLesson)
                sidebarItem(.grammar)
                sidebarItem(.vocabulary)
                sidebarItem(.reading)
                sidebarItem(.listening)
                sidebarItem(.writing)
                sidebarItem(.speaking)
            }

            Section(String(localized: "Jelajahi", comment: "Sidebar section")) {
                sidebarItem(.immersion)
                sidebarItem(.levelTest)
            }

            Section(String(localized: "Progres", comment: "Sidebar section")) {
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

    private var currentStreakCount: Int {
        // Hitung streak dari DailyStreak records
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
}

struct PlaceholderModuleView: View {
    let module: ModuleType

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Text(module.displayName)
                .font(.largeTitle)
            Text(String(localized: "Modul ini sedang dalam pengembangan.", comment: "Placeholder"))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle(module.displayName)
    }
}

#Preview {
    ContentView()
}
