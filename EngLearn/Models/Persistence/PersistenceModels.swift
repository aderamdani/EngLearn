import Foundation
import SwiftData

@Model
final class UserProgress {
    var currentLevel: String
    var totalLessonsCompleted: Int
    var totalExercisesCompleted: Int
    var totalCorrectAnswers: Int
    var totalTimeSpentSeconds: Int
    var onboardingCompleted: Bool
    var placementTestTaken: Bool
    var lastActiveDate: Date
    var createdAt: Date

    init(
        currentLevel: CEFRLevel = .a1,
        onboardingCompleted: Bool = false
    ) {
        self.currentLevel = currentLevel.rawValue
        self.totalLessonsCompleted = 0
        self.totalExercisesCompleted = 0
        self.totalCorrectAnswers = 0
        self.totalTimeSpentSeconds = 0
        self.onboardingCompleted = onboardingCompleted
        self.placementTestTaken = false
        self.lastActiveDate = Date()
        self.createdAt = Date()
    }

    var level: CEFRLevel {
        CEFRLevel(rawValue: currentLevel) ?? .a1
    }

    var accuracyPercentage: Double {
        guard totalExercisesCompleted > 0 else { return 0 }
        return Double(totalCorrectAnswers) / Double(totalExercisesCompleted) * 100
    }
}

@Model
final class LessonRecord {
    var lessonID: String
    var skill: String
    var level: String
    var completedAt: Date
    var score: Int
    var totalExercises: Int
    var correctAnswers: Int
    var timeSpentSeconds: Int

    init(
        lessonID: String,
        skill: SkillType,
        level: CEFRLevel,
        score: Int,
        totalExercises: Int,
        correctAnswers: Int,
        timeSpentSeconds: Int
    ) {
        self.lessonID = lessonID
        self.skill = skill.rawValue
        self.level = level.rawValue
        self.completedAt = Date()
        self.score = score
        self.totalExercises = totalExercises
        self.correctAnswers = correctAnswers
        self.timeSpentSeconds = timeSpentSeconds
    }

    var scorePercentage: Double {
        guard totalExercises > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalExercises) * 100
    }
}

@Model
final class VocabularyEntry {
    var word: String
    var level: String
    var partOfSpeech: String
    var definitionEN: String
    var definitionID: String
    var phonetic: String
    var exampleSentence: String
    var contextID: String
    var theme: String
    var collocations: [String]
    var easeFactor: Double
    var interval: Int
    var repetitions: Int
    var nextReviewDate: Date
    var lastReviewedAt: Date?
    var createdAt: Date

    init(
        word: String,
        level: CEFRLevel = .a1,
        partOfSpeech: String = "",
        definitionEN: String = "",
        definitionID: String = "",
        phonetic: String = "",
        exampleSentence: String = "",
        contextID: String = "",
        theme: String = "",
        collocations: [String] = []
    ) {
        self.word = word
        self.level = level.rawValue
        self.partOfSpeech = partOfSpeech
        self.definitionEN = definitionEN
        self.definitionID = definitionID
        self.phonetic = phonetic
        self.exampleSentence = exampleSentence
        self.contextID = contextID
        self.theme = theme
        self.collocations = collocations
        self.easeFactor = AppConstants.SM2.defaultEaseFactor
        self.interval = AppConstants.SM2.initialInterval
        self.repetitions = 0
        self.nextReviewDate = Date()
        self.lastReviewedAt = nil
        self.createdAt = Date()
    }

    var isDueForReview: Bool {
        nextReviewDate <= Date()
    }

    func updateAfterReview(quality: Int) {
        let q = max(0, min(AppConstants.SM2.maxQuality, quality))

        if q >= 3 {
            if repetitions == 0 {
                interval = 1
            } else if repetitions == 1 {
                interval = 6
            } else {
                interval = Int(Double(interval) * easeFactor)
            }
            repetitions += 1
        } else {
            repetitions = 0
            interval = 1
        }

        let ef = easeFactor + (0.1 - Double(5 - q) * (0.08 + Double(5 - q) * 0.02))
        easeFactor = max(AppConstants.SM2.minimumEaseFactor, ef)

        nextReviewDate = Calendar.current.date(
            byAdding: .day, value: interval, to: Date()
        ) ?? Date()
        lastReviewedAt = Date()
    }
}

@Model
final class WritingEntry {
    var promptID: String
    var level: String
    var promptText: String
    var userText: String
    var wordCount: Int
    var createdAt: Date
    var updatedAt: Date

    init(promptID: String, level: CEFRLevel, promptText: String) {
        self.promptID = promptID
        self.level = level.rawValue
        self.promptText = promptText
        self.userText = ""
        self.wordCount = 0
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    func updateText(_ text: String) {
        userText = text
        wordCount = text.split(separator: " ").count
        updatedAt = Date()
    }
}

@Model
final class SpeakingRecord {
    var exerciseID: String
    var level: String
    var recognizedText: String
    var targetText: String
    var accuracyScore: Double
    var completedAt: Date

    init(
        exerciseID: String,
        level: CEFRLevel,
        recognizedText: String,
        targetText: String,
        accuracyScore: Double
    ) {
        self.exerciseID = exerciseID
        self.level = level.rawValue
        self.recognizedText = recognizedText
        self.targetText = targetText
        self.accuracyScore = accuracyScore
        self.completedAt = Date()
    }
}

@Model
final class AchievementRecord {
    var achievementID: String
    var title: String
    var descriptionText: String
    var unlockedAt: Date

    init(achievementID: String, title: String, descriptionText: String) {
        self.achievementID = achievementID
        self.title = title
        self.descriptionText = descriptionText
        self.unlockedAt = Date()
    }
}

@Model
final class DailyStreak {
    var date: Date
    var minutesSpent: Int
    var lessonsCompleted: Int
    var exercisesCompleted: Int

    init(date: Date = .now) {
        self.date = Calendar.current.startOfDay(for: date)
        self.minutesSpent = 0
        self.lessonsCompleted = 0
        self.exercisesCompleted = 0
    }

    func addActivity(minutes: Int, lessons: Int, exercises: Int) {
        minutesSpent += minutes
        lessonsCompleted += lessons
        exercisesCompleted += exercises
    }
}
