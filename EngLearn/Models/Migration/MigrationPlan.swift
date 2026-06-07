import Foundation
import SwiftData

enum EngLearnMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}

enum SchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            UserProgress.self,
            LessonRecord.self,
            VocabularyEntry.self,
            WritingEntry.self,
            SpeakingRecord.self,
            AchievementRecord.self,
            DailyStreak.self
        ]
    }
}
