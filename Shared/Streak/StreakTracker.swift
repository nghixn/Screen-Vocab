import Foundation

/// Tracks consecutive days of actual review activity (marking a word
/// Remembered/Forgot in FlashcardView) — not just opening the app or
/// glancing at the widget, since that would make the streak meaningless.
enum StreakTracker {
    /// Call once per review action. Multiple reviews on the same day only
    /// count once; missing a day resets the streak to 1 on the next review.
    static func recordActivity(now: Date = Date()) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        var data = SharedStore.loadStreak()

        if let lastDay = data.lastActiveDay {
            let daysSince = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if daysSince == 0 {
                return // already recorded today
            } else if daysSince == 1 {
                data.currentStreak += 1
            } else {
                data.currentStreak = 1
            }
        } else {
            data.currentStreak = 1
        }

        data.longestStreak = max(data.longestStreak, data.currentStreak)
        data.lastActiveDay = today
        SharedStore.saveStreak(data)
    }

    /// Read-only view for display: if more than a day has passed since the
    /// last review, the streak is already broken even though nothing has
    /// re-recorded it yet, so reflect that here without mutating storage.
    static func currentStatus(now: Date = Date()) -> StreakData {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        var data = SharedStore.loadStreak()
        if let lastDay = data.lastActiveDay {
            let daysSince = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if daysSince > 1 {
                data.currentStreak = 0
            }
        }
        return data
    }
}
