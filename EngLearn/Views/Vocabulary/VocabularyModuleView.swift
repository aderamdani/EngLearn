import SwiftUI
import SwiftData
import OSLog

struct VocabularyModuleView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedLevel: CEFRLevel = .a1
    @State private var isLoading = false
    @State private var searchQuery = ""
    
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
            .searchable(text: $searchQuery, prompt: "Cari kosakata...")
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
                } else {
                    reviewSection
                }
            }
            .padding(Spacing.lg)
        }
    }
    
    private var levelEntries: [VocabularyEntry] {
        let entries = allEntries.filter { $0.level == selectedLevel.rawValue }
        if searchQuery.isEmpty { return entries }
        return entries.filter { $0.word.localizedCaseInsensitiveContains(searchQuery) }
    }
    
    private var statsStrip: some View {
        let mastered = levelEntries.filter { $0.repetitions >= 3 }.count
        let needReview = levelEntries.filter { $0.isDueForReview }.count
        
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.md) {
                statCard(title: "Total", value: "\(levelEntries.count)", icon: "book.fill", color: .blue)
                statCard(title: "Kuasai", value: "\(mastered)", icon: "checkmark.seal.fill", color: .green)
                statCard(title: "Review", value: "\(needReview)", icon: "clock.arrow.2.circlepath", color: .orange)
            }
            .padding(.trailing, Spacing.lg)
        }
    }
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(color)
            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.headline)
                Text(title)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background {
            RoundedRectangle(cornerRadius: CornerRadius.card)
                .fill(.background)
                .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
        }
        .glassEffect(.regular, in: .rect(cornerRadius: CornerRadius.card))
    }
    
    private var wordOfTheDaySection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            headerLabel("Kata Hari Ini", icon: "sparkles", color: .yellow)
            
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
                .background {
                    RoundedRectangle(cornerRadius: CornerRadius.card)
                        .fill(.background)
                        .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
                }
                .glassEffect(.regular, in: .rect(cornerRadius: CornerRadius.card))
            }
        }
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
                .padding(.vertical, Spacing.lg)
                .background {
                    RoundedRectangle(cornerRadius: CornerRadius.hero)
                        .fill(.background)
                        .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
                }
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
                .padding(.vertical, Spacing.lg)
                .background {
                    RoundedRectangle(cornerRadius: CornerRadius.hero)
                        .fill(.background)
                        .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
                }
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: CornerRadius.hero))
            }
            .buttonStyle(.plain)
        }
    }
    
    private var reviewSection: some View {
        let reviewList = levelEntries.filter { $0.isDueForReview }
        
        return VStack(alignment: .leading, spacing: Spacing.md) {
            headerLabel("Perlu Di-review", icon: "clock.arrow.2.circlepath", color: .orange)
            
            if reviewList.isEmpty {
                Text("Semua kata sudah dikuasai! Kamu hebat.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)
            } else {
                VStack(spacing: Spacing.sm) {
                    ForEach(reviewList.prefix(3)) { entry in
                        HStack {
                            Text(entry.word)
                                .font(.headline)
                            Spacer()
                            Text(entry.partOfSpeech)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.ultraThinMaterial, in: Capsule())
                        }
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: CornerRadius.standard)
                                .fill(.background)
                        }
                        .glassEffect(.regular, in: .rect(cornerRadius: CornerRadius.standard))
                    }
                }
            }
        }
    }
    
    private var emptyStateCard: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "character.book.closed.fill")
                .font(.system(size: 32))
                .foregroundColor(.accentColor)
            Text("Belum ada kosakata")
                .font(.headline)
            Text("Mulai belajar dengan Kartu Flash untuk level \(selectedLevel.displayName)!")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button {
                // Navigate to Flashcards or similar
            } label: {
                Text("Mulai Belajar Sekarang")
                    .font(.subheadline.bold())
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.sm)
                    .background(Color.accentColor, in: Capsule())
                    .foregroundColor(.white)
            }
            .padding(.top, Spacing.sm)
        }
        .padding(Spacing.xl)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: CornerRadius.card)
                .fill(.background)
                .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
        }
        .glassEffect(.regular, in: .rect(cornerRadius: CornerRadius.card))
    }
    
    private func headerLabel(_ title: String, icon: String, color: Color) -> some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(title)
                .font(.headline)
        }
        .padding(.leading, 4)
    }
    
    private func seedAndLoad() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await vocabularyService.seedVocabulary(modelContext: modelContext, level: selectedLevel)
        } catch {
            Log.data.error("Gagal menyemai data kosakata: \(error.localizedDescription)")
        }
    }
}

#Preview {
    VocabularyModuleView()
        .modelContainer(for: [VocabularyEntry.self], inMemory: true)
}
