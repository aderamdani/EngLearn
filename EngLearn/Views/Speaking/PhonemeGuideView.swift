import SwiftUI
import SwiftData

struct PhonemeGuideView: View {
    let phoneme: Phoneme
    
    @State private var audioService = AudioPlaybackService()
    @State private var speechService = SpeechRecognitionService()
    @State private var recognitionAuthorized = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xxl) {
                headerSection
                
                infoSection(title: "Deskripsi Bunyi", content: phoneme.descriptionID, icon: "info.circle.fill")
                
                infoSection(title: "Posisi Mulut", content: phoneme.mouthPositionID, icon: "mouth.fill")
                
                infoSection(title: "Kesalahan Umum", content: phoneme.commonMistakeID, icon: "exclamationmark.triangle.fill", color: .orange)
                
                exampleWordsSection
                
                practiceSection
            }
            .padding(Spacing.xxl)
        }
        .navigationTitle(phoneme.ipaSymbol)
        .background(.regularMaterial)
        .onDisappear {
            audioService.stop()
            speechService.stop()
        }
        .task {
            recognitionAuthorized = await speechService.requestAuthorization()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: Spacing.md) {
            Text(phoneme.ipaSymbol)
                .font(.system(size: 80, weight: .bold))
                .foregroundColor(.accentColor)
            
            Button {
                audioService.play(text: phoneme.exampleWords.first ?? "", rate: AppConstants.Limits.ttsSlowRate)
            } label: {
                HStack {
                    Image(systemName: audioService.isPlaying ? "speaker.wave.3.fill" : "play.circle.fill")
                    Text("Dengarkan")
                }
                .font(.headline)
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.sm)
                .background(Color.accentColor, in: Capsule())
                .foregroundColor(.white)
            }
            .accessibilityLabel("Dengarkan cara pengucapan")
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.xl)
        .background(.background, in: RoundedRectangle(cornerRadius: CornerRadius.hero))
        .glassEffect(.regular, in: .rect(cornerRadius: CornerRadius.hero))
    }
    
    private func infoSection(title: String, content: String, icon: String, color: Color = .accentColor) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
            }
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.lg)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: CornerRadius.card))
    }
    
    private var exampleWordsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Contoh Kata")
                .font(.headline)
            
            VStack(spacing: Spacing.sm) {
                ForEach(phoneme.exampleWords, id: \.self) { word in
                    HStack {
                        Text(word)
                            .font(.title3)
                        
                        Spacer()
                        
                        Button {
                            audioService.play(text: word, rate: AppConstants.Limits.ttsNormalRate)
                        } label: {
                            Image(systemName: "speaker.wave.2.fill")
                                .foregroundColor(.accentColor)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Dengarkan kata \(word)")
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: CornerRadius.standard)
                            .fill(.background)
                    }
                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: CornerRadius.standard))
                }
            }
        }
    }

    private var practiceSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Latihan Pengucapan")
                .font(.headline)
            
            if recognitionAuthorized {
                VStack(spacing: Spacing.md) {
                    HStack {
                        Button {
                            if speechService.isRecording {
                                speechService.stop()
                            } else {
                                try? speechService.start()
                            }
                        } label: {
                            Image(systemName: speechService.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                .font(.system(size: 44))
                                .foregroundColor(speechService.isRecording ? .red : .accentColor)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(speechService.isRecording ? "Hentikan rekaman" : "Mulai merekam")
                        
                        Text(speechService.isRecording ? "Mendengarkan..." : "Tekan untuk bicara")
                            .foregroundColor(.secondary)
                            .padding(.leading, Spacing.sm)
                        
                        Spacer()
                    }
                    
                    if !speechService.recognizedText.isEmpty {
                        Text("Yang terdengar:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(speechService.recognizedText)
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background {
                                RoundedRectangle(cornerRadius: CornerRadius.card)
                                    .fill(.background)
                            }
                            .glassEffect(.regular, in: .rect(cornerRadius: CornerRadius.card))
                    }
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: CornerRadius.card)
                        .fill(.background)
                        .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
                }
                .glassEffect(.regular, in: .rect(cornerRadius: CornerRadius.card))
            } else {
                Text("Akses mikrofon diperlukan untuk latihan ini.")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
    }
}
