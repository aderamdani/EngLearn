import SwiftUI
import SwiftData

struct DictationView: View {
    let dialogue: ListeningDialogue
    
    @State private var audioService = AudioPlaybackService()
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentIndex = 0
    @State private var inputText = ""
    @State private var score = 0
    @State private var isSubmitted = false
    @State private var showHint = false
    @State private var isComplete = false
    @State private var playbackRate: Double = AppConstants.Limits.ttsNormalRate
    
    var body: some View {
        VStack(spacing: Spacing.xxl) {
            if isComplete {
                completionView
            } else if dialogue.exercises.isEmpty {
                ContentUnavailableView("Tidak ada latihan", systemImage: "headphones")
            } else {
                exerciseContent
            }
        }
        .padding(Spacing.xxl)
        .navigationTitle(dialogue.title)
        .background(.regularMaterial)
        .onDisappear {
            audioService.stop()
        }
    }
    
    private var exerciseContent: some View {
        let exercise = dialogue.exercises[currentIndex]
        return VStack(alignment: .leading, spacing: Spacing.xl) {
            ProgressView(value: Double(currentIndex), total: Double(dialogue.exercises.count))
                .tint(.accentColor)
            
            Text("Latihan \(currentIndex + 1) dari \(dialogue.exercises.count)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            audioControls
            
            Text(exercise.prompt)
                .font(.headline)
            
            inputSection(exercise: exercise)
            
            if isSubmitted {
                feedbackSection(exercise: exercise)
            }
            
            Spacer()
            
            actionButton
        }
    }
    
    private var audioControls: some View {
        VStack(spacing: Spacing.md) {
            HStack {
                Spacer()
                Button {
                    audioService.play(text: dialogue.audioScript, rate: playbackRate)
                } label: {
                    Image(systemName: audioService.isPlaying ? "speaker.wave.3.fill" : "play.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Putar audio")
                Spacer()
            }
            
            Picker("Kecepatan", selection: $playbackRate) {
                Text("Lambat").tag(AppConstants.Limits.ttsSlowRate)
                Text("Normal").tag(AppConstants.Limits.ttsNormalRate)
                Text("Cepat").tag(AppConstants.Limits.ttsFastRate)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
        }
        .padding(Spacing.lg)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: CornerRadius.card))
        .glassEffect(.regular, in: .rect(cornerRadius: CornerRadius.card))
    }
    
    private func inputSection(exercise: DictationExercise) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            TextField("Ketik yang kamu dengar...", text: $inputText)
                .textFieldStyle(.plain)
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: CornerRadius.standard))
                .overlay {
                    RoundedRectangle(cornerRadius: CornerRadius.standard)
                        .stroke(borderColor(for: exercise), lineWidth: 1)
                }
                .disabled(isSubmitted)
                .autocorrectionDisabled()
            
            if showHint && !isSubmitted {
                Label(exercise.hintID, systemImage: "lightbulb")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
    }
    
    private func borderColor(for exercise: DictationExercise) -> Color {
        if isSubmitted {
            return isAnswerCorrect ? .green : .orange
        }
        return .secondary.opacity(0.3)
    }
    
    private func feedbackSection(exercise: DictationExercise) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Label(
                isAnswerCorrect ? "Benar sekali!" : "Hampir benar.",
                systemImage: isAnswerCorrect ? "checkmark.circle.fill" : "xmark.circle.fill"
            )
            .font(.headline)
            .foregroundColor(isAnswerCorrect ? .green : .orange)
            
            if !isAnswerCorrect {
                Text("Seharusnya: \(exercise.expectedText)")
                    .font(.body.italic())
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: CornerRadius.card))
    }
    
    private var actionButton: some View {
        Button {
            if isSubmitted { nextExercise() } else { submitAnswer() }
        } label: {
            Text(isSubmitted ? "Selanjutnya" : "Periksa")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(inputText.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray.opacity(0.3) : Color.accentColor, in: RoundedRectangle(cornerRadius: CornerRadius.card))
                .foregroundColor(.white)
        }
        .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
    }
    
    private var completionView: some View {
        VStack(spacing: Spacing.xxl) {
            Spacer()
            Image(systemName: "ear.badge.waveform")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
            
            Text("Latihan Selesai!")
                .font(.largeTitle.bold())
            
            Text("Skor pendengaran kamu:")
                .font(.headline)
            Text("\(score * 100 / dialogue.exercises.count)%")
                .font(.system(size: 60, weight: .black))
                .foregroundColor(.green)
            
            Spacer()
            Button("Selesai") { saveAndDismiss() }
                .font(.headline).frame(maxWidth: .infinity).padding()
                .background(Color.accentColor, in: RoundedRectangle(cornerRadius: CornerRadius.card))
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Logic
    
    private var isAnswerCorrect: Bool {
        let expected = dialogue.exercises[currentIndex].expectedText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let actual = inputText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return expected == actual
    }
    
    private func submitAnswer() {
        audioService.stop()
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
        if currentIndex + 1 < dialogue.exercises.count {
            withAnimation {
                currentIndex += 1
                isSubmitted = false
                showHint = false
                inputText = ""
            }
        } else {
            withAnimation { isComplete = true }
        }
    }
    
    private func saveAndDismiss() {
        let record = LessonRecord(
            lessonID: dialogue.id,
            skill: .listening,
            level: .a1,
            score: score,
            totalExercises: dialogue.exercises.count,
            correctAnswers: score,
            timeSpentSeconds: 120
        )
        modelContext.insert(record)
        
        let descriptor = FetchDescriptor<UserProgress>()
        if let progress = try? modelContext.fetch(descriptor).first {
            progress.totalLessonsCompleted += 1
            progress.totalExercisesCompleted += dialogue.exercises.count
            progress.totalCorrectAnswers += score
        }
        
        dismiss()
    }
}
