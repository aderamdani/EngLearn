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
            .background(.regularMaterial)
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
            LazyVStack(alignment: .leading, spacing: Spacing.xxl) {
                statsStrip
                
                wordOfTheDaySection
                
                actionButtons
                
                if levelEntries.isEmpty {
                    emptyStateCard
                }
            }
            .padding(Spacing.lg)
        }
    }
    
    private var levelEntries: [VocabularyEntry] {
        allEntries.filter { $0.level == selectedLevel.rawValue }
    }
    
    private var statsStrip: some View {
        let mastered = levelEntries.filter { $0.repetitions >= 3 }.count
        let needReview = levelEntries.filter { $0.isDueForReview }.count
        
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.md) {
                statCard(title: "Total Kata", value: "\(levelEntries.count)", icon: "book.fill", color: .blue)
                statCard(title: "Dikuasai", value: "\(mastered)", icon: "checkmark.seal.fill", color: .green)
                statCard(title: "Perlu Review", value: "\(needReview)", icon: "clock.arrow.2.circlepath", color: .orange)
            }
        }
    }
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(color)
            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.headline)
                Text(title)
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(.background, in: RoundedRectangle(cornerRadius: CornerRadius.card))
        .glassEffect(.regular, in: .rect(cornerRadius: CornerRadius.card))
    }
    
    private var wordOfTheDaySection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
                Text("Kata Hari Ini")
                    .font(.headline)
            }
            
            if let randomWord = levelEntries.shuffled().first {
                VStack(alignment: .leading, spacing: 4) {
                    Text(randomWord.word)
                        .font(.title2.bold())
                    Text(randomWord.definitionID)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(Spacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.background, in: RoundedRectangle(cornerRadius: CornerRadius.card))
                .glassEffect(.regular, in: .rect(cornerRadius: CornerRadius.card))
            } else {
                Text("Cari kata-kata baru untuk dipelajari!")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var emptyStateCard: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "character.book.closed.fill")
                .font(.system(size: 32))
                .foregroundColor(.accentColor)
            Text("Mulai belajar kosakata!")
                .font(.headline)
            Text("Pelajari kata-kata esensial level \(selectedLevel.displayName) untuk memperluas jangkauan komunikasimu.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding(Spacing.xl)
        .frame(maxWidth: .infinity)
        .background(.background, in: RoundedRectangle(cornerRadius: CornerRadius.card))
        .glassEffect(.regular, in: .rect(cornerRadius: CornerRadius.card))
    }
    
    private var actionButtons: some View {
        HStack(spacing: Spacing.md) {
            NavigationLink(destination: FlashcardView(level: selectedLevel)) {
                VStack(spacing: Spacing.sm) {
                    Image(systemName: "rectangle.on.rectangle.angled.fill")
                        .font(.title2)
                    Text("Kartu Flash")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.xl)
                .background(.background, in: RoundedRectangle(cornerRadius: CornerRadius.hero))
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: CornerRadius.hero))
            }
            .buttonStyle(.plain)
            
            NavigationLink(destination: VocabularyQuizView(level: selectedLevel)) {
                VStack(spacing: Spacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                    Text("Kuis")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.xl)
                .background(.background, in: RoundedRectangle(cornerRadius: CornerRadius.hero))
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: CornerRadius.hero))
            }
            .buttonStyle(.plain)
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
