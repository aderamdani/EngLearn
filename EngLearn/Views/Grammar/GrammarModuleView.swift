import SwiftUI
import SwiftData
import OSLog

struct GrammarModuleView: View {
    @State private var selectedLevel: CEFRLevel = .a1
    @State private var lessons: [Lesson] = []
    @State private var isLoading = false
    
    private let lessonService = LessonService()
    
    @Query private var lessonRecords: [LessonRecord]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                levelPicker
                
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    lessonList
                }
            }
            .navigationTitle("Grammar")
            .task(id: selectedLevel) {
                await loadLessons()
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
    
    private var lessonList: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md) {
                if lessons.isEmpty {
                    emptyState
                } else {
                    ForEach(lessons) { lesson in
                        NavigationLink(destination: GrammarLessonView(lesson: lesson)) {
                            lessonCard(lesson)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(Spacing.lg)
        }
    }
    
    private func lessonCard(_ lesson: Lesson) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(lesson.title)
                    .font(.headline)
                
                Text("\(lesson.exercises.count) Latihan")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let record = lessonRecords.first(where: { $0.lessonID == lesson.id }) {
                progressBadge(score: record.scorePercentage)
            }
        }
        .padding(Spacing.lg)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: CornerRadius.card))
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: CornerRadius.card))
        .accessibilityLabel("\(lesson.title), \(lesson.exercises.count) latihan")
    }
    
    private func progressBadge(score: Double) -> some View {
        Text("\(Int(score))%")
            .font(.caption.bold())
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(score >= 80 ? Color.green : Color.orange, in: Capsule())
            .foregroundColor(.white)
    }
    
    private var emptyState: some View {
        ContentUnavailableView(
            "Belum Ada Materi",
            systemImage: "book.closed",
            description: Text("Materi grammar untuk level \(selectedLevel.displayName) sedang dalam perjalanan!")
        )
        .padding(.top, Spacing.xxxl)
    }
    
    private func loadLessons() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            lessons = try lessonService.lessons(for: .grammar, level: selectedLevel)
        } catch {
            Log.lessons.error("Gagal memuat pelajaran: \(error.localizedDescription)")
            lessons = []
        }
    }
}

#Preview {
    GrammarModuleView()
        .modelContainer(for: [LessonRecord.self], inMemory: true)
}
