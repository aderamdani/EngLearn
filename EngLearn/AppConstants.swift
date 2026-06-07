import SwiftUI

enum AppConstants {
    static let bundleID = "com.aderamdani.EngLearn"
    static let logSubsystem = bundleID
    static let appName = "EngLearn"

    enum SM2 {
        static let defaultEaseFactor: Double = 2.5
        static let minimumEaseFactor: Double = 1.3
        static let initialInterval: Int = 1
        static let maxQuality: Int = 5
    }

    enum Limits {
        static let maxDailyGoalMinutes = 60
        static let minDailyGoalMinutes = 5
        static let maxStreakDays = 365
        static let flashcardFlipDuration: Double = 0.4
        static let exerciseTimeoutSeconds: Double = 120
        static let speechSilenceTimeout: Double = 10
        static let writingAutosaveDebounce: Double = 2.0
        static let ttsSlowRate: Double = 0.3
        static let ttsNormalRate: Double = 0.5
        static let ttsFastRate: Double = 0.7
    }

    enum Window {
        static let defaultWidth: CGFloat = 1200
        static let defaultHeight: CGFloat = 800
        static let minWidth: CGFloat = 900
        static let minHeight: CGFloat = 600
        static let sidebarMinWidth: CGFloat = 200
        static let sidebarIdealWidth: CGFloat = 220
        static let sidebarMaxWidth: CGFloat = 260
    }
}

enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32
}

enum CornerRadius {
    static let standard: CGFloat = 10
    static let card: CGFloat = 12
    static let hero: CGFloat = 16
}

extension Color {
    static let correctAnswer = Color.green
    static let incorrectAnswer = Color.orange
    static let levelA1 = Color.green
    static let levelA2 = Color.teal
    static let levelB1 = Color.blue
    static let levelB2 = Color.purple
    static let levelC1 = Color.orange
    static let levelC2 = Color.red
}

extension ShapeStyle where Self == Color {
    static func cefrColor(for level: CEFRLevel) -> Color {
        switch level {
        case .a1: return .levelA1
        case .a2: return .levelA2
        case .b1: return .levelB1
        case .b2: return .levelB2
        case .c1: return .levelC1
        case .c2: return .levelC2
        }
    }
}
