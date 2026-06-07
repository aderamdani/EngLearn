import SwiftUI
import SwiftData
import OSLog

struct GrammarModuleView: View {
    @State private var selectedLevel: CEFRLevel = .a1
    @State private var lessons: [Lesson] = []
    @State private var isLoading = false
    @State private var searchQuery = ""
    
    private let lessonService = LessonService()
    
    @Query private var lessonRecords: [LessonRecord]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                levelPicker
                
                if isLoading {
                    ProgressView("Memuat materi...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    lessonList
                }
            }
            .navigationTitle("Grammar")
            .searchable(text: $searchQuery, prompt: "Cari pelajaran...")
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
        .glassEffect(.regular, in: .rect(cornerRadius: CornerRadius.card))
        .padding(.horizontal, Spacing.lg)
    }
    
    private var lessonList: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md) {
                if filteredLessons.isEmpty {
                    emptyState
                } else {
                    ForEach(Array(filteredLessons.enumerated()), id: \.element.id) { index, lesson in
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
    
    private var filteredLessons: [Lesson] {
        if searchQuery.isEmpty {
            return lessons
        }
        return lessons.filter { $0.title.localizedCaseInsensitiveContains(searchQuery) }
    }
    
    private func lessonCard(_ lesson: Lesson, index: Int) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: "textformat")
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial, in: Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(lesson.title)
                    .font(.headline)
                
                Text("\(lesson.exercises.count) Latihan")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                difficultyBar(level: lesson.level)
            }
            
            Spacer()
            
            if let record = lessonRecords.first(where: { $0.lessonID == lesson.id }) {
                progressBadge(score: record.scorePercentage)
            }
            
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
        .accessibilityLabel("\(lesson.title), \(lesson.exercises.count) latihan")
    }
    
    private func difficultyBar(level: CEFRLevel) -> some View {
        HStack(spacing: 2) {
            let count = (level == .a1 || level == .a2) ? 1 : (level == .b1 || level == .b2 ? 2 : 3)
            ForEach(0..<3) { i in
                RoundedRectangle(cornerRadius: 1)
                    .fill(i < count ? Color.orange : Color.primary.opacity(0.1))
                    .frame(width: 12, height: 3)
            }
        }
        .padding(.top, 2)
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
        VStack(spacing: Spacing.md) {
            Text("Belum Ada Materi")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Button("Refresh") {
                Task { await loadLessons() }
            }
            .buttonStyle(.bordered)
        }
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
