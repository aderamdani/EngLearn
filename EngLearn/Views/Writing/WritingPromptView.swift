import SwiftUI
import SwiftData

struct WritingPromptView: View {
    let prompt: WritingPrompt
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var text = ""
    @State private var showSample = false
    @State private var showTip = false
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    promptHeader
                    
                    TextEditor(text: $text)
                        .font(.body)
                        .padding(Spacing.sm)
                        .frame(minHeight: 200)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: CornerRadius.card))
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.card)
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                        )
                        .accessibilityLabel("Area mengetik")
                    
                    if showTip {
                        Label(prompt.tipID, systemImage: "lightbulb.fill")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: CornerRadius.card))
                    }
                    
                    if showSample {
                        sampleAnswerView
                    }
                }
                .padding(Spacing.xxl)
            }
            
            bottomBar
        }
        .navigationTitle(prompt.promptType)
        .background(.regularMaterial)
        .onChange(of: text) { _, _ in saveDraft() }
    }
    
    private var promptHeader: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(prompt.prompt)
                .font(.title2.bold())
            
            Text(prompt.instructionID)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var sampleAnswerView: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Contoh Jawaban:")
                .font(.headline)
                .foregroundColor(.accentColor)
            
            Text(prompt.sampleAnswer)
                .font(.body.italic())
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.accentColor.opacity(0.1), in: RoundedRectangle(cornerRadius: CornerRadius.card))
        }
    }
    
    private var bottomBar: some View {
        HStack {
            wordCountBadge
            
            Spacer()
            
            Button {
                withAnimation { showTip.toggle() }
            } label: {
                Image(systemName: showTip ? "lightbulb.fill" : "lightbulb")
                    .foregroundColor(.orange)
            }
            .buttonStyle(.plain)
            .padding(.trailing, Spacing.sm)
            .accessibilityLabel("Tampilkan tip")
            
            Button {
                withAnimation { showSample.toggle() }
            } label: {
                Text(showSample ? "Sembunyikan Contoh" : "Lihat Contoh")
                    .font(.subheadline.bold())
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Button("Selesai") {
                dismiss()
            }
            .font(.headline)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
            .background(Color.accentColor, in: Capsule())
            .foregroundColor(.white)
        }
        .padding()
        .background(.ultraThinMaterial)
    }
    
    private var currentWordCount: Int {
        text.split { $0.isWhitespace || $0.isNewline }.count
    }
    
    private var wordCountBadge: some View {
        HStack(spacing: Spacing.xs) {
            Text("\(currentWordCount) / \(prompt.wordCountTarget)")
                .font(.caption.monospacedDigit())
            Image(systemName: currentWordCount >= prompt.wordCountTarget ? "checkmark.circle.fill" : "circle")
        }
        .foregroundColor(currentWordCount >= prompt.wordCountTarget ? .green : .secondary)
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.xs)
        .background(.ultraThinMaterial, in: Capsule())
    }
    
    @State private var saveTask: Task<Void, Never>? = nil

    private func saveDraft() {
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                let descriptor = FetchDescriptor<WritingEntry>(predicate: #Predicate { $0.promptID == prompt.id })
                if let entry = try? modelContext.fetch(descriptor).first {
                    entry.text = text
                    entry.wordCount = currentWordCount
                    entry.lastEditedAt = Date()
                } else {
                    let newEntry = WritingEntry(
                        promptID: prompt.id,
                        level: CEFRLevel.a1, // Defaulting to A1 for now
                        text: text,
                        wordCount: currentWordCount,
                        targetWordCount: prompt.wordCountTarget
                    )
                    modelContext.insert(newEntry)
                }
                try? modelContext.save()
                Log.general.info("Draft saved for prompt: \(prompt.id)")
            }
        }
    }
}
