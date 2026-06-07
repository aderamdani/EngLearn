import SwiftUI
import SwiftData

struct LevelTestView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentQuestionIndex = 0
    @State private var score = 0
    @State private var recommendedLevel: CEFRLevel = .a1
    @State private var isComplete = false
    @State private var selectedOption: Int? = nil
    @State private var isSubmitted = false
    
    // Adaptive logic: starting at A1, increase difficulty on correct, stay/decrease on wrong
    @State private var currentDifficulty: CEFRLevel = .a1
    
    private let questions = [
        TestQuestion(prompt: "I ___ a student.", options: ["am", "is", "are", "be"], correct: 0, level: .a1),
        TestQuestion(prompt: "She ___ to school every day.", options: ["go", "goes", "going", "gone"], correct: 1, level: .a1),
        TestQuestion(prompt: "Look! They ___ football now.", options: ["play", "plays", "are playing", "is playing"], correct: 2, level: .a1),
        TestQuestion(prompt: "Yesterday, I ___ a new book.", options: ["buy", "bought", "buys", "buying"], correct: 1, level: .a2),
        TestQuestion(prompt: "My car is ___ than yours.", options: ["fast", "faster", "more fast", "fastest"], correct: 1, level: .a2),
        TestQuestion(prompt: "I have ___ that movie three times.", options: ["see", "saw", "seen", "seeing"], correct: 2, level: .b1),
        TestQuestion(prompt: "If it rains, we ___ at home.", options: ["stay", "will stay", "would stay", "stayed"], correct: 1, level: .b1),
        TestQuestion(prompt: "He ___ for five hours before he finished.", options: ["worked", "has worked", "had worked", "was working"], correct: 2, level: .b2),
        TestQuestion(prompt: "I wish I ___ more time.", options: ["have", "had", "would have", "will have"], correct: 1, level: .b2),
        TestQuestion(prompt: "Hardly ___ I entered the room when the phone rang.", options: ["did", "had", "have", "was"], correct: 1, level: .c1)
    ]
    
    var body: some View {
        VStack(spacing: Spacing.xxl) {
            if isComplete {
                resultView
            } else {
                testContent
            }
        }
        .padding(Spacing.xxl)
        .navigationTitle("Tes Penempatan")
        .background(.regularMaterial)
    }
    
    private var testContent: some View {
        let question = questions[currentQuestionIndex]
        return VStack(alignment: .leading, spacing: Spacing.xl) {
            ProgressView(value: Double(currentQuestionIndex), total: Double(questions.count))
            
            Text("Pilihlah jawaban yang paling tepat:")
                .font(.subheadline).foregroundColor(.secondary)
            
            Text(question.prompt)
                .font(.title2.bold())
                .padding(.vertical, Spacing.lg)
            
            optionsList(question)
            
            Spacer()
            
            nextButton
        }
    }
    
    private func optionsList(_ question: TestQuestion) -> some View {
        VStack(spacing: Spacing.md) {
            ForEach(0..<question.options.count, id: \.self) { index in
                Button {
                    if !isSubmitted { selectedOption = index }
                } label: {
                    HStack {
                        Text(question.options[index]).font(.body)
                        Spacer()
                    }
                    .padding()
                    .background(selectedOption == index ? Color.accentColor.mix(with: .white, by: 0.8) : Color.clear, in: RoundedRectangle(cornerRadius: CornerRadius.card))
                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: CornerRadius.card))
                    .overlay {
                        if selectedOption == index {
                            RoundedRectangle(cornerRadius: CornerRadius.card).stroke(Color.accentColor, lineWidth: 2)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var nextButton: some View {
        Button {
            submitAndNext()
        } label: {
            Text(currentQuestionIndex + 1 == questions.count ? "Selesai" : "Berikutnya")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(selectedOption != nil ? Color.accentColor : Color.gray.opacity(0.3), in: RoundedRectangle(cornerRadius: CornerRadius.card))
                .foregroundColor(.white)
        }
        .disabled(selectedOption == nil)
    }
    
    private var resultView: some View {
        VStack(spacing: Spacing.xxl) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Tes Selesai!")
                .font(.largeTitle.bold())
            
            Text("Berdasarkan hasil tes, level yang direkomendasikan untukmu adalah:")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            LevelBadge(level: recommendedLevel)
                .scaleEffect(2)
                .padding(.vertical, Spacing.xl)
            
            Spacer()
            
            Button("Mulai Belajar") {
                saveProgressAndDismiss()
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColor, in: RoundedRectangle(cornerRadius: CornerRadius.card))
            .foregroundColor(.white)
        }
    }
    
    // MARK: - Logic
    
    private func submitAndNext() {
        let question = questions[currentQuestionIndex]
        if selectedOption == question.correct {
            score += 1
            // Simple logic: higher score = higher level
        }
        
        if currentQuestionIndex + 1 < questions.count {
            currentQuestionIndex += 1
            selectedOption = nil
        } else {
            calculateResult()
        }
    }
    
    private func calculateResult() {
        // Simple mapping for this demo
        if score >= 9 { recommendedLevel = .c1 }
        else if score >= 7 { recommendedLevel = .b2 }
        else if score >= 5 { recommendedLevel = .b1 }
        else if score >= 3 { recommendedLevel = .a2 }
        else { recommendedLevel = .a1 }
        
        withAnimation { isComplete = true }
    }
    
    private func saveProgressAndDismiss() {
        let descriptor = FetchDescriptor<UserProgress>()
        if let progress = try? modelContext.fetch(descriptor).first {
            progress.currentLevel = recommendedLevel.rawValue
        } else {
            let newProgress = UserProgress(currentLevel: recommendedLevel)
            modelContext.insert(newProgress)
        }
        try? modelContext.save()
        dismiss()
    }
    
    struct TestQuestion {
        let prompt: String
        let options: [String]
        let correct: Int
        let level: CEFRLevel
    }
}

#Preview {
    LevelTestView()
        .modelContainer(for: [UserProgress.self], inMemory: true)
}
