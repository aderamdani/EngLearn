# Changelog

All notable changes to EngLearn will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-06-07

### Added
- SwiftData persistence models: UserProgress, LessonRecord, VocabularyEntry, WritingEntry, SpeakingRecord, AchievementRecord, DailyStreak
- Schema versioning with MigrationPlan (SchemaV1)
- Data structs: Exercise (with CorrectAnswer enum), Lesson (with GrammarExplanation), Module, CurriculumTheme
- ExerciseType enum with 8 types and Indonesian localized names
- CurriculumTheme enum with spiral progression (A1-A2 -> B1-B2 -> C1-C2)
- LessonService with JSON loading and in-memory caching
- SpacedRepetitionService implementing SM-2 algorithm
- Sample curriculum: grammar_a1.json (Present Simple, 5 exercises with Indonesian explanations)
- Unit tests: CEFRLevel ordering, Exercise answer validation, SM-2 algorithm, SkillType, CurriculumTheme

## [0.1.0] - 2026-06-07

### Added
- Xcode project with ARM64-only enterprise configuration
- SwiftUI NavigationSplitView with sidebar navigation (8 modules)
- Design tokens: AppConstants, Spacing, CornerRadius, semantic colors
- Structured logging via OSLog (8 categories)
- Centralized error handling (AppError) with Indonesian messages
- Generic LoadingState<T> enum
- CEFRLevel (A1-C2) and SkillType/ModuleType enums
- SettingsView with preferences, audio, notifications, debug
- Makefile with build/run/test/clean/dmg/lint commands
- SwiftLint config with 8 anti-slop custom rules
- GitHub Actions CI/CD (build, test, lint, release)
- PR template and issue templates
- Complete documentation set (CLAUDE.md, GEMINI.md, OPENROUTER.md, SKILL.md)
- README with bilingual description (English + Bahasa Indonesia)
- Community standards (CONTRIBUTING, SECURITY, LICENSE)
- Build scripts (build_dmg.sh, notarize.sh)
- Privacy manifest (PrivacyInfo.xcprivacy)
- App Sandbox entitlements with microphone access
