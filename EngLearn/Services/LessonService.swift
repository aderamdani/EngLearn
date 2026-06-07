import Foundation
import OSLog

@MainActor
final class LessonService: Sendable {
    private var cache: [String: [Lesson]] = [:]

    func lessons(for skill: SkillType, level: CEFRLevel) throws -> [Lesson] {
        let cacheKey = "\(skill.rawValue)_\(level.rawValue)"

        if let cached = cache[cacheKey] {
            return cached
        }

        let fileName = "\(skill.rawValue)_\(level.rawValue)"

        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            Log.lessons.warning("No curriculum file found: \(fileName).json")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let lessons = try decoder.decode([Lesson].self, from: data)
            cache[cacheKey] = lessons
            Log.lessons.info("Loaded \(lessons.count) lessons from \(fileName).json")
            return lessons
        } catch {
            Log.lessons.error("Failed to decode \(fileName).json: \(error)")
            throw AppError.jsonDecodingFailed(file: fileName, underlying: error)
        }
    }

    func lesson(by id: String, skill: SkillType, level: CEFRLevel) throws -> Lesson {
        let all = try lessons(for: skill, level: level)
        guard let lesson = all.first(where: { $0.id == id }) else {
            throw AppError.lessonNotFound(id: id)
        }
        return lesson
    }

    func clearCache() {
        cache.removeAll()
        Log.lessons.info("Lesson cache cleared")
    }
}
