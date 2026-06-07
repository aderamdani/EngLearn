import SwiftUI
import SwiftData
import OSLog

struct VocabularyModuleView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedLevel: CEFRLevel = .a1
    @State private var isLoading = false
    
    @Query private var allEntries: [VocabularyEntry]
    
    private let vocabularyService = VocabularyService()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                levelPicker
                
                if isLoading {
                    ProgressView("Memuat kosakata...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    content
                }
            }
            .navigationTitle("Vocabulary")
            .task(id: selectedLevel) {
                await seedAndLoad()
            }
        }
    }
    
    private var levelPicker: some View {
        Picker("Level", selection: $selectedLevel) {
            ForEach(CEFRLevel.allCases) { level in
                Text(level.displayName).tag(level)
            }
        }
        .pickerStyle(.segmented)
        .padding(Spacing.lg)
        .background(.regularMaterial)
    }
    
    private var content: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.xxl) {
                statsSection
                
                actionButtons
            }
            .padding(Spacing.xxl)
        }
    }
    
    private var statsSection: some View {
        let levelEntries = allEntries.filter { $0.level == selectedLevel.rawValue }
        let mastered = levelEntries.filter { $0.repetitions >= 3 }.count
        let needReview = levelEntries.filter { $0.isDueForReview }.count
        
        return VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Statistik Belajar")
                .font(.headline)
            
            HStack(spacing: Spacing.lg) {
                statCard(title: "Total Kata", value: "\(levelEntries.count)", icon: "book.fill", color: .blue)
                statCard(title: "Dikuasai", value: "\(mastered)", icon: "checkmark.seal.fill", color: .green)
                statCard(title: "Perlu Review", value: "\(needReview)", icon: "clock.arrow.2.circlepath", color: .orange)
            }
        }
    }
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(value)
                .font(.title3.bold())
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.md)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: CornerRadius.card))
        .glassEffect(.regular, in: .rect(cornerRadius: CornerRadius.card))
    }
    
    private var actionButtons: some View {
        VStack(spacing: Spacing.lg) {
            NavigationLink(destination: FlashcardView(level: selectedLevel)) {
                HStack {
                    Image(systemName: "rectangle.on.rectangle.angled.fill")
                    Text("Kartu Flash (Belajar)")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .background(Color.accentColor, in: RoundedRectangle(cornerRadius: CornerRadius.card))
                .foregroundColor(.white)
            }
            .accessibilityLabel("Mulai belajar dengan kartu flash")
            
            NavigationLink(destination: VocabularyQuizView(level: selectedLevel)) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Kuis Kosakata (Uji)")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: CornerRadius.card))
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: CornerRadius.card))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Mulai kuis kosakata")
        }
    }
    
    private func seedAndLoad() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await vocabularyService.seedInitialData(modelContext: modelContext, level: selectedLevel)
        } catch {
            Log.data.error("Gagal menyemai data kosakata: \(error.localizedDescription)")
        }
    }
}

#Preview {
    VocabularyModuleView()
        .modelContainer(for: [VocabularyEntry.self], inMemory: true)
}
