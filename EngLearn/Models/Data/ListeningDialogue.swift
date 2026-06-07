import Foundation

struct ListeningDialogue: Codable, Identifiable, Sendable {
    let id: String
    let title: String
    let audioScript: String
    let speed: Double
    let speakerCount: Int
    let exercises: [DictationExercise]
}

struct DictationExercise: Codable, Identifiable, Sendable {
    let id: String
    let prompt: String
    let expectedText: String
    let hintID: String
    
    enum CodingKeys: String, CodingKey {
        case id, prompt, expectedText
        case hintID = "hint_id"
    }
}
