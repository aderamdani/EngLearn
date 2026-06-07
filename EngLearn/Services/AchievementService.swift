import Foundation
import SwiftData
import OSLog

@MainActor
final class AchievementService: Sendable {
    struct AchievementDTO: Codable {
        let id: String
        let title: String
        let description_id: String
        let icon: String
        let requirement: String
    }

    func loadAchievements() -> [AchievementDTO] {
        guard let url = Bundle.main.url(forResource: "achievements", withExtension: "json") else {
            Log.data.error("Achievements JSON file not found")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([AchievementDTO].self, from: data)
        } catch {
            Log.data.error("Failed to decode achievements: \(error)")
            return []
        }
    }

    func checkAndUnlock(modelContext: ModelContext) async {
        Log.general.info("Checking for new achievements...")
        
        let dtos = loadAchievements()
        let unlockedDescriptor = FetchDescriptor<AchievementRecord>()
        let unlockedIDs = Set((try? modelContext.fetch(unlockedDescriptor))?.map { $0.achievementID } ?? [])

        let userProgressDescriptor = FetchDescriptor<UserProgress>()
        guard let userProgress = (try? modelContext.fetch(userProgressDescriptor))?.first else { return }

        let lessonRecordsDescriptor = FetchDescriptor<LessonRecord>()
        let lessonRecords = (try? modelContext.fetch(lessonRecordsDescriptor)) ?? []

        let vocabDescriptor = FetchDescriptor<VocabularyEntry>()
        let vocabEntries = (try? modelContext.fetch(vocabDescriptor)) ?? []

        for dto in dtos {
            if unlockedIDs.contains(dto.id) { continue }

            if shouldUnlock(dto: dto, progress: userProgress, lessons: lessonRecords, vocab: vocabEntries) {
                let newRecord = AchievementRecord(
                    achievementID: dto.id,
                    title: dto.title,
                    descriptionText: dto.description_id
                )
                modelContext.insert(newRecord)
                Log.general.info("Unlocked achievement: \(dto.title)")
            }
        }
        
        try? modelContext.save()
    }

    private func shouldUnlock(dto: AchievementDTO, progress: UserProgress, lessons: [LessonRecord], vocab: [VocabularyEntry]) -> Bool {
        switch dto.id {
        case "first_lesson":
            return progress.totalLessonsCompleted >= 1
        case "streak_7":
            return false // Simplified for now
        case "grammar_a1_master":
            return lessons.filter { $0.skill == SkillType.grammar.rawValue && $0.level == CEFRLevel.a1.rawValue }.count >= 3
        case "vocab_100":
            return vocab.count >= 100
        case "reading_5":
            return lessons.filter { $0.skill == SkillType.reading.rawValue }.count >= 5
        case "perfect_score":
            return lessons.contains { $0.scorePercentage >= 100 }
        default:
            return false
        }
    }
}
