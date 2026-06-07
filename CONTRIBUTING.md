# Contributing to EngLearn

Thank you for your interest in contributing to EngLearn.

## Branch Strategy

```
main          -> production (tagged releases)
develop       -> integration
feature/*     -> new features
fix/*         -> bug fixes
content/*     -> curriculum content
release/X.X.X -> release prep
```

All PRs target `develop`. Merge `develop` -> `main` for release.

## Commit Convention

```
feat(grammar): add fill-in-the-blank exercise type
fix(vocabulary): correct SM-2 ease factor overflow
docs: update README with new module
style(dashboard): align cards to 8pt grid
refactor(models): extract CEFRLevel
perf(reading): lazy-load passage content
test(services): add LessonService unit tests
chore: configure build settings
release: v0.1.0 - Project Scaffold
```

## Development Setup

1. Clone the repository
2. Open `EngLearn.xcodeproj` in Xcode 26+
3. Select the `EngLearn` scheme
4. Build: `make build`
5. Run: `make run`
6. Test: `make test`

## Code Standards

- Swift 6 strict concurrency
- SwiftLint enforced (`.swiftlint.yml`)
- 80% test coverage target
- All explanations to users in Bahasa Indonesia
- See `CLAUDE.md` for full architecture and anti-slop rules

## Pull Request Process

1. Create branch from `develop`
2. Make changes (1-3 files per commit)
3. `make build` and `make test` must pass
4. Fill out the PR template checklist
5. Request review

## Anti-Slop Policy

All contributions must pass the anti-slop audit. See `CLAUDE.md` for the full list. Key rules:
- No `Color.opacity` backgrounds (use `.regularMaterial`)
- No ALL CAPS (Sentence Case)
- No `print()` (use `Log.xxx`)
- No force unwrapping
- No `Timer.publish`
