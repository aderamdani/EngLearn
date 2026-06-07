import SwiftUI
import OSLog

@MainActor
final class WritingService: Sendable {
    func loadPrompts(for level: CEFRLevel) throws -> [WritingPrompt] {
        let fileName = "writing_\(level.rawValue)"
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            Log.data.warning("No writing file found: \(fileName).json")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let prompts = try decoder.decode([WritingPrompt].self, from: data)
            Log.data.info("Loaded \(prompts.count) writing prompts")
            return prompts
        } catch {
            Log.data.error("Failed to decode \(fileName).json: \(error)")
            throw AppError.jsonDecodingFailed(file: fileName, underlying: error)
        }
    }
}

struct WritingModuleView: View {
    @State private var selectedLevel: CEFRLevel = .a1
    @State private var prompts: [WritingPrompt] = []
    @State private var isLoading = false
    private let writingService = WritingService()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                levelPicker
                
                if isLoading {
                    ProgressView("Memuat topik...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    promptList
                }
            }
            .navigationTitle("Writing")
            .background(.regularMaterial)
            .task(id: selectedLevel) {
                await loadPrompts()
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
    
    private var promptList: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md) {
                if prompts.isEmpty {
                    emptyState
                } else {
                    ForEach(prompts) { prompt in
                        NavigationLink(destination: WritingPromptView(prompt: prompt)) {
                            promptCard(prompt)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(Spacing.lg)
        }
    }
    
    private func promptCard(_ prompt: WritingPrompt) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: "pencil.line")
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 44, height: 44)
                .background(Color.accentColor.opacity(0.1), in: Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(prompt.promptType)
                    .font(.headline)
                
                Text("Target: \(prompt.wordCountTarget) Kata")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.ultraThinMaterial, in: Capsule())
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundColor(.secondary)
        }
        .padding(Spacing.lg)
        .background {
            RoundedRectangle(cornerRadius: CornerRadius.card)
                .fill(.background)
                .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
        }
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: CornerRadius.card))
        .accessibilityLabel("\(prompt.promptType), target \(prompt.wordCountTarget) kata")
    }
    
    private var emptyState: some View {
        VStack(spacing: Spacing.md) {
            Text("Belum Ada Topik")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .padding(.top, Spacing.xxxl)
    }
    
    private func loadPrompts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            prompts = try writingService.loadPrompts(for: selectedLevel)
        } catch {
            Log.data.error("Gagal memuat topik: \(error.localizedDescription)")
            prompts = []
        }
    }
}
