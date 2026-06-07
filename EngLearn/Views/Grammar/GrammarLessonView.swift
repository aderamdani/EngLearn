import SwiftUI

struct GrammarLessonView: View {
    let lesson: Lesson
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: Spacing.xxl) {
                if let explanation = lesson.explanation {
                    explanationSection(explanation)
                }
                
                examplesSection
                
                if let exceptions = lesson.explanation?.exceptions, !exceptions.isEmpty {
                    exceptionsSection(exceptions)
                }
                
                startButton
            }
            .padding(Spacing.lg)
        }
        .navigationTitle(lesson.title)
        .background(.regularMaterial)
    }
    
    // MARK: - Sections
    
    private func explanationSection(_ explanation: GrammarExplanation) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Penjelasan")
                .font(.headline)
            
            Text(explanation.ruleID)
                .font(.body)
                .foregroundColor(.primary)
                .padding(Spacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.background, in: RoundedRectangle(cornerRadius: CornerRadius.card))
                .glassEffect(.regular, in: .rect(cornerRadius: CornerRadius.card))
        }
    }
    
    private var examplesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Contoh Penggunaan")
                .font(.headline)
            
            ForEach(lesson.explanation?.examples ?? [], id: \.self) { example in
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text(example)
                        .font(.body.italic())
                }
                .padding(Spacing.sm)
            }
        }
    }
    
    private func exceptionsSection(_ exceptions: [String]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Pengecualian")
                .font(.headline)
                .foregroundColor(.orange)
            
            ForEach(exceptions, id: \.self) { exception in
                HStack(alignment: .top, spacing: Spacing.sm) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text(exception)
                        .font(.body)
                }
                .padding(Spacing.sm)
            }
        }
    }
    
    private var startButton: some View {
        NavigationLink(destination: GrammarExerciseView(lesson: lesson)) {
            HStack {
                Text("Mulai Latihan")
                    .font(.headline)
                Image(systemName: "play.fill")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColor, in: RoundedRectangle(cornerRadius: CornerRadius.card))
            .foregroundColor(.white)
        }
        .buttonStyle(.plain)
        .padding(.top, Spacing.xl)
        .accessibilityLabel("Mulai latihan grammar untuk \(lesson.title)")
    }
}

#Preview {
    NavigationStack {
        GrammarLessonView(lesson: Lesson(
            id: "1",
            skill: .grammar,
            level: .a1,
            title: "Present Simple",
            theme: "Daily Life",
            cefrCanDo: "Can talk about habits",
            explanation: GrammarExplanation(
                ruleID: "Gunakan present simple untuk kebiasaan atau fakta umum.",
                ruleEN: "Use present simple for habits or general truths.",
                examples: ["I eat breakfast.", "The sun rises in the east."],
                exceptions: ["He/She/It ditambahkan -s."],
                tipID: "Selalu ingat akhiran -s untuk orang ketiga tunggal."
            ),
            exercises: []
        ))
    }
}
