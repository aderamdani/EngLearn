import Foundation

enum SkillType: String, Codable, CaseIterable, Identifiable {
    case grammar
    case vocabulary
    case reading
    case listening
    case writing
    case speaking
    case dailyLesson
    case immersion

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .grammar: return "Grammar"
        case .vocabulary: return "Vocabulary"
        case .reading: return "Reading"
        case .listening: return "Listening"
        case .writing: return "Writing"
        case .speaking: return "Speaking"
        case .dailyLesson: return "Daily Lesson"
        case .immersion: return "Immersion"
        }
    }

    var localizedName: String {
        switch self {
        case .grammar: return String(localized: "Tata Bahasa", comment: "Grammar module")
        case .vocabulary: return String(localized: "Kosakata", comment: "Vocabulary module")
        case .reading: return String(localized: "Membaca", comment: "Reading module")
        case .listening: return String(localized: "Mendengar", comment: "Listening module")
        case .writing: return String(localized: "Menulis", comment: "Writing module")
        case .speaking: return String(localized: "Berbicara", comment: "Speaking module")
        case .dailyLesson: return String(localized: "Pelajaran Harian", comment: "Daily lesson")
        case .immersion: return String(localized: "Zona Imersi", comment: "Immersion zone")
        }
    }

    var systemImage: String {
        switch self {
        case .grammar: return "textformat"
        case .vocabulary: return "character.book.closed"
        case .reading: return "book"
        case .listening: return "headphones"
        case .writing: return "pencil.line"
        case .speaking: return "waveform"
        case .dailyLesson: return "calendar"
        case .immersion: return "globe"
        }
    }
}

enum ModuleType: String, CaseIterable, Identifiable {
    case dashboard
    case dailyLesson
    case grammar
    case vocabulary
    case reading
    case listening
    case writing
    case speaking
    case immersion
    case levelTest
    case achievements
    case settings

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .dailyLesson: return "Daily Lesson"
        case .grammar: return "Grammar"
        case .vocabulary: return "Vocabulary"
        case .reading: return "Reading"
        case .listening: return "Listening"
        case .writing: return "Writing"
        case .speaking: return "Speaking"
        case .immersion: return "Immersion"
        case .levelTest: return "Level Test"
        case .achievements: return "Achievements"
        case .settings: return "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .dashboard: return "square.grid.2x2"
        case .dailyLesson: return "calendar"
        case .grammar: return "textformat"
        case .vocabulary: return "character.book.closed"
        case .reading: return "book"
        case .listening: return "headphones"
        case .writing: return "pencil.line"
        case .speaking: return "waveform"
        case .immersion: return "globe"
        case .levelTest: return "checkmark.seal"
        case .achievements: return "trophy"
        case .settings: return "gearshape"
        }
    }
}
