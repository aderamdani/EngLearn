import SwiftUI
import SwiftData

struct StreakHeatmapView: View {
    @Query(sort: \DailyStreak.date, order: .forward) 
    private var streaks: [DailyStreak]
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let daysToShow = 28
    private let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            headerView
            
            VStack(spacing: 4) {
                dayLabelsRow
                
                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(lastDays, id: \.self) { date in
                        dayCell(for: date)
                    }
                }
            }
            .drawingGroup()
            
            legendView
        }
        .padding(Spacing.lg)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: CornerRadius.card))
        .glassEffect(.regular, in: .rect(cornerRadius: CornerRadius.card))
    }
    
    private var headerView: some View {
        HStack {
            Label("Aktivitas Belajar", systemImage: "flame.fill")
                .font(.headline)
                .foregroundColor(.orange)
            
            Spacer()
            
            if let month = monthLabel {
                Text(month)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var dayLabelsRow: some View {
        HStack(spacing: 0) {
            ForEach(dayLabels, id: \.self) { label in
                Text(label)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private func dayCell(for date: Date) -> some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(color(for: date))
            .aspectRatio(1, contentMode: .fit)
            .accessibilityLabel(accessibilityLabel(for: date))
    }
    
    private var legendView: some View {
        HStack(spacing: Spacing.sm) {
            Text("0 min").font(.system(size: 8)).foregroundColor(.secondary)
            legendCell(color: .gray.mix(with: .white, by: 0.9))
            legendCell(color: .green.mix(with: .white, by: 0.6))
            legendCell(color: .green.mix(with: .white, by: 0.3))
            legendCell(color: .green)
            Text("30+ min").font(.system(size: 8)).foregroundColor(.secondary)
        }
    }
    
    private func legendCell(color: Color) -> some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: 8, height: 8)
    }
    
    // MARK: - Helper Logic
    
    private var lastDays: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        return (0..<daysToShow).reversed().compactMap { day in
            calendar.date(byAdding: .day, value: -day, to: today)
        }
    }
    
    private var monthLabel: String? {
        guard let firstDay = lastDays.first else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: firstDay)
    }
    
    private func color(for date: Date) -> Color {
        guard let streak = streaks.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) else {
            return .gray.mix(with: .white, by: 0.9)
        }
        
        if streak.minutesSpent >= 30 { return .green }
        if streak.minutesSpent >= 15 { return .green.mix(with: .white, by: 0.3) }
        if streak.minutesSpent > 0 { return .green.mix(with: .white, by: 0.6) }
        return .gray.mix(with: .white, by: 0.9)
    }
    
    private func accessibilityLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateString = formatter.string(from: date)
        
        if let streak = streaks.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }), streak.minutesSpent > 0 {
            return String(localized: "Aktivitas pada \(dateString): \(streak.minutesSpent) menit", comment: "Heatmap cell accessibility")
        } else {
            return String(localized: "Tidak ada aktivitas pada \(dateString)", comment: "Heatmap cell accessibility")
        }
    }
}

#Preview {
    StreakHeatmapView()
        .modelContainer(for: DailyStreak.self, inMemory: true)
        .padding()
}
