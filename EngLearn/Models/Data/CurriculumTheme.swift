import Foundation

enum CurriculumTheme: String, Codable, CaseIterable, Sendable {
    case meAndMyFriends = "me_and_my_friends"
    case meAndMySchool = "me_and_my_school"
    case meAndMyFamily = "me_and_my_family"
    case meAndMyWorld = "me_and_my_world"
    case ourCommunities = "our_communities"
    case ourHeritage = "our_heritage"
    case ourWorld = "our_world"
    case visionsOfTheFuture = "visions_of_the_future"
    case ourLives = "our_lives"
    case ourSociety = "our_society"
    case ourEnvironment = "our_environment"
    case ourFuture = "our_future"

    var localizedName: String {
        switch self {
        case .meAndMyFriends: return String(localized: "Aku dan Temanku", comment: "Theme")
        case .meAndMySchool: return String(localized: "Aku dan Sekolahku", comment: "Theme")
        case .meAndMyFamily: return String(localized: "Aku dan Keluargaku", comment: "Theme")
        case .meAndMyWorld: return String(localized: "Aku dan Dunia Sekitar", comment: "Theme")
        case .ourCommunities: return String(localized: "Komunitas Kita", comment: "Theme")
        case .ourHeritage: return String(localized: "Warisan Kita", comment: "Theme")
        case .ourWorld: return String(localized: "Dunia Kita", comment: "Theme")
        case .visionsOfTheFuture: return String(localized: "Visi Masa Depan", comment: "Theme")
        case .ourLives: return String(localized: "Kehidupan Kita", comment: "Theme")
        case .ourSociety: return String(localized: "Masyarakat Kita", comment: "Theme")
        case .ourEnvironment: return String(localized: "Lingkungan Kita", comment: "Theme")
        case .ourFuture: return String(localized: "Masa Depan Kita", comment: "Theme")
        }
    }

    var cefrRange: ClosedRange<CEFRLevel> {
        switch self {
        case .meAndMyFriends, .meAndMySchool, .meAndMyFamily, .meAndMyWorld:
            return .a1 ... .a2
        case .ourCommunities, .ourHeritage, .ourWorld, .visionsOfTheFuture:
            return .b1 ... .b2
        case .ourLives, .ourSociety, .ourEnvironment, .ourFuture:
            return .c1 ... .c2
        }
    }
}
