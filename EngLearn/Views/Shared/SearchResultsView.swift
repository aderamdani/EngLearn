import SwiftUI
import SwiftData

struct SearchResultsView: View {
    let query: String
    let vocabularyEntries: [VocabularyEntry]

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: Spacing.xl) {
                if !vocabularyEntries.isEmpty {
                    vocabularySection
                }

                if vocabularyEntries.isEmpty {
                    ContentUnavailableView(
                        "Tidak Ada Hasil",
                        systemImage: "magnifyingglass",
                        description: Text("Tidak ditemukan hasil untuk \"\(query)\". Coba kata kunci lain.")
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding(Spacing.lg)
        }
        .navigationTitle("Hasil Pencarian")
        .background(.regularMaterial)
    }

    private var vocabularySection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Image(systemName: "character.book.closed")
                    .foregroundColor(.accentColor)
                Text("Kosakata")
                    .font(.headline)
                Text("(\(vocabularyEntries.count))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            ForEach(vocabularyEntries.prefix(20)) { entry in
                vocabResultCard(entry)
            }
        }
    }

    private func vocabResultCard(_ entry: VocabularyEntry) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Text(entry.word)
                    .font(.headline)
                Spacer()
                LevelBadge(level: CEFRLevel(rawValue: entry.level) ?? .a1, isSmall: true)
            }
            Text(entry.definitionID)
                .font(.subheadline)
                .foregroundColor(.secondary)
            if !entry.exampleSentence.isEmpty {
                Text(entry.exampleSentence)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding(Spacing.md)
        .background {
            RoundedRectangle(cornerRadius: CornerRadius.card)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 4, y: 1)
        }
        .accessibilityLabel("\(entry.word): \(entry.definitionID)")
    }
}
