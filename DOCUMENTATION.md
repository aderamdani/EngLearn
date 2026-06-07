# EngLearn — Technical Documentation

## Architecture Overview

EngLearn follows MVVM-light architecture with these layers:

### Data Layer
- **Plain Structs** (immutable, from JSON): `CEFRLevel`, `Lesson`, `Module`, `Exercise`, `SkillType`, `CurriculumTheme`, `Phoneme`, `GrammarRule`
- **SwiftData Models** (mutable, persisted): `UserProgress`, `LessonRecord`, `VocabularyEntry`, `WritingEntry`, `SpeakingRecord`, `AchievementRecord`, `DailyStreak`
- **Migration**: `EngLearnMigrationPlan` with versioned schemas

### Service Layer
- `LessonService`: JSON loading from bundle, filtering by skill + level
- `SpacedRepetitionService`: SM-2 algorithm (ease factor, interval, next review)
- `SpeechRecognitionService`: Speech Framework wrapper, auto-stop on silence
- `AudioPlaybackService`: AVSpeechSynthesizer for TTS, AVAudioPlayer for phonemes
- `TextAnalysisService`: NaturalLanguage framework for writing analysis
- `AchievementService`: Achievement tracking and unlock logic
- `LevelTestService`: Adaptive placement test (15-20 questions)
- `LoggingService`: OSLog with 8 categories

### View Layer
- `ContentView`: NavigationSplitView with sidebar (12 items)
- Module views follow standard pattern: header, level picker, progress summary, content
- `SettingsView`: TabView with General, Audio, Notifications, About
- `OnboardingView`: 8-step first-run flow

## Data Flow

```
JSON (bundle) -> LessonService -> View (@Query)
User Action -> SwiftData (@Model) -> View (@Query auto-refresh)
Preferences -> @AppStorage -> View (auto-refresh)
Navigation -> @SceneStorage -> View (state restoration)
```

## Curriculum Structure

8 modules x 6 CEFR levels = 48 content sets. JSON files in Resources/Curriculum/.

Content sources (inspiration, not affiliation):
- CEFR Framework (Council of Europe) — public domain
- Oxford University Press ELT — grammar structure
- BBC Learning English — format inspiration
- British Council LearnEnglish — skills-based approach
- Cambridge English — activity formats
- Vietnam MoE Curriculum — theme-based spiral progression

## Performance Architecture

- Zero background processing
- Timer-free design (timestamp-based tracking)
- Lazy loading for all lists
- Per-level JSON loading (not all at once)
- .drawingGroup() on all charts
- Audio buffer cleanup on navigate away
- @ObservationIgnored on non-UI properties

## Security

- App Sandbox enabled
- Hardened Runtime enabled
- Zero network requests
- Zero telemetry
- All data local (SwiftData + UserDefaults)
- Microphone access: user-initiated only, for Speaking module
