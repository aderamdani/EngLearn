import SwiftUI
import SwiftData
import OSLog

struct DailyLessonView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage("dailyGoalMinutes") private var dailyGoalMinutes = 10
    
    @Query private var todayStreaks: [DailyStreak]
    @State private var minutesLearned: Int = 0
    @State private var isComplete = false
    
    @State private var dailyLesson: Lesson? = nil
    @State private var navigateToExercise = false
    
    var body: some View {
        VStack(spacing: Spacing.xxl) {
            headerSection
            
            if isComplete {
                completionView
            } else {
                dailyChallengeContent
            }
            
            Spacer()
        }
        .padding(Spacing.xxl)
        .navigationTitle("Pelajaran Harian")
        .background(.regularMaterial)
        .onAppear {
            updateMinutesFromStreak()
        }
        .navigationDestination(isPresented: $navigateToExercise) {
            if let lesson = dailyLesson {
                GrammarExerciseView(lesson: lesson)
                    .onDisappear {
                        // After exercise is done, update streak
                        if lesson.exercises.count > 0 { // Simplistic check if we did something
                            simulateLearning(minutes: 5, exercises: lesson.exercises.count)
                        }
                    }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .stroke(Color.gray.mix(with: .white, by: 0.8), lineWidth: 10)
                    .frame(width: 150, height: 150)
                
                Circle()
                    .trim(from: 0, to: CGFloat(min(Double(minutesLearned) / Double(dailyGoalMinutes), 1.0)))
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: minutesLearned)
                
                VStack {
                    Text("\(minutesLearned)")
                        .font(.system(size: 40, weight: .black))
                    Text("menit")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .drawingGroup()
            
            Text("Target harian: \(dailyGoalMinutes) menit")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var dailyChallengeContent: some View {
        VStack(spacing: Spacing.lg) {
            Text("Tantangan Hari Ini")
                .font(.title2.bold())
            
            Text("Selesaikan campuran latihan grammar dan kosakata untuk mencapai target harianmu.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button {
                generateMixedLesson()
            } label: {
                HStack {
                    Image(systemName: "bolt.fill")
                    Text("Mulai Tantangan")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor, in: RoundedRectangle(cornerRadius: CornerRadius.card))
                .foregroundColor(.white)
            }
            .accessibilityLabel("Mulai tantangan harian")
        }
        .padding(Spacing.xl)
        .background(.background, in: RoundedRectangle(cornerRadius: CornerRadius.hero))
        .glassEffect(.regular, in: .rect(cornerRadius: CornerRadius.hero))
    }
    
    private var completionView: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Luar Biasa!")
                .font(.title.bold())
            
            Text("Kamu telah mencapai target belajar hari ini.")
                .foregroundColor(.secondary)
            
            Button("Selesai") {
                dismiss()
            }
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.accentColor, in: RoundedRectangle(cornerRadius: CornerRadius.card))
            .foregroundColor(.white)
        }
    }
    
    // MARK: - Logic
    
    private func updateMinutesFromStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        if let streak = todayStreaks.first(where: { calendar.isDate($0.date, inSameDayAs: today) }) {
            minutesLearned = streak.minutesSpent
            if minutesLearned >= dailyGoalMinutes {
                isComplete = true
            }
        }
    }
    
    private func generateMixedLesson() {
        // We will just load grammar_a1.json and take 5 random exercises to form a challenge
        let lessonService = LessonService()
        Task {
            do {
                let lessons = try lessonService.lessons(for: .grammar, level: .a1)
                let allExercises = lessons.flatMap { $0.exercises }.shuffled()
                let selected = Array(allExercises.prefix(5))
                
                dailyLesson = Lesson(
                    id: "daily_\(UUID().uuidString)",
                    skill: .dailyLesson,
                    level: .a1,
                    title: "Tantangan Harian",
                    theme: "Mixed",
                    cefrCanDo: "Daily practice",
                    explanation: nil,
                    exercises: selected
                )
                navigateToExercise = true
            } catch {
                Log.general.error("Failed to generate daily lesson")
            }
        }
    }
    
    private func simulateLearning(minutes: Int, exercises: Int) {
        minutesLearned += minutes
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        
        if let existing = todayStreaks.first(where: { calendar.isDate($0.date, inSameDayAs: today) }) {
            existing.minutesSpent = minutesLearned
            existing.exercisesCompleted += exercises
        } else {
            let newStreak = DailyStreak(date: today)
            newStreak.minutesSpent = minutesLearned
            newStreak.exercisesCompleted = exercises
            modelContext.insert(newStreak)
        }
        
        if minutesLearned >= dailyGoalMinutes {
            withAnimation { isComplete = true }
        }
        
        try? modelContext.save()
    }
}

#Preview {
    DailyLessonView()
        .modelContainer(for: [DailyStreak.self], inMemory: true)
}
