# EngLearn — OPENROUTER.md

Instructions for OpenRouter (owl-alpha). Focus: curriculum content generation, JSON schemas, content quality.

---

## Project Context

Native macOS English learning app. arm64 only. macOS 26+. Swift 6. Zero dependencies. All shared rules (architecture, HIG, anti-slop, workflow) same as CLAUDE.md.

---

## Content Generation Rules

### Language
- Exercise prompts, passages, dialogues: **English** (ini app belajar bahasa Inggris)
- Grammar explanations, feedback, hints: **Bahasa Indonesia** (casual, "kamu")
- Vocabulary definitions: **Bilingual** (English + Indonesian)

### Quality Standards
- Every exercise MUST map to a CEFR can-do statement
- Distractor options in MCQ: plausible error patterns, not random words
- Vocabulary examples: natural collocations, not forced usage
- Reading passages: coherent narratives, not disjointed paragraphs
- Grammar: rule -> example -> exception -> exercise
- No repetitive sentence structures within one lesson
- Audio scripts: natural spoken English, not written English read aloud
- No placeholder content ("Lorem ipsum", "The cat sat on the mat" tanpa konteks)

---

## JSON Curriculum Schemas

### Exercise Types
```
multipleChoice   — Select 1 correct from 4 options
fillBlank        — Type the missing word/phrase
reorder          — Arrange words into correct order
matching         — Match pairs (word-definition)
trueFalse        — Statement true or false
dictation        — Listen and type what you hear
spokenResponse   — Speak, evaluated by speech recognition
freeWriting      — Open-ended writing with word count target
```

### Grammar Lesson Schema
```json
{
  "id": "grammar_a1_present_simple",
  "skill": "grammar",
  "level": "a1",
  "title": "Present Simple",
  "theme": "me_and_my_world",
  "cefrCanDo": "Can describe daily routines using present simple",
  "explanation": {
    "rule_id": "Present Simple digunakan untuk kebiasaan dan rutinitas sehari-hari.",
    "rule_en": "Use Present Simple for habits, routines, and general truths.",
    "examples": ["I go to school every day.", "She likes coffee.", "The sun rises in the east."],
    "exceptions": ["Third person singular: add -s or -es (he goes, she watches)"],
    "tip_id": "Perhatikan: untuk he/she/it, tambahkan -s atau -es di akhir kata kerja."
  },
  "exercises": [
    {
      "id": "grammar_a1_ps_001",
      "type": "multipleChoice",
      "prompt": "She ___ to school every day.",
      "options": ["go", "goes", "going", "gone"],
      "correct": 1,
      "explanation_id": "Jawaban benar! Untuk subjek 'she' (orang ketiga tunggal), kata kerja 'go' ditambah akhiran -es menjadi 'goes'.",
      "hint_id": "Petunjuk: Perhatikan subjeknya. 'She' adalah orang ketiga tunggal.",
      "difficulty": 1,
      "cefrCanDo": "Can use present simple with third person singular"
    }
  ]
}
```

### Vocabulary Entry Schema
```json
{
  "id": "vocab_a1_hello",
  "word": "hello",
  "level": "a1",
  "partOfSpeech": "interjection",
  "phonetic": "/hɛˈloʊ/",
  "definition_en": "Used as a greeting when meeting someone",
  "definition_id": "Digunakan sebagai sapaan ketika bertemu seseorang",
  "exampleSentence": "Hello, my name is Sarah.",
  "context_id": "Biasanya digunakan di awal percakapan atau saat bertemu orang.",
  "collocations": ["say hello", "hello there", "hello everyone"],
  "theme": "me_and_my_friends",
  "audioFile": "vocab_hello.m4a"
}
```

### Reading Passage Schema
```json
{
  "id": "reading_a2_my_town",
  "skill": "reading",
  "level": "a2",
  "title": "My Town",
  "theme": "our_communities",
  "wordCount": 120,
  "passage": "Maria lives in a small town near the coast...",
  "vocabulary": ["community", "library", "neighbourhood"],
  "comprehensionQuiz": [
    {
      "id": "reading_a2_mt_001",
      "type": "multipleChoice",
      "prompt": "Where does Maria go after school?",
      "options": ["The park", "The library", "The beach", "The shop"],
      "correct": 1,
      "explanation_id": "Di paragraf kedua, Maria berkata bahwa dia pergi ke perpustakaan setelah sekolah.",
      "difficulty": 1
    }
  ]
}
```

### Listening Schema
```json
{
  "id": "listening_a1_greetings",
  "skill": "listening",
  "level": "a1",
  "title": "Greetings",
  "audioScript": "A: Hello! How are you? B: I'm fine, thank you. And you?",
  "speed": "slow",
  "speakerCount": 2,
  "exercises": [
    {
      "id": "listening_a1_gr_001",
      "type": "dictation",
      "prompt": "Dengarkan dan ketik apa yang kamu dengar.",
      "correct": "Hello! How are you?",
      "explanation_id": "Kalimat sapaan dasar dalam bahasa Inggris.",
      "difficulty": 1
    }
  ]
}
```

### Writing Prompt Schema
```json
{
  "id": "writing_a1_introduce",
  "skill": "writing",
  "level": "a1",
  "title": "Introduce Yourself",
  "promptType": "guided",
  "prompt": "Write 3-5 sentences about yourself. Include your name, age, and hobby.",
  "instruction_id": "Tulis 3-5 kalimat tentang dirimu. Sertakan nama, umur, dan hobi kamu.",
  "wordCountTarget": 30,
  "sampleAnswer": "My name is Adi. I am 15 years old. I live in Jakarta. I like playing football. My favourite subject is English.",
  "tip_id": "Mulai dengan 'My name is...' lalu ceritakan tentang dirimu."
}
```

### Speaking Phoneme Schema
```json
{
  "phoneme": "æ",
  "ipaSymbol": "æ",
  "exampleWords": ["cat", "hat", "man", "bad"],
  "description_id": "Bunyi vokal pendek, seperti 'e' pada kata 'enak' tapi mulut lebih terbuka lebar.",
  "mouthPosition_id": "Buka mulut lebar, lidah rendah di depan.",
  "audioFile": "phoneme_ae.m4a",
  "commonMistake_id": "Penutur bahasa Indonesia sering mengucapkan bunyi ini seperti 'e'. Pastikan mulut lebih terbuka."
}
```

### File Naming Convention
```
Resources/Curriculum/
├── grammar_a1.json ... grammar_c2.json
├── vocabulary_a1.json ... vocabulary_c2.json
├── reading_a1.json ... reading_c2.json
├── listening_a1.json ... listening_c2.json
├── writing_a1.json ... writing_c2.json
├── speaking_phonemes.json
├── daily_lessons.json
├── immersion_b1.json ... immersion_c2.json
└── achievements.json
```

---

## Anti-Slop for Content

- No placeholder sentences without pedagogical purpose
- Distractor options: plausible errors (e.g., common L1 interference from Indonesian)
- Vocabulary: natural collocations, not dictionary-style isolated words
- Reading: coherent narrative with clear topic sentence per paragraph
- Grammar explanations in Indonesian: progressive (rule -> contoh -> pengecualian)
- CEFR can-do statement required for every exercise
- No repetitive sentence patterns within one lesson
- Audio scripts: natural spoken register, contractions allowed

---

## Incremental Workflow
Same as CLAUDE.md. 1 task = 1 commit = 1 push. `make build` before commit.
