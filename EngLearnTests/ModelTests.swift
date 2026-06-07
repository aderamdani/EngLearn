import Testing
@testable import EngLearn

@Suite("CEFRLevel Tests")
struct CEFRLevelTests {
    @Test("All levels have display names")
    func displayNames() {
        for level in CEFRLevel.allCases {
            #expect(!level.displayName.isEmpty)
            #expect(!level.localizedName.isEmpty)
        }
    }

    @Test("Levels are ordered correctly")
    func ordering() {
        #expect(CEFRLevel.a1 < CEFRLevel.a2)
        #expect(CEFRLevel.a2 < CEFRLevel.b1)
        #expect(CEFRLevel.b1 < CEFRLevel.b2)
        #expect(CEFRLevel.b2 < CEFRLevel.c1)
        #expect(CEFRLevel.c1 < CEFRLevel.c2)
    }

    @Test("All levels have vocabulary targets")
    func vocabularyTargets() {
        for level in CEFRLevel.allCases {
            #expect(!level.vocabularyTarget.isEmpty)
        }
    }

    @Test("Level raw values match expected strings", arguments: [
        (CEFRLevel.a1, "a1"),
        (CEFRLevel.a2, "a2"),
        (CEFRLevel.b1, "b1"),
        (CEFRLevel.b2, "b2"),
        (CEFRLevel.c1, "c1"),
        (CEFRLevel.c2, "c2")
    ])
    func rawValues(level: CEFRLevel, expected: String) {
        #expect(level.rawValue == expected)
    }
}

@Suite("Exercise Tests")
struct ExerciseTests {
    @Test("CorrectAnswer index comparison")
    func indexAnswer() {
        let answer = CorrectAnswer.index(2)
        #expect(answer.isCorrect(selectedIndex: 2))
        #expect(!answer.isCorrect(selectedIndex: 0))
    }

    @Test("CorrectAnswer text comparison is case-insensitive")
    func textAnswer() {
        let answer = CorrectAnswer.text("cooks")
        #expect(answer.isCorrect(inputText: "cooks"))
        #expect(answer.isCorrect(inputText: "Cooks"))
        #expect(answer.isCorrect(inputText: "  cooks  "))
        #expect(!answer.isCorrect(inputText: "cook"))
    }

    @Test("All exercise types have localized names")
    func localizedNames() {
        for type in ExerciseType.allCases {
            #expect(!type.localizedName.isEmpty)
        }
    }
}

@Suite("SM-2 Spaced Repetition Tests")
struct SpacedRepetitionTests {
    let service = SpacedRepetitionService()

    @Test("Quality 5 increases interval")
    func perfectAnswer() {
        let result = service.nextReviewDate(
            after: 5,
            currentEaseFactor: 2.5,
            currentInterval: 1,
            currentRepetitions: 0
        )
        #expect(result.newInterval == 1)
        #expect(result.newRepetitions == 1)
        #expect(result.newEaseFactor >= 2.5)
    }

    @Test("Quality 0 resets repetitions")
    func failedAnswer() {
        let result = service.nextReviewDate(
            after: 0,
            currentEaseFactor: 2.5,
            currentInterval: 10,
            currentRepetitions: 5
        )
        #expect(result.newInterval == 1)
        #expect(result.newRepetitions == 0)
    }

    @Test("Ease factor never drops below minimum")
    func minimumEaseFactor() {
        var ef = 2.5
        var interval = 1
        var reps = 0

        for _ in 0..<20 {
            let result = service.nextReviewDate(
                after: 0,
                currentEaseFactor: ef,
                currentInterval: interval,
                currentRepetitions: reps
            )
            ef = result.newEaseFactor
            interval = result.newInterval
            reps = result.newRepetitions
        }

        #expect(ef >= AppConstants.SM2.minimumEaseFactor)
    }

    @Test("Second correct review gives 6-day interval")
    func secondReview() {
        let first = service.nextReviewDate(
            after: 4,
            currentEaseFactor: 2.5,
            currentInterval: 1,
            currentRepetitions: 0
        )
        let second = service.nextReviewDate(
            after: 4,
            currentEaseFactor: first.newEaseFactor,
            currentInterval: first.newInterval,
            currentRepetitions: first.newRepetitions
        )
        #expect(second.newInterval == 6)
    }
}

@Suite("SkillType Tests")
struct SkillTypeTests {
    @Test("All skills have SF Symbol names")
    func symbolNames() {
        for skill in SkillType.allCases {
            #expect(!skill.systemImage.isEmpty)
        }
    }

    @Test("All skills have localized names in Indonesian")
    func localizedNames() {
        for skill in SkillType.allCases {
            #expect(!skill.localizedName.isEmpty)
        }
    }
}

@Suite("CurriculumTheme Tests")
struct CurriculumThemeTests {
    @Test("A1-A2 themes cover beginner levels")
    func beginnerThemes() {
        let beginnerThemes: [CurriculumTheme] = [
            .meAndMyFriends, .meAndMySchool, .meAndMyFamily, .meAndMyWorld
        ]
        for theme in beginnerThemes {
            #expect(theme.cefrRange.contains(.a1))
            #expect(theme.cefrRange.contains(.a2))
            #expect(!theme.cefrRange.contains(.b1))
        }
    }
}
