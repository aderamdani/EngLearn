import SwiftUI
import SwiftData

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("dailyGoalMinutes") private var dailyGoalMinutes = 10
    @Environment(\.modelContext) private var modelContext
    
    @State private var currentStep = 1
    @State private var showLevelTest = false
    
    var body: some View {
        VStack {
            if showLevelTest {
                LevelTestView()
            } else {
                stepContent
            }
        }
        .frame(width: 600, height: 500)
        .background(.regularMaterial)
    }
    
    @ViewBuilder
    private var stepContent: some View {
        VStack(spacing: Spacing.xxl) {
            Spacer()
            
            switch currentStep {
            case 1: welcomeStep
            case 2: languageStep
            case 3: beginnerOrTestStep
            case 4: goalStep
            case 5: permissionStep
            case 6: finalStep
            default: welcomeStep
            }
            
            Spacer()
            
            if currentStep != 3 { // Step 3 has its own buttons
                navigationButtons
            }
        }
        .padding(Spacing.xxxl)
    }
    
    // MARK: - Steps
    
    private var welcomeStep: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "hand.wave.fill")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
            
            Text("Selamat Datang di EngLearn!")
                .font(.largeTitle.bold())
            
            Text("Teman setia kamu untuk menguasai bahasa Inggris dengan cara yang seru dan interaktif.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
    }
    
    private var languageStep: some View {
        VStack(spacing: Spacing.lg) {
            Text("Pilih Bahasa Pengantar")
                .font(.title.bold())
            
            Text("Bahasa ini akan digunakan untuk instruksi dan penjelasan.")
                .foregroundColor(.secondary)
            
            Button { /* Native selection placeholder */ } label: {
                HStack {
                    Text("Bahasa Indonesia")
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                }
                .padding()
                .background(Color.accentColor.opacity(0.1), in: RoundedRectangle(cornerRadius: CornerRadius.card))
            }
            .buttonStyle(.plain)
        }
    }
    
    private var beginnerOrTestStep: some View {
        VStack(spacing: Spacing.xl) {
            Text("Tentukan Level Kamu")
                .font(.title.bold())
            
            VStack(spacing: Spacing.md) {
                Button {
                    currentStep += 1
                } label: {
                    VStack(alignment: .leading) {
                        Text("Saya Pemula").font(.headline)
                        Text("Mulai dari level dasar (A1)").font(.caption).foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.background, in: RoundedRectangle(cornerRadius: CornerRadius.card))
                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: CornerRadius.card))
                }
                .buttonStyle(.plain)
                
                Button {
                    showLevelTest = true
                } label: {
                    VStack(alignment: .leading) {
                        Text("Ikuti Tes Penempatan").font(.headline)
                        Text("Cari tahu level CEFR kamu sekarang").font(.caption).foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.background, in: RoundedRectangle(cornerRadius: CornerRadius.card))
                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: CornerRadius.card))
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var goalStep: some View {
        VStack(spacing: Spacing.lg) {
            Text("Set Target Harian")
                .font(.title.bold())
            
            Picker("Menit per hari", selection: $dailyGoalMinutes) {
                Text("5 menit").tag(5)
                Text("10 menit").tag(10)
                Text("15 menit").tag(15)
                Text("20 menit").tag(20)
            }
            .pickerStyle(.segmented)
            
            Text("Sedikit demi sedikit, lama-lama menjadi bukit!")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var permissionStep: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "mic.fill")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
            
            Text("Izin Mikrofon")
                .font(.title.bold())
            
            Text("Kami butuh akses mikrofon untuk fitur latihan berbicara (Speaking).")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("Berikan Akses") {
                // Request permission logic
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    private var finalStep: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "rocket.fill")
                .font(.system(size: 80))
                .foregroundColor(.orange)
            
            Text("Siap Meluncur!")
                .font(.largeTitle.bold())
            
            Text("Semua persiapan sudah selesai. Ayo mulai petualangan belajarmu!")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Navigation
    
    private var navigationButtons: some View {
        HStack {
            if currentStep > 1 {
                Button("Kembali") {
                    withAnimation { currentStep -= 1 }
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(currentStep == 6 ? "Mulai Belajar!" : "Lanjut") {
                if currentStep == 6 {
                    completeOnboarding()
                } else {
                    withAnimation { currentStep += 1 }
                }
            }
            .font(.headline)
            .padding(.horizontal, Spacing.xl)
            .padding(.vertical, Spacing.sm)
            .background(Color.accentColor, in: Capsule())
            .foregroundColor(.white)
        }
    }
    
    private func completeOnboarding() {
        // Initialize user progress if not exists
        let descriptor = FetchDescriptor<UserProgress>()
        if (try? modelContext.fetch(descriptor))?.first == nil {
            let newProgress = UserProgress(currentLevel: .a1, onboardingCompleted: true)
            modelContext.insert(newProgress)
        }
        
        hasCompletedOnboarding = true
    }
}

#Preview {
    OnboardingView()
        .modelContainer(for: [UserProgress.self], inMemory: true)
}
