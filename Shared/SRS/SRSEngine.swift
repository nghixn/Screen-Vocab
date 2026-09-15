import Foundation

/// Simple Leitner-box spaced repetition scheduler.
/// Box 1 = just introduced / just forgotten, box 6 = well retained.
enum SRSEngine {
    static let minBox = 1
    static let maxBox = 6

    private static let boxIntervalHours: [Int: Double] = [
        1: 1,     // 1 hour
        2: 4,     // 4 hours
        3: 24,    // 1 day
        4: 72,    // 3 days
        5: 168,   // 1 week
        6: 504    // 3 weeks
    ]

    static func nextDueDate(afterBox box: Int, from date: Date = Date()) -> Date {
        let hours = boxIntervalHours[box] ?? 1
        return date.addingTimeInterval(hours * 3600)
    }

    static func recordResult(progress: WordProgress, remembered: Bool, now: Date = Date()) -> WordProgress {
        var updated = progress
        updated.lastReviewed = now
        updated.totalReviews += 1
        if remembered {
            updated.correctStreak += 1
            updated.box = min(updated.box + 1, maxBox)
        } else {
            updated.correctStreak = 0
            updated.box = minBox
        }
        updated.nextDueDate = nextDueDate(afterBox: updated.box, from: now)
        return updated
    }
}
