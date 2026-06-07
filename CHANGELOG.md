# Changelog

All notable changes to EngLearn will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
