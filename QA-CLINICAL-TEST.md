# EngLearn QA Clinical Test

Manual checklist. Run before every release. Every item must PASS.

---

## 1. Launch & Navigation
- [ ] Cold launch under 2 seconds
- [ ] Sidebar shows all 12 items (8 modules + immersion + level test + achievements + settings)
- [ ] Cmd+1 through Cmd+8 navigate to correct module
- [ ] Cmd+, opens Settings
- [ ] Cmd+F focuses search
- [ ] Window resizes correctly (min 900x600)
- [ ] State restored after quit and relaunch

## 2. Grammar Module
- [ ] Lesson list loads for each CEFR level
- [ ] Exercise flow: prompt -> answer -> feedback (Indonesian) -> next
- [ ] Correct answer: green indicator + explanation
- [ ] Incorrect answer: orange indicator + explanation + hint
- [ ] Progress saved to SwiftData after each exercise
- [ ] Back navigation preserves exercise position

## 3. Vocabulary Module
- [ ] Flashcard displays word, phonetic, definition (bilingual)
- [ ] Card flip animation smooth (60fps, <0.4s)
- [ ] SM-2 scheduling: correct -> longer interval, incorrect -> shorter
- [ ] Quiz scoring accurate
- [ ] Review due counter correct

## 4. Reading Module
- [ ] Passage renders with correct formatting
- [ ] Word count displayed
- [ ] Comprehension quiz flows correctly
- [ ] Highlighted vocabulary words tappable

## 5. Listening Module
- [ ] TTS playback starts within 500ms
- [ ] Play/pause with Space bar works
- [ ] Cmd+R replays audio
- [ ] TTS speed setting respected (slow/normal/fast)
- [ ] Dictation input accepts text
- [ ] TTS stops on navigate away

## 6. Writing Module
- [ ] Prompt displays correctly
- [ ] Word count updates in real-time
- [ ] Auto-save works (navigate away, come back)
- [ ] Sample answer comparison available
- [ ] Undo/Redo works (Cmd+Z / Cmd+Shift+Z)

## 7. Speaking Module
- [ ] Microphone permission requested on first use
- [ ] Permission denied: shows Indonesian recovery message
- [ ] Phoneme guide: all 44 phonemes listed
- [ ] Speech recognition starts/stops correctly
- [ ] Auto-stop after 10s silence
- [ ] Recognition stops on navigate away

## 8. Gamification
- [ ] Achievement unlocks correctly
- [ ] Streak increments on daily lesson completion
- [ ] Streak heatmap renders (30 days)
- [ ] Daily challenge generates new exercise

## 9. Accessibility
- [ ] VoiceOver: navigate entire app with keyboard
- [ ] Every button has accessibility label
- [ ] Progress values announced (percentages, scores)
- [ ] Dynamic Type: text scales appropriately
- [ ] Keyboard-only: all actions reachable
- [ ] Color contrast: 4.5:1 minimum

## 10. Performance
- [ ] Idle CPU < 3% (Activity Monitor)
- [ ] Idle memory < 150 MB
- [ ] No timer leaks (search for Timer.publish: zero results)
- [ ] No print() statements (search: zero results)
- [ ] Charts use .drawingGroup()
- [ ] LazyVStack for all scrollable lists

## 11. Data Integrity
- [ ] Progress persists after relaunch
- [ ] No data loss on force quit during exercise
- [ ] Export: PDF progress report generates correctly
- [ ] Export: CSV vocabulary list correct
- [ ] Reset progress: confirmation dialog, then clean wipe

## 12. HIG & Anti-Slop Compliance
- [ ] No Color.opacity() backgrounds (all .regularMaterial)
- [ ] No ALL CAPS text anywhere
- [ ] No massive empty state icons
- [ ] No emojis in UI or labels
- [ ] All spacing is 8pt grid (4, 8, 12, 16, 20, 24, 32)
- [ ] Corner radius consistent (10/12/16)
- [ ] Dark Mode: all views readable
- [ ] Light Mode: all views readable
- [ ] PDF export: renders in Light Mode (not blank)
- [ ] Menu bar: all custom menus present and functional
