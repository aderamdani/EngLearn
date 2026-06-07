import SwiftUI
import SwiftData

struct StreakHeatmapView: View {
    @Query(sort: \DailyStreak.date, order: .forward) 
    private var streaks: [DailyStreak]
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: Spacing.xs), count: 7)
    private let daysToShow = 28
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            headerView
            
            LazyVGrid(columns: columns, spacing: Spacing.xs) {
                ForEach(lastDays, id: \.self) { date in
                    dayCell(for: date)
                }
            }
            .drawingGroup()
        }
        .padding(Spacing.md)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: CornerRadius.card))
        .glassEffect(.regular, in: .rect(cornerRadius: CornerRadius.card))
    }
    
    private var headerView: some View {
        HStack {
            Image(systemName: "flame.fill")
                .foregroundColor(.orange)
            Text("Activity")
                .font(.headline)
            Spacer()
            Text("\(currentStreak) Day Streak")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private func dayCell(for date: Date) -> some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color(for: date))
            .aspectRatio(1, contentMode: .fit)
            .accessibilityLabel(accessibilityLabel(for: date))
    }
    
    // MARK: - Helper Logic
    
    private var lastDays: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        return (0..<daysToShow).reversed().compactMap { day in
            calendar.date(byAdding: .day, value: -day, to: today)
        }
    }
    
    private func color(for date: Date) -> Color {
        guard let streak = streaks.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) else {
            return Color.gray.mix(with: .white, by: 0.8)
        }
        
        if streak.minutesSpent >= 30 { return .green }
        if streak.minutesSpent >= 15 { return .green.mix(with: .white, by: 0.3) }
        if streak.minutesSpent > 0 { return .green.mix(with: .white, by: 0.6) }
        return Color.gray.mix(with: .white, by: 0.8)
    }
    
    private var currentStreak: Int {
        // Simple logic for preview/demo, in real app would calculate from streaks array
        streaks.count // Placeholder
    }
    
    private func accessibilityLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateString = formatter.string(from: date)
        
        if let streak = streaks.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }), streak.minutesSpent > 0 {
            return String(localized: "Aktivitas pada \(dateString): \(streak.minutesSpent) menit", comment: "Heatmap cell accessibility label with activity")
        } else {
            return String(localized: "Tidak ada aktivitas pada \(dateString)", comment: "Heatmap cell accessibility label no activity")
        }
    }
}

#Preview {
    StreakHeatmapView()
        .modelContainer(for: DailyStreak.self, inMemory: true)
        .padding()
}
