import SwiftUI
import OSLog

@MainActor
final class ListeningService: Sendable {
    func loadDialogues(for level: CEFRLevel) throws -> [ListeningDialogue] {
        let fileName = "listening_\(level.rawValue)"
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            Log.data.warning("No listening file found: \(fileName).json")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let dialogues = try decoder.decode([ListeningDialogue].self, from: data)
            Log.data.info("Loaded \(dialogues.count) listening dialogues")
            return dialogues
        } catch {
            Log.data.error("Failed to decode \(fileName).json: \(error)")
            throw AppError.jsonDecodingFailed(file: fileName, underlying: error)
        }
    }
}

struct ListeningModuleView: View {
    @State private var selectedLevel: CEFRLevel = .a1
    @State private var dialogues: [ListeningDialogue] = []
    @State private var isLoading = false
    private let listeningService = ListeningService()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                levelPicker
                
                if isLoading {
                    ProgressView("Memuat dialog...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    dialogueList
                }
            }
            .navigationTitle("Listening")
            .task(id: selectedLevel) {
                await loadDialogues()
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
    
    private var dialogueList: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md) {
                if dialogues.isEmpty {
                    emptyState
                } else {
                    ForEach(dialogues) { dialogue in
                        NavigationLink(destination: DictationView(dialogue: dialogue)) {
                            dialogueCard(dialogue)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(Spacing.lg)
        }
    }
    
    private func dialogueCard(_ dialogue: ListeningDialogue) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(dialogue.title)
                    .font(.headline)
                
                Text("\(dialogue.exercises.count) Latihan Dikte")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "headphones")
                .foregroundColor(.accentColor)
        }
        .padding(Spacing.lg)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: CornerRadius.card))
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: CornerRadius.card))
        .accessibilityLabel("\(dialogue.title), \(dialogue.exercises.count) latihan dikte")
    }
    
    private var emptyState: some View {
        ContentUnavailableView(
            "Belum Ada Dialog",
            systemImage: "waveform",
            description: Text("Materi listening untuk level \(selectedLevel.displayName) sedang dalam perjalanan!")
        )
        .padding(.top, Spacing.xxxl)
    }
    
    private func loadDialogues() async {
        isLoading = true
        defer { isLoading = false }
        do {
            dialogues = try listeningService.loadDialogues(for: selectedLevel)
        } catch {
            Log.data.error("Gagal memuat dialog: \(error.localizedDescription)")
            dialogues = []
        }
    }
}

// Stub for Compilation
struct DictationView: View {
    let dialogue: ListeningDialogue
    var body: some View { Text(dialogue.title) }
}
