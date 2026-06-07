import Foundation

enum PreviewData {
    static let sampleExercise = Exercise(
        id: "grammar_a1_ps_001",
        type: .multipleChoice,
        prompt: "She ___ to school every day.",
        options: ["go", "goes", "going", "gone"],
        correct: .index(1),
        explanationID: "Jawaban benar! Untuk subjek 'she', kata kerja 'go' ditambah -es menjadi 'goes'.",
        hintID: "Perhatikan subjeknya. 'She' adalah orang ketiga tunggal.",
        difficulty: 1,
        cefrCanDo: "Can use present simple with third person singular"
    )

    static let sampleLesson = Lesson(
        id: "grammar_a1_present_simple",
        skill: .grammar,
        level: .a1,
        title: "Present Simple",
        theme: "me_and_my_world",
        cefrCanDo: "Can describe daily routines using present simple",
        explanation: GrammarExplanation(
            ruleID: "Present Simple digunakan untuk kebiasaan sehari-hari.",
            ruleEN: "Use Present Simple for habits and routines.",
            examples: ["I go to school.", "She likes coffee."],
            exceptions: ["go -> goes", "have -> has"],
            tipID: "Untuk he/she/it, tambahkan -s atau -es."
        ),
        exercises: [sampleExercise]
    )

    static let sampleModule = Module(
        id: .grammar,
        level: .a1,
        lessons: [sampleLesson]
    )
}
