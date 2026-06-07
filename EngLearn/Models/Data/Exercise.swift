import Foundation

struct Exercise: Codable, Identifiable, Sendable {
    let id: String
    let type: ExerciseType
    let prompt: String
    let options: [String]?
    let correct: CorrectAnswer
    let explanationID: String
    let hintID: String?
    let difficulty: Int
    let cefrCanDo: String

    enum CodingKeys: String, CodingKey {
        case id, type, prompt, options, correct, difficulty, cefrCanDo
        case explanationID = "explanation_id"
        case hintID = "hint_id"
    }
}

enum ExerciseType: String, Codable, CaseIterable, Sendable {
    case multipleChoice
    case fillBlank
    case reorder
    case matching
    case trueFalse
    case dictation
    case spokenResponse
    case freeWriting

    var localizedName: String {
        switch self {
        case .multipleChoice: return String(localized: "Pilihan Ganda", comment: "Exercise type")
        case .fillBlank: return String(localized: "Isi Bagian Kosong", comment: "Exercise type")
        case .reorder: return String(localized: "Susun Kalimat", comment: "Exercise type")
        case .matching: return String(localized: "Mencocokkan", comment: "Exercise type")
        case .trueFalse: return String(localized: "Benar atau Salah", comment: "Exercise type")
        case .dictation: return String(localized: "Dikte", comment: "Exercise type")
        case .spokenResponse: return String(localized: "Jawaban Lisan", comment: "Exercise type")
        case .freeWriting: return String(localized: "Menulis Bebas", comment: "Exercise type")
        }
    }
}

enum CorrectAnswer: Codable, Sendable {
    case index(Int)
    case text(String)
    case indices([Int])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intVal = try? container.decode(Int.self) {
            self = .index(intVal)
        } else if let strVal = try? container.decode(String.self) {
            self = .text(strVal)
        } else if let arrVal = try? container.decode([Int].self) {
            self = .indices(arrVal)
        } else {
            throw DecodingError.typeMismatch(
                CorrectAnswer.self,
                .init(codingPath: decoder.codingPath, debugDescription: "Expected Int, String, or [Int]")
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .index(let val): try container.encode(val)
        case .text(let val): try container.encode(val)
        case .indices(let val): try container.encode(val)
        }
    }

    func isCorrect(selectedIndex: Int) -> Bool {
        switch self {
        case .index(let correct): return selectedIndex == correct
        case .indices(let correct): return correct.contains(selectedIndex)
        case .text: return false
        }
    }

    func isCorrect(inputText: String) -> Bool {
        guard case .text(let correct) = self else { return false }
        return inputText.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased() == correct.lowercased()
    }
}
