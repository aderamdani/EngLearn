import SwiftUI
import SwiftData

struct GrammarExerciseView: View {
    let lesson: Lesson
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentExerciseIndex = 0
    @State private var score = 0
    @State private var isComplete = false
    @State private var isSubmitted = false
    @State private var showHint = false
    
    // Exercise States
    @State private var selectedMCIndex: Int? = nil
    @State private var inputText: String = ""
    @State private var selectedTF: Bool? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            progressHeader
            
            if isComplete {
                completionView
            } else {
                exerciseContent
            }
            
            Spacer()
            
            if !isComplete {
                actionButton
            }
        }
        .padding()
        .navigationTitle(lesson.title)
        .background(.regularMaterial)
    }
    
    // MARK: - Subviews
    
    private var progressHeader: some View {
        VStack(spacing: Spacing.sm) {
            ProgressView(value: Double(currentExerciseIndex), total: Double(lesson.exercises.count))
                .tint(.accentColor)
            
            Text("Pertanyaan \(currentExerciseIndex + 1) dari \(lesson.exercises.count)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.bottom, Spacing.lg)
    }
    
    @ViewBuilder
    private var exerciseContent: some View {
        let exercise = lesson.exercises[currentExerciseIndex]
        
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                Text(exercise.prompt)
                    .font(.title3.bold())
                
                switch exercise.type {
                case .multipleChoice:
                    if let options = exercise.options, case .index(let correct) = exercise.correct {
                        MultipleChoiceView(
                            options: options,
                            correctIndex: correct,
                            selectedIndex: $selectedMCIndex,
                            isSubmitted: isSubmitted
                        )
                    }
                case .fillBlank:
                    if case .text(let correct) = exercise.correct {
                        FillBlankView(
                            prompt: "Lengkapi kalimat ini:",
                            correctAnswer: correct,
                            hint: exercise.hintID,
                            inputText: $inputText,
                            isSubmitted: isSubmitted,
                            showHint: showHint
                        )
                    }
                case .trueFalse:
                    if case .index(let correct) = exercise.correct {
                        TrueFalseView(
                            prompt: "Pernyataan ini Benar atau Salah?",
                            isCorrectTrue: correct == 1,
                            selectedAnswer: $selectedTF,
                            isSubmitted: isSubmitted
                        )
                    }
                default:
                    Text("Tipe latihan ini belum didukung.")
                }
                
                if isSubmitted {
                    feedbackSection(exercise)
                }
            }
        }
    }
    
    private func feedbackSection(_ exercise: Exercise) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Label(
                isAnswerCorrect ? "Luar Biasa! Jawabanmu benar." : "Ups, coba lagi ya!",
                systemImage: isAnswerCorrect ? "checkmark.circle.fill" : "xmark.circle.fill"
            )
            .font(.headline)
            .foregroundColor(isAnswerCorrect ? Color.correctAnswer : Color.incorrectAnswer)
            
            Text(exercise.explanationID)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: CornerRadius.card))
        .glassEffect(.regular, in: .rect(cornerRadius: CornerRadius.card))
    }
    
    private var actionButton: some View {
        Button {
            if isSubmitted {
                nextExercise()
            } else {
                submitAnswer()
            }
        } label: {
            Text(isSubmitted ? "Selanjutnya" : "Periksa Jawaban")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isAnswerReady ? Color.accentColor : Color.gray.opacity(0.3), in: RoundedRectangle(cornerRadius: CornerRadius.card))
                .foregroundColor(.white)
        }
        .disabled(!isAnswerReady)
        .accessibilityLabel(isSubmitted ? "Lanjut ke pertanyaan berikutnya" : "Periksa jawaban kamu")
    }
    
    private var completionView: some View {
        VStack(spacing: Spacing.xxl) {
            Spacer()
            
            Image(systemName: score >= 80 ? "trophy.fill" : "star.fill")
                .font(.system(size: 80))
                .foregroundColor(.yellow)
            
            Text("Latihan Selesai!")
                .font(.largeTitle.bold())
            
            Text("Kamu berhasil menyelesaikan \(lesson.title) dengan skor:")
                .font(.body)
                .multilineTextAlignment(.center)
            
            Text("\(score)%")
                .font(.system(size: 60, weight: .black))
                .foregroundColor(score >= 80 ? .green : .orange)
            
            Spacer()
            
            Button {
                saveResultAndDismiss()
            } label: {
                Text("Selesai")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor, in: RoundedRectangle(cornerRadius: CornerRadius.card))
                    .foregroundColor(.white)
            }
            .accessibilityLabel("Selesaikan pelajaran dan simpan progres")
        }
    }
    
    // MARK: - Logic
    
    private var isAnswerReady: Bool {
        let exercise = lesson.exercises[currentExerciseIndex]
        switch exercise.type {
        case .multipleChoice: return selectedMCIndex != nil
        case .fillBlank: return !inputText.trimmingCharacters(in: .whitespaces).isEmpty
        case .trueFalse: return selectedTF != nil
        default: return false
        }
    }
    
    private var isAnswerCorrect: Bool {
        let exercise = lesson.exercises[currentExerciseIndex]
        switch exercise.type {
        case .multipleChoice:
            return exercise.correct.isCorrect(selectedIndex: selectedMCIndex ?? -1)
        case .fillBlank:
            return exercise.correct.isCorrect(inputText: inputText)
        case .trueFalse:
            let selected = selectedTF == true ? 1 : 0
            return exercise.correct.isCorrect(selectedIndex: selected)
        default:
            return false
        }
    }
    
    private func submitAnswer() {
        withAnimation {
            isSubmitted = true
            if isAnswerCorrect {
                score += 1
            } else {
                showHint = true
            }
        }
    }
    
    private func nextExercise() {
        if currentExerciseIndex + 1 < lesson.exercises.count {
            withAnimation {
                currentExerciseIndex += 1
                isSubmitted = false
                showHint = false
                selectedMCIndex = nil
                inputText = ""
                selectedTF = nil
            }
        } else {
            finishLesson()
        }
    }
    
    private func finishLesson() {
        let total = lesson.exercises.count
        let finalScore = total > 0 ? (score * 100 / total) : 0
        score = finalScore
        withAnimation {
            isComplete = true
        }
    }
    
    private func saveResultAndDismiss() {
        let record = LessonRecord(
            lessonID: lesson.id,
            skill: .grammar,
            level: lesson.level,
            score: score,
            totalExercises: lesson.exercises.count,
            correctAnswers: score * lesson.exercises.count / 100,
            timeSpentSeconds: 300 // Placeholder
        )
        modelContext.insert(record)
        
        // Update user progress if needed
        let descriptor = FetchDescriptor<UserProgress>()
        if let progress = try? modelContext.fetch(descriptor).first {
            progress.totalLessonsCompleted += 1
            progress.totalExercisesCompleted += lesson.exercises.count
            progress.totalCorrectAnswers += (score * lesson.exercises.count / 100)
        }
        
        try? modelContext.save()
        
        Task {
            let achievementService = AchievementService()
            await achievementService.checkAndUnlock(modelContext: modelContext)
            
            await MainActor.run {
                dismiss()
            }
        }
    }
}

#Preview {
    NavigationStack {
        GrammarExerciseView(lesson: Lesson(
            id: "1",
            skill: .grammar,
            level: .a1,
            title: "Present Simple",
            theme: "Daily Life",
            cefrCanDo: "Can talk about habits",
            explanation: nil,
            exercises: [
                Exercise(
                    id: "e1",
                    type: .multipleChoice,
                    prompt: "She ___ to school every day.",
                    options: ["go", "goes", "going", "gone"],
                    correct: .index(1),
                    explanationID: "Gunakan 'goes' untuk subjek tunggal orang ketiga (She).",
                    hintID: "Ingat akhiran -s/es.",
                    difficulty: 1,
                    cefrCanDo: "Can use 3rd person singular"
                )
            ]
        ))
    }
}
