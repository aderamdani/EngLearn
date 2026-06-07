import Foundation

struct WritingPrompt: Codable, Identifiable, Sendable {
    let id: String
    let promptType: String
    let prompt: String // English
    let instructionID: String // Indonesian
    let wordCountTarget: Int
    let sampleAnswer: String
    let tipID: String
    
    enum CodingKeys: String, CodingKey {
        case id, promptType, prompt, wordCountTarget, sampleAnswer
        case instructionID = "instruction_id"
        case tipID = "tip_id"
    }
}
