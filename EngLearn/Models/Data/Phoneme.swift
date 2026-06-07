import Foundation

struct Phoneme: Codable, Identifiable, Sendable {
    var id: String { phoneme }
    let phoneme: String
    let ipaSymbol: String
    let exampleWords: [String]
    let descriptionID: String
    let mouthPositionID: String
    let commonMistakeID: String
    
    enum CodingKeys: String, CodingKey {
        case phoneme, ipaSymbol, exampleWords
        case descriptionID = "description_id"
        case mouthPositionID = "mouthPosition_id"
        case commonMistakeID = "commonMistake_id"
    }
}
