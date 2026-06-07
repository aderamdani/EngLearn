import Foundation

struct Lesson: Codable, Identifiable, Sendable {
    let id: String
    let skill: SkillType
    let level: CEFRLevel
    let title: String
    let theme: String
    let cefrCanDo: String
    let explanation: GrammarExplanation?
    let exercises: [Exercise]
}

struct GrammarExplanation: Codable, Sendable {
    let ruleID: String
    let ruleEN: String
    let examples: [String]
    let exceptions: [String]?
    let tipID: String?

    enum CodingKeys: String, CodingKey {
        case ruleID = "rule_id"
        case ruleEN = "rule_en"
        case examples, exceptions
        case tipID = "tip_id"
    }
}

struct Module: Identifiable, Sendable {
    let id: SkillType
    let level: CEFRLevel
    let lessons: [Lesson]

    var lessonCount: Int { lessons.count }
    var exerciseCount: Int { lessons.reduce(0) { $0 + $1.exercises.count } }
}
