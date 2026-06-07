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
        VStack(spacing: Spacing.xl) {
            headerSection
                .padding(.top, Spacing.xxl)
            
            if isComplete {
                completionView
            } else {
                dailyChallengeContent
            }
            
            Spacer()
        }
        .padding(Spacing.lg)
        .navigationTitle("Pelajaran Harian")
        .onAppear {
            updateMinutesFromStreak()
        }
        .navigationDestination(isPresented: $navigateToExercise) {
            if let lesson = dailyLesson {
                GrammarExerciseView(lesson: lesson)
                    .onDisappear {
                        if lesson.exercises.count > 0 {
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
                    .stroke(Color.primary.opacity(0.1), lineWidth: 10)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: CGFloat(min(Double(minutesLearned) / Double(dailyGoalMinutes), 1.0)))
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: minutesLearned)
                
                VStack(spacing: 0) {
                    Text("\(minutesLearned)")
                        .font(.system(size: 32, weight: .black))
                    Text("menit")
                        .font(.caption2)
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
        VStack(spacing: Spacing.md) {
            Text("Tantangan Hari Ini")
                .font(.title3.bold())
            
            Text("Selesaikan campuran latihan grammar dan kosakata untuk mencapai target harianmu.")
                .font(.subheadline)
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
            .buttonStyle(.plain)
            .accessibilityLabel("Mulai tantangan harian")
        }
        .padding(Spacing.lg)
        .background {
            RoundedRectangle(cornerRadius: CornerRadius.hero)
                .fill(.background)
                .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
        }
    }
    
    private var completionView: some View {
        VStack(spacing: Spacing.sm) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 64, height: 64)
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.green)
            }
            
            Text("Luar Biasa!")
                .font(.title2.bold())
            
            Text("Target harian tercapai.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button("Selesai") {
                dismiss()
            }
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.accentColor, in: RoundedRectangle(cornerRadius: CornerRadius.card))
            .foregroundColor(.white)
            .buttonStyle(.plain)
            .padding(.top, Spacing.md)
        }
        .padding(Spacing.lg)
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
