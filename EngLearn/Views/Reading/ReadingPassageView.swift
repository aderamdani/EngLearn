import SwiftUI
import SwiftData

struct ReadingPassageView: View {
    let passage: ReadingPassage
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xxl) {
                Text(passage.title)
                    .font(.largeTitle.bold())
                
                Text(passage.passageText)
                    .font(.body)
                    .lineSpacing(6)
                    .padding(Spacing.lg)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: CornerRadius.card))
                    .glassEffect(.regular, in: .rect(cornerRadius: CornerRadius.card))
                
                vocabularySection
                
                startButton
            }
            .padding(Spacing.xxl)
        }
        .navigationTitle("Membaca")
    }
    
    private var vocabularySection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Kosakata Penting")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: Spacing.sm) {
                ForEach(passage.vocabulary, id: \.self) { word in
                    Text(word)
                        .font(.subheadline)
                        .padding(.vertical, Spacing.xs)
                        .padding(.horizontal, Spacing.sm)
                        .background(.ultraThinMaterial, in: Capsule())
                }
            }
        }
    }
    
    private var startButton: some View {
        NavigationLink(destination: ComprehensionQuizView(passage: passage)) {
            Text("Mulai Kuis")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor, in: RoundedRectangle(cornerRadius: CornerRadius.card))
                .foregroundColor(.white)
        }
        .buttonStyle(.plain)
        .padding(.top, Spacing.xl)
        .accessibilityLabel("Mulai kuis pemahaman")
    }
}
