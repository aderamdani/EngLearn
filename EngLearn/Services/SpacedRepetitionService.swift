import Foundation
import OSLog

struct SpacedRepetitionService: Sendable {
    func nextReviewDate(
        after quality: Int,
        currentEaseFactor: Double,
        currentInterval: Int,
        currentRepetitions: Int
    ) -> (nextDate: Date, newInterval: Int, newEaseFactor: Double, newRepetitions: Int) {
        let q = max(0, min(AppConstants.SM2.maxQuality, quality))
        var interval = currentInterval
        var repetitions = currentRepetitions
        var easeFactor = currentEaseFactor

        if q >= 3 {
            switch repetitions {
            case 0: interval = 1
            case 1: interval = 6
            default: interval = Int(Double(interval) * easeFactor)
            }
            repetitions += 1
        } else {
            repetitions = 0
            interval = 1
        }

        let ef = easeFactor + (0.1 - Double(5 - q) * (0.08 + Double(5 - q) * 0.02))
        easeFactor = max(AppConstants.SM2.minimumEaseFactor, ef)

        let nextDate = Calendar.current.date(
            byAdding: .day, value: interval, to: Date()
        ) ?? Date()

        Log.srs.debug(
            "SM-2: q=\(q) ef=\(String(format: "%.2f", easeFactor)) interval=\(interval)d reps=\(repetitions)"
        )

        return (nextDate, interval, easeFactor, repetitions)
    }
}
