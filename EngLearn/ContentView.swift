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
                streakIndicator
                dailyGoalRing
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

    private var streakIndicator: some View {
        let count = streaks.count // Placeholder logic
        return Label("\(count)", systemImage: "flame.fill")
            .foregroundStyle(count > 0 ? .orange : .secondary)
            .accessibilityLabel(String(localized: "Streak: \(count) hari", comment: "Streak counter"))
    }

    private var dailyGoalRing: some View {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let minutes = streaks.first(where: { calendar.isDate($0.date, inSameDayAs: today) })?.minutesSpent ?? 0
        let progress = min(Double(minutes) / Double(dailyGoalMinutes), 1.0)
        
        return Image(systemName: progress >= 1.0 ? "checkmark.circle.fill" : (progress > 0 ? "circle.dotted" : "circle"))
            .foregroundStyle(progress >= 1.0 ? .green : .secondary)
            .accessibilityLabel(String(localized: "Target harian: \(Int(progress * 100))% selesai", comment: "Daily goal"))
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
