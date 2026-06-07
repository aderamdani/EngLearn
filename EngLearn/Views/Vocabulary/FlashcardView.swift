import SwiftUI
import SwiftData

struct FlashcardView: View {
    let level: CEFRLevel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var entries: [VocabularyEntry]
    @State private var currentIndex = 0
    @State private var isFlipped = false
    
    init(level: CEFRLevel) {
        self.level = level
        let levelString = level.rawValue
        _entries = Query(filter: #Predicate<VocabularyEntry> { $0.level == levelString }, sort: \.nextReviewDate)
    }
    
    var body: some View {
        VStack(spacing: Spacing.xxl) {
            counterView
            
            cardView
                .onTapGesture { withAnimation(.easeInOut(duration: 0.4)) { isFlipped.toggle() } }
            
            if isFlipped {
                ratingButtons
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                Text("Ketuk kartu untuk melihat arti")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(Spacing.xxl)
        .navigationTitle("Kartu Flash")
        .background(.regularMaterial)
    }
    
    private var counterView: some View {
        Text("Kartu \(entries.isEmpty ? 0 : currentIndex + 1) dari \(entries.count)")
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    private var cardView: some View {
        ZStack {
            if !entries.isEmpty {
                let entry = entries[currentIndex]
                cardFace(entry: entry, isFront: true)
                    .opacity(isFlipped ? 0 : 1)
                cardFace(entry: entry, isFront: false)
                    .opacity(isFlipped ? 1 : 0)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            } else {
                ContentUnavailableView("Tidak ada kartu", systemImage: "rectangle.stack")
            }
        }
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .accessibilityLabel(entries.isEmpty ? "Tidak ada kartu" : "Kartu kosakata: \(entries[currentIndex].word)")
    }
    
    private func cardFace(entry: VocabularyEntry, isFront: Bool) -> some View {
        VStack(spacing: Spacing.lg) {
            if isFront {
                Text(entry.word)
                    .font(.system(size: 40, weight: .bold))
                Text(entry.phonetic)
                    .font(.title3)
                    .foregroundColor(.secondary)
                Text(entry.partOfSpeech.capitalized)
                    .font(.caption.bold())
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, 2)
                    .background(.ultraThinMaterial, in: Capsule())
            } else {
                backFaceContent(entry: entry)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .background(.background, in: RoundedRectangle(cornerRadius: CornerRadius.hero))
        .glassEffect(.regular, in: .rect(cornerRadius: CornerRadius.hero))
    }
    
    private func backFaceContent(entry: VocabularyEntry) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(entry.definitionEN)
                .font(.headline)
            Text(entry.definitionID)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Divider()
            Text("Contoh:").font(.caption.bold())
            Text(entry.exampleSentence).font(.body.italic())
            if !entry.contextID.isEmpty {
                Text("Tips:").font(.caption.bold()).padding(.top, Spacing.xs)
                Text(entry.contextID).font(.caption).foregroundColor(.secondary)
            }
        }
        .padding(Spacing.xl)
    }
    
    private var ratingButtons: some View {
        HStack(spacing: Spacing.lg) {
            rateButton(title: "Sulit", color: .red, quality: 1)
            rateButton(title: "Sedang", color: .orange, quality: 3)
            rateButton(title: "Mudah", color: .green, quality: 5)
        }
    }
    
    private func rateButton(title: String, color: Color, quality: Int) -> some View {
        Button {
            rateEntry(quality: quality)
        } label: {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: CornerRadius.card))
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: CornerRadius.card))
                .tint(color)
        }
        .accessibilityLabel("Nilai sebagai \(title)")
    }
    
    private func rateEntry(quality: Int) {
        guard !entries.isEmpty, currentIndex < entries.count else { return }
        let entry = entries[currentIndex]
        entry.updateAfterReview(quality: quality)
        
        withAnimation {
            if currentIndex + 1 < entries.count {
                currentIndex += 1
                isFlipped = false
            } else {
                dismiss()
            }
        }
    }
}
