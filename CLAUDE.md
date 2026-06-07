# EngLearn — CLAUDE.md

Native macOS interactive English learning app. SwiftUI, SwiftData, Swift 6, macOS 26+ (Tahoe). Liquid Glass UI. ARM64 only. Zero third-party dependencies.

---

## Build & Run

```
make build     # Build (arm64, Debug, xcbeautify)
make run       # Build + launch app
make test      # Run tests with coverage
make clean     # Clean DerivedData
make dmg       # Archive + build DMG
make lint      # SwiftLint --strict
make version   # Show current version
```

## Key Technologies

- **SwiftUI**: Declarative UI with Liquid Glass effects (macOS 26+)
- **SwiftData**: Persistence for user progress, lesson records, vocabulary
- **Swift Charts**: Progress visualization, skill radar, streak heatmap
- **AVFoundation**: TTS audio playback for listening exercises
- **Speech Framework**: Speech-to-text for pronunciation feedback
- **NaturalLanguage**: Text analysis for writing exercises
- **OSLog**: Structured logging (NEVER use print())

---

## Architecture Patterns

- **MVVM-light**: Views own state via `@Query`, `@State`, `@AppStorage`. Service classes for complex business logic only.
- **@Observable**: For shared state. Use `@State` on owning view, `@Bindable` for child bindings.
- **MainActor Isolation**: All UI-facing logic strictly isolated to main thread.
- **NavigationSplitView**: Top-level navigation. NavigationStack only inside detail views for sub-screens.
- **LessonService**: Centralized JSON loader — `LessonService.lessons(for:level:)` loads from bundle.
- **SwiftData Models**: `UserProgress`, `LessonRecord`, `VocabularyEntry`, `WritingEntry`, `SpeakingRecord`, `AchievementRecord`, `DailyStreak`.
- **Plain Structs**: `Lesson`, `Module`, `Exercise`, `CEFRLevel`, `SkillType`, `Phoneme`, `GrammarRule` — read-only from JSON.
- **Spaced Repetition**: SM-2 algorithm in `VocabularyEntry.updateAfterReview(quality:)`.
- **Error Handling**: Centralized `AppError` enum. Every error has `recoverySuggestion` in Bahasa Indonesia.
- **Loading State**: Generic `LoadingState<T>` enum (idle/loading/loaded/failed).
- **Design Tokens**: `AppConstants`, `Spacing`, `CornerRadius` — single source of truth. NEVER hardcode values.
- **Logging**: `Log.lessons`, `Log.srs`, `Log.speech`, `Log.audio`, `Log.data`, `Log.ui`, `Log.performance`.

---

## Language Policy

### UI Labels: English
Navigation, module titles, button actions — all English.

### Penjelasan ke User: Bahasa Indonesia
- Grammar explanations: Bahasa Indonesia
- Exercise feedback: Bahasa Indonesia  
- Vocabulary definitions: Bilingual (English word + Indonesian explanation)
- Onboarding: Bahasa Indonesia
- Error messages: Bahasa Indonesia
- Tips & hints: Bahasa Indonesia
- Tone: casual ("kamu", bukan "Anda")

### Curriculum Content: English
Exercise prompts, reading passages, listening scripts — all English (ini app belajar bahasa Inggris).

### JSON Format
```json
{
  "explanation_id": "Bahasa Indonesia",
  "explanation_en": "English grammar rule",
  "hint_id": "Petunjuk dalam Bahasa Indonesia",
  "definition_id": "Definisi Bahasa Indonesia"
}
```

### NEVER
- Jangan pakai English untuk menjelaskan grammar ke user
- Jangan campur bahasa dalam satu kalimat penjelasan

---

## Curriculum Sources

| Source | Contribution |
| --- | --- |
| CEFR Framework | A1-C2 level definitions, progression targets |
| Oxford University Press ELT | Grammar & vocabulary structure |
| BBC Learning English | 6 Minute English format, pronunciation |
| British Council LearnEnglish | Skills-based learning, level tests |
| Cambridge English | Activity formats, Write & Improve |
| Vietnam MoE Curriculum | Theme-based progression, spiral repetition |

**Attribution**: Inspired by, not affiliated with. NEVER use trademarked names in app UI.

---

## Incremental Workflow (MANDATORY)

Setiap task yang kamu kerjakan HARUS mengikuti flow ini:

1. Kerjakan SATU task kecil (1-3 file max)
2. `make build` — pastikan clean, zero errors, zero warnings
3. `git add [specific files]` — JANGAN `git add .`
4. `git commit -m "type(scope): description"`
5. `git push origin main` — LANGSUNG push
6. Lanjut ke task berikutnya

### Commit Convention
```
feat(grammar): add present simple lesson with 5 exercises
fix(vocabulary): correct SM-2 ease factor overflow
docs: add README with bilingual description
style(dashboard): align progress cards to 8pt grid
refactor(models): extract CEFRLevel to separate file
perf(reading): lazy-load passage content
test(services): add LessonService unit tests
chore: configure ARM-only build settings
release: v0.1.0 - Project Scaffold
```

### DILARANG
- Menumpuk banyak perubahan dalam satu commit
- Push broken code
- Commit tanpa push
- `git add .` kecuali semua file terkait 1 task

---

## Build & Release Workflow

Ketika diminta rilis versi baru, ikuti prosedur ini **tanpa exception**:

1. `git pull`
2. Update `MARKETING_VERSION` dan `CURRENT_PROJECT_VERSION` di `project.pbxproj`
3. Update `SettingsView.swift` version fallback string
4. Update `CHANGELOG.md` dan `README.md`
5. `rm -rf ~/Library/Developer/Xcode/DerivedData/EngLearn-*`
6. `bash scripts/build_dmg.sh`
7. `git add . && git commit -m "release: vX.X.X - Short Title"`
8. `git push origin main`
9. `git tag vX.X.X && git push origin --tags`
10. `gh release create vX.X.X dist/EngLearn-X.X.X.dmg --title "vX.X.X — Short Title" --notes "..."`

---

## Apple Human Interface Guidelines (Mandatory)

Every new view, feature, or UI change MUST comply. Non-compliance blocks release.

### Typography
- **Minimum font size: 10pt.** `.caption` / `.caption2` is the floor.
- **Use semantic text styles** over hardcoded sizes.
- **Never `.primary.opacity(x)`**. Use `.secondary` directly.
- **No forced ALL CAPS** on labels or dynamic data. Sentence Case only.

### Layout & Spacing
- **8pt grid**: Use `Spacing.xs/sm/md/lg/xl/xxl/xxxl` (4-32pt). NEVER hardcode.
- **Content padding**: `Spacing.xxl` (24pt). Max `Spacing.xxxl` (32pt).
- **Card corner radius**: `CornerRadius.card` (12pt). Hero: `CornerRadius.hero` (16pt).

### Materials & Liquid Glass
- **Cards/containers**: `.background(.regularMaterial, in: RoundedRectangle(cornerRadius: CornerRadius.card))` + `.glassEffect(.regular, in: .rect(cornerRadius: CornerRadius.card))`.
- **Interactive cards**: `.glassEffect(.regular.interactive(), in: ...)`.
- **NEVER** `Color(.anything).opacity(x)` for backgrounds.
- **NEVER** layer manual blur + material + shadow (triple render = battery drain).
- **NEVER** `.glassEffect()` on content layer (list items, data cards). Glass is for navigation layer only.
- **NEVER** glass on glass — don't stack `.glassEffect()` on elements that already have it.
- **ALWAYS** use `GlassEffectContainer` when grouping multiple glass elements.
- **ALWAYS** use `.glassEffect(.regular.interactive())` for custom interactive controls.
- **ALWAYS** use `RoundedRectangle(cornerRadius: .containerConcentric)` for corner concentricity.

### Components
- **Empty states**: `.secondary` text only. No large icons.
- **Exercise feedback**: `Color.correctAnswer` (green), `Color.incorrectAnswer` (orange). Always show explanation in Bahasa Indonesia.
- **Progress bars**: `ProgressView(value:)` with `.tint(.blue)`.

---

## Performance Optimization (MANDATORY)

### CPU — Zero Idle Waste
- NO `Timer.publish` — use `.task { try await Task.sleep }` or `TimelineView`
- NO polling loops — all data-driven via `@Query` or `@Observable`
- `@ObservationIgnored` on all properties that aren't UI-facing
- NO `.onChange()` cascade — prefer derived computed properties
- `.drawingGroup()` on: Swift Charts, progress rings, heatmaps
- JSON parsing: decode ONCE at launch, cache in memory

### RAM — Under 150MB
- `LazyVStack`/`LazyHStack` for all scrollable lists
- Load curriculum JSON per level on demand, not all at once
- Audio buffers: release after playback. Speech: stop on navigate away.
- SwiftData `@Query`: ALWAYS use `#Predicate` + `fetchLimit`. NEVER fetch all then filter.
- Preview Content: `#if DEBUG` only

### Battery — No Background Activity
- App is FOREGROUND ONLY. Zero background processing.
- TTS: stop immediately when view disappears
- Speech recognition: auto-stop after 10s silence
- Daily goal tracking via timestamps, NOT running timer
- Prefer `.easeInOut(duration: 0.25)` over spring animations

### Performance Budgets
| Metric | Budget |
| --- | --- |
| Cold launch | <2 seconds |
| Idle CPU | <3% |
| Idle memory | <150 MB |
| View transition | <100ms |
| JSON lesson load | <50ms per file |
| Flashcard flip | 60fps constant |
| TTS audio start | <500ms |

---

## Liquid Glass Design System (WWDC25)

Sumber: WWDC25 "Meet Liquid Glass" + "Build a SwiftUI app with the new design"

### Core Principles

1. Liquid Glass HANYA untuk NAVIGATION LAYER — toolbar, sidebar, controls floating. JANGAN apply ke content layer (table views, list items, cards konten).
2. NEVER glass on glass — jangan stack .glassEffect() di atas elemen yang sudah punya .glassEffect(). Untuk elemen di atas glass, pakai fills, transparency, vibrancy.
3. Dua variant Regular dan Clear — JANGAN campur. Regular untuk hampir semua. Clear HANYA kalau: (a) di atas media-rich content, (b) dimming layer tidak ganggu, (c) content di atasnya bold+bright.
4. Tinting selective — .tint() HANYA untuk primary actions. JANGAN tint semua elemen.
5. Monochrome icons di toolbar — tint hanya untuk convey meaning, bukan dekorasi.

### SwiftUI API Reference

Custom glass effect capsule default:
    .glassEffect(.regular, in: .capsule)

Custom shape:
    .glassEffect(.regular, in: .rect(cornerRadius: CornerRadius.card))

Interactive untuk custom controls:
    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: CornerRadius.card))

Group multiple glass elements (WAJIB untuk visual correctness):
    GlassEffectContainer { ... }

Glass button styles:
    .buttonStyle(.glass)
    .buttonStyle(.glassProminent)

Toolbar spacing:
    ToolbarSpacer(.fixed)   // fixed antar groups
    ToolbarSpacer()         // flexible

Toolbar item tanpa shared background:
    .sharedBackgroundVisibility(.hidden)

Badge on toolbar:
    .badge(count)

Scroll edge effect untuk dense UIs:
    .scrollEdgeEffectStyle(.hard)

Corner concentricity:
    RoundedRectangle(cornerRadius: .containerConcentric)

Background extension sidebar:
    .backgroundExtensionEffect()

Sheet morphing dari button:
    .navigationTransition(.zoom(sourceID: id, in: namespace))

Search minimized:
    .searchToolbarBehavior(.minimize)

### NavigationSplitView macOS
- Sidebar otomatis floating Liquid Glass
- Pakai .backgroundExtensionEffect() supaya content tidak terpotong
- Sidebar appearance informed oleh ambient environment

### Toolbar Rules
- Items otomatis grouped di glass surface
- ToolbarSpacer(.fixed) untuk split related actions
- Monochrome rendering default
- Badge modifier untuk notifications
- HAPUS custom background di belakang toolbar — interfere scroll edge effect

### Controls
- Bordered buttons = capsule shape default
- .controlSize(.extraLarge) untuk prominent actions
- Sliders support tick marks via step parameter

### Sheets
- Partial height = inset + glass background otomatis
- HAPUS .presentationBackground() custom
- Sheet morphing via navigationTransition(.zoom)

### Accessibility (otomatis)
- Reduced Transparency: glass lebih frosty
- Increased Contrast: elemen black/white + border
- Reduced Motion: intensity berkurang, elastic disabled

### Anti-Slop Liquid Glass

NEVER:
- .glassEffect() di content layer (list items, data cards)
- Glass on glass (stack glass di atas glass)
- Mix Regular dan Clear variant
- Tint semua elemen
- Custom background di belakang toolbar
- .presentationBackground() di sheets
- Opaque fills di buttons di atas glass

ALWAYS:
- GlassEffectContainer untuk group multiple glass elements
- .glassEffect(.regular.interactive()) untuk custom interactive controls
- ToolbarSpacer(.fixed) untuk group related items
- Monochrome icons di toolbar
- .badge() untuk toolbar notifications
- RoundedRectangle(cornerRadius: .containerConcentric)
- Test dengan Reduced Transparency, Increased Contrast, Reduced Motion

---

## Native macOS Anti-Slop Guidelines

### Pre-Commit Self-Audit
Before EVERY commit, verify:
1. No `Color(...).opacity(...)` backgrounds? Use `.regularMaterial`
2. No ALL CAPS? Sentence Case only
3. No icons > 24pt in empty states? Use `.secondary` text
4. No `NavigationView`? Use `NavigationSplitView`
5. No `@StateObject`? Use `@State` + `@Observable`
6. No `print()`? Use `Log.xxx`
7. No force unwrap (`!`)? Use `guard let`
8. No hardcoded spacing? Use `Spacing.xxx`
9. No hardcoded hex colors? Use system colors
10. No box-in-box layout? Flat hierarchy

### The Rules

1. **Material Rule**: NEVER `.background(Color(...).opacity(...))`. ALWAYS `.regularMaterial` + `.glassEffect()`.
2. **Flat Hierarchy**: NEVER box-in-box. ALWAYS natural flow with subtle dividers.
3. **Refined Typography**: NEVER forced ALL CAPS. ALWAYS system text styles, Sentence Case.
4. **Silent Empty States**: NEVER massive icons. ALWAYS `.secondary` text.
5. **No Decorative Emojis**: NEVER emojis in UI or docs. ALWAYS SF Symbols.
6. **No Fake Colors**: NEVER `.primary.opacity(x)`. ALWAYS `.secondary`.
7. **Grid Spacing**: NEVER random pixels. ALWAYS `Spacing.xxx` (8pt grid).
8. **Consistent Radius**: NEVER 20pt+. ALWAYS `CornerRadius.standard/card/hero`.

---

## Timer Management

- ONLY Services own timers. Views NEVER create timers directly.
- Every timer stored as `Task` handle. Cancelled in `.onDisappear`.
- NO background timers. Pause when app is inactive.
- Daily goal: timestamp-based, not continuous timer.
- Exercise timer: `TimelineView` or `.task` with sleep.
- Audit: search for `Timer.` and `.timer` before each release. Zero `Timer.publish`.

---

## Accessibility (MANDATORY)

- `.accessibilityLabel()` on every interactive element
- `.accessibilityValue()` for scores, percentages, progress, streak
- `.accessibilityElement(children: .combine)` for related controls
- All text uses semantic styles. No hardcoded sizes.
- `.focusable()` on interactive cards. Logical tab order.
- Min contrast 4.5:1. Never color-only indicators.
- `@Environment(\.accessibilityReduceMotion)` — skip animations if true
- Listening exercises have text transcripts

---

## Animation Guidelines

| Setting | Value |
| --- | --- |
| Max duration | 0.4s (flashcard flip) |
| Default transition | .easeInOut, 0.25s |
| Allowed types | opacity, scale, slide, gentle spring |
| NEVER use | bounce, rotation > 180deg, confetti, particles |
| Reduced Motion | Instant transition (no animation) |
| Charts | .drawingGroup(). No animated entry on re-render. |

---

## Keyboard Shortcuts

| Shortcut | Action |
| --- | --- |
| Cmd+, | Settings |
| Cmd+1-8 | Navigate to module |
| Cmd+F | Search |
| Cmd+N | New writing entry |
| Cmd+Z / Cmd+Shift+Z | Undo/Redo (writing) |
| Space | Play/pause audio |
| Enter | Submit answer / Next |
| Cmd+R | Replay audio |

---

## Coding Standards

- **Architecture**: `@State` + `@Query` in views. `@Observable` for shared state. Service classes for logic. Dependency injection via init.
- **UI**: Vanilla SwiftUI + Swift Charts + Liquid Glass. SF Symbols exclusively.
- **Clean Code**: No comments unless explaining non-obvious "why".
- **Access Control**: Default `private`. Widen only when needed. All classes `final`.
- **Error Handling**: No force unwrap. `guard let` / `if let`. Exhaustive enums. Every error has recovery path.
- **Concurrency**: `@MainActor` for UI. No `DispatchQueue.main`. Structured concurrency preferred.
- **Logging**: OSLog via `Log.xxx`. NEVER `print()`.
- **Testing**: Swift Testing framework. 80% coverage target.
