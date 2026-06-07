# EngLearn macOS Engineering Skill

**Target Audience:** `npx skills` / Gemini CLI users building native macOS applications.
**Focus:** Pure Native SwiftUI, SwiftData, strict HIG compliance, Liquid Glass, ARM64 only.

## Skill Description

This skill specializes in building a highly optimized, native macOS English learning application without third-party dependencies. It enforces strict architectural boundaries (MVVM-light), zero-slop UI design (Apple HIG compliance, Liquid Glass materials), modern Swift 6 concurrency, and bilingual content (English exercises, Indonesian explanations).

## Available Actions

- **`scaffold_macos_view`**: Generates a standard macOS SwiftUI view using Liquid Glass materials, 8pt grid (`Spacing.xxx`), and the standard module view pattern (header, level picker, progress summary, content).
- **`audit_hig_compliance`**: Reviews existing views against Apple HIG and anti-slop rules. Checks for Color.opacity backgrounds, ALL CAPS, hardcoded spacing, massive empty state icons, deprecated APIs.
- **`generate_swiftdata_model`**: Creates a `@Model` conforming to project conventions (strict typing, explicit relationships, migration-ready).
- **`generate_curriculum_json`**: Creates a level-specific JSON curriculum file following the schemas in OPENROUTER.md. Bilingual: English content, Indonesian explanations.
- **`run_semver_release`**: Executes the 10-step release procedure (version bump, CHANGELOG, clean build, DMG, commit, push, tag, gh release).
- **`validate_exercise`**: Checks exercise content for linguistic validity, CEFR alignment, anti-slop (no placeholder text, plausible distractors).
- **`audit_performance`**: Checks for Timer.publish, print(), unnecessary re-renders, missing LazyVStack, missing @ObservationIgnored.

## Core Rules

1. **No Third-Party Dependencies**: 100% native Apple frameworks.
2. **Liquid Glass UI**: `.regularMaterial` + `.glassEffect()`. Never `Color.opacity`.
3. **Typography**: Sentence Case. No ALL CAPS. `.secondary` for muted. Min 10pt.
4. **Data Isolation**: Views own presentation. Services own logic. Models are immutable or `@Model`.
5. **No Force Unwrapping**: `guard let` or `if let`. Exhaustive enums.
6. **Performance**: No Timer.publish. No print(). LazyVStack for lists. <3% idle CPU.
7. **Bilingual**: English exercises, Bahasa Indonesia explanations.
8. **ARM64 Only**: `ARCHS = arm64`. macOS 26+. Xcode 26.

## How to Use

Activate this skill when constructing macOS views, reviewing UI for HIG compliance, generating curriculum content, auditing performance, or executing the release pipeline.
