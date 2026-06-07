import Foundation

enum CEFRLevel: String, Codable, CaseIterable, Identifiable, Comparable {
    case a1, a2, b1, b2, c1, c2

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .a1: return "A1"
        case .a2: return "A2"
        case .b1: return "B1"
        case .b2: return "B2"
        case .c1: return "C1"
        case .c2: return "C2"
        }
    }

    var localizedName: String {
        switch self {
        case .a1: return String(localized: "Pemula", comment: "CEFR A1 level name")
        case .a2: return String(localized: "Dasar", comment: "CEFR A2 level name")
        case .b1: return String(localized: "Menengah", comment: "CEFR B1 level name")
        case .b2: return String(localized: "Menengah Atas", comment: "CEFR B2 level name")
        case .c1: return String(localized: "Mahir", comment: "CEFR C1 level name")
        case .c2: return String(localized: "Sangat Mahir", comment: "CEFR C2 level name")
        }
    }

    var vocabularyTarget: String {
        switch self {
        case .a1: return "600-700"
        case .a2: return "800-1000"
        case .b1: return "600-800"
        case .b2: return "500-700"
        case .c1: return "400-600"
        case .c2: return "300-500"
        }
    }

    private var sortOrder: Int {
        switch self {
        case .a1: return 0
        case .a2: return 1
        case .b1: return 2
        case .b2: return 3
        case .c1: return 4
        case .c2: return 5
        }
    }

    static func < (lhs: CEFRLevel, rhs: CEFRLevel) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }
}
