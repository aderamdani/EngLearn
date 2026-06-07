import Foundation
import SwiftData
import OSLog

@MainActor
final class VocabularyService: Sendable {
    private var cache: [String: [VocabularyDTO]] = [:]

    struct VocabularyDTO: Codable {
        let word: String
        let phonetic: String
        let partOfSpeech: String
        let definition_en: String
        let definition_id: String
        let exampleSentence: String
        let context_id: String
        let collocations: [String]
        let theme: String
    }

    func loadVocabulary(for level: CEFRLevel) throws -> [VocabularyDTO] {
        let cacheKey = level.rawValue
        if let cached = cache[cacheKey] {
            return cached
        }

        let fileName = "vocabulary_\(level.rawValue)"
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            Log.data.warning("No vocabulary file found: \(fileName).json")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let vocab = try decoder.decode([VocabularyDTO].self, from: data)
            cache[cacheKey] = vocab
            Log.data.info("Loaded \(vocab.count) words from \(fileName).json")
            return vocab
        } catch {
            Log.data.error("Failed to decode \(fileName).json: \(error)")
            throw AppError.jsonDecodingFailed(file: fileName, underlying: error)
        }
    }

    func seedInitialData(modelContext: ModelContext, level: CEFRLevel) async throws {
        let dtos = try loadVocabulary(for: level)
        
        // Fetch existing words for this level to avoid duplicates
        let levelString = level.rawValue
        let descriptor = FetchDescriptor<VocabularyEntry>(
            predicate: #Predicate { $0.level == levelString }
        )
        let existingEntries = try modelContext.fetch(descriptor)
        let existingWords = Set(existingEntries.map { $0.word.lowercased() })

        for dto in dtos {
            if !existingWords.contains(dto.word.lowercased()) {
                let entry = VocabularyEntry(
                    word: dto.word,
                    level: level,
                    partOfSpeech: dto.partOfSpeech,
                    definitionEN: dto.definition_en,
                    definitionID: dto.definition_id,
                    phonetic: dto.phonetic,
                    exampleSentence: dto.exampleSentence,
                    contextID: dto.context_id,
                    theme: dto.theme,
                    collocations: dto.collocations
                )
                modelContext.insert(entry)
            }
        }
        
        try modelContext.save()
        Log.data.info("Seeded vocabulary for level \(level.displayName)")
    }
}
