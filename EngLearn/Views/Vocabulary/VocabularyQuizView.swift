import SwiftUI
import SwiftData

struct VocabularyQuizView: View {
    let level: CEFRLevel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var allEntries: [VocabularyEntry]
    @State private var quizQuestions: [QuizQuestion] = []
    @State private var currentIndex = 0
    @State private var score = 0
    @State private var isSubmitted = false
    @State private var selectedOption: Int? = nil
    @State private var isComplete = false
    
    struct QuizQuestion {
        let entry: VocabularyEntry
        let options: [String]
        let correctIndex: Int
        let isWordToDefinition: Bool
    }
    
    init(level: CEFRLevel) {
        self.level = level
        let levelString = level.rawValue
        _allEntries = Query(filter: #Predicate<VocabularyEntry> { $0.level == levelString })
    }
    
    var body: some View {
        VStack(spacing: Spacing.xxl) {
            if isComplete {
                completionView
            } else if quizQuestions.isEmpty {
                emptyState
            } else {
                quizContent
            }
        }
        .padding(Spacing.xxl)
        .navigationTitle("Kuis Kosakata")
        .background(.regularMaterial)
        .onAppear { if quizQuestions.isEmpty { generateQuiz() } }
    }
    
    private var quizContent: some View {
        let question = quizQuestions[currentIndex]
        return VStack(alignment: .leading, spacing: Spacing.xl) {
            ProgressView(value: Double(currentIndex), total: Double(quizQuestions.count))
            
            Text(question.isWordToDefinition ? "Apa arti dari kata ini?" : "Manakah kata yang tepat untuk arti ini?")
                .font(.subheadline).foregroundColor(.secondary)
            
            Text(question.isWordToDefinition ? question.entry.word : question.entry.definitionID)
                .font(.title.bold())
                .padding(.bottom, Spacing.lg)
            
            optionsList(question)
            
            if isSubmitted {
                feedbackView(question)
            }
            
            Spacer()
            
            actionButton
        }
    }
    
    private func optionsList(_ question: QuizQuestion) -> some View {
        VStack(spacing: Spacing.md) {
            ForEach(0..<question.options.count, id: \.self) { index in
                Button { if !isSubmitted { selectedOption = index } } label: {
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
    
    private func feedbackView(_ question: QuizQuestion) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(selectedOption == question.correctIndex ? "Benar!" : "Kurang tepat.")
                .font(.headline)
                .foregroundColor(selectedOption == question.correctIndex ? .green : .orange)
            Text(question.entry.definitionID)
                .font(.subheadline)
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
                .font(.headline).frame(maxWidth: .infinity).padding()
                .background(selectedOption != nil ? Color.accentColor : Color.gray.opacity(0.3), in: RoundedRectangle(cornerRadius: CornerRadius.card))
                .foregroundColor(.white)
        }
        .disabled(selectedOption == nil)
    }
    
    private var completionView: some View {
        VStack(spacing: Spacing.xxl) {
            Spacer()
            Image(systemName: "trophy.fill").font(.system(size: 80)).foregroundColor(.yellow)
            Text("Kuis Selesai!").font(.largeTitle.bold())
            Text("Skor kamu:").font(.headline)
            Text("\(score * 100 / quizQuestions.count)%").font(.system(size: 60, weight: .black)).foregroundColor(.green)
            Spacer()
            Button("Selesai") { dismiss() }
                .font(.headline).frame(maxWidth: .infinity).padding()
                .background(Color.accentColor, in: RoundedRectangle(cornerRadius: CornerRadius.card))
                .foregroundColor(.white)
        }
    }
    
    private var emptyState: some View {
        ContentUnavailableView("Belum ada kata untuk diuji", systemImage: "book.closed", description: Text("Pelajari beberapa kata di Kartu Flash terlebih dahulu!"))
    }
    
    // MARK: - Logic
    
    private func generateQuiz() {
        let reviewedEntries = allEntries.filter { $0.repetitions > 0 }
        guard reviewedEntries.count >= 4 else { return }
        
        let selectedForQuiz = reviewedEntries.shuffled().prefix(10)
        quizQuestions = selectedForQuiz.map { entry in
            let isWordToDef = Bool.random()
            var options: [String] = []
            if isWordToDef {
                options = ([entry.definitionID] + reviewedEntries.filter { $0.id != entry.id }.shuffled().prefix(3).map { $0.definitionID }).shuffled()
            } else {
                options = ([entry.word] + reviewedEntries.filter { $0.id != entry.id }.shuffled().prefix(3).map { $0.word }).shuffled()
            }
            let correctIdx = options.firstIndex(of: isWordToDef ? entry.definitionID : entry.word) ?? 0
            return QuizQuestion(entry: entry, options: options, correctIndex: correctIdx, isWordToDefinition: isWordToDef)
        }
    }
    
    private func submitAnswer() {
        withAnimation {
            isSubmitted = true
            if selectedOption == quizQuestions[currentIndex].correctIndex {
                score += 1
            }
        }
    }
    
    private func nextQuestion() {
        if currentIndex + 1 < quizQuestions.count {
            withAnimation {
                currentIndex += 1
                isSubmitted = false
                selectedOption = nil
            }
        } else {
            isComplete = true
        }
    }
}
