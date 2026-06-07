import SwiftUI

struct ContentView: View {
    @SceneStorage("selectedModule") private var selectedModule: String?
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var searchQuery = ""

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
        Label("0", systemImage: "flame")
            .foregroundStyle(.orange)
            .accessibilityLabel(String(localized: "Streak: 0 hari", comment: "Streak counter"))
    }

    private var dailyGoalRing: some View {
        Image(systemName: "circle")
            .foregroundStyle(.secondary)
            .accessibilityLabel(String(localized: "Target harian: belum dimulai", comment: "Daily goal"))
    }
}

struct OnboardingView: View {
    var body: some View {
        VStack(spacing: Spacing.xxl) {
            Text(AppConstants.appName)
                .font(.largeTitle)
            Text(String(localized: "Belajar Bahasa Inggris dari A1 sampai C2", comment: "Onboarding tagline"))
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .frame(
            minWidth: AppConstants.Window.minWidth,
            minHeight: AppConstants.Window.minHeight
        )
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
