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
            .background(.regularMaterial)
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
                    ForEach(Array(lessons.enumerated()), id: \.element.id) { index, lesson in
                        NavigationLink(destination: GrammarLessonView(lesson: lesson)) {
                            lessonCard(lesson, index: index + 1)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(Spacing.lg)
        }
    }
    
    private func lessonCard(_ lesson: Lesson, index: Int) -> some View {
        HStack(spacing: Spacing.md) {
            lessonIcon(index: index)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(lesson.title)
                        .font(.headline)
                    Spacer()
                    exerciseCountBadge(count: lesson.exercises.count)
                }
                
                if let preview = lesson.explanation?.ruleID.components(separatedBy: ".").first {
                    Text(preview + ".")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                difficultyBar(level: lesson.level)
            }
            
            if let record = lessonRecords.first(where: { $0.lessonID == lesson.id }) {
                progressBadge(score: record.scorePercentage)
            }
        }
        .padding(Spacing.lg)
        .background(.background, in: RoundedRectangle(cornerRadius: CornerRadius.card))
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: CornerRadius.card))
        .accessibilityLabel("\(lesson.title), pelajaran \(index)")
    }
    
    private func lessonIcon(index: Int) -> some View {
        ZStack {
            Circle()
                .fill(Color.accentColor.mix(with: .white, by: 0.9))
                .frame(width: 40, height: 40)
            
            Text("\(index)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.accentColor)
        }
    }
    
    private func exerciseCountBadge(count: Int) -> some View {
        Text("\(count) Q")
            .font(.system(size: 8, weight: .bold))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(.ultraThinMaterial, in: Capsule())
    }
    
    private func difficultyBar(level: CEFRLevel) -> some View {
        HStack(spacing: 2) {
            let count = (level == .a1 || level == .a2) ? 1 : (level == .b1 || level == .b2 ? 2 : 3)
            ForEach(0..<3) { i in
                RoundedRectangle(cornerRadius: 1)
                    .fill(i < count ? Color.orange : Color.secondary.opacity(0.2))
                    .frame(width: 12, height: 3)
            }
        }
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
