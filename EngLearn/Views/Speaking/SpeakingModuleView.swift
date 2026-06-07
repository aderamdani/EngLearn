import SwiftUI
import OSLog

@MainActor
final class SpeakingService: Sendable {
    func loadPhonemes() throws -> [Phoneme] {
        let fileName = "speaking_phonemes"
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            Log.data.warning("No speaking file found: \(fileName).json")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let phonemes = try decoder.decode([Phoneme].self, from: data)
            Log.data.info("Loaded \(phonemes.count) phonemes")
            return phonemes
        } catch {
            Log.data.error("Failed to decode \(fileName).json: \(error)")
            throw AppError.jsonDecodingFailed(file: fileName, underlying: error)
        }
    }
}

struct SpeakingModuleView: View {
    @State private var phonemes: [Phoneme] = []
    @State private var isLoading = false
    private let speakingService = SpeakingService()
    
    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: Spacing.md)
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView("Memuat data fonem...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if phonemes.isEmpty {
                    ContentUnavailableView("Belum Ada Data", systemImage: "waveform")
                } else {
                    phonemeGrid
                }
            }
            .navigationTitle("Speaking (Pronunciation)")
            .background(.regularMaterial)
            .task {
                await loadData()
            }
        }
    }
    
    private var phonemeGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: Spacing.md) {
                ForEach(phonemes) { phoneme in
                    NavigationLink(destination: PhonemeGuideView(phoneme: phoneme)) {
                        phonemeCard(phoneme)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(Spacing.lg)
        }
    }
    
    private func phonemeCard(_ phoneme: Phoneme) -> some View {
        VStack(spacing: Spacing.sm) {
            Text(phoneme.ipaSymbol)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.accentColor)
            
            Text(phoneme.exampleWords.first ?? "")
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.lg)
        .background(.background, in: RoundedRectangle(cornerRadius: CornerRadius.card))
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: CornerRadius.card))
        .accessibilityLabel("Fonem \(phoneme.ipaSymbol)")
    }
    
    private func loadData() async {
        isLoading = true
        defer { isLoading = false }
        do {
            phonemes = try speakingService.loadPhonemes()
        } catch {
            Log.data.error("Gagal memuat fonem: \(error.localizedDescription)")
            phonemes = []
        }
    }
}
