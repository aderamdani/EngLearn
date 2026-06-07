import Foundation

struct ReadingPassage: Codable, Identifiable, Sendable {
    let id: String
    let title: String
    let passageText: String
    let wordCount: Int
    let vocabulary: [String]
    let comprehensionQuiz: [ComprehensionQuestion]
}

struct ComprehensionQuestion: Codable, Identifiable, Sendable {
    let id: String
    let question: String
    let options: [String]
    let correctIndex: Int
    let explanationID: String
    let hintID: String
    
    enum CodingKeys: String, CodingKey {
        case id, question, options, correctIndex
        case explanationID = "explanation_id"
        case hintID = "hint_id"
    }
}
