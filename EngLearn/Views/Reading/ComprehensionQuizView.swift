import SwiftUI
import SwiftData

struct ComprehensionQuizView: View {
    let passage: ReadingPassage
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentIndex = 0
    @State private var score = 0
    @State private var isSubmitted = false
    @State private var selectedOption: Int? = nil
    @State private var isComplete = false
    
    var body: some View {
        VStack(spacing: Spacing.xxl) {
            if isComplete {
                completionView
            } else if passage.comprehensionQuiz.isEmpty {
                ContentUnavailableView("Tidak ada kuis", systemImage: "questionmark.folder")
            } else {
                quizContent
            }
        }
        .padding(Spacing.xxl)
        .navigationTitle("Kuis: \(passage.title)")
        .background(.regularMaterial)
    }
    
    private var quizContent: some View {
        let question = passage.comprehensionQuiz[currentIndex]
        return VStack(alignment: .leading, spacing: Spacing.xl) {
            ProgressView(value: Double(currentIndex), total: Double(passage.comprehensionQuiz.count))
                .tint(.accentColor)
            
            Text("Pertanyaan \(currentIndex + 1) dari \(passage.comprehensionQuiz.count)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(question.question)
                .font(.title3.bold())
                .padding(.bottom, Spacing.sm)
            
            optionsList(question)
            
            if isSubmitted {
                feedbackView(question)
            }
            
            Spacer()
            
            actionButton
        }
    }
    
    private func optionsList(_ question: ComprehensionQuestion) -> some View {
        VStack(spacing: Spacing.md) {
            ForEach(0..<question.options.count, id: \.self) { index in
                Button {
                    if !isSubmitted { selectedOption = index }
                } label: {
                    HStack {
                        Text(question.options[index]).font(.body)
                        Spacer()
                        if isSubmitted {
                            if index == question.correctIndex {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                            } else if index == selectedOption {
                                Image(systemName: "xmark.circle.fill").foregroundColor(.orange)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(optionColor(index: index, correct: question.correctIndex), in: RoundedRectangle(cornerRadius: CornerRadius.card))
                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: CornerRadius.card))
                    .overlay {
                        if selectedOption == index && !isSubmitted {
                            RoundedRectangle(cornerRadius: CornerRadius.card).stroke(Color.accentColor, lineWidth: 2)
                        }
                    }
                }
                .buttonStyle(.plain)
                .disabled(isSubmitted)
                .accessibilityLabel(question.options[index])
            }
        }
    }
    
    private func optionColor(index: Int, correct: Int) -> Color {
        if isSubmitted {
            if index == correct { return .green.mix(with: .white, by: 0.8) }
            if index == selectedOption { return .orange.mix(with: .white, by: 0.8) }
        }
        return .clear
    }
    
    private func feedbackView(_ question: ComprehensionQuestion) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Label(
                selectedOption == question.correctIndex ? "Benar!" : "Kurang tepat.",
                systemImage: selectedOption == question.correctIndex ? "checkmark.circle.fill" : "xmark.circle.fill"
            )
            .font(.headline)
            .foregroundColor(selectedOption == question.correctIndex ? .green : .orange)
            
            Text(question.explanationID)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: CornerRadius.card))
    }
    
    private var actionButton: some View {
        Button {
            if isSubmitted { nextQuestion() } else { submitAnswer() }
        } label: {
            Text(isSubmitted ? "Selanjutnya" : "Periksa")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(selectedOption != nil ? Color.accentColor : Color.gray.opacity(0.3), in: RoundedRectangle(cornerRadius: CornerRadius.card))
                .foregroundColor(.white)
        }
        .disabled(selectedOption == nil)
    }
    
    private var completionView: some View {
        VStack(spacing: Spacing.xxl) {
            Spacer()
            Image(systemName: "trophy.fill")
                .font(.system(size: 80))
                .foregroundColor(.yellow)
            
            Text("Kuis Selesai!")
                .font(.largeTitle.bold())
            
            Text("Kamu berhasil menyelesaikan kuis untuk \(passage.title) dengan skor:")
                .font(.body)
                .multilineTextAlignment(.center)
            
            Text("\(score * 100 / passage.comprehensionQuiz.count)%")
                .font(.system(size: 60, weight: .black))
                .foregroundColor(score * 100 / passage.comprehensionQuiz.count >= 80 ? .green : .orange)
            
            Spacer()
            
            Button { saveAndDismiss() } label: {
                Text("Selesai")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor, in: RoundedRectangle(cornerRadius: CornerRadius.card))
                    .foregroundColor(.white)
            }
        }
    }
    
    // MARK: - Logic
    
    private func submitAnswer() {
        withAnimation {
            isSubmitted = true
            if selectedOption == passage.comprehensionQuiz[currentIndex].correctIndex {
                score += 1
            }
        }
    }
    
    private func nextQuestion() {
        if currentIndex + 1 < passage.comprehensionQuiz.count {
            withAnimation {
                currentIndex += 1
                isSubmitted = false
                selectedOption = nil
            }
        } else {
            withAnimation { isComplete = true }
        }
    }
    
    private func saveAndDismiss() {
        let record = LessonRecord(
            lessonID: passage.id,
            skill: .reading,
            level: .a1, // Note: Level mapping could be improved
            score: score,
            totalExercises: passage.comprehensionQuiz.count,
            correctAnswers: score,
            timeSpentSeconds: 120
        )
        modelContext.insert(record)
        
        let descriptor = FetchDescriptor<UserProgress>()
        if let progress = try? modelContext.fetch(descriptor).first {
            progress.totalLessonsCompleted += 1
            progress.totalExercisesCompleted += passage.comprehensionQuiz.count
            progress.totalCorrectAnswers += score
        }
        
        dismiss()
    }
}
