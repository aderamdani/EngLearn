import SwiftUI
import SwiftData

@main
struct EngLearnApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .defaultSize(
            width: AppConstants.Window.defaultWidth,
            height: AppConstants.Window.defaultHeight
        )
        .windowResizability(.contentMinSize)
        .modelContainer(for: [
            UserProgress.self,
            LessonRecord.self,
            VocabularyEntry.self,
            WritingEntry.self,
            SpeakingRecord.self,
            AchievementRecord.self,
            DailyStreak.self
        ])
        .commands {
            CommandGroup(replacing: .newItem) {
                Button(String(localized: "New Writing Entry", comment: "Menu item")) {
                    NotificationCenter.default.post(name: .newWritingEntry, object: nil)
                }
                .keyboardShortcut("N")
            }

            CommandMenu(String(localized: "Modules", comment: "Menu title")) {
                Button("Dashboard") { selectModule(.dashboard) }
                    .keyboardShortcut("1")
                Button("Daily Lesson") { selectModule(.dailyLesson) }
                    .keyboardShortcut("2")
                Button("Grammar") { selectModule(.grammar) }
                    .keyboardShortcut("3")
                Button("Vocabulary") { selectModule(.vocabulary) }
                    .keyboardShortcut("4")
                Button("Reading") { selectModule(.reading) }
                    .keyboardShortcut("5")
                Button("Listening") { selectModule(.listening) }
                    .keyboardShortcut("6")
                Button("Writing") { selectModule(.writing) }
                    .keyboardShortcut("7")
                Button("Speaking") { selectModule(.speaking) }
                    .keyboardShortcut("8")
            }

            CommandMenu(String(localized: "Learn", comment: "Menu title")) {
                Button(String(localized: "Start Daily Lesson", comment: "Menu item")) {
                    selectModule(.dailyLesson)
                }
                .keyboardShortcut("D", modifiers: [.command, .shift])

                Button(String(localized: "Take Level Test", comment: "Menu item")) {
                    selectModule(.levelTest)
                }

                Divider()

                Button(String(localized: "Search Lessons", comment: "Menu item")) {
                    NotificationCenter.default.post(name: .focusSearch, object: nil)
                }
                .keyboardShortcut("F")
            }
        }

        #if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }

    private func selectModule(_ module: ModuleType) {
        NotificationCenter.default.post(
            name: .selectModule,
            object: module
        )
    }
}

extension Notification.Name {
    static let selectModule = Notification.Name("selectModule")
    static let newWritingEntry = Notification.Name("newWritingEntry")
    static let focusSearch = Notification.Name("focusSearch")
}
