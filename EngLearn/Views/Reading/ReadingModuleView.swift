import SwiftUI
import OSLog

@MainActor
final class ReadingService: Sendable {
    func loadPassages(for level: CEFRLevel) throws -> [ReadingPassage] {
        let fileName = "reading_\(level.rawValue)"
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            Log.data.warning("No reading file found: \(fileName).json")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let passages = try decoder.decode([ReadingPassage].self, from: data)
            Log.data.info("Loaded \(passages.count) reading passages")
            return passages
        } catch {
            Log.data.error("Failed to decode \(fileName).json: \(error)")
            throw AppError.jsonDecodingFailed(file: fileName, underlying: error)
        }
    }
}

struct ReadingModuleView: View {
    @State private var selectedLevel: CEFRLevel = .a1
    @State private var passages: [ReadingPassage] = []
    @State private var isLoading = false
    private let readingService = ReadingService()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                levelPicker
                
                if isLoading {
                    ProgressView("Memuat teks...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    passageList
                }
            }
            .navigationTitle("Reading")
            .task(id: selectedLevel) {
                await loadPassages()
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
    
    private var passageList: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md) {
                if passages.isEmpty {
                    emptyState
                } else {
                    ForEach(passages) { passage in
                        NavigationLink(destination: ReadingPassageView(passage: passage)) {
                            passageCard(passage)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(Spacing.lg)
        }
    }
    
    private func passageCard(_ passage: ReadingPassage) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(passage.title)
                    .font(.headline)
                
                Text("\(passage.wordCount) kata")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding(Spacing.lg)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: CornerRadius.card))
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: CornerRadius.card))
        .accessibilityLabel("\(passage.title), \(passage.wordCount) kata")
    }
    
    private var emptyState: some View {
        ContentUnavailableView(
            "Belum Ada Teks",
            systemImage: "book.closed",
            description: Text("Teks bacaan untuk level \(selectedLevel.displayName) sedang dalam perjalanan!")
        )
        .padding(.top, Spacing.xxxl)
    }
    
    private func loadPassages() async {
        isLoading = true
        defer { isLoading = false }
        do {
            passages = try readingService.loadPassages(for: selectedLevel)
        } catch {
            Log.data.error("Gagal memuat teks: \(error.localizedDescription)")
            passages = []
        }
    }
}

// Stub for Compilation
struct ReadingPassageView: View {
    let passage: ReadingPassage
    var body: some View { Text(passage.title) }
}

#Preview {
    ReadingModuleView()
}
