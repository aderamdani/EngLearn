# EngLearn — GEMINI.md

Specialized instructions for Gemini CLI. Focus: build optimization, testing, SwiftUI performance, concurrency safety.

---

## Swift Engineering Rules

### Progressive Architecture
- Start with direct implementation. Extract protocol only when second implementation exists.
- NO God objects: if a type exceeds 300 lines, decompose.
- Inject all dependencies via init for testability.
- Default `private`. All classes `final`. Value types over reference types.

### Error Handling
- Exhaustive enums with associated values. Every case has recovery path.
- NEVER force unwrap (`!`, `try!`, `as!`). Use `guard let` or `if let`.
- NEVER stringly-typed APIs. Use enums or constants.

### Quality Gates (verify before every commit)
- [ ] No force unwrapping
- [ ] All errors have recovery paths (in Bahasa Indonesia)
- [ ] Dependencies injected via init
- [ ] No retained cycles (use `[weak self]` where needed)
- [ ] `make build` clean — zero errors, zero warnings

---

## SwiftUI Agent Rules

### View Composition
- View `body` MAX 50 lines. Extract subviews via computed properties.
- NEVER `AnyView`. Use `@ViewBuilder` or `some View`.
- Prefer `Group {}` over `AnyView` for conditional views.
- Use `.task {}` instead of `.onAppear { Task {} }`.

### State Management
- `@State` for view-local transient state only.
- `@Query` for SwiftData reads.
- `@AppStorage` for user preferences.
- `@Observable` for shared ViewModel state.
- NEVER store derived data in `@State` — compute inline.
- NEVER modify `@State` during body evaluation.

### Deprecated API (NEVER use)
- `NavigationView` -> `NavigationSplitView` or `NavigationStack`
- `.navigationBarTitle()` -> `.navigationTitle()`
- `GeometryReader` for alignment -> `.frame()` or layout containers
- `.onAppear` for async -> `.task` modifier
- `@StateObject` -> `@State` with `@Observable` on macOS 26+

### Performance
- `LazyVStack`/`LazyHStack` for scrollable lists.
- `.drawingGroup()` for charts and complex overlapping views.
- Minimize `.onChange()` — prefer derived state.
- `ForEach`: stable `Identifiable` id. NEVER array index.
- `@ObservationIgnored` on non-UI properties.
- NO `Timer.publish`. Use `.task` with `Task.sleep` or `TimelineView`.

### Accessibility
- Every interactive element: `.accessibilityLabel()`.
- Every `Image(systemName:)` as button: `.accessibilityLabel()`.
- `.accessibilityValue()` for dynamic data.
- `.accessibilityElement(children: .combine)` for groups.

---

## Swift 6 Concurrency Rules

### MainActor Isolation
- All ViewModels and Services with UI updates MUST be `@MainActor`.
- NEVER `DispatchQueue.main.async`. Use `@MainActor` isolation.
- Background work: `Task.detached` or `nonisolated`, then hop back.

### Sendable Compliance
- All types crossing concurrency boundaries: `Sendable`.
- `@unchecked Sendable` only as last resort with documented justification.

### Task Management
- Store `Task` handles, cancel in `.onDisappear` or deinit.
- `withTaskGroup` for parallel operations.
- Prefer structured concurrency (`async let`, `TaskGroup`) over unstructured `Task {}`.

---

## Xcode Build Optimization

### Build Settings
- `SWIFT_COMPILATION_CACHING = YES`
- `SWIFT_TREAT_WARNINGS_AS_ERRORS = YES`
- `EAGER_LINKING = YES` (Debug only)
- `SWIFT_COMPILATION_MODE = singlefile` (Debug), `wholemodule` (Release)

### Code-Level
- Break complex type inference into typed intermediate `let` bindings.
- String interpolation over `+` concatenation.
- Minimize type-erasing wrappers.
- Explicit return types on complex computed properties.

---

## Performance Budgets

| Metric | Budget |
| --- | --- |
| Cold launch | <2s |
| Idle CPU | <3% |
| Idle memory | <150 MB |
| View transition | <100ms |
| Flashcard flip | 60fps |

---

## Language Policy
- UI labels: English
- Penjelasan ke user: Bahasa Indonesia (casual, "kamu")
- Error messages: Bahasa Indonesia with recovery suggestions
- Curriculum content: English

---

## Anti-Slop (same as CLAUDE.md)

1. NEVER `.background(Color(...).opacity(...))`. ALWAYS `.regularMaterial` + `.glassEffect()`.
2. NEVER box-in-box. Flat hierarchy.
3. NEVER ALL CAPS. Sentence Case.
4. NEVER massive empty state icons. Silent `.secondary` text.
5. NEVER emojis. SF Symbols.
6. NEVER `print()`. Use `Log.xxx`.
7. NEVER hardcoded spacing. Use `Spacing.xxx`.
8. NEVER `Timer.publish`. Use `.task` or `TimelineView`.

---

## Incremental Workflow
1 task = 1 commit = 1 push. `make build` before commit. Conventional commits.

---

## Release Procedure
Same as CLAUDE.md. SemVer. `build_dmg.sh`. `git tag` + `gh release create`.

---

## Technical Context: EngLearn

### Data Flow
- **Plain structs** (from JSON): `CEFRLevel`, `Lesson`, `Module`, `Exercise`, `SkillType`
- **SwiftData @Model**: `UserProgress`, `LessonRecord`, `VocabularyEntry`, `WritingEntry`, `SpeakingRecord`, `AchievementRecord`, `DailyStreak`
- **LessonService**: JSON from bundle, filter by skill + level
- **SM-2**: `VocabularyEntry.updateAfterReview(quality:)`. Quality 0-5.
- **Migration**: `EngLearnMigrationPlan` with `SchemaV1`
